--[[
	© 2023 Orllewin - All Rights Reserved.
]]
class('Merge2Component').extends()

function Merge2Component:init()
	Merge2Component.super.init(self)
	
	self.inASocket = Socket("merge_in_a", socket_receive, function(event) 
		self.outSocket:emit(event)
	end)
	self.inBSocket = Socket("merge_in_b", socket_receive, function(event) 
		self.outSocket:emit(event)
	end)
	
	self.outSocket = Socket("merge_out", socket_send)
end

function Merge2Component:allFree()
	if self:inAConnected() == false and self:inBConnected() == false and  self:outConnected() == false then
		return true
	else
		return false
	end
end

function Merge2Component:setInACable(cable)
	self.inASocket:setCable(cable)
end

function Merge2Component:inAConnected()
	return self.inASocket:connected()
end

function Merge2Component:setInBCable(cable)
	self.inBSocket:setCable(cable)
end

function Merge2Component:inBConnected()
	return self.inBSocket:connected()
end

function Merge2Component:outConnected()
	return self.outSocket:connected()
end

function Merge2Component:setOutCable(cable)
	self.outSocket:setCable(cable)
end

-- ---

function Merge2Component:unplug(cableId)
	if self:inAConnected() and "" .. self.inASocket:getCableId() == "" .. cableId then
		self.inASocket:unplug()
	end
	if self:inBConnected() and "" .. self.inBSocket:getCableId() == "" .. cableId then
		self.inBSocket:unplug()
	end
	if self:outConnected() and "" .. self.outSocket:getCableId() == "" .. cableId then
		self.outSocket:unplug()
	end
end

function Merge2Component:unplugInA() self.inASocket:unplug() end
function Merge2Component:unplugInB() self.inBSocket:unplug() end
function Merge2Component:unplugOut() self.outSocket:unplug() end