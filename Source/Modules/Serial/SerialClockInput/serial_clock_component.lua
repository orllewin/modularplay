--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('SerialClockComponent').extends()

function SerialClockComponent:init(listener)
	SerialClockComponent.super.init(self)
	
	self.listener = listener
	
	self.outSocket = Socket("serial_in_component_out", socket_send)
end

function SerialClockComponent:clock(beat)
	print("SerialClockComponent:clock " .. beat)
	self.outSocket:emit(Event(event_bang, beat))
	if self.listener ~= nil then self.listener(beat) end
end

function SerialClockComponent:unplug(cableId)
	if self:outConnected() and self.outSocket:getCableId() == cableId then self.outSocket:unplug() end
end

function SerialClockComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function SerialClockComponent:unplugOut() self.outSocket:unplug() end
function SerialClockComponent:outConnected() return self.outSocket:connected() end