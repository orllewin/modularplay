class('DividerHorizontal').extends(playdate.graphics.sprite)

function DividerHorizontal:init(x, y, width, alpha)
	DividerHorizontal.super.init(self)
	local dividerImage = playdate.graphics.image.new(width, 3)
	playdate.graphics.pushContext(dividerImage)
	local lineImage = playdate.graphics.image.new(width, 3)
	playdate.graphics.pushContext(lineImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.setLineWidth(1)
	playdate.graphics.drawLine(0, 1, width, 1) 
	playdate.graphics.popContext()
	
	if alpha == nil then
		lineImage:draw(0, 0)
	elseif alpha > 0 and alpha < 0.2 then
		lineImage:clear(playdate.graphics.kColorClear)
		
		playdate.graphics.pushContext(lineImage)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		
		for g=1,width,16 do
			playdate.graphics.drawPixel(g, 1) 
		end
		
		playdate.graphics.popContext()
		lineImage:draw(0, 0)
	else
		lineImage:drawFaded(0, 0, alpha, playdate.graphics.image.kDitherTypeBayer4x4)
	end
			
	playdate.graphics.popContext()
	self:setImage(dividerImage)
	self:moveTo(x + (width/2), y)
	self:add()
end