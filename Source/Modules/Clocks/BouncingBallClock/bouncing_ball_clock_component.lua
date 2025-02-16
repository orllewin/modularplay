--[[
	© 2023 Orllewin - All Rights Reserved.
]]
class('BouncingBallClockComponent').extends()

function BouncingBallClockComponent:init()
	BouncingBallClockComponent.super.init(self)
	self.outSocket = Socket("random_component_out", socket_send)
end

function BouncingBallClockComponent:emitNote(x, y)
	if self:outConnected() then	
		self.outSocket:emit(Event(event_bang, 100))--bpm is not correct obviously
	end
end

function BouncingBallClockComponent:unplug(cableId)
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then self.outSocket:unplug() end
end

function BouncingBallClockComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function BouncingBallClockComponent:unplugOut() self.outSocket:unplug() end
function BouncingBallClockComponent:outConnected() return self.outSocket:connected() end