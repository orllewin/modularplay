--[[
	item objects must have a String field called label
	they can optionally have a type, with only current option being checkbox:
	{
		{
			label = "Test",
			action = "some_action",
			type = "checkbox",
			checked = true
		}
	}
	
]]--
import 'Coracle/string_utils'

class('TextList').extends(playdate.graphics.sprite)

function TextList:init(items, xx, yy, w, h, rH, onChange, onSelect, zIndex)
	TextList.super.init(self)
	print("TextList:init files: " .. #items )
	
	self.zIndex = zIndex
	
	self.rowHeight = rH
	local nWidth, nHeight = playdate.graphics.getTextSize("XXX")
	
	self.fontHeight = nHeight
	
	self.items = items
	self.onChange = onChange
	self.onSelect = onSelect
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	self.yy = yy
	self.w = w
	self.h = h
	self.index = 1
	self.indexOffset = 0
	self.visibleRows = h/self.rowHeight
	if self.visibleRows > #items then self.visibleRows = #items end
	
	self:setIgnoresDrawOffset(true)
	self:moveTo(xx + w/2, yy + h/2)
	if self.zIndex ~= nil then self:setZIndex(zIndex) end
	self:add()
	
	--Focus caret
	local focusImage = playdate.graphics.image.new(w+8, self.rowHeight+6)
	playdate.graphics.pushContext(focusImage)
		playdate.graphics.setLineWidth(2)
		playdate.graphics.drawRoundRect(2, 2, w+4, self.rowHeight+1, 4)
	playdate.graphics.popContext()
	self.focusSprite = playdate.graphics.sprite.new(focusImage)
	if self.zIndex ~= nil then self.focusSprite:setZIndex(self.zIndex + 1) end
	self.focusSprite:setIgnoresDrawOffset(true)
	self.focusSprite:moveTo(xx + w/2, yy + self.rowHeight/2)
	self.focusSprite:add()
	self.focusSprite:setVisible(true)
	
	self:drawRows()
	self:drawFocused()
end

function TextList:updateItems(items)
	self.index = 1
	self.indexOffset = 0
	self.items = items
	self.visibleRows = self.h/self.rowHeight
	if self.visibleRows > #items then self.visibleRows = #items end
	self:drawRows()
	self:drawFocused()
end

function TextList:updateItemsNoReset(items)
	self.items = items
	self.visibleRows = self.h/self.rowHeight
	if self.visibleRows > #items then self.visibleRows = #items end
	self:drawRows()
	self:drawFocused()
end

function TextList:drawRows()
	local rowsImage = playdate.graphics.image.new(self.w, self.h)
	playdate.graphics.pushContext(rowsImage)
	playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
		for i=1,self.visibleRows do
			local indexOffset = self.indexOffset
			local item = self.items[i + indexOffset]
			local text = item.label
			if text == nil then
				text = self.items[i + indexOffset].category
			end
			if text == nil then
				text = "Missing identifier"
			end
			text = replace(text, "_", " ")
			if self:endsWith(text, ".pda") then  text = text:gsub(".pda", "") end
			playdate.graphics.drawText(string.upper(text), 4, ((i - 1) * self.rowHeight + ((self.rowHeight/self.fontHeight)/2) + 4))
			
			if item.type ~= nil then
				local type = item.type
				if type == "checkbox" then
					local startX = self.w - 14
					local startY = ((i - 1) * self.rowHeight + ((self.rowHeight/self.fontHeight)/2) + 2)
					
					if item.checked then
						playdate.graphics.fillRect(startX, startY, 10, 10)
					else
						playdate.graphics.drawRect(startX, startY, 10, 10)
					end
				end
			end
		end
	playdate.graphics.popContext()
	local fadedImage = playdate.graphics.image.new(self.w, self.h)
	playdate.graphics.pushContext(fadedImage)
	rowsImage:drawFaded(0, 0, 0.4, playdate.graphics.image.kDitherTypeBayer2x2)
	playdate.graphics.popContext()
	self:setImage(rowsImage)
end

--http://lua-users.org/wiki/StringRecipes
function TextList:endsWith(str, ending)
	 return ending == "" or str:sub(-#ending) == ending
end

function TextList:drawFocused()
	self.focusSprite:moveTo(
		self.focusSprite.x, 
		self.yy + (self.rowHeight * (self.index - self.indexOffset)) - self.rowHeight/2)
end

function TextList:removeAll()
	self:remove()
	self.focusSprite:remove()
end

function TextList:cranked(value)
	if value > 0 then
		self:goUp()
	elseif value < 0 then
		self:goDown()
	end
end

-- inefficient but my brain is tired:
function TextList:setSelected(index)
	if index == nil then return end
	if index > 1 then
		for i=1,index-1 do 
			self:goDown()
		end
	else
		--Again, too tired to do this properly:
		self:updateItems(self.items)
	end
end

function TextList:canGoUp()
	return true
end

function TextList:goUp()
	if self.index > 1 then 
		self.index -= 1 
		if self.index > self.visibleRows - 1 then self.indexOffset -= 1 end
	else
		self:setSelected(#self.items)
	end
	
	self:drawRows()
	self:drawFocused()
	if self.onChange then self.onChange(self.index, self.items[self.index]) end
end

function TextList:canGoDown()
	return true
end

function TextList:goDown()
	if self.index < #self.items then 
		self.index += 1 
		if self.index > self.visibleRows then self.indexOffset += 1 end
	else
		self:setSelected(1)
	end
	
	self:drawRows()
	self:drawFocused()
	if self.onChange then self.onChange(self.index, self.items[self.index]) end
end

function TextList:setFocus(focus)
	self.hasFocus = focus
	self.focusSprite:setVisible(focus)
	
	if focus then
		if self.onChange then self.onChange(self.index, self.items[self.index]) end
	end
end

function TextList:tapA()
	if self.onSelect then 
		local item =  self.items[self.index]
		if item.type then
			if item.type == "checkbox" then
				self.items[self.index].checked = not self.items[self.index].checked
				self:updateItemsNoReset(self.items)
			end
		end
		self.onSelect(self.index, item) 
	end
end

function TextList:emitSelected()
	if self.onChange then self.onChange(self.index, self.items[self.index]) end
end

function TextList:getSelected()
	return self.items[self.index]
end

function TextList:isFocused()
	print("TextList:isFocused(): " .. tostring(self.hasFocus))
	return self.hasFocus
end