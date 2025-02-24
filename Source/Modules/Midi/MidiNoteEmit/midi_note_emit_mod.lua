--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Midi/MidiNoteEmit/midi_note_emit_component'

class('MidiNoteEmitterMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 40
local moduleHeight = 50

local modType = "MidiNoteEmitterMod"
local modSubtype = "midi"

function MidiNoteEmitterMod:init(xx, yy, modId)
	MidiNoteEmitterMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.component = MidiNoteEmitterComponent()
	
	self.noteEncoderVector = Vector(xx, yy - 7)
	self.noteEncoderValue = map(self.component:getMidiNote(), 36, 95, 0.0, 1.0)
		
	self:redrawBackground()
	self:moveTo(xx, yy)
	self:add()
			
	self.socketInVector = Vector(xx - 20, yy - (moduleHeight/2) + 20)
	self.socketOutVector = Vector(xx + 21, yy - (moduleHeight/2) + 20)
end

function MidiNoteEmitterMod:redrawBackground()
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = backgroundImage:getSize()
	gfx.pushContext(backgroundImage)
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 32)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(moduleWidth + 12, 32)
	
	local note = playdate.graphics.imageWithText(self.component:getNoteStr(), moduleWidth, 10)
	local noteWidth, noteHeight = note:getSize()
	note:draw((moduleWidth/2), moduleHeight)
	
	gEncoder:setValue(self.noteEncoderValue)
	local noteEncoderImage = gEncoder:getImage()
	noteEncoderImage:draw(24, 22)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
end

function MidiNoteEmitterMod:turn(x, y, change)
	gEncoder:setValue(self.noteEncoderValue)
	gEncoder:show()
	gEncoder:moveTo(self.noteEncoderVector.x, self.noteEncoderVector.y)
	gEncoder:turn(change)
	self.noteEncoderValue = gEncoder:getValue()
	self.component:setValue(self.noteEncoderValue)
	self:redrawBackground()
end

function MidiNoteEmitterMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function MidiNoteEmitterMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function MidiNoteEmitterMod:setOutCable(patchCable)
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function MidiNoteEmitterMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function MidiNoteEmitterMod:tryConnectGhostIn(x, y, ghostCable)
	ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
	ghostCable:setGhostReceiveConnected()
	return true
end

function MidiNoteEmitterMod:tryConnectGhostOut(x, y, ghostCable)
	ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
	ghostCable:setGhostSendConnected()
	return true
end

function MidiNoteEmitterMod:type() return modType end

function MidiNoteEmitterMod:getModId()
	return self.modId
end

function MidiNoteEmitterMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function MidiNoteEmitterMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	
	local actions = {}
	
	table.insert(actions, {label="About"})
	table.insert(actions, {label="Move"})
	table.insert(actions, {label="Remove"})
	
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Emits a predefined midi note when it receives a 'bang'.")
			aboutPopup:show()
		elseif action == "Move" then
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		elseif action == "Remove" then
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end

	end)
end

function MidiNoteEmitterMod:unplug(cableId) self.component:unplug(cableId) end

function MidiNoteEmitterMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function MidiNoteEmitterMod:moveFinish()
	self.noteEncoderVector = Vector(self.x, self.y - 7)
	self.socketInVector = Vector(self.x - 20, self.y - (moduleHeight/2) + 20)
	self.socketOutVector = Vector(self.x + 21, self.y - (moduleHeight/2) + 20)
end


function MidiNoteEmitterMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.component:unplugIn()
		self.inCable:evaporate()
	end
	
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
	
	self:remove()
end

function MidiNoteEmitterMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.noteEncoderValue = self.noteEncoderValue
	
	return modState
end


function MidiNoteEmitterMod:fromState(modState)
	self.noteEncoderValue = modState.noteEncoderValue 
  self.component:setValue(self.noteEncoderValue)

	self:redrawBackground()	
end
