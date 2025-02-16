--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('DrumComponent').extends()

function DrumComponent:init(listener)
	DrumComponent.super.init(self)
	
	self.listener = listener
	
	self.expiring = false
	
	self.values = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}--todo unused, but crashes without it, see below...
	self.step = 1

	self.outSocket = Socket("drum_component_out", socket_send)

	self.inSocket = Socket("sequence_component_in", socket_receive, function(event) 
		if self.expiring == true then return end
		
		if self.step ~= event.value then
			self.step = event.value
		end
		
		self.outSocket:emit(Event(self.values[self.step]))-- todo wtf is this, old stale code?
		
		if self.listener ~= nil then
			self.listener(self.step)
		end
		
		self.step += 1
		
		if self.step == 17 then
			self.step = 1
		end
	end)
end

function DrumComponent:stopAll()
	self.expiring = true
end

function DrumComponent:getStep()
	return self.step
end

function DrumComponent:setValue(index, value)
	self.values[index] = value
end

function DrumComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function DrumComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end

function DrumComponent:unplugIn()
	self.inSocket:setCable(nil)
end

function DrumComponent:unplugOut()
	self.outSocket:setCable(nil)
end

function DrumComponent:inConnected()
	return self.inSocket:connected()
end

function DrumComponent:outConnected()
	return self.outSocket:connected()
end

