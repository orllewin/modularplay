--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('SamplePlayComponent').extends()

local minFrames = 50

function SamplePlayComponent:init(onChannel)
	SamplePlayComponent.super.init(self)
		
	self.sample = playdate.sound.sample.new("Samples/silence")
	self.sampleplayer = playdate.sound.sampleplayer.new(self.sample)
	self.sampleSynth = nil
	self:load("Samples/silence")
	self.channel = playdate.sound.channel.new()
	self.channel:addSource(self.sampleplayer)
	self.channel:setVolume(gDefaultVolume)
	
	self.looping = false
	
	if onChannel ~= nil then onChannel(self.channel) end
	
	self.connected = false

	self.outSocket = Socket("sample_player_component_out", socket_send)
	
	self.pedalInSocket = Socket("sample_player_component_in", socket_receive, function(event) 
		if self.outSocket:connected() then
			if event:getValue() >= 1 then
				self:triggerPlay()
			elseif event:getValue() <= -1 then
				self:stopPlay()
			end
		end
	end)
	
	self.noteInSocket = Socket("sample_player_component_note_in", socket_receive, function(event) 
		print("NOTE IN VALUE: " .. event:getValue())
		if self.outSocket:connected() and self.sampleSynth ~= nil then
			if event:getValue() < 0 then 
				self.sampleSynth:noteOff()
			else
				--note volume length
				self.sampleSynth:playMIDINote(math.floor(event:getValue()), 1)
			end
		end
	end)
end

function SamplePlayComponent:stopPlay()
	self.sampleplayer:stop()
end

function SamplePlayComponent:isPlaying()
	return self.sampleplayer:isPlaying()
end

function SamplePlayComponent:triggerPlay()
	self.sampleplayer:stop()
	if self.looping then
		self.sampleplayer:play(0)
	else
		self.sampleplayer:play()
	end
end

function SamplePlayComponent:isLooping()
	return self.looping
end

function SamplePlayComponent:setLooping(looping)
	self.looping = looping
end

function SamplePlayComponent:load(path)
	self.sampleplayer:stop()
	self.sample = playdate.sound.sample.new(path)
	self.sampleplayer:setSample(self.sample)
	if path ~= "Samples/silence" then
		if self.sampleSynth ~= nil then
			self.channel:removeSource(self.sampleSynth)
		end
		self.sampleSynth = playdate.sound.synth.new(self.sample, 0.5, 0.6)
		self.channel:addSource(self.sampleSynth)
	end
	
	local sampleRate = playdate.sound.getSampleRate()
	local frames = self.sampleplayer:getLength() * sampleRate
	
	self.frames = math.floor(frames)
	self.startFrame = 0
	self.endFrame = self.frames
end

function SamplePlayComponent:setSamplePitch(value)
	if value == nil then return end
	self.normalisedRate = value
	if value > 0.25 then
		self.sampleplayer:setRate(map(value, 0.0, 1.0, 0.0, 2.0))
	else
		self.sampleplayer:setRate(map(value, 0.0, 0.25, -2, 0.0))
	end

end

function SamplePlayComponent:setSampleStart(value)
	print("SamplePlayComponent:setSampleStart: " .. value .. " frames: " .. self.frames)
	self.startFrame = math.floor(map(value, 0.0, 1.0, 0, self.frames))
	if self.endFrame - self.startFrame < minFrames then
		self.startFrame = self.endFrame - minFrames
	end
	
	self.sampleplayer:stop()
	
	local subsample = self.sample:getSubsample(self.startFrame, self.endFrame)
	if(subsample == nil)then
		print("ERROR - subsample is nil")
	else
		self.sampleplayer:setSample(subsample)
		if self.sampleSynth ~= nil then
			self.channel:removeSource(self.sampleSynth)
			self.sampleSynth = playdate.sound.synth.new(subsample, 0.5, 0.6)
			self.channel:addSource(self.sampleSynth)
		end
		self:setSamplePitch(self.normalisedRate)
		--self:triggerPlay()
	end
end

function SamplePlayComponent:setSampleEnd(value)
	self.endFrame = math.floor(map(value, 0.0, 1.0, 0, self.frames))
	if self.endFrame - self.startFrame < minFrames then
		self.endFrame = self.startFrame + minFrames
	end
	
	self.sampleplayer:stop()
	
	local subsample = self.sample:getSubsample(self.startFrame, self.endFrame)
	self.sampleplayer:setSample(subsample)
	if self.sampleSynth ~= nil then
		self.channel:removeSource(self.sampleSynth)
		self.sampleSynth = playdate.sound.synth.new(subsample, 0.5, 0.6)
		self.channel:addSource(self.sampleSynth)
	end
	self:setSamplePitch(self.normalisedRate)
	--self:triggerPlay()
end


function SamplePlayComponent:unplug(cableId)
	if self:pedalInConnected() and "" .. self.pedalInSocket:getCableId() == "" .. cableId then 
		self.sampleplayer:stop()
		self.sampleSynth:stop()
		self.pedalInSocket:unplug() 
	end
	if self:noteInConnected() and "" .. self.noteInSocket:getCableId() == "" .. cableId then 
		self.sampleplayer:stop()
		self.sampleSynth:stop()
		self.noteInSocket:unplug() 
	end
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then 
		self.sampleplayer:stop()
		self.sampleSynth:stop()
		self.outSocket:unplug() 
		self.channel:setVolume(0)
	end
end

function SamplePlayComponent:setPedalInCable(cable) self.pedalInSocket:setCable(cable) end
function SamplePlayComponent:setNoteInCable(cable) self.noteInSocket:setCable(cable) end
function SamplePlayComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function SamplePlayComponent:unplugPedalIn() self.pedalInSocket:unplug() end
function SamplePlayComponent:unplugNoteIn() self.noteInSocket:unplug() end
function SamplePlayComponent:unplugOut() 
	if self.sampleplayer ~= nil then
		self.sampleplayer:stop()
	end
	
	if self.sampleSynth ~= nil then
		self.sampleSynth:stop()
	end
	
	self.channel:setVolume(0)
	self.outSocket:unplug() 
end
function SamplePlayComponent:pedalInConnected() return self.pedalInSocket:connected() end
function SamplePlayComponent:noteInConnected() return self.noteInSocket:connected() end
function SamplePlayComponent:outConnected() return self.outSocket:connected() end