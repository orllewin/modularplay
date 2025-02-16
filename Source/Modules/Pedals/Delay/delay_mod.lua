--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'Modules/mod_utils.lua'
import 'Modules/Pedals/Delay/delay_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'
import 'CoracleViews/rotary_encoder'

class('DelayMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 85
local moduleHeight = 120

local modType = "DelayMod"
local modSubtype = "audio_effect"

function DelayMod:init(xx, yy, modId)
	DelayMod.super.init(self)
	
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
	
	self.component = DelayComponent()
	
	local encoderY = yy - 30
	
	--left
	self.tapDelayEncoderVector = Vector(xx - (moduleWidth/2) + 18, encoderY)
	self.tapDelayEncoderValue = 0.35
	
	--middle
	self.feedbackEncoderVector = Vector(xx, encoderY)
	self.feedbackEncoderValue = 0.20

	--right
	self.mixEncoderVector = Vector(xx + (moduleWidth/2) - 18, encoderY)
	self.mixEncoderValue = 0.5

	self.encoderVectors = {
		self.tapDelayEncoderVector,
		self.feedbackEncoderVector,
		self.mixEncoderVector
	}

	self.socketInVector = Vector(xx - (moduleWidth/2)-2, yy - (moduleHeight/2) + gPedalAudioIOY)
	self.socketOutVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + gPedalAudioIOY)

	self:redrawBackground()
end

function DelayMod:redrawBackground()
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
	gfx.drawTextAligned("Delay", bgW/2, 68, kTextAlignment.center)
	
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
	gEncoder:setValue(self.tapDelayEncoderValue)
	local tapDelayEncoderImage = gEncoder:getImage()
	tapDelayEncoderImage:draw(encoderLeftX, encoderY)
	
	--middle
	gEncoder:setValue(self.feedbackEncoderValue)
	local feedbackEncoderImage = gEncoder:getImage()
	feedbackEncoderImage:draw(encoderMidX, encoderY)
	
	--right
	gEncoder:setValue(self.mixEncoderValue)
	local mixEncoderImage = gEncoder:getImage()
	mixEncoderImage:draw(encoderRightX, encoderY)
	
	gfx.popContext()
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function DelayMod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end

	if encoderVector == self.tapDelayEncoderVector then
		gEncoder:setValue(self.tapDelayEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.tapDelayEncoderVector.x, self.tapDelayEncoderVector.y)
		gEncoder:turn(change)
		self.tapDelayEncoderValue = gEncoder:getValue()
		self.component:setTapDelay(self.tapDelayEncoderValue)
	elseif encoderVector == self.feedbackEncoderVector then
		gEncoder:setValue(self.feedbackEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.feedbackEncoderVector.x, self.feedbackEncoderVector.y)
		gEncoder:turn(change)
		self.feedbackEncoderValue = gEncoder:getValue()
		self.component:setFeedback(self.feedbackEncoderValue)
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

function DelayMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function DelayMod:findClosestEncoderVector(x, y)
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

function DelayMod:getHostAudioModId()
	return self.hostAudioModId
end

function DelayMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.hostAudioModId = patchCable:getHostAudioModId()
	self.component:setInCable(patchCable:getCable())
end

function DelayMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	patchCable:setHostAudioModId(self.hostAudioModId)
	self.component:setOutCable(patchCable:getCable())
	print("POP: delay out cable: " .. self.modId .. " = " .. patchCable:getStartModId())
end

function DelayMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function DelayMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype)
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

function DelayMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then 
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function DelayMod:type()
	return self.modType
end

function DelayMod:getModId()
	return self.modId
end

function DelayMod:handleModClickPedal(tX, tY)
	self.upPending = true
	self:moveBy(0, 2)
	self.component:toggleOnOff()
	self:redrawBackground()
end

function DelayMod:handleModClickUp(tX, tY, listener)
	if self.upPending then
		self.upPending = false
		self:moveBy(0, -2)
	end
end

function DelayMod:handleModClick(tX, tY, listener)
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
				local aboutPopup = ModAboutPopup("A simple delay pedal. Encoders are Delay time, feedback, and mix")
				aboutPopup:show()
			else
				if self.menuListener ~= nil then 
					self.menuListener(action) 
				end
			end
		end)
	end
end

function DelayMod:setChannel(channel, onNext)
	if channel == nil then
		print("DelayMod:setChannel() CHANNEL IS NIL")
	else
		print("DelayMod:setChannel() CHANNEL EXISTS!")
	end
	self.component:setChannel(channel)
	
--now look for downstream audio effects/outputs
	if self.outCable ~= nil then
		local nextModId = self.outCable:getEndModId()
		if onNext ~= nil then onNext(nextModId, channel) end
	end
end

function DelayMod:removeChannel(channel)
	self.component:removeChannel(channel)
end

function DelayMod:unplug(cableId)
	self.component:unplug(cableId)
end

function DelayMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function DelayMod:moveFinish()
	local encoderY = self.y - 30
	self.tapDelayEncoderVector = Vector(self.x - (moduleWidth/2) + 18, encoderY)
	self.feedbackEncoderVector = Vector(self.x, encoderY)
	self.mixEncoderVector = Vector(self.x + (moduleWidth/2) - 18, encoderY)
	
	self.encoderVectors = {
		self.tapDelayEncoderVector,
		self.feedbackEncoderVector,
		self.mixEncoderVector
	}
	
	self.socketInVector = Vector(self.x - (moduleWidth/2)-2, self.y - (moduleHeight/2) + gPedalAudioIOY)
	self.socketOutVector = Vector	(self.x + (moduleWidth/2)+2, self.y - (moduleHeight/2) + gPedalAudioIOY)
end

function DelayMod:evaporate(onDetachConnected)
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

function DelayMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function DelayMod:toState()
	local modState = {}
	print("POP: saving delay mod with id: " .. self.modId)
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.tapDelayEncoderValue = self.tapDelayEncoderValue
	modState.feedbackEncoderValue = self.feedbackEncoderValue
	modState.mixEncoderValue = self.mixEncoderValue
		
	return modState
end

function DelayMod:fromState(modState)
	self.tapDelayEncoderValue = modState.tapDelayEncoderValue
	self.feedbackEncoderValue = modState.feedbackEncoderValue
	self.mixEncoderValue = modState.mixEncoderValue
	
	self.component:setTapDelay(self.tapDelayEncoderValue)
	self.component:setFeedback(self.feedbackEncoderValue)
	self.component:setMix(self.mixEncoderValue)
	
	self:redrawBackground()
end