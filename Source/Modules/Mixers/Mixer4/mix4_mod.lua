import 'Modules/mod_utils.lua'
import 'Modules/Mixers/Mixer4/mix4_component'
import 'Modules/Sprites/small_socket_sprite'

class('Mix4Mod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 105
local moduleHeight = 100
local grillDiam = 140

local modType = "Mix4Mod"
local modSubtype = "audio_effect"

function Mix4Mod:init(xx, yy, modId)
	Mix4Mod.super.init(self)
	
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
	
	-- Speaker grill:
	gfx.setColor(playdate.graphics.kColorBlack)
  for x = 1,4 do
		for y = 1,8 do
			gfx.fillCircleAtPoint(60 + (x * 12), 15 + (y * 11), 4) 
		end
	end
	
	local smallSocket = assets:image("small_socket")
	smallSocket:draw(21, 23)
	smallSocket:draw(21, 45)
	smallSocket:draw(21, 67)
	smallSocket:draw(21, 89)
	
	gfx.popContext()
	
	self.backgroundImage = backgroundImage
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.mixer = Mixer4Component()

	local inSocketX = xx - (moduleWidth/2) + 15
	local inSocketYInc = 22
	self.in1SocketVector = Vector(inSocketX, yy - (moduleHeight/2) + inSocketYInc - 5)
	self.in2SocketVector = Vector(inSocketX, yy - (moduleHeight/2) + (inSocketYInc * 2) - 5)
	self.in3SocketVector = Vector(inSocketX, yy - (moduleHeight/2) + (inSocketYInc * 3) - 5)
	self.in4SocketVector = Vector(inSocketX, yy - (moduleHeight/2) + (inSocketYInc * 4) - 5)

	local encoderX = inSocketX + 22
	
	self.volumeEncoder1Vector = Vector(encoderX, yy - (moduleHeight/2) + inSocketYInc - 5)
	self.volumeEncoder1Value = 0.0
	
	self.volumeEncoder2Vector = Vector(encoderX, yy - (moduleHeight/2) + (inSocketYInc * 2) - 5)
	self.volumeEncoder2Value = 0.0
	
	self.volumeEncoder3Vector = Vector(encoderX, yy - (moduleHeight/2) + (inSocketYInc * 3) - 5)
	self.volumeEncoder3Value = 0.0
	
	self.volumeEncoder4Vector = Vector(encoderX, yy - (moduleHeight/2) + (inSocketYInc * 4) - 5)
	self.volumeEncoder4Value = 0.0

	self.encoderVectors = {
		self.volumeEncoder1Vector,
		self.volumeEncoder2Vector,
		self.volumeEncoder3Vector,
		self.volumeEncoder4Vector
	}
	
	self:redrawBackground()
end

function Mix4Mod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = playdate.graphics.image.new(self.bgW, self.bgH)
	gfx.pushContext(backgroundImage)
	self.backgroundImage:draw(0, 0)
	
	gEncoder:setValue(self.volumeEncoder1Value)
	local volumeEncoder1Image = gEncoder:getImage()
	volumeEncoder1Image:draw(41, 21)
	
	gEncoder:setValue(self.volumeEncoder2Value)
	local volumeEncoder2Image = gEncoder:getImage()
	volumeEncoder2Image:draw(41, 43)
	
	gEncoder:setValue(self.volumeEncoder3Value)
	local volumeEncoder3Image = gEncoder:getImage()
	volumeEncoder3Image:draw(41, 65)
	
	gEncoder:setValue(self.volumeEncoder4Value)
	local volumeEncoder4Image = gEncoder:getImage()
	volumeEncoder4Image:draw(41, 87)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function Mix4Mod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end

	if encoderVector == self.volumeEncoder1Vector then
		gEncoder:setValue(self.volumeEncoder1Value)
		gEncoder:show()
		gEncoder:moveTo(self.volumeEncoder1Vector.x, self.volumeEncoder1Vector.y)
		gEncoder:turn(change)
		self.volumeEncoder1Value = gEncoder:getValue()
		self.mixer:trySetVolume(1, self.volumeEncoder1Value)
	elseif encoderVector == self.volumeEncoder2Vector then
		gEncoder:setValue(self.volumeEncoder2Value)
		gEncoder:show()
		gEncoder:moveTo(self.volumeEncoder2Vector.x, self.volumeEncoder2Vector.y)
		gEncoder:turn(change)
		self.volumeEncoder2Value = gEncoder:getValue()
		self.mixer:trySetVolume(2, self.volumeEncoder2Value)
	elseif encoderVector == self.volumeEncoder3Vector then
		gEncoder:setValue(self.volumeEncoder3Value)
		gEncoder:show()
		gEncoder:moveTo(self.volumeEncoder3Vector.x, self.volumeEncoder3Vector.y)
		gEncoder:turn(change)
		self.volumeEncoder3Value = gEncoder:getValue()
		self.mixer:trySetVolume(3, self.volumeEncoder3Value)
	elseif encoderVector == self.volumeEncoder4Vector then
		gEncoder:setValue(self.volumeEncoder4Value)
		gEncoder:show()
		gEncoder:moveTo(self.volumeEncoder4Vector.x, self.volumeEncoder4Vector.y)
		gEncoder:turn(change)
		self.volumeEncoder4Value = gEncoder:getValue()
		self.mixer:trySetVolume(4, self.volumeEncoder4Value)
	end
	
	self.redrawPending = true
end

function Mix4Mod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function Mix4Mod:findClosestEncoderVector(x, y)
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

function Mix4Mod:collision(x, y)
	if x > self.x - (self.width/2) and x < self.x + (self.width/2) and y > self.y - (self.height/2) and y < self.y + (self.height/2) then
		return true
	else
		return false
	end
end

function Mix4Mod:type()
	return self.modType
end

function Mix4Mod:getModId()
	return self.modId
end

function Mix4Mod:setInCable(patchCable)
	if self.mixer:in1Free() then
		patchCable:setEnd(self.in1SocketVector.x, self.in1SocketVector.y, self.modId)
		self.mixer:setIn1Cable(patchCable:getCable())
		self.in1Cable = patchCable
	elseif self.mixer:in2Free() then
		patchCable:setEnd(self.in2SocketVector.x, self.in2SocketVector.y, self.modId)
		self.mixer:setIn2Cable(patchCable:getCable())
		self.in2Cable = patchCable
	elseif self.mixer:in3Free() then
		patchCable:setEnd(self.in3SocketVector.x, self.in3SocketVector.y, self.modId)
		self.mixer:setIn3Cable(patchCable:getCable())
		self.in3Cable = patchCable
	elseif self.mixer:in4Free() then
		patchCable:setEnd(self.in4SocketVector.x, self.in4SocketVector.y, self.modId)
		self.mixer:setIn4Cable(patchCable:getCable())
		self.in4Cable = patchCable
	end
end

function Mix4Mod:setChannel(channel)
	if channel == nil then
		print("Mix4Mod:setChannel() CHANNEL IS NIL")
	else
		print("Mix4Mod:setChannel() CHANNEL EXISTS!")
	end
	if self.mixer:in1Free() then
		print("IN 1 is FREE - setting channel")
		self.mixer:setChannel(1, channel)
	elseif self.mixer:in2Free() then
		self.mixer:setChannel(2, channel)
	elseif self.mixer:in3Free() then
		self.mixer:setChannel(3, channel)
	elseif self.mixer:in4Free() then
		self.mixer:setChannel(4, channel)
	end
end

function Mix4Mod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype)
	
	if sourceSubtype == "midi" or sourceSubtype == "clock_router" then
		return false
	end
	
	local socketVector = nil
	if self.mixer:in1Free() then
		socketVector = self.in1SocketVector
	elseif self.mixer:in2Free() then
		socketVector = self.in2SocketVector
	elseif self.mixer:in3Free() then
		socketVector = self.in3SocketVector
	elseif self.mixer:in4Free() then
		socketVector = self.in4SocketVector
	end
	
	if socketVector ~= nil then
		ghostCable:setEnd(socketVector.x, socketVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	else
		return false
	end
end

function Mix4Mod:tryConnectGhostOut(x, y, ghostCable)
	return false
end

function Mix4Mod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end


function Mix4Mod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action, index) 
		self.menuIndex = index
		if action == "About" then
			local aboutPopup = ModAboutPopup("A mixer with 4 channels")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end, self.menuIndex)
end

function Mix4Mod:unplug(cableId)
	if self.mixer:in1Connected() and self.mixer:getCableId(1) == cableId then
		self.mixer:unplug(1)
	elseif self.mixer:in2Connected() and self.mixer:getCableId(2) == cableId then
		self.mixer:unplug(2)
	elseif self.mixer:in3Connected() and self.mixer:getCableId(3) == cableId then
		self.mixer:unplug(3)
	elseif self.mixer:in4Connected() and self.mixer:getCableId(4) == cableId then
		self.mixer:unplug(4)
	end
end

function Mix4Mod:repositionBy(x, y)
	self:moveBy(x, y)
end

function Mix4Mod:moveFinish()
	local inSocketX = self.x - (moduleWidth/2) + 15
	local inSocketYInc = 22
	self.in1SocketVector = Vector(inSocketX, self.y - (moduleHeight/2) + inSocketYInc - 5)
	self.in2SocketVector = Vector(inSocketX, self.y - (moduleHeight/2) + (inSocketYInc * 2) - 5)
	self.in3SocketVector = Vector(inSocketX, self.y - (moduleHeight/2) + (inSocketYInc * 3) - 5)
	self.in4SocketVector = Vector(inSocketX, self.y - (moduleHeight/2) + (inSocketYInc * 4) - 5)
	
	local encoderX = inSocketX + 22
	
	self.volumeEncoder1Vector = Vector(encoderX, self.y - (moduleHeight/2) + inSocketYInc - 5)
	self.volumeEncoder2Vector = Vector(encoderX, self.y - (moduleHeight/2) + (inSocketYInc * 2) - 5)
	self.volumeEncoder3Vector = Vector(encoderX, self.y - (moduleHeight/2) + (inSocketYInc * 3) - 5)
	self.volumeEncoder4Vector = Vector(encoderX, self.y - (moduleHeight/2) + (inSocketYInc * 4) - 5)
	
	self.encoderVectors = {
		self.volumeEncoder1Vector,
		self.volumeEncoder2Vector,
		self.volumeEncoder3Vector,
		self.volumeEncoder4Vector
	}
end

function Mix4Mod:evaporate(onDetachConnected)
	--first detach cables
	if self.mixer:in1Connected() then
		onDetachConnected(self.in1Cable:getStartModId(), self.in1Cable:getCableId())
		self.mixer:unplugIn1()
		self.in1Cable:evaporate()
	end
	
	if self.mixer:in2Connected() then
		onDetachConnected(self.in2Cable:getStartModId(), self.in2Cable:getCableId())
		self.mixer:unplugIn2()
		self.in2Cable:evaporate()
	end
	
	if self.mixer:in3Connected() then
		onDetachConnected(self.in3Cable:getStartModId(), self.in3Cable:getCableId())
		self.mixer:unplugIn3()
		self.in3Cable:evaporate()
	end
	
	if self.mixer:in4Connected() then
		onDetachConnected(self.in4Cable:getStartModId(), self.in4Cable:getCableId())
		self.mixer:unplugIn4()
		self.in4Cable:evaporate()
	end
	
	self:remove()
end

function Mix4Mod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.volumeEncoder1Value = self.volumeEncoder1Value
	modState.volumeEncoder2Value = self.volumeEncoder2Value
	modState.volumeEncoder3Value = self.volumeEncoder3Value
	modState.volumeEncoder4Value = self.volumeEncoder4Value
	return modState
end

function Mix4Mod:fromState(modState)
	self.volumeEncoder1Value = modState.volumeEncoder1Value 
	self.volumeEncoder2Value = modState.volumeEncoder2Value 
	self.volumeEncoder3Value = modState.volumeEncoder3Value 
	self.volumeEncoder4Value = modState.volumeEncoder4Value 
	
	self.mixer:trySetVolume(1, self.volumeEncoder1Value)
	self.mixer:trySetVolume(2, self.volumeEncoder2Value)
	self.mixer:trySetVolume(3, self.volumeEncoder3Value)
	self.mixer:trySetVolume(4, self.volumeEncoder4Value)
	
	self:redrawBackground()
end