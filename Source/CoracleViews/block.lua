class('Block').extends(playdate.graphics.sprite)

function Block:init(x, y, width, height, alpha)
	Block.super.init(self)
	self.alpha = alpha
	self.h = height
	self.w = width
	self:setWidth(width)
	self:moveTo(x, y)
	self:add()
end

function Block:getWidth()
	return self.w
end

function Block:setWidth(width)
	self.w = width
	local blockImage = playdate.graphics.image.new(width, self.h)
	playdate.graphics.pushContext(blockImage)
	local rectImage = playdate.graphics.image.new(width, self.h)
	playdate.graphics.pushContext(rectImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.fillRect(0, 0, width, self.h) 
	playdate.graphics.popContext()
	
	if self.alpha == nil then
		rectImage:draw(0, 0)
	else
		rectImage:drawFaded(0, 0, self.alpha, playdate.graphics.image.kDitherTypeDiagonalLine)
	end
			
	playdate.graphics.popContext()
	self:setImage(blockImage)
end