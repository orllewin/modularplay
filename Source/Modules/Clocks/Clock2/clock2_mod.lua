--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Clocks/Clock2/clock2_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'

class('Clock2Mod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 50
local moduleHeight = 85

local modType = "Clock2Mod"
local modSubtype = "clock_router"

function Clock2Mod:init(xx, yy, modId)
	Clock2Mod.super.init(self)
	
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
	local socketImage = assets:getImage("small_socket")
	socketImage:draw(20, 20)
	socketImage:draw(42, 20)
	socketImage:draw(20, 42)
	socketImage:draw(42, 42)

	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.component = Clock2Component()
	
	self.clockEncoder = RotaryEncoder(xx, yy - moduleWidth/2 + 45, function(value) 
		local bpm = math.floor(map(value, 0.0, 1.0, 1, 200))
		self.component:setBPM(bpm)
	end)
	self.clockEncoder:setValue(map(120, 1, 200, 0.0, 1.0))
	
	self.socketOutAVector = Vector(xx - 10, yy - 30)
	self.socketOutBVector = Vector(xx + 10, yy - 30)
	self.socketOutCVector = Vector(xx -10, yy -1)
	self.socketOutDVector = Vector(xx +10, yy - 1)
end

function Clock2Mod:turn(x, y, change)
	self.clockEncoder:turn(change)
end

function Clock2Mod:setOutCable(patchCable)
	if self.component:aConnected() ~= true then
		self.outACable = patchCable
		patchCable:setStart(self.socketOutAVector.x, self.socketOutAVector.y, self.modId)
		self.component:setOutACable(patchCable:getCable())
	elseif self.component:bConnected() ~= true then
		self.outBCable = patchCable
		patchCable:setStart(self.socketOutBVector.x, self.socketOutBVector.y, self.modId)
		self.component:setOutBCable(patchCable:getCable())
	elseif self.component:cConnected() ~= true then
		self.outCCable = patchCable
		patchCable:setStart(self.socketOutCVector.x, self.socketOutCVector.y, self.modId)
		self.component:setOutCCable(patchCable:getCable())
	elseif self.component:dConnected() ~= true then
		self.outCCable = patchCable
		patchCable:setStart(self.socketOutDVector.x, self.socketOutDVector.y, self.modId)
		self.component:setOutDCable(patchCable:getCable())
	end
end

function Clock2Mod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function Clock2Mod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:aConnected() ~= true then
		ghostCable:setStart(self.socketOutAVector.x, self.socketOutAVector.y)
		ghostCable:setGhostSendConnected()
		return true
	elseif self.component:bConnected() ~= true then
		ghostCable:setStart(self.socketOutBVector.x, self.socketOutBVector.y)
		ghostCable:setGhostSendConnected()
		return true
	elseif self.component:cConnected() ~= true then
		ghostCable:setStart(self.socketOutCVector.x, self.socketOutCVector.y)
		ghostCable:setGhostSendConnected()
		return true
	elseif self.component:dConnected() ~= true then
		ghostCable:setStart(self.socketOutDVector.x, self.socketOutDVector.y)
		ghostCable:setGhostSendConnected()
		return true
	else
		return false
	end
end

function Clock2Mod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Sends a periodic 'bang', usually the first module added to a rack.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end

	end)
end

function Clock2Mod:repositionBy(x, y)
	self:moveBy(x, y)
	self.clockEncoder:moveBy(x, y)
end

function Clock2Mod:moveFinish()
	self.socketOutAVector = Vector(self.x - 10, self.y - 30)
	self.socketOutBVector = Vector(self.x + 10, self.y - 30)
	self.socketOutCVector = Vector(self.x -10, self.y -1)
	self.socketOutDVector = Vector(self.x +10, self.y - 1)
end


function Clock2Mod:evaporate(onDetachConnected)
	print("Clock2Mod evaporate removing cables")
	self.component:stop()
	--first detach cables
	if self.component:aConnected() then
		onDetachConnected(self.outACable:getEndModId(), self.outACable:getCableId())
		self.component:unplugA()
		self.outACable:evaporate()
	end
	
	if self.component:bConnected() then
		onDetachConnected(self.outBCable:getEndModId(), self.outBCable:getCableId())
		self.component:unplugB()
		self.outBCable:evaporate()
	end
	
	if self.component:cConnected() then
		onDetachConnected(self.outCCable:getEndModId(), self.outCCable:getCableId())
		self.component:unplugC()
		self.outCCable:evaporate()
	end
	
	if self.component:dConnected() then
		onDetachConnected(self.outDCable:getEndModId(), self.outDCable:getCableId())
		self.component:unplugC()
		self.outDCable:evaporate()
	end
	
	--then remove sprites
	self.clockEncoder:evaporate()
	playdate.graphics.sprite.removeSprites({self.labelSprite})
	self.clockEncoder = nil
	self.labelSprite = nil
	self:remove()
end

function Clock2Mod:type() return modType end
function Clock2Mod:getModId() return self.modId end
function Clock2Mod:unplug(cableId) self.component:unplug(cableId) end
function Clock2Mod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function Clock2Mod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.clockEncoderVal = self.clockEncoder:getValue()
	return modState
end

function Clock2Mod:fromState(modState)
	self.clockEncoder:setValue(modState.clockEncoderVal)
end