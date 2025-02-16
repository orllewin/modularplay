--[[
	© 2023 Orllewin - All Rights Reserved.
]]
class('SamplerComponent').extends()

function SamplerComponent:init(listener)
	SamplerComponent.super.init(self)
	
	playdate.sound.micinput.startListening()
	
	self.listener = listener
	self.recording = false
	
	
	self.inSocket = Socket("record_toggle_in", socket_recieve, function(event)
		if event:getValue() == 1 then
			self:startRecording()
		elseif event:getValue() == -1 then
			self:stopRecording()
		end
	end)
end

function SamplerComponent:playBuffer()
	if self.buffer == nil then return end
	if self.previewPlayer ~= nil then self.previewPlayer:stop()	end
	self.previewPlayer = playdate.sound.sampleplayer.new(self.buffer)
	self.previewPlayer:play()
end

function SamplerComponent:save(filename)
	if(filename == nil) then return end
	local filepath = "Recorded/" .. filename .. ".pda"
	print("Saving to " .. filepath)
	self.buffer:save(filepath)
end

function SamplerComponent:startRecording()
	print("START REC")
	self.buffer = playdate.sound.sample.new(gMaxSampleSeconds, playdate.sound.kFormat16bitMono)
	self.recording = true
	self.listener({
		recording = true
	})
	playdate.sound.micinput.recordToSample(self.buffer, function(sample) 
		print("RECORDING STOPPED")
	end)
	
	self.timer = playdate.timer.new((gMaxSampleSeconds * 1000) + 1000, function(timer) 
		print("TIMER FINISHED")
		if self.recording then
			self:stopRecording()
		end
	end)
	self.timer.updateCallback = function(timer)
		local remainingMs = timer.timeLeft
		self.listener({
			remaining = remainingMs
		})
	end
end

function SamplerComponent:stopRecording()
	playdate.sound.micinput.stopRecording()
	if self.timer ~= nil then self.timer:remove() end
	self.recording = false
	self.listener({
		recording = false
	})
	
end

function SamplerComponent:isRecording()
	return self.recording
end

function SamplerComponent:inConnected()
	return self.inSocket:connected()
end

function SamplerComponent:bang()
	return self.inSocket:emit(Event(event_bang, 1))
end

function SamplerComponent:unbang()
	return self.inSocket:emit(Event(event_bang, -1))
end

function SamplerComponent:unplug(cableId)
	if self:inConnected() and "" .. cableId == "" .. self.inSocket:getCableId() then
		self.inSocket:unplug()
	end
end


function SamplerComponent:unplugIn(cableId)
	self.inSocket:setCable(nil)
end

function SamplerComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end