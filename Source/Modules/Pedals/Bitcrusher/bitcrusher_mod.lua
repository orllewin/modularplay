--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'Modules/mod_utils.lua'
import 'Modules/Pedals/Bitcrusher/bitcrusher_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'

class('BitcrusherMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 85
local moduleHeight = 120

local modType = "BitcrusherMod"
local modSubtype = "audio_effect"

function BitcrusherMod:init(xx, yy, modId)
	BitcrusherMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.upPending = false
	
	self:moveTo(xx, yy)
	self:add()
	
	self.component = BitcrusherComponent()

	local encoderY = yy - 30
	--left
	self.amountEncoderVector = Vector(xx - (moduleWidth/2) + 18, encoderY)
	self.amountEncoderValue = 0.0
	
	--middle
	self.undersampleEncoderVector = Vector(xx, encoderY)
	self.undersampleEncoderValue = 0.0
	
	--right
	self.mixEncoderVector = Vector(xx + (moduleWidth/2) - 18, encoderY)
	self.mixEncoderValue = 0.5
	
	self.encoderVectors = {
		self.amountEncoderVector,
		self.undersampleEncoderVector,
		self.mixEncoderVector
	}

	self.socketInVector = Vector(xx - (moduleWidth/2)-2, yy - (moduleHeight/2) + gPedalAudioIOY)
	self.socketOutVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + gPedalAudioIOY)

	self:redrawBackground()
end

function BitcrusherMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	

	
	gfx.pushContext(backgroundImage)
	
	if self.component:isOn() then
		local pedalOn = assets:image("pedal_on")
		pedalOn:draw(bgW/2 - 5, 19)
	else
		local pedalOn = assets:image("pedal_off")
		pedalOn:draw(bgW/2 - 5, 19)
	end
	
	gfx.drawLine((bgW/2) - (moduleWidth/2) + 7, 60, (bgW/2) + (moduleWidth/2) - 7, 60)
	gfx.drawTextAligned("Krush", bgW/2, 68, kTextAlignment.center)
	
	local mixImage = assets:image("mix")
	mixImage:draw(bgW - 38, 20)
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(gPedalLeftJackX, gPedalAudioIOY)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(gPedalRightJackX, gPedalAudioIOY)
	
	generateHalftoneRoundedRect(71, 43, 0.3):draw(20, 83)
	
	--draw encoders
	local encoderLeftX = 22
	local encoderMidX = 46
	local encoderRightX = 71
	local encoderY = 34
	
	--left
	gEncoder:setValue(self.amountEncoderValue)
	local amountEncoderImage = gEncoder:getImage()
	amountEncoderImage:draw(encoderLeftX, encoderY)
	
	--middle
	gEncoder:setValue(self.undersampleEncoderValue)
	local undersampleEncoderImage = gEncoder:getImage()
	undersampleEncoderImage:draw(encoderMidX, encoderY)
	
	--right
	gEncoder:setValue(self.mixEncoderValue)
	local mixEncoderImage = gEncoder:getImage()
	mixEncoderImage:draw(encoderRightX, encoderY)
	
	gfx.popContext()
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function BitcrusherMod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end

	if encoderVector == self.amountEncoderVector then
		gEncoder:setValue(self.amountEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.amountEncoderVector.x, self.amountEncoderVector.y)
		gEncoder:turn(change)
		self.amountEncoderValue = gEncoder:getValue()
		self.component:setAmount(self.amountEncoderValue)
	elseif encoderVector == self.undersampleEncoderVector then
		gEncoder:setValue(self.undersampleEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.undersampleEncoderVector.x, self.undersampleEncoderVector.y)
		gEncoder:turn(change)
		self.undersampleEncoderValue = gEncoder:getValue()
		self.component:setUndersampling(math.min(0.99, self.undersampleEncoderValue))
	elseif encoderVector == self.mixEncoderVector then
		gEncoder:setValue(self.mixEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.mixEncoderVector.x, self.mixEncoderVector.y)
		gEncoder:turn(change)
		self.mixEncoderValue = gEncoder:getValue()
		self.component:setMix(self.mixEncoderValue)
	end
	
	self.redrawPending = true
end

function BitcrusherMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function BitcrusherMod:findClosestEncoderVector(x, y)
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

function BitcrusherMod:getHostAudioModId()
	return self.hostAudioModId
end

function BitcrusherMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.hostAudioModId = patchCable:getHostAudioModId()
	self.component:setInCable(patchCable:getCable())
end

function BitcrusherMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function BitcrusherMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function BitcrusherMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype)
	if ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.component:inConnected() then 
		return false
	elseif sourceSubtype == "midi" or sourceSubtype == "clock_router" then
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function BitcrusherMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then 
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function BitcrusherMod:type()
	return self.modType
end

function BitcrusherMod:getModId()
	return self.modId
end

function BitcrusherMod:handleModClickPedal(tX, tY)
	self.upPending = true
	self:moveBy(0, 2)
	self.component:toggleOnOff()
	self:redrawBackground()
end

function BitcrusherMod:handleModClickUp(tX, tY, listener)
	if self.upPending then
		self.upPending = false
		self:moveBy(0, -2)
	end
end

function BitcrusherMod:handleModClick(tX, tY, listener)
	if tY > self.y - 20 then
		self:handleModClickPedal(tX, tY)
	else
		self.menuListener = listener
		local actions = {
			{label = "About"},
			{label = "Move"},
			{label = "Remove"}
		}
		local contextMenu = ModuleMenu(actions)
		contextMenu:show(function(action) 
			if action == "About" then
				local aboutPopup = ModAboutPopup("todo")
				aboutPopup:show()
			else
				if self.menuListener ~= nil then 
					self.menuListener(action) 
				end
			end
		end)
	end
end

function BitcrusherMod:setChannel(channel, onNext)
	if channel == nil then
		print("BitcrusherMod:setChannel() CHANNEL IS NIL")
	else
		print("BitcrusherMod:setChannel() CHANNEL EXISTS!")
	end
	self.component:setChannel(channel)
	
	--now look for downstream audio effects/outputs
	if self.outCable ~= nil then
		local nextModId = self.outCable:getEndModId()
		if onNext ~= nil then onNext(nextModId, channel) end
	end
end

function BitcrusherMod:removeChannel(channel)
	self.component:removeChannel(channel)
end

function BitcrusherMod:unplug(cableId)
	self.component:unplug(cableId)
end

function BitcrusherMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function BitcrusherMod:moveFinish()
	local encoderY = self.y - 30
	self.amountEncoderVector = Vector(self.x - (moduleWidth/2) + 18, encoderY)
	self.undersampleEncoderVector = Vector(self.x, encoderY)
	self.mixEncoderVector = Vector(self.x + (moduleWidth/2) - 18, encoderY)

	self.encoderVectors = {
		self.amountEncoderVector,
		self.undersampleEncoderVector,
		self.mixEncoderVector
	}

	self.socketInVector = Vector(self.x - (moduleWidth/2)-2, self.y - (moduleHeight/2) + gPedalAudioIOY)
	self.socketOutVector = Vector	(self.x + (moduleWidth/2)+2, self.y - (moduleHeight/2) + gPedalAudioIOY)
end

function BitcrusherMod:evaporate(onDetachConnected)
	print("BitcrusherMod:evaporate()")
	--first detach cables

	
	if self.component:inConnected() then
		self.component:unplugIn()
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.inCable:evaporate()
	end
	
	if self.component:outConnected() then 
		self.component:unplugOut()
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.outCable:evaporate()
	end
	
	--then remove sprites
	playdate.graphics.sprite.removeSprites({self.cutoffFreqLabelSprite})
	self:remove()
end

function BitcrusherMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function BitcrusherMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.amountEncoderValue = self.amountEncoderValue
	modState.undersampleEncoderValue = self.undersampleEncoderValue
	modState.mixEncoderValue = self.mixEncoderValue
	
	return modState
end

function BitcrusherMod:fromState(modState)
	self.amountEncoderValue = modState.amountEncoderValue
	self.undersampleEncoderValue = modState.undersampleEncoderValue
	self.mixEncoderValue = modState.mixEncoderValue
	
	self.component:setAmount(self.amountEncoderValue)
	self.component:setUndersampling(math.min(0.99, self.undersampleEncoderValue))
	self.component:setMix(self.mixEncoderValue)
	
	self:redrawBackground()
end