class('VerticalSlider').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local sliderWidth = 18
local sliderHeight = 50

function VerticalSlider:init(xx, yy, value, listener)
	VerticalSlider.super.init(self)
	
	self.value = value
	self.segments = 6
	self.xx = xx
	self.yy = yy

	self.rangeStart = 0.0
	self.rangeEnd = 1.0
	self.listener = listener
	
	self.backplateImage = gfx.image.new(sliderWidth, sliderHeight)
	gfx.pushContext(self.backplateImage)
	
	gfx.setColor(gfx.kColorBlack)

	for i=1,self.segments do
		local y = map(i, 1, self.segments, 0, sliderHeight)
		gfx.drawLine(0, y, sliderWidth, y) 
	end	
	
	gfx.drawLine(0, sliderHeight - 1, sliderWidth, sliderHeight - 1) 
	gfx.popContext()
	
	--self:setImage(backplateImage)
	self:moveTo(xx, yy)
	--self:add()
	
	local knobImage = gfx.image.new(sliderWidth,7)
	gfx.pushContext(knobImage)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRoundRect(0, 0, sliderWidth, 7, 2)
	gfx.popContext()
	
	self.knobSprite = gfx.sprite.new(knobImage)
	self.knobSprite:moveTo(xx, yy + (sliderHeight/2))
	self.knobSprite:add()
		
end

function VerticalSlider:repositionBy(x, y)
	self:moveBy(x, y)
	self.knobSprite:moveBy(x, y)
	self.xx = self.xx + x
	self.yy = self.yy + y
end

function VerticalSlider:setZIndex(zIndex)
	self.knobSprite:setZIndex(zIndex)
end

function VerticalSlider:getBackplateImage()
	return self.backplateImage
end

function VerticalSlider:show()
	self.knobSprite:add()
end

function VerticalSlider:hide()
	self.knobSprite:remove()
end

function VerticalSlider:evaporate()
	self.knobSprite:remove()
	--self:remove()
end

--deprecated?
function VerticalSlider:activateDebounce()	
end

function VerticalSlider:turn(degrees)
	if(degrees == 0.0)then return end --indicates no change from crank in this frame
	if degrees > 0 and self.value < self.rangeEnd then
		self.value += 0.025
	elseif degrees < 0 and self.value > self.rangeStart then
		self.value -= 0.025
	else
		return
	end

	self.knobSprite:moveTo(self.xx, self.yy + (sliderHeight/2) - map(self.value, self.rangeStart, self.rangeEnd,0, sliderHeight))
		
	if self.listener ~= nil then self.listener(self.value) end
end

function VerticalSlider:setValueWithListener(value)
	self.value = value
	self.knobSprite:moveTo(self.xx, self.yy + (sliderHeight/2) - map(self.value, self.rangeStart, self.rangeEnd,0, sliderHeight))
	
	if self.listener ~= nil then self.listener(self.value) end
end

function VerticalSlider:setValue(value)
	self.value = value
	self.knobSprite:moveTo(self.xx, self.yy + (sliderHeight/2) - map(self.value, self.rangeStart, self.rangeEnd,0, sliderHeight))
end