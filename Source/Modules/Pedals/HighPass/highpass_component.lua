--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('HighpassComponent').extends()

function HighpassComponent:init()
	HighpassComponent.super.init(self)
	
	self.isActive = true
	self.mix = 0.5
	
	self.filter = playdate.sound.twopolefilter.new(playdate.sound.kFilterHighPass)
	self.filter:setMix(self.mix)
	self.filter:setFrequency(5000)
	self.filter:setResonance(0.5)
	
	self.outSocket = Socket("lowpass_mod_out", socket_send)
	self.inSocket = Socket("lowpass_mod_in", socket_receive)
end

function HighpassComponent:setChannel(channel)
	self.channel = channel
	channel:addEffect(self.filter)
end

function HighpassComponent:removeChannel(channel)
	channel:removeEffect(self.filter)
end

function HighpassComponent:toggleOnOff()
	if self.isActive then
		self.filter:setMix(0.0)
		self.isActive = false
	else
		self.filter:setMix(self.mix)
		self.isActive = true
	end
end

function HighpassComponent:isOn()
	return self.isActive
end

function HighpassComponent:setMix(value)
	self.mix = value
	self.filter:setMix(self.mix)
end

function HighpassComponent:setFrequency(value)
	self.filter:setFrequency(value)
end

function HighpassComponent:setResonance(value)
	self.filter:setResonance(value)
end

function HighpassComponent:inConnected()
	return self.inSocket:connected()
end

function HighpassComponent:outConnected()
	return self.outSocket:connected()
end

function HighpassComponent:unplug(cableId)
	if self:inConnected() and "" .. cableId == "" .. self.inSocket:getCableId() then
		self.inSocket:unplug()
		self.channel:removeEffect(self.filter)
	end
	if self:outConnected() and "" .. cableId == "" .. self.outSocket:getCableId() then
		self.outSocket:unplug()
	end
end

function HighpassComponent:unplugIn()
	self.inSocket:unplug()
end

function HighpassComponent:unplugOut()
	self.outSocket:unplug()
end

function HighpassComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function HighpassComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end