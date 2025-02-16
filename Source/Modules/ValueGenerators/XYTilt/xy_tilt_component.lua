--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('XYTiltComponent').extends()

function XYTiltComponent:init(onUpdate)
	XYTiltComponent.super.init(self)
	
	self.onUpdate = onUpdate
	
	self.stopping = false
	
	playdate.startAccelerometer()

	self.outXSocket = Socket("xy_out_x", socket_send)
	self.outYSocket = Socket("xy_out_y", socket_send)
	
	self.updateTimer = playdate.timer.new(75, function() 
		if self.stopping then return end
		local x, y, z = playdate.readAccelerometer()

		x = math.min(math.max(-1.0, x * 2), 1.0)
		y = math.min(math.max(-1.0, y * 2), 1.0) * -1
		onUpdate(x, y)
	  self.outXSocket:emit(Event(event_value, map(x, -1.0, 1.0, 0.0, 1.0)))
		self.outYSocket:emit(Event(event_value, map(y, -1.0, 1.0, 0.0, 1.0)))
	end)
		self.updateTimer.repeats = true
end


function XYTiltComponent:unplug(cableId)
	if self:outXConnected() and "" .. self.outXSocket:getCableId() == "" .. cableId then self.outXSocket:unplug() end
	
	if self:outYConnected() and "" .. self.outYSocket:getCableId() == "" .. cableId then self.outYSocket:unplug() end
end

function XYTiltComponent:stop()
	self.stopping = true
	self.updateTimer:remove()
end

function XYTiltComponent:unplugOutX(cableId) self.outXSocket:unplug() end
function XYTiltComponent:outXConnected() return self.outXSocket:connected() end
function XYTiltComponent:setOutXCable(cable)self.outXSocket:setCable(cable)end

function XYTiltComponent:unplugOutY(cableId) self.outYSocket:unplug() end
function XYTiltComponent:outYConnected() return self.outYSocket:connected() end
function XYTiltComponent:setOutYCable(cable)self.outYSocket:setCable(cable)end