--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('PongMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local fmod <const> = math.fmod

local moduleWidth = 160
local moduleHeight = 120

local ballVelocityInc = 0.2
local maxYVelocity = 1.5
local cpuYStepSize = 1.6

local modType = "PongMod"
local modSubtype = "other"

function PongMod:init(xx, yy, modId)
	PongMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.bigFont = assets:bigFont()
	
	self.evaporating = false
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	
	gfx.pushContext(backgroundImage)
	
	for i=1,11 do
		gfx.fillRect(bgW/2, 11 + (i * 10), 3, 5)
	end
		
	gfx.popContext()
	
	self.yy = yy
	self.xx = xx
	self.bgW = bgW
	self.bgH = bgH
	self.backgroundImage = backgroundImage
	
	self.rebounds = 0
	
	self.playerScore = 0
	self.cpuScore = 0

	self:moveTo(xx, yy)
	self:add()
	self:redrawBackground()
	
	self.playerPosition = Vector(xx - moduleWidth/2 + 10, yy)
	self.cpuPosition = Vector(xx + moduleWidth/2 - 10, yy)
	self.ballPosition = Vector(xx - moduleWidth/4, yy + math.floor(math.random(-(moduleHeight/2), (moduleHeight/2))))
	self.ballVelocity = Vector(2, 1)
	
	local playerImage = gfx.image.new(5, 25, gfx.kColorBlack)
	self.playerSprite = gfx.sprite.new(playerImage)
	self.playerSprite:setCollideRect(0, 0, self.playerSprite:getSize())
	self.playerSprite:moveTo(self.playerPosition.x, self.playerPosition.y)
	self.playerSprite:add()
	
	self.cpuSprite = gfx.sprite.new(playerImage)
	self.cpuSprite:setCollideRect(0, 0, self.cpuSprite:getSize())
	self.cpuSprite:moveTo(self.cpuPosition.x, self.cpuPosition.y)
	self.cpuSprite:add()
	
	local ballImage = gfx.image.new(5, 5, gfx.kColorBlack)
	self.ballSprite = gfx.sprite.new(ballImage)
	self.ballSprite:setCollideRect(0, 0, self.ballSprite:getSize())
	self.ballSprite:moveTo(self.ballPosition.x, self.ballPosition.y)
	self.ballSprite:add()
	
	self.arenaTop = self.yy - moduleHeight/2 + 4
	self.arenaBottom = self.yy + moduleHeight/2 - 3
	self.arenaLeft = self.xx - moduleWidth/2
	self.arenaRight = self.xx + moduleWidth/2
	
	self.gameLoop = playdate.timer.new(1000)
	self.gameLoop.repeats = true
	self.gameLoop.updateCallback = function(timer)
		if self.evaporating then return end
		self.ballPosition:plus(self.ballVelocity)
		if self.ballPosition.y >= self.arenaBottom or self.ballPosition.y <= self.arenaTop then
			self.ballVelocity.y *= -1
		end
		
		if self.ballPosition.x > self.xx then
			if self.ballPosition.y > self.cpuPosition.y + 12 then
				self.cpuPosition.y = math.min(self.arenaBottom - 12, self.cpuPosition.y + cpuYStepSize)
				self.cpuSprite:moveTo(self.cpuPosition.x, self.cpuPosition.y)
			elseif self.ballPosition.y < self.cpuPosition.y - 12 then
				self.cpuPosition.y = math.max(self.arenaTop + 12, self.cpuPosition.y - cpuYStepSize)
				self.cpuSprite:moveTo(self.cpuPosition.x, self.cpuPosition.y)
			end
		end
		
		self.ballSprite:moveTo(self.ballPosition.x, self.ballPosition.y)
		
		if #self.cpuSprite:overlappingSprites() > 0 then
			self.rebounds += 1
			self.ballVelocity.x *= -1
			self.ballPosition.x -= 2
			-- CPU rebound Y velocity
			local cpuY = self.cpuPosition.y
			local ballY = self.ballPosition.y
			local paddleDistance = math.abs(cpuY - ballY)
			if self.ballVelocity.y > 0 then
				self.ballVelocity.y =  map(paddleDistance, 0, 12, 0, maxYVelocity)
			else
				self.ballVelocity.y = map(paddleDistance, 0, 12, 0, -maxYVelocity)
			end
			
			print("rebounds: " .. self.rebounds)
			if self.rebounds == 4 or self.rebounds == 12 then
				self.ballVelocity.x -= ballVelocityInc
				print("Inc ball x velocity to: " .. self.ballVelocity.x)
				if self.rebounds == 12 then
					self.rebounds = 1
				end
			end
		elseif #self.playerSprite:overlappingSprites() > 0 then
			self.rebounds += 1
			self.ballVelocity.x *= -1
			self.ballPosition.x += 2
			--Player rebound Y velocity
			local playerY = self.playerPosition.y
			local ballY = self.ballPosition.y
			local paddleDistance = math.abs(playerY - ballY)
			if self.ballVelocity.y > 0 then
				self.ballVelocity.y = map(paddleDistance, 0, 12, 0, maxYVelocity)
			else
				self.ballVelocity.y = map(paddleDistance, 0, 12, 0, -maxYVelocity)
			end
			
			if self.rebounds == 4 or self.rebounds == 12 then
				self.ballVelocity.x += ballVelocityInc
				print("Inc ball x velocity to: " .. self.ballVelocity.x)
				if self.rebounds == 12 then
					self.rebounds = 1
				end
			end
		end
		
		if self.arenaLeft > self.ballPosition.x then
			--cpu scores
			self.cpuScore += 1
			self:redrawBackground()
			self.ballPosition.x = self.xx
			self.ballVelocity.y = 1
			self.ballVelocity.x = -2
			self.rebounds = 1
			self.ballSprite:moveTo(self.ballPosition.x, self.ballPosition.y)
		elseif self.arenaRight < self.ballPosition.x then
			--player scores
			self.playerScore += 1
			print("Player scores: " .. self.playerScore)
			self:redrawBackground()
			self.ballPosition.x = self.xx
			self.ballVelocity.y = 1
			self.ballVelocity.x = 2
			self.rebounds = 1
			self.ballSprite:moveTo(self.ballPosition.x, self.ballPosition.y)
		end
	end
end

function PongMod:turn(x, y, change)
	if change > 0 then
		self.playerPosition.y = math.min(self.arenaBottom - 12, self.playerPosition.y + 2)
	elseif change < 0 then
		self.playerPosition.y = math.max(self.arenaTop + 12, self.playerPosition.y - 2)
	end
	
	self.playerSprite:moveTo(self.playerPosition.x, self.playerPosition.y)
	
end

function PongMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = gfx.image.new(self.bgW, self.bgH)	
	gfx.pushContext(backgroundImage)
	self.backgroundImage:draw(0, 0)
	
	self.bigFont:drawText("" .. self.playerScore, (self.bgW/2) - 25, 20)
	self.bigFont:drawText("" .. self.cpuScore, (self.bgW/2) + 18, 20)
		
	gfx.popContext()
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function PongMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function PongMod:type()
	return self.modType
end

function PongMod:getModId()
	return self.modId
end

function PongMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("A Pong easter egg, only not hidden very well.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function PongMod:handleModClickUp(tX, tY, listener)
	--todo
end

function PongMod:evaporate(onDetachConnected)	
	self.evaporating = true
	self.playerSprite:remove()
	self.cpuSprite:remove()
	self.ballSprite:remove()
	self:remove()
end

function PongMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function PongMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	return modState
end

function PongMod:fromState(modState)
	--noop
end