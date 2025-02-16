--[[

]]--
class('Mixer4SlidersComponent').extends()

function Mixer4SlidersComponent:init(onOsc)
	Mixer4SlidersComponent.super.init(self)
		
	self.in1Socket = Socket("mixer_in_1", socket_receive)
	self.in2Socket = Socket("mixer_in_2", socket_receive)
	self.in3Socket = Socket("mixer_in_3", socket_receive)
	self.in4Socket = Socket("mixer_in_4", socket_receive)
	
	self.auto1Socket = Socket("mixer_auto_in_1", socket_receive, function(event) 
		onOsc(1, event:getValue())
	end)
	self.auto2Socket = Socket("mixer_auto_in_2", socket_receive, function(event) 
		onOsc(2, event:getValue())
	end)
	self.auto3Socket = Socket("mixer_auto_in_3", socket_receive, function(event) 
		onOsc(3, event:getValue())
	end)
	self.auto4Socket = Socket("mixer_auto_in_4", socket_receive, function(event) 
		onOsc(4, event:getValue())
	end)

end

function Mixer4SlidersComponent:setPan(index, value)
	if value == nil then return end
	local pan = map(value, 0.0, 1.0, -1.0, 1.0)
	if index == 1 then
		if self:in1Connected() then self:getChannel(1):setPan(pan) end
	elseif index == 2 then
		if self:in2Connected() then self:getChannel(2):setPan(pan) end
	elseif index == 3 then
		if self:in3Connected() then self:getChannel(3):setPan(pan) end
	elseif index == 4 then
		if self:in4Connected() then self:getChannel(4):setPan(pan) end
	end
end

function Mixer4SlidersComponent:trySetVolume(index, value)
	if index == 1 then
		if self:in1Connected() then self:getChannel(1):setVolume(value) end
	elseif index == 2 then
		if self:in2Connected() then self:getChannel(2):setVolume(value) end
	elseif index == 3 then
		if self:in3Connected() then self:getChannel(3):setVolume(value) end
	elseif index == 4 then
		if self:in4Connected() then self:getChannel(4):setVolume(value) end
	end
end

function Mixer4SlidersComponent:setChannel(index, channel)
	if index == 1 then
		self.channel1 = channel
	elseif index == 2 then
		self.channel2 = channel
	elseif index == 3 then
		self.channel3 = channel
	elseif index == 4 then
		self.channel4 = channel
	end
end

function Mixer4SlidersComponent:getChannel(index)
  if index == 1 then
		return self.channel1
	elseif index == 2 then
		return self.channel2
	elseif index == 3 then
		return self.channel3
	elseif index == 4 then
		return self.channel4
	end
end

function Mixer4SlidersComponent:setIn1Cable(cable) self.in1Socket:setCable(cable) end
function Mixer4SlidersComponent:setIn2Cable(cable) self.in2Socket:setCable(cable) end
function Mixer4SlidersComponent:setIn3Cable(cable) self.in3Socket:setCable(cable) end
function Mixer4SlidersComponent:setIn4Cable(cable) self.in4Socket:setCable(cable) end

function Mixer4SlidersComponent:setAutoInCable(index, cable)
	if index == 1 then
		self.auto1Socket:setCable(cable)
	elseif index == 2 then
		self.auto2Socket:setCable(cable)
	elseif index == 3 then
		self.auto3Socket:setCable(cable)
	elseif index == 4 then
		self.auto4Socket:setCable(cable)
	end	
end

function Mixer4SlidersComponent:autoInConnected(index)
	if index == 1 then
		return self.auto1Socket:connected()
	elseif index == 2 then
		return self.auto2Socket:connected()
	elseif index == 3 then
		return self.auto3Socket:connected()
	elseif index == 4 then
		return self.auto4Socket:connected()
	end	
end

function Mixer4SlidersComponent:autoInFree(index)
	if index == 1 then
		return self.auto1Socket:free()
	elseif index == 2 then
		return self.auto2Socket:free()
	elseif index == 3 then
		return self.auto3Socket:free()
	elseif index == 4 then
		return self.auto4Socket:free()
	end	
end



-- -- ----
function Mixer4SlidersComponent:unplug(cableId)
	if self:in1Connected() and "" .. self.in1Socket:getCableId() == "" .. cableId then
		self.in1Socket:unplug()
	elseif self:in2Connected() and "" .. self.in2Socket:getCableId() == "" .. cableId then
		self.in2Socket:unplug()
	elseif self:in3Connected() and "" .. self.in3Socket:getCableId() == "" .. cableId then
		self.in3Socket:unplug()
	elseif self:in4Connected() and "" .. self.in4Socket:getCableId() == "" .. cableId then
		self.in4Socket:unplug()
	end
end

function Mixer4SlidersComponent:unplugIn1() 
	local channel1 = self:getChannel(1)
	if channel1 ~= nil then channel1:setVolume(0) end
	self.in1Socket:setCable(nil) 
end
function Mixer4SlidersComponent:unplugIn2() 
	local channel2 = self:getChannel(2)
	if channel2 ~= nil then channel2:setVolume(0) end
	self.in2Socket:setCable(nil)
end
function Mixer4SlidersComponent:unplugIn3() 
	local channel3 = self:getChannel(3)
	if channel3 ~= nil then channel3:setVolume(0) end
	self.in3Socket:setCable(nil)
end
function Mixer4SlidersComponent:unplugIn4() 
	local channel4 = self:getChannel(4)
	if channel4 ~= nil then channel4:setVolume(0) end
	self.in4Socket:setCable(nil)
end
function Mixer4SlidersComponent:unplugAuto1() self.auto1Socket:setCable(nil) end
function Mixer4SlidersComponent:unplugAuto2() self.auto2Socket:setCable(nil) end
function Mixer4SlidersComponent:unplugAuto3() self.auto3Socket:setCable(nil) end
function Mixer4SlidersComponent:unplugAuto4() self.auto4Socket:setCable(nil) end
function Mixer4SlidersComponent:in1Connected() return self.in1Socket:connected() end
function Mixer4SlidersComponent:in2Connected() return self.in2Socket:connected() end
function Mixer4SlidersComponent:in3Connected() return self.in3Socket:connected() end
function Mixer4SlidersComponent:in4Connected() return self.in4Socket:connected() end
function Mixer4SlidersComponent:auto1Connected() return self.auto1Socket:connected() end
function Mixer4SlidersComponent:auto2Connected() return self.auto2Socket:connected() end
function Mixer4SlidersComponent:auto3Connected() return self.auto3Socket:connected() end
function Mixer4SlidersComponent:auto4Connected() return self.auto4Socket:connected() end
function Mixer4SlidersComponent:in1Free() return not self.in1Socket:connected() end
function Mixer4SlidersComponent:in2Free() return not self.in2Socket:connected() end
function Mixer4SlidersComponent:in3Free() return not self.in3Socket:connected() end
function Mixer4SlidersComponent:in4Free() return not self.in4Socket:connected() end