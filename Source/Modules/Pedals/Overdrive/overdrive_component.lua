--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('OverdriveComponent').extends()

function OverdriveComponent:init()
	OverdriveComponent.super.init(self)
	
	self.isActive = true
	self.mix = 0.5
	
	self.filter = playdate.sound.overdrive.new()
	self.filter:setMix(self.mix)
	self.filter:setGain(0.5)
	self.filter:setLimit(0.5)
	
	self.outSocket = Socket("overdrive_mod_out", socket_send)
	self.inSocket = Socket("overdrive_mod_in", socket_receive)
end

function OverdriveComponent:setChannel(channel)
	self.channel = channel
	channel:addEffect(self.filter)
end

function OverdriveComponent:removeChannel(channel)
	channel:removeEffect(self.filter)
end

function OverdriveComponent:toggleOnOff()
	if self.isActive then
		self.filter:setMix(0.0)
		self.isActive = false
	else
		self.filter:setMix(self.mix)
		self.isActive = true
	end
end

function OverdriveComponent:isOn()
	return self.isActive
end


function OverdriveComponent:setMix(value)
	self.mix = value
	self.filter:setMix(self.mix)
end

function OverdriveComponent:setGain(value)
	self.filter:setGain(value)
end

function OverdriveComponent:setLimit(value)
	self.filter:setLimit(value)
end

function OverdriveComponent:inConnected()
	return self.inSocket:connected()
end

function OverdriveComponent:outConnected()
	return self.outSocket:connected()
end

function OverdriveComponent:unplug(cableId)
	if self:inConnected() and "" .. cableId == "" .. self.inSocket:getCableId() then
		self.inSocket:unplug()
		self.channel:removeEffect(self.filter)
	end
	if self:outConnected() and "" .. cableId == "" .. self.outSocket:getCableId() then
		self.outSocket:unplug()
	end
end

function OverdriveComponent:unplugIn(cableId)
	self.inSocket:setCable(nil)
end

function OverdriveComponent:unplugOut(cableId)
	self.outSocket:setCable(nil)
end

function OverdriveComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function OverdriveComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end