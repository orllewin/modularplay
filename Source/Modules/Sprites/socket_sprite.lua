class('SocketSprite').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local socket_width = 20
local socket_height = 32

socket_in = 1
socket_out = 2

-- Deprecated - draw direct to module background and use self.socketInVector = Vector(x, y) instead for cable placement
function SocketSprite:init(xx, yy, type)
	SocketSprite.super.init(self)
	
	local socketImage = gfx.image.new(socket_width, socket_height)
	gfx.pushContext(socketImage)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillCircleAtPoint(socket_width/2, socket_height - (socket_width/2), socket_width/2)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawCircleAtPoint(socket_width/2, socket_height - (socket_width/2), socket_width/2)	
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.fillCircleAtPoint(socket_width/2, socket_height - (socket_width/2), socket_width/4)	
	
	if type ~= nil then
		if type == socket_in then
			local arrow = playdate.graphics.image.new("Images/arrow_in")
			arrow:drawCentered(socket_width/2, 5)
		elseif type == socket_out then
			local arrow = playdate.graphics.image.new("Images/arrow_out")
			arrow:drawCentered(socket_width/2, 5)
		end
	end
	
	gfx.popContext()
	
	self:setImage(socketImage)
	self:moveTo(xx, yy)
	self:add()
end

function SocketSprite:getSocketY()
	return self.y + (socket_height/2) - (socket_width/2)
end