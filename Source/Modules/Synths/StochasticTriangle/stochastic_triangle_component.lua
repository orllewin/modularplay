--[[

]]--
import 'midi'

class('StochasticTriangleComponent').extends()

local mode1_1 = 1
local mode1_2 = 2
local mode1_4 = 3
local mode1_8 = 4
local mode1_16 = 5
local mode1_32 = 6
local mode1_64 = 7

function StochasticTriangleComponent:init(onChannel)
	StochasticTriangleComponent.super.init(self)
	
	self.expiring = false
	
	self.midi = Midi()	
	
	--clock delay
	self.bpm = -1
	self.divisionChoice = 5
	self.probability = 20
	self.delayMS = 250
	self.didDelay = false
	
	self.expiring = false
	
	--blackhole
	self.gravity = 0.85
	self.notes = self.midi:getNotes2(60, "Major")
	
	self.normalisedMin = 0.175
	self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, #self.notes))
	
	self.normalisedMax = 0.4
	self.maxNoteIndex = math.floor(map(0.4, 0.0, 1.0, 1, #self.notes))
	
	self.synth = playdate.sound.synth.new(playdate.sound.kWaveTriangle)
	self.synth:setVolume(0.5)
	self.synth:setAttack(0.8)
	self.synth:setDecay(0.1)
	self.synth:setSustain(0.75)
	self.synth:setRelease(1.1)
	self.synth:setEnvelopeCurvature(1.0)
	self.synthChannel = playdate.sound.channel.new()
	self.synthChannel:addSource(self.synth)
	self.synthChannel:setVolume(gDefaultVolume)
	
	local maxSeconds = 2.0
	self.filter = playdate.sound.delayline.new(maxSeconds)
	self.filter:setFeedback(0.5)
	self.tap = self.filter:addTap(0.5)
	self.synthChannel:addEffect(self.filter)
	
	
	if onChannel ~= nil then onChannel(self.synthChannel) end

	self.inSocket = Socket("stochastic_tri_module", socket_receive, function(event) 
		--self.synth:playMIDINote(math.floor(event:getValue()))
		if self.expiring then return end
		self:maybeDelay(event)
	end)
		
	self.outSocket = Socket("synth_module", socket_send)
end

function StochasticTriangleComponent:stopAll()
	self.expiring = true
	self.synth:noteOff()
	self.synthChannel:remove()
end

function StochasticTriangleComponent:pitchUp()
	self.normalisedMin = math.min(0.75, self.normalisedMin + 0.1)
	self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, #self.notes))
	
	self.normalisedMax = math.min(1.0, self.normalisedMax + 0.1)
	self.maxNoteIndex = math.floor(map(self.normalisedMax, 0.0, 1.0, 1, #self.notes))
end

function StochasticTriangleComponent:pitchDown()
	self.normalisedMin = math.max(0.01, self.normalisedMin -  0.1)
	self.minNoteIndex = math.floor(map(self.normalisedMin, 0.0, 1.0, 1, #self.notes))
	
	self.normalisedMax = math.max(0.2, self.normalisedMax -  0.1)
	self.maxNoteIndex = math.floor(map(self.normalisedMax, 0.0, 1.0, 1, #self.notes))
end

function StochasticTriangleComponent:maybeDelay(event)
	if event ~= nil then
		if self.didDelay then
			self.didDelay = false
			return
		end
		if event:getValue() ~= self.bpm then
			--update delayMS
			self.bpm = event:getValue()
			self:calculateMS()
		end
		if math.random(100) < self.probability then
			self.didDelay = true
			playdate.timer.performAfterDelay(self.delayMS, function() 
				self:maybeBlackhole(event)
			end)
		else
			self:maybeBlackhole(event)
		end
	end
end

function StochasticTriangleComponent:maybeBlackhole(event)
	if math.random() > self.gravity then
		self:emitMidi()
	end
end

function StochasticTriangleComponent:emitMidi()
	local midiNote = self.notes[math.floor(map(math.random(), 0.0, 1.0, self.minNoteIndex, self.maxNoteIndex))]
	self.synth:playMIDINote(midiNote)
	
	if math.random() < 0.05 then
		self.divisionChoice = math.floor(math.random(), 0.0, 1.0, 1, 7)
		self:calculateMS()
	end
end

function StochasticTriangleComponent:calculateMS()
	
	local bpm = self.bpm
	local bpmMs = (60000/bpm)
	
	if self.divisionChoice == mode1_1 then
		self.delayMS = bpmMs
	elseif self.divisionChoice == mode1_2 then
		self.delayMS = bpmMs/2
	elseif self.divisionChoice == mode1_4 then
		self.delayMS = bpmMs/4
	elseif self.divisionChoice == mode1_8 then
		self.delayMS = bpmMs/8
	elseif self.divisionChoice == mode1_16 then 
		self.delayMS = bpmMs/16
	elseif self.divisionChoice == mode1_32 then 
		self.delayMS = bpmMs/32
	elseif self.divisionChoice == mode1_64 then	
		self.delayMS = bpmMs/64
	else
		self.delayMS = 1
	end	
end

function StochasticTriangleComponent:setVolume(value)
	self.synth:setVolume(value)
end

function StochasticTriangleComponent:getVolume()
	return self.synth:getVolume()
end

function StochasticTriangleComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function StochasticTriangleComponent:setOutCable(cable)
	--todo - link to a channel in a speaker module?
	self.outSocket:setCable(cable)
end

function StochasticTriangleComponent:unplug(cableId)
	if self:inConnected() and "" .. self.inSocket:getCableId() == "" .. cableId then
	self.inSocket:unplug()
	end
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then
	self.outSocket:unplug()
	end
end

function StochasticTriangleComponent:unplugIn()
	self.inSocket:setCable(nil)
end

function StochasticTriangleComponent:unplugOut()
	self.outSocket:setCable(nil)
end

function StochasticTriangleComponent:inConnected()
	return self.inSocket:connected()
end

function StochasticTriangleComponent:outConnected()
	return self.outSocket:connected()
end