--[[
	© 2023 Orllewin - All Rights Reserved.
	
	This mod will have two encoders 
	- one controls frequency in Hz
	- the second moves through the wavetable
	
	This plan is to only have a single sprite.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Synths/WavetableHz/wavetable_hz_component'

class('WavetableHzMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local mod <const> = math.fmod

local moduleWidth = 85
local moduleHeight = 60

local modType = "WavetableHzMod"
local modSubtype = SourceTypes.audio_gen

function WavetableHzMod:init(xx, yy, modId, onInit)
	WavetableHzMod.super.init(self)
	
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
	local bgH = moduleHeight + 25
	
	self.hzEncoderVector = Vector(xx - 19, yy + 1)
	self.hzEncoderValue = 0.25
	
	self.xMorphEncoderVector = Vector(xx + 21, yy + 1)	
	self.xMorphEncoderValue = 0.0
	
	self.encoderVectors = {
		self.hzEncoderVector,
		self.xMorphEncoderVector,
	}

	self:redrawBackground()
	self:moveTo(xx, yy)
	self:add()
	
	self.component = WavetableHzComponent("synth_module", function(event)  		
		--Main in listener
	end, function(event) 
		--paramX listener
		self.xMorphEncoderValue = event:getValue()
		self:redrawBackground()
	end, function(channel)
		self.onInit(self.modId, channel)
	end)

	self.paramXInVector = Vector	(xx + (moduleWidth/2)+2, yy - 13)
	self.socketOutVector = Vector	(xx + (moduleWidth/2)+2, yy + 13)

end

function WavetableHzMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function WavetableHzMod:redrawBackground()
	gEncoder:hide()
	self.backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = self.backgroundImage:getSize()

	gfx.pushContext(self.backgroundImage)
	
	gfx.drawTextAligned("Hz",  bgW/2 - 20, 23, kTextAlignment.center)
	gfx.drawTextAligned("X",  bgW/2 + 20, 23, kTextAlignment.center)
	
	gEncoder:setValue(self.hzEncoderValue)
	local hzEncoderImage = gEncoder:getImage()
	hzEncoderImage:draw(bgW/2 - 30, 35)
	
	gEncoder:setValue(self.xMorphEncoderValue)
	local xMorphEncoderImage = gEncoder:getImage()
	xMorphEncoderImage:draw(bgW/2 + 10, 35)

	local rightSocket = assets:image("side_socket_right")	
	rightSocket:draw(97, 50)--audio out
	rightSocket:draw(97, 24) -- x morph in
	
	local wtLabel = replace(self.waveTableName, "_256", "")
	wtLabel = replace(wtLabel, ".pda", "")
	gfx.drawTextAligned(wtLabel, bgW/2, bgH - 28, kTextAlignment.center)

	gfx.popContext()
	
	self:setImage(self.backgroundImage)
	self.redrawPending = false
end

function WavetableHzMod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end
	
	if encoderVector == self.hzEncoderVector then
		gEncoder:setValue(self.hzEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.hzEncoderVector.x, self.hzEncoderVector.y)
		gEncoder:turn(change)
		self.hzEncoderValue = gEncoder:getValue()
		self.component:setNormalisedHz(self.hzEncoderValue)
	elseif encoderVector == self.xMorphEncoderVector then
		gEncoder:setValue(self.xMorphEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.xMorphEncoderVector.x, self.xMorphEncoderVector.y)
		gEncoder:turn(change)
		self.xMorphEncoderValue = gEncoder:getValue()
		self.component:setXMorph(self.xMorphEncoderValue)
	end
	self.redrawPending = true
end

function WavetableHzMod:findClosestEncoderVector(x, y)
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

function WavetableHzMod:setOutCable(patchCable)
	patchCable:setEnd(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function WavetableHzMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

--The synth has multiple inputs so we need to find the closest socket...
function WavetableHzMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype, onError)
	if sourceSubtype == "midi" or sourceSubtype == "audio_gen" or sourceSubtype == "audio_effect" then 
		if onError ~= nil then onError("This input requires a value signal") end
		return false 
	elseif self.component:paramXConnected() then
		return false
	else
		ghostCable:setEnd(self.paramXInVector.x, self.paramXInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function WavetableHzMod:setInCable(patchCable)
	if self.component:paramXConnected() then
		--noop
	else
		self.paramXInCable = patchCable
		self.component:setParamXInCable(patchCable:getCable())
	end
end

function WavetableHzMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function WavetableHzMod:type()
	return modType
end

function WavetableHzMod:getModId()
	return self.modId
end

function WavetableHzMod:handleModClick(tX, tY, listener)
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

function WavetableHzMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function WavetableHzMod:moveFinish()
	self.hzEncoderVector = Vector(self.x - 19, self.y + 1)
	self.xMorphEncoderVector = Vector(self.x + 21, self.y + 1)	
	self.paramXInVector = Vector	(self.x + (moduleWidth/2)+2, self.y - 13)
	self.socketOutVector = Vector	(self.x + (moduleWidth/2)+2, self.y + 13)

	self.encoderVectors = {
		self.hzEncoderVector,
		self.xMorphEncoderVector,
	}

end

function WavetableHzMod:evaporate(onDetachConnected)
	--first stop any notes playing:
	self.component:stopAll()
	
	--first detach cables	
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
	
	self:remove()
end

function WavetableHzMod:unplug(cableId)	
	if self.component:outConnected() and "" .. self.outCable:getCableId() == "" .. cableId then
		self.component:unplugOut()
		self.outCable = nil
	end
	
	if self.component:paramXConnected() and "" .. self.paramXInCable:getCableId() == "" .. cableId then
		self.component:unplugParamX()
		self.paramXInCable = nil
	end
end

function WavetableHzMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function WavetableHzMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.waveTableName = self.waveTableName	
	modState.xMorphEncoderValue = self.xMorphEncoderValue
	modState.hzEncoderValue = self.hzEncoderValue
	return modState
end

function WavetableHzMod:fromState(modState)
	self.waveTableName = modState.waveTableName
	self.xMorphEncoderValue = modState.xMorphEncoderValue
	self.hzEncoderValue = modState.hzEncoderValue
	self.component:setNormalisedHz(self.hzEncoderValue)
	self.component:setXMorph(self.xMorphEncoderValue)
	self:redrawBackground()
	self.component:setWavetable("Wavetables/" .. self.waveTableName)		
end