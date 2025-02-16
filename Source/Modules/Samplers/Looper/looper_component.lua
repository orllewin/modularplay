--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('LooperComponent').extends()

function LooperComponent:init(onChannel)
	LooperComponent.super.init(self)
	
	self.bpm = -1
	self.step = 0
	self.loopLength = 16
	
	self.sample = playdate.sound.sample.new("Samples/loops/glitch_loop_04_175BPM")
	self.sampleplayer = playdate.sound.sampleplayer.new(self.sample)
	self.channel = playdate.sound.channel.new()
	self.channel:addSource(self.sampleplayer)
	self.channel:setVolume(gDefaultVolume)
	if onChannel ~= nil then onChannel(self.channel) end
	
	self.connected = false
	self.playing = false
	
	self.outSocket = Socket("sample_looper_component_out", socket_send)
	
	self.inSocket = Socket("sample_looper_component_in", socket_receive, function(event) 
		self.step += 1
		if self.step == self.loopLength and self.inSocket:connected() and self.outSocket:connected() then
			if self.bpm ~= event:getBPM() then
				local bpm = event:getBPM()
				local barLength = (60000/bpm)
				local sampleLength = self.sample:getLength() * 1000
				local rate = (sampleLength/barLength) / 4
				
				print("sample lengthms: " .. sampleLength .. " barLengthMS: " .. barLength .. " ratio: " .. rate )
				self.sampleplayer:setRate(rate)
			end
			self.sampleplayer:stop()
			self.sampleplayer:play()
		end
		
		if event:getValue() == 1 and self.playing == false then
			self.sampleplayer:stop()
			self.sampleplayer:play()
			self.playing = true
		end
		
		if self.step == self.loopLength then
			self.step = 0
		end
	end)
end

function LooperComponent:pitchDown()
	-- do usual rate calc then half - and also double steps
end

function LooperComponent:pitchUp()
	-- do usual rate calc then double - and also half steps
end

function LooperComponent:setLoopLength(value)
	local index = math.floor(map(value, 0.0, 1.0, 1, 5))
	if index == 1 then
		self.loopLength = 1
	elseif index == 2 then
		self.loopLength = 2
	elseif index == 3 then
		self.loopLength = 4
	elseif index == 4 then
		self.loopLength = 8
	elseif index == 5 then
		self.loopLength = 16
	end
	
	self.bpm = -1
	
	if self.step > self.loopLength then
		self.step = 0
	end
	
	self.playing = false
end

function LooperComponent:unplug(cableId)
	if self:inConnected() and "" .. self.inSocket:getCableId() == "" .. cableId then 
		self.sampleplayer:stop()
		self.inSocket:unplug() 
	end
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then 
		self.sampleplayer:stop()
		self.outSocket:unplug() 
	end
end

function LooperComponent:setInCable(cable) self.inSocket:setCable(cable) end
function LooperComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function LooperComponent:unplugIn() self.inSocket:unplug() end
function LooperComponent:unplugOut() self.outSocket:unplug() end
function LooperComponent:inConnected() return self.inSocket:connected() end
function LooperComponent:outConnected() return self.outSocket:connected() end