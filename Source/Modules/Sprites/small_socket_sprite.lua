class('SmallSocketSprite').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local socket_width = 16

-- Deprecated - draw direct to module background and use self.socketInVector = Vector(x, y) instead for cable placement
function SmallSocketSprite:init(xx, yy)
	SmallSocketSprite.super.init(self)
	
	local socketImage = playdate.graphics.image.new(socket_width, socket_width)
	gfx.pushContext(socketImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.drawCircleAtPoint(socket_width/2, socket_width - (socket_width/2), socket_width/2)	
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.fillCircleAtPoint(socket_width/2, socket_width - (socket_width/2), socket_width/4)	
	
	gfx.popContext()
	
	self:setImage(socketImage)
	self:moveTo(xx, yy)
	self:add()
end

function SmallSocketSprite:getSocketY()
	return self.y
end