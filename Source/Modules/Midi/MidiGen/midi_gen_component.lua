--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'midi'

class('MidiGenComponent').extends()

function MidiGenComponent:init()
	MidiGenComponent.super.init(self)
	
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
	
	self.blackhole = 0.5
	
	self.inSocket = Socket("random_component_in", socket_receive, function(event) 
		self:doClockDelay(event)
	end)
end

function MidiGenComponent:setScale(value)
	
	local scales = self:getScales()
	self.scale = scales[math.floor(map(value, 0.0, 1.0, 1, #scales))].name
	print("midigen encoder setScale(): " .. self.scale)
	self:updateNotes()
end

function MidiGenComponent:setScaleName(scale)
	self.scale = scale
	print("midigen menu setScale(): " .. self.scale)
	self:updateNotes()
end

function MidiGenComponent:getScale()
	return self.scale
end

function MidiGenComponent:getScales()
	return self.midi:getScales()
end

function MidiGenComponent:setKeyIndex(index)
	self.keyIndex = index
	self:updateNotes()
end

function MidiGenComponent:updateNotes()
	self.notes = {}
	self.notes = self.midi:getNotes2(self.keyIndex + 23, self.scale)
	print("Notes updated, there are " .. #self.notes .. " notes")
	self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, #self.notes))
	self.maxNoteIndex = math.floor(map(self.normalisedMax, 0.0, 1.0, 1, #self.notes))
	
	
	print("Notes updated: min Note Index: " .. self.minNoteIndex)
	print("Notes updated: max Note Index: " .. self.maxNoteIndex)
end

function MidiGenComponent:setHighRange(value)
	self.normalisedMax = value
	self.maxNoteIndex = math.floor(map(self.normalisedMax, 0.0, 1.0, 1, #self.notes))
end

function MidiGenComponent:setLowRange(value)
	self.normalisedMin = value
	self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, #self.notes))
end

function MidiGenComponent:doClockDelay(event)
		--if delayed last event skip the next
		if self.didDelay then
			self.didDelay = false
			return
		end
		
		--if bpm changes update new ms delay
		if event:getValue() ~= self.bpm then
			--update delayMS
			self.bpm = event:getValue()
			self:calculateMS()
		end
		
		if self.delayMS == -1 then
			self:doBlackhole(event)
		elseif math.random(100) < self.probability then
			self.didDelay = true
			playdate.timer.performAfterDelay(self.delayMS, function() 
				self:doBlackhole(event)
			end)
		else
			self:doBlackhole(event)
		end
end

function MidiGenComponent:doBlackhole(event)
	if math.random() > self.blackhole then
		self:doRandomToMidi(event)
	else
		if math.random() > 0.9 then
			self.outSocket:emit(Event(event_value, -1))
		end
	end
end

function MidiGenComponent:doRandomToMidi(event)
	local rnd = math.random()
	local noteIndex = math.floor(map(rnd, 0.0, 1.0, self.minNoteIndex, self.maxNoteIndex))
	local midiNote = self.notes[noteIndex]
	self.outSocket:emit(Event(event_value, midiNote))
end

function MidiGenComponent:updateRange()	
	self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, #self.notes))
	self.maxNoteIndex = math.floor(map(self.normalisedMax, 0.0, 1.0, 1, #self.notes))
end

function MidiGenComponent:setDivisionDelay(normalisedInput)
	self.divisionChoice = math.floor(map(normalisedInput, 0.0, 1.0, 1, 8))
	self:calculateMS()
	return self.divisionChoice
end

function MidiGenComponent:calculateMS()
	
	local bpm = self.bpm
	local bpmMs = (60000/bpm)
	
	if self.divisionChoice == 1 then
		self.delayMS = -1
	elseif self.divisionChoice == 2 then
		self.delayMS = bpmMs
	elseif self.divisionChoice == 3 then
		self.delayMS = bpmMs/2
	elseif self.divisionChoice == 4 then
		self.delayMS = bpmMs/4
	elseif self.divisionChoice == 5 then
		self.delayMS = bpmMs/8
	elseif self.divisionChoice == 6 then 
		self.delayMS = bpmMs/16
	elseif self.divisionChoice == 7 then 
		self.delayMS = bpmMs/32
	elseif self.divisionChoice == 8 then	
		self.delayMS = bpmMs/64
	else
		self.delayMS = 1
	end	
end

function MidiGenComponent:setChance(normalisedChance)
	self.probability = math.floor(normalisedChance * 100)
	return "" .. self.probability .. "%"
end

function MidiGenComponent:getDivChoice()
	return self.divisionChoice
end

function MidiGenComponent:setGravity(value)
	self.blackhole = value
end

function MidiGenComponent:setHighRange(value)
	self.normalisedMax = value
	self:updateRange()
end

function MidiGenComponent:setLowRange(value)
	self.normalisedMin = value
	self:updateRange()
end

function MidiGenComponent:unplug(cableId)
	if self:inConnected() and "" .. self.inSocket:getCableId() == "" .. cableId then self.inSocket:unplug() end
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then self.outSocket:unplug() end
end

function MidiGenComponent:setInCable(cable) self.inSocket:setCable(cable) end
function MidiGenComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function MidiGenComponent:unplugIn() self.inSocket:unplug() end
function MidiGenComponent:unplugOut() self.outSocket:unplug() end
function MidiGenComponent:inConnected() return self.inSocket:connected() end
function MidiGenComponent:outConnected() return self.outSocket:connected() end