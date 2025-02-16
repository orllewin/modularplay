--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/Clocks/BouncingBallClock/bouncing_ball_clock_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'

class('BouncingBallClockMod').extends(playdate.graphics.sprite)

local menuActions = {
	{
		label = "Faster"
	},
	{
		label = "Slower"
	},
	{
		label = "Add Ball"
	},
	{
		label = "Remove Ball"
	},
	{
		label = "About"
	},
	{
		label = "Move"
	},
	{
		label = "Remove"
	}
}

local gfx <const> = playdate.graphics

local moduleWidth = 100
local moduleHeight = 100

local modType = "BouncingBallClockMod"
local modSubtype = "clock_router"

function BouncingBallClockMod:init(xx, yy, modId, onInit)
	BouncingBallClockMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.onInit = onInit
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.ballVelocity = 3.0
	
	self.menuIndex = 1
		
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	self.bgW = bgW
	self.bgH = bgH
	
	gfx.pushContext(backgroundImage)
	
	local brownianBackgroundImage = gfx.image.new("Images/brownian_background")
	brownianBackgroundImage:draw(14, 14)
		
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(112, 25)
	
	gfx.popContext()

	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
	
	self.balls = {}
	
	self.moleculeImage = assets:image("brownian_molecule")
	local molecule1Sprite = gfx.sprite.new(self.moleculeImage)
	local molecule1X = math.random(-40, 40)
	local molecule1Y = math.random(-40, 40)
	molecule1Sprite:moveTo(self.x + molecule1X, self.y + molecule1Y)
	molecule1Sprite:add()
	
	table.insert(self.balls, {
		location = Vector(molecule1X, molecule1Y),
		direction = Vector(math.random(), math.random()),
		velocity = self.ballVelocity,
		sprite = molecule1Sprite
	})
		
	self.spriteUpdateTimer = playdate.timer.new(500)
	self.spriteUpdateTimer.repeats = true
	self.spriteUpdateTimer.updateCallback = function()
 		for i=1,#self.balls do
			local molecule = self.balls[i]
			--print("Updating molecule at " .. molecule.location.x .. " x " .. molecule.location.y)
			molecule.location.x = molecule.location.x + (molecule.velocity * molecule.direction.x)
			molecule.location.y = molecule.location.y + (molecule.velocity * molecule.direction.y)
			if molecule.location.x >= 50 - 5 then
				molecule.direction.x = molecule.direction.x * -1
				self.component:emitNote(molecule.location.x, molecule.location.y)
			elseif molecule.location.x <= -50 + 5 then
				molecule.direction.x = molecule.direction.x * -1
				self.component:emitNote(molecule.location.x, molecule.location.y)
			end
			
			if molecule.location.y >= 50 - 5 then
				molecule.direction.y = molecule.direction.y * -1
				self.component:emitNote(molecule.location.x, molecule.location.y)
			elseif molecule.location.y <= -50 + 5 then
				molecule.direction.y = molecule.direction.y * -1
				self.component:emitNote(molecule.location.x, molecule.location.y)
			end
			
			molecule.sprite:moveTo(self.x + molecule.location.x, self.y + molecule.location.y)
	 	end
	end
	
	self.component = BouncingBallClockComponent()
	
	self.socketOutVector = Vector	(self.x + (moduleWidth/2)+2, self.y - 30)
end

function BouncingBallClockMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function BouncingBallClockMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function BouncingBallClockMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function BouncingBallClockMod:addBall()
	local moleculeSprite = gfx.sprite.new(self.moleculeImage)
	local moleculeX = math.random(-30, 30)
	local moleculeY = math.random(-30, 30)
	moleculeSprite:moveTo(self.x + moleculeX, self.y + moleculeY)
	moleculeSprite:add()
	
	table.insert(self.balls, {
		location = Vector(moleculeX, moleculeY),
		direction = Vector(math.random(), math.random()),
		velocity = self.ballVelocity,
		sprite = moleculeSprite
	})
end

function BouncingBallClockMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	
	local contextMenu = ModuleMenu(menuActions)
	contextMenu:show(function(action, index) 
		self.menuIndex = index

		if action == "Add Ball" then
			self:addBall()
		elseif action == "Remove Ball" then
			if #self.balls > 0 then
				self.balls[#self.balls].sprite:remove()
				table.remove(self.balls, #self.balls)
			end
		elseif action == "Faster" then
			--faster
			if self.ballVelocity < 16.0 then
				self.ballVelocity += 0.25
			end
			for i=1,#self.balls do
				self.balls[i].velocity = self.ballVelocity
			end
		elseif action == "Slower" then
			--slower
			if self.ballVelocity > 0.0 then
				self.ballVelocity -= 0.25
			end
			for i=1,#self.balls do
				self.balls[i].velocity = self.ballVelocity
			end	
		elseif action == "About" then
			local aboutPopup = ModAboutPopup("New and experimental (and possibly buggy), add balls that bounce around a box, when they hit a wall a clock event is emitted.")
			aboutPopup:show()
		elseif action == "Move" then
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		elseif action == "Remove" then
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		else
			--NOOP
		end
	end, self.menuIndex)
end

function BouncingBallClockMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function BouncingBallClockMod:moveFinish()
	self.socketOutVector = Vector	(self.x + (moduleWidth/2)+2, self.y - 10)
end

function BouncingBallClockMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
		
	self.spriteUpdateTimer:remove()
	
	for i=1,#self.balls do
		self.balls[i].sprite:remove()
	end
	
	self:remove()
end

function BouncingBallClockMod:type() return modType end
function BouncingBallClockMod:getModId() return self.modId end
function BouncingBallClockMod:unplug(cableId) self.component:unplug(cableId) end
function BouncingBallClockMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function BouncingBallClockMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y	
	
	modState.ballVelocity = self.ballVelocity
	modState.ballCount = #self.balls
	return modState
end

function BouncingBallClockMod:fromState(modState)
	self.ballVelocity = modState.ballVelocity
	
	local ballCount = modState.ballCount
	
	if ballCount > 1 then
		for i = 1, ballCount - 1 do
			self:addBall()
		end
	end
end