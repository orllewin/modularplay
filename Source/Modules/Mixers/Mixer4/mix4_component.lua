--[[

]]--
class('Mixer4Component').extends()

function Mixer4Component:init()
	Mixer4Component.super.init(self)
	
	self.outSocket = Socket("mixer_out", socket_send)
	
	self.in1Socket = Socket("mixer_in_1", socket_receive)
	self.in2Socket = Socket("mixer_in_2", socket_receive)
	self.in3Socket = Socket("mixer_in_3", socket_receive)
	self.in4Socket = Socket("mixer_in_4", socket_receive)
end

function Mixer4Component:trySetVolume(index, value)
	if index == 1 then
		if self:in1Connected() then 
			local channel = self:getChannel(1)
			if channel ~= nil then channel:setVolume(value) end
		end
	elseif index == 2 then
		if self:in2Connected() then 
			local channel = self:getChannel(2)
			if channel ~= nil then channel:setVolume(value) end
		end
	elseif index == 3 then
		if self:in3Connected() then 
			local channel = self:getChannel(3)
			if channel ~= nil then channel:setVolume(value) end
		end
	elseif index == 4 then
		if self:in4Connected() then 
			local channel = self:getChannel(4)
			if channel ~= nil then channel:setVolume(value) end
		end
	end
end

function Mixer4Component:getCableId(index)
	if index == 1 then
		return self.in1Socket:getCableId()
	elseif index == 2 then
		return self.in2Socket:getCableId()
	elseif index == 3 then
		return self.in3Socket:getCableId()
	elseif index == 4 then
		return self.in4Socket:getCableId()
	end
end

function Mixer4Component:unplug(index)
	if index == 1 then
		self.in1Socket:setCable(nil)
		self.channel1 = nil
	elseif index == 2 then
		self.in2Socket:setCable(nil)
		self.channel2 = nil
	elseif index == 3 then
		self.in3Socket:setCable(nil)
		self.channel3 = nil
	elseif index == 4 then
		self.in4Socket:setCable(nil)
		self.channel4 = nil
	end
end

function Mixer4Component:setChannel(index, channel)
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

function Mixer4Component:getChannel(index)
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

function Mixer4Component:setIn1Cable(cable)
	print("Mixer4Component:setIn1Cable....")
	self.in1Socket:setCable(cable)
end

function Mixer4Component:setIn2Cable(cable)
	self.in2Socket:setCable(cable)
end

function Mixer4Component:setIn3Cable(cable)
	self.in3Socket:setCable(cable)
end

function Mixer4Component:setIn4Cable(cable)
	self.in4Socket:setCable(cable)
end
-- -- ----
function Mixer4Component:unplugIn1()
	local channel1 = self:getChannel(1)
	if channel1 ~= nil then channel1:setVolume(0) end
	self.in1Socket:setCable(nil)
end

function Mixer4Component:unplugIn2()
	local channel2 = self:getChannel(2)
	if channel2 ~= nil then channel2:setVolume(0) end
	self.in2Socket:setCable(nil)
end

function Mixer4Component:unplugIn3()
	local channel3= self:getChannel(3)
	if channel3 ~= nil then channel3:setVolume(0) end
	self.in3Socket:setCable(nil)
end

function Mixer4Component:unplugIn4()
	local channel4 = self:getChannel(4)
	if channel4 ~= nil then channel4:setVolume(0) end
	self.in4Socket:setCable(nil)
end

-- --- -----
function Mixer4Component:outConnected()
	return self.outSocket:connected()
end

function Mixer4Component:in1Connected()
	return self.in1Socket:connected()
end

function Mixer4Component:in2Connected()
	return self.in2Socket:connected()
end

function Mixer4Component:in3Connected()
	return self.in3Socket:connected()
end

function Mixer4Component:in4Connected()
	return self.in4Socket:connected()
end

function Mixer4Component:in1Free()
	return not self.in1Socket:connected()
end

function Mixer4Component:in2Free()
	return not self.in2Socket:connected()
end

function Mixer4Component:in3Free()
	return not self.in3Socket:connected()
end

function Mixer4Component:in4Free()
	return not self.in4Socket:connected()
end

