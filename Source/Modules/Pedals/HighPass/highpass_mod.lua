--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'Modules/mod_utils.lua'
import 'Modules/Pedals/Highpass/highpass_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'

class('HighpassMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 85
local moduleHeight = 120

local modType = "HighpassMod"
local modSubtype = "audio_effect"

function HighpassMod:init(xx, yy, modId)
	HighpassMod.super.init(self)
	
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
	
	self.component = HighpassComponent()

	local encoderY = yy - 30
	--self.component:setMix(value)
	self.mixEncoderVector = Vector(xx + (moduleWidth/2) - 18,encoderY)
	self.mixEncoderValue = 0.5

	self.freqEncoderVector = Vector(xx - (moduleWidth/2) + 18, encoderY)
	self.freqEncoderValue = 0.25
	
	self.resonanceEncoderVector = Vector(xx, encoderY, encoderY)
	self.resonanceEncoderValue = 0.5

	self.encoderVectors = {
		self.mixEncoderVector,
		self.freqEncoderVector,
		self.resonanceEncoderVector
	}

	self.socketInVector = Vector(xx - (moduleWidth/2)-2, yy - (moduleHeight/2) + gPedalAudioIOY)
	self.socketOutVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + gPedalAudioIOY)

	self:redrawBackground()
end

function HighpassMod:redrawBackground()
	self.redrawPending = false
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
	gfx.drawTextAligned("Hi-Pass", bgW/2, 68, kTextAlignment.center)
	
	local mixImage = assets:image("mix")
	mixImage:draw(bgW - 38, 20)
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(gPedalLeftJackX, gPedalAudioIOY)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(gPedalRightJackX, gPedalAudioIOY)
	
	generateHalftoneRoundedRect(71, 43, 0.3):draw(20, 83)
	
	--encoders
	--left
	gEncoder:setValue(self.freqEncoderValue)
	local frequencyEncoderImage = gEncoder:getImage()
	frequencyEncoderImage:draw(22, 34)
	
	--middle
	gEncoder:setValue(self.resonanceEncoderValue)
	local resonanceEncoderImage = gEncoder:getImage()
	resonanceEncoderImage:draw(46, 34)
	
	--right
	gEncoder:setValue(self.mixEncoderValue)
	local mixEncoderImage = gEncoder:getImage()
	mixEncoderImage:draw(71, 34)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
end

function HighpassMod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end
	
	if encoderVector == self.freqEncoderVector then
		gEncoder:setValue(self.freqEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.freqEncoderVector.x, self.freqEncoderVector.y)
		gEncoder:turn(change)
		self.freqEncoderValue = gEncoder:getValue()
		self.component:setFrequency(map(self.freqEncoderValue, 0.0, 1.0, 0.0, 5000.0))
	elseif encoderVector == self.resonanceEncoderVector then
		gEncoder:setValue(self.resonanceEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.resonanceEncoderVector.x, self.resonanceEncoderVector.y)
		gEncoder:turn(change)
		self.resonanceEncoderValue = gEncoder:getValue()
		self.component:setResonance(self.resonanceEncoderValue)
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

function HighpassMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function HighpassMod:findClosestEncoderVector(x, y)
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

function HighpassMod:getHostAudioModId()
	return self.hostAudioModId
end

function HighpassMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.hostAudioModId = patchCable:getHostAudioModId()
	self.component:setInCable(patchCable:getCable())
end

function HighpassMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function HighpassMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function HighpassMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype)
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

function HighpassMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then 
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function HighpassMod:type()
	return modType
end

function HighpassMod:getModId()
	return self.modId
end

function HighpassMod:handleModClickPedal(tX, tY)
	self.upPending = true
	self:moveBy(0, 2)
	self.component:toggleOnOff()
	self:redrawBackground()
end

function HighpassMod:handleModClickUp(tX, tY, listener)
	if self.upPending then
		self.upPending = false
		self:moveBy(0, -2)
	end
end

function HighpassMod:handleModClick(tX, tY, listener)
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

function HighpassMod:setChannel(channel, onNext)
	if channel == nil then
		print("HighpassMod:setChannel() CHANNEL IS NIL")
	else
		print("HighpassMod:setChannel() CHANNEL EXISTS!")
	end
	self.component:setChannel(channel)
	
	--now look for downstream audio effects/outputs
	if self.outCable ~= nil then
		local nextModId = self.outCable:getEndModId()
		if onNext ~= nil then onNext(nextModId, channel) end
	end
end

function HighpassMod:removeChannel(channel)
	self.component:removeChannel(channel)
end

function HighpassMod:unplug(cableId)
	self.component:unplug(cableId)
end

function HighpassMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function HighpassMod:moveFinish()
	local encoderY = self.y - 30
	self.mixEncoderVector = Vector(self.x + (moduleWidth/2) - 18,encoderY)
	self.freqEncoderVector = Vector(self.x - (moduleWidth/2) + 18, encoderY)
	self.resonanceEncoderVector = Vector(self.x, encoderY, encoderY)

	self.encoderVectors = {
		self.mixEncoderVector,
		self.freqEncoderVector,
		self.resonanceEncoderVector
	}
	
	self.socketInVector = Vector(self.x - (moduleWidth/2)-2, self.y - (moduleHeight/2) + gPedalAudioIOY)
	self.socketOutVector = Vector	(self.x + (moduleWidth/2)+2, self.y - (moduleHeight/2) + gPedalAudioIOY)
end

function HighpassMod:evaporate(onDetachConnected)
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

function HighpassMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function HighpassMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.mixEncoderValue = self.mixEncoderValue
	modState.freqEncoderValue = self.freqEncoderValue
	modState.resonanceEncoderValue = self.resonanceEncoderValue
	
	return modState
end

function HighpassMod:fromState(modState)
	self.mixEncoderValue = modState.mixEncoderValue
	self.freqEncoderValue = modState.freqEncoderValue
	self.resonanceEncoderValue = modState.resonanceEncoderValue
	
	self.component:setFrequency(map(self.freqEncoderValue, 0.0, 1.0, 0.0, 5000.0))
	self.component:setResonance(self.resonanceEncoderValue)
	self.component:setMix(self.mixEncoderValue)
	
	self:redrawBackground()
end