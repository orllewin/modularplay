class('Assets').extends()

local gfx <const> = playdate.graphics

function Assets:init()
	Assets.super.init(self)
	self.images = {}
	self._bigFont = nil
end

function Assets:getImage(filename)
	return self:image(filename)
end

function Assets:image(filename)
	if self.images[filename] == nil then
		self.images[filename] = gfx.image.new("Images/" .. filename)
	end
	
	return self.images[filename]
end

function Assets:bigFont()
	if self._bigFont == nil then
		self._bigFont = gfx.font.new("Fonts/pixarlmed")
	end
	
	return self._bigFont
end