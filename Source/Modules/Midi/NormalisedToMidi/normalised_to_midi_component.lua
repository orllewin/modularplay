--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'midi'

class('NormalisedToMidiComponent').extends()

local chordTypeMajor = 1
local chordTypeMinor = 2

function NormalisedToMidiComponent:init()
	NormalisedToMidiComponent.super.init(self)
	
	self.outSocket = Socket("normalised_to_midi_component_out", socket_send)
	
	self.midi = Midi()
	
	self.normalisedMin = 0.0
	self.normalisedMax = 1.0
	self.minNoteIndex = 1
	self.maxNoteIndex = 127
	
	self.chordType = chordTypeMajor
	self.keyIndex = 1
	
	self:updateNotes()
	
	self.inSocket = Socket("normalised_to_midi_component_in", socket_receive, function(event) 
		local midiNote = 0
		midiNote = self.notes[math.floor(map(event:getValue(), 0.0, 1.0, self.minNoteIndex, self.maxNoteIndex))]
		self.outSocket:emit(Event(event_value, midiNote))
	end)
end

function NormalisedToMidiComponent:setChordType(chordType)
	if chordType == chordTypeMajor then
		self:setChordTypeMajor()
	elseif chordType == chordTypeMinor then
		self:setChordTypeMinor()
	end
end

function NormalisedToMidiComponent:setChordTypeMajor()
	self.chordType = chordTypeMajor
	self:updateNotes()
end

function NormalisedToMidiComponent:setChordTypeMinor()
	self.chordType = chordTypeMinor
	self:updateNotes()
end

function NormalisedToMidiComponent:setKeyIndex(index)
	self.keyIndex = index
	self:updateNotes()
end

function NormalisedToMidiComponent:updateNotes()
	self.notes = {}
	self.notes = self.midi:getNotes(self.keyIndex, self.chordType)
	print("Notes updated, there are " .. #self.notes .. " notes")
	self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, #self.notes))
	self.maxNoteIndex = math.floor(map(self.normalisedMax, 0.0, 1.0, 1, #self.notes))
	
	
	print("Notes updated: min Note Index: " .. self.minNoteIndex)
	print("Notes updated: max Note Index: " .. self.maxNoteIndex)
end

function NormalisedToMidiComponent:setHighRange(value)
	self.normalisedMax = value
	self.maxNoteIndex = math.floor(map(self.normalisedMax, 0.0, 1.0, 1, #self.notes))
end

function NormalisedToMidiComponent:setLowRange(value)
	self.normalisedMin = value
	self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, #self.notes))
end

function NormalisedToMidiComponent:unplug(cableId)
	if self:inConnected() and "" .. self.inSocket:getCableId() == "" .. cableId then self.inSocket:unplug() end
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then self.outSocket:unplug() end
end

function NormalisedToMidiComponent:getChordType() return self.chordType end
function NormalisedToMidiComponent:setInCable(cable) self.inSocket:setCable(cable) end
function NormalisedToMidiComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function NormalisedToMidiComponent:unplugIn() self.inSocket:unplug() end
function NormalisedToMidiComponent:unplugOut() self.outSocket:unplug() end
function NormalisedToMidiComponent:inConnected() return self.inSocket:connected() end
function NormalisedToMidiComponent:outConnected() return self.outSocket:connected() end