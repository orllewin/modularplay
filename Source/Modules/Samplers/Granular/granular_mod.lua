--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Samplers/Granular/granular_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'

class('GranularMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 180
local moduleHeight = 80

local modType = "GranularMod"
local modSubtype = "audio_gen"

function GranularMod:init(xx, yy, modId, onInit)
	GranularMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	gGranularRunning = true
	
	self.onInit = onInit
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.menuIndex = 1
		
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	gfx.pushContext(backgroundImage)
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 32)
	leftSocket:draw(10, 65)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(moduleWidth + 14, 65)
	
	
	-- |    |    |    |    |    |
	
	local sW = bgW/5
	gfx.drawTextAligned("Min", sW, 78, kTextAlignment.center)
	gfx.drawTextAligned("Max", sW * 2, 78, kTextAlignment.center)
	gfx.drawTextAligned("Size", sW * 3, 78, kTextAlignment.center)
	gfx.drawTextAligned("Rev %", sW * 4, 78, kTextAlignment.center)
		
	gfx.popContext()
	
	self.backgroundImage = backgroundImage
	
	self:moveTo(xx, yy)
	self:add()
	
	self.component = GranularComponent(self.modId, function(channel)
		print("Adding channel for modId: " .. self.modId)
		self.onInit(self.modId, channel)
	end, function()
		--todo - instead of redrawing entire background draw just the sample location 
		self:redrawSample()
	end)
	
	local eY = yy+ 11
	
	-- |    |    |  .  |    |    |
	local eW = bgW/10
	
	--subsample min position
	self.minPositionEncoderVector = Vector(xx - (eW * 3), eY)
	self.minPositionEncoderValue = 0.0
	self.minPositionEncoderImage = nil 
	
	--subsample max position
	self.maxPositionEncoderVector = Vector(xx - eW, eY)
	self.maxPositionEncoderValue = 1.0
	self.maxPositionEncoderImage = nil
	
	--subsample width/size
	self.subsampleWidthEncoderVector = Vector(xx + eW, eY)
	self.subsampleWidthEncoderValue = 0.5
	self.subsampleWidthEncoderImage = nil
	
	--rev %
	self.reverseEncoderVector = Vector(xx + (eW * 3), eY)
	self.reverseEncoderValue = 0.5
	self.reverseEncoderImage = nil

	self.encoderVectors = {
		self.minPositionEncoderVector,
		self.maxPositionEncoderVector,
		self.subsampleWidthEncoderVector,
		self.reverseEncoderVector
	}
	
	self.block = Block(xx, yy - moduleHeight/2 + 20, 100, 20, 0.5)
	self.hDiv = DividerHorizontal(xx - moduleWidth/2 + 10, yy - moduleHeight/2 + 20, moduleWidth - 15, 0.1)
	
	self.positionSocketVector = Vector(xx - (moduleWidth/2)-2, yy - 20)
	self.bangSocketVector = Vector(xx - (moduleWidth/2)-2, yy + 17)
	self.socketOutVector = Vector	(xx + (moduleWidth/2)+2, yy + 17)

	self.inSocketVectors = {
		self.positionSocketVector,
		self.bangSocketVector
	}
	
	self:redrawBackground()
end

function GranularMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function GranularMod:redrawSample()
	local minMs = self.component:getMinMs()
	local maxMs = self.component:getMaxMs()
	local subsampleMs = self.component:getSubsampleMs()
	local blockWidth = math.floor(map(subsampleMs, minMs, maxMs, 10, moduleWidth/3))
	self.block:setWidth(blockWidth)
	
	local normalisedStartPosition = self.component:getNormalisedStart()
	
	local blockX = self.x + map(normalisedStartPosition, 0.0, 1.0, self.block:getWidth()/2, moduleWidth - self.block:getWidth()/2)
	local blockY = self.block.y
	self.block:moveTo(blockX - (moduleWidth/2), blockY)
end

function GranularMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = self.backgroundImage:getSize()

	gfx.pushContext(backgroundImage)
	
	self.backgroundImage:draw(0, 0)
	
	local sX = 23
	local eX = 113
	local len = 100
	
	local minY = 20
	local maxY = 47
	
	local sW = bgW/5
	local eF = 10
	
	--subsample min position
	if self.minPositionEncoderValue == nil then
		return
	end
	if self.minPositionEncoderImage == nil then
		print("11111111")
		gEncoder:setValue(self.minPositionEncoderValue)
		self.minPositionEncoderImage = gEncoder:getImage()
		self.minPositionEncoderImage:draw(sW * 1 - eF, 55)
	else
		self.minPositionEncoderImage:draw(sW * 1 - eF, 55)
	end
	
	local minX = map(self.minPositionEncoderValue, 0.0, 1.0, 0.0, moduleWidth - 1) + 14
	gfx.drawLine(minX, minY+3, minX, maxY-3)
	
	--subsample max position
	if self.maxPositionEncoderValue == nil then
		return
	end
	if self.maxPositionEncoderImage == nil then
		print("222222222")
		gEncoder:setValue(self.maxPositionEncoderValue)
		self.maxPositionEncoderImage = gEncoder:getImage()
		self.maxPositionEncoderImage:draw(sW * 2 - eF, 55)
	else
		self.maxPositionEncoderImage:draw(sW * 2 - eF, 55)
	end
	
	local maxX = map(self.maxPositionEncoderValue, 0.0, 1.0, 0.0, moduleWidth - 1) + 14
	gfx.drawLine(maxX, minY+3, maxX, maxY-3)
	
	--subsample width
	if self.subsampleWidthEncoderValue == nil then
		self.subsampleWidthEncoderValue = 0.5
	end
	if self.subsampleWidthEncoderImage == nil then
		print("33333")
		gEncoder:setValue(self.subsampleWidthEncoderValue)
		self.subsampleWidthEncoderImage = gEncoder:getImage()
		self.subsampleWidthEncoderImage:draw(sW * 3 - eF, 55)
	else
		self.subsampleWidthEncoderImage:draw(sW * 3 - eF, 55)
	end
	

	
	--rev chance
	if self.reverseEncoderImage == nil then
		print("444444")
		gEncoder:setValue(self.reverseEncoderValue)
		self.reverseEncoderImage = gEncoder:getImage()
		self.reverseEncoderImage:draw(sW * 4 - eF, 55)
	else
		self.reverseEncoderImage:draw(sW * 4 - eF, 55)
	end

	gfx.popContext()
	
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function GranularMod:turn(x, y, change)
	print("00000000")
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end

	if encoderVector == self.minPositionEncoderVector then
		gEncoder:setValue(self.minPositionEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.minPositionEncoderVector.x, self.minPositionEncoderVector.y)
		gEncoder:turn(change)
		self.minPositionEncoderValue = gEncoder:getValue()
		self.minPositionEncoderImage = gEncoder:getImage()
		
		if self.minPositionEncoderValue < self.component:getMaxPosition() then
			self.component:setSubsampleMinStart(self.minPositionEncoderValue)
		else
			self.minPositionEncoderValue = self.component:getMaxPosition()
			self.component:setSubsampleMinStart(self.minPositionEncoderValue)
		end
		
	elseif encoderVector == self.maxPositionEncoderVector then
		gEncoder:setValue(self.maxPositionEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.maxPositionEncoderVector.x, self.maxPositionEncoderVector.y)
		gEncoder:turn(change)
		self.maxPositionEncoderValue = gEncoder:getValue()
		self.maxPositionEncoderImage = gEncoder:getImage()
		
		self.component:setSubsampleMaxEnd(self.maxPositionEncoderValue)
		
		if self.maxPositionEncoderValue > self.component:getMinPosition() then
			self.component:setSubsampleMaxEnd(self.maxPositionEncoderValue)
		else
			self.maxPositionEncoderValue = self.component:getMinPosition()
			self.component:setSubsampleMaxEnd(self.maxPositionEncoderValue)
		end
		
	elseif encoderVector == self.subsampleWidthEncoderVector then
		gEncoder:setValue(self.subsampleWidthEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.subsampleWidthEncoderVector.x, self.subsampleWidthEncoderVector.y)
		gEncoder:turn(change)
		self.subsampleWidthEncoderValue = gEncoder:getValue()
		self.subsampleWidthEncoderImage = gEncoder:getImage()
		
		self.component:setSubsampleWidth(self.subsampleWidthEncoderValue)
	elseif encoderVector == self.reverseEncoderVector then
		gEncoder:setValue(self.reverseEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.reverseEncoderVector.x, self.reverseEncoderVector.y)
		gEncoder:turn(change)
		self.reverseEncoderValue = gEncoder:getValue()
		self.reverseEncoderImage = gEncoder:getImage()
		
		self.component:setSubsampleReverseChance(self.reverseEncoderValue)
	end
	self:redrawBackground()
	self.redrawPending = false
end

function GranularMod:findClosestEncoderVector(x, y)
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


function GranularMod:setInCable(patchCable)
	local closestInVector = self:findClosestInVector(patchCable:getEndX(), patchCable:getEndY())
	
	if closestInVector == self.positionSocketVector then
		patchCable:setEnd(self.positionSocketVector.x, self.positionSocketVector.y, self.modId)
		self.positionCable = patchCable
		self.component:positionSocketInsert(patchCable:getCable())
	elseif closestInVector == self.bangSocketVector then
		patchCable:setEnd(self.bangSocketVector.x, self.bangSocketVector.y, self.modId)
		self.bangCable = patchCable
		self.component:bangSocketInsert(patchCable:getCable())
	end
end

function GranularMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function GranularMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function GranularMod:findClosestInVector(x, y)
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

function GranularMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype, onError)
	local closestInVector = self:findClosestInVector(x, y)
	
	if closestInVector == self.positionSocketVector then
		if sourceSubtype ~= SourceTypes.normalised_value then
			if onError ~= nil then onError("This input requires a value signal") end
				return false 
	 	elseif ghostCable:getStartModId() == self.modId then
			print("Can't connect a mod to itself...")
			return false
		elseif self.component:positionSocketConnected() then
			return false
		else
			ghostCable:setEnd(self.positionSocketVector.x, self.positionSocketVector.y)
			ghostCable:setGhostReceiveConnected()
			return true
		end
	elseif closestInVector == self.bangSocketVector then
		if sourceSubtype ~= "clock_router" and sourceSubtype ~= "clock_router_or_midi" then
			if onError ~= nil then onError("This input requires a clock signal") end
				return false 
  		elseif ghostCable:getStartModId() == self.modId then
				print("Can't connect a mod to itself...")
				return false
			elseif self.component:bangSocketConnected() then
				return false
			else
				ghostCable:setEnd(self.bangSocketVector.x, self.bangSocketVector.y)
				ghostCable:setGhostReceiveConnected()
				return true
			end
		end
end

function GranularMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function GranularMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local samples = playdate.file.listFiles("Recorded/")
	
	local actions = {
		{
			label="Octave -3",
			type = "checkbox",
			checked = self.component:octaveEnabled(-3)
		},
		{
			label="Octave -2",
			type = "checkbox",
			checked = self.component:octaveEnabled(-2)
		},
		{
			label="Octave -1",
			type = "checkbox",
			checked = self.component:octaveEnabled(-1)
		},
		{
			label="Octave Orig.",
			type = "checkbox",
			checked = self.component:octaveEnabled(1)
		},
		{
			label="Octave +1",
			type = "checkbox",
			checked = self.component:octaveEnabled(2)
		}
	}

	
	if self.component:isSmoothingOn() then
		local smoothingEntry = {
			label = "Turn smoothing off"
		}
		table.insert(actions, smoothingEntry)
	else
		local smoothingEntry = {
			label = "Apply smoothing"
		}
		table.insert(actions, smoothingEntry)
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
		
		if obj.type ~= nil and obj.type == "checkbox" then
			if obj.label == "Octave -3" then
				self.component:setOctaveEnabled(-3, obj.checked)
			elseif obj.label == "Octave -2" then
				self.component:setOctaveEnabled(-2, obj.checked)
			elseif obj.label == "Octave -1" then
				self.component:setOctaveEnabled(-1, obj.checked)
			elseif obj.label == "Octave Orig." then
				self.component:setOctaveEnabled(1, obj.checked)	
			elseif obj.label == "Octave +1" then
				self.component:setOctaveEnabled(2, obj.checked)			
			end
		else
			if action == "-----------------" then
				--no op
			elseif action == "Turn smoothing off" then
				self.component:setDoSmoothing(false)
			elseif action == "Apply smoothing" then
				self.component:setDoSmoothing(true)
			elseif action == "About" then
				local aboutPopup = ModAboutPopup("Plays subsamples at various octaves. Top input is position for use with an oscillator (0.0 to 1.0). Bottom input is for use with a bang; a clock or pedal.")
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
				--load a sample
				local path = nil
				if obj.path ~= nil then
					path = obj.path
				else
					path = "Recorded/" .. action
				end
			
				print("loading: " .. path)
				self.component:load(path)
			end
		end
	end, self.menuIndex)
end

function GranularMod:repositionBy(x, y)
	self:moveBy(x, y)
	self.block:moveBy(x, y)
	self.hDiv:moveBy(x, y)
end

function GranularMod:moveFinish()
	local eY = self.y + 11
	
	self.subsampleWidthEncoderVector = Vector(self.x - 34, eY)
	self.maxPositionEncoderVector = Vector(self.x - 20, eY)	
	self.samplePitchEncoderVector = Vector(self.x + 34, eY)

	self.encoderVectors = {
		self.samplePitchEncoderVector,
		self.subsampleWidthEncoderVector,
		self.maxPositionEncoderVector
	}
	
	self.positionSocketVector = Vector(self.x - (moduleWidth/2)-2, self.y - 20)
	self.bangSocketVector = Vector(self.x - (moduleWidth/2)-2, self.y + 17)
	self.socketOutVector = Vector(self.x + (moduleWidth/2)+2, self.y + 17)
	
	self.inSocketVectors = {
		self.positionSocketVector,
		self.bangSocketVector
	}
	
end

function GranularMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
	
	if self.component:positionSocketConnected() then
		onDetachConnected(self.positionCable:getStartModId(), self.positionCable:getCableId())
		self.component:unplugPositionSocket()
		self.positionCable:evaporate()
	end
	
	if self.component:bangSocketConnected() then
		onDetachConnected(self.bangCable:getStartModId(), self.bangCable:getCableId())
		self.component:unplugBangSocket()
		self.bangCable:evaporate()
	end
	
	--then remove sprites
	self.block:remove()
	self.hDiv:remove()
	self:remove()
end

function GranularMod:type() return modType end
function GranularMod:getModId() return self.modId end
function GranularMod:unplug(cableId) self.component:unplug(cableId) end
function GranularMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function GranularMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y	

	modState.filePath = self.component:getFilePath()
	modState.doSmoothing = self.component:isSmoothingOn()
	modState.octaveMinus3 = self.component:octaveEnabled(-3)
	modState.octaveMinus2 = self.component:octaveEnabled(-2)
	modState.octaveMinus1 = self.component:octaveEnabled(-1)
	modState.octaveOriginal = self.component:octaveEnabled(1)
	modState.octaveTimes2 = self.component:octaveEnabled(2)
	modState.normalisedStart = self.component:getNormalisedStart()
	modState.normalisedEnd = self.component:getNormalisedEnd()
	modState.reverseChance = self.component:getSubsampleReverseChance()
	return modState
end

function GranularMod:fromState(modState)
	self.component:load(modState.filePath)
	self.component:setDoSmoothing(modState.doSmoothing)
	self.component:setOctaveEnabled(-3, modState.octaveMinus3)
	self.component:setOctaveEnabled(-2, modState.octaveMinus2)
	self.component:setOctaveEnabled(-1, modState.octaveMinus1)
	self.component:setOctaveEnabled(1, modState.octaveOriginal)
	self.component:setOctaveEnabled(2, modState.octaveTimes2)
	self.component:setSubsampleMinStart(modState.normalisedStart)
	self.component:setSubsampleMaxEnd(modState.normalisedEnd)
	self.component:setSubsampleReverseChance(modState.reverseChance)
end