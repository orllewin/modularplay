--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('GranularComponent').extends()

local minFrames = 10
local minWidthMs = 10

function GranularComponent:init(modId, onChannel, updateListener)
	GranularComponent.super.init(self)
	
	self.modId = modId
	
	self.subsamples = {}
	
	self.octaveDown3 = true
	self.octaveDown2 = true
	self.octaveDown1 = true
	self.octaveNoChange = false
	self.octaveUp1 = false
	
	self.prevStartMs = -1
	self.prevEndMs = -1
	
	self.doSmoothing = false
	
	self.updateListener = updateListener
	self.loading = false
	self.normalisedWidth = 0.5
	self.normalisedMinPosition = 0.0
	self.normalisedMaxPosition = 1.0
	self.normalisedReverseChance = 0.5
	self.minWidthMs = minWidthMs
	self.path = "Samples/silence"
	self:load(self.path)
  self.sampleplayer = playdate.sound.sampleplayer.new(self.sample)
	
	self.waitingForLoad = true
	self.waitTimeout = 0
	
	self.channel = playdate.sound.channel.new()
	self.channel:addSource(self.sampleplayer)
	self.channel:setVolume(gDefaultVolume)
	
	if onChannel ~= nil then onChannel(self.channel) end
	
	self.connected = false

	self.outSocket = Socket("sample_player_component_out", socket_send)
	
	self.positionSocket = Socket("granular_position_in", socket_receive, function(event) 
		if self.path == "Samples/silence" or self.bangSocket:connected() then
			return
		end
		self:setSubsampleMinStart(event:getValue())
		self:setSubsampleMaxEnd(event:getValue())
	end)
	
	self.bangSocket = Socket("granular_bang_in", socket_receive, function(event) 
		if self.path == "Samples/silence" or self.positionSocket:connected() then
			return
		end
		
		if self.doSmoothing then
			if self.sampleplayer:isPlaying() then
				self.releaseTimer:reset()
				self.releaseTimer:start()
				playdate.timer.performAfterDelay(self.releaseMs, function() 
					self.sampleplayer:stop()
					self:generateSubsample()
					self:setRateAndPlay()
				end)
			else
				self:generateSubsample()
				self:setRateAndPlay()
			end
		else
			if self.sampleplayer:isPlaying() then
				self.sampleplayer:stop()
			end
			
			self:generateSubsample()
			self:setRateAndPlay()
		end		
	end)
	
	--Pseudo attack envelope timer
	self.attackTime = 250
	self.attackTimer = playdate.timer.new(self.attackTime, 0.0, 1.0)
	self.attackTimer.discardOnCompletion = false
	self.attackTimer.updateCallback = function ()
		self.sampleplayer:setVolume(self.attackTimer.value)
	end
	self.attackTimer:pause()
	
	self.releaseMs = 75
	self.releaseTimer = playdate.timer.new(self.releaseMs, 1.0, 0.0)
	self.releaseTimer.discardOnCompletion = false
	self.releaseTimer.updateCallback = function ()
		self.sampleplayer:setVolume(self.releaseTimer.value)
	end
	self.releaseTimer:pause()
end

function GranularComponent:play()
	if(self.waitTimeout < self.attackTime) then
		self.attackTimer.duration = self.waitTimeout/10
	else
		self.attackTimer.duration = self.attackTime
	end

	if self.doSmoothing then
		self.attackTimer:reset()
		self.attackTimer:start()
		self.sampleplayer:play()
	else
		self.sampleplayer:play()
	end
end

function GranularComponent:setOctaveEnabled(octaveIdentifier, enabled)
	if octaveIdentifier == -3 then
		self.octaveDown3 = enabled
	elseif octaveIdentifier == -2 then
		self.octaveDown2 = enabled
	elseif octaveIdentifier == -1 then
		self.octaveDown1 = enabled
	elseif octaveIdentifier == 1 then
		self.octaveNoChange = enabled
	elseif octaveIdentifier == 2 then
		self.octaveUp1 = enabled
	end
end

function GranularComponent:octaveEnabled(octaveIdentifier)
	if octaveIdentifier == -3 then
		return self.octaveDown3
	elseif octaveIdentifier == -2 then
		return self.octaveDown2
	elseif octaveIdentifier == -1 then
		return self.octaveDown1
	elseif octaveIdentifier == 1 then
		return self.octaveNoChange
	elseif octaveIdentifier == 2 then
		return self.octaveUp1 
	end
end

function GranularComponent:setSubsampleWidth(encoderValue)
	self.normalisedWidth = encoderValue
	self.maxWidthMs = self.sampleMs/3
	self.subsampleMs = math.floor(map(self.normalisedWidth, 0.0, 1.0, self.minWidthMs, self.maxWidthMs))
end

function GranularComponent:generateSubsample()	
	local minStartMs = math.floor(map(self.normalisedMinPosition, 0.0, 1.0, 0, self.sampleMs))
	local maxEndMs = math.floor(map(self.normalisedMaxPosition, 0.0, 1.0, 0, self.sampleMs)) 
	
	local subsampleStartMs = math.random(minStartMs, maxEndMs)
	local subsampleEndMs = subsampleStartMs + self.subsampleMs
	
	if self.prevStartMs == subsampleStartMs and self.prevEndMs == subsampleEndMs then
		return
	else
		self.prevStartMs = subsampleStartMs
		self.prevEndMs = subsampleEndMs
	end

	local sampleRate = self.sample:getSampleRate()
	self.startFrame = math.floor(subsampleStartMs/1000 * sampleRate)
	self.endFrame = math.floor(subsampleEndMs/1000 * sampleRate)
	local subsample = self.sample:getSubsample(self.startFrame, self.endFrame)
	self.subsampleSeconds = subsample:getLength()
	self.sampleplayer:setSample(subsample)
end

function GranularComponent:getNormalisedStart()
	if self.startFrame == nil then
		return 0.0
	else
		return map(self.startFrame, 0, self.frames, 0.0, 1.0)
	end
end

function GranularComponent:getNormalisedEnd()
	if self.endFrame == nil then
		return 1.0
	else
		return map(self.endFrame, 0, self.frames, 0.0, 1.0)
	end
end

function GranularComponent:stopPlay()
	self.sampleplayer:stop()
end

function GranularComponent:isPlaying()
	return self.sampleplayer:isPlaying()
end

function GranularComponent:load(path)
	self.path = path
	self.loading = true
	print("GRAIN Loading: " .. path)
	
	self.sample = playdate.sound.sample.new(path)
	
	print("GRAIN calculating frames")
	local sampleRate = self.sample:getSampleRate()
	self.frames = math.floor(self.sample:getLength() * sampleRate)
	self.sampleMs = self.sample:getLength() * 1000	
	self:setSubsampleWidth(self.normalisedWidth)	

	self.playTimestampMs = playdate.getCurrentTimeMilliseconds()
	self.subsampleSeconds = 0
	--self.updateListener()

	self.loading = false
	self.waitingForLoad = false
end

function GranularComponent:setRateAndPlay()
	
	if self.waitingForLoad == true then
		return
	end
	
	local activeOctaves = {}
	local rate = 1
	
	if self.octaveDown3 then
		table.insert(activeOctaves, "-3")
	end
	
	if self.octaveDown2 then
		table.insert(activeOctaves, "-2")
	end
	
	if self.octaveDown1 then
		table.insert(activeOctaves, "-1")
	end
	
	if self.octaveNoChange then
		table.insert(activeOctaves, "1")
	end
	
	if self.octaveUp1 then
		table.insert(activeOctaves, "+1")
	end
	
	local octaves = #activeOctaves
	if octaves > 0 then
		local octaveChoice = math.floor(math.random(octaves))
		if activeOctaves[octaveChoice] == "-3" then
			rate = 0.125
			self.waitTimeout = (self.subsampleSeconds * 1000) * 4
		elseif activeOctaves[octaveChoice] == "-2" then
			rate = 0.25
			self.waitTimeout = (self.subsampleSeconds * 1000) * 4
		elseif activeOctaves[octaveChoice] == "-1" then
			rate = 0.5
			self.waitTimeout = (self.subsampleSeconds * 1000) * 2
		elseif activeOctaves[octaveChoice] == "1" then
			rate = 1.0
			self.waitTimeout = (self.subsampleSeconds * 1000)
		elseif activeOctaves[octaveChoice] == "+1" then
			rate = 2.0
			self.waitTimeout = (self.subsampleSeconds * 1000) / 2
		end
		
		self.playTimestampMs = playdate.getCurrentTimeMilliseconds()
		
		if math.random() < self.normalisedReverseChance then
			self.sampleplayer:setRate(-rate)
			self:play()
		else
			self.sampleplayer:setRate(rate)
			self:play()
		end
		
		self.updateListener()
	else
		print("No active octaves")
	end
end

function GranularComponent:unplug(cableId)
	if self:positionSocketConnected() and "" .. self.positionSocket:getCableId() == "" .. cableId then 
		self.sampleplayer:stop()
		self.positionSocket:unplug() 
	end
	if self:bangSocketConnected() and "" .. self.bangSocket:getCableId() == "" .. cableId then 
		self.sampleplayer:stop()
		self.bangSocket:unplug() 
	end
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then 
		self.sampleplayer:stop()
		self.outSocket:unplug() 
		self.channel:setVolume(0)
	end
end

function GranularComponent:setSubsampleMaxEnd(normalisedValue) self.normalisedMaxPosition = normalisedValue end
function GranularComponent:getMaxPosition() return self.normalisedMaxPosition end
function GranularComponent:setSubsampleMinStart(normalisedValue) self.normalisedMinPosition = normalisedValue end
function GranularComponent:getMinPosition() return self.normalisedMinPosition end
function GranularComponent:getMaxMs() return self.maxWidthMs end
function GranularComponent:getMinMs() return self.minWidthMs end
function GranularComponent:getSubsampleMs() return self.subsampleMs end
function GranularComponent:setSubsampleReverseChance(normalisedValue) self.normalisedReverseChance = normalisedValue end
function GranularComponent:getSubsampleReverseChance() return self.normalisedReverseChance end
function GranularComponent:setDoSmoothing(smoooooooooooooth) self.doSmoothing = smoooooooooooooth end
function GranularComponent:positionSocketInsert(cable) self.positionSocket:setCable(cable) end
function GranularComponent:bangSocketInsert(cable) self.bangSocket:setCable(cable) end
function GranularComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function GranularComponent:unplugPositionSocket() self.positionSocket:unplug() end
function GranularComponent:unplugBangSocket() self.bangSocket:unplug() end
function GranularComponent:unplugOut() 
	self.sampleplayer:stop()
	self.channel:setVolume(0)
	self.outSocket:unplug() 
end
function GranularComponent:positionSocketConnected() return self.positionSocket:connected() end
function GranularComponent:bangSocketConnected() return self.bangSocket:connected() end
function GranularComponent:outConnected() return self.outSocket:connected() end

--Save state methods
function GranularComponent:getFilePath() return self.path end
function GranularComponent:isSmoothingOn() return self.doSmoothing end