class('BangSprite').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local diam = 20

-- Deprecated... do not use
function BangSprite:init(xx, yy)
	BangSprite.super.init(self)
	
	self.frameTimer = nil
	
	local bangImage = playdate.graphics.image.new(diam, diam)
	gfx.pushContext(bangImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.fillCircleAtPoint(diam/2, diam/2, diam/2)	
	gfx.popContext()
	
	local fadedImage = playdate.graphics.image.new(diam, diam)
	gfx.pushContext(fadedImage)
		bangImage:drawFaded(0, 0, 0.4, playdate.graphics.image.kDitherTypeBayer2x2)
	gfx.popContext()
	self:setImage(fadedImage)
	self:moveTo(xx, yy)
	self:add()
end

function BangSprite:show()
	if gModularRunning == false then return end
	self:add()
end

function BangSprite:hide()
	if gModularRunning == false then return end
	self:remove()
end