--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Samplers/Looper/looper_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'

class('LooperMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 50
local moduleHeight = 50

local modType = "LooperMod"
local modSubtype = "audio_gen"

function LooperMod:init(xx, yy, modId, onInit)
	LooperMod.super.init(self)
	
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
	
	self:moveTo(xx, yy)
	self:add()
	
	self.component = LooperComponent(function(channel)
		self.onInit(self.modId, channel)
	end)
	
	self.loopLengthEncoderVector = Vector(xx - 19, yy + 1)
	self.loopLengthEncoderValue = 1.0
	
	self.encoderVectors = {
		self.loopLengthEncoderVector
	}
	
	self.socketInVector = Vector(xx - 25, 	yy)
	self.socketOutVector = Vector(xx + 25, 	yy)
	
	self:redrawBackground()
end

function LooperMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function LooperMod:redrawBackground()
	gEncoder:hide()
	self.backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = self.backgroundImage:getSize()

	gfx.pushContext(self.backgroundImage)
	
	gEncoder:setValue(self.loopLengthEncoderValue)
	local loopLengthEncoderImage = gEncoder:getImage()
	loopLengthEncoderImage:draw(bgW/2, 35)
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 32)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(62, 32)
	
	gfx.popContext()
	
	self:setImage(self.backgroundImage)
	self.redrawPending = false
end

function LooperMod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end
	
	if encoderVector == self.loopLengthEncoderVector then
		gEncoder:setValue(self.loopLengthEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.loopLengthEncoderVector.x, self.loopLengthEncoderVector.y)
		gEncoder:turn(change)
		self.loopLengthEncoderValue = gEncoder:getValue()
		self.component:setLoopLength(self.loopLengthEncoderValue)
	end
	self.redrawPending = true
end

function LooperMod:findClosestEncoderVector(x, y)
	local reticleVector = Vector(x, y)
	local closestDistance = 1000
	local closestIndex = -1
	for i=1,#self.encoderVectors do
		local encoderVector = self.encoderVectors[i]
		local distance = reticleVector:distance(encoderVector)
		if distance < closestDistance then
			closestDistance = distance
			closestIndex = i
		end
	end
	
	return self.encoderVectors[closestIndex]
end


function LooperMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function LooperMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function LooperMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function LooperMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype, onError)
	if sourceSubtype ~= "clock_router" then
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

function LooperMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function LooperMod:handleModClick(tX, tY, listener)
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

function LooperMod:evaporate(onDetachConnected)
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

function LooperMod:type() return modType end
function LooperMod:getModId() return self.modId end
function LooperMod:unplug(cableId) self.component:unplug(cableId) end
function LooperMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function LooperMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y	
	modState.waveformType = self.component:getWaveformTypeIndex()
	return modState
end

function LooperMod:fromState(modState)
	self.component:setWaveform(modState.waveformType)
end