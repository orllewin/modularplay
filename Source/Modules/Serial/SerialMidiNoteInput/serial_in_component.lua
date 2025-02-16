--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('SerialInComponent').extends()

function SerialInComponent:init(listener)
	SerialInComponent.super.init(self)
	
	self.listener = listener
	
	self.outSocket = Socket("serial_in_component_out", socket_send)
end

function SerialInComponent:mn(midiNote)
	self.outSocket:emit(Event(event_value, midiNote))
	if self.listener ~= nil then self.listener(midiNote) end
end

function SerialInComponent:unplug(cableId)
	if self:outConnected() and self.outSocket:getCableId() == cableId then self.outSocket:unplug() end
end

function SerialInComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function SerialInComponent:unplugOut() self.outSocket:unplug() end
function SerialInComponent:outConnected() return self.outSocket:connected() end