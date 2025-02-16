--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('BitcrusherComponent').extends()

function BitcrusherComponent:init()
	BitcrusherComponent.super.init(self)
	
	self.isActive = true
	self.mix = 0.5
	
	self.filter = playdate.sound.bitcrusher.new()
	self.filter:setMix(self.mix)
	self.filter:setAmount(0.0)
	self.filter:setUndersampling(0.0)

	self.outSocket = Socket("bitcrusher_mod_out", socket_send)
	self.inSocket = Socket("bitcrusher_mod_in", socket_receive)
end

function BitcrusherComponent:setChannel(channel)
	self.channel = channel
	channel:addEffect(self.filter)
end

function BitcrusherComponent:removeChannel(channel)
	channel:removeEffect(self.filter)
end

function BitcrusherComponent:toggleOnOff()
	if self.isActive then
		self.filter:setMix(0.0)
		self.isActive = false
	else
		self.filter:setMix(self.mix)
		self.isActive = true
	end
end

function BitcrusherComponent:isOn()
	return self.isActive
end

function BitcrusherComponent:setMix(value)
	print("BitcrusherComponent:setMix: " .. value)
	self.mix = value
	self.filter:setMix(self.mix)
end

function BitcrusherComponent:setAmount(value)
	print("BitcrusherComponent:setAmount: " .. value)
	self.filter:setAmount(value)
end

function BitcrusherComponent:setUndersampling(value)
	print("BitcrusherComponent:setUndersampling: " .. value)
	self.filter:setUndersampling(value)
end

function BitcrusherComponent:inConnected()
	return self.inSocket:connected()
end

function BitcrusherComponent:outConnected()
	return self.outSocket:connected()
end

function BitcrusherComponent:unplug(cableId)
	if self:inConnected() and "" .. cableId == "" .. self.inSocket:getCableId() then
		self.inSocket:unplug()
		self.channel:removeEffect(self.filter)
	end
	if self:outConnected() and "" .. cableId == "" .. self.outSocket:getCableId() then
		self.outSocket:unplug()
	end
end

function BitcrusherComponent:unplugIn()
	self.inSocket:unplug()
end

function BitcrusherComponent:unplugOut()
	self.outSocket:unplug()
end

function BitcrusherComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function BitcrusherComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end