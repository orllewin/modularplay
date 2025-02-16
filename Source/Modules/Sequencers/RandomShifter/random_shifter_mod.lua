--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'Modules/Sequencers/RandomShifter/random_shifter_component'

class('RandomShifterMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 50
local moduleHeight = 50

local modType = "RandomShifterMod"
local modSubtype = "midi"

function RandomShifterMod:init(xx, yy, modId)
	RandomShifterMod.super.init(self)
	
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
	rightSocket:draw(62, 32)
	
	gfx.drawTextAligned("+-12", bgW/2, bgH/2 - 2, kTextAlignment.center)
	
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()

	self.socketInVector = Vector(xx - 25, 	yy)
	self.socketOutVector = Vector(xx + 25, 	yy)
	
	self.component = RandomShifterComponent()
end

function RandomShifterMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function RandomShifterMod:setOutCable(patchCable)
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function RandomShifterMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function RandomShifterMod:tryConnectGhostIn(x, y, ghostCable)
	--todo - check in cable type
	--todo stop connecting to self
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function RandomShifterMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function RandomShifterMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Emits a random value when it receives a 'bang'.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function RandomShifterMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function RandomShifterMod:moveFinish()
	self.socketInVector = Vector(self.x - 25, self.y)
	self.socketOutVector = Vector(self.x + 25, self.y)
end

function RandomShifterMod:evaporate(onDetachConnected)
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
	
	--then remove sprites
	playdate.graphics.sprite.removeSprites({self.inSocketSprite, self.outSocketSprite})
	self.inSocketSprite = nil
	self.outSocketSprite = nil
	self:remove()
end

function RandomShifterMod:type() return modType end
function RandomShifterMod:getModId() return self.modId end
function RandomShifterMod:unplug(cableId) 
	if self.component:inConnected() and self.inCable:getCableId() == cableId then
		print("Unplugging in")
		self.component:unplugIn()
		self.inCable = nil
	end
	if self.component:outConnected() and self.outCable:getCableId() == cableId then
		self.component:unplugOut()
		self.outCable = nil
	end
	self.component:unplug(cableId) 
end
function RandomShifterMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function RandomShifterMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	return modState
end

function RandomShifterMod:fromState(modState)
	--noop
end