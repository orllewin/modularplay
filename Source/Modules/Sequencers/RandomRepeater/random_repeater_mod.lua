--[[
	© 2023 Orllewin - All Rights Reserved.
	
	Four outputs, one input.
]]
import 'Modules/mod_utils.lua'
import 'Modules/Sequencers/RandomRepeater/random_repeater_component'

class('RandomRepeaterMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 25
local moduleHeight = 100

local rotationRight = 1
local rotationDown = 2
local rotationLeft = 3
local rotatioUp = 4

local modType = "RandomRepeaterMod"
local modSubtype = "clock_router_or_midi"

function RandomRepeaterMod:init(xx, yy, modId)
	RandomRepeaterMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.rotation = rotationRight
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	
	gfx.pushContext(backgroundImage)	
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 56)
		
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(37, 18)
	rightSocket:draw(37, 43)
	rightSocket:draw(37, 68)
	rightSocket:draw(37, 92)
	
	local bifurcateImage = playdate.graphics.image.new("Images/random_repeater")
	bifurcateImage:draw(12, 14)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
		
	self.socketInVector = Vector(self.x - 13, 	self.y)
	self.socketOutAVector = Vector(self.x + 13, self.y - 40)
	self.socketOutBVector = Vector(self.x + 13, self.y - 15)
	self.socketOutCVector = Vector(self.x + 13, self.y + 15)
	self.socketOutDVector = Vector(self.x + 13, self.y + 40)
	
	self.component = RandomRepeaterComponent()
end

function RandomRepeaterMod:onRotate()
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	
	gfx.pushContext(backgroundImage)	
	local leftSocket = assets:image("side_socket_left")
	local rightSocket = assets:image("side_socket_right")
	local bottomSocket = assets:image("side_socket_bottom")
	local topSocket = assets:image("side_socket_up")
	local bifurcateImage = playdate.graphics.image.new("Images/bifurcate_four")
	if self.rotation == rotationRight then
		leftSocket:draw(10, 32)
		topSocket:draw(20, 10)
		topSocket:draw(40, 10)
		bottomSocket:draw(20, 62)
		bottomSocket:draw(40, 62)
		bifurcateImage:drawRotated(37, 40, 90)
		self.socketInVector = Vector(self.x - 25, 	self.y)
		self.socketOutAVector = Vector(self.x - 15, self.y + 25)
		self.socketOutBVector = Vector(self.x + 15, self.y + 25)
		self.socketOutCVector = Vector(self.x - 15, self.y - 25)
		self.socketOutDVector = Vector(self.x + 15, self.y - 25)
	elseif self.rotation == rotationDown then
		bifurcateImage:drawRotated(40, 38, 180)
		topSocket:draw(32, 10)
		leftSocket:draw(10, 20)
		leftSocket:draw(10, 40)
		rightSocket:draw(62, 20)
		rightSocket:draw(62, 40)
		self.socketInVector = Vector(self.x, 	self.y - 25)
		self.socketOutAVector = Vector(self.x + 25, self.y - 15)
		self.socketOutBVector = Vector(self.x + 25, self.y + 15)
		self.socketOutCVector = Vector(self.x - 25, self.y - 15)
		self.socketOutDVector = Vector(self.x - 25, self.y + 15)
	elseif self.rotation == rotationLeft then
		rightSocket:draw(62, 32)
		topSocket:draw(20, 10)
		topSocket:draw(40, 10)
		bottomSocket:draw(20, 62)
		bottomSocket:draw(40, 62)
		bifurcateImage:drawRotated(42, 40, 270)
		self.socketInVector = Vector(self.x + 25, 	self.y)
		self.socketOutAVector = Vector(self.x - 15, self.y - 25)
		self.socketOutBVector = Vector(self.x + 15, self.y - 25)
		self.socketOutCVector = Vector(self.x - 15, self.y + 25)
		self.socketOutDVector = Vector(self.x + 15, self.y + 25)
	elseif self.rotation == rotationUp then
		bifurcateImage:draw(20, 25)
		bottomSocket:draw(32, 62)
		leftSocket:draw(10, 20)
		leftSocket:draw(10, 40)
		rightSocket:draw(62, 20)
		rightSocket:draw(62, 40)
		self.socketInVector = Vector(self.x, 	self.y + 25)
		self.socketOutAVector = Vector(self.x + 25, self.y - 15)
		self.socketOutBVector = Vector(self.x + 25, self.y + 15)
		self.socketOutCVector = Vector(self.x - 25, self.y - 15)
		self.socketOutDVector = Vector(self.x - 25, self.y + 15)
	end
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
end

function RandomRepeaterMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function RandomRepeaterMod:setOutCable(patchCable)
	if not self.component:outAConnected() then
		patchCable:setStart(self.socketOutAVector.x, self.socketOutAVector.y, self.modId)
		self.outACable = patchCable
		self.component:setOutACable(patchCable:getCable())
	elseif not self.component:outBConnected() then
		patchCable:setStart(self.socketOutBVector.x, self.socketOutBVector.y, self.modId)
		self.outBCable = patchCable
		self.component:setOutBCable(patchCable:getCable())
	elseif not self.component:outCConnected() then
		patchCable:setStart(self.socketOutCVector.x, self.socketOutCVector.y, self.modId)
		self.outCCable = patchCable
		self.component:setOutCCable(patchCable:getCable())
	elseif not self.component:outDConnected() then
		patchCable:setStart(self.socketOutDVector.x, self.socketOutDVector.y, self.modId)
		self.outDCable = patchCable
		self.component:setOutDCable(patchCable:getCable())
	end
end

function RandomRepeaterMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function RandomRepeaterMod:tryConnectGhostIn(x, y, ghostCable)
	if ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif not self.component:inConnected() then
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	else
		return false
	end
end

function RandomRepeaterMod:tryConnectGhostOut(x, y, ghostCable)
	if not self.component:outAConnected() then
		ghostCable:setStart(self.socketOutAVector.x, self.socketOutAVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	elseif not self.component:outBConnected() then
		ghostCable:setStart(self.socketOutBVector.x, self.socketOutBVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	elseif not self.component:outCConnected() then
		ghostCable:setStart(self.socketOutCVector.x, self.socketOutCVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	elseif not self.component:outDConnected() then
		ghostCable:setStart(self.socketOutDVector.x, self.socketOutDVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	else
		return false
	end

	
end

function RandomRepeaterMod:type()
	return modType
end

function RandomRepeaterMod:getModId()
	return self.modId
end

function RandomRepeaterMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	
	local actions = {}
	if self.component:allFree() then
		actions = {
			{label = "About"},
			{label = "Move"},
			{label = "Rotate"},
			{label = "Remove"}
		}
	else
		actions = {
			{label = "About"},
			{label = "Move"},
			{label = "Remove"}
		}
	end

	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Splits / duplicates a clock signal into four. Can be rotated, but only before cables are attached")
			aboutPopup:show()
		elseif action == "Rotate" then
			if self.rotation == rotationRight then
				self.rotation = rotationDown
				self:onRotate()
			elseif self.rotation == rotationDown then
				self.rotation = rotationLeft
				self:onRotate()
			elseif self.rotation == rotationLeft then
				self.rotation = rotationUp
				self:onRotate()
			elseif self.rotation == rotationUp then
				self.rotation = rotationRight
				self:onRotate()
			end
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function RandomRepeaterMod:unplug(cableId)
	self.component:unplug(cableId)
end

function RandomRepeaterMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function RandomRepeaterMod:moveFinish()	
	if self.rotation == rotationRight then
		self.socketInVector = Vector(self.x - 25, 	self.y)
		self.socketOutAVector = Vector(self.x - 15, self.y + 25)
		self.socketOutBVector = Vector(self.x + 15, self.y + 25)
		self.socketOutCVector = Vector(self.x - 15, self.y - 25)
		self.socketOutDVector = Vector(self.x + 15, self.y - 25)
	elseif self.rotation == rotationDown then
		self.socketInVector = Vector(self.x, 	self.y - 25)
		self.socketOutAVector = Vector(self.x + 25, self.y - 15)
		self.socketOutBVector = Vector(self.x + 25, self.y + 15)
		self.socketOutCVector = Vector(self.x - 25, self.y - 15)
		self.socketOutDVector = Vector(self.x - 25, self.y + 15)
	elseif self.rotation == rotationLeft then
		self.socketInVector = Vector(self.x + 25, 	self.y)
		self.socketOutAVector = Vector(self.x - 15, self.y - 25)
		self.socketOutBVector = Vector(self.x + 15, self.y - 25)
		self.socketOutCVector = Vector(self.x - 15, self.y + 25)
		self.socketOutDVector = Vector(self.x + 15, self.y + 25)
	elseif self.rotation == rotationUp then
		self.socketInVector = Vector(self.x, 	self.y + 25)
		self.socketOutAVector = Vector(self.x + 25, self.y - 15)
		self.socketOutBVector = Vector(self.x + 25, self.y + 15)
		self.socketOutCVector = Vector(self.x - 25, self.y - 15)
		self.socketOutDVector = Vector(self.x - 25, self.y + 15)
	end
end

function RandomRepeaterMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.component:unplugIn()
		self.inCable:evaporate()
		self.inCable = nil
	end
	
	if self.component:outAConnected() then
		onDetachConnected(self.outACable:getEndModId(), self.outACable:getCableId())
		self.component:unplugOutA()
		self.outACable:evaporate()
		self.outACable = nil
	end
	
	if self.component:outBConnected() then
		onDetachConnected(self.outBCable:getEndModId(), self.outBCable:getCableId())
		self.component:unplugOutB()
		self.outBCable:evaporate()
		self.outBCable = nil
	end
	
	if self.component:outCConnected() then
		onDetachConnected(self.outCCable:getEndModId(), self.outCCable:getCableId())
		self.component:unplugOutC()
		self.outCCable:evaporate()
		self.outCCable = nil
	end
	
	if self.component:outDConnected() then
		onDetachConnected(self.outDCable:getEndModId(), self.outDCable:getCableId())
		self.component:unplugOutD()
		self.outDCable:evaporate()
		self.outDCable = nil
	end
	
	self:remove()
end

function RandomRepeaterMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function RandomRepeaterMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.rotation = self.rotation
	return modState
end

function RandomRepeaterMod:fromState(modState)
	--NOOP
end