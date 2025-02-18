--[[
	© 2023 Orllewin - All Rights Reserved.
]]--
import 'Modules/mod_utils.lua'
import 'Modules/Synths/WaveTableSynth2D/wavetable_synth2d_component'

class('WavetableSynth2DMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local mod <const> = math.fmod

local moduleWidth = 85
local moduleHeight = 120
local bannerImage = gfx.image.new("Images/wavetable_mod_banner")
local curveImage = gfx.image.new("Images/envelope_curve")
local wt2dImage = gfx.image.new("Images/wt2d")

local modType = "WavetableSynth2DMod"
local modSubtype = SourceTypes.audio_gen

function WavetableSynth2DMod:init(xx, yy, modId, onInit)
	WavetableSynth2DMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	self.onInit = onInit
	
	self.redrawPending = true
	self.waveTableName = "FAIRLIGHT1"
	
	--ADSR alignment
	local bgW = moduleWidth + 14
	local bgH = moduleHeight + 25
	self.bgW = bgW
	self.bgH = bgH
	local adsrColWidth = moduleWidth/4
	local adsrEncoderY1 = yy - (bgH/2) + 80
	local adsrEncoderY2 = yy - (bgH/2) + 115
	local shadowPadding = (bgW - moduleWidth)/2
	
	local encoderLeftX = xx - (moduleWidth/2) + 18
	local encoderMidX = xx
	local encoderRightX = xx + (moduleWidth/2) - 18

	self:redrawBackground()
	self:moveTo(xx, yy)
	self:add()
	
	self.component = WavetableSynth2DComponent("synth_module", function(event)  		
		--Main in listener
	end, function(event) 
		--paramX listener
		self.paramXEncoderValue = event:getValue()
	end, function(event) 
		--paramY listener
		self.paramYEncoderValue = event:getValue()
	end, function(channel)
		self.onInit(self.modId, channel)
	end)
		
	self.paramXEncoderVector = Vector(encoderLeftX, yy - (moduleHeight/2) + 32)
	self.paramXEncoderValue = 0.0
	
	self.paramYEncoderVector = Vector(encoderRightX, yy - (moduleHeight/2) + 32)
	self.paramYEncoderValue = 0.0
	
	--ADSR
	self.attackEncoderVector = Vector(encoderLeftX, adsrEncoderY1)
	self.attackEncoderValue = 0.1
	
	self.decayEncoderVector = Vector(encoderRightX, adsrEncoderY1)
	self.decayEncoderValue = 0.1
	
	self.sustainEncoderVector = Vector(encoderLeftX, adsrEncoderY2)
	self.sustainEncoderValue = 0.8
	
	self.releaseEncoderVector = Vector(encoderMidX, adsrEncoderY2)
	self.releaseEncoderValue = 1.0
	
	self.envelopeCurveEncoderVector = Vector(encoderRightX, adsrEncoderY2)
	self.envelopeCurveEncoderValue = 0.5
		
	self.encoderVectors = {
		self.paramXEncoderVector,
		self.paramYEncoderVector,
		self.attackEncoderVector,
		self.decayEncoderVector,
		self.sustainEncoderVector,
		self.releaseEncoderVector,
		self.envelopeCurveEncoderVector,
	}
	
	self.socketInVector = Vector(xx - (moduleWidth/2)-2, yy - (moduleHeight/2) + 100)
	self.paramXInVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + 27)
	self.paramYInVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + 58)
	
	self.socketOutVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + 100)
	
	self.inSocketVectors = {
		self.socketInVector,
		self.paramXInVector,
		self.paramYInVector,
	}
	
	self:redrawBackground()
end

function WavetableSynth2DMod:redrawBackground()
	if self.redrawPending == false then
		return
	end
	gEncoder:hide()
	self.backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = self.backgroundImage:getSize()
	

	gfx.pushContext(self.backgroundImage)
	
	gfx.drawTextAligned("A",  30, 60, kTextAlignment.center)
	gfx.drawTextAligned("D",  80, 60, kTextAlignment.center)
	gfx.drawTextAligned("S",  30, 95, kTextAlignment.center)
	gfx.drawTextAligned("R",  55, 95, kTextAlignment.center)
	
	--draw encoders
	local encoderLeftX = 22
	local encoderMidX = 46
	local encoderRightX = 71
	
	--X
	gEncoder:setValue(self.paramXEncoderValue)
	local attackEncoderImage = gEncoder:getImage()
	attackEncoderImage:draw(encoderLeftX, 35)
	
	--Y
	gEncoder:setValue(self.paramYEncoderValue)
	local attackEncoderImage = gEncoder:getImage()
	attackEncoderImage:draw(encoderRightX, 35)
	
	--Attack
	gEncoder:setValue(self.attackEncoderValue)
	local attackEncoderImage = gEncoder:getImage()
	attackEncoderImage:draw(encoderLeftX, 70)
	
	--Decay
	gEncoder:setValue(self.decayEncoderValue)
	local decayEncoderImage = gEncoder:getImage()
	decayEncoderImage:draw(encoderRightX, 70)
	
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
	
	curveImage:draw(73, 91)
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 100)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(97, 100)
	rightSocket:draw(97, 27)
	rightSocket:draw(97, 58)
	
	gfx.drawTextAligned("X", 48, 43, kTextAlignment.center)
	gfx.drawTextAligned("Y", 65, 43, kTextAlignment.center)
	
	local wtLabel = replace(self.waveTableName, "_256", "")
	wtLabel = replace(wtLabel, ".pda", "")
	gfx.drawTextAligned(wtLabel, bgW/2, 25, kTextAlignment.center)
	
	wt2dImage:draw(45, 54)
	
	gfx.popContext()
	
	self:setImage(self.backgroundImage)
	
	self.redrawPending = false
end

function WavetableSynth2DMod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end
	
	if encoderVector == self.paramXEncoderVector then
		gEncoder:setValue(self.paramXEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.paramXEncoderVector.x, self.paramXEncoderVector.y)
		gEncoder:turn(change)
		self.paramXEncoderValue = gEncoder:getValue()
		self.component:setXMorph(self.paramXEncoderValue)
	elseif encoderVector == self.paramYEncoderVector then
		gEncoder:setValue(self.paramYEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.paramYEncoderVector.x, self.paramYEncoderVector.y)
		gEncoder:turn(change)
		self.paramYEncoderValue = gEncoder:getValue()
		self.component:setYMorph(self.paramYEncoderValue)
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
	elseif encoderVector == self.envelopeCurveEncoderVector then
		gEncoder:setValue(self.envelopeCurveEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.envelopeCurveEncoderVector.x, self.envelopeCurveEncoderVector.y)
		gEncoder:turn(change)
		self.envelopeCurveEncoderValue = gEncoder:getValue()
		self.component:setEnvelopeCurve(self.envelopeCurveEncoderValue)
	end
	self.redrawPending = true
	end
	
function WavetableSynth2DMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function WavetableSynth2DMod:findClosestEncoderVector(x, y)
	local reticleVector = Vector(x, y)
	local closestDistance = 1000
	local closestIndex = -1
	for i=1,#self.encoderVectors do
		local anEncoder = self.encoderVectors[i]
		local encoderVector = Vector(anEncoder.x, anEncoder.y)
		local distance = reticleVector:distance(encoderVector)
		if distance < closestDistance then
			closestDistance = distance
			closestIndex = i
		end
	end
	
	return self.encoderVectors[closestIndex]
end

function WavetableSynth2DMod:findClosestInVector(x, y)
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

function WavetableSynth2DMod:setOutCable(patchCable)
	patchCable:setEnd(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function WavetableSynth2DMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

--The synth has multiple inputs so we need to find the closest socket...
function WavetableSynth2DMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype, onError)
	local inSocket = self:findClosestInVector(x, y)
	if inSocket.x == self.socketInVector.x and self.inCable == nil then
		if sourceSubtype ~= "midi"  and sourceSubtype ~= "clock_router_or_midi" then 
			if onError ~= nil then onError("This input requires a midi signal") end
			return false 
		end
		ghostCable:setEnd(inSocket.x, inSocket.y)
		ghostCable:setGhostReceiveConnected()
		return true
	elseif inSocket.y == self.paramXInVector.y and self.paramXInCable == nil then
		if sourceSubtype == "clock_router" or sourceSubtype == "midi" or sourceSubtype == "audio_gen" or sourceSubtype == "audio_effect" then 
			if onError ~= nil then onError("This input requires a value signal") end
			return false 
		end
		ghostCable:setEnd(self.paramXInVector.x, self.paramXInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	elseif inSocket.y == self.paramYInVector.y and self.paramYInCable == nil then
		if sourceSubtype == "clock_router" or sourceSubtype == "midi" or sourceSubtype == "audio_gen" or sourceSubtype == "audio_effect" then 
			if onError ~= nil then onError("This input requires a value signal") end
			return false 
		end
		ghostCable:setEnd(self.paramYInVector.x, self.paramYInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end

	return false
end

function WavetableSynth2DMod:setInCable(patchCable)
	local cableX, cableY = patchCable:getEndXY()
	local inSocket = self:findClosestInVector(cableX, cableY)
	patchCable:setEnd(inSocket.x, inSocket.y, self.modId)
	if inSocket.x == self.socketInVector.x then
		self.inCable = patchCable
		self.component:setInCable(patchCable:getCable())
	elseif inSocket.y == self.paramXInVector.y then
		self.paramXInCable = patchCable
		self.component:setParamXInCable(patchCable:getCable())
	elseif inSocket.y == self.paramYInVector.y then
		self.paramYInCable = patchCable
		self.component:setParamYInCable(patchCable:getCable())
	end
end

function WavetableSynth2DMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function WavetableSynth2DMod:type()
	return modType
end

function WavetableSynth2DMod:getModId()
	return self.modId
end

function WavetableSynth2DMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	
	local wavetables = playdate.file.listFiles("Wavetables/")
	
	local actions = {}
	for w=1,#wavetables do
		local entry = {
			label = "" .. wavetables[w]
		}
		table.insert(actions, entry)
	end
	
	table.insert(actions, {label="About"})
	table.insert(actions, {label="Move"})
	table.insert(actions, {label="Remove"})
	
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 		
		if action == "About" then
			local aboutPopup = ModAboutPopup("A wavetable synth. All wavetables are from waveeditonline.com (CC0 1.0 Universal (CC0 1.0) Public Domain Dedication)")
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
			self.component:setWavetable("Wavetables/" .. action)		
			self.waveTableName = action
			self.redrawPending = true
			self:redrawBackground()	
		end
	end)
end

function WavetableSynth2DMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function WavetableSynth2DMod:moveFinish()
	self.socketInVector = Vector(self.x - (moduleWidth/2) - 2, self.y - (moduleHeight/2) + 100)
	self.paramXInVector = Vector(self.x + (moduleWidth/2) + 2, self.y - (moduleHeight/2) + 27)
	self.paramYInVector = Vector(self.x + (moduleWidth/2) + 2, self.y - (moduleHeight/2) + 58)
	self.socketOutVector = Vector(self.x + (moduleWidth/2) + 2, self.y - (moduleHeight/2) + 100)
	
	self.inSocketVectors = {
		self.socketInVector,
		self.paramXInVector,
		self.paramYInVector,
	}
	
	local adsrEncoderY1 = self.y - (self.bgH/2) + 80
	local adsrEncoderY2 = self.y - (self.bgH/2) + 115
	
	local encoderLeftX = self.x - (moduleWidth/2) + 18
	local encoderMidX =  self.x
	local encoderRightX =  self.x + (moduleWidth/2) - 18
	
	self.paramXEncoderVector = Vector(encoderLeftX, self.y - (moduleHeight/2) + 32)
	self.paramYEncoderVector = Vector(encoderRightX, self.y - (moduleHeight/2) + 32)
	
	--ADSR
	self.attackEncoderVector = Vector(encoderLeftX, adsrEncoderY1)
	self.decayEncoderVector = Vector(encoderRightX, adsrEncoderY1)
	self.sustainEncoderVector = Vector(encoderLeftX, adsrEncoderY2)
	self.releaseEncoderVector = Vector(encoderMidX, adsrEncoderY2)
	self.envelopeCurveEncoderVector = Vector(encoderRightX, adsrEncoderY2)
	
	self.encoderVectors = {
		self.paramXEncoderVector,
		self.paramYEncoderVector,
		self.attackEncoderVector,
		self.decayEncoderVector,
		self.sustainEncoderVector,
		self.releaseEncoderVector,
		self.envelopeCurveEncoderVector,
	}
end

function WavetableSynth2DMod:evaporate(onDetachConnected)
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
	
	if self.component:paramXConnected() then
		onDetachConnected(self.paramXInCable:getStartModId(), self.paramXInCable:getCableId())
		self.component:unplugParamX()
		self.paramXInCable:evaporate()
		self.paramXInCable = nil
	end
	
	if self.component:paramYConnected() then
		onDetachConnected(self.paramYInCable:getStartModId(), self.paramYInCable:getCableId())
		self.component:unplugParamY()
		self.paramYInCable:evaporate()
		self.paramYInCable = nil
	end
		
	self:remove()
end

function WavetableSynth2DMod:unplug(cableId)
	if self.component:inConnected() and "" .. self.inCable:getCableId() == "" .. cableId then
		self.component:unplugIn()
		self.inCable = nil
	end
	
	if self.component:outConnected() and "" .. self.outCable:getCableId() == "" .. cableId then
		self.component:unplugOut()
		self.outCable = nil
	end
	
	if self.component:paramXConnected() and "" .. self.paramXInCable:getCableId() == "" .. cableId then
		self.component:unplugParamX()
		self.paramXInCable = nil
	end
	
	if self.component:paramYConnected() and "" .. self.paramYInCable:getCableId() == "" .. cableId then
		self.component:unplugParamY()
		self.paramYInCable = nil
	end
end

function WavetableSynth2DMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function WavetableSynth2DMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.waveTableName = self.waveTableName	
	modState.paramXEncoderValue = self.paramXEncoderValue
	modState.attackEncoderValue = self.attackEncoderValue
	modState.decayEncoderValue = self.decayEncoderValue
	modState.sustainEncoderValue = self.sustainEncoderValue
	modState.releaseEncoderValue = self.releaseEncoderValue
	modState.envelopeCurveEncoderValue = self.envelopeCurveEncoderValue
	return modState
end

function WavetableSynth2DMod:fromState(modState)
	self.waveTableName = modState.waveTableName
	self.paramXEncoderValue = modState.paramXEncoderValue 
	self.attackEncoderValue = modState.attackEncoderValue
	self.decayEncoderValue = modState.decayEncoderValue
	self.sustainEncoderValue = modState.sustainEncoderValue
	self.releaseEncoderValue = modState.releaseEncoderValue
	self.envelopeCurveEncoderValue = modState.envelopeCurveEncoderValue
	
	self:redrawBackground()
	self.component:setWavetable("Wavetables/" .. self.waveTableName)		
end