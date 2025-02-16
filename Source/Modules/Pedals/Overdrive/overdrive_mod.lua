--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Pedals/Overdrive/overdrive_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'
import 'CoracleViews/rotary_encoder'

class('OverdriveMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 85
local moduleHeight = 120

local modType = "OverdriveMod"
local modSubtype = "audio_effect"

function OverdriveMod:init(xx, yy, modId)
	OverdriveMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	self.upPending = false
	
	self:moveTo(xx, yy)
	self:add()
		
	self.component = OverdriveComponent()

	local encoderY = yy - 30

	--left
	self.gainEncoderVector = Vector(xx - (moduleWidth/2) + 18, encoderY)
	self.gainEncoderValue = 0.5
	
	--middle
	self.limitEncoderVector = Vector(xx, encoderY)
	self.limitEncoderValue = 0.5
	
	--right
	self.mixEncoderVector = Vector(xx + (moduleWidth/2) - 18, encoderY)
	self.mixEncoderValue = 0.5

	self.encoderVectors = {
		self.gainEncoderVector,
		self.limitEncoderVector,
		self.mixEncoderVector
	}

	self.socketInVector = Vector(xx - (moduleWidth/2)-2, yy - (moduleHeight/2) + gPedalAudioIOY)
	self.socketOutVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + gPedalAudioIOY)

	self:redrawBackground()
end

function OverdriveMod:redrawBackground()
	print("OverdriveMod:redrawBackground()")
	gEncoder:hide()
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	
	gfx.pushContext(backgroundImage)
	
	if self.component:isOn() then
		local pedalOn = assets:image("pedal_on")
		pedalOn:draw(bgW/2 - 5, 19)
	else
		local pedalOn = assets:image("pedal_off")
		pedalOn:draw(bgW/2 - 5, 19)
	end
	
	gfx.drawLine((bgW/2) - (moduleWidth/2) + 7, 60, (bgW/2) + (moduleWidth/2) - 7, 60)
	gfx.drawTextAligned("Overdrive", bgW/2, 68, kTextAlignment.center)
	
	local mixImage = assets:image("mix")
	mixImage:draw(bgW - 38, 20)
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(gPedalLeftJackX, gPedalAudioIOY)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(gPedalRightJackX, gPedalAudioIOY)
	
	generateHalftoneRoundedRect(71, 43, 0.3):draw(20, 83)
	
	--draw encoders
	local encoderLeftX = 22
	local encoderMidX = 46
	local encoderRightX = 71
	local encoderY = 34
	
	--left
	gEncoder:setValue(self.gainEncoderValue)
	local gainEncoderImage = gEncoder:getImage()
	gainEncoderImage:draw(encoderLeftX, encoderY)
	
	--middle
	gEncoder:setValue(self.limitEncoderValue)
	local limitEncoderImage = gEncoder:getImage()
	limitEncoderImage:draw(encoderMidX, encoderY)
	
	--right
	gEncoder:setValue(self.mixEncoderValue)
	local mixEncoderImage = gEncoder:getImage()
	mixEncoderImage:draw(encoderRightX, encoderY)
	
	gfx.popContext()
	self:setImage(backgroundImage)
	self.redrawPending = false
	print("OverdriveMod:redrawBackground() - done")
end

function OverdriveMod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end
	-- self.gainEncoderVector,
	-- self.limitEncoderVector,
	-- self.mixEncoderVector
	if encoderVector == self.gainEncoderVector then
		gEncoder:setValue(self.gainEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.gainEncoderVector.x, self.gainEncoderVector.y)
		gEncoder:turn(change)
		self.gainEncoderValue = gEncoder:getValue()
		self.component:setGain(map(self.gainEncoderValue, 0.0, 1.0, 0.0, 3.0))
	elseif encoderVector == self.limitEncoderVector then
		gEncoder:setValue(self.limitEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.limitEncoderVector.x, self.limitEncoderVector.y)
		gEncoder:turn(change)
		self.limitEncoderValue = gEncoder:getValue()
		self.component:setLimit(self.limitEncoderValue)
	elseif encoderVector == self.mixEncoderVector then
		gEncoder:setValue(self.mixEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.mixEncoderVector.x, self.mixEncoderVector.y)
		gEncoder:turn(change)
		self.mixEncoderValue = gEncoder:getValue()
		self.component:setMix(self.mixEncoderValue)
	end
	
	self.redrawPending = true
end

function OverdriveMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function OverdriveMod:findClosestEncoderVector(x, y)
	local reticleVector = Vector(x, y)
	local closestDistance = 1000
	local closestIndex = -1
	for i=1,#self.encoderVectors do
		local encoderVector = self.encoderVectors[i]
		local distance = reticleVector:distance(encoderVector)
		if distance < closestDistance then
			closestDistance = distance
			closestIndex = i
		end
	end
	
	return self.encoderVectors[closestIndex]
end


function OverdriveMod:getHostAudioModId()
	return self.hostAudioModId
end

function OverdriveMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.hostAudioModId = patchCable:getHostAudioModId()
	self.component:setInCable(patchCable:getCable())
end

function OverdriveMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function OverdriveMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function OverdriveMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype)
	if ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.component:inConnected() then 
		return false
	elseif sourceSubtype == "midi" or sourceSubtype == "clock_router" then
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function OverdriveMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then 
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function OverdriveMod:type()
	return modType
end

function OverdriveMod:getModId()
	return self.modId
end

function OverdriveMod:handleModClickPedal(tX, tY)
	self.upPending = true
	self:moveBy(0, 2)
	self.component:toggleOnOff()
	self:redrawBackground()
end

function OverdriveMod:handleModClickUp(tX, tY, listener)
	if self.upPending then
		self.upPending = false
		self:moveBy(0, -2)
	end
end

function OverdriveMod:handleModClick(tX, tY, listener)
	if tY > self.y - 20 then
		self:handleModClickPedal(tX, tY)
	else
		self.menuListener = listener
		local actions = {
			{label = "About"},
			{label = "Move"},
			{label = "Remove"}
		}
		local contextMenu = ModuleMenu(actions)
		contextMenu:show(function(action) 
			if action == "About" then
				local aboutPopup = ModAboutPopup("todo")
				aboutPopup:show()
			else
				if self.menuListener ~= nil then 
					self.menuListener(action) 
				end
			end
		end)
	end
end

function OverdriveMod:setChannel(channel, onNext)
	if channel == nil then
		print("OverdriveMod:setChannel() CHANNEL IS NIL")
	else
		print("OverdriveMod:setChannel() CHANNEL EXISTS!")
	end
	self.component:setChannel(channel)
	
	--now look for downstream audio effects/outputs
	if self.outCable ~= nil then
		local nextModId = self.outCable:getEndModId()
		if onNext ~= nil then onNext(nextModId, channel) end
	end
end

function OverdriveMod:removeChannel(channel)
	self.component:removeChannel(channel)
end

function OverdriveMod:unplug(cableId)
	self.component:unplug(cableId)
end

function OverdriveMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function OverdriveMod:moveFinish()
	local encoderY = self.y - 30

	self.gainEncoderVector = Vector(self.x - (moduleWidth/2) + 18, encoderY)
	self.limitEncoderVector = Vector(self.x, encoderY)
	self.mixEncoderVector = Vector(self.x + (moduleWidth/2) - 18, encoderY)

	self.encoderVectors = {
		self.gainEncoderVector,
		self.limitEncoderVector,
		self.mixEncoderVector
	}
	
	self.socketInVector = Vector(self.x - (moduleWidth/2)-2, self.y - (moduleHeight/2) + gPedalAudioIOY)
	self.socketOutVector = Vector	(self.x + (moduleWidth/2)+2, self.y - (moduleHeight/2) + gPedalAudioIOY)
end


function OverdriveMod:evaporate(onDetachConnected)
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

function OverdriveMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function OverdriveMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.gainEncoderValue = self.gainEncoderValue
	modState.limitEncoderValue = self.limitEncoderValue
	modState.mixEncoderValue = self.mixEncoderValue
	
	return modState
end

function OverdriveMod:fromState(modState)
	self.gainEncoderValue = modState.gainEncoderValue
  self.limitEncoderValue = modState.limitEncoderValue
  self.mixEncoderValue = modState.mixEncoderValue
	
	self.component:setGain(map(self.gainEncoderValue, 0.0, 1.0, 0.0, 3.0))
	self.component:setLimit(self.limitEncoderValue)
	self.component:setMix(self.mixEncoderValue)

	self:redrawBackground()
end