class('TextInputScreen').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local chars = {
	{"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"},
	{"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"},
	{"A", "S", "D", "F", "G", "H", "J", "K", "L", "-"},
	{"Z", "X", "C", "V", "B", "N", "M", " ", "", ""}
}

local keyboardImage = gfx.image.new("Images/keyboard")

function TextInputScreen:init(text)
	TextInputScreen.super.init(self)
	
	self.showing = false
	
	self.rowIndex = 1
	self.colIndex = 1
	
	if text ~= nil then
		self.input = text
	else
		self.input = ""
	end
	
	self.backgroundImage = gfx.getDisplayImage()
	
	gfx.pushContext(self.backgroundImage)
	local semitransImage = gfx.image.new(400, 240, gfx.kColorWhite)
	semitransImage:drawFaded(0, 0, 0.8, gfx.image.kDitherTypeDiagonalLine)
	
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRoundRect(86, 105, 233, 135, 5)

	keyboardImage:draw(90, 151)
	
	gfx.setColor(gfx.kColorBlack)
	gfx.drawRoundRect(86, 105, 233, 135, 5)
	
	gfx.popContext()
	

	
	self:setImage(self.backgroundImage)
	self:setZIndex(gTextInputDialogZ + 1)
	self:moveTo(200, 120)
	self:setIgnoresDrawOffset(true)
	
	
	
	local focusImage = gfx.image.new(22, 22)
	gfx.pushContext(focusImage)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawRoundRect(0, 0, 22, 22, 3)
	gfx.popContext()
	self.focusSprite = gfx.sprite.new(focusImage)
	self.focusSprite:setZIndex(31001)
	self.focusSprite:setIgnoresDrawOffset(true)
	self.focusSprite:moveTo(100, 163)
	
	
	local inputImage = gfx.image.new(1, 1)
	self.inputSprite = gfx.sprite.new(inputImage)
	self.inputSprite:setZIndex(gTextInputDialogZ + 5)
	self.inputSprite:moveTo(200, 142)
	self.inputSprite:setIgnoresDrawOffset(true)
	
	
	
	self:redrawInput()
end

function TextInputScreen:isShowing()
	return self.showing
end

function TextInputScreen:moved()
	self.rowIndex = math.max(1, self.rowIndex)
	self.rowIndex = math.min(4, self.rowIndex)
	self.colIndex = math.max(1, self.colIndex)
	self.colIndex = math.min(10, self.colIndex)
	self.focusSprite:moveTo(79 + (self.colIndex * 22), 141	 + (self.rowIndex * 22))
end

function TextInputScreen:push(message, onDone)
	self.onDone = onDone
	self:add()
	self.focusSprite:add()
	self.inputSprite:add()
		
	if message ~= nil then
		local messageImage = gfx.imageWithText(message, 400, 100)
		self.messageSprite = gfx.sprite.new(messageImage)
		self.messageSprite:setZIndex(gTextInputDialogZ + 6)
		self.messageSprite:moveTo(200, 125)
		self.messageSprite:setIgnoresDrawOffset(true)
		self.messageSprite:add()
	end
	
	self.inputHandler = {
		
		cranked = function(change, acceleratedChange)
			
		end,
		
		leftButtonDown = function()
			self.colIndex -= 1
			self:moved()
		end,
		
		rightButtonDown = function()
			self.colIndex += 1
			self:moved()
		end,
		
		upButtonDown = function()
			self.rowIndex -= 1
			self:moved()
		end,
		
		downButtonDown = function()
			self.rowIndex += 1
			self:moved()
		end,
		
		BButtonDown = function()
			self.input = nil
			self:pop()
		end,
		
		AButtonDown = function()
			if self.rowIndex == 4 and self.colIndex == 9 then
				print("delete")
				if string.len(self.input) > 0 then
					self.input = self.input:sub(1, -2)
					self:redrawInput()
				end
			elseif self.rowIndex == 4 and self.colIndex == 10 then
				self:pop()
			else
				self.input = self.input .. chars[self.rowIndex][self.colIndex]
				self:redrawInput()
			end
			
		end,
	}
	playdate.inputHandlers.push(self.inputHandler)
	self.showing = true
end

function TextInputScreen:redrawInput()
		if string.len(self.input) > 0 then
			local inputImage = gfx.imageWithText(self.input, 400, 100)
			self.inputSprite:setImage(inputImage)
			self.inputSprite:add()
		else
			self.inputSprite:remove()
		end
end

function TextInputScreen:pop()
	self.isShowing = false
	self.focusSprite:remove()
	self.inputSprite:remove()
	self.focusSprite = nil
	self.inputSprite = nil
	if self.messageSprite ~= nil then 
		self.messageSprite:remove() 
		self.messageSprite = nil
	end
	self:remove()
	
	if self.input == "" then self.input = nil end
	
	playdate.inputHandlers.pop()
	if self.onDone ~= nil then self.onDone(self.input) end
end