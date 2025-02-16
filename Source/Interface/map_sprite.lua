class('MapSprite').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

function MapSprite:init(mapImage)
	MapSprite.super.init(self)
	
	self.scrollStep = 4
	
	local scaledW, scaleH = mapImage:getSize()
	self.mapWidth = scaledW
	self.mapHeight = scaleH
	
	self.mapSprite = gfx.sprite.new(mapImage)
	self.mapSprite:moveTo(200, 120)
	self.mapSprite:setIgnoresDrawOffset(true)
	self.mapSprite:setZIndex(gReticleZ + 1)
	self.mapSprite:add()
	
	local diam = 35
	local reticleImage = playdate.graphics.image.new(diam, diam)
	
	gfx.pushContext(reticleImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.setLineWidth(3)
	gfx.drawLine(0, diam/2, diam/2-5, diam/2)
	gfx.drawLine(diam, diam/2, diam/2+5, diam/2)
	gfx.drawLine(diam/2, 0, diam/2, diam/2-5)
	gfx.drawLine(diam/2, diam, diam/2, diam/2+5)
	gfx.setLineWidth(1)
	gfx.popContext()
	
	self.reticleSprite = gfx.sprite.new(reticleImage)
	self.reticleSprite:moveTo(200, 120)
	self.reticleSprite:setIgnoresDrawOffset(true)
	self.reticleSprite:setZIndex(gReticleZ + 2)
	self.reticleSprite:add()
	
	print("Map scaled width " .. scaledW .. " scaled height: " .. scaleH)

	--todo - make frame rect sprite to sit on top of map
	-- then map scrolls `inside` that
	-- 
	-- gfx.pushContext(mapImage)
	-- mapImage:draw(0, 0)
	-- gfx.drawLine(0, 0, scaledW, scaleH)
	-- gfx.drawLine(scaledW, 0, 0, scaleH)
	-- gfx.popContext()
	-- self:setIgnoresDrawOffset(true)
	-- self:setImage(mapImage)
	-- self:moveTo(200, 120)
	-- self:setZIndex(gReticleZ + 1)
	-- 
	
end

function MapSprite:close()
	gScrollLock = false
	gMapShowing = false
	self.mapSprite:remove()
	self.reticleSprite:remove()
	self:remove()
	playdate.inputHandlers.pop()
end

function MapSprite:show()
	self.mapSprite:add()
	gScrollLock = true
	gMapShowing = true
	
	self.inputHandler = {
		
		BButtonDown = function()
			self:close()
		end,
		
		AButtonDown = function()
			
		end
	}
	playdate.inputHandlers.push(self.inputHandler)
end

function MapSprite:mapMovedRight()
	if self.reticleSprite.x < 60 then
		if self.mapSprite.x - (self.mapWidth/2) < 0 then
			self.mapSprite:moveBy(self.scrollStep, 0)
			return true
		else
			return false
		end
	else
		return false
	end
end

function MapSprite:mapMovedLeft()
	if self.reticleSprite.x > 340 then
		if self.mapSprite.x + (self.mapWidth/2) > 400 then
			self.mapSprite:moveBy(-self.scrollStep, 0)
			return true
		else
			return false
		end
	else
		return false
	end
end

function MapSprite:mapMovedUp()
	if self.reticleSprite.y > 200 then
		if self.mapSprite.y + (self.mapHeight/2) > 240 then
			self.mapSprite:moveBy(0, -self.scrollStep)
			return true
		else
			return false
		end
	else
		return false
	end
end

function MapSprite:mapMovedDown()
	if self.reticleSprite.y < 40 then
		if self.mapSprite.y - (self.mapHeight/2) < 0 then
			self.mapSprite:moveBy(0, self.scrollStep)
			return true
		else
			return false
		end
	else
		return false
	end
end

function MapSprite:draw()
	if playdate.buttonIsPressed(playdate.kButtonLeft) then
		if self:mapMovedRight() == false then
			self.reticleSprite:moveBy(-self.scrollStep, 0)
		end
	end
	
	if playdate.buttonIsPressed(playdate.kButtonRight) then
		if self:mapMovedLeft() == false then
			self.reticleSprite:moveBy(self.scrollStep, 0)
		end
	end
	
	if playdate.buttonIsPressed(playdate.kButtonUp) then
		if self:mapMovedDown() == false then
			self.reticleSprite:moveBy(0, -self.scrollStep)
		end
	end
	
	if playdate.buttonIsPressed(playdate.kButtonDown) then
		if self:mapMovedUp() == false then
			self.reticleSprite:moveBy(0, self.scrollStep)
		end
	end
	
end