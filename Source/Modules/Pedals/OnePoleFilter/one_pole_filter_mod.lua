--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/Pedals/OnePoleFilter/one_pole_filter_component'

class('OnePoleFilterMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 85
local moduleHeight = 120

local modType = "OnePoleFilterMod"
local modSubtype = "audio_effect"

function OnePoleFilterMod:init(xx, yy, modId)
	OnePoleFilterMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
		
	self:moveTo(xx, yy)
	self:add()
	
	self.component = OnePoleFilterComponent(function() 
	
	end)

	local encoderY = yy - 30

	self.frequencyEncoderVector = Vector(xx - (moduleWidth/2) + 18, encoderY)
	self.frequencyEncoderValue = 0.5
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

function OnePoleFilterMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	
	gfx.pushContext(backgroundImage)
	
	gfx.drawLine((bgW/2) - (moduleWidth/2) + 7, 60, (bgW/2) + (moduleWidth/2) - 7, 60)
	gfx.drawTextAligned("One Pole", bgW/2, 68, kTextAlignment.center)
	
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


function OnePoleFilterMod:turn(x, y, change)
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
		local cutoff = map(self.frequencyEncoderValue, 0.0, 1.0, -1.0, 1.0)
		self.component:setCutoffFreq(cutoff)
		self.frequencyLabel = ""..round(cutoff, 1)
		self:redrawBackground()
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

function OnePoleFilterMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function OnePoleFilterMod:findClosestEncoderVector(x, y)
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

function OnePoleFilterMod:getHostAudioModId()
	return self.hostAudioModId
end

function OnePoleFilterMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.hostAudioModId = patchCable:getHostAudioModId()
	self.component:setInCable(patchCable:getCable())
end

function OnePoleFilterMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function OnePoleFilterMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function OnePoleFilterMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype)
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

function OnePoleFilterMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function OnePoleFilterMod:type()
	return self.modType
end

function OnePoleFilterMod:getModId()
	return self.modId
end

function OnePoleFilterMod:handleModClick(tX, tY, listener)
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

function OnePoleFilterMod:setChannel(channel, onNext)
	if channel == nil then
		print("OnePoleFilterMod:setChannel() CHANNEL IS NIL")
	else
		print("OnePoleFilterMod:setChannel() CHANNEL EXISTS!")
	end
	self.component:setChannel(channel)
	
--now look for downstream audio effects/outputs
	if self.outCable ~= nil then
		local nextModId = self.outCable:getEndModId()
		if onNext ~= nil then onNext(nextModId, channel) end
	end
end

function OnePoleFilterMod:removeChannel(channel)
	self.component:removeChannel(channel)
end

function OnePoleFilterMod:unplug(cableId)
	self.component:unplug(cableId)
end

function OnePoleFilterMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function OnePoleFilterMod:moveFinish()
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

function OnePoleFilterMod:evaporate(onDetachConnected)
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

function OnePoleFilterMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function OnePoleFilterMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.frequencyEncoderValue = self.frequencyEncoderValue
	modState.frequencyLabel = self.frequencyLabel
	modState.mixEncoderValue = self.mixEncoderValue
	
	return modState
end

function OnePoleFilterMod:fromState(modState)
	self.frequencyEncoderValue = modState.frequencyEncoderValue
  self.frequencyLabel = modState.frequencyLabel
  self.mixEncoderValue = modState.mixEncoderValue
	
	local cutoff = map(self.frequencyEncoderValue, 0.0, 1.0, -1.0, 1.0)
	self.component:setCutoffFreq(cutoff)
	self.component:setMix(self.mixEncoderValue)
	
	self:redrawBackground()
end