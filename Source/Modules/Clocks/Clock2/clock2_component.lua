--[[
	© 2023 Orllewin - All Rights Reserved.

	A clock just emits quarter-note bang events (event_bang).
	It only has an out-socket.
	Bpm calculations: https://tuneform.com/tools/time-tempo-bpm-to-milliseconds-ms
]]

import 'Coracle/timing_utils'

class('Clock2Component').extends()

local defaultBPM = 120

function Clock2Component:init(listener, bpm)
	Clock2Component.super.init(self)
	
	self.listener = listener
	self.outSocketA = Socket("clock2_a", socket_send)
	self.outSocketB = Socket("clock2_b", socket_send)
	self.outSocketC = Socket("clock2_c", socket_send)
	self.outSocketD = Socket("clock2_d", socket_send)
	
	self.timestamp = 0
	
	self.step = 1
	
	if bpm == nil then
		self.bpm = defaultBPM
	else
		self.bpm = bpm
	end
end

function Clock2Component:stop()
	self.timer:remove()
end

function Clock2Component:getBPM()
	return self.bpm
end

function Clock2Component:setOutACable(cable)
	self.outSocketA:setCable(cable)
end

function Clock2Component:setOutBCable(cable)
	self.outSocketB:setCable(cable)
end

function Clock2Component:setOutCCable(cable)
	self.outSocketC:setCable(cable)
end

function Clock2Component:setOutDCable(cable)
	self.outSocketD:setCable(cable)
end

function Clock2Component:aConnected()
	return self.outSocketA:connected()
end

function Clock2Component:bConnected()
	return self.outSocketB:connected()
end

function Clock2Component:cConnected()
	return self.outSocketC:connected()
end

function Clock2Component:dConnected()
	return self.outSocketD:connected()
end

function Clock2Component:unplug(cableId)
	if self:aConnected() and self.outSocketA:getCableId() == cableId then
		self.outSocketA:unplug()
	end
	
	if self:bConnected() and self.outSocketB:getCableId() == cableId then
		self.outSocketB:unplug()
	end
	
	if self:cConnected() and self.outSocketC:getCableId() == cableId then
		self.outSocketC:unplug()
	end
	
	if self:dConnected() and self.outSocketD:getCableId() == cableId then
		self.outSocketD:unplug()
	end
end

function Clock2Component:unplugA()
	self.outSocketA:setCable(nil)
end

function Clock2Component:unplugB()
	self.outSocketB:setCable(nil)
end

function Clock2Component:unplugC()
	self.outSocketC:setCable(nil)
end

function Clock2Component:unplugD()
	self.outSocketD:setCable(nil)
end

-- There's a bug with playdate.timer
-- it reliably takes 34 and 31 (simulator and hardware) longer than what you ask for.
function Clock2Component:bpmMs(bpm)
	if playdate.isSimulator then
		return (60000/(bpm*4)) - 34
	else
		return (60000/(bpm*4)) - 31
	end
end

function Clock2Component:bang()	
	if self.outSocketA:connected() then
		self.outSocketA:emit(Event(event_bang, self.step, self.bpm))
	end
	if self.outSocketB:connected() then
		self.outSocketB:emit(Event(event_bang, self.step, self.bpm))
	end
	if self.outSocketC:connected() then
		self.outSocketC:emit(Event(event_bang, self.step, self.bpm))
	end
	if self.outSocketD:connected() then
		self.outSocketD:emit(Event(event_bang, self.step, self.bpm))
	end
	
	self.step += 1
	if self.step == 17 then self.step = 1 end

	if self.listener ~= nil then self.listener() end
end

function Clock2Component:setBPM(bpm)
	self.bpm = bpm
	if self.timer ~= nil then self.timer:remove() end
	self.timer = playdate.timer.new(self:bpmMs(self.bpm), function() 
		self:bang()
	end)
	self.timer.repeats = true
end