--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'Coracle/string_utils'

class('WavetableSynth2DComponent').extends()

local sound <const> = playdate.sound

function WavetableSynth2DComponent:init(id, listener, paramXListener, paramYListener, onChannel)
	WavetableSynth2DComponent.super.init(self)
	
	self.expiring = false
	
	self.id = id
	self.listener = listener
	self.paramXListener = paramXListener
	self.paramYListener = paramYListener
	
	self.attack = 0.1
	self.decay = 0.1
	self.sustain = 0.8
	self.release = 1.0
	self.curve = 0.5
	
	self.synth = sound.synth.new()
	local sample = sound.sample.new("Wavetables/FAIRLIGHT1")
	self.synth:setWavetable(sample, 256, 8)
	self.synth:setVolume(1)
	
	self.channel = playdate.sound.channel.new()
	self.channel:addSource(self.synth)
	self.channel:setVolume(gDefaultVolume)
	self.synth:setADSR(self.attack, self.decay, self.sustain, self.release)
	self.synth:setEnvelopeCurvature(self.curve)
	
	self.paramX = 0
	self.paramY = 0
	
	self.inSocket = Socket("synth_module", socket_receive, function(event) 
		if self.expiring == true then return end 	
		if event:getValue() < 0 then 
			self.synth:noteOff()
		else
			--note volume length
			self.synth:playMIDINote(math.floor(event:getValue()), 1)
		end
			
		if self.listener ~= nil then
			self.listener(event)
		end
	end)
	
	self.paramXInSocket = Socket("synth_module_paramX_in", socket_receive, function(event) 
		if self.expiring == true then return end 
		self.paramX = event:getValue()
		if self.paramXListener ~= nil then
			self.paramXListener(event)
			self:setXMorph(event:getValue())
		end
	end)
	
	self.paramYInSocket = Socket("synth_module_paramY_in", socket_receive, function(event) 
		if self.expiring == true then return end 
		self.paramY = event:getValue()
		if self.paramYListener ~= nil then
			self.paramYListener(event)
			self:setYMorph(event:getValue())
		end
	end)
	
	if onChannel ~= nil then onChannel(self.channel) end
	
	self.outSocket = Socket("synth_module", socket_send)

end

function WavetableSynth2DComponent:stopAll()
	self.expiring = true
	self.synth:noteOff()
	self.channel:remove()
end

function WavetableSynth2DComponent:setXMorph(value)
	self.paramX = value
	self.synth:setParameter(2, self.paramX)
end

function WavetableSynth2DComponent:setYMorph(value)
	self.paramY = value
	self.synth:setParameter(4, self.paramY)
end

function WavetableSynth2DComponent:setWavetable(path)
	print("WavetableSynth2DComponent:setWavetable(): " .. path)
	local sample = sound.sample.new(path)
	
	if string.find(path, "256") then
		self.synth:setWavetable(sample, 512, 32)
	else
		self.synth:setWavetable(sample, 256, 8)
	end
	
	self.synth:setADSR(self.attack, self.decay, self.sustain, self.release)
	self.synth:setEnvelopeCurvature(self.curve)
	self.synth:setParameter(2, self.paramX)
	self.synth:setParameter(4, self.paramY)
end

--Attack is in seconds
function WavetableSynth2DComponent:setAttack(value)
	self.attack = map(value, 0.0, 1.0, 0.0, 0.5)
	self.synth:setAttack(self.attack)
end

--Decay is in seconds
function WavetableSynth2DComponent:setDecay(value)
	self.decay = map(value, 0.0, 1.0, 0.0, 0.5)
	self.synth:setDecay(self.decay)
end

function WavetableSynth2DComponent:setSustain(value)
	self.sustain = value
	self.synth:setSustain(self.sustain)
end

function WavetableSynth2DComponent:setRelease(value)
	self.release = map(value, 0.0, 1.0, 0.0, 1.0)
	self.synth:setRelease(self.release)
end


function WavetableSynth2DComponent:setEnvelopeCurve(value)
	self.curve = value
	self.synth:setEnvelopeCurvature(self.curve)
end

function WavetableSynth2DComponent:setParamXInCable(cable) self.paramXInSocket:setCable(cable) end
function WavetableSynth2DComponent:setParamYInCable(cable) self.paramYInSocket:setCable(cable) end
function WavetableSynth2DComponent:setInCable(cable) self.inSocket:setCable(cable) end
function WavetableSynth2DComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function WavetableSynth2DComponent:unplugIn() self.inSocket:unplug() end
function WavetableSynth2DComponent:unplugOut() self.outSocket:unplug() end
function WavetableSynth2DComponent:unplugParamX() self.paramXInSocket:unplug() end
function WavetableSynth2DComponent:unplugParamY() self.paramYInSocket:unplug() end
function WavetableSynth2DComponent:inConnected() return self.inSocket:connected() end
function WavetableSynth2DComponent:outConnected() return self.outSocket:connected() end
function WavetableSynth2DComponent:paramXConnected() return self.paramXInSocket:connected() end
function WavetableSynth2DComponent:paramYConnected() return self.paramYInSocket:connected() end