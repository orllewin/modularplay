--[[
	© 2023 Orllewin - All Rights Reserved.
]]--
import 'Modules/mod_utils.lua'
import 'Modules/Synths/WaveTableSynth/wavetable_synth_component'

class('WavetableSynthMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local mod <const> = math.fmod

local moduleWidth = 85
local moduleHeight = 120
local bannerImage = gfx.image.new("Images/wavetable_mod_banner")
local curveImage = gfx.image.new("Images/envelope_curve")

local modType = "WavetableSynthMod"
local modSubtype = SourceTypes.audio_gen

function WavetableSynthMod:init(xx, yy, modId, onInit)
	WavetableSynthMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.onInit = onInit
	
	self.waveTableName = "FAIRLIGHT1"
	
	--ADSR alignment
	local bgW = moduleWidth + 14
	self.bgW = bgW
	local bgH = moduleHeight + 25
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
	
	self.component = WavetableSynthComponent("synth_module", function(event)  		
		--Main in listener
	end, function(event) 
		--paramX listener
		self.paramXEncoderValue = event:getValue()
	end, function(channel)
		self.onInit(self.modId, channel)
	end)
		
	
	-- self.paramXEncoder = RotaryEncoder(encoderRightX, adsrEncoderY1, function(value) 
	-- 	self.component:setXMorph(value)
	-- end)
	self.paramXEncoderVector = Vector(encoderRightX, adsrEncoderY1)
	self.paramXEncoderValue = 0.0
	
	--ADSR
	-- self.attackEncoder = RotaryEncoder(encoderLeftX, adsrEncoderY1, function(value) 
	-- 	self.component:setAttack(value)
	-- end)
	-- self.attackEncoder:setValue(0.1)
	self.attackEncoderVector = Vector(encoderLeftX, adsrEncoderY1)
	self.attackEncoderValue = 0.1
	
	-- self.decayEncoder = RotaryEncoder(encoderMidX, adsrEncoderY1, function(value) 
	-- 	self.component:setDecay(value)
	-- end)
	-- self.decayEncoder:setValue(0.1)
	self.decayEncoderVector = Vector(encoderMidX, adsrEncoderY1)
	self.decayEncoderValue = 0.1
	
	-- self.sustainEncoder = RotaryEncoder(encoderLeftX, adsrEncoderY2, function(value) 
	-- 	self.component:setSustain(value)
	-- end)
	-- self.sustainEncoder:setValue(0.8)
	self.sustainEncoderVector = Vector(encoderLeftX, adsrEncoderY2)
	self.sustainEncoderValue = 0.8
	
	-- self.releaseEncoder = RotaryEncoder(encoderMidX, adsrEncoderY2, function(value) 
	-- 	self.component:setRelease(value)
	-- end)
	-- self.releaseEncoder:setValue(1.0)
	self.releaseEncoderVector = Vector(encoderMidX, adsrEncoderY2)
	self.releaseEncoderValue = 1.0
	
	-- self.envelopeCurveEncoder = RotaryEncoder(encoderRightX, adsrEncoderY2, function(value) 
	-- 	self.component:setEnvelopeCurve(value)
	-- end)
	-- self.envelopeCurveEncoder:setValue(0.5)
	self.envelopeCurveEncoderVector = Vector(encoderRightX, adsrEncoderY2)
	self.envelopeCurveEncoderValue = 0.5
		
	self.encoderVectors = {
		self.paramXEncoderVector,
		self.attackEncoderVector,
		self.decayEncoderVector,
		self.sustainEncoderVector,
		self.releaseEncoderVector,
		self.envelopeCurveEncoderVector
	}
	
	self.socketInVector = Vector(xx - (moduleWidth/2)-2, yy - (moduleHeight/2) + 100)
	self.paramXInVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + 27)
	self.socketOutVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + 100)
	
	self.inSocketVectors = {
		self.socketInVector,
		self.paramXInVector
	}
	
	self:redrawBackground()
end

function WavetableSynthMod:redrawBackground()
	if self.redrawPending == false then
		return
	end
	
	gEncoder:hide()
	self.backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = self.backgroundImage:getSize()
	
	gfx.pushContext(self.backgroundImage)
	
	gfx.drawTextAligned("A",  30, 60, kTextAlignment.center)
	gfx.drawTextAligned("D",  55, 60, kTextAlignment.center)
	gfx.drawTextAligned("S",  30, 95, kTextAlignment.center)
	gfx.drawTextAligned("R",  55, 95, kTextAlignment.center)
	
	--draw encoders
	local encoderLeftX = 22
	local encoderMidX = 46
	local encoderRightX = 71
	
	--X
	gEncoder:setValue(self.paramXEncoderValue)
	local attackEncoderImage = gEncoder:getImage()
	attackEncoderImage:draw(encoderRightX, 70)
	
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
	
	curveImage:draw(73, 91)
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 100)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(97, 100)
	rightSocket:draw(97, 27)
	
	gfx.drawTextAligned("X", 80, 60, kTextAlignment.center)
	
	print("mxcvbdejhbvejhfbvejhfbhjebfhje")
	local wtLabel = replace(self.waveTableName, "_256", "")
	wtLabel = replace(wtLabel, ".pda", "")
	gfx.drawTextAligned(wtLabel, bgW/2, 25, kTextAlignment.center)
	
	bannerImage:draw(16, 38)
	gfx.popContext()
	
	self:setImage(self.backgroundImage)
	self.redrawPending = false
end

function WavetableSynthMod:turn(x, y, change)
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
	
function WavetableSynthMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function WavetableSynthMod:findClosestEncoderVector(x, y)
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

function WavetableSynthMod:findClosestInVector(x, y)
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

function WavetableSynthMod:setOutCable(patchCable)
	patchCable:setEnd(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function WavetableSynthMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

--The synth has multiple inputs so we need to find the closest socket...
function WavetableSynthMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype, onError)
	local inSocket = self:findClosestInVector(x, y)
	if inSocket.x == self.socketInVector.x and self.inCable == nil then
		if sourceSubtype ~= "midi" and sourceSubtype ~= "clock_router_or_midi" then 
			if onError ~= nil then onError("This input requires a midi signal") end
			return false 
		end
		ghostCable:setEnd(inSocket.x, inSocket.y)
		ghostCable:setGhostReceiveConnected()
		return true
	elseif inSocket.y == self.paramXInVector.y and self.paramXInCable == nil then
		print("Source subtype: " .. sourceSubtype)
		if sourceSubtype == SourceTypes.normalised_value then
			ghostCable:setEnd(self.paramXInVector.x, self.paramXInVector.y)
			ghostCable:setGhostReceiveConnected()
			return true
		else
			if onError ~= nil then onError("This input requires a value signal") end
			return false 
		end
	end

	return false
end

function WavetableSynthMod:setInCable(patchCable)
	local cableX, cableY = patchCable:getEndXY()
	local inSocket = self:findClosestInVector(cableX, cableY)
	patchCable:setEnd(inSocket.x, inSocket.y, self.modId)
	if inSocket.x == self.socketInVector.x then
		self.inCable = patchCable
		self.component:setInCable(patchCable:getCable())
	elseif inSocket.y == self.paramXInVector.y then
		self.paramXInCable = patchCable
		self.component:setParamXInCable(patchCable:getCable())
	end
end

function WavetableSynthMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function WavetableSynthMod:type()
	return modType
end

function WavetableSynthMod:getModId()
	return self.modId
end

function WavetableSynthMod:handleModClick(tX, tY, listener)
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

function WavetableSynthMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function WavetableSynthMod:moveFinish()	
	self.socketInVector = Vector(self.x - (moduleWidth/2) - 2, self.y - (moduleHeight/2) + 100)
	self.paramXInVector = Vector(self.x + (moduleWidth/2) + 2, self.y - (moduleHeight/2) + 27)
	self.socketOutVector = Vector(self.x + (moduleWidth/2) + 2, self.y - (moduleHeight/2) + 100)
	
	self.inSocketVectors = {
		self.socketInVector,
		self.paramXInVector
	}
	

	local adsrColWidth = moduleWidth/4
	local adsrEncoderY1 = self.y - (self.bgH/2) + 80
	local adsrEncoderY2 = self.y - (self.bgH/2) + 115
	local shadowPadding = (self.bgW - moduleWidth)/2
	
	local encoderLeftX = self.x - (moduleWidth/2) + 18
	local encoderMidX = self.x
	local encoderRightX = self.x + (moduleWidth/2) - 18
	
	self.paramXEncoderVector = Vector(encoderRightX, adsrEncoderY1)
	self.attackEncoderVector = Vector(encoderLeftX, adsrEncoderY1)
	self.decayEncoderVector = Vector(encoderMidX, adsrEncoderY1)
	self.sustainEncoderVector = Vector(encoderLeftX, adsrEncoderY2)
	self.releaseEncoderVector = Vector(encoderMidX, adsrEncoderY2)
	self.envelopeCurveVector = Vector(encoderRightX, adsrEncoderY2)
		
	self.encoderVectors = {
		self.paramXEncoderVector,
		self.attackEncoderVector,
		self.decayEncoderVector,
		self.sustainEncoderVector,
		self.releaseEncoderVector,
		self.envelopeCurveEncoderVector
	}
end

function WavetableSynthMod:evaporate(onDetachConnected)
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
		print("removing paramx cableid: " .. self.paramXInCable:getCableId() .. "attached to: " .. self.paramXInCable:getEndModId())
		onDetachConnected(self.paramXInCable:getStartModId(), self.paramXInCable:getCableId())
		self.component:unplugParamX()
		self.paramXInCable:evaporate()
		self.paramXInCable = nil
	end
			
	self:remove()
end

function WavetableSynthMod:unplug(cableId)
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
end

function WavetableSynthMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function WavetableSynthMod:toState()
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

function WavetableSynthMod:fromState(modState)
	self.waveTableName = modState.waveTableName
	self.waveTableName= modState.waveTableName
	self.paramXEncoderValue = modState.paramXEncoderValue
	self.attackEncoderValue = modState.attackEncoderValue
	self.decayEncoderValue = modState.decayEncoderValue
	self.sustainEncoderValue = modState.sustainEncoderValue
	self.releaseEncoderValue = modState.releaseEncoderValue
	self.envelopeCurveEncoderValue = modState.envelopeCurveEncoderValue
	
	self:redrawBackground()
	self.component:setWavetable("Wavetables/" .. self.waveTableName)		
end