import 'midi'

class('DroneSeqComponent').extends()

function DroneSeqComponent:init()
	DroneSeqComponent.super.init(self)
		
	self.midi = Midi()
	
	self.outSocket1 = Socket("drone_seq_out_1", socket_send)
	self.outSocket2 = Socket("drone_seq_out_2", socket_send)
	self.outSocket3 = Socket("drone_seq_out_3", socket_send)
	self.outSocket4 = Socket("drone_seq_out_4", socket_send)
end

function DroneSeqComponent:setChannelCable(index, cable)
	if index == 1 then
		self.outSocket1:setCable(cable)
	elseif index == 2 then
		self.outSocket2:setCable(cable)
	elseif index == 3 then
		self.outSocket3:setCable(cable)
	elseif index == 4 then
		self.outSocket4:setCable(cable)
	end
end

function DroneSeqComponent:channelFree(index)
	if index == 1 then
		return self.outSocket1:free()
	elseif index == 2 then
		return self.outSocket2:free()
	elseif index == 3 then
		return self.outSocket3:free()
	elseif index == 4 then
		return self.outSocket4:free()
	end
end

function DroneSeqComponent:connected(index)
	if index == 1 then
		return self.outSocket1:connected()
	elseif index == 2 then
		return self.outSocket2:connected()
	elseif index == 3 then
		return self.outSocket3:connected()
	elseif index == 4 then
		return self.outSocket4:connected()
	end
end

function DroneSeqComponent:unplug(cableId)
	if self:connected(1) and "" .. self.outSocket1:getCableId() == "" .. cableId then 
		self.outSocket1:unplug()
	elseif self:connected(2) and "" .. self.outSocket2:getCableId() == "" .. cableId then 
		self.outSocket2:unplug()
	elseif self:connected(3) and "" .. self.outSocket3:getCableId() == "" .. cableId then 
		self.outSocket3:unplug()
	elseif self:connected(4) and "" .. self.outSocket4:getCableId() == "" .. cableId then 
		self.outSocket4:unplug()
	end
end

function DroneSeqComponent:unplug(index)
	if index == 1 then
		self.outSocket1:emit(Event(event_value, -1))
		return self.outSocket1:unplug()
	elseif index == 2 then
		self.outSocket2:emit(Event(event_value, -1))
		return self.outSocket2:unplug()
	elseif index == 3 then
		self.outSocket3:emit(Event(event_value, -1))
		return self.outSocket3:unplug()
	elseif index == 4 then
		self.outSocket4:emit(Event(event_value, -1))
		return self.outSocket4:unplug()
	end
end

function DroneSeqComponent:allNotesOff()
	self.outSocket1:emit(Event(event_value, -1))
	self.outSocket2:emit(Event(event_value, -1))
	self.outSocket3:emit(Event(event_value, -1))
	self.outSocket4:emit(Event(event_value, -1))
end

function DroneSeqComponent:retrigger()
	self:setNoteValue(1, self.channel1Value, nil)
	self:setNoteValue(2, self.channel2Value, nil)
	self:setNoteValue(3, self.channel3Value, nil)
	self:setNoteValue(4, self.channel4Value, nil)
end

function DroneSeqComponent:setNoteValue(index, value, onNoteLabel)
	if value == nil then return end
	local note = math.floor(map(value, 0.0, 1.0, 0, 127))
	if index == 1 then
		self.channel1Value = value
		self.outSocket1:emit(Event(event_value, note))
	elseif index == 2 then
		self.channel2Value = value
		self.outSocket2:emit(Event(event_value, note))
	elseif index == 3 then
		self.channel3Value = value
		self.outSocket3:emit(Event(event_value, note))
	elseif index == 4 then
		self.channel4Value = value
		self.outSocket4:emit(Event(event_value, note))
	end

	if onNoteLabel ~= nil then onNoteLabel(self.midi:noteNumberToLabel(note)) end
end