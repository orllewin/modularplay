--[[
	© 2023 Orllewin - All Rights Reserved.
	
	Two outputs, one input.
]]
import 'Modules/mod_utils.lua'
import 'Modules/Clocks/Merge2/merge2_component'

class('Merge2Mod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 50
local moduleHeight = 50

local modType = "Merge2Mod"
local modSubtype = "clock_router_or_midi"

function Merge2Mod:init(xx, yy, modId)
	Merge2Mod.super.init(self)
	
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
	leftSocket:draw(10, 20)
	leftSocket:draw(10, 40)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(62, 32)
	
	local bifurcateImage = playdate.graphics.image.new("Images/merge_two")
	bifurcateImage:draw(24, 28)

	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()

	self.value = 0.0
		
	self.socketInAVector = Vector(xx - 25, yy - 15)
	self.socketInBVector = Vector(xx - 25, yy + 15)
	self.socketOutVector = Vector(xx + 25, yy)
	
	self.component = Merge2Component()
end

function Merge2Mod:setInCable(patchCable)
	if not self.component:inAConnected() then
		patchCable:setEnd(self.socketInAVector.x, self.socketInAVector.y, self.modId)
		self.inACable = patchCable
		self.component:setInACable(patchCable:getCable())
	elseif not self.component:inBConnected() then
		patchCable:setEnd(self.socketInBVector.x, self.socketInBVector.y, self.modId)
		self.inBCable = patchCable
		self.component:setInBCable(patchCable:getCable())
	end
end

function Merge2Mod:setOutCable(patchCable)
	if not self.component:outConnected() then
		patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		self.outCable = patchCable
		self.component:setOutCable(patchCable:getCable())
	end
end

function Merge2Mod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function Merge2Mod:tryConnectGhostIn(x, y, ghostCable)
	if ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.component:inAConnected() and self.component:inBConnected() then
		return false
	else
		if self.component:inAConnected() then
			ghostCable:setEnd(self.socketInAVector.x, self.socketInAVector.y)
			ghostCable:setGhostReceiveConnected()
		else
			ghostCable:setEnd(self.socketInBVector.x, self.socketInBVector.y)
			ghostCable:setGhostReceiveConnected()
		end

		return true
	end
end

function Merge2Mod:tryConnectGhostOut(x, y, ghostCable)
	if not self.component:outConnected() then
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	else
		return false
	end
end

function Merge2Mod:type()
	return modType
end

function Merge2Mod:getModId()
	return self.modId
end

function Merge2Mod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	
	local actions = {
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}

	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Allows two sources to be connected to the same socket. eg. a synth can have two modules sending midi notes")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function Merge2Mod:unplug(cableId)
	self.component:unplug(cableId)
end

function Merge2Mod:repositionBy(x, y)
	self:moveBy(x, y)
end

function Merge2Mod:moveFinish()	
	self.socketInAVector = Vector(self.x - 25, self.y - 15)
	self.socketInBVector = Vector(self.x - 25, self.y + 15)
	self.socketOutVector = Vector(self.x + 25, self.y)
end

function Merge2Mod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:inAConnected() then
		onDetachConnected(self.inACable:getStartModId(), self.inACable:getCableId())
		self.component:unplugInA()
		self.inACable:evaporate()
		self.inACable = nil
	end
	
	if self.component:inBConnected() then
		onDetachConnected(self.inBCable:getStartModId(), self.inBCable:getCableId())
		self.component:unplugInB()
		self.inBCable:evaporate()
		self.inBCable = nil
	end
	
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
		self.outCable = nil
	end

	self:remove()
end

function Merge2Mod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function Merge2Mod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.rotation = self.rotation
	return modState
end

function Merge2Mod:fromState(modState)
	self.rotation = modState.rotation
end