--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Pedals/RingModulator/ring_modulator_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'
import 'CoracleViews/rotary_encoder'

class('RingModulatorMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 85
local moduleHeight = 120

local modType = "RingModulatorMod"
local modSubtype = "audio_effect"

function RingModulatorMod:init(xx, yy, modId)
	RingModulatorMod.super.init(self)
	
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
	
	self.component = RingModulatorComponent(function() 
	
	end)

	local encoderY = yy - 30
	
	self.frequencyEncoderVector = Vector(xx - (moduleWidth/2) + 18, encoderY)
	self.frequencyEncoderValue = 0.0
	self.frequencyLabel = "0"
	
	self.mixEncoderVector = Vector(xx + (moduleWidth/2) - 18, encoderY)
	self.mixEncoderValue = 0.5

	self.encoderVectors = {
		self.frequencyEncoderVector,
		self.mixEncoderVector
	}

	self.socketInVector = Vector(xx - (moduleWidth/2)-2, yy - (moduleHeight/2) + gPedalAudioIOY)
	self.socketOutVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + gPedalAudioIOY)

	self:redrawBackground()
end

function RingModulatorMod:redrawBackground()
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
	gfx.drawTextAligned("RingMod", bgW/2, 68, kTextAlignment.center)
	
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
	
	gfx.drawTextAligned(self.frequencyLabel, encoderLeftX + 10, encoderY - 12, kTextAlignment.center)
	gEncoder:setValue(self.frequencyEncoderValue)
	local frequencyEncoderImage = gEncoder:getImage()
	frequencyEncoderImage:draw(encoderLeftX, encoderY)
		
	--right
	gEncoder:setValue(self.mixEncoderValue)
	local mixEncoderImage = gEncoder:getImage()
	mixEncoderImage:draw(encoderRightX, encoderY)
	
	gfx.popContext()
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function RingModulatorMod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end
	-- 	self.frequencyEncoderVector,
	-- self.mixEncoderVector
	if encoderVector == self.frequencyEncoderVector then
		gEncoder:setValue(self.frequencyEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.frequencyEncoderVector.x, self.frequencyEncoderVector.y)
		gEncoder:turn(change)
		self.frequencyEncoderValue = gEncoder:getValue()
		self.component:setFrequency(self.frequencyEncoderValue, function(freq) 
			if freq < 1000 then
				self.frequencyLabel = ""..math.floor(freq)
			else
				local thousands = math.floor(freq/1000)
				self.frequencyLabel = ""..thousands .. "k"
			end
			self:redrawBackground()
		end)
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

function RingModulatorMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function RingModulatorMod:findClosestEncoderVector(x, y)
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


function RingModulatorMod:getHostAudioModId()
	return self.hostAudioModId
end

function RingModulatorMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.hostAudioModId = patchCable:getHostAudioModId()
	self.component:setInCable(patchCable:getCable())
end

function RingModulatorMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function RingModulatorMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function RingModulatorMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype)
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

function RingModulatorMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then 
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function RingModulatorMod:type()
	return "RingModulatorMod"
end

function RingModulatorMod:getModId()
	return self.modId
end

function RingModulatorMod:handleModClickPedal(tX, tY)
	self.upPending = true
	self:moveBy(0, 2)
	self.component:toggleOnOff()
	self:redrawBackground()
end

function RingModulatorMod:handleModClickUp(tX, tY, listener)
	if self.upPending then
		self.upPending = false
		self:moveBy(0, -2)
	end
end

function RingModulatorMod:handleModClick(tX, tY, listener)
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

function RingModulatorMod:setChannel(channel, onNext)
	if channel == nil then
		print("RingModulatorMod:setChannel() CHANNEL IS NIL")
	else
		print("RingModulatorMod:setChannel() CHANNEL EXISTS!")
	end
	self.component:setChannel(channel)
	
	--now look for downstream audio effects/outputs
	if self.outCable ~= nil then
		local nextModId = self.outCable:getEndModId()
		if onNext ~= nil then onNext(nextModId, channel) end
	end
end

function RingModulatorMod:removeChannel(channel)
	self.component:removeChannel(channel)
end

function RingModulatorMod:unplug(cableId)
	self.component:unplug(cableId)
end

function RingModulatorMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function RingModulatorMod:moveFinish()
	local encoderY = self.y - 30
	
	self.frequencyEncoderVector = Vector(self.x - (moduleWidth/2) + 18, encoderY)
	self.mixEncoderVector = Vector(self.x + (moduleWidth/2) - 18, encoderY)

	self.encoderVectors = {
		self.frequencyEncoderVector,
		self.mixEncoderVector
	}
	
	self.socketInVector = Vector(self.x - (moduleWidth/2)-2, self.y - (moduleHeight/2) + gPedalAudioIOY)
	self.socketOutVector = Vector	(self.x + (moduleWidth/2)+2, self.y - (moduleHeight/2) + gPedalAudioIOY)
end


function RingModulatorMod:evaporate(onDetachConnected)
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

function RingModulatorMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function RingModulatorMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.frequencyEncoderValue = self.frequencyEncoderValue
	modState.mixEncoderValue = self.mixEncoderValue
	modState.frequencyLabel = self.frequencyLabel
	
	return modState
end

function RingModulatorMod:fromState(modState)
	self.frequencyEncoderValue = modState.frequencyEncoderValue
	self.mixEncoderValue = modState.mixEncoderValue
	self.frequencyLabel = modState.frequencyLabel
	
	self.component:setFrequency(self.frequencyEncoderValue, nil)
	self.component:setMix(self.mixEncoderValue)
	
	self:redrawBackground()
end