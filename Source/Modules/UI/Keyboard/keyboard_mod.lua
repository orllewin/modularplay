--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/UI/Keyboard/keyboard_component'

class('KeyboardMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local keyboardImage = gfx.image.new("Images/keyboard")

local moduleWidth = 228
local moduleHeight = 116

local modType = "KeyboardMod"
local modSubtype = "other"

function KeyboardMod:init(xx, yy, modId)
	KeyboardMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
		
	self:moveTo(xx, yy)
	self:add()
	
	self.component = KeyboardComponent(function() 
	
	end)

	self.socketOutVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + gPedalAudioIOY)
	
	self:redrawBackground()
end

function KeyboardMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	
	gfx.pushContext(backgroundImage)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(240, gPedalAudioIOY)
	keyboardImage:draw(18, 38)

		
	gfx.popContext()
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function KeyboardMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function KeyboardMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end


function KeyboardMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function KeyboardMod:type()
	return self.modType
end

function KeyboardMod:getModId()
	return self.modId
end

function KeyboardMod:handleModClick(tX, tY, listener)
	--todo if top left corner remove
	if self.component:outConnected() then
		self.component:bang()
	end
end

function KeyboardMod:handleModClickUp(tX, tY, listener)
	if self.component:outConnected() then
		self.component:unbang()
	end
end

function KeyboardMod:unplug(cableId)
	self.component:unplug(cableId)
end

function KeyboardMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
	
	self:remove()
end

function KeyboardMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function KeyboardMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	return modState
end

function KeyboardMod:fromState(modState)
	--noop
end