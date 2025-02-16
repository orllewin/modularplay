--[[
	© 2024 Orllewin - All Rights Reserved.
]]
import 'Modules/Serial/SerialBang/serial_bang_component'

class('SerialBangMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local usbImage = gfx.image.new("Images/usb")

local moduleWidth = 85
local moduleHeight = 35

local modType = "SerialBangMod"
local modSubtype = "clock_router"

function SerialBangMod:init(xx, yy, modId)
	SerialBangMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	self.serialBangId = 1
	
	
	self:redrawBackground()
	self:moveTo(xx, yy)
	self:add()
	
	
	
	
	self.socketOutVector = Vector(xx + moduleWidth/2, 	yy)

	self.component = SerialBangComponent(function(midiNote)
	--nothing here		
	end)
end

function SerialBangMod:bang()
	self.component:bang()
end

function SerialBangMod:bangId()
	return self.serialBangId
end

function SerialBangMod:mn(midiNote)
	self.component:mn(midiNote)
end

function SerialBangMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function SerialBangMod:redrawBackground()
	self.backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = self.backgroundImage:getSize()
	
	gfx.pushContext(self.backgroundImage)
		
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(bgW - 16, bgH/2 - 8)
	--gfx.drawTextAligned("WIP", bgW/2, bgH/2 - 15, kTextAlignment.center)
	--gfx.drawTextAligned("Midi in", bgW/2, bgH/2, kTextAlignment.center)
	
	usbImage:drawScaled(22, 20, 0.75)
	
	assets:bigFont():drawText("" .. self.serialBangId, bgW/2 + 12, bgH/2 - 11, kTextAlignment.center)
		
	gfx.popContext()
	
	self:setImage(self.backgroundImage)
end

function SerialBangMod:setOutCable(patchCable)
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function SerialBangMod:type() return modType end
function SerialBangMod:getModId() return self.modId end
function SerialBangMod:tryConnectGhostIn(x, y, ghostCable) return false end
function SerialBangMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end
function SerialBangMod:unplug(cableId) self.component:unplug(cableId) end

function SerialBangMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function SerialBangMod:moveFinish()
	self.socketOutVector = Vector(self.x + moduleWidth/2, self.y)
end

function SerialBangMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
	
	self:remove()
end

function SerialBangMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function SerialBangMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = nil
	
	actions = {
		{label = "About"},
		{label = "Serial ID 1"},
		{label = "Serial ID 2"},
		{label = "Serial ID 3"},
		{label = "Serial ID 4"},
		{label = "Serial ID 5"},
		{label = "Serial ID 6"},
		{label = "Serial ID 7"},
		{label = "Serial ID 8"},
		{label = "Serial ID 9"},
		{label = "Serial ID 10"},
		{label = "Serial ID 11"},
		{label = "Serial ID 12"},
		{label = "Serial ID 13"},
		{label = "Serial ID 14"},
		{label = "Serial ID 15"},
		{label = "Serial ID 16"},
		{label = "Move"},
		{label = "Remove"}
	}
	 
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action, index) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Midi note input - requires Midi Bus project running on a computer, see website for more details.")
			aboutPopup:show()
		elseif action == "Move" or action == "Remove" then
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		else
			print("serial id selection: " .. index)
			self.serialBangId = index -1
			self:redrawBackground()
		end
	end)
end

function SerialBangMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
		
	self:remove()
end
	