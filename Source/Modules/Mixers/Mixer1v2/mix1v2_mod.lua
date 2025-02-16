--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'Modules/mod_utils.lua'
import 'Modules/sprites/small_socket_sprite'

class('Mix1v2Mod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 50
local moduleHeight = 50

local modType = "Mix1v2Mod"
local modSubtype = "audio_effect"

function Mix1v2Mod:init(xx, yy, modId)
	Mix1v2Mod.super.init(self)
	
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
	gfx.pushContext(backgroundImage)
	
	local bottomSocket = assets:image("side_socket_bottom")
	bottomSocket:draw(30, 63)
	
	gfx.setColor(playdate.graphics.kColorBlack)
	for x = 1,3 do
		for y = 1,3 do
			gfx.fillCircleAtPoint((bgW - moduleWidth)/2 + 1 + (x * 12), (bgH - moduleHeight)/2 + 2 + (y * 11), 4) 
		end
	end
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.hasCable = false
	self.inVector = Vector(xx, yy + 28)
	
	--self.channel:setVolume(value)
end

function Mix1v2Mod:volumeUp()
	if self.channel ~= nil then 
		self.channel:setVolume(math.min(1.0, self.channel:getVolume() + 0.05))
	end
end

function Mix1v2Mod:volumeDown()
	if self.channel ~= nil then 
		self.channel:setVolume(math.max(0.0, self.channel:getVolume() - 0.05))
	end
end

function Mix1v2Mod:turn(x, y, change)
	print("Mix1v2Mod: turn change: " .. change)
	-- todo: self.channel:setVolume(value)
end

function Mix1v2Mod:setInCable(patchCable)
	patchCable:setEnd(self.inVector.x, self.inVector.y, self.modId)
	self.inCable = patchCable
	self.hasCable = true
end

function Mix1v2Mod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function Mix1v2Mod:tryConnectGhostIn(x, y, ghostCable)
	if self.hasCable == false then
		ghostCable:setEnd(self.inVector.x, self.inVector.y)
		return true
	else
		return false
	end
end

function Mix1v2Mod:tryConnectGhostOut(x, y, ghostCable)
	return false
end

function Mix1v2Mod:type()
	return modType
end

function Mix1v2Mod:getModId()
	return self.modId
end

function Mix1v2Mod:setChannel(channel)
	if channel == nil then
		print("Mix1v2Mod:setChannel() CHANNEL IS NIL")
	else
		print("Mix1v2Mod:setChannel() CHANNEL EXISTS!")
	end
	self.channel = channel
	self.channel:setVolume(0.8)
end

function Mix1v2Mod:repositionBy(x, y)
	self:moveBy(x, y)
end

function Mix1v2Mod:moveFinish()
	self.inVector = Vector(self.x, self.y + 28)
end

function Mix1v2Mod:evaporate(onDetachConnected)
	if self.hasCable then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.inCable:evaporate()
		self.inCable = nil
	end

	self:remove()
end

function Mix1v2Mod:unplug(cableId)
	if self.inCable ~= nil and self.inCable:getCableId() == cableId then
		if self.channel ~= nil then
			self.channel:setVolume(0)
		end
		self.hasCable = false
	end
end

function Mix1v2Mod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	
	local actions = nil
	if self.channel ~= nil then
		local volume = math.floor(round(self.channel:getVolume() * 100, 2))
		actions = {
			{label = "Volume: " .. volume},
			{label = "Volume Up"},
			{label = "Volume Down"},
			{label = "Volume 100"},
			{label = "Volume 90"},
			{label = "Volume 80"},
			{label = "Volume 70"},
			{label = "Volume 60"},
			{label = "Volume 50"},
			{label = "Volume 40"},
			{label = "Volume 30"},
			{label = "Volume 20"},
			{label = "Volume 10"},
			{label = "Volume 0"},
			{label = "About"},
			{label = "Move"},
			{label = "Remove"}
		}
	else
		actions = {
			{label = "About"},
			{label = "Move"},
			{label = "Remove"}
		}
	end

	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action, index) 
		self.menuIndex = index
		if action == "About" then
			local aboutPopup = ModAboutPopup("A single source speaker module.")
			aboutPopup:show()
		elseif action == "Volume Up" then
			self:volumeUp()
		elseif action == "Volume Down" then
			self:volumeDown()
		elseif action == "Volume 100" then
			self.channel:setVolume(1.0)
		elseif action == "Volume 90" then
			self.channel:setVolume(0.9)
		elseif action == "Volume 80" then
			self.channel:setVolume(0.8)
		elseif action == "Volume 70" then
			self.channel:setVolume(0.7)
		elseif action == "Volume 60" then
			self.channel:setVolume(0.6)
		elseif action == "Volume 50" then
			self.channel:setVolume(0.5)
		elseif action == "Volume 40" then
			self.channel:setVolume(0.4)
		elseif action == "Volume 30" then
			self.channel:setVolume(0.3)
		elseif action == "Volume 20" then
			self.channel:setVolume(0.2)
		elseif action == "Volume 10" then
			self.channel:setVolume(0.1)
		elseif action == "Volume 0" then
			self.channel:setVolume(0.0)
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end, self.menuIndex)
end

function Mix1v2Mod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	if self.channel ~= nil then
		modState.volumeValue = self.channel:getVolume()
	else
		modState.volumeValue = 0.0
	end
	
	return modState
end

function Mix1v2Mod:fromState(modState)
	self.volumeValue = modState.volumeValue

	if self.channel ~= nil then
		self.channel:setVolume(self.volumeValue)
	end
	
	self:redrawBackground()
end

function Mix1v2Mod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end