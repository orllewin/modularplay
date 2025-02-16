--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Midi/NormalisedToMidi/normalised_to_midi_component'

class('NormalisedToMidiMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local arrowMajorImage = playdate.graphics.image.new("Images/arrow_up")
local arrowMinorImage = playdate.graphics.image.new("Images/arrow_down")

local moduleWidth = 85
local moduleHeight = 75

local modType = "NormalisedToMidiMod"
local modSubtype = "midi"

local notes = {"C", "C#", "D", "E♭", "E", "F", "F#", "G", "A♭", "A", "B♭", "B"}

function NormalisedToMidiMod:init(xx, yy, modId)
	NormalisedToMidiMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.major = true
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = backgroundImage:getSize()
	gfx.pushContext(backgroundImage)
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 32)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(97, 32)
	
	gfx.drawTextAligned("High", bgW/2 + 19, 20, kTextAlignment.center)
	gfx.drawTextAligned("Low", bgW/2 + 19, 55, kTextAlignment.center)
	
	gfx.drawTextAligned("Maj", bgW/2 - 19, 57, kTextAlignment.center)
	gfx.drawTextAligned("Min", bgW/2 - 19, 77, kTextAlignment.center)
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.component = NormalisedToMidiComponent()
	
	local noteC = playdate.graphics.imageWithText("C", 20, 20)
	self.noteSprite = gfx.sprite.new(noteC)
	self.noteSprite:moveTo(xx - 19, yy - 28)
	self.noteSprite:add()
	
	self.noteEncoder = RotaryEncoder(xx - 19, yy - 12, function(value)
		local noteIndex = math.floor(map(value, 0.0, 1.0, 1, #notes))
		local image = playdate.graphics.imageWithText(notes[noteIndex], 20, 20)
		self.noteSprite:setImage(image)
		self.component:setKeyIndex(noteIndex)
	end)
	
	self.hiRangeEncoder = RotaryEncoder(xx + 19, yy - 12, function(value)
		self.component:setHighRange(value)
	end)
	
	self.loRangeEncoder = RotaryEncoder(xx + 19, yy + 22, function(value) 
		self.component:setLowRange(value)
	end)
	
	self.encoders = {
		self.noteEncoder,
		self.hiRangeEncoder,
		self.loRangeEncoder
	}
	
	self.majMinSprite = gfx.sprite.new(arrowMajorImage)
	self.majMinSprite:moveTo(xx - 19, yy + 19)
	self.majMinSprite:add()
	
	self.socketInVector = Vector(xx - 40, yy - (moduleHeight/2) + 20)
	self.socketOutVector = Vector(xx + 41, yy - (moduleHeight/2) + 20)
end


function NormalisedToMidiMod:turn(x, y, change)
	local encoder = self:findClosestEncoder(x, y)
	encoder:turn(change)
end

function NormalisedToMidiMod:findClosestEncoder(x, y)
  local reticleVector = Vector(x, y)
	local closestDistance = 1000
	local closestIndex = -1
	for i=1,#self.encoders do
		local anEncoder = self.encoders[i]
		local encoderVector = Vector(anEncoder.x, anEncoder.y)
		local distance = reticleVector:distance(encoderVector)
		if distance < closestDistance then
			closestDistance = distance
			closestIndex = i
		end
	end
	
	return self.encoders[closestIndex]
end


function NormalisedToMidiMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function NormalisedToMidiMod:setOutCable(patchCable)
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function NormalisedToMidiMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function NormalisedToMidiMod:tryConnectGhostIn(x, y, ghostCable)
	ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
	ghostCable:setGhostReceiveConnected()
	return true
end

function NormalisedToMidiMod:tryConnectGhostOut(x, y, ghostCable)
	ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
	ghostCable:setGhostSendConnected()
	return true
end

function NormalisedToMidiMod:type() return modType end

function NormalisedToMidiMod:getModId()
	return self.modId
end

function NormalisedToMidiMod:handleModClick(tX, tY, listener)
	print("click: " .. tX  .. ":" .. tY)
	self.menuListener = listener
	local actions = {
		{label = "Toggle Major/Minor"},
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Maps a value in the range 0.0 to 1.0 to Midi 1 to 127 values")
			aboutPopup:show()
		elseif action == "Toggle Major/Minor" then
			if self.major == true then
				self.major = false
				self.majMinSprite:setImage(arrowMinorImage)
				self.component:setChordTypeMinor()
			else 
				self.major = true
				self.majMinSprite:setImage(arrowMajorImage)
				self.component:setChordTypeMajor()
			end
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end

	end)
end

function NormalisedToMidiMod:unplug(cableId) self.component:unplug(cableId) end

function NormalisedToMidiMod:repositionBy(x, y)
	self:moveBy(x, y)
	self.noteSprite:moveBy(x, y)
	self.noteEncoder:moveBy(x, y)
	self.hiRangeEncoder:moveBy(x, y)
	self.loRangeEncoder:moveBy(x, y)
	self.majMinSprite:moveBy(x, y)
	
	self.encoders = {
		self.noteEncoder,
		self.hiRangeEncoder,
		self.loRangeEncoder
	}
end

function NormalisedToMidiMod:moveFinish()
	self.socketInVector = Vector(self.x - 40, self.y - (moduleHeight/2) + 20)
	self.socketOutVector = Vector(self.x + 41, self.y - (moduleHeight/2) + 20)
end

function NormalisedToMidiMod:evaporate(onDetachConnected)
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
	
	self.hiRangeEncoder:evaporate()
	self.loRangeEncoder:evaporate()
	
	--then remove sprites
	playdate.graphics.sprite.removeSprites({self.inSocketSprite, self.outSocketSprite})
	self.inSocketSprite = nil
	self.outSocketSprite = nil
	self:remove()
end

function NormalisedToMidiMod.ghostModule()
	local templateImage = playdate.graphics.image.new(moduleWidth, moduleHeight)
	gfx.pushContext(templateImage)
	gfx.setLineWidth(6)
	gfx.setColor(playdate.graphics.kColorBlack)
	gfx.drawRoundRect(3, 3, moduleWidth-6, moduleHeight-6, 8)
	gfx.setLineWidth(1)
	gfx.popContext()
	
	local ghostImage = playdate.graphics.image.new(moduleWidth, moduleHeight)
	gfx.pushContext(ghostImage)
	templateImage:drawFaded(0, 0, 0.3, playdate.graphics.image.kDitherTypeDiagonalLine)
	gfx.popContext()
	
	return playdate.graphics.sprite.new(ghostImage)
end

function NormalisedToMidiMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.chordType = self.component:getChordType()	
	
	modState.noteEncoderVal = self.noteEncoder:getValue()
	modState.hiRangeEncoderVal = self.hiRangeEncoder:getValue()
	modState.loRangeEncoderVal = self.loRangeEncoder:getValue()
	
	return modState
end

function NormalisedToMidiMod:fromState(modState)
	self.component:setChordType(modState.chordType)
	self.noteEncoder:setValue(modState.noteEncoderVal)
	self.hiRangeEncoder:setValue(modState.hiRangeEncoderVal)
	self.loRangeEncoder:setValue(modState.loRangeEncoderVal)
end