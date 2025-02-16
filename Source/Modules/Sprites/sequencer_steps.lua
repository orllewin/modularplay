class('SequencerSteps').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local prevPatternActiveImage = gfx.image.new("Images/dm_pattern_prev")
local nextPatternActiveImage = gfx.image.new("Images/dm_pattern_next")
local prevPatternInactiveImage = gfx.image.new("Images/dm_pattern_prev_inactive")
local nextPatternInactiveImage = gfx.image.new("Images/dm_pattern_next_inactive")
local stepOffImage = gfx.image.new("Images/dm_step_off")
local stepOnImage = gfx.image.new("Images/dm_step_on")
local stepOnImage90 = gfx.image.new("Images/dm_step_on_2")
local stepOnImage80 = gfx.image.new("Images/dm_step_on_3")
local stepOnImage70 = gfx.image.new("Images/dm_step_on_4")

function SequencerSteps:init(xx, yy, onPatternChange)
	SequencerSteps.super.init(self)
	
	self.onPatternChange = onPatternChange
	
	self.w = 270
	self.h = 24
	
	local backgroundImage = gfx.image.new(self.w, self.h)
	gfx.pushContext(backgroundImage)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, 0, self.w, self.h)
	
	self.pattern = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	self.xCoords = {}
	
	self.pages = 1
	self.page = 1

	for i=1,18 do
		local sX = (i-1) * 15
		if i == 1 then
			prevPatternInactiveImage:draw(sX, 0)
		elseif i == 18 then
			nextPatternInactiveImage:draw(sX, 0)
		else
			stepOffImage:draw(sX, 0)
			table.insert(self.xCoords, sX + (xx - 120))
		end
	end
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
end

function SequencerSteps:repositionBy(x, y)
	self:moveBy(x, y)
end

function SequencerSteps:moveFinish()	
	self.xCoords = {}
	for i=1,18 do
		local sX = (i-1) * 15
		if i == 1 then
			--NOOP
		elseif i == 18 then
			--NOOP
		else
			table.insert(self.xCoords, sX + (self.x - 120))
		end
	end
end

function SequencerSteps:redraw()
	local backgroundImage = gfx.image.new(self.w, self.h)
	gfx.pushContext(backgroundImage)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, 0, self.w, self.h)
	
	for i=1,18 do
		local sX = (i-1) * 15
		if i == 1 then
			if self.page > 1 then
				prevPatternActiveImage:draw(sX, 0)
			else
				prevPatternInactiveImage:draw(sX, 0)
			end
		elseif i == 18 then
			if self.pages > 1 and  self.page < self.pages then
				nextPatternActiveImage:draw(sX, 0)
			else
				nextPatternInactiveImage:draw(sX, 0)
			end
		else
			local stepIndex = ((self.page - 1) * 16) + (i-1)
			local stepVal = self.pattern[stepIndex]
			if stepVal == 0 then
				stepOffImage:draw((i-1) * 15, 0)
			elseif stepVal == 1 then
				stepOnImage:draw((i-1) * 15, 0)
			elseif stepVal == 2 then
				stepOnImage90:draw((i-1) * 15, 0)
			elseif stepVal == 3 then
				stepOnImage80:draw((i-1) * 15, 0)
			elseif stepVal == 4 then
				stepOnImage70:draw((i-1) * 15, 0)
			end
		end
	end
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
end

function SequencerSteps:setPattern(pattern, activeLength)
	self.pattern = pattern
	self.page = 1
	self.pages = math.floor((activeLength/16))
	self:redraw()
end

function SequencerSteps:onClick(x, y)
	local clickStep = -1
	if x < self.xCoords[1] - 15 then
		if self.page > 1 then 
			self.page -= 1 
			self:redraw()
			return
		end
	elseif x > self.xCoords[#self.xCoords] then
		if self.page < self.pages then 
			self.page += 1 
			self:redraw()
			return
		end
	else
		for i=1,#self.xCoords do
			local xC = self.xCoords[i]
			if x > xC - 15 and x < xC then
				clickStep = i
				break
			end
		end
	end
	
	if clickStep == -1 then return end
	
	local stepIndex = clickStep + ((self.page - 1) * 16)
	local stepState = self.pattern[stepIndex]
	stepState += 1
	if stepState == 5 then stepState = 0 end
	self.pattern[stepIndex] = stepState	
	self:redraw()
	
	if self.onPatternChange~= nil then self.onPatternChange(self.pattern) end
end

function SequencerSteps:collision(x, y)
	if x > self.x - (self.w/2) and x < self.x + (self.w/2) and y > self.y - (self.h/2) and y < self.y + (self.h/2) then
		return true
	else
		return false
	end
end