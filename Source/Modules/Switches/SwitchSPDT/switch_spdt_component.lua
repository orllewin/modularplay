--[[
	© 2023 Orllewin - All Rights Reserved.
]]
class('SwitchSPDTComponent').extends()

function SwitchSPDTComponent:init(listener)
	SwitchSPDTComponent.super.init(self)
	
	self.listener = listener
	
	self.aEmitting = true
	self.inSocket = Socket("switch_module_in", socket_receive, function(event) 
		if self.aEmitting then 
			self.outASocket:emit(event)
		else
			self.outBSocket:emit(event)
	 	end
	end)
	
	self.inToggleSocket = Socket("switch_module_toggle_in", socket_receive, function(event) 
			self:toggle()
			if self.listener ~= nil then self.listener() end
		end)
	
	self.outASocket = Socket("spdt_switch_module_out_a", socket_send)
	self.outBSocket = Socket("spdt_switch_module_out_b", socket_send)
end

function SwitchSPDTComponent:toggle()
	if self.aEmitting then
		self.aEmitting = false
	else
		self.aEmitting = true
	end
end

function SwitchSPDTComponent:unplug(cableId)
	if self:inConnected() and "" .. self.inSocket:getCableId() == "" .. cableId then self.inSocket:unplug()	end
	if self:inToggleConnected() and "" .. self.inToggleSocket:getCableId() == "" .. cableId then self.inToggleSocket:unplug()	end
	if self:outAConnected() and "" .. self.outASocket:getCableId() == "" .. cableId then self.outASocket:unplug()	end
	if self:outBConnected() and "" .. self.outBSocket:getCableId() == "" .. cableId then self.outBSocket:unplug()	end
end

function SwitchSPDTComponent:isOn() return self.aEmitting end
function SwitchSPDTComponent:switchOn() self.aEmitting = true end
function SwitchSPDTComponent:switchOff() self.aEmitting = false end
function SwitchSPDTComponent:setInCable(cable) self.inSocket:setCable(cable) end
function SwitchSPDTComponent:setToggleInCable(cable) self.inToggleSocket:setCable(cable) end
function SwitchSPDTComponent:setOutACable(cable) self.outASocket:setCable(cable) end
function SwitchSPDTComponent:setOutBCable(cable) self.outBSocket:setCable(cable) end
function SwitchSPDTComponent:unplugIn() self.inSocket:unplug() end
function SwitchSPDTComponent:unplugToggleIn() self.inToggleSocket:unplug() end
function SwitchSPDTComponent:unplugOutA() self.outASocket:unplug() end
function SwitchSPDTComponent:unplugOutB() self.outBSocket:unplug() end
function SwitchSPDTComponent:inConnected() return self.inSocket:connected() end
function SwitchSPDTComponent:inToggleConnected() return self.inToggleSocket:connected() end
function SwitchSPDTComponent:outAConnected() return self.outASocket:connected() end
function SwitchSPDTComponent:outBConnected() return self.outBSocket:connected() end