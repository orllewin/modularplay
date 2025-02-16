class('Intro').extends()

local t = 0.0
local cameraZ = 27.0
local cX = 200
local cY = 120
local q = 0
local sQ = 0
local b = 0
local p = 0
local z = 0
local s = 0

local gfx <const> = playdate.graphics
local max <const> = math.max
local sin <const> = math.sin
local cos <const> = math.cos

function Intro:init()
	Intro.super.init(self)
	
	playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)
	
	self.bigFont = assets:bigFont()	
end

function Intro:update()
	local xLocation = (-1 * globalXDrawOffset) + 400
	local yLocation = (-1 * globalYDrawOffset) + 240
	
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(xLocation-400, yLocation-240, 400, 240)
	cameraZ -= 0.3

	t += 0.08
	
	gfx.setColor(gfx.kColorBlack)
	self.bigFont:drawTextAligned("ORLLEWIN", xLocation - 200, yLocation - 130, kTextAlignment.center)
	for i = 40, 0, -1  do
	
		q = (i * i)
		sQ = sin(q)
		
		b = i % 6 + t + i
	
		p = i + t
		z = cameraZ + cos(b) * 3 + cos(p) * sQ
		s = max(0.2, (100 / (z * 4)))
		
		gfx.fillCircleAtPoint(xLocation - (cX * (z + sin(b) * 5 + sin(p) * sQ) / z), yLocation - (cY + cX * (cos(q)- cos(b+t))/z), s)
	end
end