--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('WavetableHzComponent').extends()

local sound <const> = playdate.sound

function WavetableHzComponent:init(id, listener, paramXListener, onChannel)
	WavetableHzComponent.super.init(self)
	
	self.expiring = false
	
	self.id = id
	self.listener = listener
	self.paramXListener = paramXListener
	
	self.attack = 0.1
	self.decay = 0.1
	self.sustain = 0.8
	self.release = 1.0
	self.curve = 0.5
	
	self.synth = sound.synth.new()
	local sample = sound.sample.new("Wavetables/FAIRLIGHT1")
	self.synth:setWavetable(sample, 256)
	self.synth:setVolume(1)
	
	self.channel = playdate.sound.channel.new()
	self.channel:addSource(self.synth)
	self.channel:setVolume(gDefaultVolume)
	self.synth:setADSR(self.attack, self.decay, self.sustain, self.release)
	self.synth:setEnvelopeCurvature(self.curve)
	
	self.paramX = 0
	
	self.paramXInSocket = Socket("wavetable_hz_x_morph_in", socket_receive, function(event) 
		self.paramX = event:getValue()
		if self.paramXListener ~= nil then
			self.paramXListener(event)
			self:setXMorph(event:getValue())
		end
	end)
	
	if onChannel ~= nil then onChannel(self.channel) end
	
	self.outSocket = Socket("wavetable_hz_mod_out", socket_send)
end

function WavetableHzComponent:stopAll()
	self.expiring = true
	self.synth:noteOff()
end

function WavetableHzComponent:setNormalisedHz(value)
	self.synth:playNote(map(value, 0.0, 1.0, 1.0, 600.0))
end

function WavetableHzComponent:setXMorph(value)
	self.paramX = value
	self.synth:setParameter(2, self.paramX)
end

function WavetableHzComponent:setWavetable(path)
	print("WavetableHzComponent:setWavetable(): " .. path)
	local sample = sound.sample.new(path)
	
	if string.find(path, "256") then
		self.synth:setWavetable(sample, 512, 32)
	else
		self.synth:setWavetable(sample, 256, 8)
	end
	
	self.synth:setADSR(self.attack, self.decay, self.sustain, self.release)
	self.synth:setEnvelopeCurvature(self.curve)
	self.synth:setParameter(2, self.paramX)
end

--Attack is in seconds
function WavetableHzComponent:setAttack(value)
	self.attack = map(value, 0.0, 1.0, 0.0, 0.5)
	self.synth:setAttack(self.attack)
end

--Decay is in seconds, but 1 seconds max is fine so:
function WavetableHzComponent:setDecay(value)
	self.decay = map(value, 0.0, 1.0, 0.0, 0.5)
	self.synth:setDecay(self.decay)
end

function WavetableHzComponent:setSustain(value)
	self.sustain = value
	self.synth:setSustain(self.sustain)
end

function WavetableHzComponent:setRelease(value)
	self.release = map(value, 0.0, 1.0, 0.0, 1.0)
	self.synth:setRelease(self.release)
end

--Attack is in seconds
function WavetableHzComponent:setEnvelopeCurve(value)
	self.curve = value
	self.synth:setEnvelopeCurvature(self.curve)
end

function WavetableHzComponent:setParamXInCable(cable) self.paramXInSocket:setCable(cable) end
function WavetableHzComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function WavetableHzComponent:unplugOut() self.outSocket:unplug() end
function WavetableHzComponent:unplugParamX() self.paramXInSocket:unplug() end
function WavetableHzComponent:outConnected() return self.outSocket:connected() end
function WavetableHzComponent:paramXConnected() return self.paramXInSocket:connected() end