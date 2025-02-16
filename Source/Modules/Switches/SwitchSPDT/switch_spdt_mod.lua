--[[
	© 2023 Orllewin - All Rights Reserved.

	Off, swallows an event, on lets it through.
	Live use - toggle menu
]]--
import 'Modules/mod_utils.lua'
import 'Modules/Sprites/small_socket_sprite'
import 'Modules/Switches/SwitchSPDT/switch_spdt_component'

class('SwitchSPDTMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 50
local moduleHeight = 50

local modType = "SwitchSPDTMod"
local modSubtype = "clock_router"

local aOnImage = gfx.image.new("Images/spdt_a")
local bOnImage = gfx.image.new("Images/spdt_b")

function SwitchSPDTMod:init(xx, yy, modId)
	SwitchSPDTMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.component = SwitchSPDTComponent(function(event)  	
		self:redraw()
	end)
	
	self:redraw()
	self:moveTo(xx, yy)
	self:add()
	
	self.socketInVector = Vector(xx - 25, yy + 8)
	self.automationInVector = Vector(xx, yy + 28)
	
	self.socketOutAVector = Vector(xx + 25, yy - 16)
	self.socketOutBVector = Vector(xx + 25, yy + 16)
	
	
	self.inVectors = {
		self.socketInVector,
		self.automationInVector
	}
end

function SwitchSPDTMod:redraw()
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = backgroundImage:getSize()
	self.bgH = bgH
	gfx.pushContext(backgroundImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	
	gfx.drawTextAligned(">", 22, bgH/2 - 4, kTextAlignment.center)	
	gfx.drawTextAligned(">", 56, 24, kTextAlignment.center)
	gfx.drawTextAligned(">", 56, 48, kTextAlignment.center)
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 32)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(62, 21)
	rightSocket:draw(62, 42)
	
	local bottomSocket = assets:image("side_socket_bottom")
	bottomSocket:draw(30, 63)
	
	if self.component:isOn() then
		aOnImage:draw(28, 25)
	else
		bOnImage:draw(28, 25)
	end		
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
end

function SwitchSPDTMod:findClosestInVector(x, y)
	local reticleVector = Vector(x, y)
	local closestDistance = 1000
	local closestIndex = -1
	for i=1,#self.inVectors do
		local aVector = self.inVectors[i]
		print("Recticle: " .. x .. "x" .. y .. " socket: " .. aVector.x .. "x" .. aVector.y)
		local distance = reticleVector:distance(aVector)
		print("Distance for index " .. i .. ": " .. distance)
		if distance < closestDistance then
			closestDistance = distance
			closestIndex = i
		end
	end
	print("closest in vec tor index: " .. closestIndex)
	return self.inVectors[closestIndex]
end

function SwitchSPDTMod:setInCable(patchCable)
	local cableX, cableY = patchCable:getEndXY()
	if self.component:inConnected() and self.component:inToggleConnected() then
		--noop
	elseif self.component:inConnected() then
		patchCable:setEnd(self.automationInVector.x, self.automationInVector.y, self.modId)
		self.inToggleCable = patchCable
		self.component:setToggleInCable(patchCable:getCable())
	elseif self.component:inToggleConnected() then
		patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
		self.inCable = patchCable
		self.component:setInCable(patchCable:getCable())
	else
		local inVector = self:findClosestInVector(cableX, cableY)
		if inVector.x == self.socketInVector.x then
			patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
			self.inCable = patchCable
			self.component:setInCable(patchCable:getCable())
		elseif inVector.x == self.automationInVector.x then
			patchCable:setEnd(self.automationInVector.x, self.automationInVector.y, self.modId)
			self.inToggleCable = patchCable
			self.component:setToggleInCable(patchCable:getCable())
		end
	end
end

function SwitchSPDTMod:setOutCable(patchCable)
	if self.component:outAConnected() == false then
		patchCable:setEnd(self.socketOutAVector.x, self.socketOutAVector.y, self.modId)
		self.outACable = patchCable
		self.component:setOutACable(patchCable:getCable())
		return true
	elseif self.component:outBConnected() == false then
		patchCable:setEnd(self.socketOutBVector.x, self.socketOutBVector.y, self.modId)
		self.outBCable = patchCable
		self.component:setOutBCable(patchCable:getCable())
		return true
	else
		return false
	end
end

function SwitchSPDTMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function SwitchSPDTMod:tryConnectGhostIn(x, y, ghostCable)
	if self.component:inConnected() and self.component:inToggleConnected() then
		return false
	elseif self.component:inConnected() then
		ghostCable:setEnd(self.automationInVector.x, self.automationInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	elseif self.component:inToggleConnected() then
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	else
		local inVector = self:findClosestInVector(ghostCable:getEndX(), ghostCable:getEndY())
		ghostCable:setEnd(inVector.x, inVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function SwitchSPDTMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outAConnected() == false then
		ghostCable:setStart(self.socketOutAVector.x, self.socketOutAVector.y)
		ghostCable:setGhostSendConnected()
		return true
	elseif self.component:outBConnected() == false then
		ghostCable:setStart(self.socketOutBVector.x, self.socketOutBVector.y)
		ghostCable:setGhostSendConnected()
		return true
	else
		return false
	end
end

function SwitchSPDTMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "Toggle"},
		{label = "Remove"},
		{label = "About"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "Toggle" then
			self.component:toggle()
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


function SwitchSPDTMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function SwitchSPDTMod:type() return modType end
function SwitchSPDTMod:getModId() return self.modId end
function SwitchSPDTMod:unplug(cableId) self.component:unplug(cableId) end

function SwitchSPDTMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function SwitchSPDTMod:moveFinish()
	self.socketInVector = Vector(self.x - 25, self.y + 8)
	self.automationInVector = Vector(self.x, self.y + 28)
	
	self.socketOutAVector = Vector(self.x + 25, self.y - 16)
	self.socketOutBVector = Vector(self.x + 25, self.y + 16)
	
	
	self.inVectors = {
		self.socketInVector,
		self.automationInVector
	}
end

function SwitchSPDTMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.component:unplugIn()
		self.inCable:evaporate()
	end
	
	if self.component:outAConnected() then
		onDetachConnected(self.outACable:getEndModId(), self.outACable:getCableId())
		self.component:unplugOutA()
		self.outACable:evaporate()
	end
	
	if self.component:outBConnected() then
		onDetachConnected(self.outBCable:getEndModId(), self.outBCable:getCableId())
		self.component:unplugOutB()
		self.outBCable:evaporate()
	end
	
	self:remove()
end

function SwitchSPDTMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.isOn = self.component:isOn()
	return modState
end

function SwitchSPDTMod:fromState(modState)
	if modState.isOn == true then
		self.component:switchOn()
	else
		self.component:switchOff()
	end
end