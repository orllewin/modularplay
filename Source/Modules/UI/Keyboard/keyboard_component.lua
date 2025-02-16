--[[
	© 2023 Orllewin - All Rights Reserved.
]]
class('KeyboardComponent').extends()

function KeyboardComponent:init()
	KeyboardComponent.super.init(self)
	
	self.inSocket = Socket("keyboard_in", socket_receive)
	self.outSocket = Socket("keyboard_out", socket_send)
end

function KeyboardComponent:outConnected()
	return self.outSocket:connected()
end

function KeyboardComponent:bang()
	return self.outSocket:emit(Event(event_bang, 1))
end

function KeyboardComponent:unbang()
	return self.outSocket:emit(Event(event_bang, -1))
end

function KeyboardComponent:unplug(cableId)
	if self:outConnected() and "" .. cableId == "" .. self.outSocket:getCableId() then
		self.outSocket:unplug()
	end
end


function KeyboardComponent:unplugOut(cableId)
	self.outSocket:setCable(nil)
end

function KeyboardComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end