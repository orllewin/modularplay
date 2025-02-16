--[[
	© 2023 Orllewin - All Rights Reserved.
]]
class('Bifurcate4Component').extends()

function Bifurcate4Component:init()
	Bifurcate4Component.super.init(self)
	
	self.outASocket = Socket("splitter_out_a", socket_send)
	self.outBSocket = Socket("splitter_out_b", socket_send)
	self.outCSocket = Socket("splitter_out_c", socket_send)
	self.outDSocket = Socket("splitter_out_d", socket_send)
	
	self.inSocket = Socket("splitter_in", socket_receive, function(event) 
		self.outASocket:emit(event)
		self.outBSocket:emit(event)
		self.outCSocket:emit(event)
		self.outDSocket:emit(event)
	end)
end


function Bifurcate4Component:allFree()
	if self.inSocket:free() and self.outASocket:free() and self.outASocket:free() and self.outASocket:free() and self.outASocket:free() then
		return true
	else
		return false
	end
end

function Bifurcate4Component:setInCable(cable)
	self.inSocket:setCable(cable)
end

function Bifurcate4Component:setOutACable(cable)
	self.outASocket:setCable(cable)
end

function Bifurcate4Component:setOutBCable(cable)
	self.outBSocket:setCable(cable)
end

function Bifurcate4Component:setOutCCable(cable)
	self.outCSocket:setCable(cable)
end

function Bifurcate4Component:setOutDCable(cable)
	self.outDSocket:setCable(cable)
end
-- -- ----

function Bifurcate4Component:unplug(cableId)
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

function Bifurcate4Component:unplugIn()
	self.inSocket:setCable(nil)
end

function Bifurcate4Component:unplugOutA()
	self.outASocket:setCable(nil)
end

function Bifurcate4Component:unplugOutB()
	self.outBSocket:setCable(nil)
end

function Bifurcate4Component:unplugOutC()
	self.outCSocket:setCable(nil)
end

function Bifurcate4Component:unplugOutD()
	self.outDSocket:setCable(nil)
end

function Bifurcate4Component:inConnected()
	return self.inSocket:connected()
end

function Bifurcate4Component:outAConnected()
	return self.outASocket:connected()
end

function Bifurcate4Component:outBConnected()
	return self.outBSocket:connected()
end

function Bifurcate4Component:outCConnected()
	return self.outCSocket:connected()
end

function Bifurcate4Component:outDConnected()
	return self.outDSocket:connected()
end