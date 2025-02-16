--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'Coracle/tables'

class('OR606Component').extends()

local snd <const> = playdate.sound

local volumes = {1.0, 0.8, 0.6, 0.4}

local blank16 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

function OR606Component:init(onChannel)
	OR606Component.super.init(self)
	
	self.expiring = false
	
	self.channel = snd.channel.new()
	self.channel:setVolume(gDefaultVolume)
	
	self.BD = snd.sampleplayer.new("Samples/606-BD")
	self.channel:addSource(self.BD)
	
	self.SD = snd.sampleplayer.new("Samples/606-SD")
	self.channel:addSource(self.SD)
	
	self.LT = snd.sampleplayer.new("Samples/606-LT")
	self.channel:addSource(self.LT)
		
	self.HT = snd.sampleplayer.new("Samples/606-HT")
	self.channel:addSource(self.HT)
	
	self.CY = snd.sampleplayer.new("Samples/606-CY")
	self.channel:addSource(self.CY)
	
	self.OH = snd.sampleplayer.new("Samples/606-OH")
	self.channel:addSource(self.OH)
	
	self.CH = snd.sampleplayer.new("Samples/606-CH")
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
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	}
	
	self.stepLengths = {
		16, 16, 16, 16, 16, 16, 16
	}
	
	self.steps = {
		1, 1, 1, 1, 1, 1, 1
	}
	
	self.step = 1

	self.outSocket = Socket("drum_component_out", socket_send)

	self.inSocket = Socket("sequence_component_in", socket_receive, function(event)
		if self.expiring == true then return end 		
		-- main step counter
		self.step += 1
		if self.step == 17 then
			self.step = 1
		end
		
		if self.step ~= event.value then
			self.step = event.value
		end
		
		--individual samples:
		for i=1, 7 do
			self.steps[i] += 1
			if self.steps[i] > self.stepLengths[i] then
				self.steps[i] = 1
			end
		end
		
		if self.onStep ~= nil then self.onStep(self.step) end
		
		self:playStep()
	end)
end

function OR606Component:removeSources()	
	self.BD:stop()
	self.channel:removeSource(self.BD)
	
	self.SD:stop()
	self.channel:removeSource(self.SD)
	
	self.LT:stop()
	self.channel:removeSource(self.LT)
		
	self.HT:stop()
	self.channel:removeSource(self.HT)
	
	self.CY:stop()
	self.channel:removeSource(self.CY)
	
	self.OH:stop()
	self.channel:removeSource(self.OH)
	
	self.CH:stop()
	self.channel:removeSource(self.CH)
	
	self.channel:remove()
end

function OR606Component:getPatternLength(drumIndex)
	local patternLength = self.stepLengths[drumIndex]
	print("returning pattern length: " .. patternLength)
	return patternLength
end

function OR606Component:setPatternLength(drumIndex, stepLength)
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

function OR606Component:playStep()
	for i=1,7 do
		local v = self.patterns[i][self.steps[i]]
		if v > 0 then
			self:playDrum(i, v)
		end
	end
end

function OR606Component:playDrum(drumIndex, volume)
	if drumIndex == 1 then
		self.BD:setVolume(volumes[volume])
		self.BD:play()
	elseif drumIndex == 2 then
		self.SD:setVolume(volumes[volume])
		self.SD:play()
	elseif drumIndex == 3 then
		self.LT:setVolume(volumes[volume])
		self.LT:play()
	elseif drumIndex == 4 then
		self.HT:setVolume(volumes[volume])
		self.HT:play()	
	elseif drumIndex == 5 then
		self.CY:setVolume(volumes[volume])
		self.CY:play()			
	elseif drumIndex == 6 then
		self.OH:setVolume(volumes[volume])
		self.OH:play()				
	elseif drumIndex == 7 then
		self.CH:setVolume(volumes[volume])
		self.CH:play()				
	end
end

function OR606Component:getPattern(patternIndex)
	return self.patterns[patternIndex]
end

function OR606Component:setPattern(patternIndex, pattern)
	self.patterns[patternIndex] = pattern
end

function OR606Component:stopAll() self.expiring = true end
function OR606Component:setInCable(cable) self.inSocket:setCable(cable) end
function OR606Component:setOutCable(cable) self.outSocket:setCable(cable) end
function OR606Component:unplugIn() self.inSocket:setCable(nil) end
function OR606Component:unplugOut() self.outSocket:setCable(nil) end
function OR606Component:inConnected() return self.inSocket:connected() end
function OR606Component:outConnected() return self.outSocket:connected() end