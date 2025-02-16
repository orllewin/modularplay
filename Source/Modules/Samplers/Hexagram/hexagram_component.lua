--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('HexagramComponent').extends()

local maxActiveCount = 8
local minActiveCount = 1

local pitchModeLow = -1
local pitchModeMid = 0
local pitchModeHigh = 1

local hiRates = {1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0}
local midRates = {1.0, 0.5, 0.5, 0.5, 0.5, 1.0, 1.0}
local loRates = {0.5, 0.5, 0.5, 1.0, 0.5, 0.5, 0.5}

function HexagramComponent:init(onChannel)
	HexagramComponent.super.init(self)
	
	print("HEXAGRAM COMPONENT init()")
	
	self.channel = playdate.sound.channel.new()
	
	self.channel:setVolume(gDefaultVolume)
	
	self.activeCount = 4
	
	self.frame = 1
	
	self.pitchMode = pitchModeMid
	self.reverseProbability = 0.5
	self.playbackFrequency = 0.5
	
	self.samples = {}
	for i=1,maxActiveCount do 
		local sample = playdate.sound.sample.new("Samples/silence")
		local orlSample = OrlSample(sample)
		self.channel:addSource(orlSample:getPlayer())
		local delayedSample = {
			orlSample = orlSample,
			triggerFrame = math.floor(math.random(10, 100))
		}
		table.insert(self.samples, delayedSample)
	end
	
	onChannel(self.channel)
	
	self.timer = playdate.timer.new(500, function() 
		self.frame += 1
		for i=1,self.activeCount do
			if self.samples[i].orlSample:isPlaying() then
				self.samples[i].triggerFrame = self.frame + self:randomFutureFrame()
			end
			if self.frame == self.samples[i].triggerFrame then
				self:updateOrlSampleParams(i)
				self.samples[i].orlSample:play()
			end
		end
	end)
	self.timer.repeats = true

	self.outSocket = Socket("hexagram_mod_out", socket_send)
end

function HexagramComponent:stopAll()
	self.timer:remove()
	for i=1,maxActiveCount do
		if self.samples[i].orlSample ~= nil then
			self.samples[i].orlSample:stopAndFree()
		end
	end
end

function HexagramComponent:randomFutureFrame()
	local normalisedFuture = (1.0 - self.playbackFrequency)
	local futureFrames = math.max(8, math.floor((normalisedFuture * 10) * math.random(50)))
	--print("HexagramComponent:randomFutureFrame(): "  .. normalisedFuture .. " futureframes:" .. futureFrames)
	return futureFrames
end

function HexagramComponent:setPitchMode(value)
	self.pitchMode = math.floor(map(value, 0.0, 1.0, -1, 1))
end

function HexagramComponent:setReverseProbability(value)
	self.reverseProbability = value
end

function HexagramComponent:setPlaybackFrequency(value)
	self.playbackFrequency = value
end

function HexagramComponent:setCount(value)
	self.activeCount = math.floor(map(value, 0.0, 1.0, minActiveCount, maxActiveCount))
end

function HexagramComponent:getRate()
	if self.pitchMode == pitchModeMid then
		return midRates[math.floor(math.random(1,#midRates))]
	elseif self.pitchMode == pitchModeLow then
		return loRates[math.floor(math.random(1,#midRates))]
	elseif self.pitchMode == pitchModeHigh then
		return hiRates[math.floor(math.random(1,#midRates))]
	end
end

function HexagramComponent:updateOrlSampleParams(index)
	
		self.samples[index].orlSample:getRandomBuffer()
		
		local rate =  self:getRate()
		if math.random() < self.reverseProbability then
			rate = rate * -1
		end
		
		self.samples[index].orlSample:setRate(rate)
end

function HexagramComponent:setChannel(channel)
	self.channel = channel
	channel:addEffect(self.filter)
	channel:addSource(self.tap)
end

function HexagramComponent:removeChannel(channel)
	channel:removeEffect(self.filter)
	channel:removeSource(self.tap)
end

function HexagramComponent:outConnected()
	return self.outSocket:connected()
end

function HexagramComponent:unplug(cableId)
	if self:outConnected() and "" .. cableId == "" .. self.outSocket:getCableId() then
		self.outSocket:unplug()
	end
end

function HexagramComponent:unplugOut()
	self.outSocket:unplug()
end

function HexagramComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end