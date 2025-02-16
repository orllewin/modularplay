--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'Modules/ValueGenerators/Oscillator2/oscillator2_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'

local MODE_POSITION = 1
local MODE_WIDTH = 2
local MODE_FREQUENCY = 3

class('Oscillator2Mod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local positionImage = gfx.image.new("Images/position")
local widthImage = gfx.image.new("Images/width")
local timeImage = gfx.image.new("Images/time")

local moduleWidth = 34
local moduleHeight = 48

local modType = "Oscillator2Mod"
local modSubtype = SourceTypes.normalised_value

function Oscillator2Mod:init(xx, yy, modId)
	Oscillator2Mod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.mode = MODE_FREQUENCY
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	self.bgW = bgW
	self.bgH = bgH
	gfx.pushContext(backgroundImage)
	local bottomSocket = assets:image("side_socket_bottom")
	bottomSocket:draw(22, bgH - 15)		
	gfx.popContext()
	
	self.backgroundImage = backgroundImage
		
	self:moveTo(xx, yy)
	self:add()
	
	self.component = Oscillator2Component()
	
	self.positionEncoderValue = 0.5
	self.widthEncoderValue = 1.0
	self.frequencyEncoderValue = 0.45
	
	self.encoderVector = Vector(xx, yy + 8)
	self.encoderValue = 0.45

	self.socketOutVector = Vector	(xx, yy + (moduleHeight/2))
	
	self:redrawBackground()
end

function Oscillator2Mod:redrawBackground()
	gEncoder:hide()
	
	local backgroundImage = gfx.image.new(self.bgW, self.bgH)
	gfx.pushContext(backgroundImage)
	
	self.backgroundImage:draw(0, 0)
	
	if self.mode == MODE_POSITION then
		positionImage:draw(24, 23)
		gEncoder:setValue(self.positionEncoderValue)
	elseif self.mode == MODE_WIDTH then
		widthImage:draw(26, 23)
		gEncoder:setValue(self.widthEncoderValue)
	elseif self.mode == MODE_FREQUENCY then
		timeImage:draw(24, 20)
		gEncoder:setValue(self.frequencyEncoderValue)
	end
	
	local encoderImage = gEncoder:getImage()
	encoderImage:draw(21, 36)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function Oscillator2Mod:turn(x, y, change)
	gEncoder:moveTo(self.encoderVector.x, self.encoderVector.y)
	if self.mode == MODE_FREQUENCY then
		gEncoder:setValue(self.frequencyEncoderValue)
		gEncoder:show()
		gEncoder:turn(change)
		self.frequencyEncoderValue = gEncoder:getValue()
		self.component:setFrequency(self.frequencyEncoderValue)
	elseif self.mode == MODE_POSITION then
		gEncoder:setValue(self.positionEncoderValue)
		gEncoder:show()
		gEncoder:turn(change)
		self.positionEncoderValue = gEncoder:getValue()
		self.component:setPosition(self.positionEncoderValue)
	elseif self.mode == MODE_WIDTH then
		gEncoder:setValue(self.widthEncoderValue)
		gEncoder:show()
		gEncoder:turn(change)
		self.widthEncoderValue = gEncoder:getValue()
		self.component:setWidth(self.widthEncoderValue)
	end
		
	self.redrawPending = true
end

function Oscillator2Mod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function Oscillator2Mod:findClosestEncoderVector(x, y)
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

function Oscillator2Mod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	patchCable:setHostAudioModId(self.hostAudioModId)
	self.component:setOutCable(patchCable:getCable())
end

function Oscillator2Mod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function Oscillator2Mod:tryConnectGhostIn(x, y, ghostCable)
	return false
end

function Oscillator2Mod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then 
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function Oscillator2Mod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "Mode: Position"},
		{label = "Mode: Width"},
		{label = "Mode: Frequency"},
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "Mode: Position" then
			self.mode = MODE_POSITION
			self:redrawBackground()
		elseif action == "Mode: Width" then
			self.mode = MODE_WIDTH
			self:redrawBackground()
		elseif action == "Mode: Frequency" then
			self.mode = MODE_FREQUENCY
			self:redrawBackground()
		elseif action == "About" then
			local aboutPopup = ModAboutPopup("Oscillates between two values in the range 0.0 to 1.0. You set the centre value and the width, and the oscillation rate")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function Oscillator2Mod:type() return modType end
function Oscillator2Mod:getModId() return self.modId end
function Oscillator2Mod:removeChannel(channel) self.component:removeChannel(channel) end
function Oscillator2Mod:unplug(cableId) self.component:unplug(cableId) end
function Oscillator2Mod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function Oscillator2Mod:repositionBy(x, y)
	self:moveBy(x, y)
end

function Oscillator2Mod:moveFinish()
	self.encoderVector = Vector(self.x, self.y + 8)	
	self.socketOutVector = Vector	(self.x, self.y + (moduleHeight/2))
end

function Oscillator2Mod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
		
	self:remove()
end

function Oscillator2Mod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.positionEncoderValue = self.positionEncoderValue
	modState.widthEncoderValue = self.widthEncoderValue
	modState.frequencyEncoderValue = self.frequencyEncoderValue
	modState.mode = self.mode

	return modState
end

function Oscillator2Mod:fromState(modState)
 self.positionEncoderValue = modState.positionEncoderValue
 self.component:setPosition(self.positionEncoderValue)
 
 self.widthEncoderValue = modState.widthEncoderValue
 self.component:setWidth(self.widthEncoderValue)
 
 self.frequencyEncoderValue = modState.frequencyEncoderValue
 self.component:setFrequency(self.frequencyEncoderValue)
 
 self.mode = modState.mode
 
 self:redrawBackground()
end