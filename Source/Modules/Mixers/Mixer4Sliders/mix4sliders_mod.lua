import 'Modules/mod_utils.lua'
import 'CoracleViews/vertical_slider'
import 'Modules/Mixers/Mixer4Sliders/mix4sliders_component'
import 'Modules/Sprites/small_socket_sprite'

class('Mix4SliderMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 150
local moduleHeight = 115
local grillDiam = 140

local modType = "Mix4SliderMod"
local modSubtype = "audio_effect"

function Mix4SliderMod:init(xx, yy, modId)
	Mix4SliderMod.super.init(self)
	
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
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
  for x = 1,4 do
		for y = 1,9 do
			gfx.fillCircleAtPoint(105 + (x * 12), 16 + (y * 11), 4) 
		end
	end
	
	local socketXInc = 22
	
	local smallSocket = assets:image("small_socket")
	smallSocket:draw(21, 20)
	smallSocket:draw(21 + socketXInc, 20)
	smallSocket:draw(21 + (socketXInc * 2), 20)
	smallSocket:draw(21 + (socketXInc * 3), 20)
	
	local bottomSocket = assets:image("side_socket_bottom")
	bottomSocket:draw(21, moduleHeight + 13)
	bottomSocket:draw(21 + socketXInc, moduleHeight + 13)
	bottomSocket:draw(21 + (socketXInc * 2), moduleHeight + 13)
	bottomSocket:draw(21 + (socketXInc * 3), moduleHeight + 13)
	
	local sliderBackplate = gSlider:getBackplateImage()
	sliderBackplate:draw(20, 68)
	sliderBackplate:draw(42, 68)
	sliderBackplate:draw(64, 68)
	sliderBackplate:draw(86, 68)
	
	gfx.popContext()
	
	self.backgroundImage = backgroundImage
	
	self:moveTo(xx, yy)
	self:add()
	
	local inSocketX = xx - (moduleWidth/2) + 15
	local inSocketY = yy - (moduleHeight/2) + 10
	self.in1SocketVector = Vector(inSocketX, inSocketY)
	self.in2SocketVector = Vector(inSocketX + socketXInc, inSocketY)
	self.in3SocketVector = Vector(inSocketX + (socketXInc * 2), inSocketY)
	self.in4SocketVector = Vector(inSocketX + (socketXInc * 3), inSocketY)
	
	local autoSocketY = yy + (moduleHeight/2) + 4
	self.auto1SocketVector = Vector(inSocketX, autoSocketY)
	self.auto2SocketVector = Vector(inSocketX + socketXInc, autoSocketY)
	self.auto3SocketVector = Vector(inSocketX + (socketXInc * 2), autoSocketY)
	self.auto4SocketVector = Vector(inSocketX + (socketXInc * 3), autoSocketY)
	
	self.automationVectors = {
		self.auto1SocketVector,
		self.auto2SocketVector,
		self.auto3SocketVector,
		self.auto4SocketVector
	}
	
	local sliderXInc = 22
	
	self.slider1Value = 0.0
	self.slider2Value = 0.0
	self.slider3Value = 0.0
	self.slider4Value = 0.0
	
	self.slider1 = VerticalSlider(xx - (moduleWidth/2) + 15, yy + 20, 0.0, function(value) 
		self.slider1Value = value
		self.component:trySetVolume(1, value)
	end)
	
	self.slider2 = VerticalSlider(xx - (moduleWidth/2) + 15 + sliderXInc, yy + 20, 0.0, function(value)
		self.slider2Value = value 
		self.component:trySetVolume(2, value)
	end)
	
	self.slider3 = VerticalSlider(xx - (moduleWidth/2) + 15 + (sliderXInc * 2), yy + 20, 0.0, function(value) 
		self.slider3Value = value
		self.component:trySetVolume(3, value)
	end)
	
	self.slider4 = VerticalSlider(xx - (moduleWidth/2) + 15 + (sliderXInc * 3), yy + 20, 0.0, function(value) 
		self.slider4Value = value
		self.component:trySetVolume(4, value)
	end)
			
	self.sliders = {
		self.slider1,
		self.slider2,
		self.slider3,
		self.slider4
	}
	
	self.pan1EncoderVector = Vector(xx - (moduleWidth/2) + 15, yy - 22)
	self.pan1EncoderValue = 0.5
	
	self.pan2EncoderVector = Vector(xx - (moduleWidth/2) + 15 + sliderXInc, yy - 22)
	self.pan2EncoderValue = 0.5
	
	self.pan3EncoderVector = Vector(xx - (moduleWidth/2) + 15 + (sliderXInc * 2), yy - 22)
	self.pan3EncoderValue = 0.5
	
	self.pan4EncoderVector = Vector(xx - (moduleWidth/2) + 15 + (sliderXInc * 3), yy - 22)
	self.pan4EncoderValue = 0.5
	
	self.encoderVectors = {
		self.pan1EncoderVector,
		self.pan2EncoderVector,
		self.pan3EncoderVector,
		self.pan4EncoderVector
	}
	
	self.component = Mixer4SlidersComponent(function(index, value) 
		if self.sliders ~= nil then
			self.sliders[index]:setValueWithListener(value)
		end
	end)
	
	self:redrawBackground()
end

function Mix4SliderMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = playdate.graphics.image.new(self.bgW, self.bgH)
	gfx.pushContext(backgroundImage)
	self.backgroundImage:draw(0, 0)
	
	gEncoder:setValue(self.pan1EncoderValue)
	local pan1EncoderImage = gEncoder:getImage()
	pan1EncoderImage:draw(19, 40)
	
	gEncoder:setValue(self.pan2EncoderValue)
	local pan2EncoderImage = gEncoder:getImage()
	pan2EncoderImage:draw(41, 40)
	
	gEncoder:setValue(self.pan3EncoderValue)
	local pan3EncoderImage = gEncoder:getImage()
	pan3EncoderImage:draw(63, 40)
	
	gEncoder:setValue(self.pan4EncoderValue)
	local pan4EncoderImage = gEncoder:getImage()
	pan4EncoderImage:draw(85, 40)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	
	self.redrawPending = false
end

function Mix4SliderMod:findClosestEncoderVector(x, y)
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

function Mix4SliderMod:findClosestSlider(x, y)
	if self.sliders == nil then return nil end
	local reticleVector = Vector(x, y)
	local closestDistance = 1000
	local closestIndex = -1
	for i=1,#self.sliders do
		local aSlider = self.sliders[i]
		local sliderVector = Vector(aSlider.x, aSlider.y)
		local distance = reticleVector:distance(sliderVector)
		if distance < closestDistance then
			closestDistance = distance
			closestIndex = i
		end
	end
	
	return self.sliders[closestIndex]
end

function Mix4SliderMod:findClosestAutomationVector(x, y)
	local reticleVector = Vector(x, y)
	local closestDistance = 1000
	local closestIndex = -1
	for i=1,#self.automationVectors do
		local aVector = self.automationVectors[i]
		local distance = reticleVector:distance(aVector)
		if distance < closestDistance then
			closestDistance = distance
			closestIndex = i
		end
	end
	
	return self.automationVectors[closestIndex]
end

function Mix4SliderMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end


function Mix4SliderMod:turn(x, y, change)
	if y > self.y - 10 then
		local slider = self:findClosestSlider(x, y)
		if slider ~= nil then
			slider:turn(change)
		end
	else
		local encoderVector = nil
		if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
			encoderVector = self:findClosestEncoderVector(x, y)
			self.lastEncoderX = x
			self.lastEncoderY = y
			self.lastEncoderVector = encoderVector
		else
			encoderVector = self.lastEncoderVector
		end
		
		if encoderVector == self.pan1EncoderVector then
			gEncoder:setValue(self.pan1EncoderValue)
			gEncoder:show()
			gEncoder:moveTo(self.pan1EncoderVector.x, self.pan1EncoderVector.y)
			gEncoder:turn(change)
			self.pan1EncoderValue = gEncoder:getValue()
			self.component:setPan(1, self.pan1EncoderValue)
		elseif encoderVector == self.pan2EncoderVector then
			gEncoder:setValue(self.pan2EncoderValue)
			gEncoder:show()
			gEncoder:moveTo(self.pan2EncoderVector.x, self.pan2EncoderVector.y)
			gEncoder:turn(change)
			self.pan2EncoderValue = gEncoder:getValue()
			self.component:setPan(2, self.pan2EncoderValue)
		elseif encoderVector == self.pan3EncoderVector then
			gEncoder:setValue(self.pan3EncoderValue)
			gEncoder:show()
			gEncoder:moveTo(self.pan3EncoderVector.x, self.pan3EncoderVector.y)
			gEncoder:turn(change)
			self.pan3EncoderValue = gEncoder:getValue()
			self.component:setPan(3, self.pan3EncoderValue)
		elseif encoderVector == self.pan4EncoderVector then
			gEncoder:setValue(self.pan4EncoderValue)
			gEncoder:show()
			gEncoder:moveTo(self.pan4EncoderVector.x, self.pan4EncoderVector.y)
			gEncoder:turn(change)
			self.pan4EncoderValue = gEncoder:getValue()
			self.component:setPan(4, self.pan4EncoderValue)
		end
		
		self.redrawPending = true
	end
end

function Mix4SliderMod:collision(x, y)
	if x > self.x - (self.width/2) and x < self.x + (self.width/2) and y > self.y - (self.height/2) and y < self.y + (self.height/2) then
		return true
	else
		return false
	end
end

function Mix4SliderMod:type()
	return modType
end

function Mix4SliderMod:getModId()
	return self.modId
end

function Mix4SliderMod:setInCable(patchCable, sourceSubtype)
	
	local isAutomation = true
	
	if sourceSubtype == nil then sourceSubtype = self.sourceSubtype end
	
	print("mix4s source subtype: " .. sourceSubtype)
	
	if sourceSubtype == "audio_gen" or sourceSubtype == "audio_effect" then
		isAutomation = false
	end
	
	if isAutomation and patchCable:getEndY() > self.y then
		print("connect to automation inputs")
		local pX, pY = patchCable:getEndXY()
		local closestAutomationVector = self:findClosestAutomationVector(pX, pY)
		if closestAutomationVector.x == self.auto1SocketVector.x then
			patchCable:setEnd(self.auto1SocketVector.x, self.auto1SocketVector.y, self.modId)
			self.component:setAutoInCable(1, patchCable:getCable())
			self.autoIn1Cable = patchCable
		elseif closestAutomationVector.x == self.auto2SocketVector.x then
			patchCable:setEnd(self.auto2SocketVector.x, self.auto2SocketVector.y, self.modId)
			self.component:setAutoInCable(2, patchCable:getCable())
			self.autoIn2Cable = patchCable
		elseif closestAutomationVector.x == self.auto3SocketVector.x then
			patchCable:setEnd(self.auto3SocketVector.x, self.auto3SocketVector.y, self.modId)
			self.component:setAutoInCable(3, patchCable:getCable())
			self.autoIn3Cable = patchCable
		elseif closestAutomationVector.x == self.auto4SocketVector.x then
			patchCable:setEnd(self.auto4SocketVector.x, self.auto4SocketVector.y, self.modId)
			self.component:setAutoInCable(4, patchCable:getCable())
			self.autoIn4Cable = patchCable
		end
		
		return
	end
	
	
	if self.component:in1Free() then
		print("setInCable() self.component:in1Free()...")
		patchCable:setEnd(self.in1SocketVector.x, self.in1SocketVector.y, self.modId)
		self.component:setIn1Cable(patchCable:getCable())
		self.in1Cable = patchCable
	elseif self.component:in2Free() then
		patchCable:setEnd(self.in2SocketVector.x, self.in2SocketVector.y, self.modId)
		self.component:setIn2Cable(patchCable:getCable())
		self.in2Cable = patchCable
	elseif self.component:in3Free() then
		patchCable:setEnd(self.in3SocketVector.x, self.in3SocketVector.y, self.modId)
		self.component:setIn3Cable(patchCable:getCable())
		self.in3Cable = patchCable
	elseif self.component:in4Free() then
		patchCable:setEnd(self.in4SocketVector.x, self.in4SocketVector.y, self.modId)
		self.component:setIn4Cable(patchCable:getCable())
		self.in4Cable = patchCable
	end
end

function Mix4SliderMod:setChannel(channel)
	if channel == nil then
		print("Mix4SliderMod:setChannel() CHANNEL IS NIL")
	else
		print("Mix4SliderMod:setChannel() CHANNEL EXISTS!")
	end
	if self.component:in1Free() then
		print("Mix4SliderMod self.component:in1Free() true")
		self.component:setChannel(1, channel)
	elseif self.component:in2Free() then
		self.component:setChannel(2, channel)
	elseif self.component:in3Free() then
		self.component:setChannel(3, channel)
	elseif self.component:in4Free() then
		self.component:setChannel(4, channel)
	end
end

function Mix4SliderMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype)
	
	self.sourceSubtype = sourceSubtype
	if sourceSubtype == "midi" then
		return false
	end
	
	local isAutomation = true
	
	print("mix4s source subtype: " .. sourceSubtype)
	
	if sourceSubtype == "audio_gen" or sourceSubtype == "audio_effect" then
		isAutomation = false
	end
	
	if isAutomation == true and ghostCable:getEndY() > self.y then
		
		print("connect to automation inputs")
		local pX, pY = ghostCable:getEndXY()
		local closestAutomationVector = self:findClosestAutomationVector(pX, pY)
		if closestAutomationVector.x == self.auto1SocketVector.x then
			if self.component:autoInFree(1) then
				ghostCable:setEnd(closestAutomationVector.x, closestAutomationVector.y)
				ghostCable:setGhostReceiveConnected()
				return true
			else
				return false
			end
		elseif closestAutomationVector.x == self.auto2SocketVector.x then
			if self.component:autoInFree(2) then
				ghostCable:setEnd(closestAutomationVector.x, closestAutomationVector.y)
				ghostCable:setGhostReceiveConnected()
				return true
			else
				return false
			end
		elseif closestAutomationVector.x == self.auto3SocketVector.x then
			if self.component:autoInFree(3) then
				ghostCable:setEnd(closestAutomationVector.x, closestAutomationVector.y)
				ghostCable:setGhostReceiveConnected()
				return true
			else
				return false
			end
		elseif closestAutomationVector.x == self.auto4SocketVector.x then
			if self.component:autoInFree(4) then
				ghostCable:setEnd(closestAutomationVector.x, closestAutomationVector.y)
				ghostCable:setGhostReceiveConnected()
				return true
			else
				return false
			end
		end
	end
	
	-- If we got this far and it's automation return false - need to drop cable lower down for automation, and this prevents automation connecting to audio ins
	if isAutomation then
		return false
	end
	
	local socketVector = nil
	if self.component:in1Free() then
		print("infree1")
		socketVector = self.in1SocketVector
	elseif self.component:in2Free() then
		print("infree2")
		socketVector = self.in2SocketVector
	elseif self.component:in3Free() then
		print("infree3")
		socketVector = self.in3SocketVector
	elseif self.component:in4Free() then
		print("infree4")
		socketVector = self.in4SocketVector
	end
	
	if socketVector ~= nil then
		ghostCable:setEnd(socketVector.x, socketVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	else
		print("No free sockets found")
		return false
	end
end

function Mix4SliderMod:tryConnectGhostOut(x, y, ghostCable) return false end
function Mix4SliderMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function Mix4SliderMod:handleModClick(tX, tY, listener)
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

function Mix4SliderMod:unplug(cableId) self.component:unplug(cableId) end

function Mix4SliderMod:repositionBy(x, y)
	self:moveBy(x, y)
	self.slider1:repositionBy(x, y)
	self.slider2:repositionBy(x, y)
	self.slider3:repositionBy(x, y)
	self.slider4:repositionBy(x, y)
end

function Mix4SliderMod:moveFinish()
	local socketXInc = 22
	local sliderXInc = 22
	local inSocketX = self.x - (moduleWidth/2) + 15
	local inSocketY = self.y - (moduleHeight/2) + 10
	self.in1SocketVector = Vector(inSocketX, inSocketY)
	self.in2SocketVector = Vector(inSocketX + socketXInc, inSocketY)
	self.in3SocketVector = Vector(inSocketX + (socketXInc * 2), inSocketY)
	self.in4SocketVector = Vector(inSocketX + (socketXInc * 3), inSocketY)
	
	local autoSocketY = self.y + (moduleHeight/2) + 4
	self.auto1SocketVector = Vector(inSocketX, autoSocketY)
	self.auto2SocketVector = Vector(inSocketX + socketXInc, autoSocketY)
	self.auto3SocketVector = Vector(inSocketX + (socketXInc * 2), autoSocketY)
	self.auto4SocketVector = Vector(inSocketX + (socketXInc * 3), autoSocketY)
	
	self.automationVectors = {
		self.auto1SocketVector,
		self.auto2SocketVector,
		self.auto3SocketVector,
		self.auto4SocketVector
	}
			
	self.sliders = {
		self.slider1,
		self.slider2,
		self.slider3,
		self.slider4
	}
	
	self.pan1EncoderVector = Vector(self.x - (moduleWidth/2) + 15, self.y - 22)
	self.pan2EncoderVector = Vector(self.x - (moduleWidth/2) + 15 + sliderXInc, self.y - 22)
	self.pan3EncoderVector = Vector(self.x - (moduleWidth/2) + 15 + (sliderXInc * 2), self.y - 22)
	self.pan4EncoderVector = Vector(self.x - (moduleWidth/2) + 15 + (sliderXInc * 3), self.y - 22)
	
	self.encoderVectors = {
		self.pan1EncoderVector,
		self.pan2EncoderVector,
		self.pan3EncoderVector,
		self.pan4EncoderVector
	}
	
end

function Mix4SliderMod:evaporate(onDetachConnected)
	--first detach cables
	--Audio in...
	if self.component:in1Connected() then
		onDetachConnected(self.in1Cable:getStartModId(), self.in1Cable:getCableId())
		self.component:unplugIn1()
		self.in1Cable:evaporate()
	end
	
	if self.component:in2Connected() then
		onDetachConnected(self.in2Cable:getStartModId(), self.in2Cable:getCableId())
		self.component:unplugIn2()
		self.in2Cable:evaporate()
	end
	
	if self.component:in3Connected() then
		onDetachConnected(self.in3Cable:getStartModId(), self.in3Cable:getCableId())
		self.component:unplugIn3()
		self.in3Cable:evaporate()
	end
	
	if self.component:in4Connected() then
		onDetachConnected(self.in4Cable:getStartModId(), self.in4Cable:getCableId())
		self.component:unplugIn4()
		self.in4Cable:evaporate()
	end
	
	--Automated in
	if self.component:auto1Connected() then
		onDetachConnected(self.autoIn1Cable:getStartModId(), self.autoIn1Cable:getCableId())
		self.component:unplugAuto1()
		self.autoIn1Cable:evaporate()
	end
	
	if self.component:auto2Connected() then
		onDetachConnected(self.autoIn2Cable:getStartModId(), self.autoIn2Cable:getCableId())
		self.component:unplugAuto2()
		self.autoIn2Cable:evaporate()
	end
	
	if self.component:auto3Connected() then
		onDetachConnected(self.autoIn3Cable:getStartModId(), self.autoIn3Cable:getCableId())
		self.component:unplugAuto3()
		self.autoIn3Cable:evaporate()
	end
	
	if self.component:auto4Connected() then
		onDetachConnected(self.autoIn4Cable:getStartModId(), self.autoIn4Cable:getCableId())
		self.component:unplugAuto4()
		self.autoIn4Cable:evaporate()
	end
	
	for i=1,#self.sliders do
		self.sliders[i]:evaporate()
	end
	
	self.sliders = nil
	
	self:remove()
end

function Mix4SliderMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.pan1EncoderValue = self.pan1EncoderValue
	modState.pan2EncoderValue = self.pan2EncoderValue
	modState.pan3EncoderValue = self.pan3EncoderValue
	modState.pan4EncoderValue = self.pan4EncoderValue
	
	modState.slider1Value = self.slider1Value
	modState.slider2Value = self.slider2Value
	modState.slider3Value = self.slider3Value
	modState.slider4Value = self.slider4Value
	
	return modState
end

function Mix4SliderMod:fromState(modState)
	self.pan1EncoderValue = modState.pan1EncoderValue
	self.pan2EncoderValue = modState.pan2EncoderValue
	self.pan3EncoderValue = modState.pan3EncoderValue
	self.pan4EncoderValue = modState.pan4EncoderValue
	
	self.component:setPan(1, modState.pan1EncoderValue)
	self.component:setPan(2, modState.pan2EncoderValue)
	self.component:setPan(3, modState.pan3EncoderValue)
	self.component:setPan(4, modState.pan4EncoderValue)
	
	self.slider1:setValueWithListener(modState.slider1Value)
	self.slider2:setValueWithListener(modState.slider2Value)
	self.slider3:setValueWithListener(modState.slider3Value)
	self.slider4:setValueWithListener(modState.slider4Value)
	
	self:redrawBackground()
end