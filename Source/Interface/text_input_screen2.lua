class('TextInputScreen').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local chars = {	"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", 
								"q", "w", "e", "r", "t", "y", "u", "i", "o", "p", 
								"a", "s", "d", "f", "g", "h", "j", "k", "l", 
								"z", "x", "c", "v", "b", "n", "m"}
								
local upper = {	"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", 
								"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", 
								"A", "S", "D", "F", "G", "H", "J", "K", "L", 
								"Z", "X", "C", "V", "B", "N", "M"}
								
local xCoords = {	38, 74, 110, 146, 182, 218, 254, 290, 326, 362, 
									38, 74, 110, 146, 182, 218, 254, 290, 326, 362, 
								  56, 92, 128, 164, 200, 236, 272, 308, 344, 
								  74, 110,146, 182, 218, 254, 290}
									
local yCoords = {100, 125, 150, 175}

local row1CharCount = 10
local row2CharCount = 10
local row3CharCount = 9
local row4CharCount = 8
local row5CharCount = 2
							
local keyRow1Y = 100
local keyRow2Y = 125
local keyRow3Y = 150
local keyRow4Y = 175

local focusWidth = 26
local focusHeight = 30

local margin = 20

function TextInputScreen:init(text)
	TextInputScreen.super.init(self)
	
	self.lower = true
	self.showing = false
	
	if text ~= nil then
		self.input = text
	else
		self.input = ""
	end
	
	self.defaultFont = gfx.getFont()
	local pixarlmed = gfx.font.new("Fonts/pixarlmed")
	gfx.setFont(pixarlmed)

	self.backgroundImageLower = playdate.graphics.image.new(400, 240)
	gfx.pushContext(self.backgroundImageLower)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	gfx.fillRect(0, 0, 400, 240)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
		
	for n=1,36 do			
			local y = 0
			if n <= 10 then
				y = keyRow1Y
			elseif n <= 20 then 
				y = keyRow2Y
			elseif n <= 29 then
				y = keyRow3Y
			else
				y = keyRow4Y
			end
			
			gfx.drawTextAligned(chars[n], xCoords[n], y, kTextAlignment.center)
	end
	
	gfx.drawTextAligned("del", 343, 175, kTextAlignment.center)
	gfx.drawTextAligned("space", 200, 205, kTextAlignment.center)
	gfx.drawTextAligned("done", 335, 205, kTextAlignment.center)
	
	gfx.popContext()
	
	self.backgroundImageUpper = playdate.graphics.image.new(400, 240)
	gfx.pushContext(self.backgroundImageUpper)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	gfx.fillRect(0, 0, 400, 240)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
		
	for n=1,36 do			
			local y = 0
			if n <= 10 then
				y = keyRow1Y
			elseif n <= 20 then 
				y = keyRow2Y
			elseif n <= 29 then
				y = keyRow3Y
			else
				y = keyRow4Y
			end
			
			gfx.drawTextAligned(upper[n], xCoords[n], y, kTextAlignment.center)
	end
	
	gfx.drawTextAligned("del", 343, 175, kTextAlignment.center)
	gfx.drawTextAligned("space", 200, 205, kTextAlignment.center)
	gfx.drawTextAligned("done", 335, 205, kTextAlignment.center)
	
	gfx.popContext()
	
	self:setImage(self.backgroundImageLower)
	self:setZIndex(gTextInputDialogZ + 1)
	self:moveTo(200, 120)
	self:setIgnoresDrawOffset(true)
	
	self.rowIndex = 3
	self.letterIndex = 5
	
	local focusImage = playdate.graphics.image.new(focusWidth, focusHeight)
	gfx.pushContext(focusImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.drawRoundRect(0, 0, focusWidth, focusHeight, 7)
	gfx.popContext()
	self.focusSprite = gfx.sprite.new(focusImage)
	self.focusSprite:setZIndex(31001)
	self.focusSprite:setIgnoresDrawOffset(true)
	
	local spacebarWidth = 136
	local spacebarHeight = focusHeight
	local spacebarImage = playdate.graphics.image.new(spacebarWidth, 30)
	gfx.pushContext(spacebarImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.drawRoundRect(0, 0, spacebarWidth, spacebarHeight, 7)
	gfx.popContext()
	self.spacebarSprite = gfx.sprite.new(spacebarImage)
	self.spacebarSprite:setZIndex(gTextInputDialogZ + 2)
	self.spacebarSprite:moveTo(200, 216)
	self.spacebarSprite:setIgnoresDrawOffset(true)
	
	local deleteWidth = 50
	local deleteHeight = focusHeight
	local deleteImage = playdate.graphics.image.new(deleteWidth, 30)
	gfx.pushContext(deleteImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.drawRoundRect(0, 0, deleteWidth, deleteHeight, 7)
	gfx.popContext()
	self.deleteSprite = gfx.sprite.new(deleteImage)
	self.deleteSprite:setZIndex(gTextInputDialogZ + 3)
	self.deleteSprite:moveTo(345, keyRow4Y + (focusHeight/2) - 5)
	self.deleteSprite:setIgnoresDrawOffset(true)
	
	local doneWidth = 63
	local doneHeight = focusHeight
	local doneImage = playdate.graphics.image.new(doneWidth, 30)
	gfx.pushContext(doneImage)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	gfx.drawRoundRect(0, 0, doneWidth, doneHeight, 7)
	gfx.popContext()
	self.doneSprite = gfx.sprite.new(doneImage)
	self.doneSprite:setZIndex(gTextInputDialogZ + 4)
	self.doneSprite:moveTo(336, 216)
	self.doneSprite:setIgnoresDrawOffset(true)
	
	local inputImage = playdate.graphics.image.new(1, 1)
	self.inputSprite = gfx.sprite.new(inputImage)
	self.inputSprite:setZIndex(gTextInputDialogZ + 5)
	self.inputSprite:moveTo(200, 67)
	self.inputSprite:setIgnoresDrawOffset(true)
	
	self:redrawInput()
end

function TextInputScreen:isShowing()
	return self.showing
end

function TextInputScreen:push(message, onDone)
	self.onDone = onDone
	self:add()
	self.focusSprite:add()
	self.inputSprite:add()
	
	self:updateFocusCaret()
	
	if message ~= nil then
		local messageImage = gfx.imageWithText(message, 400, 100)
		self.messageSprite = gfx.sprite.new(messageImage)
		self.messageSprite:setZIndex(gTextInputDialogZ + 6)
		self.messageSprite:moveTo(200, 25)
		self.messageSprite:setIgnoresDrawOffset(true)
		self.messageSprite:add()
	end
	
	self.inputHandler = {
		
		cranked = function(change, acceleratedChange)
			
		end,
		
		leftButtonDown = function()
			self.letterIndex = math.max(1, self.letterIndex  - 1)
			self:updateFocusCaret()
		end,
		
		rightButtonDown = function()
			self.letterIndex += 1
			
			if self.rowIndex == 1 then
				if self.letterIndex > row1CharCount then self.letterIndex = row1CharCount end
		 	elseif self.rowIndex == 2 then
				if self.letterIndex > row2CharCount then self.letterIndex = row2CharCount end 
			elseif self.rowIndex == 3 then
				if self.letterIndex > row3CharCount then self.letterIndex = row3CharCount end 	 
			elseif self.rowIndex == 4 then
				if self.letterIndex > row4CharCount then self.letterIndex = row4CharCount end 		 
			end
			self:updateFocusCaret()
		end,
		
		upButtonDown = function()
			self.rowIndex = math.max(1, self.rowIndex - 1)
			if self.rowIndex == 4 then
				self.letterIndex = 4
			end
			self:updateFocusCaret()
		end,
		
		downButtonDown = function()
			self.rowIndex = math.min(5, self.rowIndex + 1)
			if self.rowIndex == 1 then
				if self.letterIndex > row1CharCount then self.letterIndex = row1CharCount end
			 elseif self.rowIndex == 2 then
				if self.letterIndex > row2CharCount then self.letterIndex = row2CharCount end 
			elseif self.rowIndex == 3 then
				if self.letterIndex > row3CharCount then self.letterIndex = row3CharCount end 	 
			elseif self.rowIndex == 4 then
				if self.letterIndex > row4CharCount then self.letterIndex = row4CharCount end 
			elseif self.rowIndex == 5 then	
				--space bar	
				self.letterIndex = 1 
			end
			self:updateFocusCaret()
			
		end,
		
		BButtonDown = function()
			self.lower = not self.lower
			
			if self.lower then
				self:setImage(self.backgroundImageLower)
			else
				self:setImage(self.backgroundImageUpper)
			end
		end,
		
		AButtonDown = function()
			self.focusSprite:moveBy(0, 1)
			self.spacebarSprite:moveBy(0, 1)
			self.deleteSprite:moveBy(0, 1)
			
			if self.rowIndex == 1 then
				if self.lower then
					self.input = self.input .. chars[self.letterIndex]
				else
					self.input = self.input .. upper[self.letterIndex]
				end
			elseif self.rowIndex == 2 then
				if self.lower then
					self.input = self.input .. chars[self.letterIndex + 10]
				else
					self.input = self.input .. upper[self.letterIndex + 10]
				end
			elseif self.rowIndex == 3 then
				if self.lower then
					self.input = self.input .. chars[self.letterIndex + 20]
				else
					self.input = self.input .. upper[self.letterIndex + 20]
				end
			elseif self.rowIndex == 4 then
				if self.letterIndex == row4CharCount then
					if string.len(self.input) > 0 then
						self.input = self.input:sub(1, -2)
					end
				else
					if self.lower then
						self.input = self.input .. chars[self.letterIndex + 29]
					else
						self.input = self.input .. upper[self.letterIndex + 29]
					end
				end
			elseif self.rowIndex == 5 then
				if self.letterIndex == 1 then
					self.input = self.input .. " "
				elseif self.letterIndex == 2 then
					self:pop()
					return
				end
				
			end
			
			print("Input: " .. self.input)
			
			self:redrawInput()
		end,
		
		BButtonUp = function()
			
		end,
		
		AButtonUp = function()
			self.focusSprite:moveBy(0, -1)
			self.spacebarSprite:moveBy(0, -1)
			self.deleteSprite:moveBy(0, -1)
		end
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

function TextInputScreen:updateFocusCaret()
	if self.rowIndex == 1 then
		self.focusSprite:moveTo(xCoords[self.letterIndex], yCoords[self.rowIndex] + (focusHeight/2) - 5)
		self.focusSprite:add()
		self.spacebarSprite:remove()
		self.deleteSprite:remove()
	elseif self.rowIndex == 2 then
		self.focusSprite:moveTo(xCoords[self.letterIndex + 10], yCoords[self.rowIndex] + (focusHeight/2) - 5)
		self.focusSprite:add()
		self.spacebarSprite:remove()
		self.deleteSprite:remove()
	elseif self.rowIndex == 3 then
		self.focusSprite:moveTo(xCoords[self.letterIndex + 20], yCoords[self.rowIndex] + (focusHeight/2) - 5)
		self.focusSprite:add()
		self.spacebarSprite:remove()
		self.deleteSprite:remove()
	elseif self.rowIndex == 4 then
		if self.letterIndex == row4CharCount then
			--delete
			self.focusSprite:remove()
			self.spacebarSprite:remove()
			self.deleteSprite:add()
		else
			self.focusSprite:moveTo(xCoords[self.letterIndex + 29], yCoords[self.rowIndex] + (focusHeight/2) - 5)
			self.focusSprite:add()
			self.spacebarSprite:remove()
			self.deleteSprite:remove()
		end
		self.doneSprite:remove()
	elseif self.rowIndex == 5 then
		self.focusSprite:remove()
		self.deleteSprite:remove()
		if self.letterIndex == 1 then
			self.spacebarSprite:add()
			self.doneSprite:remove()
		elseif self.letterIndex == 2 then
			self.spacebarSprite:remove()
			self.doneSprite:add()
		end
	else
		print("Invalid row index: " .. self.rowIndex)
	end
end

function TextInputScreen:pop()
	self.isShowing = false
	gfx.setFont(self.defaultFont)
	self.focusSprite:remove()
	self.spacebarSprite:remove()
	self.deleteSprite:remove()
	self.doneSprite:remove()
	self.inputSprite:remove()
	self.focusSprite = nil
	self.spacebarSprite = nil
	self.deleteSprite = nil
	self.doneSprite = nil
	self.inputSprite = nil
	if self.messageSprite ~= nil then 
		self.messageSprite:remove() 
		self.messageSprite = nil
	end
	self:remove()
	
	playdate.inputHandlers.pop()
	if self.onDone ~= nil then self.onDone(self.input) end
end