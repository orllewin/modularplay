--[[

 Emits every other event
	
]]--
class('ToClockComponent').extends()

local fmod <const> = math.fmod

function ToClockComponent:init()
	ToClockComponent.super.init(self)
	

	self.outSocket = Socket("to_clock_out", socket_send)
	
	self.counter = 0
	
	self.inSocket = Socket("to_clock_in", socket_receive, function(event) 
		self.outSocket:emit(Event(event_bang, 1))
	end)
end

function ToClockComponent:unplug(cableId)
	if self:inConnected() and "" .. self.inSocket:getCableId() == "" .. cableId then
		self.inSocket:unplug()
	end
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then
		self.outSocket:unplug()
	end
end

function ToClockComponent:unplugIn() self.inSocket:unplug() end
function ToClockComponent:unplugOut() self.outSocket:unplug() end

function ToClockComponent:inConnected()
	return self.inSocket:connected()
end

function ToClockComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function ToClockComponent:outConnected()
	return self.outSocket:connected()
end

function ToClockComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end