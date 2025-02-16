--[[



]]--
import 'Modules/mod_utils.lua'
import 'Modules/Synths/OrlSynth/synth_component'
import 'Modules/Sprites/small_socket_sprite'

class('SynthMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local mod <const> = math.fmod

local moduleWidth = 85
local moduleHeight = 120

local logoImage = gfx.image.new("Images/orl_synth_logo")
local sineImage = playdate.graphics.image.new("Images/wf_sine")
local squareImage = playdate.graphics.image.new("Images/wf_square")
local triangleImage = playdate.graphics.image.new("Images/wf_triangle")
local sawtoothImage = playdate.graphics.image.new("Images/wf_sawtooth")
local poImage1 = playdate.graphics.image.new("Images/wf_po_1")
local poImage2 = playdate.graphics.image.new("Images/wf_po_2")
local poImage3 = playdate.graphics.image.new("Images/wf_po_3")
local curveImage = playdate.graphics.image.new("Images/envelope_curve")
local automatedImage = gfx.image.new("Images/encoder_automated")

local modType = "SynthMod"
local modSubtype = SourceTypes.audio_gen

function SynthMod:init(xx, yy, modId, onInit)
	SynthMod.super.init(self)
	
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
	
	logoImage:draw(48, 36)
	
	gfx.drawTextAligned("A",  30, 60, kTextAlignment.center)
	gfx.drawTextAligned("D",  55, 60, kTextAlignment.center)
	gfx.drawTextAligned("S",  30, 95, kTextAlignment.center)
	gfx.drawTextAligned("R",  55, 95, kTextAlignment.center)
	
	
	curveImage:draw(73, 91)
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 100)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(97, 100)
	rightSocket:draw(97, 27)
	rightSocket:draw(97, 58)
	
	--draw encoders
	local encoderLeftX = 22
	local encoderMidX = 46
	local encoderRightX = 71
	
	--waveform
	gEncoder:setValue(self.waveformEncoderValue)
	local waveformEncoderImage = gEncoder:getImage()
	waveformEncoderImage:draw(encoderLeftX, 36)

	gfx.popContext()
	
	self.backgroundImage = backgroundImage
	
	self.onInit = onInit
	
	--ADSR alignment
	local adsrColWidth = moduleWidth/4
	local adsrEncoderY1 = yy - (bgH/2) + 80
	local adsrEncoderY2 = yy - (bgH/2) + 115
	local shadowPadding = (bgW - moduleWidth)/2
	
	local encoderLeftX = xx - (moduleWidth/2) + 18
	local encoderMidX = xx
	local encoderRightX = xx + (moduleWidth/2) - 18
		
	self:moveTo(xx, yy)
	self:add()
	
	self.param1AutomationCounter = 1
	self.param2AutomationCounter = 1
			
	self.waveformSprite = gfx.sprite.new(sineImage)
	self.waveformSprite:moveTo(encoderLeftX, yy - (moduleHeight/2) + 12)
	self.waveformSprite:add()
	
	self.param1EncoderVector = Vector(encoderRightX, yy - (moduleHeight/2) + 32)
	self.param1EncoderValue = 0.0
	
	self.param2EncoderVector = Vector(encoderRightX, adsrEncoderY1)
	self.param2EncoderValue = 0.0
			
	self.waveformEncoderVector = Vector(encoderLeftX, yy - (moduleHeight/2) + 32)
	self.waveformEncoderValue = 0.0
	self.poParamsVisible = false

	--ADSR
	self.attackEncoderVector = Vector(encoderLeftX, adsrEncoderY1)
	self.attackEncoderValue = 0.1
	
	self.decayEncoderVector = Vector(encoderMidX, adsrEncoderY1)
	self.decayEncoderValue = 0.1

	self.sustainEncoderVector = Vector(encoderLeftX, adsrEncoderY2)
	self.sustainEncoderValue = 0.8
	
	self.releaseEncoderVector = Vector(encoderMidX, adsrEncoderY2)
	self.releaseEncoderValue = 0.6
	
	self.curveEncoderVector = Vector(encoderRightX, adsrEncoderY2)
	self.envelopeCurveEncoderValue = 0.5
	
	self.encoderVectors = {
		self.param1EncoderVector,
		self.param2EncoderVector,
		self.waveformEncoderVector,
		self.attackEncoderVector,
		self.decayEncoderVector,
		self.sustainEncoderVector,
		self.releaseEncoderVector,
		self.curveEncoderVector
	}
	
	self.socketInVector = Vector(xx - (moduleWidth/2)-2, yy - (moduleHeight/2) + 100)
	self.param1InVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + 27)
	self.param2InVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + 58)
	
	self.socketOutVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + 100)
	
	self.inSocketVectors = {
		self.socketInVector,
		self.param1InVector,
		self.param2InVector,
	}
	
	self.component = SynthComponent("synth_module", function(event)  		
		--Main in listener
	end, function(event) 
		--param1 listener
		self.param1EncoderValue = event:getValue()
	end, function(event) 
		--param2 listener
		self.param2EncoderValue = event:getValue()
	end, function(channel)
		self.onInit(self.modId, channel)
	end)
	
	self:redrawBackground()

end

function SynthMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = gfx.image.new(self.bgW, self.bgH)
	
		
	gfx.pushContext(backgroundImage)
	self.backgroundImage:draw(0, 0)
	--draw encoders
	local encoderLeftX = 22
	local encoderMidX = 46
	local encoderRightX = 71
	
	--waveform
	gEncoder:setValue(self.waveformEncoderValue)
	local waveformEncoderImage = gEncoder:getImage()
	waveformEncoderImage:draw(encoderLeftX, 36)
	
	if self.poParamsVisible then
		gfx.drawTextAligned("P1", 80, 25, kTextAlignment.center)
		gfx.drawTextAligned("P2", 80, 60, kTextAlignment.center)
		
		--param1
		if self.component:param1Connected() then
			automatedImage:draw(encoderRightX, 36)
		else
			gEncoder:setValue(self.param1EncoderValue)
			local param1EncoderImage = gEncoder:getImage()
			param1EncoderImage:draw(encoderRightX, 36)
		end
		
		--param2
		if self.component:param2Connected() then
			automatedImage:draw(encoderRightX, 70)
		else
			gEncoder:setValue(self.param2EncoderValue)
			local param2EncoderImage = gEncoder:getImage()
			param2EncoderImage:draw(encoderRightX, 70)
		end
	end
	
	--Attack
	gEncoder:setValue(self.attackEncoderValue)
	local attackEncoderImage = gEncoder:getImage()
	attackEncoderImage:draw(encoderLeftX, 70)
	
	--Decay
	gEncoder:setValue(self.decayEncoderValue)
	local decayEncoderImage = gEncoder:getImage()
	decayEncoderImage:draw(encoderMidX, 70)
	
	--Sustain
	gEncoder:setValue(self.sustainEncoderValue)
	local sustainEncoderImage = gEncoder:getImage()
	sustainEncoderImage:draw(encoderLeftX, 105)
	
	--Release
	gEncoder:setValue(self.releaseEncoderValue)
	local releaseEncoderImage = gEncoder:getImage()
	releaseEncoderImage:draw(encoderMidX, 105)
	
	--Curve
	gEncoder:setValue(self.envelopeCurveEncoderValue)
	local curveEncoderImage = gEncoder:getImage()
	curveEncoderImage:draw(encoderRightX, 105)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function SynthMod:hideTEParams()
	self.poParamsVisible = false
	self:redrawBackground()
end

function SynthMod:showTEParams()
	self.poParamsVisible = true
	self:redrawBackground()
end

function SynthMod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end
	
	if encoderVector == self.waveformEncoderVector then
		gEncoder:setValue(self.waveformEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.waveformEncoderVector.x, self.waveformEncoderVector.y)
		gEncoder:turn(change)
		self.waveformEncoderValue = gEncoder:getValue()
		self.waveformLabel = self.component:setWaveform(self.waveformEncoderValue)
		self.poParamsVisible = false
		if self.waveformLabel == "Sine" then
			self.waveformSprite:setImage(sineImage)
		elseif self.waveformLabel == "Square" then
			self.waveformSprite:setImage(squareImage)
			self:hideTEParams()
		elseif self.waveformLabel == "Triangle" then
			self.waveformSprite:setImage(triangleImage)
			self:hideTEParams()
		elseif self.waveformLabel == "Sawtooth" then
			self.waveformSprite:setImage(sawtoothImage)
			self:hideTEParams()
		elseif self.waveformLabel == "PO Phase" then
			self.waveformSprite:setImage(poImage1)
			self:showTEParams()
			self.poParamsVisible = true
		elseif self.waveformLabel == "PO Digital" then
			self.waveformSprite:setImage(poImage2)
			self:showTEParams()
			self.poParamsVisible = true
		elseif self.waveformLabel == "PO Vosim" then
			self.waveformSprite:setImage(poImage3)
			self:showTEParams()
			self.poParamsVisible = true
		end
	elseif encoderVector == self.attackEncoderVector then
		gEncoder:setValue(self.attackEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.attackEncoderVector.x, self.attackEncoderVector.y)
		gEncoder:turn(change)
		self.attackEncoderValue = gEncoder:getValue()
		self.component:setAttack(self.attackEncoderValue)
	elseif encoderVector == self.decayEncoderVector then
		gEncoder:setValue(self.decayEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.decayEncoderVector.x, self.decayEncoderVector.y)
		gEncoder:turn(change)
		self.decayEncoderValue = gEncoder:getValue()
		self.component:setDecay(self.decayEncoderValue)
	elseif encoderVector == self.sustainEncoderVector then
		gEncoder:setValue(self.sustainEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.sustainEncoderVector.x, self.sustainEncoderVector.y)
		gEncoder:turn(change)
		self.sustainEncoderValue = gEncoder:getValue()
		self.component:setSustain(self.sustainEncoderValue)
	elseif encoderVector == self.releaseEncoderVector then
		gEncoder:setValue(self.releaseEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.releaseEncoderVector.x, self.releaseEncoderVector.y)
		gEncoder:turn(change)
		self.releaseEncoderValue = gEncoder:getValue()
		self.component:setRelease(self.releaseEncoderValue)
	elseif encoderVector == self.curveEncoderVector then
		gEncoder:setValue(self.envelopeCurveEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.curveEncoderVector.x, self.curveEncoderVector.y)
		gEncoder:turn(change)
		self.envelopeCurveEncoderValue = gEncoder:getValue()
		self.component:setEnvelopeCurve(self.envelopeCurveEncoderValue)
	elseif encoderVector == self.param1EncoderVector then
		gEncoder:setValue(self.param1EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.param1EncoderVector.x, self.param1EncoderVector.y)
		gEncoder:turn(change)
		self.param1EncoderValue = gEncoder:getValue()
		self.component:setParameter1(self.param1EncoderValue)
	elseif encoderVector == self.param2EncoderVector then
		gEncoder:setValue(self.param2EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.param2EncoderVector.x, self.param2EncoderVector.y)
		gEncoder:turn(change)
		self.param2EncoderValue = gEncoder:getValue()
		self.component:setParameter2(self.param2EncoderValue)
	end
	
	self.redrawPending = true
end

function SynthMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function SynthMod:findClosestEncoderVector(x, y)
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

function SynthMod:findClosestInVector(x, y)
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

function SynthMod:setOutCable(patchCable)
	patchCable:setEnd(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	 self.component:setOutCable(patchCable:getCable())
end

function SynthMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

--The synth has multiple inputs so we need to find the closest socket...
function SynthMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype, onError)
	print("SOURCE SUBTYPE: " .. sourceSubtype)
	local inSocket = self:findClosestInVector(x, y)
	if inSocket.x == self.socketInVector.x and self.inCable == nil then
		if sourceSubtype ~= "midi" and sourceSubtype ~= "clock_router_or_midi" then 
			if onError ~= nil then onError("This input requires a midi signal") end
			return false 
		end
		ghostCable:setEnd(inSocket.x, inSocket.y)
		ghostCable:setGhostReceiveConnected()
		return true
	elseif inSocket.y == self.param1InVector.y and self.param1InCable == nil then
		if sourceSubtype == "midi" or sourceSubtype == "audio_gen" or sourceSubtype == "audio_effect" then 
			if onError ~= nil then onError("This input requires a value signal") end
			return false 
		end
		ghostCable:setEnd(inSocket.x, inSocket.y)
		ghostCable:setGhostReceiveConnected()
		return true
	elseif inSocket.y == self.param2InVector.y and self.param2InCable == nil then
		if sourceSubtype == "midi" or sourceSubtype == "audio_gen" or sourceSubtype == "audio_effect" then
			if onError ~= nil then onError("This input requires a value signal") end	
		  return false 
	 	end
		ghostCable:setEnd(inSocket.x, inSocket.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end

	return false
end

function SynthMod:setInCable(patchCable)
	local cableX, cableY = patchCable:getEndXY()
	local inSocket = self:findClosestInVector(cableX, cableY)
	patchCable:setEnd(inSocket.x, inSocket.y, self.modId)
	if inSocket.x == self.socketInVector.x then
		self.inCable = patchCable
		 self.component:setInCable(patchCable:getCable())
	elseif inSocket.y == self.param1InVector.y then
		self.param1InCable = patchCable
		 self.component:setParam1InCable(patchCable:getCable())
	elseif inSocket.y == self.param2InVector.y then
		self.param2InCable = patchCable
		 self.component:setParam2InCable(patchCable:getCable())
	end
end

function SynthMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function SynthMod:type()
	return modType
end

function SynthMod:getModId()
	return self.modId
end

function SynthMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Orl synth includes the standard waveforms and 3 Pocket Operator synths from Teenage Engineering. The TE synths have 2 additional parameters which can be automated.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end

	end)
end

function SynthMod:repositionBy(x, y)
	self:moveBy(x, y)
	self.waveformSprite:moveBy(x, y)
end

function SynthMod:moveFinish()
	local adsrColWidth = moduleWidth/4
	local adsrEncoderY1 = self.y - (self.bgH/2) + 80
	local adsrEncoderY2 = self.y - (self.bgH/2) + 115
	local shadowPadding = (self.bgW - moduleWidth)/2
	
	local encoderLeftX = self.x - (moduleWidth/2) + 18
	local encoderMidX = self.x
	local encoderRightX = self.x + (moduleWidth/2) - 18
	
	self.param1EncoderVector = Vector(encoderRightX, self.y - (moduleHeight/2) + 32)
	self.param2EncoderVector = Vector(encoderRightX, adsrEncoderY1)
	self.waveformEncoderVector = Vector(encoderLeftX, self.y - (moduleHeight/2) + 32)
	self.attackEncoderVector = Vector(encoderLeftX, adsrEncoderY1)
	self.decayEncoderVector = Vector(encoderMidX, adsrEncoderY1)
	self.sustainEncoderVector = Vector(encoderLeftX, adsrEncoderY2)
	self.releaseEncoderVector = Vector(encoderMidX, adsrEncoderY2)
	self.curveEncoderVector = Vector(encoderRightX, adsrEncoderY2)

	self.encoderVectors = {
		self.param1EncoderVector,
		self.param2EncoderVector,
		self.waveformEncoderVector,
		self.attackEncoderVector,
		self.decayEncoderVector,
		self.sustainEncoderVector,
		self.releaseEncoderVector,
		self.curveEncoderVector
	}
	
	self.socketInVector = Vector(self.x - (moduleWidth/2)-2, self.y - (moduleHeight/2) + 100)
	self.param1InVector = Vector(self.x + (moduleWidth/2)+2, self.y - (moduleHeight/2) + 27)
	self.param2InVector = Vector(self.x + (moduleWidth/2)+2, self.y - (moduleHeight/2) + 58)
	self.socketOutVector = Vector(self.x + (moduleWidth/2)+2, self.y - (moduleHeight/2) + 100)
	
	self.inSocketVectors = {
		self.socketInVector,
		self.param1InVector,
		self.param2InVector
	}
	
end

function SynthMod:evaporate(onDetachConnected)
	--first stop any notes playing:
	self.component:stopAll()
	
	--first detach cables
	if self.component:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		 self.component:unplugIn()
		self.inCable:evaporate()
		self.inCable = nil
	end
	
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		 self.component:unplugOut()
		self.outCable:evaporate()
		self.outCable = nil
	end
	
	if self.component:param1Connected() then
		onDetachConnected(self.param1InCable:getStartModId(), self.param1InCable:getCableId())
		 self.component:unplugParam1()
		self.param1InCable:evaporate()
		self.param1InCable = nil
	end
	
	if self.component:param2Connected() then
		onDetachConnected(self.param2InCable:getStartModId(), self.param2InCable:getCableId())
		 self.component:unplugParam2()
		self.param2InCable:evaporate()
		self.param2InCable = nil
	end

	self.waveformSprite:remove()
	self.waveformSprite = nil
	
	self:remove()
end

function SynthMod:unplug(cableId)
	if self.component:inConnected() and "" .. self.inCable:getCableId() == "" .. cableId then
		 self.component:unplugIn()
		self.inCable = nil
	end
	
	if self.component:outConnected() and "" .. self.outCable:getCableId() == "" .. cableId then
		 self.component:unplugOut()
		self.outCable = nil
	end
	
	if self.component:param1Connected() and "" .. self.param1InCable:getCableId() == "" .. cableId then
		 self.component:unplugParam1()
		self.param1InCable = nil
	end
	
	if self.component:param2Connected() and "" .. self.param2InCable:getCableId() == "" .. cableId then
		 self.component:unplugParam2()
		self.param2InCable = nil
	end
end

function SynthMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function SynthMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.waveformEncoderValue = self.waveformEncoderValue
	modState.param1EncoderValue = self.param1EncoderValue
	modState.param2EncoderValue = self.param2EncoderValue
	modState.attackEncoderValue = self.attackEncoderValue
	modState.decayEncoderValue = self.decayEncoderValue
	modState.sustainEncoderValue = self.sustainEncoderValue
	modState.releaseEncoderValue = self.releaseEncoderValue
	modState.envelopeCurveEncoderValue = self.envelopeCurveEncoderValue
	return modState
end

function SynthMod:fromState(modState)
	self.waveformEncoderValue = modState.waveformEncoderValue
	self.waveformLabel = self.component:setWaveform(self.waveformEncoderValue)
	self.poParamsVisible = false
	if self.waveformLabel == "Sine" then
		self.waveformSprite:setImage(sineImage)
	elseif self.waveformLabel == "Square" then
		self.waveformSprite:setImage(squareImage)
	elseif self.waveformLabel == "Triangle" then
		self.waveformSprite:setImage(triangleImage)
	elseif self.waveformLabel == "Sawtooth" then
		self.waveformSprite:setImage(sawtoothImage)
	elseif self.waveformLabel == "PO Phase" then
		self.waveformSprite:setImage(poImage1)
		self.poParamsVisible = true
	elseif self.waveformLabel == "PO Digital" then
		self.waveformSprite:setImage(poImage2)
		self.poParamsVisible = true
	elseif self.waveformLabel == "PO Vosim" then
		self.waveformSprite:setImage(poImage3)
		self.poParamsVisible = true
	end
	
	self.param1EncoderValue = modState.param1EncoderValue
	self.component:setParameter1(self.param1EncoderValue)
	
	self.param2EncoderValue = modState.param2EncoderValue
	self.component:setParameter2(self.param2EncoderValue)
	
	self.attackEncoderValue = modState.attackEncoderValue
	self.component:setAttack(self.attackEncoderValue)
	
	self.decayEncoderValue = modState.decayEncoderValue
	self.component:setDecay(self.decayEncoderValue)
	
	self.sustainEncoderValue = modState.sustainEncoderValue
	self.component:setSustain(self.sustainEncoderValue)
	
	self.releaseEncoderValue = modState.releaseEncoderValue
	self.component:setRelease(self.releaseEncoderValue)
	
	self.envelopeCurveEncoderValue = modState.envelopeCurveEncoderValue
	self.component:setEnvelopeCurve(self.envelopeCurveEncoderValue)
	
	self:redrawBackground()
end