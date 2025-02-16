--[[
	© 2023 Orllewin - All Rights Reserved.
]]--
import 'Modules/mod_utils.lua'
import 'Modules/Sprites/small_socket_sprite'
import 'Modules/Switches/Timed/timed_switch_component'

import 'Coracle/math'

class('TimedSwitchMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 50
local moduleHeight = 50

local modType = "TimedSwitchMod"
local modSubtype = "clock_router"

local offImage = gfx.image.new("Images/switch_open")
local onImage = gfx.image.new("Images/switch_closed")

function TimedSwitchMod:init(xx, yy, modId)
	TimedSwitchMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.component = TimedSwitchComponent(function(emiting)  	
		self:redraw()	
	end)
	
	self:redraw()
	self:moveTo(xx, yy)
	self:add()
		
	self.socketInVector = Vector(xx - 25, yy + 8)
	self.socketOutVector = Vector(xx + 25, yy + 8)
end

function TimedSwitchMod:redraw()
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = backgroundImage:getSize()
	self.bgH = bgH
	gfx.pushContext(backgroundImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	
	gfx.drawTextAligned(">", 22, bgH/2 - 1, kTextAlignment.center)
	gfx.drawTextAligned(">", 56, bgH/2 - 1, kTextAlignment.center)
	
if self.component:isOn() then
		onImage:draw(29, 33)
		gfx.drawTextAligned("On" , bgW/2, 20, kTextAlignment.center)
	else
		offImage:draw(29, 33)
		gfx.drawTextAligned("Off" , bgW/2, 20, kTextAlignment.center)
	end
	
	local bars = self.component:getBars()
	if bars == 1 then
		gfx.drawTextAligned("m." .. bars, bgW/2, 50, kTextAlignment.center)
	else
		gfx.drawTextAligned("mm." .. bars, bgW/2, 50, kTextAlignment.center)
	end
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 32)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(62, 32)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
end

function TimedSwitchMod:findClosestInSocketSprite(x, y)
	print("Recticle x: " .. x .. " y: " .. y)
	local reticleVector = Vector(x, y)
	local closestDistance = 1000
	local closestIndex = -1
	for i=1,#self.insocketSprites do
		local aSocket = self.insocketSprites[i]
		
		local socketVector = Vector(aSocket.x, aSocket.y)
		local distance = reticleVector:distance(socketVector)
		print("Checking distance to socket at x: " .. aSocket.x .. " y: " .. aSocket.y .. " distance is: " .. distance)
		if distance < closestDistance then
			closestDistance = distance
			closestIndex = i
		end
	end
	print("findClosestInSocketSprite using index " .. closestIndex)
	return self.insocketSprites[closestIndex]
end

function TimedSwitchMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function TimedSwitchMod:setOutCable(patchCable)
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function TimedSwitchMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function TimedSwitchMod:tryConnectGhostIn(x, y, ghostCable)
	if self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function TimedSwitchMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function TimedSwitchMod:type() return modType end
function TimedSwitchMod:getModId() return self.modId end

function TimedSwitchMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "Toggle"},
		{label = "1 bar"},
		{label = "4 bars"},
		{label = "8 bars"},
		{label = "16 bars"},
		{label = "32 bars"},
		{label = "64 bars"},
		{label = "128 bars"},
		{label = "256 bars"},
		{label = "512 bars"},
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "Toggle" then
			self.component:toggle()
			self:redraw()
		elseif action == "1 bar" then
			self.component:setBars(1)
			self:redraw()
		elseif action == "4 bars" then
			self.component:setBars(4)
			self:redraw()
		elseif action == "8 bars" then
			self.component:setBars(8)
			self:redraw()
		elseif action == "16 bars" then
			self.component:setBars(16)
			self:redraw()
		elseif action == "32 bars" then
			self.component:setBars(32)
			self:redraw()
		elseif action == "64 bars" then
			self.component:setBars(64)
			self:redraw()
		elseif action == "128 bars" then
			self.component:setBars(128)
			self:redraw()
		elseif action == "256 bars" then
			self.component:setBars(256)
			self:redraw()
		elseif action == "512 bars" then
			self.component:setBars(512)
			self:redraw()
		elseif action == "About" then
			local aboutPopup = ModAboutPopup("A switch, use to toggle different patterns on your canvas.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end

	end)
end


function TimedSwitchMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end
function TimedSwitchMod:unplug(cableId) self.component:unplug(cableId) end

function TimedSwitchMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function TimedSwitchMod:moveFinish()
	self.socketInVector = Vector(self.x - 25, self.y + 8)
	self.socketOutVector = Vector(self.x + 25, self.y + 8)
end

function TimedSwitchMod:evaporate(onDetachConnected)
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
	
	self:remove()
end

function TimedSwitchMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.bars = self.component:getBars()
	
	return modState
end

function TimedSwitchMod:fromState(modState)
	self.component:setBars(modState.bars)
end