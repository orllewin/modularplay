--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Midi/MidiKeyboard/midi_keyboard_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'

class('MidiKeyboardMod').extends(playdate.graphics.sprite)

		local menuActions = {
	{
		label = "Octave Up"
	},
	{
		label = "Octave Down"
	},
	{
		label = "About"
	},
	{
		label = "Move"
	},
	{
		label = "Remove"
	}
}

local gfx <const> = playdate.graphics

local moduleWidth = 223
local moduleHeight = 60

local modType = "MidiKeyboardMod"
local modSubtype = "midi"

function MidiKeyboardMod:init(xx, yy, modId, onInit)
	MidiKeyboardMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.onInit = onInit
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.menuIndex = 1
		
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	gfx.pushContext(backgroundImage)
	
	local keyboardImage = gfx.image.new("Images/big_keyboard")
	local invertedKeyboard = keyboardImage:invertedImage()
	invertedKeyboard:draw(20, 30)
		
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(235, 25)
	
	gfx.drawText("ORLLEWIN", 165, 19)
		
	gfx.popContext()

	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.component = MidiKeyboardComponent()
	
	self.socketOutVector = Vector	(xx + (moduleWidth/2)+2, yy - 10)
	
end

function MidiKeyboardMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function MidiKeyboardMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function MidiKeyboardMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function MidiKeyboardMod:keyboardPress(tX, tY)
	print("keyaord presssss")
	if tY > self.y -15 then
		--todo get x note
		local rX = tX -(self.x - (moduleWidth/2))
		
		if rX > 6.5 and rX < 230 then
			rX = rX - 6.5
			if tY < self.y + 10 then
				--BLACK NOTE
				local blackNoteIndex = math.floor(map(rX + 8, 0, 192, 1, 20)) - 1
				self.component:playBlackNote(blackNoteIndex)
				
			else
				--WHITE NOTE
				local whiteNoteIndex = math.floor(map(rX, 0, 200, 1, 21))
				self.component:playWhiteNote(whiteNoteIndex)
			end
			return true
		else
			return false
		end
	else
		return false
	end
end

function MidiKeyboardMod:handleModClickUp(tX, tY, listener)
	self.component:noteOff()
end

function MidiKeyboardMod:handleModClick(tX, tY, listener)
	if self:keyboardPress(tX, tY) then
		--NOOP
	else
		self.menuListener = listener
		
		local contextMenu = ModuleMenu(menuActions)
		contextMenu:show(function(action, index) 
			self.menuIndex = index
	
			if action == "Octave Up" then
				self.component:octaveUp()
			elseif action == "Octave Down" then
				self.component:octaveDown()
			elseif action == "About" then
				local aboutPopup = ModAboutPopup("A midi keyboard. Not massively practical.")
				aboutPopup:show()
			elseif action == "Move" then
				if self.menuListener ~= nil then 
					self.menuListener(action) 
				end
			elseif action == "Remove" then
				if self.menuListener ~= nil then 
					self.menuListener(action) 
				end
			else
				--NOOP
			end
		end, self.menuIndex)
	end
end

function MidiKeyboardMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function MidiKeyboardMod:moveFinish()
	self.socketOutVector = Vector	(self.x + (moduleWidth/2)+2, self.y - 10)
end

function MidiKeyboardMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
		
	--then remove sprites
	self:remove()
end

function MidiKeyboardMod:type() return modType end
function MidiKeyboardMod:getModId() return self.modId end
function MidiKeyboardMod:unplug(cableId) 
	local didUnplug = self.component:unplug(cableId) 
	if didUnplug then
		self.outCable = nil
	end
end
function MidiKeyboardMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function MidiKeyboardMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y	
	return modState
end

function MidiKeyboardMod:fromState(modState)
	--NOOP
end