--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'midi'

class('MidiGenBouncyBallComponent').extends()

function MidiGenBouncyBallComponent:init()
	MidiGenBouncyBallComponent.super.init(self)
	
	self.midi = Midi()
	
	self.normalisedMin = 0.0
	self.normalisedMax = 1.0
	self.minNoteIndex = 1
	self.maxNoteIndex = 127
	
	self.keyIndex = 1
	self.scale = "Major"
	
	self:updateNotes()
		
	self.bpm = -1
	self.divisionChoice = 4
	self.probability = 60
	self.delayMS = 250
	
	self.didDelay = false
	
	self.outSocket = Socket("random_component_out", socket_send)
	
	self.inSocket = Socket("random_component_in", socket_receive, function(event) 
		self:doClockDelay(event)
	end)
end

function MidiGenBouncyBallComponent:emitNote(x, y)
	if self:outConnected() then	
		self:doRandomToMidi()
	end
end

function MidiGenBouncyBallComponent:setScale(value)
	
	local scales = self:getScales()
	self.scale = scales[math.floor(map(value, 0.0, 1.0, 1, #scales))].name
	print("midigen encoder setScale(): " .. self.scale)
	self:updateNotes()
end

function MidiGenBouncyBallComponent:setScaleName(scale)
	self.scale = scale
	print("midigen menu setScale(): " .. self.scale)
	self:updateNotes()
end

function MidiGenBouncyBallComponent:getScale()
	return self.scale
end

function MidiGenBouncyBallComponent:getScales()
	return self.midi:getScales()
end

function MidiGenBouncyBallComponent:setKeyIndex(index)
	self.keyIndex = index
	self:updateNotes()
end

function MidiGenBouncyBallComponent:updateNotes()
	self.notes = {}
	self.notes = self.midi:getNotes2(self.keyIndex + 23, self.scale)
	print("Notes updated, there are " .. #self.notes .. " notes")
	self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, #self.notes))
	self.maxNoteIndex = math.floor(map(self.normalisedMax, 0.0, 1.0, 1, #self.notes))
	
	
	print("Notes updated: min Note Index: " .. self.minNoteIndex)
	print("Notes updated: max Note Index: " .. self.maxNoteIndex)
end

function MidiGenBouncyBallComponent:setHighRange(value)
	self.normalisedMax = value
	self.maxNoteIndex = math.floor(map(self.normalisedMax, 0.0, 1.0, 1, #self.notes))
end

function MidiGenBouncyBallComponent:setLowRange(value)
	self.normalisedMin = value
	self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, #self.notes))
end

function MidiGenBouncyBallComponent:doRandomToMidi()
	local rnd = math.random()
	local noteIndex = math.floor(map(rnd, 0.0, 1.0, self.minNoteIndex, self.maxNoteIndex))
	local midiNote = self.notes[noteIndex]
	self.outSocket:emit(Event(event_value, midiNote))
end

function MidiGenBouncyBallComponent:updateRange()	
	self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, #self.notes))
	self.maxNoteIndex = math.floor(map(self.normalisedMax, 0.0, 1.0, 1, #self.notes))
end

function MidiGenBouncyBallComponent:setChance(normalisedChance)
	self.probability = math.floor(normalisedChance * 100)
	return "" .. self.probability .. "%"
end

function MidiGenBouncyBallComponent:setHighRange(value)
	self.normalisedMax = value
	self:updateRange()
end

function MidiGenBouncyBallComponent:setLowRange(value)
	self.normalisedMin = value
	self:updateRange()
end

function MidiGenBouncyBallComponent:unplug(cableId)
	if self:inConnected() and "" .. self.inSocket:getCableId() == "" .. cableId then self.inSocket:unplug() end
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then self.outSocket:unplug() end
end

function MidiGenBouncyBallComponent:setInCable(cable) self.inSocket:setCable(cable) end
function MidiGenBouncyBallComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function MidiGenBouncyBallComponent:unplugIn() self.inSocket:unplug() end
function MidiGenBouncyBallComponent:unplugOut() self.outSocket:unplug() end
function MidiGenBouncyBallComponent:inConnected() return self.inSocket:connected() end
function MidiGenBouncyBallComponent:outConnected() return self.outSocket:connected() end