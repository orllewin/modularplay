
--[[
	© 2023 Orllewin - All Rights Reserved.

	https://www.musicradar.com/reviews/cyclone-analogic-tt-606
]]

import 'Modules/Sprites/sequencer_steps'
import 'Modules/Drums/OR606/or606_component'

class('OR606Mod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 280
local moduleHeight = 125

local modType = "OR606Mod"
local modSubtype = "audio_gen"

local drumSelector = gfx.image.new("Images/drum_selector")
local patternLengthSelector = gfx.image.new("Images/pattern_length_selector")
local drumLabels = {"Bass Drum", "Snare Drum", "Low Tom", "High Tom", "Cymbal", "Open Hat", "Closed Hat"}

function OR606Mod:init(xx, yy, modId, onInit)
	OR606Mod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.onInit = onInit
	
	self.modType = modType
	self.modSubtype = modSubtype
	self.selectedDrumIndex = 1
	self.selectedDrumLabel = drumLabels[1]
	
	self.component = OR606Component(function(channel)
		if self.onInit ~= nil then self.onInit(self.modId, channel) end
	end)
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	self.bgW = bgW
	self.bgH = bgH
	gfx.pushContext(backgroundImage)
	gfx.drawText("Orllewin", 40, 23)
	gfx.drawText("Drumatix", 222, 42)
	local bigFont = assets:bigFont()
	bigFont:drawText("OR-606", 115, 60)
	drumSelector:draw(20, 55)
	patternLengthSelector:draw(215, 55)
	local smallSocket = assets:image("small_socket")
	smallSocket:draw(20, 20)
	smallSocket:draw(272, 20)
	gfx.popContext()
	
	self.backgroundImage = backgroundImage
	
	self:moveTo(xx, yy)
	self:add()
	
	self.steps = SequencerSteps(xx, yy + (moduleHeight/2) - 22, function(pattern)
		print("Set pattern: " .. self.selectedDrumIndex)
		--printTable(pattern)
		self.component:setPattern(self.selectedDrumIndex, pattern)
	end)
		
	self.drumSelectEncoderVector = Vector(xx - (moduleWidth/2) + 45, yy + 4)
	self.drumSelectEncoderValue = 0.0
	
	self.patternLengthEncoderVector = Vector(xx + (moduleWidth/2) - 45, yy + 4)
	self.patternLengthEncoderValue = 0.0
		
	self.encoderVectors = {
		self.drumSelectEncoderVector,
		self.patternLengthEncoderVector
	}
	
	self.socketInVector = Vector(xx - (moduleWidth/2) +14, yy - (moduleHeight/2) + 15)
	self.socketOutVector = Vector(xx + (moduleWidth/2) - 16, yy - (moduleHeight/2) + 15)
	
	self:redrawBackground()
end

function OR606Mod:unplug(cableId)
	if self.component:inConnected() and self.inCable:getCableId() == cableId then
		 self.component:unplugIn()
		 self.inCable = nil
	end
	
	if self.component:outConnected() and "" .. self.outCable:getCableId() == "" .. cableId then
		 self.component:unplugOut()
		self.outCable = nil
	end
end

function OR606Mod:repositionBy(x, y)
	self:moveBy(x, y)
	self.steps:repositionBy(x, y)
end

function OR606Mod:moveFinish()	
	self.steps:moveFinish()	
	self.socketInVector = Vector(self.x - (moduleWidth/2) +16, self.y - (moduleHeight/2) + 20)
	self.socketOutVector = Vector(self.x + (moduleWidth/2) - 16, self.y - (moduleHeight/2) + 20)
	self.drumSelectEncoderVector = Vector(self.x - (moduleWidth/2) + 45, self.y + 4)
	self.patternLengthEncoderVector = Vector(self.x + (moduleWidth/2) - 45, self.y + 4)
	
	self.encoderVectors = {
		self.drumSelectEncoderVector,
		self.patternLengthEncoderVector
	}
end

function OR606Mod:evaporate(onDetachConnected)
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
	
	--stop drum machine playing, free up resources:
	self.component:stopAll()
	self.component:removeSources()
	
	self.steps:remove()
	self.steps = nil
	self:remove()
end

function OR606Mod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = gfx.image.new(self.bgW, self.bgH)
	gfx.pushContext(backgroundImage)	
	self.backgroundImage:draw(0, 0)
	
	--drum select
	gEncoder:setValue(self.drumSelectEncoderValue)
	local drumSelectEncoderImage = gEncoder:getImage()
	drumSelectEncoderImage:draw(49, 71)
	
	--pattern length
	gEncoder:setValue(self.patternLengthEncoderValue)
	local patternLengthEncoderImage = gEncoder:getImage()
	patternLengthEncoderImage:draw(239, 71)
	
	gfx.drawTextAligned(self.selectedDrumLabel, self.bgW/2, 90, kTextAlignment.center)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function OR606Mod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end
	
	self.redrawPending = true
	
	if encoderVector == self.drumSelectEncoderVector then
		gEncoder:setValue(self.drumSelectEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.drumSelectEncoderVector.x, self.drumSelectEncoderVector.y)
		gEncoder:turn(change)
		self.drumSelectEncoderValue = gEncoder:getValue()
		self.selectedDrumIndex = math.floor(map(self.drumSelectEncoderValue, 0.0, 1.0, 1, 7))
		local drumLabel = drumLabels[self.selectedDrumIndex]
		if drumLabel ~= self.selectedDrumLabel then
			self.selectedDrumLabel = drumLabel
			self:redrawBackground()
			self.redrawPending = false
		end
		self.steps:setPattern(self.component:getPattern(self.selectedDrumIndex), self.component:getPatternLength(self.selectedDrumIndex))
	elseif encoderVector == self.patternLengthEncoderVector then
		gEncoder:setValue(self.patternLengthEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.patternLengthEncoderVector.x, self.patternLengthEncoderVector.y)
		gEncoder:turn(change)
		self.patternLengthEncoderValue = gEncoder:getValue()
		local stepLengthIndex = math.floor(map(self.patternLengthEncoderValue, 0.0, 1.0, 1, 5))
		self.component:setPatternLength(self.selectedDrumIndex, stepLengthIndex * 16)
		self.steps:setPattern(self.component:getPattern(self.selectedDrumIndex), self.component:getPatternLength(self.selectedDrumIndex))
	end
	
	
end

function OR606Mod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function OR606Mod:findClosestEncoderVector(x, y)
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

function OR606Mod:type()
	return modType
end

function OR606Mod:getModId()
	return self.modId
end

function OR606Mod:handleModClick(tX, tY, listener)
	if self.steps:collision(tX, tY) then
		self.steps:onClick(tX, tY, function(pattern)
			--todo Update pattern!
			
		end)
	else
		self.menuListener = listener
		local actions = {
			{label = "About"},
			{label = "Move"},
			{label = "Remove"}
		}
		local contextMenu = ModuleMenu(actions)
		contextMenu:show(function(action) 
			if action == "About" then
				local aboutPopup = ModAboutPopup("A clone of the Roland TR-606")
				aboutPopup:show()
			else
				if self.menuListener ~= nil then 
					self.menuListener(action) 
				end
			end
	
		end)
	end
end

function OR606Mod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function OR606Mod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function OR606Mod:tryConnectGhostIn(x, y, ghostCable)
	if ghostCable:getStartModId() == self.modId then
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

function OR606Mod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function OR606Mod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function OR606Mod:setOutCable(patchCable)
	patchCable:setEnd(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function OR606Mod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.pattern1Length = self.component:getPatternLength(1)
	modState.pattern1 = self.component:getPattern(1)
	
	modState.pattern2Length = self.component:getPatternLength(2)
	modState.pattern2 = self.component:getPattern(2)
	
	modState.pattern3Length = self.component:getPatternLength(3)
	modState.pattern3 = self.component:getPattern(3)
	
	modState.pattern4Length = self.component:getPatternLength(4)
	modState.pattern4 = self.component:getPattern(4)
	
	modState.pattern5Length = self.component:getPatternLength(5)
	modState.pattern5 = self.component:getPattern(5)
	
	modState.pattern6Length = self.component:getPatternLength(6)
	modState.pattern6 = self.component:getPattern(6)
	
	modState.pattern7Length = self.component:getPatternLength(7)
	modState.pattern7 = self.component:getPattern(7)
	
	--todo - encoder values
	modState.drumSelectEncoderValue = self.drumSelectEncoderValue
	modState.patternLengthEncoderValue  = self.patternLengthEncoderValue 
	
	modState.selectedDrumIndex = self.selectedDrumIndex
		
	return modState
end

function OR606Mod:fromState(modState)
	self.component:setPatternLength(1, modState.pattern1Length)
	self.component:setPattern(1, modState.pattern1)
	
	self.component:setPatternLength(2, modState.pattern2Length)
	self.component:setPattern(2, modState.pattern2)
	
	self.component:setPatternLength(3, modState.pattern3Length)
	self.component:setPattern(3, modState.pattern3)
	
	self.component:setPatternLength(4, modState.pattern4Length)
	self.component:setPattern(4, modState.pattern4)
	
	self.component:setPatternLength(5, modState.pattern5Length)
	self.component:setPattern(5, modState.pattern5)
	
	self.component:setPatternLength(6, modState.pattern6Length)
	self.component:setPattern(6, modState.pattern6)
	
	self.component:setPatternLength(7, modState.pattern7Length)
	self.component:setPattern(7, modState.pattern7)
	
	self.drumSelectEncoderValue = modState.drumSelectEncoderValue
  self.patternLengthEncoderValue = modState.patternLengthEncoderValue
	
	self.selectedDrumIndex = modState.selectedDrumIndex
	self.selectedDrumLabel = drumLabels[self.selectedDrumIndex]

	self.steps:setPattern(self.component:getPattern(self.selectedDrumIndex), self.component:getPatternLength(self.selectedDrumIndex))
	
	self:redrawBackground()
end