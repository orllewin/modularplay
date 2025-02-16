--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('MicroSynthComponent').extends()

function MicroSynthComponent:init(onChannel)
	MicroSynthComponent.super.init(self)
	
	self.expiring = false
	
	self.waveformChoice = 1
	
	self.synth = playdate.sound.synth.new(playdate.sound.kWaveSine)
	self.synth:setVolume(0.5)
	
	self.channel = playdate.sound.channel.new()
	self.channel:addSource(self.synth)
	self.channel:setVolume(gDefaultVolume)
	if onChannel ~= nil then onChannel(self.channel) end

	self.inSocket = Socket("synth_module", socket_receive, function(event) 
		if self.expiring == true then return end 
		if event:getValue() > 0 then
			self.synth:playMIDINote(math.floor(event:getValue()))
		else
			self.synth:noteOff()
		end
	end)
		
	self.outSocket = Socket("synth_module", socket_send)
end

function MicroSynthComponent:stopAll()
	self.expiring = true
	self.synth:noteOff()
	self.channel:remove()
end

function MicroSynthComponent:setWaveform(index)
	self.waveformTypeIndex = index
	if index == 1 then
		self.synth:setWaveform(playdate.sound.kWaveSine)
	elseif index == 2 then
		self.synth:setWaveform(playdate.sound.kWaveSquare)
	elseif index == 3 then
		self.synth:setWaveform(playdate.sound.kWaveSawtooth)
	elseif index == 4 then
		self.synth:setWaveform(playdate.sound.kWaveTriangle)
	elseif index == 5 then
		self.synth:setWaveform(playdate.sound.kWavePOPhase)
	elseif index == 6 then
		self.synth:setWaveform(playdate.sound.kWavePODigital)
	elseif index == 7 then
		self.synth:setWaveform(playdate.sound.kWavePOVosim)
	end
end

function MicroSynthComponent:setVolume(value)
	self.synth:setVolume(value)
end

function MicroSynthComponent:getVolume()
	return self.synth:getVolume()
end

function MicroSynthComponent:unplug(cableId)
	if self:inConnected() and "" .. self.inSocket:getCableId() == "" .. cableId then self.inSocket:unplug() end
	
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then
			--todo remove all fx... - needs global list of channel <> fx?
			self.synth:stop()
			self.outSocket:unplug()
	end
end

function MicroSynthComponent:getWaveformTypeIndex() return self.waveformTypeIndex end
function MicroSynthComponent:setInCable(cable) self.inSocket:setCable(cable) end
function MicroSynthComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function MicroSynthComponent:unplugIn() self.inSocket:unplug() end
function MicroSynthComponent:unplugOut() self.outSocket:unplug() end
function MicroSynthComponent:inConnected() return self.inSocket:connected() end
function MicroSynthComponent:outConnected() return self.outSocket:connected() end