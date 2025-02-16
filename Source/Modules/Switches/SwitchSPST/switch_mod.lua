--[[
	© 2023 Orllewin - All Rights Reserved.
	
	Off, swallows an event, on lets it through.
	Live use - toggle menu
]]--
import 'Modules/mod_utils.lua'
import 'Modules/Sprites/small_socket_sprite'
import 'Modules/Switches/SwitchSPST/switch_component'

class('SwitchMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 50
local moduleHeight = 50

local modType = "SwitchMod"
local modSubtype = "clock_router"

local offImage = gfx.image.new("Images/switch_open")
local onImage = gfx.image.new("Images/switch_closed")

function SwitchMod:init(xx, yy, modId)
	SwitchMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
		
	self.component = SwitchComponent("synth_module", function(event) 
		self:redraw() 	
	end)
	
	self:redraw()
	self:moveTo(xx, yy)
	self:add()
	
	self.socketInVector = Vector(xx - 25, yy + 8)
	self.socketOutVector = Vector(xx + 25, yy + 8)
	self.automationInVector = Vector(xx, yy + 28)
	
	self.inVectors = {
		self.socketInVector,
		self.automationInVector
	}

end

function SwitchMod:redraw()
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = backgroundImage:getSize()
	self.bgH = bgH
	
	gfx.pushContext(backgroundImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
		
	gfx.drawTextAligned(">", 22, bgH/2 - 1, kTextAlignment.center)
	gfx.drawTextAligned(">", 56, bgH/2 - 1, kTextAlignment.center)
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 32)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(62, 32)
	
	local bottomSocket = assets:image("side_socket_bottom")
	bottomSocket:draw(30, 63)
	
	if self.component:isOn() then
		onImage:draw(29, 33)
		gfx.drawTextAligned("On" , bgW/2, 20, kTextAlignment.center)
	else
		offImage:draw(29, 33)
		gfx.drawTextAligned("Off" , bgW/2, 20, kTextAlignment.center)
	end
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
end

function SwitchMod:findClosestInVector(x, y)
	local reticleVector = Vector(x, y)
	local closestDistance = 1000
	local closestIndex = -1
	for i=1,#self.inVectors do
		local aVector = self.inVectors[i]
		local distance = reticleVector:distance(aVector)
		if distance < closestDistance then
			closestDistance = distance
			closestIndex = i
		end
	end
	return self.inVectors[closestIndex]
end

function SwitchMod:setInCable(patchCable)
	local cableX, cableY = patchCable:getEndXY()
	local inVector = self:findClosestInVector(cableX, cableY)

	if inVector.x == self.socketInVector.x then
		patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
		self.inCable = patchCable
		self.component:setInCable(patchCable:getCable())
	elseif inVector.x == self.automationInVector.x then
		patchCable:setEnd(self.automationInVector.x, self.automationInVector.y, self.modId)
		self.inToggleCable = patchCable
		self.component:setToggleInCable(patchCable:getCable())
	end
end

function SwitchMod:setOutCable(patchCable)
	patchCable:setEnd(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function SwitchMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function SwitchMod:tryConnectGhostIn(x, y, ghostCable)
	local inVector = self:findClosestInVector(x, y)
	ghostCable:setEnd(inVector.x, inVector.y)
	ghostCable:setGhostReceiveConnected()
	return true
end

function SwitchMod:tryConnectGhostOut(x, y, ghostCable)
	ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
	ghostCable:setGhostSendConnected()
	return true
end

function SwitchMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	
	local actions = {
		{label = "Toggle"},
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "Toggle" then
			self.component:toggle()
			self:redraw()	
		elseif action == "About" then
			local aboutPopup = ModAboutPopup("A switch, use to toggle different patterns in your patch.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function SwitchMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end
function SwitchMod:type() return modType end
function SwitchMod:getModId() return self.modId end
function SwitchMod:unplug(cableId) self.component:unplug(cableId) end

function SwitchMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function SwitchMod:moveFinish()
	self.socketInVector = Vector(self.x - 25, self.y + 8)
	self.socketOutVector = Vector(self.x + 25, self.y + 8)
	self.automationInVector = Vector(self.x, self.y + 28)
	
	self.inVectors = {
		self.socketInVector,
		self.automationInVector
	}
end

function SwitchMod:evaporate(onDetachConnected)
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

function SwitchMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	--todo
	
	return modState
end

function SwitchMod:fromState(modState)
	--todo
end