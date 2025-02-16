--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('OnePoleFilterComponent').extends()

function OnePoleFilterComponent:init(id, listener)
	OnePoleFilterComponent.super.init(self)
	
	self.id = id
	self.listener = listener
	
	self.filter = playdate.sound.onepolefilter.new()
	
	self.outSocket = Socket("one_pole_out", socket_send)
	
	self.inSocket = Socket("one_pole_in", socket_receive, function(event) 
		if event ~= nil then
			
		end
	end)
end

function OnePoleFilterComponent:setChannel(channel)
	channel:addEffect(self.filter)
end

function OnePoleFilterComponent:removeChannel(channel)
	channel:removeEffect(self.filter)
end

function OnePoleFilterComponent:setMix(value)
	print("onepole mix: " .. value)
	self.filter:setMix(value)
end

function OnePoleFilterComponent:setCutoffFreq(value)
	print("onepole paramval: " .. value)
	self.filter:setParameter(value)
end

function OnePoleFilterComponent:inConnected()
	return self.inSocket:connected()
end

function OnePoleFilterComponent:outConnected()
	return self.outSocket:connected()
end

function OnePoleFilterComponent:unplug(cableId)
	if self:inConnected() and "" .. cableId == "" .. self.inSocket:getCableId() then
		self.inSocket:unplug()
		self.channel:removeEffect(self.filter)
	end
	if self:outConnected() and "" .. cableId == "" .. self.outSocket:getCableId() then
		self.outSocket:unplug()
	end
end

function OnePoleFilterComponent:unplugIn(cableId) self.inSocket:unplug() end
function OnePoleFilterComponent:unplugOut(cableId) self.outSocket:unplug() end

function OnePoleFilterComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function OnePoleFilterComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end