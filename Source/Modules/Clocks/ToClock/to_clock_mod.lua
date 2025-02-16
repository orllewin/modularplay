--[[
	
	Coerce any input to a clock event
	
	© 2024 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Clocks/ToClock/to_clock_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'

class('ToClockMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 75
local moduleHeight = 50

local modType = "ToClockMod"
local modSubtype = "clock_router"

function ToClockMod:init(xx, yy, modId)
	ToClockMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	gfx.pushContext(backgroundImage)
		
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 32)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(87, 32)
	
	local clock = playdate.graphics.image.new("Images/clock")
	clock:drawCentered(bgW/2 + 20, bgH/2)
	
	gfx.drawTextAligned(">", bgW/2, bgH/2 - 4, kTextAlignment.center)
	
	local clockHalved = playdate.graphics.image.new("Images/unknown_signal")
	clockHalved:drawCentered(bgW/2 - 20, bgH/2)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()

	self.socketInVector = Vector(xx - 36, yy)
	self.socketOutVector = Vector(xx + 36, yy)

	self.component = ToClockComponent()
end


function ToClockMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function ToClockMod:setOutCable(patchCable)
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function ToClockMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function ToClockMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype, onError)
	if sourceSubtype == "audio_gen" then 
		if onError ~= nil then onError("This input requires anything but an audio signal") end
		return false 
	elseif ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function ToClockMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function ToClockMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Coerces any non-audio input into a clock event.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function ToClockMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function ToClockMod:moveFinish()	
	self.socketInVector = Vector(self.x - 36, self.y)
	self.socketOutVector = Vector(self.x + 36, self.y)
end

function ToClockMod:evaporate(onDetachConnected)
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

function ToClockMod:type() return modType end
function ToClockMod:getModId() return self.modId end
function ToClockMod:unplug(cableId) self.component:unplug(cableId) end
function ToClockMod.ghostModule()return buildGhostModule(moduleWidth, moduleHeight) end

function ToClockMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	return modState
end

function ToClockMod:fromState(modState)
	--noop
end