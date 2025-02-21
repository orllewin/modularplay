--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Midi/MidiNoteEmit/midi_note_emit_component'

class('MidiNoteEmitterMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local arrowMajorImage = playdate.graphics.image.new("Images/arrow_up")
local arrowMinorImage = playdate.graphics.image.new("Images/arrow_down")

local moduleWidth = 55
local moduleHeight = 75

local modType = "MidiNoteEmitterMod"
local modSubtype = "midi"

local notes = {"C", "C#", "D", "E♭", "E", "F", "F#", "G", "A♭", "A", "B♭", "B"}

function MidiNoteEmitterMod:init(xx, yy, modId)
	MidiNoteEmitterMod.super.init(self)
	
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
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 32)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(97, 32)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.component = MidiNoteEmitterComponent()
	
	local noteC = playdate.graphics.imageWithText("C", 20, 20)
	self.noteSprite = gfx.sprite.new(noteC)
	self.noteSprite:moveTo(xx - 19, yy - 28)
	self.noteSprite:add()
	
	self.noteEncoder = RotaryEncoder(xx - 19, yy - 12, function(value)
		local noteIndex = math.floor(map(value, 0.0, 1.0, 1, 127))
		local image = playdate.graphics.imageWithText(notes[noteIndex], 20, 20)
		self.noteSprite:setImage(image)
		self.component:setValue(value)
	end)
	
	self.encoders = {
		self.noteEncoder,
	}
		
	self.socketInVector = Vector(xx - 40, yy - (moduleHeight/2) + 20)
	self.socketOutVector = Vector(xx + 41, yy - (moduleHeight/2) + 20)
end

function MidiNoteEmitterMod:turn(x, y, change)
	self.noteEncoder:turn(change)
end

function MidiNoteEmitterMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function MidiNoteEmitterMod:setOutCable(patchCable)
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function MidiNoteEmitterMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function MidiNoteEmitterMod:tryConnectGhostIn(x, y, ghostCable)
	ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
	ghostCable:setGhostReceiveConnected()
	return true
end

function MidiNoteEmitterMod:tryConnectGhostOut(x, y, ghostCable)
	ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
	ghostCable:setGhostSendConnected()
	return true
end

function MidiNoteEmitterMod:type() return modType end

function MidiNoteEmitterMod:getModId()
	return self.modId
end

function MidiNoteEmitterMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end