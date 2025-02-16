--[[
	No input
	Multiple midi outs...
	Each channel has a single note set via encoder
]]--
import 'CoreLibs/graphics'
import 'Modules/Sequencers/DroneSequencer/drone_seq_component'

class('DroneSeqMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 85
local moduleHeight = 120

local stepImage = playdate.graphics.image.new("Images/step")

local modType = "DroneSeqMod"
local modSubtype = "midi"

function DroneSeqMod:init(xx, yy, modId)
	DroneSeqMod.super.init(self)
	
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
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(97, 25)
	rightSocket:draw(97, 51)
	rightSocket:draw(97, 79)
	rightSocket:draw(97, 107)
	local droneseqImage = gfx.imageWithText("DroneSeq", 100, 10)
	droneseqImage:drawRotated(28, bgH/2, -90)
	gfx.popContext()
	self.backgroundImage = backgroundImage
	
	self:moveTo(xx, yy)
	self:add()
	
	self.component = DroneSeqComponent()
	
	self.channel1NoteLabel = "--"
	self.channel1EncoderVector = Vector(xx + (moduleWidth/2) - 18, yy - (moduleHeight/2) + 18)
	self.channel1EncoderValue = 0.0
	
	self.channel2NoteLabel = "--"
	self.channel2EncoderVector = Vector(xx + (moduleWidth/2) - 18, yy - (moduleHeight/2) + 46)
	self.channel2EncoderValue = 0.0
	
	self.channel3NoteLabel = "--"
	self.channel3EncoderVector = Vector(xx + (moduleWidth/2) - 18, yy - (moduleHeight/2) + 74)
	self.channel3EncoderValue = 0.0
	
	self.channel4NoteLabel = "--"
	self.channel4EncoderVector = Vector(xx + (moduleWidth/2) - 18, yy - (moduleHeight/2) + 102)
	self.channel4EncoderValue = 0.0
	
	self.encoderVectors = {
		self.channel1EncoderVector,
		self.channel2EncoderVector,
		self.channel3EncoderVector,
		self.channel4EncoderVector,
	}
	
	self.socketOutVector1 = Vector(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + 24)
	self.socketOutVector2 = Vector(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + 48)
	self.socketOutVector3 = Vector(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + 72)
	self.socketOutVector4 = Vector(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + 96)

	self:redrawBackground()
end

function DroneSeqMod:redrawBackground()
	self.redrawPending = false
	gEncoder:hide()
	local backgroundImage = gfx.image.new(self.bgW, self.bgH)
	gfx.pushContext(backgroundImage)
	self.backgroundImage:draw(0, 0)

	--encoders
	gEncoder:setValue(self.channel1EncoderValue)
	local channel1EncoderImage = gEncoder:getImage()
	channel1EncoderImage:draw(71, 22)
	gfx.drawTextAligned(self.channel1NoteLabel, 65, 28, kTextAlignment.right)
	
	gEncoder:setValue(self.channel2EncoderValue)
	local channel2EncoderImage = gEncoder:getImage()
	channel2EncoderImage:draw(71, 50)
	gfx.drawTextAligned(self.channel2NoteLabel, 65, 56, kTextAlignment.right)
	
	gEncoder:setValue(self.channel3EncoderValue)
	local channel3EncoderImage = gEncoder:getImage()
	channel3EncoderImage:draw(71, 78)
	gfx.drawTextAligned(self.channel3NoteLabel, 65, 84, kTextAlignment.right)
	
	gEncoder:setValue(self.channel4EncoderValue)
	local channel4EncoderImage = gEncoder:getImage()
	channel4EncoderImage:draw(71, 106)
	gfx.drawTextAligned(self.channel4NoteLabel, 65, 112, kTextAlignment.right)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
end

function DroneSeqMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function DroneSeqMod:findClosestEncoderVector(x, y)
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

function DroneSeqMod:setOutCable(patchCable)	
	if self.component:channelFree(1) then 
		self.outCable1 = patchCable
		patchCable:setStart(self.socketOutVector1.x, self.socketOutVector1.y, self.modId)
		self.component:setChannelCable(1, patchCable:getCable())
		return true	
	elseif self.component:channelFree(2) then 
		self.outCable2 = patchCable
		patchCable:setStart(self.socketOutVector2.x, self.socketOutVector2.y, self.modId)
		self.component:setChannelCable(2, patchCable:getCable())
		return true	
	elseif self.component:channelFree(3) then 
		self.outCable3 = patchCable
		patchCable:setStart(self.socketOutVector3.x, self.socketOutVector3.y, self.modId)
		self.component:setChannelCable(3, patchCable:getCable())
		return true	
	elseif self.component:channelFree(4) then 
		self.outCable4 = patchCable
		patchCable:setStart(self.socketOutVector4.x, self.socketOutVector4.y, self.modId)
		self.component:setChannelCable(4, patchCable:getCable())
		return true	
	end
end

function DroneSeqMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:channelFree(1) then 
		ghostCable:setStart(self.socketOutVector1.x, self.socketOutVector1.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true	
	elseif self.component:channelFree(2) then 
		ghostCable:setStart(self.socketOutVector2.x, self.socketOutVector2.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true	
	elseif self.component:channelFree(3) then 
		ghostCable:setStart(self.socketOutVector3.x, self.socketOutVector3.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true	
	elseif self.component:channelFree(4) then 
		ghostCable:setStart(self.socketOutVector4.x, self.socketOutVector4.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true	
	else
		print("DroneSeqMod is full")
		return false
	end
end

function DroneSeqMod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end
	
	if encoderVector == self.channel1EncoderVector then
		gEncoder:setValue(self.channel1EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.channel1EncoderVector.x, self.channel1EncoderVector.y)
		gEncoder:turn(change)
		self.channel1EncoderValue = gEncoder:getValue()
		self.component:setNoteValue(1, self.channel1EncoderValue, function(label) 
			self.channel1NoteLabel = label
			self:redrawBackground()
		end)
	elseif encoderVector == self.channel2EncoderVector then
		gEncoder:setValue(self.channel2EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.channel2EncoderVector.x, self.channel2EncoderVector.y)
		gEncoder:turn(change)
		self.channel2EncoderValue = gEncoder:getValue()
		self.component:setNoteValue(2, self.channel2EncoderValue, function(label) 
			self.channel2NoteLabel = label
			self:redrawBackground()
		end)
	elseif encoderVector == self.channel3EncoderVector then
		gEncoder:setValue(self.channel3EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.channel3EncoderVector.x, self.channel3EncoderVector.y)
		gEncoder:turn(change)
		self.channel3EncoderValue = gEncoder:getValue()
		self.component:setNoteValue(3, self.channel3EncoderValue, function(label) 
			self.channel3NoteLabel = label
			self:redrawBackground()
		end)
	elseif encoderVector == self.channel4EncoderVector then
		gEncoder:setValue(self.channel4EncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.channel4EncoderVector.x, self.channel4EncoderVector.y)
		gEncoder:turn(change)
		self.channel4EncoderValue = gEncoder:getValue()
		self.component:setNoteValue(4, self.channel4EncoderValue, function(label) 
			self.channel4NoteLabel = label
			self:redrawBackground()
		end)
	end
	
	self.redrawPending = true
end

function DroneSeqMod:retrigger()
	self.component:retrigger()
end

function DroneSeqMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function DroneSeqMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "Play/Retrigger"},
		{label = "Stop"},
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "Play/Retrigger" then
			self.component:retrigger()
		elseif action == "Stop" then
			self.component:allNotesOff()
		elseif action == "About" then
			local aboutPopup = ModAboutPopup("Each channel emits a single note when its encoder is turned.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function DroneSeqMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function DroneSeqMod:moveFinish()
	self.channel1EncoderVector = Vector(self.x + (moduleWidth/2) - 18, self.y - (moduleHeight/2) + 18)
	self.channel2EncoderVector = Vector(self.x + (moduleWidth/2) - 18, self.y - (moduleHeight/2) + 46)
	self.channel3EncoderVector = Vector(self.x + (moduleWidth/2) - 18, self.y - (moduleHeight/2) + 74)
	self.channel4EncoderVector = Vector(self.x + (moduleWidth/2) - 18, self.y - (moduleHeight/2) + 102)

	self.encoderVectors = {
		self.channel1EncoderVector,
		self.channel2EncoderVector,
		self.channel3EncoderVector,
		self.channel4EncoderVector,
	}

	self.socketOutVector1 = Vector(self.x + (moduleWidth/2)+2, self.y - (moduleHeight/2) + 24)
	self.socketOutVector2 = Vector(self.x + (moduleWidth/2)+2, self.y - (moduleHeight/2) + 48)
	self.socketOutVector3 = Vector(self.x + (moduleWidth/2)+2, self.y - (moduleHeight/2) + 72)
	self.socketOutVector4 = Vector(self.x + (moduleWidth/2)+2, self.y - (moduleHeight/2) + 96)

end

function DroneSeqMod:evaporate(onDetachConnected)
	
	self.component:allNotesOff()
	
	if self.component:connected(1) then 
		onDetachConnected(self.outCable1:getEndModId(), self.outCable1:getCableId())
		self.component:unplug(1)
		self.outCable1:evaporate()
		self.outCable1 = nil
	end
		
	if self.component:connected(2) then 
		onDetachConnected(self.outCable2:getEndModId(), self.outCable2:getCableId())
		self.component:unplug(2)
		self.outCable2:evaporate()
		self.outCable2 = nil
	end
	
	if self.component:connected(3) then 
		onDetachConnected(self.outCable3:getEndModId(), self.outCable3:getCableId())
		self.component:unplug(3)
		self.outCable3:evaporate()
		self.outCable3 = nil
	end
	
	if self.component:connected(4) then 
		onDetachConnected(self.outCable4:getEndModId(), self.outCable4:getCableId())
		self.component:unplug(4)
		self.outCable4:evaporate()
		self.outCable4 = nil
	end

	self:remove()
end

function DroneSeqMod:unplug(cableId) self.component:unplug(cableId) end
function DroneSeqMod:type() return modType end
function DroneSeqMod:getModId() return self.modId end
function DroneSeqMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function DroneSeqMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.channel1EncoderVal = self.channel1EncoderValue
	modState.channel2EncoderVal = self.channel2EncoderValue
	modState.channel3EncoderVal = self.channel3EncoderValue
	modState.channel4EncoderVal = self.channel4EncoderValue
		
	return modState
end

function DroneSeqMod:fromState(modState)
	self.channel1EncoderValue = modState.channel1EncoderVal
	self.channel2EncoderValue = modState.channel2EncoderVal
	self.channel3EncoderValue = modState.channel3EncoderVal
	self.channel4EncoderValue = modState.channel4EncoderVal
	
	self.component:setNoteValue(1, self.channel1EncoderValue, function(label) 
		self.channel1NoteLabel = label
	end)
	self.component:setNoteValue(2, self.channel2EncoderValue, function(label) 
		self.channel2NoteLabel = label
	end)
	self.component:setNoteValue(3, self.channel4EncoderValue, function(label) 
		self.channel3NoteLabel = label
	end)
	self.component:setNoteValue(4, self.channel4EncoderValue, function(label) 
		self.channel4NoteLabel = label
	end)
	
	self:redrawBackground()
end