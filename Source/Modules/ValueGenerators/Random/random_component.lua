--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('RandomComponent').extends()

function RandomComponent:init()
	RandomComponent.super.init(self)
	
	self.outSocket = Socket("random_component_out", socket_send)
	
	self.inSocket = Socket("random_component_in", socket_receive, function(event) 
		self.outSocket:emit(Event(event_value, math.random()))
	end)
end

function RandomComponent:unplug(cableId)
	if self:inConnected() and "" .. self.inSocket:getCableId() == "" .. cableId then self.inSocket:unplug() end
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then self.outSocket:unplug() end
end

function RandomComponent:setInCable(cable) self.inSocket:setCable(cable) end
function RandomComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function RandomComponent:unplugIn() self.inSocket:unplug() end
function RandomComponent:unplugOut() self.outSocket:unplug() end
function RandomComponent:inConnected() return self.inSocket:connected() end
function RandomComponent:outConnected() return self.outSocket:connected() end