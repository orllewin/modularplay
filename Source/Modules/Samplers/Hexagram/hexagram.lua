--[[
	https://orllewin.github.io/old/coracle/drawings/experiments/hexagrams/
]]--
import 'Coracle/math'

class('Hexagram').extends(playdate.graphics.sprite)

local TWO_PI = 6.2831855

function Hexagram:init(x, y, d, alpha)
	Hexagram.super.init(self)
	
	self.d = d
	self.alpha = alpha
	
	self.hexXCoords = {}
	self.hexYCoords = {}
	local rads = TWO_PI/6.0
	for i=1,6 do
		self.hexXCoords[i] = math.sin(rads * i)
		self.hexYCoords[i] = math.cos(rads * i)
	end
	
	self:setImage(self:generate(1.0))
	self:moveTo(x, y)
	self:add()
	
end

function Hexagram:repositionBy(x, y)
	self:moveBy(x, y)
end

function Hexagram:cast(value)
	local image = self:generate(value)
	self:setImage(image)
end

function Hexagram:evaporate()
	self:remove()
end

function Hexagram:generate(value)
	local image = playdate.graphics.image.new(self.d, self.d, playdate.graphics.kColorWhite)
	local count = math.floor(map(value, 0.0, 1.0, 3.0, 20.0))
	playdate.graphics.pushContext(image)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	if math.random(100) < 5 then
		playdate.graphics.drawCircleAtPoint(self.d/2, self.d/2, self.d/2) 
	end
	for i = 1,count do
		local index1 = math.floor(math.random(6))
		local index2 = math.floor(math.random(6))
		playdate.graphics.drawLine(
			self.d/2 + self.hexXCoords[index1] * self.d/2, 
			self.d/2 + self.hexYCoords[index1]* self.d/2, 
			self.d/2 + self.hexXCoords[index2]* self.d/2, 
			self.d/2 + self.hexYCoords[index2]* self.d/2
		)
	end
	
	playdate.graphics.popContext()
	
	if(self.alpha == nil or self.alpha == 1) then
		return image
	else
		local base = playdate.graphics.image.new(self.d, self.d)
		playdate.graphics.pushContext(base)
		image:drawFaded(0, 0, self.alpha, playdate.graphics.image.kDitherTypeBayer2x2)
		playdate.graphics.popContext()
		return base
	end
end