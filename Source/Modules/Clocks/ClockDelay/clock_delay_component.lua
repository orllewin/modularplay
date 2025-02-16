--[[
	© 2023 Orllewin - All Rights Reserved.
]]
class('ClockDelayComponent').extends()

local mode1_1 = 1
local mode1_2 = 2
local mode1_4 = 3
local mode1_8 = 4
local mode1_16 = 5
local mode1_32 = 6
local mode1_64 = 7

function ClockDelayComponent:init()
	ClockDelayComponent.super.init(self)
	
	self.bpm = -1
	self.divisionChoice = 4
	self.probability = 60
	self.delayMS = 250
	
	self.didDelay = false
	
	self.outSocket = Socket("clock_delay_out", socket_send)
	
	self.inSocket = Socket("clock_delay_in", socket_receive, function(event) 
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
					self.outSocket:emit(event)
				end)
			else
				self.outSocket:emit(event)
			end
		end
	end)
end

function ClockDelayComponent:calculateMS()
	
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

function ClockDelayComponent:setChance(normalisedChance)
	self.probability = math.floor(normalisedChance * 100)
	return "" .. self.probability .. "%"
end

function ClockDelayComponent:getDivChoice()
	return self.divisionChoice
end

function ClockDelayComponent:setDivisionDelay(normalisedInput)
	self.divisionChoice = math.floor(map(normalisedInput, 0.0, 1.0, 1, 7))
	self:calculateMS()
	return self.divisionChoice
end

function ClockDelayComponent:inConnected()
	return self.inSocket:connected()
end

function ClockDelayComponent:outConnected()
	return self.outSocket:connected()
end

function ClockDelayComponent:unplug(cableId)
	if self:inConnected() and "" .. self.inSocket:getCableId() == "" .. cableId then
		self.inSocket:unplug()
	end
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then
		self.outSocket:unplug()
	end
end

function ClockDelayComponent:unplugIn(cableId)
	self.inSocket:unplug()
end

function ClockDelayComponent:unplugOut(cableId)
	self.outSocket:unplug()
end

function ClockDelayComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function ClockDelayComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end