--[[
	© 2023 Orllewin - All Rights Reserved.
]]
print("HEXAGRAM: imports")
import 'Modules/Samplers/Hexagram/hexagram_component'
print("HEXAGRAM: imports: component done")

import 'Modules/Samplers/Hexagram/hexagram'
print("HEXAGRAM: imports: hexagram graphic done")

class('HexagramMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 155
local moduleHeight = 100

local modType = "HexagramMod"
local modSubtype = "audio_gen"

print("HEXAGRAM: images init")

-- local hexagramImage = gfx.image.new("Images/hexagram")
-- print("HEXAGRAM: images init: Images/hexagram done")

print("HEXAGRAM: images init ----->")

local pitchBackplateImage = gfx.image.new("Images/hexagram_pitch_backplate")
print("HEXAGRAM: images init: Images/hexagram_pitch_backplate done")

local reverse = gfx.image.new("Images/hexagram_reverse")
print("HEXAGRAM: images init: Images/hexagram_reverse done")

local frequency = gfx.image.new("Images/hexagram_frequency")
print("HEXAGRAM: images init: Images/hexagram_frequency done")

local count = gfx.image.new("Images/hexagram_number")
print("HEXAGRAM: images init: Images/hexagram_number done")

print("HEXAGRAM: images init done")

function HexagramMod:init(xx, yy, modId, onInit)
	HexagramMod.super.init(self)
	
	print("HEXAGRAM: init()")
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.onInit = onInit
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	print("HEXAGRAM: init() - start listening")
	playdate.sound.micinput.startListening()
	gHexagramRunning = true
		
	self:moveTo(xx, yy)
	self:add()
	
	self.component = HexagramComponent(function(channel)
			self.onInit(self.modId, channel)
	end)
	
	local encoderY = yy + 30
	
	--left
	self.pitchModeEncoderVector = Vector(xx - (moduleWidth/2) + 24, encoderY)
	self.pitchModeEncoderValue = 0.5
	
	--middle
	self.reverseEncoderVector = Vector(xx - 18, encoderY)
	self.reverseEncoderValue = 0.5

	--right
	self.frquencyEncoderVector = Vector(xx + 17, encoderY)
	self.frequencyEncoderValue = 0.5
	
	--rightermost
	self.countEncoderVector = Vector(xx + (moduleWidth/2) - 26, encoderY)
	self.countEncoderValue = 0.5

	self.encoderVectors = {
		self.pitchModeEncoderVector,
		self.reverseEncoderVector,
		self.frquencyEncoderVector,
		self.countEncoderVector
	}
	
	self.hexagram1 = Hexagram(xx - 55, yy - 17, 26, 0.9)
	self.hexagram2 = Hexagram(xx - 20, yy - 17, 26, 0.9)
	self.hexagram3 = Hexagram(xx + 20, yy - 17, 26, 0.9)
	self.hexagram4 = Hexagram(xx + 55, yy - 17, 26, 0.9)

	self.socketOutVector = Vector	(xx + (moduleWidth/2), yy - (moduleHeight/2) + gPedalAudioIOY - 5)

	self:redrawBackground()
end

function HexagramMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	
	gfx.pushContext(backgroundImage)

	local rightSocket = assets:image("side_socket_right")	
	rightSocket:draw(gPedalRightJackX + 71, gPedalAudioIOY)
		
	--draw encoders
	local encoderLeftX = 28
	local encoderMidX = bgW/2 - 11
	local encoderRightX = bgW/2 - 11 + 36
	local encoderY = 84
	
	--left
	pitchBackplateImage:draw(18, 68)
	gEncoder:setValue(self.pitchModeEncoderValue)
	local pitchModeEncoderImage = gEncoder:getImage()
	pitchModeEncoderImage:draw(28, encoderY)
	
	--middle
	reverse:draw(58, 68)
	gEncoder:setValue(self.reverseEncoderValue)
	local reverseEncoderImage = gEncoder:getImage()
	reverseEncoderImage:draw(63, encoderY)
	
	--right
	frequency:draw(95, 68)
	gEncoder:setValue(self.frequencyEncoderValue)
	local frequencyEncoderImage = gEncoder:getImage()
	frequencyEncoderImage:draw(98, encoderY)
	
	--rightermost
	count:draw(130, 68)
	gEncoder:setValue(self.countEncoderValue)
	local countEncoderImage = gEncoder:getImage()
	countEncoderImage:draw(133, encoderY)
	
	if gHexagramRunning then
		gfx.drawText("Recording", 20, 20)
	else
		gfx.drawText("Idle", 20, 20)
	end
	
	gfx.popContext()
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function HexagramMod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end

	if encoderVector == self.pitchModeEncoderVector then
		gEncoder:setValue(self.pitchModeEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.pitchModeEncoderVector.x, self.pitchModeEncoderVector.y)
		gEncoder:turn(change)
		self.pitchModeEncoderValue = gEncoder:getValue()
		self.component:setPitchMode(self.pitchModeEncoderValue)
		self.hexagram1:cast(self.pitchModeEncoderValue)
	elseif encoderVector == self.reverseEncoderVector then
		gEncoder:setValue(self.reverseEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.reverseEncoderVector.x, self.reverseEncoderVector.y)
		gEncoder:turn(change)
		self.reverseEncoderValue = gEncoder:getValue()
		self.component:setReverseProbability(self.reverseEncoderValue)
		self.hexagram2:cast(self.reverseEncoderValue)
	elseif encoderVector == self.frquencyEncoderVector then
		gEncoder:setValue(self.frequencyEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.frquencyEncoderVector.x, self.frquencyEncoderVector.y)
		gEncoder:turn(change)
		self.frequencyEncoderValue = gEncoder:getValue()
		self.component:setPlaybackFrequency(self.frequencyEncoderValue)
		self.hexagram3:cast(self.frequencyEncoderValue)
	elseif encoderVector == self.countEncoderVector then
		gEncoder:setValue(self.countEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.countEncoderVector.x, self.countEncoderVector.y)
		gEncoder:turn(change)
		self.countEncoderValue = gEncoder:getValue()
		self.component:setCount(self.countEncoderValue)
		self.hexagram4:cast(self.countEncoderValue)
	end
	
	self.redrawPending = true
end

function HexagramMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function HexagramMod:findClosestEncoderVector(x, y)
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

function HexagramMod:getHostAudioModId()
	return self.hostAudioModId
end

function HexagramMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	patchCable:setHostAudioModId(self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function HexagramMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function HexagramMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype)
	return false
end

function HexagramMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then 
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function HexagramMod:type()
	return self.modType
end

function HexagramMod:getModId()
	return self.modId
end

function HexagramMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	
	local actions = nil
	if gHexagramRunning then
		actions = {
			{label = "Stop recording"},
			{label = "About"},
			{label = "Move"},
			{label = "Remove"}
		}
	else
		actions = {
			{label = "Start recording"},
			{label = "About"},
			{label = "Move"},
			{label = "Remove"}
		}
	end
	
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "Start recording" then
			gHexagramRunning = true
			self:redrawBackground()
		elseif action == "Stop recording" then
			gHexagramRunning = false
			self:redrawBackground()
		elseif action == "About" then
			local aboutPopup = ModAboutPopup("Ghosts from the past haunt the present. Hexagram samples live audio using the Playdate microphone, for best use make sure you're using headphones so it doesn't resample its own output.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function HexagramMod:setChannel(channel, onNext)
	if channel == nil then
		print("HexagramMod:setChannel() CHANNEL IS NIL")
	else
		print("HexagramMod:setChannel() CHANNEL EXISTS!")
	end
	self.component:setChannel(channel)
	
--now look for downstream audio effects/outputs
	if self.outCable ~= nil then
		local nextModId = self.outCable:getEndModId()
		if onNext ~= nil then onNext(nextModId, channel) end
	end
end

function HexagramMod:removeChannel(channel)
	self.component:removeChannel(channel)
end

function HexagramMod:unplug(cableId)
	self.component:unplug(cableId)
end

function HexagramMod:repositionBy(x, y)
	self:moveBy(x, y)
	self.hexagram1:repositionBy(x, y)
	self.hexagram2:repositionBy(x, y)
	self.hexagram3:repositionBy(x, y)
	self.hexagram4:repositionBy(x, y)
end

function HexagramMod:moveFinish()
	local encoderY = self.y + 30
	self.pitchModeEncoderVector = Vector(self.x - (moduleWidth/2) + 24, encoderY)
	self.reverseEncoderVector = Vector(self.x - 18, encoderY)
	self.frquencyEncoderVector = Vector(self.x + 17, encoderY)
	self.countEncoderVector = Vector(self.x + (moduleWidth/2) - 26, encoderY)
	self.socketOutVector = Vector	(self.x + (moduleWidth/2), self.y - (moduleHeight/2) + gPedalAudioIOY - 5)

	self.encoderVectors = {
		self.pitchModeEncoderVector,
		self.reverseEncoderVector,
		self.frquencyEncoderVector,
		self.countEncoderVector
	}
end

function HexagramMod:evaporate(onDetachConnected)
	gHexagramRunning = false
	self.component:stopAll()

	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
	
	self.hexagram1:evaporate()
	self.hexagram1 = nil
	
	self.hexagram2:evaporate()
	self.hexagram2 = nil
	
	self.hexagram3:evaporate()
	self.hexagram3 = nil
	
	self.hexagram4:evaporate()
	self.hexagram4 = nil

	self:remove()
end

function HexagramMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function HexagramMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.pitchModeEncoderValue = self.pitchModeEncoderValue
	modState.reverseEncoderValue = self.reverseEncoderValue
	modState.frequencyEncoderValue = self.frequencyEncoderValue
	modState.countEncoderValue = self.countEncoderValue
		
	return modState
end

function HexagramMod:fromState(modState)
	self.pitchModeEncoderValue = modState.pitchModeEncoderValue
	self.reverseEncoderValue = modState.reverseEncoderValue
	self.frequencyEncoderValue = modState.frequencyEncoderValue
	self.countEncoderValue = modState.countEncoderValue 

	self.component:setPitchMode(self.pitchModeEncoderValue)
	self.component:setReverseProbability(self.reverseEncoderValue)
	self.component:setPlaybackFrequency(self.frequencyEncoderValue)
	self.component:setCount(self.countEncoderValue)
	
	self:redrawBackground()
end