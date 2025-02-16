class('ReticleSprite').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local diam = 35

function ReticleSprite:init(xx, yy)
	ReticleSprite.super.init(self)
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
	
	self:setIgnoresDrawOffset(true)
	
	local fadedImage = playdate.graphics.image.new(diam, diam)
	gfx.pushContext(fadedImage)
	
	reticleImage:drawFaded(0, 0, 0.5, gfx.image.kDitherTypeFloydSteinberg)
	gfx.popContext()
	
	self:setImage(fadedImage)
	self:moveTo(200, 120)
	self:setZIndex(gReticleZ)
	self:add()
end