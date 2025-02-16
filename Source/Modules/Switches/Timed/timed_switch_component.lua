--[[
	© 2023 Orllewin - All Rights Reserved.
]]--
class('TimedSwitchComponent').extends()

function TimedSwitchComponent:init(listener)
	TimedSwitchComponent.super.init(self)
	
	self.listener = listener
	
	self.inBeats = 0
	self.toggleAtBar = 4
	self.repeats = false
	self.emitting = false
	
	self.inSocket = Socket("switch_module_in", socket_receive, function(event) 
		self.inBeats += 1

		if self.inBeats/4 >= self.toggleAtBar then
			self.inBeats = 0
			self.emitting = not self.emitting
			if self.listener ~= nil then self.listener(self.emitting) end
		end
		if self.emitting then self.outSocket:emit(event) end
	end)
		
	self.outSocket = Socket("switch_module_out", socket_send)
end

function TimedSwitchComponent:setBars(bars)
	if bars == nil then
		print("bars is nil")
		return
	end
	print("Setting bars to " .. bars)
	self.inBeats = 0
	self.toggleAtBar = bars
end

function TimedSwitchComponent:getBars()
	return self.toggleAtBar
end

function TimedSwitchComponent:toggle()
	if self.emitting then
		self.emitting = false
	else
		self.emitting = true
	end
end

function TimedSwitchComponent:unplug(cableId)
	if self:inConnected() and "" .. self.inSocket:getCableId() == "" .. cableId then self.inSocket:unplug() end
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then self.outSocket:unplug() end
end

function TimedSwitchComponent:isOn() return self.emitting end
function TimedSwitchComponent:switchOn() self.emitting = true end
function TimedSwitchComponent:switchOff() self.emitting = false end
function TimedSwitchComponent:setInCable(cable) self.inSocket:setCable(cable) end
function TimedSwitchComponent:setOutCable(cable) self.outSocket:setCable(cable) end
function TimedSwitchComponent:unplugIn() self.inSocket:unplug() end
function TimedSwitchComponent:unplugOut() self.outSocket:unplug() end
function TimedSwitchComponent:inConnected() return self.inSocket:connected() end
function TimedSwitchComponent:outConnected() return self.outSocket:connected() end