--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('RandomShifterComponent').extends()

function RandomShifterComponent:init()
	RandomShifterComponent.super.init(self)
	
	self.outSocket = Socket("random_component_out", socket_send)
	
	self.inSocket = Socket("random_component_in", socket_receive, function(event) 
		if math.random() < 0.33 then
			self.outSocket:emit(Event(event_value, event:getValue() - 12))
		elseif math.random() > 0.66 then
			self.outSocket:emit(Event(event_value, event:getValue() + 12))
		else
			self.outSocket:emit(event)
		end
		
	end)
end

function RandomShifterComponent:unplug(cableId)
	if self:inConnected() and "" .. self.inSocket:getCableId() == "" .. cableId then self.inSocket:unplug() end
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then self.outSocket:unplug() end
end

function RandomShifterComponent:setInCable(cable) self.inSocket:setCable(cable) end
function RandomShifterComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function RandomShifterComponent:unplugIn() self.inSocket:unplug() end
function RandomShifterComponent:unplugOut() self.outSocket:unplug() end
function RandomShifterComponent:inConnected() return self.inSocket:connected() end
function RandomShifterComponent:outConnected() return self.outSocket:connected() end