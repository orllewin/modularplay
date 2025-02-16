--[[
	© 2023 Orllewin - All Rights Reserved.
	
	Combines clock delay, blackhole, RNG, and Value-to-midi in one module - outputs midi notes.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Midi/MidiGenBouncyBall/midi_gen_bouncy_ball_component'

class('MidiGenBouncyBallMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 100
local moduleHeight = 220

local maxBlackholeSize = 48

local modType = "MidiGenBouncyBallMod"
local modSubtype = "midi"

local notes = {"C", "C#", "D", "E♭", "E", "F", "F#", "G", "A♭", "A", "B♭", "B"}

function MidiGenBouncyBallMod:init(xx, yy, modId)
	print("MidiGenBouncyBallMod INIT")
	MidiGenBouncyBallMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.major = true
	
	self.component = MidiGenBouncyBallComponent()
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = backgroundImage:getSize()
	self.bgW = bgW
	self.bgH = bgH
	gfx.pushContext(backgroundImage)	
	
	local brownianBackgroundImage = gfx.image.new("Images/brownian_background")
	brownianBackgroundImage:draw(15, 14)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(112, 132)
	
	gfx.drawTextAligned("Vel", bgW/2 + 10, 120, kTextAlignment.center)
	
	gfx.drawTextAligned("High", bgW/2 + 27, 161, kTextAlignment.center)
	gfx.drawTextAligned("Low", bgW/2 + 27, 197, kTextAlignment.center)
	
	gfx.drawTextAligned("Sc.", bgW/2 - 11, 197, kTextAlignment.center)
	
	gfx.popContext()
	
	self.backgroundImage = backgroundImage
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()

  --speed
  self.velocityEncoderVector = Vector(xx + 10, yy + 17)
  self.velocityEncoderValue = 0.25
	
  -- Key
	self.keyEncoderVector = Vector(xx - 4, yy + 57)
	self.keyEncoderValue = 0.5
	self.keyLabel = "C"
	
	-- High
	self.highEncoderVector = Vector(xx + 26, yy + 57)
	self.highEncoderValue = 0.45
	self.component:setHighRange(self.highEncoderValue)
	
	-- Low
	self.lowEncoderVector = Vector(xx + 26, yy + 93)
	self.lowEncoderValue = 0.25
	self.component:setLowRange(self.lowEncoderValue)
	
	--Scales
	self.scalesEncoderVector = Vector(xx - 4, yy + 93)
	self.scalesEncoderValue = 0.0
	self.component:setLowRange(self.lowEncoderValue)
	
	self.encoderVectors = {
		self.velocityEncoderVector,
		self.keyEncoderVector,
		self.highEncoderVector,
		self.lowEncoderVector,
		self.scalesEncoderVector
	}
		
	self.socketOutVector = Vector(xx + 53, yy - (moduleHeight/2) + 124)
	
	--balls
	self.ballVelocity = map(self.velocityEncoderValue, 0.0, 1.0, 0.0, 6.0)
	
	self:redrawBackground()
	
	self.molecules = {}
	
	self.moleculeImage = assets:image("brownian_molecule")
	local molecule1Sprite = gfx.sprite.new(self.moleculeImage)
	local molecule1X = math.random(-40, 40)
	local molecule1Y = math.random(-40, 40)
	molecule1Sprite:moveTo(self.x + molecule1X, self.y + molecule1Y)
	molecule1Sprite:add()
	
	table.insert(self.molecules, {
		location = Vector(molecule1X, molecule1Y),
		direction = Vector(math.random(), math.random()),
		sprite = molecule1Sprite
	})
		
	self.spriteUpdateTimer = playdate.timer.new(500)
	self.spriteUpdateTimer.repeats = true
	self.spriteUpdateTimer.updateCallback = function()
		 for i=1,#self.molecules do
			
			local molecule = self.molecules[i]
			molecule.location.x = molecule.location.x + (self.ballVelocity * molecule.direction.x)
			molecule.location.y = molecule.location.y + (self.ballVelocity * molecule.direction.y)
			
			if molecule.location.x >= 43 then
				molecule.direction.x = molecule.direction.x * -1
				self.component:emitNote(molecule.location.x, molecule.location.y)
			elseif molecule.location.x <= -45 then
				molecule.direction.x = molecule.direction.x * -1
				self.component:emitNote(molecule.location.x, molecule.location.y)
			end
			
			if molecule.location.y >= 39 then
				molecule.direction.y = molecule.direction.y * -1
				self.component:emitNote(molecule.location.x, molecule.location.y)
			elseif molecule.location.y <= -45 then
				molecule.direction.y = molecule.direction.y * -1
				self.component:emitNote(molecule.location.x, molecule.location.y)
			end
			
			molecule.sprite:moveTo(self.x + molecule.location.x, self.y + molecule.location.y - 58)
		 end
	end
end

function MidiGenBouncyBallMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = gfx.image.new(self.bgW, self.bgH)
	gfx.pushContext(backgroundImage)	
	
	self.backgroundImage:draw(0, 0)
	
	--Velocity
	gEncoder:setValue(self.velocityEncoderValue)
	local velocityEncoderImage = gEncoder:getImage()
	velocityEncoderImage:draw(self.bgW/2, 131)

	-- Note/Key
	gfx.drawTextAligned(self.keyLabel, 52, 161, kTextAlignment.center)
	gEncoder:setValue(self.keyEncoderValue)
	local keyEncoderImage = gEncoder:getImage()
	keyEncoderImage:draw(42, 171)
	
	-- High range
	gEncoder:setValue(self.highEncoderValue)
	local highEncoderImage = gEncoder:getImage()
	highEncoderImage:draw(80, 171)
	
	-- Low range
	gEncoder:setValue(self.lowEncoderValue)
	local lowEncoderImage = gEncoder:getImage()
	lowEncoderImage:draw(80, 207)
	
	-- Scales
	local scaleImage = gfx.imageWithText(self.component:getScale(), 200, 10)
	local rotatedScaleImage = scaleImage:rotatedImage(-90)
	local ww, hh = rotatedScaleImage:getSize()
	rotatedScaleImage:draw(24, self.bgH - (hh + 24))

	gEncoder:setValue(self.scalesEncoderValue)
	local scalesEncoderImage = gEncoder:getImage()
	scalesEncoderImage:draw(42, 207)
	
	gfx.popContext()
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function MidiGenBouncyBallMod:turn(x, y, change)
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
	
	if encoderVector == self.velocityEncoderVector then
		gEncoder:setValue(self.velocityEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.velocityEncoderVector.x, self.velocityEncoderVector.y)
		gEncoder:turn(change)
		self.velocityEncoderValue = gEncoder:getValue()
		self.ballVelocity = map(self.velocityEncoderValue, 0.0, 1.0, 0.0, 6.0)
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

function MidiGenBouncyBallMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function MidiGenBouncyBallMod:findClosestEncoderVector(x, y)
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

function MidiGenBouncyBallMod:setOutCable(patchCable)
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function MidiGenBouncyBallMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function MidiGenBouncyBallMod:tryConnectGhostIn(x, y, ghostCable)
	return false
end

function MidiGenBouncyBallMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function MidiGenBouncyBallMod:type() return modType end

function MidiGenBouncyBallMod:getModId()
	return self.modId
end

function MidiGenBouncyBallMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	
	local actions = {
		{
			label = "Add Ball"
		},
		{
			label = "Remove Ball"
		}
	}
	
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
		if action == "Add Ball" then
			local moleculeSprite = gfx.sprite.new(self.moleculeImage)
			local moleculeX = math.random(-30, 30)
			local moleculeY = math.random(-30, 30)
			moleculeSprite:moveTo(self.x + moleculeX, self.y + moleculeY)
			moleculeSprite:add()
			
			table.insert(self.molecules, {
				location = Vector(moleculeX, moleculeY),
				direction = Vector(math.random(), math.random()),
				sprite = moleculeSprite
			})
		elseif action == "Remove Ball" then
			if #self.molecules > 0 then
				self.molecules[#self.molecules].sprite:remove()
				table.remove(self.molecules, #self.molecules)
			end
		elseif action == "About" then
			local aboutPopup = ModAboutPopup("New and experimental (and possibly buggy), add balls that bounce around a box, when they hit a wall a midi note is emitted.")
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

function MidiGenBouncyBallMod:unplug(cableId) self.component:unplug(cableId) end

function MidiGenBouncyBallMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function MidiGenBouncyBallMod:moveFinish()
	self.velocityEncoderVector = Vector(self.x, yy + 17)
	self.keyEncoderVector = Vector(self.x - 4, self.y + 7)
	self.highEncoderVector = Vector(self.x + 26, self.y + 7)
	self.lowEncoderVector = Vector(self.x + 26, self.y + 43)
	self.scalesEncoderVector = Vector(self.x - 4, self.y + 43)

	self.encoderVectors = {
		self.velocityEncoderVector,
		self.keyEncoderVector,
		self.highEncoderVector,
		self.lowEncoderVector,
		self.scalesEncoderVector
	}
		
	self.socketInVector = Vector(self.x - 47, self.y - (moduleHeight/2) + 20)
	self.socketOutVector = Vector(self.x + 53, self.y - (moduleHeight/2) + 24)
end


function MidiGenBouncyBallMod:evaporate(onDetachConnected)	
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
	
	self.spriteUpdateTimer:remove()
	
	for i=1,#self.molecules do
		self.molecules[i].sprite:remove()
	end
	
	self:remove()
end

function MidiGenBouncyBallMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function MidiGenBouncyBallMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y

	modState.velocityEncoderValue = self.velocityEncoderValue
	modState.keyEncoderValue = self.keyEncoderValue
	modState.highEncoderValue = self.highEncoderValue
	modState.lowEncoderValue = self.lowEncoderValue
	modState.scalesEncoderValue = self.scalesEncoderValue
	
	return modState
end


function MidiGenBouncyBallMod:fromState(modState)
	self.velocityEncoderValue = modState.velocityEncoderValue
	self.ballVelocity = map(self.velocityEncoderValue, 0.0, 1.0, 0.0, 6.0)
	
	self.keyEncoderValue = modState.keyEncoderValue
  self.highEncoderValue = modState.highEncoderValue
  self.lowEncoderValue = modState.lowEncoderValue
	self.scalesEncoderValue = modState.scalesEncoderValue
	
	self.component:setHighRange(self.highEncoderValue)
	self.component:setLowRange(self.lowEncoderValue)
	
	local noteIndex = math.floor(map(self.keyEncoderValue, 0.0, 1.0, 1, #notes))
	self.keyLabel = notes[noteIndex]
	self.component:setKeyIndex(noteIndex)
	
	self.component:setScale(self.scalesEncoderValue)
	
	self:redrawBackground()
	
end