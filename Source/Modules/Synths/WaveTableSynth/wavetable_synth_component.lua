--[[
	© 2023 Orllewin - All Rights Reserved.
]]
class('WavetableSynthComponent').extends()

local sound <const> = playdate.sound

function WavetableSynthComponent:init(id, listener, paramXListener, onChannel)
	WavetableSynthComponent.super.init(self)
	
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
	
	self.inSocket = Socket("synth_module", socket_receive, function(event) 
		if self.expiring == true then return end 	
		
		if event:getValue() < 0 then 
			self.synth:noteOff()
		else
			self.synth:playMIDINote(math.floor(event:getValue()))
		end
			
		if self.listener ~= nil then
			self.listener(event)
		end
	end)
	
	self.paramXInSocket = Socket("synth_module_paramX_in", socket_receive, function(event) 
		self.paramX = event:getValue()
		if self.paramXListener ~= nil then
			self.paramXListener(event)
			self:setXMorph(event:getValue())
		end
	end)
	
	if onChannel ~= nil then onChannel(self.channel) end
	
	self.outSocket = Socket("synth_module", socket_send)
end

function WavetableSynthComponent:stopAll()
	self.expiring = true
	self.synth:noteOff()
	self.channel:remove()
end

function WavetableSynthComponent:setXMorph(value)
	self.paramX = value
	self.synth:setParameter(2, self.paramX)
end

function WavetableSynthComponent:setWavetable(path)
	print("WavetableSynthComponent:setWavetable(): " .. path)
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
function WavetableSynthComponent:setAttack(value)
	self.attack = map(value, 0.0, 1.0, 0.0, 0.5)
	self.synth:setAttack(self.attack)
end

--Decay is in seconds, but 1 seconds max is fine so:
function WavetableSynthComponent:setDecay(value)
	self.decay = map(value, 0.0, 1.0, 0.0, 0.5)
	self.synth:setDecay(self.decay)
end

function WavetableSynthComponent:setSustain(value)
	self.sustain = value
	self.synth:setSustain(self.sustain)
end

function WavetableSynthComponent:setRelease(value)
	self.release = map(value, 0.0, 1.0, 0.0, 1.0)
	self.synth:setRelease(self.release)
end

--Attack is in seconds
function WavetableSynthComponent:setEnvelopeCurve(value)
	self.curve = value
	self.synth:setEnvelopeCurvature(self.curve)
end

function WavetableSynthComponent:setParamXInCable(cable) self.paramXInSocket:setCable(cable) end
function WavetableSynthComponent:setInCable(cable) self.inSocket:setCable(cable) end
function WavetableSynthComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function WavetableSynthComponent:unplugIn() self.inSocket:unplug() end
function WavetableSynthComponent:unplugOut() self.outSocket:unplug() end
function WavetableSynthComponent:unplugParamX() 
	print("WavetableSynthComponent:unplugParamX() ")
	self.paramXInSocket:unplug() 
end
function WavetableSynthComponent:inConnected() return self.inSocket:connected() end
function WavetableSynthComponent:outConnected() return self.outSocket:connected() end
function WavetableSynthComponent:paramXConnected() return self.paramXInSocket:connected() end