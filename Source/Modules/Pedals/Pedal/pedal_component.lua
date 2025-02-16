--[[
	© 2023 Orllewin - All Rights Reserved.
]]
class('PedalComponent').extends()

function PedalComponent:init()
	PedalComponent.super.init(self)
	
	self.countdownSound = playdate.sound.sampleplayer.new("Samples/ui_blip")
	
	self.inSocket = Socket("pedal_in", socket_receive, function(event) 
		if event:getValue() > 0 then
			self:bang()
		elseif event:getValue() < 0 then
			self:unbang()
		end
	end)
	
	self.outSocket = Socket("pedal_out", socket_send)
end

function PedalComponent:beep()
	self.countdownSound:play()
end

function PedalComponent:inConnected() return self.inSocket:connected() end
function PedalComponent:outConnected() return self.outSocket:connected() end

function PedalComponent:unplugIn(cableId) self.inSocket:setCable(nil) end
function PedalComponent:unplugOut(cableId) self.outSocket:setCable(nil) end

function PedalComponent:setInCable(cable) self.inSocket:setCable(cable) end
function PedalComponent:setOutCable(cable) self.outSocket:setCable(cable) end

function PedalComponent:bang() return self.outSocket:emit(Event(event_bang, 1)) end
function PedalComponent:unbang() return self.outSocket:emit(Event(event_bang, -1)) end

function PedalComponent:unplug(cableId)
	if self:inConnected() and "" .. cableId == "" .. self.inSocket:getCableId() then
		self.inSocket:unplug()
	elseif self:outConnected() and "" .. cableId == "" .. self.outSocket:getCableId() then
		self.outSocket:unplug()
	end
end
