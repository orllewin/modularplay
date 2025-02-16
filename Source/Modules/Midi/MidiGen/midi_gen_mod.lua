--[[
	© 2023 Orllewin - All Rights Reserved.
	
	Combines clock delay, blackhole, RNG, and Value-to-midi in one module - outputs midi notes.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Midi/MidiGen/midi_gen_component'

class('MidiGenMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 100
local moduleHeight = 120

local maxBlackholeSize = 48

local modType = "MidiGenMod"
local modSubtype = "midi"

local notes = {"C", "C#", "D", "E♭", "E", "F", "F#", "G", "A♭", "A", "B♭", "B"}

function MidiGenMod:init(xx, yy, modId)
	print("MidiGenMod INIT")
	MidiGenMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.major = true
	
	self.component = MidiGenComponent()
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = backgroundImage:getSize()
	self.bgW = bgW
	self.bgH = bgH
	gfx.pushContext(backgroundImage)	

	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 32)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(112, 32)
	
	gfx.drawTextAligned("High", bgW/2 + 27, 61, kTextAlignment.center)
	gfx.drawTextAligned("Low", bgW/2 + 27, 97, kTextAlignment.center)
	
	gfx.drawTextAligned("Sc.", bgW/2 - 11, 97, kTextAlignment.center)
	
	gfx.popContext()
	
	self.backgroundImage = backgroundImage
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
		
	-- Clock Div
	self.clockDivisionEncoderVector = Vector(xx - 12, yy - 33)
	self.clockDivisionEncoderValue = map(120, 1, 200, 0.0, 1.0)
	self.clockDivisionLabel = "1/8"
	self.clockDivisionIndex = -1
	
	-- Blackhole
	self.gravityEncoderVector = Vector(xx + 34, yy - 33)
	self.gravityEncoderValue = 0.5

  -- Key
	self.keyEncoderVector = Vector(xx - 4, yy + 7)
	self.keyEncoderValue = 0.5
	self.keyLabel = "C"
	
	-- High
	self.highEncoderVector = Vector(xx + 26, yy + 7)
	self.highEncoderValue = 0.45
	self.component:setHighRange(self.highEncoderValue)
	
	-- Low
	self.lowEncoderVector = Vector(xx + 26, yy + 43)
	self.lowEncoderValue = 0.25
	self.component:setLowRange(self.lowEncoderValue)
	
	--Scales
	self.scalesEncoderVector = Vector(xx - 4, yy + 43)
	self.scalesEncoderValue = 0.0
	self.component:setLowRange(self.lowEncoderValue)
	
	self.encoderVectors = {
		self.clockDivisionEncoderVector,
		self.gravityEncoderVector,
		self.keyEncoderVector,
		self.highEncoderVector,
		self.lowEncoderVector,
		self.scalesEncoderVector
	}
		
	self.socketInVector = Vector(xx - 47, yy - (moduleHeight/2) + 20)
	self.socketOutVector = Vector(xx + 53, yy - (moduleHeight/2) + 24)
	
	self:redrawBackground()
end

function MidiGenMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = gfx.image.new(self.bgW, self.bgH)
	gfx.pushContext(backgroundImage)	
	
	self.backgroundImage:draw(0, 0)
	
	-- Clock division
	gfx.drawTextAligned(self.clockDivisionLabel, 52, 22, kTextAlignment.center)
	gEncoder:setValue(self.clockDivisionEncoderValue)
	local clockDivisionEncoderImage = gEncoder:getImage()
	clockDivisionEncoderImage:draw(42, 31)
	
	-- Black hole
	local holeImage = gfx.image.new(maxBlackholeSize, maxBlackholeSize)
	gfx.pushContext(holeImage)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillCircleAtPoint(maxBlackholeSize/2, maxBlackholeSize/2, map(self.gravityEncoderValue, 0.0, 1.0, 10, maxBlackholeSize/2))
	gfx.popContext()
	
	local holeImage2 = gfx.image.new(maxBlackholeSize, maxBlackholeSize)
	gfx.pushContext(holeImage2)
	holeImage:drawFaded(0, 0, 0.3, gfx.image.kDitherTypeDiagonalLine)
	gfx.popContext()
	
	holeImage2:draw(66, 17)
	
	gEncoder:setValue(self.gravityEncoderValue)
	local gravityEncoderImage = gEncoder:getImage()
	gravityEncoderImage:draw(80, 31)
	
	-- Note/Key
	gfx.drawTextAligned(self.keyLabel, 52, 61, kTextAlignment.center)
	gEncoder:setValue(self.keyEncoderValue)
	local keyEncoderImage = gEncoder:getImage()
	keyEncoderImage:draw(42, 71)
	
	-- High range
	gEncoder:setValue(self.highEncoderValue)
	local highEncoderImage = gEncoder:getImage()
	highEncoderImage:draw(80, 71)
	
	-- Low range
	gEncoder:setValue(self.lowEncoderValue)
	local lowEncoderImage = gEncoder:getImage()
	lowEncoderImage:draw(80, 107)
	
	-- Scales
	local scaleImage = gfx.imageWithText(self.component:getScale(), 100, 10)
	scaleImage:drawRotated(30, self.bgH/2, -90)

	gEncoder:setValue(self.scalesEncoderValue)
	local scalesEncoderImage = gEncoder:getImage()
	scalesEncoderImage:draw(42, 107)
	
	

	gfx.popContext()
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function MidiGenMod:turn(x, y, change)
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
	
	if encoderVector == self.clockDivisionEncoderVector then
		gEncoder:setValue(self.clockDivisionEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.clockDivisionEncoderVector.x, self.clockDivisionEncoderVector.y)
		gEncoder:turn(change)
		self.clockDivisionEncoderValue = gEncoder:getValue()
		local division = self.component:setDivisionDelay(self.clockDivisionEncoderValue)
		if division == 1 and self.clockDivisionIndex ~= 1 then
			self.clockDivisionLabel = "None"
		elseif division == 2 and self.clockDivisionIndex ~= 2 then
			self.clockDivisionLabel = "1/1"
		elseif division == 3 and self.clockDivisionIndex ~= 3 then
			self.clockDivisionLabel = "1/2"
		elseif division == 4 and self.clockDivisionIndex ~= 4 then
			self.clockDivisionLabel = "1/4"
		elseif division == 5 and self.clockDivisionIndex ~= 5 then
			self.clockDivisionLabel = "1/8"
		elseif division == 6 and self.clockDivisionIndex ~= 6 then 
			self.clockDivisionLabel = "1/16"
		elseif division == 7 and self.clockDivisionIndex ~= 7 then 
			self.clockDivisionLabel = "1/32"
		elseif division == 8 and self.clockDivisionIndex ~= 8 then	
			self.clockDivisionLabel = "1/64"
		end	
		
		if division ~= self.clockDivisionIndex then
			self.clockDivisionIndex = division
			self:redrawBackground()
			self.redrawPending = false
		end
		
	elseif encoderVector == self.gravityEncoderVector then
		gEncoder:setValue(self.gravityEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.gravityEncoderVector.x, self.gravityEncoderVector.y)
		gEncoder:turn(change)
		self.gravityEncoderValue = gEncoder:getValue()
		self.component:setGravity(self.gravityEncoderValue)
		self:redrawBackground()
		self.redrawPending = false
	elseif encoderVector == self.keyEncoderVector then
		gEncoder:setValue(self.keyEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.keyEncoderVector.x, self.keyEncoderVector.y)
		gEncoder:turn(change)
		self.keyEncoderValue = gEncoder:getValue()
		local noteIndex = math.floor(map(self.keyEncoderValue, 0.0, 1.0, 1, #notes))
		self.keyLabel = notes[noteIndex]
		self.component:setKeyIndex(noteIndex)
		self:redrawBackground()
		self.redrawPending = false
	elseif encoderVector == self.highEncoderVector then
		gEncoder:setValue(self.highEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.highEncoderVector.x, self.highEncoderVector.y)
		gEncoder:turn(change)
		self.highEncoderValue = gEncoder:getValue()
		self.component:setHighRange(self.highEncoderValue)
	elseif encoderVector == self.lowEncoderVector then
		gEncoder:setValue(self.lowEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.lowEncoderVector.x, self.lowEncoderVector.y)
		gEncoder:turn(change)
		self.lowEncoderValue = gEncoder:getValue()
		self.component:setLowRange(self.lowEncoderValue)
	elseif encoderVector == self.scalesEncoderVector then
		gEncoder:setValue(self.scalesEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.scalesEncoderVector.x, self.scalesEncoderVector.y)
		gEncoder:turn(change)
		self.scalesEncoderValue = gEncoder:getValue()
		self.component:setScale(self.scalesEncoderValue)
		self:redrawBackground()
		self.redrawPending = false
	end
end

function MidiGenMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function MidiGenMod:findClosestEncoderVector(x, y)
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

function MidiGenMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function MidiGenMod:setOutCable(patchCable)
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function MidiGenMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function MidiGenMod:tryConnectGhostIn(x, y, ghostCable)
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

function MidiGenMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function MidiGenMod:type() return modType end

function MidiGenMod:getModId()
	return self.modId
end

function MidiGenMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	
	local actions = {}
	local scales = self.component:getScales()
	for i=1,#scales do
		local entry = {
			label = "" .. scales[i].name
		}
		table.insert(actions, entry)
	end
	
	table.insert(actions, {label="About"})
	table.insert(actions, {label="Move"})
	table.insert(actions, {label="Remove"})
	
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Emits a random value when it receives a 'bang'. Input is a clock, outputs a midi note. Top left is a clock delay with a 50% probability, top right is a blackhole, turn up for fewer notes.")
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
			--change scale
			self.component:setScaleName(action)
			self:redrawBackground()
		end

	end)
end

function MidiGenMod:unplug(cableId) self.component:unplug(cableId) end

function MidiGenMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function MidiGenMod:moveFinish()
	self.clockDivisionEncoderVector = Vector(self.x - 12, self.y - 33)
	self.gravityEncoderVector = Vector(self.x + 34, self.y - 33)
	self.keyEncoderVector = Vector(self.x - 4, self.y + 7)
	self.highEncoderVector = Vector(self.x + 26, self.y + 7)
	self.lowEncoderVector = Vector(self.x + 26, self.y + 43)
	self.scalesEncoderVector = Vector(self.x - 4, self.y + 43)

	self.encoderVectors = {
		self.clockDivisionEncoderVector,
		self.gravityEncoderVector,
		self.keyEncoderVector,
		self.highEncoderVector,
		self.lowEncoderVector,
		self.scalesEncoderVector
	}
		
	self.socketInVector = Vector(self.x - 47, self.y - (moduleHeight/2) + 20)
	self.socketOutVector = Vector(self.x + 53, self.y - (moduleHeight/2) + 24)
end


function MidiGenMod:evaporate(onDetachConnected)
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

function MidiGenMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function MidiGenMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.clockDivisionEncoderValue = self.clockDivisionEncoderValue
	modState.gravityEncoderValue = self.gravityEncoderValue
	modState.keyEncoderValue = self.keyEncoderValue
	modState.highEncoderValue = self.highEncoderValue
	modState.lowEncoderValue = self.lowEncoderValue
	modState.scalesEncoderValue = self.scalesEncoderValue
	
	return modState
end


function MidiGenMod:fromState(modState)
	self.clockDivisionEncoderValue = modState.clockDivisionEncoderValue 
  self.gravityEncoderValue = modState.gravityEncoderValue
	self.keyEncoderValue = modState.keyEncoderValue
  self.highEncoderValue = modState.highEncoderValue
  self.lowEncoderValue = modState.lowEncoderValue
	self.scalesEncoderValue = modState.scalesEncoderValue
	
	local division = self.component:setDivisionDelay(self.clockDivisionEncoderValue)
	if division == 1 and self.clockDivisionIndex ~= 1 then
		self.clockDivisionLabel = "1/1"
	elseif division == 2 and self.clockDivisionIndex ~= 2 then
		self.clockDivisionLabel = "1/2"
	elseif division == 3 and self.clockDivisionIndex ~= 3 then
		self.clockDivisionLabel = "1/4"
	elseif division == 4 and self.clockDivisionIndex ~= 4 then
		self.clockDivisionLabel = "1/8"
	elseif division == 5 and self.clockDivisionIndex ~= 5 then 
		self.clockDivisionLabel = "1/16"
	elseif division == 6 and self.clockDivisionIndex ~= 6 then 
		self.clockDivisionLabel = "1/32"
	elseif division == 7 and self.clockDivisionIndex ~= 7 then	
		self.clockDivisionLabel = "1/64"
	end	
	
	self.component:setGravity(self.gravityEncoderValue)
	self.component:setHighRange(self.highEncoderValue)
	self.component:setLowRange(self.lowEncoderValue)
	
	local noteIndex = math.floor(map(self.keyEncoderValue, 0.0, 1.0, 1, #notes))
	self.keyLabel = notes[noteIndex]
	self.component:setKeyIndex(noteIndex)
	
	self.component:setScale(self.scalesEncoderValue)
	
	self:redrawBackground()
	
end