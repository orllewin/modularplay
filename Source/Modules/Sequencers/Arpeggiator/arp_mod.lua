--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Sequencers/Arpeggiator/arp_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Modules/Sprites/sequencer_grid'

class('ArpMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 295
local moduleHeight = 218

local modType = "ArpMod"
local modSubtype = "midi"

local patternLengthSelector = gfx.image.new("Images/pattern_length_selector")
local backplate = gfx.image.new("images/seq_controls_backplate")

function ArpMod:init(xx, yy, modId)
	ArpMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = self.backgroundImage:getSize()
	self.bgW = bgW
	self.bgH = bgH
	
	gfx.pushContext(self.backgroundImage)		
	
	local smallSocket = assets:image("small_socket")
	smallSocket:draw(23, bgH - 50)
	smallSocket:draw(bgW - 43, bgH - 50)
	patternLengthSelector:draw(200, 176)
	backplate:draw(58, 166)
	
	local prevImage = gfx.image.new("Images/sq_pattern_prev_inactive")
	prevImage:draw(18, 20)
	
	local nextImage = gfx.image.new("Images/sq_pattern_next_inactive")
	nextImage:draw(290, 20)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.component = ArpComponent()
	
	self.grid = SequencerGrid(xx, yy-30, function(pattern)
		self.component:setPattern(pattern)
	end)


	self.socketInVector = Vector(xx - (bgW/2) + 38, yy + (bgH/2) - 38)
	self.socketOutVector = Vector(xx + (bgW/2) - 38, yy + (bgH/2)- 38)

	-- self.rateEncoder = RotaryEncoder(xx - (moduleWidth/2) + 75, yy + 80, function(value)
	-- 	--1/1, 1/2, 1/4, etc take logic from Clock Delay
	-- 	local degrees = map(value, 0.0, 1.0, 0, 300)
	-- 	local rateIndex = math.max(1, math.floor((degrees/(300/3) + 0.5)))
	-- 	self.component:setRate(rateIndex - 3)
	-- end)
	-- self.rateEncoder:setValue(1.0)
	self.rateEncoderVector = Vector(xx - (moduleWidth/2) + 75, yy + 80)
	self.rateEncoderValue = 1.0
	
	-- self.octaveEncoder = RotaryEncoder(xx, yy + 80, function(value)
	-- 	local degrees = map(value, 0.0, 1.0, 0, 300)
	-- 	local octaveIndex = math.max(1, math.floor((degrees/(300/5) + 0.5)))
	-- 	self.component:setOctave(math.floor(map(octaveIndex, 1, 5, -2, 2)))
	-- end)
	-- self.octaveEncoder:setValue(0.5)
	self.octaveEncoderVector = Vector(xx, yy + 80)
	self.octaveEncoderValue = 0.5
	
	-- self.stepCountEncoder = RotaryEncoder(xx + (moduleWidth/2) - 75, yy + 80, function(value)
	-- 	local degrees = map(value, 0.0, 1.0, 0, 300)
	-- 	local stepLengthIndex = math.max(1, math.floor((degrees/(300/5) + 0.5)))
	-- 	self.component:setPatternLength(stepLengthIndex * 16)
	-- 	self.grid:setPattern(self.component:getPattern(), self.component:getPatternLength())
	-- end)
	-- self.stepCountEncoder:setValue(0.0)
	self.stepEncoderVector = Vector(xx + (moduleWidth/2) - 75, yy + 80)
	self.stepEncoderValue = 0.0
	
	self.encoderVectors = {
		self.rateEncoderVector,
		self.octaveEncoderVector,
		self.stepEncoderVector
	}
	
	self:redrawBackground()
end

function ArpMod:redrawBackground()
	self.redrawPending = false
	gEncoder:hide()
	local backgroundImage = gfx.image.new(self.bgW, self.bgH)
	gfx.pushContext(backgroundImage)
	self.backgroundImage:draw(0, 0)
	
	local encoderY = self.bgH/2 + 70
	--rate encoder
	gEncoder:setValue(self.rateEncoderValue)
	local rateEncoderImage = gEncoder:getImage()
	rateEncoderImage:draw(79, encoderY)
	
	--octave encoder
	gEncoder:setValue(self.octaveEncoderValue)
	local octaveEncoderImage = gEncoder:getImage()
	octaveEncoderImage:draw(151, encoderY)
	
	--step encoder
	gEncoder:setValue(self.stepEncoderValue)
	local stepEncoderImage = gEncoder:getImage()
	stepEncoderImage:draw(224, encoderY)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
end

function ArpMod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end
	
	if encoderVector == self.rateEncoderVector then
		gEncoder:setValue(self.rateEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.rateEncoderVector.x, self.rateEncoderVector.y)
		gEncoder:turn(change)
		self.rateEncoderValue = gEncoder:getValue()
		-- 	--1/1, 1/2, 1/4, etc take logic from Clock Delay
		local degrees = map(self.rateEncoderValue, 0.0, 1.0, 0, 300)
		local rateIndex = math.max(1, math.floor((degrees/(300/3) + 0.5)))
		self.component:setRate(rateIndex - 3)
	elseif encoderVector == self.octaveEncoderVector then
		gEncoder:setValue(self.octaveEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.octaveEncoderVector.x, self.octaveEncoderVector.y)
		gEncoder:turn(change)
		self.octaveEncoderValue = gEncoder:getValue()
		local degrees = map(self.octaveEncoderValue, 0.0, 1.0, 0, 300)
		local octaveIndex = math.max(1, math.floor((degrees/(300/5) + 0.5)))
		self.component:setOctave(math.floor(map(octaveIndex, 1, 5, -2, 2)))
	elseif encoderVector == self.stepEncoderVector then
		gEncoder:setValue(self.stepEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.stepEncoderVector.x, self.stepEncoderVector.y)
		gEncoder:turn(change)
		self.stepEncoderValue = gEncoder:getValue()
		local degrees = map(self.stepEncoderValue, 0.0, 1.0, 0, 300)
		local stepLengthIndex = math.max(1, math.floor((degrees/(300/5) + 0.5)))
		self.component:setPatternLength(stepLengthIndex * 16)
		self.grid:setPattern(self.component:getPattern(), self.component:getPatternLength())
	end
	
	self.redrawPending = true
end

function ArpMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function ArpMod:findClosestEncoderVector(x, y)
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

function ArpMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function ArpMod:type()
	return modType
end

function ArpMod:getModId()
	return self.modId
end

function ArpMod:unplug(cableId)
	if self.component:inConnected() and cableId == self.inCable:getCableId() then
		self.component:unplugIn()
		self.inCable = nil
	end
	if self.component:outConnected() and cableId == self.outCable:getCableId() then
		 self.component:unplugOut()
		 self.outCable = nil
	end
end

function ArpMod:handleModClick(tX, tY, listener)
	if self.grid:collision(tX, tY) then
		self.grid:onClick(tX, tY, function(pattern)
			--todo Update pattern!
			
		end)
		
	elseif tY < (self.y + 40) then
			if tX < self.x then
				self.grid:prevPage()
			elseif tX > self.x then
				self.grid:nextPage()
			end
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
				local aboutPopup = ModAboutPopup("A step sequencer")
				aboutPopup:show()
			else
				if self.menuListener ~= nil then 
					self.menuListener(action) 
				end
			end
		end)
	end
end

function ArpMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function ArpMod:tryConnectGhostIn(x, y, ghostCable)
	if ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.component:outConnected() then
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function ArpMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function ArpMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function ArpMod:setOutCable(patchCable)
	patchCable:setEnd(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function ArpMod:repositionBy(x, y)
	self:moveBy(x, y)
	self.grid:repositionBy(x, y)
end

function ArpMod:moveFinish()
	self.socketInVector = Vector(self.x - (self.bgW/2) + 38, self.y + (self.bgH/2) - 38)
	self.socketOutVector = Vector(self.x + (self.bgW/2) - 38, self.y + (self.bgH/2)- 38)
	
	self.rateEncoderVector = Vector(self.x - (moduleWidth/2) + 75, self.y + 80)
	self.octaveEncoderVector = Vector(self.x, self.y + 80)
	self.stepEncoderVector = Vector(self.x + (moduleWidth/2) - 75, self.y + 80)
			
	self.encoderVectors = {
		self.rateEncoderVector,
		self.octaveEncoderVector,
		self.stepEncoderVector 
	}
end

function ArpMod:evaporate(onDetachConnected)
	
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
	
	self:remove()
	self.grid:remove()
	self.grid = nil
end


function ArpMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	local pattern = self.component:getPattern()
	modState.pattern = pattern

	return modState
end

function ArpMod:fromState(modState)
	self.component:setPattern(modState.pattern)
	self.grid:setPattern(modState.pattern, math.floor(#modState.pattern/16))
end

