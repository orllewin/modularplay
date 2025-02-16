--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Clocks/Blackhole/blackhole_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'

class('BlackholeMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 50
local moduleHeight = 50

local modType = "BlackholeMod"
local modSubtype = "clock_router_or_midi"

function BlackholeMod:init(xx, yy, modId)
	BlackholeMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	self.bgW = bgW
	self.bgH = bgH
	gfx.pushContext(backgroundImage)		
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 32)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(62, 32)
	gfx.popContext()
	
	self.backgroundImage = backgroundImage
	
	self:moveTo(xx, yy)
	self:add()
	
	self.component = BlackholeComponent()
	
	self.gravityEncoderVector = Vector(xx, yy)
	self.gravityEncoderValue = 0.5
	
	self.socketInVector = Vector(xx - 25, 	yy)
	self.socketOutVector = Vector(xx + 25, 	yy)
	
	self:redrawBackground()
end

function BlackholeMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = gfx.image.new(self.bgW, self.bgH)
	
	gfx.pushContext(backgroundImage)
	self.backgroundImage:draw(0, 0)
	
	local holeImage = gfx.image.new(moduleWidth, moduleHeight)
	gfx.pushContext(holeImage)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillCircleAtPoint(moduleWidth/2, moduleHeight/2, map(self.gravityEncoderValue, 0.0, 1.0, 2, moduleWidth))
	gfx.popContext()
	
	local holeImage2 = gfx.image.new(moduleWidth, moduleHeight)
	gfx.pushContext(holeImage2)
	holeImage:drawFaded(0, 0, 0.4, gfx.image.kDitherTypeDiagonalLine)
	gfx.popContext()
	
	holeImage2:draw(14, 14)
	
	gEncoder:setValue(self.gravityEncoderValue)
	local gravityEncoderImage = gEncoder:getImage()
	gravityEncoderImage:draw(29, 29)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function BlackholeMod:turn(x, y, change)
	gEncoder:setValue(self.gravityEncoderValue)
	gEncoder:show()
	gEncoder:moveTo(self.gravityEncoderVector.x, self.gravityEncoderVector.y)
	gEncoder:turn(change)
	self.gravityEncoderValue = gEncoder:getValue()
	self.component:setGravity(self.gravityEncoderValue)
	self:redrawBackground()
	self.redrawPending = false
end

function BlackholeMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function BlackholeMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function BlackholeMod:setOutCable(patchCable)
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function BlackholeMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function BlackholeMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype, onError)
	if sourceSubtype ~= "clock_router" and sourceSubtype ~= "midi" then 
		if onError ~= nil then onError("This input requires a clock or midi signal") end
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

function BlackholeMod:tryConnectGhostOut(x, y, ghostCable)
	if not self.component:outConnected() then
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	else
		return false
	end
end

function BlackholeMod:type()
	return self.modType
end

function BlackholeMod:getModId()
	return self.modId
end

function BlackholeMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Clock events might get sucked into the blackhole. Higher gravity means fewer event make it though.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function BlackholeMod:unplug(cableId)
	self.component:unplug(cableId)
end

function BlackholeMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function BlackholeMod:moveFinish()	
	self.socketInVector = Vector(self.x - 25, self.y)
	self.socketOutVector = Vector(self.x + 25, self.y)
	self.gravityEncoderVector = Vector(self.x, self.y)
end

function BlackholeMod:evaporate(onDetachConnected)
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

function BlackholeMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function BlackholeMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.gravityEncoderValue = self.gravityEncoderValue
	
	return modState
end

function BlackholeMod:fromState(modState)
	self.gravityEncoderValue = modState.gravityEncoderValue
	self.component:setGravity(self.gravityEncoderValue)
	self:redrawBackground() 
end