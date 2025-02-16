--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'Modules/mod_utils.lua'
import 'Modules/Clocks/ClockDelay/clock_delay_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'

class('ClockDelayMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 75
local moduleHeight = 50

local modType = "ClockDelayMod"
local modSubtype = "clock_router"

local font = playdate.graphics.font.new("Fonts/parodius_ext")
playdate.graphics.setFont(font)

function ClockDelayMod:init(xx, yy, modId)
	ClockDelayMod.super.init(self)
	
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
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 32)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(87, 32)
	gfx.popContext()
	
	self.backgroundImage = backgroundImage

	self:moveTo(xx, yy)
	self:add()
	
	self.component = ClockDelayComponent()

	self.divisionEncoderVector = Vector(xx - 18, yy + 5)
	self.divisionEncoderValue = map(120, 1, 200, 0.0, 1.0)
	self.divisionLabel = "1/8"
	
	self.probabilityEncoderVector = Vector(xx + 18, yy + 5)
	self.probabilityEncoderValue = 0.5
	self.probabilityLabel = "50%"
	
	self.encoderVectors = {
		self.divisionEncoderVector,
		self.probabilityEncoderVector
	}
	
	self.socketInVector = Vector(xx - 36, yy)
	self.socketOutVector = Vector(xx + 36, yy)
	
	self:redrawBackground()
end

function ClockDelayMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = gfx.image.new(self.bgW, self.bgH)
	gfx.pushContext(backgroundImage)	
	self.backgroundImage:draw(0, 0)
	
  --draw encoders
	local encoderLeftX = 22
	local encoderRightX = 60
	local encoderY = 34
	
	--left
	gfx.drawTextAligned(self.divisionLabel, 35, 22, kTextAlignment.center)
	gEncoder:setValue(self.divisionEncoderValue)
	local divisionEncoderImage = gEncoder:getImage()
	divisionEncoderImage:draw(encoderLeftX, encoderY)
		
	--right
	gfx.drawTextAligned(self.probabilityLabel, 69, 22, kTextAlignment.center)
	gEncoder:setValue(self.probabilityEncoderValue)
	local probabilityEncoderImage = gEncoder:getImage()
	probabilityEncoderImage:draw(encoderRightX, encoderY)
	
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function ClockDelayMod:turn(x, y, change)
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

	if encoderVector == self.divisionEncoderVector then
		gEncoder:setValue(self.divisionEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.divisionEncoderVector.x, self.divisionEncoderVector.y)
		gEncoder:turn(change)
		self.divisionEncoderValue = gEncoder:getValue()
		local division = self.component:setDivisionDelay(self.divisionEncoderValue)
		if division == 1 then
			self.divisionLabel = "1/1"
		elseif division == 2 then
			self.divisionLabel = "1/2"
		elseif division == 3 then
			self.divisionLabel = "1/4"
		elseif division == 4 then
			self.divisionLabel = "1/8"
		elseif division == 5 then 
			self.divisionLabel = "1/16"
		elseif division == 6 then 
			self.divisionLabel = "1/32"
		elseif division == 7 then	
			self.divisionLabel = "1/64"
		end	
		self:redrawBackground()
		self.redrawPending = false
	elseif encoderVector == self.probabilityEncoderVector then
		gEncoder:setValue(self.probabilityEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.probabilityEncoderVector.x, self.probabilityEncoderVector.y)
		gEncoder:turn(change)
		self.probabilityEncoderValue = gEncoder:getValue()
		self.probabilityLabel = self.component:setChance(self.probabilityEncoderValue)
		self:redrawBackground()
		self.redrawPending = false
	end
end

function ClockDelayMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function ClockDelayMod:findClosestEncoderVector(x, y)
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


function ClockDelayMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function ClockDelayMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function ClockDelayMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function ClockDelayMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype, onError)
	if sourceSubtype ~= "clock_router" then 
		if onError ~= nil then onError("This input requires a clock signal") end
		return false 
	elseif ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function ClockDelayMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function ClockDelayMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Will randomly hold onto a clock event before releasing it.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function ClockDelayMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function ClockDelayMod:moveFinish()	
	self.socketInVector = Vector(self.x - 36, self.y)
	self.socketOutVector = Vector(self.x + 36, self.y)
	self.divisionEncoderVector = Vector(self.x - 18, self.y + 5)
	self.probabilityEncoderVector = Vector(self.x + 18, self.y + 5)
	
	self.encoderVectors = {
		self.divisionEncoderVector,
		self.probabilityEncoderVector
	}
end

function ClockDelayMod:evaporate(onDetachConnected)
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
	self:remove()
end

function ClockDelayMod:type() return modType end
function ClockDelayMod:getModId() return self.modId end
function ClockDelayMod:unplug(cableId) self.component:unplug(cableId) end
function ClockDelayMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function ClockDelayMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.divisionEncoderValue = self.divisionEncoderValue
	modState.divisionLabel = self.divisionLabel
	modState.probabilityEncoderValue = self.probabilityEncoderValue
	modState.probabilityLabel = self.probabilityLabel
	
	return modState
end

function ClockDelayMod:fromState(modState)
	self.divisionEncoderValue = modState.divisionEncoderValue
	self.divisionLabel = modState.divisionLabel
	self.probabilityEncoderValue = modState.probabilityEncoderValue
	self.probabilityLabel = modState.probabilityLabel
	self.component:setDivisionDelay(self.divisionEncoderValue)
	self.component:setChance(self.probabilityEncoderValue)
	self:redrawBackground()
end