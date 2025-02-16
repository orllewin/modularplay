--[[

 Emits every other event
	
]]--
class('ClockDividerComponent').extends()

local fmod <const> = math.fmod

function ClockDividerComponent:init()
	ClockDividerComponent.super.init(self)
	

	self.outSocket = Socket("throttle_out", socket_send)
	
	self.counter = 0
	
	self.inSocket = Socket("throttle_in", socket_receive, function(event) 
		self:onInEvent(event)
	end)
end

function ClockDividerComponent:onInEvent(event)
	self.counter += 1
	if fmod(self.counter, 2) == 0 then
		self.outSocket:emit(event)
	end
end

function ClockDividerComponent:unplug(cableId)
	if self:inConnected() and "" .. self.inSocket:getCableId() == "" .. cableId then
		self.inSocket:unplug()
	end
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then
		self.outSocket:unplug()
	end
end

function ClockDividerComponent:unplugIn() self.inSocket:unplug() end
function ClockDividerComponent:unplugOut() self.outSocket:unplug() end

function ClockDividerComponent:inConnected()
	return self.inSocket:connected()
end

function ClockDividerComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function ClockDividerComponent:outConnected()
	return self.outSocket:connected()
end

function ClockDividerComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end