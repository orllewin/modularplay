--[[
	
]]--

import 'Coracle/math'
import 'CoracleViews/label_left'

class('RotaryEncoder').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local mod <const> = math.fmod
local diam = 	20

local frames = 21

local automatedImage = gfx.image.new("Images/encoder_automated")
local encoderTable = gfx.imagetable.new("Images/encoder")

function RotaryEncoder:init(xx, yy, listener)
	RotaryEncoder.super.init(self)
	
	self.listener = listener
	
	self.yy = yy
	
	self.frameCounter = 1
	
	self:setImage(encoderTable:getImage(1))
	self:moveTo(xx, yy)
	self:add()
	
	self.degrees = 0
	
	self.viewId = "unknown"
end

function RotaryEncoder:setListener(listener)
	self.listener = listener
end

function RotaryEncoder:removeListener()
	self.listener = nil
end
	
function RotaryEncoder:show()
	self:add()
end

function RotaryEncoder:hide()
	self:remove()
end

function RotaryEncoder:setViewId(viewId)
	self.viewId = viewId
end
	
function RotaryEncoder:getViewId()
	return self.viewId
end

function RotaryEncoder:evaporate()
	self:remove()
end

--0deg to 300deg
function RotaryEncoder:turn(degrees)
	if(degrees == 0.0)then return end --indicates no change from crank in this frame
	self.degrees = math.max(0, (math.min(300, self.degrees + degrees)))
	self:setImage(encoderTable:getImage(math.floor(map(self.degrees, 0, 300, 1, frames))))
	if self.listener ~= nil then self.listener(round(self:getValue(), 2)) end
end

function RotaryEncoder:turnNoCallback(degrees)
	if(degrees == 0.0)then return end --indicates no change from crank in this frame
	self.degrees = math.max(0, (math.min(300, self.degrees + degrees)))
	self:setImage(encoderTable:getImage(math.floor(map(self.degrees, 0, 300, 1, frames))))
	
end

-- 0.0 to 1.0
function RotaryEncoder:getValue()
	return map(self.degrees, 0, 300, 0.0, 1.0)
end

-- 0.0 to 1.0
function RotaryEncoder:setValue(value)
	if value == nil then return end
	local normalised = value
	if value > 1.0 then
		normalised = 1.0
	elseif value < 0.0 then
		normalised = 0.0
	end
	
	self.degrees = map(value, 0.0, 1.0, 0, 300)
	self:setImage(encoderTable:getImage(math.floor(map(self.degrees, 0, 300, 1, frames))))

	if(self.listener ~= nil)then self.listener(round(normalised, 2)) end
end

-- 0.0 to 1.0
function RotaryEncoder:setValueNoCallback(value)
	local normalised = value
	if value > 1.0 then
		normalised = 1.0
	elseif value < 0.0 then
		normalised = 0.0
	end
	self.degrees = map(normalised, 0.0, 1.0, 0, 300)
	self:setImage(encoderTable:getImage(math.floor(map(self.degrees, 0, 300, 1, frames))))
end

function RotaryEncoder:getY()
	return self.yy
end