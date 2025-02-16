--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'Modules/Serial/SerialMidiNoteInput/serial_in_component'

class('SerialInMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local usbImage = gfx.image.new("Images/usb")

local moduleWidth = 85
local moduleHeight = 35

local modType = "SerialInMod"
local modSubtype = "midi"

function SerialInMod:init(xx, yy, modId)
	SerialInMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self:redrawBackground()
	self:moveTo(xx, yy)
	self:add()
		
	self.socketOutVector = Vector(xx + moduleWidth/2, 	yy)
	
	self.component = SerialInComponent(function(midiNote)
		
	end)
end

function SerialInMod:mn(midiNote)
	self.component:mn(midiNote)
end

function SerialInMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function SerialInMod:redrawBackground()
	self.backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = self.backgroundImage:getSize()
	
	gfx.pushContext(self.backgroundImage)
		
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(bgW - 16, bgH/2 - 8)
	--gfx.drawTextAligned("WIP", bgW/2, bgH/2 - 15, kTextAlignment.center)
	--gfx.drawTextAligned("Midi in", bgW/2, bgH/2, kTextAlignment.center)
	
	assets:image("tiny_keyboard_icon"):draw(65, 22)
	
	usbImage:drawScaled(22, 20, 0.75)
		
	gfx.popContext()
	
	self:setImage(self.backgroundImage)
end

function SerialInMod:setOutCable(patchCable)
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function SerialInMod:type() return modType end
function SerialInMod:getModId() return self.modId end
function SerialInMod:tryConnectGhostIn(x, y, ghostCable) return false end
function SerialInMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end
function SerialInMod:unplug(cableId) self.component:unplug(cableId) end

function SerialInMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function SerialInMod:moveFinish()
	self.socketOutVector = Vector(self.x + moduleWidth/2, self.y)
end

function SerialInMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
	
	self:remove()
end

function SerialInMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function SerialInMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = nil
	
	actions = {
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	 
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Midi note input - requires Midi Bus project running on a computer, see website for more details.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function SerialInMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
	
	self:remove()
end
	