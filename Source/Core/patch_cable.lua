--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Coracle/vector'

class('PatchCable').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local sqrt <const> = math.sqrt
local sinh <const> = math.sinh
local cosh <const> = math.cosh

local cableWidth = 3

local modeCatenary = 1
local modeStraightLine = 2

function PatchCable:init(ghost, cableId)
	PatchCable.super.init(self)
	
	if cableId == nil then
		local seconds, milliseconds =  playdate.getSecondsSinceEpoch()
		self.cableId = "PatchCable-" .. ((seconds * 1000) + milliseconds) .. "_" .. (math.random())
	else
		self.cableId = cableId
	end
	
	if ghost == nil then
		self.ghost = false
	else
		self.ghost = ghost
	end
	
	if self.ghost then
		self.mode = modeStraightLine
	else
		self.mode = modeCatenary
	end
	
	self.hostAudioModId = nil
		
	self.ghostSendConnected = false
	self.ghostReceiveConnected = false
	
	self.sendSocket = nil
	self.receiveSocket = nil
	
	self.orientation = -1
	
	self.maxY = 0
	
	self.startX = -1
	self.startY = -1
	
	self.endX = -10
	self.endY = -10
	
	self.length = 125
	
	self:redraw()
	self:setZIndex(gCableZ)
	self:add()
	
	self.showing = true
end

function PatchCable:setHostAudioModId(modId)
		self.hostAudioModId = modId
end

function PatchCable:getHostAudioModId()
	return self.hostAudioModId
end


function PatchCable:setStartModId(modId)
	self.startModId = modId
end

function PatchCable:setStartAudioModId(modId)
	self.hostAudioModId = modId
end

function PatchCable:setEndModId(modId)
	self.endModId = modId
end

function PatchCable:evaporate()
	self:remove()
end

function PatchCable:isShowing()
	return self.showing
end

function PatchCable:show()
	self.showing = true
	self:add()
end

function PatchCable:hide()
	self.showing = false
	self:remove()
end

function PatchCable:clone(other)
	other:setStart(self.startX, self.startY)
	other:setEnd(self.endX, self.endY)
end

function PatchCable:getEndXY()
	return self.endX, self.endY
end

function PatchCable:getEndX()
	return self.endX
end

function PatchCable:getEndY()
	return self.endY
end

function PatchCable:setStart(startX, startY, modId)
	self.startX = startX
	self.startY = startY
	self.startModId = modId
	self:redraw()
end

function PatchCable:repositionStart(x, y)
	self.startX = self.startX + x
	self.startY = self.startY + y
	self.mode = modeStraightLine
	
	self:redraw(distance)
end

function PatchCable:repositionEnd(x, y)
	self.endX = self.endX + x
	self.endY = self.endY + y	
	self.mode = modeStraightLine
	self:redraw()
end

function PatchCable:finishReposition()
	local dx = self.endX - self.startX
	local dy = self.endY - self.endY
	local distance = sqrt(dx * dx + dy * dy)
	
	if distance > self.length/3 then
		self.length = distance + (distance/3)
	end
	
	self.mode = modeCatenary
	
	self:redraw(distance)
end

function Vector:distance(vector)
	local dx = self.x - vector.x
	local dy = self.y - vector.y
	return sqrt(dx * dx + dy * dy)
end

function PatchCable:setEnd(endX, endY, modId)
	self.endX = endX
	self.endY = endY
	self.endModId = modId
	
	local dx = endX - self.startX
	local dy = endY - self.endY
	local distance = sqrt(dx * dx + dy * dy)
	
	if distance > self.length/3 then
		self.length = distance + (distance/3)
	end

	self:redraw(distance)
end

function PatchCable:redraw(distance)
	local startX = self.startX
	local startY = self.startY
	local endX = self.endX
	local endY = self.endY
	
	local cableImage = nil
	
	local width = math.max(1, math.abs(endX - startX))
	local height = 240 - math.min(startY, endY)
	
	local forceStraight = false
	
	if distance ~= nil and distance < 20 then
		forceStraight = true
	end
	
	if math.abs(startX - endX) < 5 then
		forceStraight = true
	end
	
	if self.mode == modeStraightLine then
		width = math.max(1, math.abs(endX - startX))
		height = math.max(1, math.abs(endY - startY))
		cableImage = playdate.graphics.image.new(width,height)
		
		if startY < endY then
			if startX < endX then
				self.pointA = Vector(0, 0)
				self.pointB = Vector(width, endY - startY)
			else
				self.pointA = Vector(0, endY - startY)
				self.pointB = Vector(width, 0)
			end
		else
			if startX < endX then
				self.pointA = Vector(0, startY - endY)
				self.pointB = Vector(width, 0)
			else
				self.pointA = Vector(0, 0)
				self.pointB = Vector(width,  startY - endY)
			end
		end
		
		gfx.pushContext(cableImage)
		gfx.setLineWidth(cableWidth * 1.5)
		gfx.drawLine(self.pointA.x, self.pointA.y, self.pointB.x, self.pointB.y)
		gfx.popContext()
		
		self:setImage(cableImage)
		gfx.setLineWidth(1)
		self:moveTo(math.min(startX, endX) + (width/2) , math.min(startY, endY) + height/2)
		return
	end
	
	if startX == endX then
		width = cableWidth
		local h =  math.abs(endY - startY)
		if h < 1 then h = 1 end
		cableImage = playdate.graphics.image.new(cableWidth, h, playdate.graphics.kColorBlack)
	else		
		if startY < endY then
			if startX < endX then
				self.pointA = Vector(0, 0)
				self.pointB = Vector(width, endY - startY)
			else
				self.pointA = Vector(0, endY - startY)
				self.pointB = Vector(width, 0)
			end
		else
			if startX < endX then
				self.pointA = Vector(0, startY - endY)
				self.pointB = Vector(width, 0)
			else
				self.pointA = Vector(0, 0)
				self.pointB = Vector(width,  startY - endY)
			end
		end
		
		--A ghost cable moves and redraw a lot, so use fewer expensive operations
		local chain = nil
		if self.ghost then
			chain = self:compute_chain(9)
		else
			chain = self:compute_chain(18)
		end
		
		local prev = Vector(-1, -1)
		local	current = Vector(-1, -1)
		
		height =  (math.max(1, math.min(500,self.maxY)) + cableWidth)
		
		cableImage = playdate.graphics.image.new(width,height)
		gfx.pushContext(cableImage)
		
		gfx.setColor(playdate.graphics.kColorBlack)
		
		gfx.setLineWidth(cableWidth)
		for i=1,#chain do
			current = chain[i]
			
			if(prev.x ~= -1 and prev.y ~= -1 and i >1)then
				gfx.drawLine(current.x, current.y, prev.x, prev.y)
			end
			
			prev.x = current.x
			prev.y = current.y
		end
		gfx.setLineWidth(1)
		gfx.popContext()
	end
	
	if self.ghost ~= nil and self.ghost == true then
		local fadedImage = playdate.graphics.image.new(width, math.max(1, height))
		gfx.pushContext(fadedImage)
			cableImage:drawFaded(0, 0, 0.3, playdate.graphics.image.kDitherTypeBayer2x2)
		gfx.popContext()
		self:setImage(fadedImage)
	else
		local fadedImage = playdate.graphics.image.new(width, math.max(1, height))
		gfx.pushContext(fadedImage)
			cableImage:drawFaded(0, 0, 0.6, playdate.graphics.image.kDitherTypeBayer2x2)
		gfx.popContext()
		self:setImage(fadedImage)
	end
	
	self:moveTo(math.min(startX, endX) + (width/2) , math.min(startY, endY) + height/2)
end

function PatchCable:getCable()
	return self
end

function PatchCable:compute_chain(n)
	
	local array = {}
	local a = self:find_a()
	local x = self:find_x(a)
	
	self.maxY = 0
	
	local y0 = self.pointA.y - -1*a*cosh((self.pointA.x-x)/a)
	local y1 = self.pointB.y - -1*a*cosh((self.pointB.x-x)/a);
	
	for i=0,n-1 do
		local t = self.pointA.x + i/(n-1) * (self.pointB.x-self.pointA.x)
		local y = -1*a*cosh((t-x)/a) + self:lerp(y0,y1,i/(n-1))
		local v = Vector(t, y)
		
		if v.y > self.maxY then
			self.maxY = v.y
		end
		
		table.insert(array, v)		
	end
	
	return array
end

function PatchCable:find_a()
	local k = self.length/(self.pointB.x - self.pointA.x)
	local x = sqrt(6*(k-1))
	local nb_iter = 50
	-- looking for the solution to sinh(x)/x-k = 0 using Newton
	for i=0, nb_iter do
		x -= (sinh(x)-k*x)/(cosh(x) - k)
	end
	return (self.pointB.x - self.pointA.x)/(2*x)
end

function PatchCable:find_x(a)
	local x = self:lerp(self.pointA.x, self.pointB.x, 0.5)
	local nb_iter = 50
	for i=0, nb_iter do
		x += (-1*cosh((self.pointA.x-x)/a)- -1*cosh((self.pointB.x-x)/a) + (self.pointB.y-self.pointA.y)/a)/(-1*sinh((self.pointA.x-x)/a)- -1*sinh((self.pointB.x-x)/a))
	end
	return x;
end

function PatchCable:lerp(a,b,t) 
	return a * (1-t) + b * t 
end

function PatchCable:inConnected()
	return self.cable:sendConnected()
end

function PatchCable:inFree()
	if self.ghost then
		return not self.ghostSendConnected
	else
		return not self.cable:sendConnected()
	end
end

function PatchCable:outConnected()
	return self.cable:receiveConnected()
end

function PatchCable:outFree()
	if self.ghost then
		return not self.ghostReceiveConnected
	else
		return not self.cable:receiveConnected()
	end
end

function PatchCable:setGhostSendConnected()
	self.ghostSendConnected = true
end

function PatchCable:setGhostReceiveConnected()
	self.ghostReceiveConnected = true
end

-- Non sprite state:
function PatchCable:setSendSocket(socket)
	print("PatchCable has send socket")
	self.sendSocket = socket
end

function PatchCable:setReceiveSocket(socket)
	if socket == nil then
		print("PatchCable setReceiveSocket passed nil")
	else
		print("PatchCable has receive socket")
	end
	
	self.receiveSocket = socket
end

function PatchCable:sendConnected()
	if self.sendSocket ~= nil then 
		return true 
	else
		return false 
	end
end

function PatchCable:receiveConnected()
	if self.receiveSocket ~= nil then 
		return true 
	else
		return false 
	end
end

function PatchCable:send(event)
	if self.receiveSocket == nil then return end
	self.receiveSocket:receive(event)
end

function PatchCable:getStartModId()
	return self.startModId
end

function PatchCable:getEndModId()
	return self.endModId
end

function PatchCable:getCableId()
	return self.cableId
end

function PatchCable:toState()
	local modState = {}
	modState.cableId = self.cableId
	modState.startModId = self.startModId
	modState.endModId = self.endModId
	modState.hostAudioModId = self.hostAudioModId
	
	modState.startX = self.startX
	modState.startY = self.startY
	modState.endX = self.endX
	modState.endY = self.endY
	modState.length = self.length
	return modState
end


function PatchCable:fromState(modState)
	self.startModId = modState.startModId
	self.endModId = modState.endModId
	self.startX = modState.startX
	self.startY = modState.startY
	self.endX = modState.endX
	self.endY = modState.endY
  self.length = modState.length
	self.hostAudioModId = modState.hostAudioModId
end
