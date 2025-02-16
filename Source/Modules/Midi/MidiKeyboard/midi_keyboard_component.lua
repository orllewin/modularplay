--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'midi'

class('MidiKeyboardComponent').extends()

local whiteNotes = {0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19, 21, 23, 24, 26, 28, 29, 31, 33, 35}
local blackNotes = {1, 3, -1, 6, 8, 10, -1, 13, 15, -1, 18, 20, 22, -1, 25, 27, -1, 30, 32, 34}

function MidiKeyboardComponent:init(onChannel)
	MidiKeyboardComponent.super.init(self)
	self.midi = Midi()
	self.octave = 3
	self.outSocket = Socket("midi_keys_component_out", socket_send)
end

function MidiKeyboardComponent:octaveUp()
	if self.octave < 9 then self.octave += 1 end
end

function MidiKeyboardComponent:octaveDown()
	if self.octave > 0 then self.octave -= 1 end
end

function MidiKeyboardComponent:noteOff()
	if self.outSocket:connected() then
		self.outSocket:emit(Event(event_value, -1))
	end
end

function MidiKeyboardComponent:playBlackNote(index)
	if self.outSocket:connected() then
		local midiNote = (self.octave * 12) + blackNotes[index]
		if blackNotes[index] ~= -1 then
			print("Playing note: " .. self.midi:noteNumberToLabelNoOctave(midiNote))
			self.outSocket:emit(Event(event_value, midiNote))
		end
	end 
end

function MidiKeyboardComponent:playWhiteNote(index)
	if self.outSocket:connected() then
		local midiNote = (self.octave * 12) + whiteNotes[index]
		print("Playing note: " .. self.midi:noteNumberToLabelNoOctave(midiNote))
		self.outSocket:emit(Event(event_value, midiNote))
	end 
end

function MidiKeyboardComponent:unplug(cableId)
	if self:outConnected() and self.outSocket:getCableId() == cableId then 
		print("MidiKeyboardComponent:unplug(cableId): YES " .. cableId)
		self.outSocket:unplug() 
		return true
	else
		print("MidiKeyboardComponent:unplug(cableId): NO " .. cableId)
		return false
	end
end

function MidiKeyboardComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function MidiKeyboardComponent:unplugOut() self.outSocket:unplug() end
function MidiKeyboardComponent:outConnected() return self.outSocket:connected() end