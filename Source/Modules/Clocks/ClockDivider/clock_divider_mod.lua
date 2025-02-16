--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Clocks/ClockDivider/clock_divider_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'

class('ClockDividerMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 75
local moduleHeight = 50

local modType = "ClockDividerMod"
local modSubtype = "clock_router"

function ClockDividerMod:init(xx, yy, modId)
	ClockDividerMod.super.init(self)
	
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
	clock:drawCentered(bgW/2 - 20, bgH/2)
	
	gfx.drawTextAligned(">", bgW/2, bgH/2 - 4, kTextAlignment.center)
	
	local clockHalved = playdate.graphics.image.new("Images/clock_halved")
	clockHalved:drawCentered(bgW/2 + 20, bgH/2)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()

	self.socketInVector = Vector(xx - 36, yy)
	self.socketOutVector = Vector(xx + 36, yy)

	self.component = ClockDividerComponent()
end


function ClockDividerMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function ClockDividerMod:setOutCable(patchCable)
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function ClockDividerMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function ClockDividerMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype, onError)
	if sourceSubtype ~= "clock_router" then 
		if onError ~= nil then onError("This input requires a clock signal") end
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

function ClockDividerMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function ClockDividerMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Emits every other event, halving the clock rate.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function ClockDividerMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function ClockDividerMod:moveFinish()	
	self.socketInVector = Vector(self.x - 36, self.y)
	self.socketOutVector = Vector(self.x + 36, self.y)
end

function ClockDividerMod:evaporate(onDetachConnected)
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

function ClockDividerMod:type() return modType end
function ClockDividerMod:getModId() return self.modId end
function ClockDividerMod:unplug(cableId) self.component:unplug(cableId) end
function ClockDividerMod.ghostModule()return buildGhostModule(moduleWidth, moduleHeight) end

function ClockDividerMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	return modState
end

function ClockDividerMod:fromState(modState)
	--noop
end