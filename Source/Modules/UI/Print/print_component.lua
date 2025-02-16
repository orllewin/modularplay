--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('PrintComponent').extends()

function PrintComponent:init(id, listener)
	PrintComponent.super.init(self)
	
	self.id = id
	self.listener = listener
	
	self.outSocket = Socket("print_module_out", socket_send)
	
	self.inSocket = Socket("print_module_in", socket_receive, function(event) 
		if event ~= nil then
			self.outSocket:emit(event)
		end
		if self.listener ~= nil then
			self.listener(event)
		end
	end)
end

function PrintComponent:inConnected()
	return self.inSocket:connected()
end

function PrintComponent:outConnected()
	return self.outSocket:connected()
end

function PrintComponent:unplug(cableId)
	if self:inConnected() then
		local inCableId = self.inSocket:getCableId()
		if inCableId == cableId then
			self.inSocket:unplug()
		end
	end
	
	if self:outConnected() then
		local outCableId = self.outSocket:getCableId()
		if outCableId == cableId then
			self.outSocket:unplug()
		end
	end
end

function PrintComponent:unplugIn()
	self.inSocket:unplug()
end

function PrintComponent:unplugOut()
	self.outSocket:unplug()
end


function PrintComponent:setInCable(cable)
	self.inSocket:setCable(cable)
end

function PrintComponent:setOutCable(cable)
	self.outSocket:setCable(cable)
end