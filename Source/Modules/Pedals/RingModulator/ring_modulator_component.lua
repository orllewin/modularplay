--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('RingModulatorComponent').extends()

function RingModulatorComponent:init(id, listener)
	RingModulatorComponent.super.init(self)
	
	self.isActive = true
	self.mix = 0.5
	
	self.id = id
	self.listener = listener
	
	self.filter = playdate.sound.ringmod.new()
	self.filter:setMix(self.mix)
	
	self.outSocket = Socket("ring_mod_out", socket_send)
	
	self.inSocket = Socket("ring_mod_in", socket_receive, function(event) 
		if event ~= nil then
			
		end
	end)
end

function RingModulatorComponent:setChannel(channel)
	self.channel = channel
	channel:addEffect(self.filter)
end

function RingModulatorComponent:removeChannel(channel)
	channel:removeEffect(self.filter)
end

function RingModulatorComponent:toggleOnOff()
	if self.isActive then
		self.filter:setMix(0.0)
		self.isActive = false
	else
		self.filter:setMix(self.mix)
		self.isActive = true
	end
end

function RingModulatorComponent:isOn()
	return self.isActive
end

function RingModulatorComponent:setMix(value)
	self.mix = value
	self.filter:setMix(self.mix)
end

function RingModulatorComponent:setFrequency(value, onFrequency)
	local freq = map(value, 0.0, 1.0, 20, 10000)
	self.filter:setFrequency(freq)
	if onFrequency ~= nil then onFrequency(freq) end
end

function RingModulatorComponent:unplug(cableId)
	if self:inConnected() and "" .. cableId == "" .. self.inSocket:getCableId() then
		self.inSocket:unplug()
		self.channel:removeEffect(self.filter)
	end
	if self:outConnected() and "" .. cableId == "" .. self.outSocket:getCableId() then
		self.outSocket:unplug()
	end
end

function RingModulatorComponent:inConnected() return self.inSocket:connected() end
function RingModulatorComponent:outConnected() return self.outSocket:connected() end
function RingModulatorComponent:unplugIn(cableId) self.inSocket:unplug() end
function RingModulatorComponent:unplugOut(cableId) self.outSocket:unplug() end
function RingModulatorComponent:setInCable(cable) self.inSocket:setCable(cable) end
function RingModulatorComponent:setOutCable(cable) self.outSocket:setCable(cable) end