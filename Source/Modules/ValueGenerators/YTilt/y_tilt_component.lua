--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('YTiltComponent').extends()

function YTiltComponent:init(onUpdate)
	YTiltComponent.super.init(self)
	
	self.onUpdate = onUpdate
	
	self.stopping = false
	
	playdate.startAccelerometer()

	self.outYSocket = Socket("y_out_y", socket_send)
	
	self.updateTimer = playdate.timer.new(75, function() 
		if self.stopping then return end
		local x, y, z = playdate.readAccelerometer()

		y = math.min(math.max(-1.0, y * 2), 1.0) * -1
		self.onUpdate(y)
		self.outYSocket:emit(Event(event_value, y))
	end)
	self.updateTimer.repeats = true
end


function YTiltComponent:unplug(cableId)	
	if self:outYConnected() and "" .. self.outYSocket:getCableId() == "" .. cableId then self.outYSocket:unplug() end
end

function YTiltComponent:stop()
	self.stopping = true
	self.updateTimer:remove()
end

function YTiltComponent:unplugOutY(cableId) self.outYSocket:unplug() end
function YTiltComponent:outYConnected() return self.outYSocket:connected() end
function YTiltComponent:setOutYCable(cable)self.outYSocket:setCable(cable)end