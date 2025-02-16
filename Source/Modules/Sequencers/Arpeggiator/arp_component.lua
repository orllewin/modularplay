--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('ArpComponent').extends()

local random <const> = math.random
local blank16 = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

function ArpComponent:init()
	ArpComponent.super.init(self)
			
	self.pattern = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	self.stepLength = 16
	self.step = 1
	self.seqStep = 1
	
	self.stopping = false
	
	self.octave = 0
	self.rate = 0
	
	self.outSocket = Socket("arp_out", socket_send)
	
	self.inSocket = Socket("arp_in", socket_receive, function(event) 
		if self.stopping then
			return
		end
		-- main step counter
		self.step += 1
		if self.step == 17 then
			self.step = 1
		end
		
		local note = self.pattern[self.seqStep]
	
		if self.rate == 0 then
			--RATE 1
			self.seqStep += 1
			if self.seqStep > self.stepLength then
				self.seqStep  = 1
			end
		
			if note <=0 then return end
			self.outSocket:emit(Event(event_value, note + (self.octave * 12)))
			
		elseif self.rate == -1 and math.fmod(self.step, 2) == 0 then
			--RATE 1/2
			self.seqStep += 1
			if self.seqStep > self.stepLength then
				self.seqStep  = 1
			end
			
			if note <=0 then return end
			self.outSocket:emit(Event(event_value,  note + (self.octave * 12)))
			
		elseif self.rate == -2 and math.fmod(self.step, 4) == 0 then
			--RATE 1/4
			self.seqStep += 1
			if self.seqStep > self.stepLength then
				self.seqStep  = 1
			end
					
			if note <=0 then return end
			self.outSocket:emit(Event(event_value,  note + (self.octave * 12)))
		end	
	end)
end

function ArpComponent:stopAll()
	self.outSocket:emit(Event(event_value,  -1))
	self.stopping = true
end

function ArpComponent:setRate(rate)
	if rate == self.rate then return end
	print("Setting rate to: " .. rate)
	self.rate = rate
end

function ArpComponent:setOctave(octave)
	if octave == self.octave then return end
	print("Setting octave to " .. octave)
	self.octave = octave
end

function ArpComponent:setPattern(pattern)
	self.pattern = pattern	
end

function ArpComponent:setPatternLength(stepLength)
	if self.stepLength == stepLength then
		print("self.stepLength already set to " .. stepLength .. " steps")
		return
	end
	
	while #self.pattern < stepLength do
		tableConcat(self.pattern, blank16)
	end
	
	self.stepLength = stepLength
	self.seqStep = self.step
end

function ArpComponent:getPattern()
	return self.pattern
end

function ArpComponent:getPatternLength()
	return self.stepLength
end

function ArpComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function ArpComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function ArpComponent:unplugIn()
	self.inSocket:setCable(nil)
end

function ArpComponent:unplugOut()
	self.outSocket:setCable(nil)
end

function ArpComponent:inConnected()
	return self.inSocket:connected()
end

function ArpComponent:outConnected()
	return self.outSocket:connected()
end

