--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'Coracle/tables'

class('OR808Component').extends()

local snd <const> = playdate.sound

local volumes = {1.0, 0.8, 0.6, 0.4}

local blank16 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

function OR808Component:init(onChannel)
	OR808Component.super.init(self)
	
	self.expiring = false
	
	self.channel = snd.channel.new()
	self.channel:setVolume(gDefaultVolume)
	
	self.bdDecay = 0.0
	
	self.BD = snd.sampleplayer.new("Samples/808-BD")
	self.BD:setVolume(1)
	self.channel:addSource(self.BD)
	
	self.BS = snd.sampleplayer.new("Samples/808-BS")
	self.BS:setVolume(0)
	self.channel:addSource(self.BS)
	
	self.SD = snd.sampleplayer.new("Samples/808-SD")
	self.channel:addSource(self.SD)
	
	self.LT = snd.sampleplayer.new("Samples/808-LT")
	self.channel:addSource(self.LT)
	
	self.MT = snd.sampleplayer.new("Samples/808-MT")
	self.channel:addSource(self.MT)
		
	self.HT = snd.sampleplayer.new("Samples/808-HT")
	self.channel:addSource(self.HT)
	
	self.RS = snd.sampleplayer.new("Samples/808-RS")
	self.channel:addSource(self.RS)
	
	self.CP = snd.sampleplayer.new("Samples/808-CP")
	self.channel:addSource(self.CP)
	
	self.CB = snd.sampleplayer.new("Samples/808-CB")
	self.channel:addSource(self.CB)
	
	self.CY = snd.sampleplayer.new("Samples/808-CY")
	self.channel:addSource(self.CY)
	
	self.OH = snd.sampleplayer.new("Samples/808-OH")
	self.channel:addSource(self.OH)
	
	self.CH = snd.sampleplayer.new("Samples/808-CH")
	self.channel:addSource(self.CH)
	
	onChannel(self.channel)
	
	self.onStep = onStep
	
	self.patterns = {
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	}
	
	self.stepLengths = {
		16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16
	}
	
	self.steps = {
		1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	}
	
	self.step = 1

	self.outSocket = Socket("drum_component_out", socket_send)

	self.inSocket = Socket("sequence_component_in", socket_receive, function(event) 		
		-- main step counter
		self.step += 1
		if self.step == 17 then
			self.step = 1
		end
		
		if self.step ~= event.value then
			self.step = event.value
		end
		
		--individual samples:
		for i=1, 11 do
			self.steps[i] += 1
			if self.steps[i] > self.stepLengths[i] then
				self.steps[i] = 1
			end
		end
		
		if self.onStep ~= nil then self.onStep(self.step) end
		
		self:playStep()
		
		
	end)
end

function OR808Component:removeSources()		
	self.BD:stop()
	self.channel:removeSource(self.BD)
	
	self.BS:stop()
	self.channel:removeSource(self.BS)
	
	self.SD:stop()
	self.channel:removeSource(self.SD)
	
	self.LT:stop()
	self.channel:removeSource(self.LT)
	
	self.MT:stop()
	self.channel:removeSource(self.MT)
		
	self.HT:stop()
	self.channel:removeSource(self.HT)
	
	self.RS:stop()
	self.channel:removeSource(self.RS)
	
	self.CP:stop()
	self.channel:removeSource(self.CP)
	
	self.CB:stop()
	self.channel:removeSource(self.CB)
	
	self.CY:stop()
	self.channel:removeSource(self.CY)
	
	self.OH:stop()
	self.channel:removeSource(self.OH)
	
	self.CH:stop()
	self.channel:removeSource(self.CH)
	
	self.channel:remove()
end


function OR808Component:setBassDrumDecay(value)
	self.bdDecay = value
end

function OR808Component:getPatternLength(drumIndex)
	local patternLength = self.stepLengths[drumIndex]
	print("returning pattern length: " .. patternLength)
	return patternLength
end

function OR808Component:setPatternLength(drumIndex, stepLength)
	if self.stepLengths[drumIndex] == stepLength then
		print("Drum " .. drumIndex .. " already set to " .. stepLength .. " steps")
		return
	end

	if #self.patterns[drumIndex] < stepLength then
		tableConcat(self.patterns[drumIndex], blank16)
	end
	
	--keep patterns in sync:
	self.steps[drumIndex] = self.step
	self.stepLengths[drumIndex] = stepLength
end

function OR808Component:playStep()
	for i=1,11 do
		local v = self.patterns[i][self.steps[i]]
		if v > 0 then
			self:playDrum(i, v)
		end
	end
end

function OR808Component:playDrum(drumIndex, volume)
	if drumIndex == 1 then
		local adjusted = map(self.bdDecay, 0.0, 1.0, 0.0, volumes[volume])
		local bdVolume = volumes[volume] - adjusted
		self.BD:setVolume(bdVolume)
		self.BS:setVolume(adjusted)
		self.BD:play()
		self.BS:play()
	elseif drumIndex == 2 then
		self.SD:setVolume(volumes[volume])
		self.SD:play()
	elseif drumIndex == 3 then
		self.LT:setVolume(volumes[volume])
		self.LT:play()
	elseif drumIndex == 4 then
		self.MT:setVolume(volumes[volume])
		self.MT:play()	
	elseif drumIndex == 5 then
		self.HT:setVolume(volumes[volume])
		self.HT:play()	
	elseif drumIndex == 6 then
		self.RS:setVolume(volumes[volume])
		self.RS:play()			
	elseif drumIndex == 7 then
		self.CP:setVolume(volumes[volume])
		self.CP:play()				
	elseif drumIndex == 8 then
		self.CB:setVolume(volumes[volume])
		self.CB:play()			
	elseif drumIndex == 9 then
		self.CY:setVolume(volumes[volume])
		self.CY:play()		
	elseif drumIndex == 10 then
		self.OH:setVolume(volumes[volume])
		self.OH:play()		
	elseif drumIndex == 11 then
		self.CH:setVolume(volumes[volume])
		self.CH:play()	
	end
end

function OR808Component:getPattern(patternIndex)
	return self.patterns[patternIndex]
end

function OR808Component:setPattern(patternIndex, pattern)
	self.patterns[patternIndex] = pattern
end

function OR808Component:stopAll() self.expiring = true end
function OR808Component:setInCable(cable) self.inSocket:setCable(cable) end
function OR808Component:setOutCable(cable) self.outSocket:setCable(cable) end
function OR808Component:unplugIn() self.inSocket:setCable(nil) end
function OR808Component:unplugOut() self.outSocket:setCable(nil) end
function OR808Component:inConnected() return self.inSocket:connected() end
function OR808Component:outConnected() return self.outSocket:connected() end