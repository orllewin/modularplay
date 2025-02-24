--[[
	© 2025 Orllewin - All Rights Reserved.
]]

import 'midi'

class('MidiNoteEmitterComponent').extends()

function MidiNoteEmitterComponent:init()
	MidiNoteEmitterComponent.super.init(self)
	
	self.outSocket = Socket("midi_note_emitter_out", socket_send)
	
	self.midi = Midi()
		
	-- Middle C
	self.midiNote = 60
	
	self.inSocket = Socket("midi_note_emitter_in", socket_receive, function(event) 
		self.outSocket:emit(Event(event_value, self.midiNote))
	end)
end

function MidiNoteEmitterComponent:setValue(value)
	self.midiNote = math.floor(map(value, 0.0, 1.0, 36, 95))
end

function MidiNoteEmitterComponent:getNoteStr()
	return self.midi:noteNumberToLabel(self.midiNote)
end

function MidiNoteEmitterComponent:getMidiNote() return self.midiNote end
function MidiNoteEmitterComponent:setInCable(cable) self.inSocket:setCable(cable) end
function MidiNoteEmitterComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function MidiNoteEmitterComponent:unplugIn() self.inSocket:unplug() end
function MidiNoteEmitterComponent:unplugOut() self.outSocket:unplug() end
function MidiNoteEmitterComponent:inConnected() return self.inSocket:connected() end
function MidiNoteEmitterComponent:outConnected() return self.outSocket:connected() end