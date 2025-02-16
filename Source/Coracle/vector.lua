class('Vector').extends()

local sqrt <const> = math.sqrt

function Vector:init(x, y)
	 Vector.super.init(self)
	 self.x = x or 0
	 self.y = y or 0
end

function Vector:distance(vector)
	local dx = self.x - vector.x
	local dy = self.y - vector.y
	return sqrt(dx * dx + dy * dy)
end

function Vector:direction(vector)
	local direction = Vector(vector.x - self.x, vector.y - self.y)
	direction:normalise()
	return direction
end

function Vector:times(amount)
	 self.x = self.x * amount
	 self.y = self.y * amount
end

function Vector:normalise(vector)
	 local magnitude = math.sqrt(self.x * self.x + self.y * self.y)
	 if(magnitude > 0) then
		 self.x = self.x/magnitude
		 self.y = self.y/magnitude
	 end
end

function vectorMinus(a, b)
	 return Vector(a.x - b.x, a.y - b.y)
end

function Vector:plus(vector)
	 self.x = self.x + vector.x
	 self.y = self.y + vector.y
end

function Vector:limit(max)
	 local magnitudeSquared = self.x * self.x + self.y * self.y
	 if(magnitudeSquared > max * max) then
		self:normalise()
		self.x = self.x * max
		self.y = self.y * max
	 end
end