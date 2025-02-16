--[[
	© 2023 Orllewin - All Rights Reserved.
]]

class('GameOfLifeMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local fmod <const> = math.fmod
local random <const> = math.random

local neighbourXIndexes = {-1, 0, 1, -1, 1, -1, 0, 1}
local neighbourYIndexes = {-1, -1, -1, 0, 0, 1, 1, 1}	

local moduleWidth = 168
local moduleHeight = 168

local ballVelocityInc = 0.2
local maxYVelocity = 1.5
local cpuYStepSize = 1.6

local modType = "GameOfLifeMod"
local modSubtype = "other"

function GameOfLifeMod:init(xx, yy, modId)
	GameOfLifeMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.evaporating = false
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	
	gfx.pushContext(backgroundImage)		
	gfx.popContext()
	
	self.yy = yy
	self.xx = xx
	self.bgW = bgW
	self.bgH = bgH
	self.backgroundImage = backgroundImage
	
	self:moveTo(xx, yy)
	self:add()

	self.cellArray = {}
	for i=1,400 do
		local isAlive = false
		if random(100) < 10 then
			isAlive = true
		end
		local cell = {
			x = fmod(i,20),
			y = fmod(math.floor(i/20), 20),
			alive = isAlive,
			pendingAlive = false
		}

		table.insert(self.cellArray, cell)
		
	end
	
	self:redrawBackground()
	
	self.frame = 0

	self.gameLoop = playdate.timer.new(1000)
	self.gameLoop.repeats = true
	self.gameLoop.updateCallback = function(timer)
		if self.evaporating then return end
		--GOL
		self.frame += 1
		if fmod(self.frame, 4) == 0 then
			for i=1, #self.cellArray do
				local aliveNeighbours = 0
				local x = self.cellArray[i].x
				local y = self.cellArray[i].y
				
				for n=1,8 do 
					local nX = x + neighbourXIndexes[n]
					local nY = y + neighbourYIndexes[n]
					if( nX < 0 or nX >= 20 or nY < 0 or nY >= 20) then
						--noop
					else
						if(self.cellArray[(nY * 20 + nX) + 1].alive) then aliveNeighbours += 1 end
					end
				end
				
				if aliveNeighbours < 2 then 
					self.cellArray[i].pendingAlive = false 
				elseif aliveNeighbours > 3 then
					self.cellArray[i].pendingAlive = false
				elseif self.cellArray[i].alive and aliveNeighbours == 2 then
					self.cellArray[i].pendingAlive = self.cellArray[i].alive
				elseif self.cellArray[i].alive and aliveNeighbours == 3 then
					self.cellArray[i].pendingAlive = self.cellArray[i].alive
				elseif aliveNeighbours == 3 and self.cellArray[i].alive == false then
					self.cellArray[i].pendingAlive = true
				end
			end
			
			self:redrawBackground()
			
			for i=1, #self.cellArray do
				self.cellArray[i].alive = self.cellArray[i].pendingAlive
			end
		end
	end
end

function GameOfLifeMod:turn(x, y, change)
	--NOOP
end

function GameOfLifeMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = gfx.image.new(self.bgW, self.bgH)	
	gfx.pushContext(backgroundImage)
	self.backgroundImage:draw(0, 0)
	
	for i=1, #self.cellArray do
		local cell = self.cellArray[i]
		if cell.alive then
			playdate.graphics.fillCircleAtPoint(22 + cell.x * 8, 22 + cell.y * 8, 3.5) 
		end
	end
	

	gfx.popContext()
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function GameOfLifeMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function GameOfLifeMod:type()
	return self.modType
end

function GameOfLifeMod:getModId()
	return self.modId
end

function GameOfLifeMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "Restart"},
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "Restart" then
			self.cellArray = {}
			for i=1,400 do
				local isAlive = false
				if random(100) < 20 then
					isAlive = true
				end
				local cell = {
					x = fmod(i,20),
					y = fmod(math.floor(i/20), 20),
					alive = isAlive,
					pendingAlive = false
				}
			
				table.insert(self.cellArray, cell)
				
			end
		elseif action == "About" then
			local aboutPopup = ModAboutPopup("A Game of Life easter egg, possibly with some mistakes.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function GameOfLifeMod:handleModClickUp(tX, tY, listener)
	--todo
end

function GameOfLifeMod:evaporate(onDetachConnected)	
	self.evaporating = true
	self:remove()
end

function GameOfLifeMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function GameOfLifeMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	return modState
end

function GameOfLifeMod:fromState(modState)
	--noop
end