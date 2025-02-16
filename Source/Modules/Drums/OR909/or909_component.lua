--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'Coracle/tables'

class('OR909Component').extends()

local snd <const> = playdate.sound

local volumes = {1.0, 0.8, 0.6, 0.4}

local blank16 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

function OR909Component:init(onChannel)
	OR909Component.super.init(self)
	
	self.expiring = false
	
	self.channel = snd.channel.new()
	self.channel:setVolume(gDefaultVolume)
	
	self.BD = snd.sampleplayer.new("Samples/909-BD")
	self.channel:addSource(self.BD)
	
	self.SD = snd.sampleplayer.new("Samples/909-SD")
	self.channel:addSource(self.SD)
	
	self.RC = snd.sampleplayer.new("Samples/909-RC")
	self.channel:addSource(self.RC)
		
	self.RS = snd.sampleplayer.new("Samples/909-RS")
	self.channel:addSource(self.RS)
	
	self.CY = snd.sampleplayer.new("Samples/909-CY")
	self.channel:addSource(self.CY)
	
	self.OH = snd.sampleplayer.new("Samples/909-OH")
	self.channel:addSource(self.OH)
	
	self.CH = snd.sampleplayer.new("Samples/909-CH")
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

function OR909Component:removeSources()	
	self.BD:stop()
	self.channel:removeSource(self.BD)
	
	self.SD:stop()
	self.channel:removeSource(self.SD)
	
	self.RC:stop()
	self.channel:removeSource(self.RC)
		
	self.RS:stop()
	self.channel:removeSource(self.RS)
	
	self.CY:stop()
	self.channel:removeSource(self.CY)
	
	self.OH:stop()
	self.channel:removeSource(self.OH)
	
	self.CH:stop()
	self.channel:removeSource(self.CH)
	
	self.channel:remove()
end

function OR909Component:getPatternLength(drumIndex)
	local patternLength = self.stepLengths[drumIndex]
	print("returning pattern length: " .. patternLength)
	return patternLength
end

function OR909Component:setPatternLength(drumIndex, stepLength)
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

function OR909Component:playStep()
	for i=1,7 do
		local v = self.patterns[i][self.steps[i]]
		if v > 0 then
			self:playDrum(i, v)
		end
	end
end

function OR909Component:playDrum(drumIndex, volume)
	if drumIndex == 1 then
		self.BD:setVolume(volumes[volume])
		self.BD:play()
	elseif drumIndex == 2 then
		self.SD:setVolume(volumes[volume])
		self.SD:play()
	elseif drumIndex == 3 then
		self.RC:setVolume(volumes[volume])
		self.RC:play()
	elseif drumIndex == 4 then
		self.RS:setVolume(volumes[volume])
		self.RS:play()	
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

function OR909Component:getPattern(patternIndex)
	return self.patterns[patternIndex]
end

function OR909Component:setPattern(patternIndex, pattern)
	self.patterns[patternIndex] = pattern
end

function OR909Component:stopAll() self.expiring = true end
function OR909Component:setInCable(cable) self.inSocket:setCable(cable) end
function OR909Component:setOutCable(cable) self.outSocket:setCable(cable) end
function OR909Component:unplugIn() self.inSocket:setCable(nil) end
function OR909Component:unplugOut() self.outSocket:setCable(nil) end
function OR909Component:inConnected() return self.inSocket:connected() end
function OR909Component:outConnected() return self.outSocket:connected() end