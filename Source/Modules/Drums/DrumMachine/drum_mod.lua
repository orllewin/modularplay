--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'Modules/Drums/DrumMachine/drum_component'

class('DrumMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local snd <const> = playdate.sound

local moduleWidth = 102
local moduleHeight = 116

local stepImage = gfx.image.new("Images/step")

local modType = "DrumMod"
local modSubtype = "audio_gen"

function DrumMod:init(xx, yy, modId, onInit)
	DrumMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.onInit = onInit
	
	self.sampleIndexes = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	
	self.channel = snd.channel.new()
	self.channel:setVolume(gDefaultVolume)
	
	if onInit ~= nil then self.onInit(self.modId, self.channel) end
	
	self.lastSample = "--- ---"
	
	self.samples = {
		{
			name = "606-BD",
			path = "Samples/606-BD",
			player = snd.sampleplayer.new("Samples/606-BD")
		},
		{
			name = "606-CH",
			path = "Samples/606-CH",
			player = snd.sampleplayer.new("Samples/606-CH")
		},
		{
			name = "606-CY",
			path = "Samples/606-CY",
			player = snd.sampleplayer.new("Samples/606-CY")
		},
		{
			name = "606-HT",
			path = "Samples/606-HT",
			player = snd.sampleplayer.new("Samples/606-HT")
		},
		{
			name = "606-LT",
			path = "Samples/606-LT",
			player = snd.sampleplayer.new("Samples/606-LT")
		},
		{
			name = "606-OH",
			path = "Samples/606-OH",
			player = snd.sampleplayer.new("Samples/606-OH")
		},
		{
			name = "606-SD",
			path = "Samples/606-SD",
			player = snd.sampleplayer.new("Samples/606-SD")
		},
		{
			name = "808-BD",
			path = "Samples/808-BD",
			player = snd.sampleplayer.new("Samples/808-bd")
		},
		{
			name = "808-BS",
			path = "Samples/808-BS",
			player = snd.sampleplayer.new("Samples/808-BS")
		},
		{
			name = "808-CB",
			path = "Samples/808-CB",
			player = snd.sampleplayer.new("Samples/808-CB")
		},
		{
			name = "808-CH",
			path = "Samples/808-CH",
			player = snd.sampleplayer.new("Samples/808-CH")
		},
		{
			name = "808-CL",
			path = "Samples/808-CL",
			player = snd.sampleplayer.new("Samples/808-CL")
		},
		{
			name = "808-CP",
			path = "Samples/808-CP",
			player = snd.sampleplayer.new("Samples/808-CP")
		},
		{
			name = "808-CY",
			path = "Samples/808-CY",
			player = snd.sampleplayer.new("Samples/808-CY")
		},
		{
			name = "808-HC",
			path = "Samples/808-HC",
			player = snd.sampleplayer.new("Samples/808-HC")
		},
		{
			name = "808-HT",
			path = "Samples/808-HT",
			player = snd.sampleplayer.new("Samples/808-HT")
		},
		{
			name = "808-LC",
			path = "Samples/808-LC",
			player = snd.sampleplayer.new("Samples/808-LC")
		},
		{
			name = "808-LT",
			path = "Samples/808-LT",
			player = snd.sampleplayer.new("Samples/808-LT")
		},
		{
			name = "808-MA",
			path = "Samples/808-MA",
			player = snd.sampleplayer.new("Samples/808-MA")
		},
		{
			name = "808-MC",
			path = "Samples/808-MC",
			player = snd.sampleplayer.new("Samples/808-MC")
		},
		{
			name = "808-MT",
			path = "Samples/808-MT",
			player = snd.sampleplayer.new("Samples/808-MT")
		},
		{
			name = "808-OH",
			path = "Samples/808-OH",
			player = snd.sampleplayer.new("Samples/808-OH")
		},
		{
			name = "808-RS",
			path = "Samples/808-RS",
			player = snd.sampleplayer.new("Samples/808-RS")
		},
		{
			name = "808-SD",
			path = "Samples/808-SD",
			player = snd.sampleplayer.new("Samples/808-SD")
		},
		{
			name = "909-BD",
			path = "Samples/909-BD",
			player = snd.sampleplayer.new("Samples/909-BD")
		},
		{
			name = "909-CH",
			path = "Samples/909-CH",
			player = snd.sampleplayer.new("Samples/909-CH")
		},
		{
			name = "909-CP",
			path = "Samples/909-CP",
			player = snd.sampleplayer.new("Samples/909-CP")
		},
		{
			name = "909-CY",
			path = "Samples/909-CY",
			player = snd.sampleplayer.new("Samples/909-CY")
		},
		{
			name = "909-OH",
			path = "Samples/909-OH",
			player = snd.sampleplayer.new("Samples/909-OH")
		},
		{
			name = "909-RC",
			path = "Samples/909-RC",
			player = snd.sampleplayer.new("Samples/909-RC")
		},
		{
			name = "909-RS",
			path = "Samples/909-RS",
			player = snd.sampleplayer.new("Samples/909-RS")
		},
		{
			name = "909-SD",
			path = "Samples/909-SD",
			player = snd.sampleplayer.new("Samples/909-SD")
		}
	}
	
	for i=1,#self.samples do
		local sample = self.samples[i]
		self.channel:addSource(sample.player)
	end
	
		
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()	
	self.bgW = bgW
	self.bgH = bgH
	gfx.pushContext(backgroundImage)
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, bgH/2 + 10)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(115, bgH/2 + 10)
	
	gfx.popContext()
	
	self.backgroundImage = backgroundImage
	self:moveTo(xx, yy)
	self:add()
	
	self.col1X = xx - 33
	self.col2X = xx - 11
	self.col3X = xx + 11
	self.col4X = xx + 32
	
	self.row1Y = yy - 17
	self.row2Y = yy + 5
	self.row3Y = yy + 27
	self.row4Y = yy + 49
	
	self.socketInY = yy - (moduleHeight/2) + 22
	self.socketOutY = yy - (moduleHeight/2) + 124
	
	self.stepSprite = gfx.sprite.new(stepImage)
	self.stepSprite:setZIndex(28890)
	self.stepSprite:moveTo(self.col1X, self.row1Y - 22)
	self.stepSprite:add()
	
	local topRowOffset = 30
	local bottomRowOffset = 6
	self.component = DrumComponent(function(step) 
		if step == 1 then
			self.stepSprite:moveTo(self.col1X, self.row1Y - 22)
			self:playStep(1)
		elseif step == 2 then
			self.stepSprite:moveTo(self.col2X, self.row1Y - 22)
			self:playStep(2)
		elseif step == 3 then
			self.stepSprite:moveTo(self.col3X, self.row1Y - 22)
			self:playStep(3)
		elseif step == 4 then
			self.stepSprite:moveTo(self.col4X, self.row1Y - 22)
			self:playStep(4)
		elseif step == 5 then
			self.stepSprite:moveTo(self.col1X, self.row2Y - 22)
			self:playStep(5)
		elseif step == 6 then
			self.stepSprite:moveTo(self.col2X, self.row2Y - 22)
			self:playStep(6)
		elseif step == 7 then
			self.stepSprite:moveTo(self.col3X, self.row2Y - 22)	
			self:playStep(7)	
		elseif step == 8 then
			self.stepSprite:moveTo(self.col4X, self.row2Y - 22)
			self:playStep(8)			
		elseif step == 9 then
			self.stepSprite:moveTo(self.col1X, self.row3Y - 22)
			self:playStep(9)
		elseif step == 10 then
			self.stepSprite:moveTo(self.col2X, self.row3Y - 22)
			self:playStep(10)
		elseif step == 11 then
			self.stepSprite:moveTo(self.col3X, self.row3Y - 22)
			self:playStep(11)
		elseif step == 12 then
			self.stepSprite:moveTo(self.col4X, self.row3Y - 22)
			self:playStep(12)
		elseif step == 13 then
			self.stepSprite:moveTo(self.col1X, self.row4Y - 22)
			self:playStep(13)
		elseif step == 14 then
			self.stepSprite:moveTo(self.col2X, self.row4Y - 22)
			self:playStep(14)
		elseif step == 15 then
			self.stepSprite:moveTo(self.col3X, self.row4Y - 22)	
			self:playStep(15)	
		elseif step == 16 then
			self.stepSprite:moveTo(self.col4X, self.row4Y - 22)	
			self:playStep(16)			
		end
	end)

	--ROW1
	self.step1EncoderVector = Vector(self.col1X, self.row1Y - 16)
	self.step1EncoderValue = 0.0
	
	self.step2EncoderVector = Vector(self.col2X, self.row1Y - 16)
	self.step2EncoderValue = 0.0
	
	self.step3EncoderVector = Vector(self.col3X, self.row1Y - 16)
	self.step3EncoderValue = 0.0
	
	self.step4EncoderVector = Vector(self.col4X + 1, self.row1Y - 16)
	self.step4EncoderValue = 0.0
	
	--ROW2
	self.step5EncoderVector = Vector(self.col1X, self.row2Y - 16)
	self.step5EncoderValue = 0.0
	
	self.step6EncoderVector = Vector(self.col2X, self.row2Y - 16)
	self.step6EncoderValue = 0.0
	
	self.step7EncoderVector = Vector(self.col3X, self.row2Y - 16)
	self.step7EncoderValue = 0.0
	
	self.step8EncoderVector = Vector(self.col4X + 1, self.row2Y - 16)
	self.step8EncoderValue = 0.0
	
	--ROW3
	self.step9EncoderVector = Vector(self.col1X, self.row3Y - 16)
	self.step9EncoderValue = 0.0
	
	self.step10EncoderVector = Vector(self.col2X, self.row3Y - 16)
	self.step10EncoderValue = 0.0
	
	self.step11EncoderVector = Vector(self.col3X, self.row3Y - 16)
	self.step11EncoderValue = 0.0
	
	self.step12EncoderVector = Vector(self.col4X + 1, self.row3Y - 16)
	self.step12EncoderValue = 0.0
	
	--ROW4
	self.step13EncoderVector = Vector(self.col1X, self.row4Y - 16)
	self.step13EncoderValue = 0.0
	
	self.step14EncoderVector = Vector(self.col2X, self.row4Y - 16)
	self.step14EncoderValue = 0.0
	
	self.step15EncoderVector = Vector(self.col3X, self.row4Y - 16)
	self.step15EncoderValue = 0.0
	
	self.step16EncoderVector = Vector(self.col4X + 1, self.row4Y - 16)
	self.step16EncoderValue = 0.0
	
	self.encoderVectors = {
		self.step1EncoderVector,
		self.step2EncoderVector,
		self.step3EncoderVector,
		self.step4EncoderVector,
		self.step5EncoderVector,
		self.step6EncoderVector,
		self.step7EncoderVector,
		self.step8EncoderVector,
		self.step9EncoderVector,
		self.step10EncoderVector,
		self.step11EncoderVector,
		self.step12EncoderVector,
		self.step13EncoderVector,
		self.step14EncoderVector,
		self.step15EncoderVector,
		self.step16EncoderVector
	}
	
	self.socketInVector = Vector(xx - (moduleWidth/2), yy + 14)
	self.socketOutVector = Vector(xx + (moduleWidth/2), yy + 14)
	
	self:redrawBackground()
end

function DrumMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = gfx.image.new(self.bgW, self.bgH)
	gfx.pushContext(backgroundImage)	
	self.backgroundImage:draw(0, 0)
	
	--draw encoders
	local col1X = 22
	local col2X = 44
	local col3X = 66
	local col4X = 88
	local row1Y = 22
	local row2Y = 44
	local row3Y = 66
	local row4Y = 88
	
	-- Row 1
	gEncoder:setValue(self.step1EncoderValue)
	local step1EncoderImage = gEncoder:getImage()
	step1EncoderImage:draw(col1X, row1Y)
	
	gEncoder:setValue(self.step2EncoderValue)
	local step2EncoderImage = gEncoder:getImage()
	step2EncoderImage:draw(col2X, row1Y)
	
	gEncoder:setValue(self.step3EncoderValue)
	local step3EncoderImage = gEncoder:getImage()
	step3EncoderImage:draw(col3X, row1Y)
	
	gEncoder:setValue(self.step4EncoderValue)
	local step4EncoderImage = gEncoder:getImage()
	step4EncoderImage:draw(col4X, row1Y)
	
	-- Row 2
	gEncoder:setValue(self.step5EncoderValue)
	local step5EncoderImage = gEncoder:getImage()
	step5EncoderImage:draw(col1X, row2Y)
	
	gEncoder:setValue(self.step6EncoderValue)
	local step6EncoderImage = gEncoder:getImage()
	step6EncoderImage:draw(col2X, row2Y)
	
	gEncoder:setValue(self.step7EncoderValue)
	local step7EncoderImage = gEncoder:getImage()
	step7EncoderImage:draw(col3X, row2Y)
	
	gEncoder:setValue(self.step8EncoderValue)
	local step8EncoderImage = gEncoder:getImage()
	step8EncoderImage:draw(col4X, row2Y)

	-- Row 3
	gEncoder:setValue(self.step9EncoderValue)
	local step9EncoderImage = gEncoder:getImage()
	step9EncoderImage:draw(col1X, row3Y)
	
	gEncoder:setValue(self.step10EncoderValue)
	local step10EncoderImage = gEncoder:getImage()
	step10EncoderImage:draw(col2X, row3Y)
	
	gEncoder:setValue(self.step11EncoderValue)
	local step11EncoderImage = gEncoder:getImage()
	step11EncoderImage:draw(col3X, row3Y)
	
	gEncoder:setValue(self.step12EncoderValue)
	local step12EncoderImage = gEncoder:getImage()
	step12EncoderImage:draw(col4X, row3Y)
	
	-- Row 4
	gEncoder:setValue(self.step13EncoderValue)
	local step13EncoderImage = gEncoder:getImage()
	step13EncoderImage:draw(col1X, row4Y)
	
	gEncoder:setValue(self.step14EncoderValue)
	local step14EncoderImage = gEncoder:getImage()
	step14EncoderImage:draw(col2X, row4Y)
	
	gEncoder:setValue(self.step15EncoderValue)
	local step15EncoderImage = gEncoder:getImage()
	step15EncoderImage:draw(col3X, row4Y)
	
	gEncoder:setValue(self.step16EncoderValue)
	local step16EncoderImage = gEncoder:getImage()
	step16EncoderImage:draw(col4X, row4Y)
	gfx.drawTextAligned(self.lastSample, self.bgW/2, 114, kTextAlignment.center)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function DrumMod:playStep(index)
	if self.sampleIndexes[index] ~= 0 then
		self.samples[self.sampleIndexes[index]].player:play()
	end
end

function DrumMod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end
	
	if encoderVector == self.step1EncoderVector then
		gEncoder:setValue(self.step1EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step1EncoderVector.x, self.step1EncoderVector.y)
		gEncoder:turn(change)
		self.step1EncoderValue = gEncoder:getValue()
		self:setSample(1, self.step1EncoderValue)
	elseif encoderVector == self.step2EncoderVector then
		gEncoder:setValue(self.step2EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step2EncoderVector.x, self.step2EncoderVector.y)
		gEncoder:turn(change)
		self.step2EncoderValue = gEncoder:getValue()
		self:setSample(2, self.step2EncoderValue)
	elseif encoderVector == self.step3EncoderVector then
		gEncoder:setValue(self.step3EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step3EncoderVector.x, self.step3EncoderVector.y)
		gEncoder:turn(change)
		self.step3EncoderValue = gEncoder:getValue()
		self:setSample(3, self.step3EncoderValue)
	elseif encoderVector == self.step4EncoderVector then
		gEncoder:setValue(self.step4EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step4EncoderVector.x, self.step4EncoderVector.y)
		gEncoder:turn(change)
		self.step4EncoderValue = gEncoder:getValue()
		self:setSample(4, self.step4EncoderValue)
	elseif encoderVector == self.step5EncoderVector then
		gEncoder:setValue(self.step5EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step5EncoderVector.x, self.step5EncoderVector.y)
		gEncoder:turn(change)
		self.step5EncoderValue = gEncoder:getValue()
		self:setSample(5, self.step5EncoderValue)
	elseif encoderVector == self.step6EncoderVector then
		gEncoder:setValue(self.step6EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step6EncoderVector.x, self.step6EncoderVector.y)
		gEncoder:turn(change)
		self.step6EncoderValue = gEncoder:getValue()
		self:setSample(6, self.step6EncoderValue)
	elseif encoderVector == self.step7EncoderVector then
		gEncoder:setValue(self.step7EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step7EncoderVector.x, self.step7EncoderVector.y)
		gEncoder:turn(change)
		self.step7EncoderValue = gEncoder:getValue()
		self:setSample(7, self.step7EncoderValue)	
	elseif encoderVector == self.step8EncoderVector then
		gEncoder:setValue(self.step8EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step8EncoderVector.x, self.step8EncoderVector.y)
		gEncoder:turn(change)
		self.step8EncoderValue = gEncoder:getValue()
		self:setSample(8, self.step8EncoderValue)
	elseif encoderVector == self.step9EncoderVector then
		gEncoder:setValue(self.step9EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step9EncoderVector.x, self.step9EncoderVector.y)
		gEncoder:turn(change)
		self.step9EncoderValue = gEncoder:getValue()
		self:setSample(9, self.step9EncoderValue)	
	elseif encoderVector == self.step10EncoderVector then
		gEncoder:setValue(self.step10EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step10EncoderVector.x, self.step10EncoderVector.y)
		gEncoder:turn(change)
		self.step10EncoderValue = gEncoder:getValue()
		self:setSample(10, self.step10EncoderValue)	
	elseif encoderVector == self.step11EncoderVector then
		gEncoder:setValue(self.step11EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step11EncoderVector.x, self.step11EncoderVector.y)
		gEncoder:turn(change)
		self.step11EncoderValue = gEncoder:getValue()
		self:setSample(11, self.step11EncoderValue)	
	elseif encoderVector == self.step12EncoderVector then
		gEncoder:setValue(self.step12EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step12EncoderVector.x, self.step12EncoderVector.y)
		gEncoder:turn(change)
		self.step12EncoderValue = gEncoder:getValue()
		self:setSample(12, self.step12EncoderValue)	
	elseif encoderVector == self.step13EncoderVector then
		gEncoder:setValue(self.step13EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step13EncoderVector.x, self.step13EncoderVector.y)
		gEncoder:turn(change)
		self.step13EncoderValue = gEncoder:getValue()
		self:setSample(13, self.step13EncoderValue)	
	elseif encoderVector == self.step14EncoderVector then
		gEncoder:setValue(self.step14EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step14EncoderVector.x, self.step14EncoderVector.y)
		gEncoder:turn(change)
		self.step14EncoderValue = gEncoder:getValue()
		self:setSample(14, self.step14EncoderValue)	
	elseif encoderVector == self.step15EncoderVector then
		gEncoder:setValue(self.step15EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step15EncoderVector.x, self.step15EncoderVector.y)
		gEncoder:turn(change)
		self.step15EncoderValue = gEncoder:getValue()
		self:setSample(15, self.step15EncoderValue)	
	elseif encoderVector == self.step16EncoderVector then
		gEncoder:setValue(self.step16EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step16EncoderVector.x, self.step16EncoderVector.y)
		gEncoder:turn(change)
		self.step16EncoderValue = gEncoder:getValue()
		self:setSample(16, self.step16EncoderValue)	
	end
	self:redrawBackground()
	self.redrawPending = false
end

function DrumMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function DrumMod:findClosestEncoderVector(x, y)
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



function DrumMod:setSample(index, value)
	--self.component:setSample(index, map(value, 0.0, 1.0, 0, 6))--todo - get valid values
	local sampleIndex = math.floor(map(value, 0.0, 1.0, 0, #self.samples))
	self.sampleIndexes[index] = sampleIndex
	if sampleIndex > 0 then
		self.lastSample = self.samples[sampleIndex].name
	else
		self.lastSample = ""
	end
end

function DrumMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function DrumMod:setOutCable(patchCable)
	patchCable:setEnd(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function DrumMod:collision(x, y)
	if x > self.x - (self.width/2) and x < self.x + (self.width/2) and y > self.y - (self.height/2) and y < self.y + (self.height/2) then
		return true
	else
		return false
	end
end

function DrumMod:tryConnectGhostIn(x, y, ghostCable)
	if ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif  self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function DrumMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function DrumMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "All off"},
		{label = "Randomise"},
		{label = "4/4 808 Kick"},
		{label = "4/4 909 Kick"},
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "Randomise" then
			self:randomise()
		elseif action == "All off" then
			self:setAllOff()
		elseif action == "4/4 808 Kick" then
			self:set44_808_Kick()
		elseif action == "4/4 909 Kick" then
			self:set44_909_Kick()
		elseif action == "About" then
			local aboutPopup = ModAboutPopup("A simple drum machine, each encoder selects the sample for a step from a built-in bank.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end

	end)
end

function DrumMod:unplug(cableId)
	if self.component:inConnected() and self.inCable:getCableId() == cableId then
	 	self.component:unplugIn()
	 	self.inCable = nil
	end
	
	if self.component:outConnected() and "" .. self.outCable:getCableId() == "" .. cableId then
		 self.component:unplugOut()
		self.outCable = nil
	end
end

function DrumMod:repositionBy(x, y)
	self:moveBy(x, y)
	self.stepSprite:moveBy(x, y)
end

function DrumMod:moveFinish()	
	self.col1X = self.x - 33
	self.col2X = self.x - 11
	self.col3X = self.x + 11
	self.col4X = self.x + 32
	
	self.row1Y = self.y - 17
	self.row2Y = self.y + 5
	self.row3Y = self.y + 27
	self.row4Y = self.y + 49
	
	self.socketInY = self.y - (moduleHeight/2) + 22
	self.socketOutY = self.y - (moduleHeight/2) + 124
	
	self.step1EncoderVector = Vector(self.col1X, self.row1Y - 16)
	self.step2EncoderVector = Vector(self.col2X, self.row1Y - 16)
	self.step3EncoderVector = Vector(self.col3X, self.row1Y - 16)
	self.step4EncoderVector = Vector(self.col4X + 1, self.row1Y - 16)
	self.step5EncoderVector = Vector(self.col1X, self.row2Y - 16)
	self.step6EncoderVector = Vector(self.col2X, self.row2Y - 16)
	self.step7EncoderVector = Vector(self.col3X, self.row2Y - 16)
	self.step8EncoderVector = Vector(self.col4X + 1, self.row2Y - 16)
	self.step9EncoderVector = Vector(self.col1X, self.row3Y - 16)
	self.step10EncoderVector = Vector(self.col2X, self.row3Y - 16)
	self.step11EncoderVector = Vector(self.col3X, self.row3Y - 16)
	self.step12EncoderVector = Vector(self.col4X + 1, self.row3Y - 16)
	self.step13EncoderVector = Vector(self.col1X, self.row4Y - 16)
	self.step14EncoderVector = Vector(self.col2X, self.row4Y - 16)
	self.step15EncoderVector = Vector(self.col3X, self.row4Y - 16)
	self.step16EncoderVector = Vector(self.col4X + 1, self.row4Y - 16)
	
	self.encoderVectors = {
		self.step1EncoderVector,
		self.step2EncoderVector,
		self.step3EncoderVector,
		self.step4EncoderVector,
		self.step5EncoderVector,
		self.step6EncoderVector,
		self.step7EncoderVector,
		self.step8EncoderVector,
		self.step9EncoderVector,
		self.step10EncoderVector,
		self.step11EncoderVector,
		self.step12EncoderVector,
		self.step13EncoderVector,
		self.step14EncoderVector,
		self.step15EncoderVector,
		self.step16EncoderVector
	}
	
	self.socketInVector = Vector(self.x - (moduleWidth/2), self.y + 14)
	self.socketOutVector = Vector(self.x + (moduleWidth/2), self.y + 14)
end

function DrumMod:evaporate(onDetachConnected)
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
	
	self.component:stopAll()
	
	for i=#self.samples,1,-1 do
		local samplePlayer = self.samples[i]
		samplePlayer.player:stop()
		self.channel:removeSource(samplePlayer.player)
		self.samples[i] = nil
	end
	
	self.channel:remove()
	self.samplePlayers = nil
	
	--then remove sprites
	playdate.graphics.sprite.removeSprites({self.stepSprite})

	self.stepSprite = nil	
	self:remove()
end

function DrumMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end
function DrumMod:type() return self.modType end
function DrumMod:getModId() return self.modId end

function DrumMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.step1EncoderValue = self.step1EncoderValue
	modState.step2EncoderValue = self.step2EncoderValue
	modState.step3EncoderValue = self.step3EncoderValue
	modState.step4EncoderValue = self.step4EncoderValue
	modState.step5EncoderValue = self.step5EncoderValue
	modState.step6EncoderValue = self.step6EncoderValue
	modState.step7EncoderValue = self.step7EncoderValue
	modState.step8EncoderValue = self.step8EncoderValue
	modState.step9EncoderValue = self.step9EncoderValue
	modState.step10EncoderValue = self.step10EncoderValue
	modState.step11EncoderValue = self.step11EncoderValue
	modState.step12EncoderValue = self.step12EncoderValue
	modState.step13EncoderValue = self.step13EncoderValue
	modState.step14EncoderValue = self.step14EncoderValue
	modState.step15EncoderValue = self.step15EncoderValue
	modState.step16EncoderValue = self.step16EncoderValue


	return modState
end

function DrumMod:updateSamples()
	self:setSample(1, self.step1EncoderValue)
	self:setSample(2, self.step2EncoderValue)
	self:setSample(3, self.step3EncoderValue)
	self:setSample(4, self.step4EncoderValue)
	self:setSample(5, self.step5EncoderValue)
	self:setSample(6, self.step6EncoderValue)
	self:setSample(7, self.step7EncoderValue)
	self:setSample(8, self.step8EncoderValue)
	self:setSample(9, self.step9EncoderValue)
	self:setSample(10, self.step10EncoderValue)
	self:setSample(11, self.step11EncoderValue)
	self:setSample(12, self.step12EncoderValue)
	self:setSample(13, self.step13EncoderValue)
	self:setSample(14, self.step14EncoderValue)
	self:setSample(15, self.step15EncoderValue)
	self:setSample(16, self.step16EncoderValue)
end

function DrumMod:randomise()
	local rnd = math.random
	self.step1EncoderValue = rnd()
	self.step2EncoderValue = rnd()
	self.step3EncoderValue = rnd()
	self.step4EncoderValue = rnd()
	self.step5EncoderValue = rnd()
	self.step6EncoderValue = rnd()
	self.step7EncoderValue = rnd()
	self.step8EncoderValue = rnd()
	self.step9EncoderValue = rnd()
	self.step10EncoderValue = rnd()
	self.step11EncoderValue = rnd()
	self.step12EncoderValue = rnd()
	self.step13EncoderValue = rnd()
	self.step14EncoderValue = rnd()
	self.step15EncoderValue = rnd()
	self.step16EncoderValue = rnd()
	
	self:updateSamples()
	
	self:redrawBackground()
end

function DrumMod:setAllOff()
	self.step1EncoderValue = 0.0
	self.step2EncoderValue = 0.0
	self.step3EncoderValue = 0.0
	self.step4EncoderValue = 0.0
	self.step5EncoderValue = 0.0
	self.step6EncoderValue = 0.0
	self.step7EncoderValue = 0.0
	self.step8EncoderValue = 0.0
	self.step9EncoderValue = 0.0
	self.step10EncoderValue = 0.0
	self.step11EncoderValue = 0.0
	self.step12EncoderValue = 0.0
	self.step13EncoderValue = 0.0
	self.step14EncoderValue = 0.0
	self.step15EncoderValue = 0.0
	self.step16EncoderValue = 0.0
	self:updateSamples()
	self:redrawBackground()
end

function DrumMod:set44_808_Kick()
	local kickEncoderValue = 0.25
	self.step1EncoderValue = kickEncoderValue
	self.step5EncoderValue = kickEncoderValue
	self.step9EncoderValue = kickEncoderValue
	self.step13EncoderValue = kickEncoderValue
	self:updateSamples()
	self:redrawBackground()
end

function DrumMod:set44_909_Kick()
	local kickEncoderValue = 0.8
	self.step1EncoderValue = kickEncoderValue
	self.step5EncoderValue = kickEncoderValue
	self.step9EncoderValue = kickEncoderValue
	self.step13EncoderValue = kickEncoderValue
	self:updateSamples()
	self:redrawBackground()
end

function DrumMod:fromState(modState)
	self.step1EncoderValue = modState.step1EncoderValue
	self.step2EncoderValue = modState.step2EncoderValue
	self.step3EncoderValue = modState.step3EncoderValue
	self.step4EncoderValue = modState.step4EncoderValue
	self.step5EncoderValue = modState.step5EncoderValue
	self.step6EncoderValue = modState.step6EncoderValue
	self.step7EncoderValue = modState.step7EncoderValue
	self.step8EncoderValue = modState.step8EncoderValue
	self.step9EncoderValue = modState.step9EncoderValue
	self.step10EncoderValue = modState.step10EncoderValue
	self.step11EncoderValue = modState.step11EncoderValue
	self.step12EncoderValue = modState.step12EncoderValue
	self.step13EncoderValue = modState.step13EncoderValue
	self.step14EncoderValue = modState.step14EncoderValue
	self.step15EncoderValue = modState.step15EncoderValue
	self.step16EncoderValue = modState.step16EncoderValue
	
	self:setSample(1, self.step1EncoderValue)
	self:setSample(2, self.step2EncoderValue)
	self:setSample(3, self.step3EncoderValue)
	self:setSample(4, self.step4EncoderValue)
	self:setSample(5, self.step5EncoderValue)
	self:setSample(6, self.step6EncoderValue)
	self:setSample(7, self.step7EncoderValue)
	self:setSample(8, self.step8EncoderValue)
	self:setSample(9, self.step9EncoderValue)
	self:setSample(10, self.step10EncoderValue)
	self:setSample(11, self.step11EncoderValue)
	self:setSample(12, self.step12EncoderValue)
	self:setSample(13, self.step13EncoderValue)
	self:setSample(14, self.step14EncoderValue)
	self:setSample(15, self.step15EncoderValue)
	self:setSample(16, self.step16EncoderValue)
	
	self:redrawBackground()
end