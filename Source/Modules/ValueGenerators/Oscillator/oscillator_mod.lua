--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/ValueGenerators/Oscillator/oscillator_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'

class('OscillatorMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local positionImage = gfx.image.new("Images/position")
local widthImage = gfx.image.new("Images/width")
local timeImage = gfx.image.new("Images/time")

local moduleWidth = 34
local moduleHeight = 118

local modType = "OscillatorMod"
local modSubtype = SourceTypes.normalised_value

function OscillatorMod:init(xx, yy, modId)
	OscillatorMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	self.bgW = bgW
	self.bgH = bgH
	gfx.pushContext(backgroundImage)
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, bgH - 46)		
	gfx.popContext()
	
	self.backgroundImage = backgroundImage
		
	self:moveTo(xx, yy)
	self:add()
	
	self.component = OscillatorComponent()

	local encoderY = yy + 12
	
	self.positionEncoderVector = Vector(xx, yy - 34)
	self.positionEncoderValue = 0.5

	self.widthEncoderVector = Vector(xx, yy + 3)
	self.widthEncoderValue = 1.0

	self.frequencyEncoderVector = Vector(xx, yy + 40)
	self.frequencyEncoderValue = 0.25
	
	self.encoderVectors = {
		self.positionEncoderVector,
		self.widthEncoderVector,
		self.frequencyEncoderVector
	}

	self.socketOutVector = Vector	(xx - (moduleWidth/2)-2, yy + (moduleHeight/2) - 24)
	
	self:redrawBackground()
end

function OscillatorMod:redrawBackground()
	self.redrawPending = false
	gEncoder:hide()
	
	local backgroundImage = gfx.image.new(self.bgW, self.bgH)
	gfx.pushContext(backgroundImage)
	
	self.backgroundImage:draw(0, 0)
		
	--encoders
	positionImage:draw(24, 20)
	gEncoder:setValue(self.positionEncoderValue)
	local positionEncoderImage = gEncoder:getImage()
	positionEncoderImage:draw(21, 30)
	
	widthImage:draw(26, 56)
	gEncoder:setValue(self.widthEncoderValue)
	local widthEncoderImage = gEncoder:getImage()
	widthEncoderImage:draw(21, 67)
	
	timeImage:draw(24, 90)
	gEncoder:setValue(self.frequencyEncoderValue)
	local freqEncoderImage = gEncoder:getImage()
	freqEncoderImage:draw(21, 104)
		
	gfx.popContext()
	
	self:setImage(backgroundImage)
end

function OscillatorMod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end

	if encoderVector == self.positionEncoderVector then
		gEncoder:setValue(self.positionEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.positionEncoderVector.x, self.positionEncoderVector.y)
		gEncoder:turn(change)
		self.positionEncoderValue = gEncoder:getValue()
		self.component:setPosition(self.positionEncoderValue)
	elseif encoderVector == self.widthEncoderVector then
		gEncoder:setValue(self.widthEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.widthEncoderVector.x, self.widthEncoderVector.y)
		gEncoder:turn(change)
		self.widthEncoderValue = gEncoder:getValue()
		self.component:setWidth(self.widthEncoderValue)
	elseif encoderVector == self.frequencyEncoderVector then
		gEncoder:setValue(self.frequencyEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.frequencyEncoderVector.x, self.frequencyEncoderVector.y)
		gEncoder:turn(change)
		self.frequencyEncoderValue = gEncoder:getValue()
		self.component:setFrequency(self.frequencyEncoderValue)
	end
	
	self.redrawPending = true
end

function OscillatorMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function OscillatorMod:findClosestEncoderVector(x, y)
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

function OscillatorMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	patchCable:setHostAudioModId(self.hostAudioModId)
	self.component:setOutCable(patchCable:getCable())
end

function OscillatorMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function OscillatorMod:tryConnectGhostIn(x, y, ghostCable)
	return false
end

function OscillatorMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then 
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function OscillatorMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Oscillates between two values in the range 0.0 to 1.0. You set the centre value and the width, and the oscillation rate")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function OscillatorMod:type() return modType end
function OscillatorMod:getModId() return self.modId end
function OscillatorMod:removeChannel(channel) self.component:removeChannel(channel) end
function OscillatorMod:unplug(cableId) self.component:unplug(cableId) end
function OscillatorMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function OscillatorMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function OscillatorMod:moveFinish()
	self.positionEncoderVector = Vector(self.x, self.y - 34)
	self.widthEncoderVector = Vector(self.x, self.y + 3)
	self.frequencyEncoderVector = Vector(self.x, self.y + 40)
	self.socketOutVector = Vector	(self.x - (moduleWidth/2)-2, self.y + (moduleHeight/2) - 24)
	
	self.encoderVectors = {
		self.positionEncoderVector,
		self.widthEncoderVector,
		self.frequencyEncoderVector
	}
end

function OscillatorMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
		
	self:remove()
end

function OscillatorMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.positionEncoderValue = self.positionEncoderValue
	modState.widthEncoderValue = self.widthEncoderValue
	modState.frequencyEncoderValue = self.frequencyEncoderValue

	return modState
end

function OscillatorMod:fromState(modState)
 self.positionEncoderValue = modState.positionEncoderValue
 self.component:setPosition(self.positionEncoderValue)
 
 self.widthEncoderValue = modState.widthEncoderValue
 self.component:setWidth(self.widthEncoderValue)
 
 self.frequencyEncoderValue = modState.frequencyEncoderValue
 self.component:setFrequency(self.frequencyEncoderValue)
 
 self:redrawBackground()
end