--[[
	© 2023 Orllewin - All Rights Reserved.
	
	Two outputs, one input.
]]
import 'Modules/mod_utils.lua'
import 'Modules/Clocks/Bifurcate2/bifurcate2_component'

class('Bifurcate2Mod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 50
local moduleHeight = 50

local rotationRight = 1
local rotationDown = 2
local rotationLeft = 3
local rotatioUp = 4

local modType = "Bifurcate2Mod"
local modSubtype = "clock_router_or_midi"

function Bifurcate2Mod:init(xx, yy, modId)
	Bifurcate2Mod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.rotation = rotationRight
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	
	gfx.pushContext(backgroundImage)	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 32)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(62, 20)
	rightSocket:draw(62, 40)
	
	local bifurcateImage = playdate.graphics.image.new("Images/bifurcate_two")
	bifurcateImage:draw(24, 28)
	

	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()

	self.value = 0.0
		
	self.socketInVector = Vector(xx - 25, 	yy)
	self.socketOutAVector = Vector(xx + 25, yy - 15)
	self.socketOutBVector = Vector(xx + 25, yy + 15)
	
	self.component = Bifurcate2Component()
end

function Bifurcate2Mod:onRotate()
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	local leftSocket = assets:image("side_socket_left")
	local rightSocket = assets:image("side_socket_right")
	local bottomSocket = assets:image("side_socket_bottom")
	local topSocket = assets:image("side_socket_up")
	gfx.pushContext(backgroundImage)	

	local bifurcateImage = playdate.graphics.image.new("Images/bifurcate_two")
	if self.rotation == rotationRight then
		bifurcateImage:draw(24, 28)
		leftSocket:draw(10, 32)
		rightSocket:draw(62, 20)
		rightSocket:draw(62, 40)
		self.socketInVector = Vector(self.x - 25, 	self.y)
		self.socketOutAVector = Vector(self.x + 25, self.y - 15)
		self.socketOutBVector = Vector(self.x + 25, self.y + 15)
	elseif self.rotation == rotationDown then
		bifurcateImage:drawRotated(40, 38, 90)
		bottomSocket:draw(21, 62)
		bottomSocket:draw(42, 62)
		topSocket:draw(32, 10)
		self.socketInVector = Vector(self.x, 	self.y - 25)
		self.socketOutAVector = Vector(self.x - 15, self.y + 25)
		self.socketOutBVector = Vector(self.x + 15, self.y + 25)
	elseif self.rotation == rotationLeft then
		bifurcateImage:draw(26, 28, playdate.graphics.kImageFlippedX)
		rightSocket:draw(62, 32)
		leftSocket:draw(10, 20)
		leftSocket:draw(10, 40)
		self.socketInVector = Vector(self.x + 25, 	self.y)
		self.socketOutAVector = Vector(self.x - 25, self.y - 15)
		self.socketOutBVector = Vector(self.x - 25, self.y + 15)
	elseif self.rotation == rotationUp then
		bifurcateImage:drawRotated(40, 38, -90)
		topSocket:draw(21, 10)
		topSocket:draw(42, 10)
		bottomSocket:draw(32, 62)
		self.socketInVector = Vector(self.x, 	self.y + 25)
		self.socketOutAVector = Vector(self.x - 15, self.y - 25)
		self.socketOutBVector = Vector(self.x + 15, self.y - 25)
	end
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
end

function Bifurcate2Mod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function Bifurcate2Mod:setOutCable(patchCable)
	if not self.component:outAConnected() then
		patchCable:setStart(self.socketOutAVector.x, self.socketOutAVector.y, self.modId)
		self.outACable = patchCable
		self.component:setOutACable(patchCable:getCable())
	elseif not self.component:outBConnected() then
		patchCable:setStart(self.socketOutBVector.x, self.socketOutBVector.y, self.modId)
		self.outBCable = patchCable
		self.component:setOutBCable(patchCable:getCable())
	end
end

function Bifurcate2Mod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function Bifurcate2Mod:tryConnectGhostIn(x, y, ghostCable)
	if ghostCable:getStartModId() == self.modId then
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

function Bifurcate2Mod:tryConnectGhostOut(x, y, ghostCable)
	if not self.component:outAConnected() then
		ghostCable:setStart(self.socketOutAVector.x, self.socketOutAVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	elseif not self.component:outBConnected() then
		ghostCable:setStart(self.socketOutBVector.x, self.socketOutBVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	else
		return false
	end
end

function Bifurcate2Mod:type()
	return modType
end

function Bifurcate2Mod:getModId()
	return self.modId
end

function Bifurcate2Mod:handleModClick(tX, tY, listener)
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
			local aboutPopup = ModAboutPopup("Splits / duplicates a clock signal. Can be rotated, but only before cables are attached")
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

function Bifurcate2Mod:unplug(cableId)
	self.component:unplug(cableId)
end

function Bifurcate2Mod:repositionBy(x, y)
	self:moveBy(x, y)
end

function Bifurcate2Mod:moveFinish()
	if self.rotation == rotationRight then
		self.socketInVector = Vector(self.x - 25, 	self.y)
		self.socketOutAVector = Vector(self.x + 25, self.y - 15)
		self.socketOutBVector = Vector(self.x + 25, self.y + 15)
	elseif self.rotation == rotationDown then
		self.socketInVector = Vector(self.x, 	self.y - 25)
		self.socketOutAVector = Vector(self.x - 15, self.y + 25)
		self.socketOutBVector = Vector(self.x + 15, self.y + 25)
	elseif self.rotation == rotationLeft then
		self.socketInVector = Vector(self.x + 25, 	self.y)
		self.socketOutAVector = Vector(self.x - 25, self.y - 15)
		self.socketOutBVector = Vector(self.x - 25, self.y + 15)
	elseif self.rotation == rotationUp then
		self.socketInVector = Vector(self.x, 	self.y + 25)
		self.socketOutAVector = Vector(self.x - 15, self.y - 25)
		self.socketOutBVector = Vector(self.x + 15, self.y - 25)
	end
end

function Bifurcate2Mod:evaporate(onDetachConnected)
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
	
	self:remove()
end

function Bifurcate2Mod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function Bifurcate2Mod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.rotation = self.rotation
	return modState
end

function Bifurcate2Mod:fromState(modState)
	self.rotation = modState.rotation
	self:onRotate()
end