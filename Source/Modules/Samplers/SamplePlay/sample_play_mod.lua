--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Samplers/SamplePlay/sample_play_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'

class('SamplePlayMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 110
local moduleHeight = 80

local modType = "SamplePlayMod"
local modSubtype = "audio_gen"

function SamplePlayMod:init(xx, yy, modId, onInit)
	SamplePlayMod.super.init(self)
	
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
	
	local icn = gfx.image.new("Images/sampler_icon")
	icn:draw(73, 56)
	
	local uiBg = gfx.image.new("Images/sample_player_ui_bg")
	uiBg:draw(23, 23)
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 32)
	leftSocket:draw(10, 65)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(123, 65)
	
	gfx.drawText("S", 30, 78)
	gfx.drawText("E", 58, 78)
	gfx.drawText("P", 100, 78)
		
	gfx.popContext()
	
	self.backgroundImage = backgroundImage
	
	self:moveTo(xx, yy)
	self:add()
	
	self.component = SamplePlayComponent(function(channel)
		self.onInit(self.modId, channel)
	end)
	
	local eY = yy+ 11
	
	self.loopStartEncoderVector = Vector(xx - 34, eY)
	self.loopStartEncoderValue = 0.0
	
	self.loopEndEncoderVector = Vector(xx - 20, eY)
	self.loopEndEncoderValue = 1.0
	
	self.samplePitchEncoderVector = Vector(xx + 34, eY)
	self.samplePitchEncoderValue = 0.5
	
	self.encoderVectors = {
		self.samplePitchEncoderVector,
		self.loopStartEncoderVector,
		self.loopEndEncoderVector
	}
	
	self.pedalInVector = Vector(xx - (moduleWidth/2)-2, yy - 20)
	self.noteInVector = Vector(xx - (moduleWidth/2)-2, yy + 17)
	self.socketOutVector = Vector	(xx + (moduleWidth/2)+2, yy + 17)

	self.inSocketVectors = {
		self.pedalInVector,
		self.noteInVector
	}
	
	self:redrawBackground()
end

function SamplePlayMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function SamplePlayMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = self.backgroundImage:getSize()

	gfx.pushContext(backgroundImage)
	
	self.backgroundImage:draw(0, 0)
	
	local sX = 23
	local eX = 113
	local len = 100
	
	local minY = 23
	local maxY = 47
	
	gEncoder:setValue(self.loopStartEncoderValue)
	local loopStartEncoderImage = gEncoder:getImage()
	loopStartEncoderImage:draw(24, 55)
	gfx.drawLine(sX + (self.loopStartEncoderValue * 100), minY+3, sX + (self.loopStartEncoderValue * 100), maxY-3)
	
	gEncoder:setValue(self.loopEndEncoderValue)
	local loopEndEncoderImage = gEncoder:getImage()
	loopEndEncoderImage:draw(52, 55)
	gfx.drawLine(eX - ((1.0-self.loopEndEncoderValue)*100), minY+3, eX - ((1.0-self.loopEndEncoderValue)*100), maxY-3)
	
	gEncoder:setValue(self.samplePitchEncoderValue)
	local samplePitchEncoderImage = gEncoder:getImage()
	samplePitchEncoderImage:draw(93, 55)
	
	local pY = minY + map(self.samplePitchEncoderValue, 0.0, 1.0, 0.0, maxY - minY)
	gfx.drawLine(sX, pY, eX, pY)
	

	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function SamplePlayMod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end
	
	if encoderVector == self.samplePitchEncoderVector then
		gEncoder:setValue(self.samplePitchEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.samplePitchEncoderVector.x, self.samplePitchEncoderVector.y)
		gEncoder:turn(change)
		self.samplePitchEncoderValue = gEncoder:getValue()
		self.component:setSamplePitch(self.samplePitchEncoderValue)
	elseif encoderVector == self.loopStartEncoderVector then
		gEncoder:setValue(self.loopStartEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.loopStartEncoderVector.x, self.loopStartEncoderVector.y)
		gEncoder:turn(change)
		self.loopStartEncoderValue = gEncoder:getValue()
		self.component:setSampleStart(self.loopStartEncoderValue)
	elseif encoderVector == self.loopEndEncoderVector then
		gEncoder:setValue(self.loopEndEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.loopEndEncoderVector.x, self.loopEndEncoderVector.y)
		gEncoder:turn(change)
		self.loopEndEncoderValue = gEncoder:getValue()
		self.component:setSampleEnd(self.loopEndEncoderValue)
	end
	self:redrawBackground()
	self.redrawPending = false
end

function SamplePlayMod:findClosestEncoderVector(x, y)
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


function SamplePlayMod:setInCable(patchCable)
	local closestInVector = self:findClosestInVector(patchCable:getEndX(), patchCable:getEndY())
	
	if closestInVector == self.pedalInVector then
		patchCable:setEnd(self.pedalInVector.x, self.pedalInVector.y, self.modId)
		self.pedalInCable = patchCable
		self.component:setPedalInCable(patchCable:getCable())
	elseif closestInVector == self.noteInVector then
		patchCable:setEnd(self.noteInVector.x, self.noteInVector.y, self.modId)
		self.noteInCable = patchCable
		self.component:setNoteInCable(patchCable:getCable())
	end
end

function SamplePlayMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function SamplePlayMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function SamplePlayMod:findClosestInVector(x, y)
	print("Recticle x: " .. x .. " y: " .. y)
	local reticleVector = Vector(x, y)
	local closestDistance = 1000
	local closestIndex = -1
	for i=1,#self.inSocketVectors do
		local aSocketVector = self.inSocketVectors[i]
		local distance = reticleVector:distance(aSocketVector)
		if distance < closestDistance then
			closestDistance = distance
			closestIndex = i
		end
	end
	return self.inSocketVectors[closestIndex]
end

function SamplePlayMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype, onError)
	local closestInVector = self:findClosestInVector(x, y)
	
	if closestInVector == self.pedalInVector then
		if sourceSubtype ~= "clock_router" then
			if onError ~= nil then onError("This input requires a clock signal") end
				return false 
	 	elseif ghostCable:getStartModId() == self.modId then
			print("Can't connect a mod to itself...")
			return false
		elseif self.component:pedalInConnected() then
			return false
		else
			ghostCable:setEnd(self.pedalInVector.x, self.pedalInVector.y)
			ghostCable:setGhostReceiveConnected()
			return true
		end
	elseif closestInVector == self.noteInVector then
		if sourceSubtype ~= "midi" and sourceSubtype ~= "clock_router_or_midi" then
			if onError ~= nil then onError("This input requires a midi/note signal") end
				return false 
  		elseif ghostCable:getStartModId() == self.modId then
				print("Can't connect a mod to itself...")
				return false
			elseif self.component:noteInConnected() then
				return false
			else
				ghostCable:setEnd(self.noteInVector.x, self.noteInVector.y)
				ghostCable:setGhostReceiveConnected()
				return true
			end
		end
end

function SamplePlayMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function SamplePlayMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local samples = playdate.file.listFiles("Recorded/")
	
	local actions = {}
	
	if self.component:isPlaying() then
		local loopEntry = {
			label = "Stop"
		}
		table.insert(actions, loopEntry)
	else
		local loopEntry = {
			label = "Play"
		}
		table.insert(actions, loopEntry)
	end
	
	if self.component:isLooping() then
		local loopEntry = {
			label = "Loop Off"
		}
		table.insert(actions, loopEntry)
	else
		local loopEntry = {
			label = "Loop On"
		}
		table.insert(actions, loopEntry)
	end
	
	local divEntry1 = {
		label = "-----------------"
	}
	table.insert(actions, divEntry1)
	
	if samples ~= nil then
		for s=1,#samples do
			local entry = {
				label = "" .. samples[s]
			}
			table.insert(actions, entry)
		end
	end
	
	local speechSamples = playdate.file.listFiles("Samples/samples")
	
	if speechSamples ~= nil then
		for s=1,#speechSamples do
			local entry = {
				label = "" .. speechSamples[s],
				path = "Samples/samples/" .. speechSamples[s]
			}
			table.insert(actions, entry)
		end
	end
	
	local divEntry2 = {
		label = "-----------------"
	}
	table.insert(actions, divEntry2)
	
	table.insert(actions, {label="About"})
	table.insert(actions, {label="Move"})
	table.insert(actions, {label="Remove"})

	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action, index, obj) 
		self.menuIndex = index

		if action == "-----------------" then
			--no op
		elseif action == "Stop" then
			self.component:stopPlay()
		elseif action == "Play" then
			self.component:triggerPlay()
		elseif action == "About" then
			local aboutPopup = ModAboutPopup("Plays the selected sample when an event hits the in socket. Use with the Core > Pedal module for manual use.")
			aboutPopup:show()
		elseif action == "Move" then
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		elseif action == "Remove" then
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		elseif action == "Loop Off" then
			self.component:setLooping(false)
		elseif action == "Loop On" then
			self.component:setLooping(true)
		else
			--load a sample
			local path = nil
			if obj.path ~= nil then
				path = obj.path
			else
				path = "Recorded/" .. action
			end
		
			self.component:load(path)
			
			self.loopStartEncoderValue = 0.0
			self.component:setSampleStart(self.loopStartEncoderValue)
			self.loopEndEncoderValue = 1.0
			self.component:setSampleEnd(self.loopEndEncoderValue)
			self.samplePitchEncoderValue = 0.5
			self.component:setSamplePitch(self.samplePitchEncoderValue)
			
			self:redrawBackground()
		end
	end, self.menuIndex)
end

function SamplePlayMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function SamplePlayMod:moveFinish()
	local eY = self.y + 11
	
	self.loopStartEncoderVector = Vector(self.x - 34, eY)
	self.loopEndEncoderVector = Vector(self.x - 20, eY)	
	self.samplePitchEncoderVector = Vector(self.x + 34, eY)

	self.encoderVectors = {
		self.samplePitchEncoderVector,
		self.loopStartEncoderVector,
		self.loopEndEncoderVector
	}
	
	self.pedalInVector = Vector(self.x - (moduleWidth/2)-2, self.y - 20)
	self.noteInVector = Vector(self.x - (moduleWidth/2)-2, self.y + 17)
	self.socketOutVector = Vector(self.x + (moduleWidth/2)+2, self.y + 17)
	
	self.inSocketVectors = {
		self.pedalInVector,
		self.noteInVector
	}
	
end

function SamplePlayMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
	
	if self.component:pedalInConnected() then
		onDetachConnected(self.pedalInCable:getStartModId(), self.pedalInCable:getCableId())
		self.component:unplugPedalIn()
		self.pedalInCable:evaporate()
	end
	
	if self.component:noteInConnected() then
		onDetachConnected(self.noteInCable:getStartModId(), self.noteInCable:getCableId())
		self.component:unplugNoteIn()
		self.noteInCable:evaporate()
	end
	
	--then remove sprites
	self:remove()
end

function SamplePlayMod:type() return modType end
function SamplePlayMod:getModId() return self.modId end
function SamplePlayMod:unplug(cableId) self.component:unplug(cableId) end
function SamplePlayMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function SamplePlayMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y	

	return modState
end

function SamplePlayMod:fromState(modState)
	--todo
end