--[[
	© 2023 Orllewin - All Rights Reserved.
]]
class('LowpassComponent').extends()

function LowpassComponent:init()
	LowpassComponent.super.init(self)
	
	self.isActive = true
	self.mix = 0.5
	
	self.filter = playdate.sound.twopolefilter.new(playdate.sound.kFilterLowPass)
	self.filter:setMix(self.mix)
	self.filter:setFrequency(5000)
	self.filter:setResonance(0.5)
	
	self.outSocket = Socket("lowpass_mod_out", socket_send)
	self.inSocket = Socket("lowpass_mod_in", socket_receive)
end

function LowpassComponent:setChannel(channel)
	self.channel = channel
	channel:addEffect(self.filter)
end

function LowpassComponent:removeChannel(channel)
	channel:removeEffect(self.filter)
end

function LowpassComponent:toggleOnOff()
	if self.isActive then
		self.filter:setMix(0.0)
		self.isActive = false
	else
		self.filter:setMix(self.mix)
		self.isActive = true
	end
end

function LowpassComponent:isOn()
	return self.isActive
end

function LowpassComponent:setMix(value)
	self.mix = value
	self.filter:setMix(self.mix)
end

function LowpassComponent:setFrequency(value)
	self.filter:setFrequency(value)
end

function LowpassComponent:setResonance(value)
	self.filter:setResonance(value)
end

function LowpassComponent:inConnected()
	return self.inSocket:connected()
end

function LowpassComponent:outConnected()
	return self.outSocket:connected()
end

function LowpassComponent:unplug(cableId)
	if self:inConnected() and "" .. cableId == "" .. self.inSocket:getCableId() then
		self.inSocket:unplug()
		self.channel:removeEffect(self.filter)
	end
	if self:outConnected() and "" .. cableId == "" .. self.outSocket:getCableId() then
		self.outSocket:unplug()
	end
end

function LowpassComponent:unplugIn(cableId)
	self.inSocket:setCable(nil)
end

function LowpassComponent:unplugOut(cableId)
	self.outSocket:setCable(nil)
end

function LowpassComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function LowpassComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end