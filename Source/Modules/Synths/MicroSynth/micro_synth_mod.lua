--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Synths/MicroSynth/micro_synth_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'

class('MicroSynthMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 50
local moduleHeight = 50

local sineImage = playdate.graphics.image.new("Images/wf_sine")
local squareImage = playdate.graphics.image.new("Images/wf_square")
local triangleImage = playdate.graphics.image.new("Images/wf_triangle")
local sawtoothImage = playdate.graphics.image.new("Images/wf_sawtooth")
local poImage1 = playdate.graphics.image.new("Images/wf_po_1")
local poImage2 = playdate.graphics.image.new("Images/wf_po_2")
local poImage3 = playdate.graphics.image.new("Images/wf_po_3")

local modType = "MicroSynthMod"
local modSubtype = SourceTypes.audio_gen

function MicroSynthMod:init(xx, yy, modId, onInit)
	MicroSynthMod.super.init(self)
	
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
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 32)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(62, 32)
	
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.waveformSprite = gfx.sprite.new(sineImage)
	self.waveformSprite:moveTo(xx, yy)
	
	self.component = MicroSynthComponent(function(channel)
			self.onInit(self.modId, channel)
		end)

	self.waveformSprite:add()
		
	self.socketInVector = Vector(xx - 25, 	yy)
	self.socketOutVector = Vector(xx + 25, 	yy)
end

function MicroSynthMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function MicroSynthMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function MicroSynthMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function MicroSynthMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype, onError)
	if sourceSubtype ~= "midi" and sourceSubtype ~= "clock_router_or_midi" then
		if onError ~= nil then onError("This input requires a clock signal") end
		return false 
 	elseif ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function MicroSynthMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function MicroSynthMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "Sine"},
		{label = "Square"},
		{label = "Triangle"},
		{label = "Sawtooth"},
		{label = "PO Phase"},
		{label = "PO Digital"},
		{label = "PO Vosim"},
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action, index) 
		self.menuIndex = index

		if action == "Sine" then
			self.waveformSprite:setImage(sineImage)
			self.component:setWaveform(1)
		elseif action == "Square" then
			self.waveformSprite:setImage(squareImage)
			self.component:setWaveform(2)
		elseif action == "Triangle" then
			self.waveformSprite:setImage(triangleImage)
			self.component:setWaveform(4)
		elseif action == "Sawtooth" then
			self.waveformSprite:setImage(sawtoothImage)
			self.component:setWaveform(3)
		elseif action == "PO Phase" then
			self.waveformSprite:setImage(poImage1)
			self.component:setWaveform(5)
		elseif action == "PO Digital" then
			self.waveformSprite:setImage(poImage2)
			self.component:setWaveform(6)
		elseif action == "PO Vosim" then
			self.waveformSprite:setImage(poImage3)
			self.component:setWaveform(7)
		elseif action == "About" then
			local aboutPopup = ModAboutPopup("All the same waveform types as OrlSynth but without ADSR or extra parameters")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end, self.menuIndex)
end

function MicroSynthMod:repositionBy(x, y)
	self:moveBy(x, y)
	self.waveformSprite:moveBy(x, y)
end

function MicroSynthMod:moveFinish()
	self.socketInVector = Vector(self.x - 25, self.y)
	self.socketOutVector = Vector(self.x + 25, self.y)
end

function MicroSynthMod:evaporate(onDetachConnected)
	--first stop any notes playing:
	self.component:stopAll()
	
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

	--then remove sprites
	playdate.graphics.sprite.removeSprites({self.waveformSprite})
	self:remove()
end

function MicroSynthMod:type() return modType end
function MicroSynthMod:getModId() return self.modId end
function MicroSynthMod:unplug(cableId) self.component:unplug(cableId) end
function MicroSynthMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function MicroSynthMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y	
	modState.waveformType = self.component:getWaveformTypeIndex()
	return modState
end

function MicroSynthMod:fromState(modState)
	self.component:setWaveform(modState.waveformType)
end