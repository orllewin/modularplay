--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/Samplers/Sampler/sampler_component'

class('SamplerMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local micGrillImage = gfx.image.new("Images/mic_grill")

local moduleWidth = 85
local moduleHeight = 120

local modType = "SamplerMod"
local modSubtype = "other"

function SamplerMod:init(xx, yy, modId)
	SamplerMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
		
	self:moveTo(xx, yy)
	self:add()
	
	self.recording = false
	
	self.remaining = gMaxSampleSeconds
	
	self.component = SamplerComponent(function(event) 
		if event.recording ~= nil then
			self.recording = event.recording
			self:redrawBackground()
		end
		
		if event.remaining ~= nil then
			local remaining = math.floor(event.remaining/1000)
			if remaining ~= self.remaining then
				self.remaining = remaining
				self:redrawBackground()
			end
		end
	end)

	self.socketInVector = Vector(xx - (moduleWidth/2)-2, yy - (moduleHeight/2) + gPedalAudioIOY)
		
	self:redrawBackground()
end

function SamplerMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	
	gfx.pushContext(backgroundImage)
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(gPedalLeftJackX, gPedalAudioIOY)
	
	if self.recording then
		gfx.drawTextAligned("Recording", bgW/2, 120, kTextAlignment.center)
	else
		gfx.drawTextAligned("Stopped", bgW/2, 120, kTextAlignment.center)
	end
	
	for x = 1,9 do
		for y = 1,5 do
			gfx.fillCircleAtPoint(17 + (x * 8), 37 + (y * 8), 2) 
		end
	end
	
	gfx.drawRoundRect(20, 85, 75, 30, 3) 
	
	local elapsed = 30 - self.remaining
	if elapsed < 10 then
		gfx.drawTextAligned("0" ..elapsed, 24, 90, kTextAlignment.left)
	else
		gfx.drawTextAligned("" .. elapsed, 24, 90, kTextAlignment.left)
	end
	
	if self.remaining < 10 then
		gfx.drawTextAligned("0" .. self.remaining .. "/30", bgW - 22, 102, kTextAlignment.right)
	else
		gfx.drawTextAligned("" .. self.remaining .. "/30", bgW - 22, 102, kTextAlignment.right)
	end
	
	gfx.setColor(gfx.kColorXOR)
	gfx.fillRect(22, 100, map(30 - self.remaining, 0, 30, 71, 0), 12)
	gfx.fillRect(22, 88, map(elapsed, 0, 30, 0, 71), 12)
	
	
	
	gfx.drawText("OR SMP-1", 23, 27)
	
	--micGrillImage:draw(75, 110)
		
	gfx.popContext()
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function SamplerMod:setInCable(patchCable)
	self.inCable = patchCable
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.component:setInCable(patchCable:getCable())
end

function SamplerMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function SamplerMod:tryConnectGhostOut(x, y, ghostCable)
	return false
end

function SamplerMod:tryConnectGhostIn(x, y, ghostCable)
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function SamplerMod:type()
	return self.modType
end

function SamplerMod:getModId()
	return self.modId
end

function SamplerMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = nil
	
	if self.component:isRecording() then
		actions = {
			{label = "Stop"},
			{label = "Play"},
			{label = "Save"},
			{label = "About"},
			{label = "Move"},
			{label = "Remove"}
		}
	else
		actions = {
			{label = "Record"},
			{label = "Play"},
			{label = "Save"},
			{label = "About"},
			{label = "Move"},
			{label = "Remove"}
		}
	end
	 
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "Stop" then
			self.component:stopRecording()
		elseif action == "Record" then
			self.component:startRecording()
		elseif action == "Play" then
			self.component:playBuffer()
		elseif action == "Save" then
			playdate.timer.performAfterDelay(gInputPopupTimeout, function() 
				local textInputScreen = TextInputScreen()
				gModularRunning = false
				textInputScreen:push("Enter sample filename:", function(name)
					gModularRunning = true
					textInputScreen = nil
					self.component:save(name)
				end)
			end)
		elseif action == "About" then
			local aboutPopup = ModAboutPopup("Samples audio for use in other modules. You need to manually stop any other audio sources when using this module.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function SamplerMod:unplug(cableId)
	self.component:unplug(cableId)
end

function SamplerMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function SamplerMod:moveFinish()
	self.socketInVector = Vector(self.x - (moduleWidth/2)-2, self.y - (moduleHeight/2) + gPedalAudioIOY)
end

function SamplerMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.component:unplugIn()
		self.inCable:evaporate()
	end
	
	self:remove()
end

function SamplerMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function SamplerMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	return modState
end

function SamplerMod:fromState(modState)
	--noop
end