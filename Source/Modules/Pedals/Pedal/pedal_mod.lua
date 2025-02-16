--[[
	NOT an effect, but it is a pedal, and so are the effects so...
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/Pedals/Pedal/pedal_component'

class('PedalMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 85
local moduleHeight = 120

local modType = "PedalMod"
local modSubtype = "clock_router"

local mode_simple = 1
local mode_momentary = 2
local mode_countdown = 3
local mode_countdown_running = 4

local socketImage = gfx.image.new("Images/small_socket")

function PedalMod:init(xx, yy, modId)
	PedalMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.upPending = false
	
	self.mode = mode_momentary
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	gfx.pushContext(backgroundImage)	
	socketImage:draw(25, 25)
	gfx.drawText("PS-1", 60, 27)
	local rightSocket = assets:image("side_socket_right")	
	rightSocket:draw(gPedalRightJackX, gPedalAudioIOY)
	generateHalftoneRoundedRect(71, 80, 0.2):draw(20, 45)
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.component = PedalComponent(function() 
	
	end)

	self.socketInVector = Vector(xx - (moduleWidth/2) + 17, yy - (moduleHeight/2) + 17)
	self.socketOutVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + gPedalAudioIOY)
	
end

function PedalMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function PedalMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function PedalMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function PedalMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype, onError)
	if sourceSubtype ~= "clock_router" then 
		if onError ~= nil then onError("This input requires a clock signal") end
		return false 
	elseif self.component:inConnected() then
		print("PedalMod:tryConnectGhostIn - already connected")
		onError("Already connected")
		return false
	else
		print("PedalMod:tryConnectGhostIn - connecting...")
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end


function PedalMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function PedalMod:type() return self.modType end
function PedalMod:getModId() return self.modId end
function PedalMod:unplug(cableId) self.component:unplug(cableId) end
function PedalMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function PedalMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function PedalMod:moveFinish()
	self.socketInVector = Vector(self.x - (moduleWidth/2) + 17, self.y - (moduleHeight/2) + 17)
	self.socketOutVector = Vector	(self.x + (moduleWidth/2) + 2, self.y - (moduleHeight/2) + gPedalAudioIOY)
end

function PedalMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.component:unplugIn()
		self.inCable:evaporate()
	end
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
	
	self:remove()
end

function PedalMod:handleModClickPedal(tX, tY)
	self.upPending = true
	self:moveBy(0, 2)
	if self.mode == mode_countdown then
		local countdownTimer = playdate.timer.new(4000, function() 
			self.component:bang()
			self.mode = mode_countdown_running
		end)
		
		local oneSecondFired = false
		local twoSecondFired = false
		local threeSecondFired = false
		countdownTimer.updateCallback = function()
			local elapsed = countdownTimer.currentTime
			if elapsed < 1000 then
				--do nothing
			elseif elapsed < 2000 and not oneSecondFired then
					oneSecondFired = true
					self.component:beep()
			elseif elapsed > 2000 and elapsed < 3000 and not twoSecondFired then
				twoSecondFired = true
				self.component:beep()
			elseif elapsed > 3000 and elapsed < 4000 and not threeSecondFired then
				threeSecondFired = true
				self.component:beep()
			end
		end
	elseif self.mode == mode_countdown_running then
		self.component:unbang()
		self.mode = mode_countdown
	elseif self.component:outConnected() then
		self.component:bang()
	end
end

function PedalMod:handleModClickUp(tX, tY, listener)
	if self.upPending then
		self.upPending = false
		self:moveBy(0, -2)
	end
	if self.mode == mode_momentary then
		if self.component:outConnected() then
			self.component:unbang()
		end
	end
end

function PedalMod:handleModClick(tX, tY, listener)
	if tY > self.y - 20 then
		self:handleModClickPedal(tX, tY)
	else
		self.menuListener = listener
		local actions = {
			{label = "Mode: Single"},
			{label = "Mode: Momentary"},
			{label = "Mode: Countdown"},
			{label = "About"},
			{label = "Move"},
			{label = "Remove"}
		}
		local contextMenu = ModuleMenu(actions)
		contextMenu:show(function(action) 
			if action == "Mode: Single" then
				self.mode = mode_simple
			elseif action == "Mode: Momentary" then
				self.mode = mode_momentary
				self:redrawBackground()
			elseif action == "Mode: Countdown" then
				self.mode = mode_countdown
				self:redrawBackground()
			elseif action == "About" then
				local aboutPopup = ModAboutPopup("A pedal. Three modes: single emits an event when tapped, momentary emits one event when pressed, and another when released. Countdown will play 3 audible tones before toggling, only useful with the Sampler module. The input socket is for use with an external midi signal.")
				aboutPopup:show()
			else
				if self.menuListener ~= nil then 
					self.menuListener(action) 
				end
			end
		end)
	end
end

function PedalMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	return modState
end

function PedalMod:fromState(modState)
	--noop
end