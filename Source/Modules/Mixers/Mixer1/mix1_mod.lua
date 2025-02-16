--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'Modules/mod_utils.lua'
import 'Modules/sprites/small_socket_sprite'

class('Mix1Mod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 60
local moduleHeight = 70

local modType = "SpeakerMod"
local modSubtype = "audio_effect"

function Mix1Mod:init(xx, yy, modId)
	Mix1Mod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.channel = nil
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = backgroundImage:getSize()
	self.bgW = bgW
	self.bgH = bgH
	gfx.pushContext(backgroundImage)
	gfx.setColor(playdate.graphics.kColorBlack)
	for x = 1,4 do
		for y = 1,3 do
			gfx.fillCircleAtPoint((bgW - moduleWidth)/2 + (x * 12), (bgH - moduleHeight)/2 + y * 11, 4)
		end
	end
	local smallSocket = assets:image("small_socket")
	smallSocket:draw(20, 62)
	gfx.popContext()
	
	self.backgroundImage = backgroundImage
	
	self:moveTo(xx, yy)
	self:add()
	
	self.hasCable = false
	self.inVector = Vector(xx - (moduleWidth/2) + 12, yy + (moduleHeight/2) - 14)
	
	self.volumeEncoderVector = Vector(xx + (bgW/2) - 30, yy + (bgH/2)- 30)
	self.volumeEncoderValue = 0.0
	
	self:redrawBackground()
end

function Mix1Mod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = playdate.graphics.image.new(moduleWidth + 28, moduleHeight + 28)
	gfx.pushContext(backgroundImage)
	self.backgroundImage:draw(0, 0)
	
	gEncoder:setValue(self.volumeEncoderValue)
	local volumeEncoderImage = gEncoder:getImage()
	volumeEncoderImage:draw(48, 58)

	gfx.popContext()
	
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function Mix1Mod:turn(x, y, change)
	gEncoder:setValue(self.volumeEncoderValue)
	gEncoder:show()
	gEncoder:moveTo(self.volumeEncoderVector.x, self.volumeEncoderVector.y)
	gEncoder:turn(change)
	self.volumeEncoderValue = gEncoder:getValue()
	if self.channel ~= nil then 
		self.channel:setVolume(self.volumeEncoderValue) 
	end
	
	self.redrawPending = true
end

function Mix1Mod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function Mix1Mod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function Mix1Mod:setInCable(patchCable)
	patchCable:setEnd(self.inVector.x, self.inVector.y, self.modId)
	self.inCable = patchCable
	self.hasCable = true
end

function Mix1Mod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype)
	print("Mix1Mod: tryConnectGhostIn(), hasCable: " .. tostring(self.hasCable))
	if sourceSubtype == "midi" or sourceSubtype == "clock_router" then
		print("Mix1Mod: tryConnectGhostIn() bad subtype")
		return false
	elseif self.hasCable == false then
		print("Mix1Mod: tryConnectGhostIn() success")
		ghostCable:setEnd(self.inVector.x, self.inVector.y)
		return true
	else
		print("Mix1Mod: tryConnectGhostIn() already has cable")
		return false
	end
end

function Mix1Mod:tryConnectGhostOut(x, y, ghostCable)
	return false
end

function Mix1Mod:type()
	return modType
end

function Mix1Mod:getModId()
	return self.modId
end

function Mix1Mod:setChannel(channel)
	if channel == nil then
		print("Mix1Mod:setChannel() CHANNEL IS NIL")
	else
		print("Mix1Mod:setChannel() CHANNEL EXISTS!")
	end
	self.channel = channel
end

function Mix1Mod:handleModClick(tX, tY, listener)
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
			local aboutPopup = ModAboutPopup("A single source speaker module.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end, self.menuIndex)
end

function Mix1Mod:setVolume(volume)
	if self.channel ~= nil then
		self.channel:setVolume(volume)
		self.volumeEncoderValue = volume
		self:redrawBackground()
	end
end

function Mix1Mod:repositionBy(x, y)
	self:moveBy(x, y)
end

function Mix1Mod:moveFinish()
	self.inVector = Vector(self.x - (moduleWidth/2) + 12, self.y + (moduleHeight/2) - 14)
	self.volumeEncoderVector = Vector(self.x + (self.bgW/2) - 30, self.y + (self.bgH/2)- 30)
end

function Mix1Mod:evaporate(onDetachConnected)
	if self.hasCable then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.inCable:evaporate()
		self.inCable = nil
	end

	self:remove()
end

function Mix1Mod:unplug(cableId)	
	if self.inCable:getCableId() == cableId then
		self.hasCable = false
		self.inCable = nil
		if self.channel ~= nil then
			self.channel:setVolume(0)
		end
	end
end

function Mix1Mod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	modState.volumeEncoderValue = self.volumeEncoderValue
	return modState
end

function Mix1Mod:fromState(modState)
	self.volumeEncoderValue = modState.volumeEncoderValue
	
	if self.channel ~= nil then
		self.channel:setVolume(self.volumeEncoderValue)
	end
	
	self:redrawBackground()
end

function Mix1Mod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end