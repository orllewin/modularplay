--[[
	LabelLeft draws a label in the current default font (set via playdate.graphics.setFont(font))
	with left edge at x, and top edge at y, LabelLeft("Hello", 0, 0) will draw in the top left corner of the screen.
	The alpha argument is optional with a default of 1 but can also be changed later.
	_____________________
	|Hello              |
	|                   |
	|                   |
	|___________________|
]]--

class('LabelLeft').extends(playdate.graphics.sprite)

function LabelLeft:init(text, x, y, alpha)
	LabelLeft.super.init(self)
	
	self.xx = x
	self.yy = y
	
	if alpha == nil then
		self.alpha = 1
	else
		self.alpha = alpha
	end
		
	self:setText(text)
	self:add()
end

function LabelLeft:setAlpha(alpha)
	self.alpha = alpha
	self:forceRedraw()
end

function LabelLeft:forceRedraw()
	local text = self.text
	self.text = ""
	self:setText(text)
end

function LabelLeft:setText(text)
	if text == self.text then return end -- only redraw if text has changed
	self.text = text
	if text == "" then self.text = " " end
	local nWidth, nHeight = playdate.graphics.getTextSize(self.text)
	local image = playdate.graphics.image.new(nWidth, nHeight)
	playdate.graphics.pushContext(image)
	playdate.graphics.drawText(self.text, 0, 0)
	playdate.graphics.popContext()
	
	if(self.alpha == 1) then
		self:setImage(image)
	else
		local base = playdate.graphics.image.new(nWidth, nHeight)
		playdate.graphics.pushContext(base)
		image:drawFaded(0, 0, self.alpha, playdate.graphics.image.kDitherTypeBayer2x2)
		playdate.graphics.popContext()
		self:setImage(base)
	end
	
	self:moveTo(self.xx + (nWidth/2), self.yy + (nHeight/2))
end
