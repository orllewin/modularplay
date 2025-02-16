--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('DelayComponent').extends()

local maxSeconds = 2.0

function DelayComponent:init()
	DelayComponent.super.init(self)
	
	self.isActive = true
	self.mix = 0.4
	

	self.filter = playdate.sound.delayline.new(maxSeconds)
	self.filter:setFeedback(0.20)
	self.filter:setMix(0)
	self.tap = self.filter:addTap(maxSeconds)
	self.tap:setVolume(self.mix)
	self:setTapDelay(0.35)
	
	self.outSocket = Socket("delay_mod_out", socket_send)
	
	self.inSocket = Socket("delay_mod_in", socket_receive)
end

function DelayComponent:setChannel(channel)
	self.channel = channel
	channel:addEffect(self.filter)
	channel:addSource(self.tap)
end

function DelayComponent:removeChannel(channel)
	channel:removeEffect(self.filter)
	channel:removeSource(self.tap)
end

function DelayComponent:isOn()
	return self.isActive
end

function DelayComponent:toggleOnOff()
	if self.isActive then
		self.tap:setVolume(0.0)
		self.isActive = false
	else
		self.tap:setVolume(self.mix)
		self.isActive = true
	end
end

-- Delay mix stays at 0, it's the tap that supplies the delay effect
function DelayComponent:setMix(value)
	--self.filter:setMix(value)
	self.mix = value
	self.tap:setVolume(value)
end

function DelayComponent:setFeedback(value)
	self.filter:setFeedback(value)
end

function DelayComponent:setTapDelay(value)
	self.tap:setDelay(map(value, 0.0, 1.0, 0.0, maxSeconds))
end

function DelayComponent:inConnected()
	return self.inSocket:connected()
end

function DelayComponent:outConnected()
	return self.outSocket:connected()
end

function DelayComponent:unplug(cableId)
	if self:inConnected() and cableId == self.inSocket:getCableId() then
		self.inSocket:unplug()
		if self.channel ~= nil then 
			self.channel:removeEffect(self.filter)
		end
	end
	if self:outConnected() and cableId == self.outSocket:getCableId() then
		print("DelayComponent:unplug(): removing out  " .. cableId)
		self.outSocket:unplug()
		if self.channel ~= nil then 
			self.channel:removeEffect(self.filter)
		end
	end
end

function DelayComponent:unplugIn()
	self.inSocket:unplug()
end

function DelayComponent:unplugOut()
	self.outSocket:unplug()
end

function DelayComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function DelayComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end