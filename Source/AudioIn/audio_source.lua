class('AudioSource').extends()

function AudioSource:init()
	AudioSource.super.init()
	self.recording = false
	
	self.slots = 5
	self.currentSlot = 1
end

function AudioSource:start()
	self:recordSample()
end

function AudioSource:recordSample()
	
	self.currentSlot += 1
	if self.currentSlot == self.slots + 1 then
		self.currentSlot = 1
	end
	
	print("recordSample() to slot " .. self.currentSlot .. " micLevel: " .. playdate.sound.micinput.getLevel() .. " AudioSource: " .. playdate.sound.micinput.getSource())
	
	self.buffer = playdate.sound.sample.new(6, playdate.sound.kFormat16bitMono)
	self.recording = true
	
	--[[
		Ideally we'd have this anonymous callback function recursively call recordSample() but
		there's a bug in the underlying implementation preventing that tidy syntax so we have to
		toggle a flag instead that's read in the main update loop to record the next subsample
		in the circular sample buffer
	--]]
	
	playdate.sound.micinput.recordToSample(self.buffer, function(sample)
		self.buffer:save("audio_buffer_" .. self.currentSlot .. ".pda")
		self.recording = false
	end)
end

function AudioSource:isRecording()
	return self.recording
end


	