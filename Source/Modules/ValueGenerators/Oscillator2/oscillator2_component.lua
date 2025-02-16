--[[
	© 2023 Orllewin - All Rights Reserved.
]]
class('Oscillator2Component').extends()

function Oscillator2Component:init()
	Oscillator2Component.super.init(self)
	
	self.position = 0.55
	self.width = 1.0
	self.frequency = 0.25
	
	self.timer = nil

	self.outSocket = Socket("osc_out", socket_send)
	
end

function Oscillator2Component:update()
	if self.timer ~= nil then
		self.timer:remove()
	end
	
	if self.updateTimer ~= nil then
		self.updateTimer:remove()
	end
	
	local startValue = math.max(0.0, self.position - (self.width/2))
	local endValue = math.min(1.0, self.position + (self.width/2))
	
	local ms = map(self.frequency, 0.0, 1.0, 50000, 200)
	
	self.timer = playdate.timer.new(ms, startValue, endValue)
	self.timer.reverses = true
	self.timer.repeats = true
	
	self.updateTimer = playdate.timer.new(100, function() 
		self.outSocket:emit(Event(event_value, self.timer.value))
	end)
	self.updateTimer.repeats = true
end

function Oscillator2Component:setPosition(value)
	print("setPosition(): " .. value)
	self.position = value
	self:update()
end

function Oscillator2Component:setWidth(value)
	print("setWidth(): " .. value)
	self.width = value
	self:update()
end

function Oscillator2Component:setFrequency(value)
	print("setFrequency(): " .. value)
	self.frequency = value
	self:update()
end

function Oscillator2Component:unplug(cableId)
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then self.outSocket:unplug() end
end

function Oscillator2Component:unplugOut(cableId) self.outSocket:unplug() end
function Oscillator2Component:outConnected() return self.outSocket:connected() end

function Oscillator2Component:setOutCable(cable)
	self.outSocket:setCable(cable)
	self:update()
end