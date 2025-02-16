--[[


]]--

class('SeqGridComponent').extends()

function SeqGridComponent:init(listener)
	SeqGridComponent.super.init(self)
	
	self.listener = listener
	
	self.noteOffMode = true
	
	self.values = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}
	self.step = 1
	
	self.outSocket = Socket("sequence_component_out", socket_send)
	
	self.inSocket = Socket("sequence_component_in", socket_receive, function(event) 
		if self.noteOffMode == false and self.values[self.step] == -1 then
			--noop
		else 
			self.outSocket:emit(Event(event_value, self.values[self.step]))
		end
		
		if self.listener ~= nil then
			self.listener(self.step)
		end
		
		self.step += 1
		
		if self.step > 16 then
			self.step = 1
		end
	end)
end

function SeqGridComponent:toggleNoteOffMode()
	self.noteOffMode = not self.noteOffMode
end

function SeqGridComponent:getStep()
	return self.step
end

function SeqGridComponent:setValue(index, value)
	self.values[index] = value
end

function SeqGridComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function SeqGridComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function SeqGridComponent:unplugIn()
	self.inSocket:setCable(nil)
end

function SeqGridComponent:unplugOut()
	self.outSocket:setCable(nil)
end

function SeqGridComponent:inConnected()
	return self.inSocket:connected()
end

function SeqGridComponent:outConnected()
	return self.outSocket:connected()
end

