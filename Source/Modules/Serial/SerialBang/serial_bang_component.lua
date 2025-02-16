--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('SerialBangComponent').extends()

function SerialBangComponent:init(listener)
	SerialBangComponent.super.init(self)
	
	self.listener = listener
	
	self.outSocket = Socket("serial_bang_component_out", socket_send)
end

function SerialBangComponent:bang()
	self.outSocket:emit(Event(event_bang, 1))
	if self.listener ~= nil then self.listener(1) end
end

function SerialBangComponent:unplug(cableId)
	if self:outConnected() and self.outSocket:getCableId() == cableId then self.outSocket:unplug() end
end

function SerialBangComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function SerialBangComponent:unplugOut() self.outSocket:unplug() end
function SerialBangComponent:outConnected() return self.outSocket:connected() end