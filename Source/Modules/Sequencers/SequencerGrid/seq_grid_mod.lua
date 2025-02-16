--[[


]]--
import 'Modules/mod_utils.lua'
import 'midi'
import 'Coracle/vector'
import 'CoracleViews/rotary_encoder'
import 'Modules/Sequencers/SequencerGrid/seq_grid_component'

class('SeqGridMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 100
local moduleHeight = 145

local stepImage = playdate.graphics.image.new("Images/step")

local modType = "SeqGridMod"
local modSubtype = "midi"

function SeqGridMod:init(xx, yy, modId)
	SeqGridMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.midi = Midi()
	self.midiValues = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	
	
	self.noteLabels = {"--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--"}
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = backgroundImage:getSize()
	self.bgW = bgW
	self.bgH = bgH
	gfx.pushContext(backgroundImage)
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(gPedalLeftJackX, gPedalAudioIOY)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(113, gPedalAudioIOY)
	gfx.popContext()
	
	self.backgroundImage = backgroundImage
	
	self:moveTo(xx, yy)
	self:add()
	
	self.col1X = xx -  (2 * 23) + 11
	self.col2X = xx -  (1 * 23) + 11
	self.col3X = xx +  (1 * 23) - 11
	self.col4X = xx +  (2 * 23) - 11
	
	self.row1Y = yy - (moduleHeight/2) + 28
	self.row2Y = yy - (moduleHeight/2) + 62
	self.row3Y = yy - (moduleHeight/2) + 96
	self.row4Y = yy - (moduleHeight/2) + 130
	
	local socketInY = yy - (moduleHeight/2) + 22
	local socketOutY = yy - (moduleHeight/2) + 124
	
	self.stepSprite = gfx.sprite.new(stepImage)
	self.stepSprite:moveTo(self.col1X, self.row1Y)
	
	local topRowOffset = 30
	local bottomRowOffset = 6
	self.component = SeqGridComponent(function(step) 
		if step == 1 then
			self.stepSprite:moveTo(self.col1X, self.row1Y)
		elseif step == 2 then
			self.stepSprite:moveTo(self.col2X, self.row1Y)
		elseif step == 3 then
			self.stepSprite:moveTo(self.col3X, self.row1Y)
		elseif step == 4 then
			self.stepSprite:moveTo(self.col4X, self.row1Y)
		elseif step == 5 then
			self.stepSprite:moveTo(self.col1X, self.row2Y)
		elseif step == 6 then
			self.stepSprite:moveTo(self.col2X, self.row2Y)
		elseif step == 7 then
			self.stepSprite:moveTo(self.col3X, self.row2Y)	
		elseif step == 8 then
			self.stepSprite:moveTo(self.col4X, self.row2Y)		
		elseif step == 9 then
			self.stepSprite:moveTo(self.col1X, self.row3Y)
		elseif step == 10 then
			self.stepSprite:moveTo(self.col2X, self.row3Y)
		elseif step == 11 then
			self.stepSprite:moveTo(self.col3X, self.row3Y)
		elseif step == 12 then
			self.stepSprite:moveTo(self.col4X, self.row3Y)
		elseif step == 13 then
			self.stepSprite:moveTo(self.col1X, self.row4Y)
		elseif step == 14 then
			self.stepSprite:moveTo(self.col2X, self.row4Y)
		elseif step == 15 then
			self.stepSprite:moveTo(self.col3X, self.row4Y)	
		elseif step == 16 then
			self.stepSprite:moveTo(self.col4X, self.row4Y)			
		end
	end)
	

	self.step1EncoderVector = Vector(self.col1X, self.row1Y)
	self.step1EncoderValue = 0.0

	self.step2EncoderVector = Vector(self.col2X, self.row1Y)
	self.step2EncoderValue = 0.0
	
	self.step3EncoderVector = Vector(self.col3X, self.row1Y)
	self.step3EncoderValue = 0.0
	
	self.step4EncoderVector = Vector(self.col4X, self.row1Y)
	self.step4EncoderValue = 0.0
	
	self.step5EncoderVector = Vector(self.col1X, self.row2Y)
	self.step5EncoderValue = 0.0
	
	self.step6EncoderVector = Vector(self.col2X, self.row2Y)
	self.step6EncoderValue = 0.0
	
	self.step7EncoderVector = Vector(self.col3X, self.row2Y)
	self.step7EncoderValue = 0.0
	
	self.step8EncoderVector = Vector(self.col4X, self.row2Y)
	self.step8EncoderValue = 0.0
	
	self.step9EncoderVector = Vector(self.col1X, self.row3Y)
	self.step9EncoderValue = 0.0
	
	self.step10EncoderVector = Vector(self.col2X, self.row3Y)
	self.step10EncoderValue = 0.0
	
	self.step11EncoderVector = Vector(self.col3X, self.row3Y)
	self.step11EncoderValue = 0.0
	
	self.step12EncoderVector = Vector(self.col4X, self.row3Y)
	self.step12EncoderValue = 0.0
	
	self.step13EncoderVector = Vector(self.col1X, self.row4Y)
	self.step13EncoderValue = 0.0
	
	self.step14EncoderVector = Vector(self.col2X, self.row4Y)
	self.step14EncoderValue = 0.0
	
	self.step15EncoderVector = Vector(self.col3X, self.row4Y)
	self.step15EncoderValue = 0.0
	
	self.step16EncoderVector = Vector(self.col4X, self.row4Y)
	self.step16EncoderValue = 0.0
	
	--Add step sprite after the encoders so it draws on top:
	self.stepSprite:add()
	
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
	
	self.socketInVector = Vector(xx - (moduleWidth/2)-2, yy - (moduleHeight/2) + gPedalAudioIOY)
	self.socketOutVector = Vector	(xx + 52, yy - (moduleHeight/2) + gPedalAudioIOY)
		
	self:redrawBackground()
end

function SeqGridMod:setNote(index, value)
	if value == 0.0 then
		self.noteLabels[index] = "--"
		self:redrawBackground()
		self.component:setValue(index, -1)
	else
		local midiNote = math.floor(map(value, 0.0, 1.0, 21, 127))
		self.noteLabels[index] =  self.midi:noteNumberToLabelNoOctave(midiNote)
		self:redrawBackground()
		self.component:setValue(index, midiNote)
	end

end

function SeqGridMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = gfx.image.new(self.bgW, self.bgH)	
	gfx.pushContext(backgroundImage)
	
	self.backgroundImage:draw(0, 0)
	
	local leftPadding = (self.bgW - moduleWidth)/2 - 11
	local columnWidth = (moduleWidth/4) - 1
	
	-- Row 1
	gEncoder:setValue(self.step1EncoderValue)
	local step1EncoderImage = gEncoder:getImage()
	step1EncoderImage:draw(leftPadding + (1 * columnWidth) - 9, 32)
	
	gEncoder:setValue(self.step2EncoderValue)
	local step2EncoderImage = gEncoder:getImage()
	step2EncoderImage:draw(leftPadding + (2 * columnWidth) - 9, 32)
	
	gEncoder:setValue(self.step3EncoderValue)
	local step3EncoderImage = gEncoder:getImage()
	step3EncoderImage:draw(leftPadding + (3 * columnWidth) - 9, 32)
	
	gEncoder:setValue(self.step4EncoderValue)
	local step4EncoderImage = gEncoder:getImage()
	step4EncoderImage:draw(leftPadding + (4 * columnWidth) - 9, 32)
	
	for tr=1, 4 do
		gfx.drawTextAligned(self.noteLabels[tr], leftPadding + (tr * columnWidth), 22, kTextAlignment.center)
	end
	
	-- Row 2
	gEncoder:setValue(self.step5EncoderValue)
	local step5EncoderImage = gEncoder:getImage()
	step5EncoderImage:draw(leftPadding + ((5-4) * columnWidth) - 9, 66)
	
	gEncoder:setValue(self.step6EncoderValue)
	local step6EncoderImage = gEncoder:getImage()
	step6EncoderImage:draw(leftPadding + ((6-4) * columnWidth) - 9, 66)
	
	gEncoder:setValue(self.step7EncoderValue)
	local step7EncoderImage = gEncoder:getImage()
	step7EncoderImage:draw(leftPadding + ((7-4) * columnWidth) - 9, 66)
	
	gEncoder:setValue(self.step8EncoderValue)
	local step8EncoderImage = gEncoder:getImage()
	step8EncoderImage:draw(leftPadding + ((8-4) * columnWidth) - 9, 66)
	
	for tr=5, 8 do
		gfx.drawTextAligned(self.noteLabels[tr], leftPadding + ((tr-4) * columnWidth), 56, kTextAlignment.center)
	end
	
	-- Row 3
	gEncoder:setValue(self.step9EncoderValue)
	local step9EncoderImage = gEncoder:getImage()
	step9EncoderImage:draw(leftPadding + ((9-8) * columnWidth) - 9, 100)
	
	gEncoder:setValue(self.step10EncoderValue)
	local step10EncoderImage = gEncoder:getImage()
	step10EncoderImage:draw(leftPadding + ((10-8) * columnWidth) - 9, 100)
	
	gEncoder:setValue(self.step11EncoderValue)
	local step11EncoderImage = gEncoder:getImage()
	step11EncoderImage:draw(leftPadding + ((11-8) * columnWidth) - 9, 100)
	
	gEncoder:setValue(self.step12EncoderValue)
	local step12EncoderImage = gEncoder:getImage()
	step12EncoderImage:draw(leftPadding + ((12-8) * columnWidth) - 9, 100)
	
	for tr=9, 12 do
		gfx.drawTextAligned(self.noteLabels[tr], leftPadding + ((tr-8) * columnWidth), 90, kTextAlignment.center)
	end
	
	-- Row 4
	gEncoder:setValue(self.step13EncoderValue)
	local step13EncoderImage = gEncoder:getImage()
	step13EncoderImage:draw(leftPadding + ((13-12) * columnWidth) - 9, 134)
	
	gEncoder:setValue(self.step14EncoderValue)
	local step14EncoderImage = gEncoder:getImage()
	step14EncoderImage:draw(leftPadding + ((14-12) * columnWidth) - 9, 134)
	
	gEncoder:setValue(self.step15EncoderValue)
	local step15EncoderImage = gEncoder:getImage()
	step15EncoderImage:draw(leftPadding + ((15-12) * columnWidth) - 9, 134)
	
	gEncoder:setValue(self.step16EncoderValue)
	local step16EncoderImage = gEncoder:getImage()
	step16EncoderImage:draw(leftPadding + ((16-12) * columnWidth) - 9, 134)
	
	for tr=13, 16 do
		gfx.drawTextAligned(self.noteLabels[tr], leftPadding + ((tr-12) * columnWidth), 124, kTextAlignment.center)
	end
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function SeqGridMod:turn(x, y, change)
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
		self:setNote(1, self.step1EncoderValue)
	elseif encoderVector == self.step2EncoderVector then
		gEncoder:setValue(self.step2EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step2EncoderVector.x, self.step2EncoderVector.y)
		gEncoder:turn(change)
		self.step2EncoderValue = gEncoder:getValue()
		self:setNote(2, self.step2EncoderValue)
	elseif encoderVector == self.step3EncoderVector then
		gEncoder:setValue(self.step3EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step3EncoderVector.x, self.step3EncoderVector.y)
		gEncoder:turn(change)
		self.step3EncoderValue = gEncoder:getValue()
		self:setNote(3, self.step3EncoderValue)
	elseif encoderVector == self.step4EncoderVector then
		gEncoder:setValue(self.step4EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step4EncoderVector.x, self.step4EncoderVector.y)
		gEncoder:turn(change)
		self.step4EncoderValue = gEncoder:getValue()
		self:setNote(4, self.step4EncoderValue)
	elseif encoderVector == self.step5EncoderVector then
		gEncoder:setValue(self.step5EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step5EncoderVector.x, self.step5EncoderVector.y)
		gEncoder:turn(change)
		self.step5EncoderValue = gEncoder:getValue()
		self:setNote(5, self.step5EncoderValue)
	elseif encoderVector == self.step6EncoderVector then
		gEncoder:setValue(self.step6EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step6EncoderVector.x, self.step6EncoderVector.y)
		gEncoder:turn(change)
		self.step6EncoderValue = gEncoder:getValue()
		self:setNote(6, self.step6EncoderValue)
	elseif encoderVector == self.step7EncoderVector then
		gEncoder:setValue(self.step7EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step7EncoderVector.x, self.step7EncoderVector.y)
		gEncoder:turn(change)
		self.step7EncoderValue = gEncoder:getValue()
		self:setNote(7, self.step7EncoderValue)	
	elseif encoderVector == self.step8EncoderVector then
		gEncoder:setValue(self.step8EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step8EncoderVector.x, self.step8EncoderVector.y)
		gEncoder:turn(change)
		self.step8EncoderValue = gEncoder:getValue()
		self:setNote(8, self.step8EncoderValue)
	elseif encoderVector == self.step9EncoderVector then
		gEncoder:setValue(self.step9EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step9EncoderVector.x, self.step9EncoderVector.y)
		gEncoder:turn(change)
		self.step9EncoderValue = gEncoder:getValue()
		self:setNote(9, self.step9EncoderValue)	
	elseif encoderVector == self.step10EncoderVector then
		gEncoder:setValue(self.step10EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step10EncoderVector.x, self.step10EncoderVector.y)
		gEncoder:turn(change)
		self.step10EncoderValue = gEncoder:getValue()
		self:setNote(10, self.step10EncoderValue)	
	elseif encoderVector == self.step11EncoderVector then
		gEncoder:setValue(self.step11EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step11EncoderVector.x, self.step11EncoderVector.y)
		gEncoder:turn(change)
		self.step11EncoderValue = gEncoder:getValue()
		self:setNote(11, self.step11EncoderValue)	
	elseif encoderVector == self.step12EncoderVector then
		gEncoder:setValue(self.step12EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step12EncoderVector.x, self.step12EncoderVector.y)
		gEncoder:turn(change)
		self.step12EncoderValue = gEncoder:getValue()
		self:setNote(12, self.step12EncoderValue)	
	elseif encoderVector == self.step13EncoderVector then
		gEncoder:setValue(self.step13EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step13EncoderVector.x, self.step13EncoderVector.y)
		gEncoder:turn(change)
		self.step13EncoderValue = gEncoder:getValue()
		self:setNote(13, self.step13EncoderValue)	
	elseif encoderVector == self.step14EncoderVector then
		gEncoder:setValue(self.step14EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step14EncoderVector.x, self.step14EncoderVector.y)
		gEncoder:turn(change)
		self.step14EncoderValue = gEncoder:getValue()
		self:setNote(14, self.step14EncoderValue)	
	elseif encoderVector == self.step15EncoderVector then
		gEncoder:setValue(self.step15EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step15EncoderVector.x, self.step15EncoderVector.y)
		gEncoder:turn(change)
		self.step15EncoderValue = gEncoder:getValue()
		self:setNote(15, self.step15EncoderValue)	
	elseif encoderVector == self.step16EncoderVector then
		gEncoder:setValue(self.step16EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.step16EncoderVector.x, self.step16EncoderVector.y)
		gEncoder:turn(change)
		self.step16EncoderValue = gEncoder:getValue()
		self:setNote(16, self.step16EncoderValue)	
	end
	self.redrawPending = true
end

function SeqGridMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function SeqGridMod:findClosestEncoderVector(x, y)
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



function SeqGridMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function SeqGridMod:setOutCable(patchCable)
	patchCable:setEnd(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function SeqGridMod:collision(x, y)
	if x > self.x - (self.width/2) and x < self.x + (self.width/2) and y > self.y - (self.height/2) and y < self.y + (self.height/2) then
		return true
	else
		return false
	end
end

function SeqGridMod:tryConnectGhostIn(x, y, ghostCable)
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function SeqGridMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function SeqGridMod:type()
	return self.modType
end

function SeqGridMod:getModId()
	return self.modId
end

function SeqGridMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "Toggle sustain mode"},
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "Toggle sustain mode" then
			self.component:toggleNoteOffMode()
		elseif action == "About" then
			local aboutPopup = ModAboutPopup("A basic 16 step note sequencer. Encoder fully off will either let the note continue, or send a note off value depending on the menu toggle.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end

	end)
end

function SeqGridMod:unplug(cableId)
	if self.component:inConnected() and self.inCable:getCableId() == cableId then
	 	self.component:unplugIn()
		self.inCable = nil
	end
	
	if self.component:outConnected() and self.outCable:getCableId() == cableId then
	 	self.component:unplugOut()
		self.outCable = nil
	end
end

function SeqGridMod:repositionBy(x, y)
	self:moveBy(x, y)
	self.stepSprite:moveBy(x, y)
end

function SeqGridMod:moveFinish()
	self.col1X = self.x -  (2 * 23) + 11
	self.col2X = self.x -  (1 * 23) + 11
	self.col3X = self.x +  (1 * 23) - 11
	self.col4X = self.x +  (2 * 23) - 11
	
	self.row1Y = self.y - (moduleHeight/2) + 28
	self.row2Y = self.y - (moduleHeight/2) + 62
	self.row3Y = self.y - (moduleHeight/2) + 96
	self.row4Y = self.y - (moduleHeight/2) + 130
	
	self.step1EncoderVector = Vector(self.col1X, self.row1Y)
	self.step2EncoderVector = Vector(self.col2X, self.row1Y)
	self.step3EncoderVector = Vector(self.col3X, self.row1Y)
	self.step4EncoderVector = Vector(self.col4X, self.row1Y)
	self.step5EncoderVector = Vector(self.col1X, self.row2Y)
	self.step6EncoderVector = Vector(self.col2X, self.row2Y)
	self.step7EncoderVector = Vector(self.col3X, self.row2Y)
	self.step8EncoderVector = Vector(self.col4X, self.row2Y)
	self.step9EncoderVector = Vector(self.col1X, self.row3Y)
	self.step10EncoderVector = Vector(self.col2X, self.row3Y)
	self.step11EncoderVector = Vector(self.col3X, self.row3Y)
	self.step12EncoderVector = Vector(self.col4X, self.row3Y)
	self.step13EncoderVector = Vector(self.col1X, self.row4Y)
	self.step14EncoderVector = Vector(self.col2X, self.row4Y)
	self.step15EncoderVector = Vector(self.col3X, self.row4Y)
	self.step16EncoderVector = Vector(self.col4X, self.row4Y)
	
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
	
	self.socketInVector = Vector(self.x - (moduleWidth/2)-2, self.y - (moduleHeight/2) + gPedalAudioIOY)
	self.socketOutVector = Vector	(self.x + 52, self.y - (moduleHeight/2) + gPedalAudioIOY)
end

function SeqGridMod:evaporate(onDetachConnected)
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
	self.stepSprite:remove()
	self.stepSprite = nil

	self:remove()
end

function SeqGridMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function SeqGridMod:toState()
	print("CREATING SEQGRID STATE")
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

function SeqGridMod:fromState(modState)
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
	
	self:setNote(1, self.step1EncoderValue)
	self:setNote(2, self.step2EncoderValue)
	self:setNote(3, self.step3EncoderValue)
	self:setNote(4, self.step4EncoderValue)
	self:setNote(5, self.step5EncoderValue)
	self:setNote(6, self.step6EncoderValue)
	self:setNote(7, self.step7EncoderValue)
	self:setNote(8, self.step8EncoderValue)
	self:setNote(9, self.step9EncoderValue)
	self:setNote(10, self.step10EncoderValue)
	self:setNote(11, self.step11EncoderValue)
	self:setNote(12, self.step12EncoderValue)
	self:setNote(13, self.step13EncoderValue)
	self:setNote(14, self.step14EncoderValue)
	self:setNote(15, self.step15EncoderValue)
	self:setNote(16, self.step16EncoderValue)
	
	
	self:redrawBackground()

end