--[[
	© 2023 Orllewin - All Rights Reserved.
]]
class('Bifurcate2Component').extends()

function Bifurcate2Component:init()
	Bifurcate2Component.super.init(self)
	
	self.outASocket = Socket("splitter_out_a", socket_send)
	self.outBSocket = Socket("splitter_out_b", socket_send)
	
	self.inSocket = Socket("splitter_in", socket_receive, function(event) 
		self.outASocket:emit(event)
		self.outBSocket:emit(event)
	end)
end

function Bifurcate2Component:allFree()
	if self:inConnected() == false and self:outAConnected() == false and  self:outBConnected() == false then
		return true
	else
		return false
	end
end

function Bifurcate2Component:setInCable(cable)
	self.inSocket:setCable(cable)
end

function Bifurcate2Component:inConnected()
	return self.inSocket:connected()
end

function Bifurcate2Component:outAConnected()
	return self.outASocket:connected()
end

function Bifurcate2Component:outBConnected()
	return self.outBSocket:connected()
end

function Bifurcate2Component:setOutACable(cable)
	self.outASocket:setCable(cable)
end

function Bifurcate2Component:setOutBCable(cable)
	self.outBSocket:setCable(cable)
end
-- ---

function Bifurcate2Component:unplug(cableId)
	if self:inConnected() and "" .. self.inSocket:getCableId() == "" .. cableId then
		self.inSocket:unplug()
	end
	if self:outAConnected() and "" .. self.outASocket:getCableId() == "" .. cableId then
		self.outASocket:unplug()
	end
	if self:outBConnected() and "" .. self.outBSocket:getCableId() == "" .. cableId then
		self.outBSocket:unplug()
	end
end

function Bifurcate2Component:unplugIn() self.inSocket:unplug() end
function Bifurcate2Component:unplugOutA() self.outASocket:unplug() end
function Bifurcate2Component:unplugOutB() self.outBSocket:unplug() end