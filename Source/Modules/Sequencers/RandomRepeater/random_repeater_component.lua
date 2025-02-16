--[[
	© 2023 Orllewin - All Rights Reserved.
]]
class('RandomRepeaterComponent').extends()

function RandomRepeaterComponent:init()
	RandomRepeaterComponent.super.init(self)
	
	self.outASocket = Socket("splitter_out_a", socket_send)
	self.outBSocket = Socket("splitter_out_b", socket_send)
	self.outCSocket = Socket("splitter_out_c", socket_send)
	self.outDSocket = Socket("splitter_out_d", socket_send)
	
	self.inSocket = Socket("splitter_in", socket_receive, function(event)
		if self.outASocket:connected() and self.outBSocket:free() and self.outCSocket:free() and self.outDSocket:free() then
			self.outASocket:emit(event)
		elseif self.outASocket:connected() and self.outBSocket:connected() and self.outCSocket:free() and self.outDSocket:free() then
			if math.random() < 0.5 then
				self.outASocket:emit(event)
			else
				self.outBSocket:emit(event)
			end
		elseif self.outASocket:connected() and self.outBSocket:connected() and self.outCSocket:connected() and self.outDSocket:free() then
			if math.random() < 0.33 then
				self.outASocket:emit(event)
			elseif math.random() < 0.66 then
				self.outBSocket:emit(event)
			else 
				self.outCSocket:emit(event)
			end
		elseif self.outASocket:connected() and self.outBSocket:connected() and self.outCSocket:connected() and self.outDSocket:connected() then
			if math.random() < 0.25 then
				self.outASocket:emit(event)
			elseif math.random() < 0.50 then
				self.outBSocket:emit(event)
			elseif math.random() < 0.75 then 
				self.outCSocket:emit(event)
			else
				self.outDSocket:emit(event)
			end
		end
	end)
end


function RandomRepeaterComponent:allFree()
	if self.inSocket:free() and self.outASocket:free() and self.outASocket:free() and self.outASocket:free() and self.outASocket:free() then
		return true
	else
		return false
	end
end

function RandomRepeaterComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function RandomRepeaterComponent:setOutACable(cable)
	self.outASocket:setCable(cable)
end

function RandomRepeaterComponent:setOutBCable(cable)
	self.outBSocket:setCable(cable)
end

function RandomRepeaterComponent:setOutCCable(cable)
	self.outCSocket:setCable(cable)
end

function RandomRepeaterComponent:setOutDCable(cable)
	self.outDSocket:setCable(cable)
end
-- -- ----

function RandomRepeaterComponent:unplug(cableId)
	if self:inConnected() and "" .. self.inSocket:getCableId() == "" .. cableId then
		self.inSocket:unplug()
	end
	if self:outAConnected() and "" .. self.outASocket:getCableId() == "" .. cableId then
		self.outASocket:unplug()
	end
	if self:outBConnected() and "" .. self.outBSocket:getCableId() == "" .. cableId then
		self.outBSocket:unplug()
	end
	if self:outCConnected() and "" .. self.outCSocket:getCableId() == "" .. cableId then
		self.outCSocket:unplug()
	end
	if self:outDConnected() and "" .. self.outDSocket:getCableId() == "" .. cableId then
		self.outDSocket:unplug()
	end
end

function RandomRepeaterComponent:unplugIn()
	self.inSocket:setCable(nil)
end

function RandomRepeaterComponent:unplugOutA()
	self.outASocket:setCable(nil)
end

function RandomRepeaterComponent:unplugOutB()
	self.outBSocket:setCable(nil)
end

function RandomRepeaterComponent:unplugOutC()
	self.outCSocket:setCable(nil)
end

function RandomRepeaterComponent:unplugOutD()
	self.outDSocket:setCable(nil)
end

function RandomRepeaterComponent:inConnected()
	return self.inSocket:connected()
end

function RandomRepeaterComponent:outAConnected()
	return self.outASocket:connected()
end

function RandomRepeaterComponent:outBConnected()
	return self.outBSocket:connected()
end

function RandomRepeaterComponent:outCConnected()
	return self.outCSocket:connected()
end

function RandomRepeaterComponent:outDConnected()
	return self.outDSocket:connected()
end