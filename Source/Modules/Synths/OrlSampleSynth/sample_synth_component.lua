--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('SampleSynthComponent').extends()

function SampleSynthComponent:init(onChannel)
	SampleSynthComponent.super.init(self)
	
	self.expiring = false
		
	self.sample = nil
	self.sampleSynthA = nil
	self.sampleSynthB = nil
	
	self.attack = 0.1
	self.decay = 0.1
	self.sustain = 0.8
	self.release = 1.0
	self.curve = 0.5

	self.channel = playdate.sound.channel.new()
	self.channel:setVolume(gDefaultVolume)
	
	self:load("Samples/pcm/celestial_pad", nil, nil)
	
	
	if onChannel ~= nil then onChannel(self.channel) end
	
	self.connected = false

	self.outSocket = Socket("sample_player_component_out", socket_send)
	
	self.noteInSocket = Socket("sample_player_component_note_in", socket_receive, function(event) 
		if self.expiring == true then return end 
		if self.outSocket:connected() then
			if event:getValue() < 0 then 
				if self.sampleSynthA ~= nil then
					self.sampleSynthA:noteOff()
				end
				if self.sampleSynthB ~= nil then
					self.sampleSynthB:noteOff()
				end
			else				
				if self.sampleSynthA:isPlaying() then
					self.sampleSynthA:noteOff()
					self.sampleSynthB:playMIDINote(math.floor(event:getValue()), 1)
				elseif self.sampleSynthB:isPlaying() then
					self.sampleSynthB:noteOff()
					self.sampleSynthA:playMIDINote(math.floor(event:getValue()), 1)
				else
					self.sampleSynthA:playMIDINote(math.floor(event:getValue()), 1)
				end
			end
		end
	end)
end

function SampleSynthComponent:stopAll()
	self.expiring = true
	self:stopPlay()
	self.channel:remove()
end

function SampleSynthComponent:stopPlay()
	if sampleSynthA ~= nil then self.sampleSynthA:stop() end
	if sampleSynthB ~= nil then self.sampleSynthB:stop() end
end

function SampleSynthComponent:isPlaying()
	return self.sampleSynthA:isPlaying() or self.sampleSynthB:isPlaying()
end

function SampleSynthComponent:loadWithSamplesSustain(path, sustainStartFrames, sustainEndFrames)
	self.sample = playdate.sound.sample.new(path)
	
	if self.sampleSynthA ~= nil then
		self.sampleSynthA:stop()
		self.channel:removeSource(self.sampleSynthA)
	end
	if self.sampleSynthB ~= nil then
		self.sampleSynthB:stop()
		self.channel:removeSource(self.sampleSynthB)
	end
	local sampleRate = playdate.sound.getSampleRate()
	local frames = self.sample:getLength() * sampleRate
	if sustainStartFrames ~= nil and sustainEndFrames ~= nil then
		--turning sustain off for now due a bug with Playdate's audio engine:
		self.sampleSynthA = playdate.sound.synth.new(self.sample)
		self.sampleSynthA:setADSR(self.attack, self.decay, self.sustain, self.release)
		self.sampleSynthA:setEnvelopeCurvature(self.curve)
		self.sampleSynthB = playdate.sound.synth.new(self.sample)
		self.sampleSynthB:setADSR(self.attack, self.decay, self.sustain, self.release)
		self.sampleSynthB:setEnvelopeCurvature(self.curve)
	else
		self.sampleSynthA = playdate.sound.synth.new(self.sample)
		self.sampleSynthA:setADSR(self.attack, self.decay, self.sustain, self.release)
		self.sampleSynthA:setEnvelopeCurvature(self.curve)
		self.sampleSynthB = playdate.sound.synth.new(self.sample)
		self.sampleSynthB:setADSR(self.attack, self.decay, self.sustain, self.release)
		self.sampleSynthB:setEnvelopeCurvature(self.curve)
	end
	--self.sampleSynth:setLegato(true)
	self.channel:addSource(self.sampleSynthA)
	self.channel:addSource(self.sampleSynthB)
end

function SampleSynthComponent:load(path, sustainStart, sustainEnd)
	self.sample = playdate.sound.sample.new(path)

	if self.sampleSynthA ~= nil then
		self.sampleSynthA:stop()
		self.channel:removeSource(self.sampleSynthA)
	end
	if self.sampleSynthB ~= nil then
		self.sampleSynthB:stop()
		self.channel:removeSource(self.sampleSynthB)
	end
	local sampleRate = playdate.sound.getSampleRate()
	local frames = self.sample:getLength() * sampleRate
	if sustainStart ~= nil and sustainEnd ~= nil then
		--turning sustain off for now due a bug with Playdate's audio engine:
		self.sampleSynthA = playdate.sound.synth.new(self.sample)
		self.sampleSynthA:setADSR(self.attack, self.decay, self.sustain, self.release)
		self.sampleSynthA:setEnvelopeCurvature(self.curve)
		self.sampleSynthB = playdate.sound.synth.new(self.sample)
		self.sampleSynthB:setADSR(self.attack, self.decay, self.sustain, self.release)
		self.sampleSynthB:setEnvelopeCurvature(self.curve)
		--self.sampleSynth = playdate.sound.synth.new(self.sample, math.floor(sustainStart * sampleRate), math.floor(sustainEnd * sampleRate))
	else
		self.sampleSynthA = playdate.sound.synth.new(self.sample)
		self.sampleSynthA:setADSR(self.attack, self.decay, self.sustain, self.release)
		self.sampleSynthA:setEnvelopeCurvature(self.curve)
		self.sampleSynthB = playdate.sound.synth.new(self.sample)
		self.sampleSynthB:setADSR(self.attack, self.decay, self.sustain, self.release)
		self.sampleSynthB:setEnvelopeCurvature(self.curve)
	end
	
	self.channel:addSource(self.sampleSynthA)
	self.channel:addSource(self.sampleSynthB)
end

function SampleSynthComponent:unplug(cableId)
	if self:noteInConnected() and "" .. self.noteInSocket:getCableId() == "" .. cableId then 
		if self.sampleSynthA ~= nil then self.sampleSynthA:stop() end
		if self.sampleSynthB ~= nil then self.sampleSynthB:stop() end
		self.noteInSocket:unplug() 
	end
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then 
		if self.sampleSynthA ~= nil then self.sampleSynthA:stop() end
		if self.sampleSynthB ~= nil then self.sampleSynthB:stop() end
		self.outSocket:unplug() 
	end
end


--Attack is in seconds
function SampleSynthComponent:setAttack(value)
	self.attack = map(value, 0.0, 1.0, 0.0, 1.0)
	if self.sampleSynthA ~= nil then self.sampleSynthA:setAttack(self.attack) end
	if self.sampleSynthB ~= nil then self.sampleSynthB:setAttack(self.attack) end
end

--Decay is in seconds, but 1 seconds max is fine so:
function SampleSynthComponent:setDecay(value)
	self.decay = map(value, 0.0, 1.0, 0.0, 0.75)
	if self.sampleSynthA ~= nil then self.sampleSynthA:setDecay(self.decay) end
	if self.sampleSynthB ~= nil then self.sampleSynthB:setDecay(self.decay) end
end

function SampleSynthComponent:setSustain(value)
	self.sustain = value
	if self.sampleSynthA ~= nil then self.sampleSynthA:setSustain(self.sustain) end
	if self.sampleSynthB ~= nil then self.sampleSynthB:setSustain(self.sustain) end
end

function SampleSynthComponent:setRelease(value)
	self.release = map(value, 0.0, 1.0, 0.0, 2.0)
	if self.sampleSynthA ~= nil then self.sampleSynthA:setRelease(self.release) end
	if self.sampleSynthB ~= nil then self.sampleSynthB:setRelease(self.release) end
end

function SampleSynthComponent:setEnvelopeCurve(value)
	self.curve = value
	if self.sampleSynthA ~= nil then self.sampleSynthA:setEnvelopeCurvature(self.curve) end
	if self.sampleSynthB ~= nil then self.sampleSynthB:setEnvelopeCurvature(self.curve) end
end

function SampleSynthComponent:setNoteInCable(cable) self.noteInSocket:setCable(cable) end
function SampleSynthComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function SampleSynthComponent:unplugNoteIn() self.noteInSocket:unplug() end
function SampleSynthComponent:unplugOut() self.outSocket:unplug() end
function SampleSynthComponent:noteInConnected() return self.noteInSocket:connected() end
function SampleSynthComponent:outConnected() return self.outSocket:connected() end