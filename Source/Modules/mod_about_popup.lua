--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils'

class('ModAboutPopup').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local width = 150
local height = 230

function ModAboutPopup:init(aboutText)
	ModAboutPopup.super.init(self)
	
	local w = width
	local h = height
	
	if playdate.display.getScale() == 1 then
		self.aboutSprite = playdate.graphics.sprite.spriteWithText(string.upper(aboutText), width - 12, height - 12, playdate.graphics.kColorWhite, 3, "...", kTextAlignment.left)
		self.aboutSprite:setIgnoresDrawOffset(true)	
		self.aboutSprite:moveTo(100,  120)
	elseif playdate.display.getScale() == 2 then
		w = 200
		h = 120	
		self.aboutSprite = playdate.graphics.sprite.spriteWithText(string.upper(aboutText), w , h, playdate.graphics.kColorWhite, 3, "...", kTextAlignment.left)
		self.aboutSprite:moveTo(100,  60)
		self.aboutSprite:setIgnoresDrawOffset(true)	
	end
	

	
	
	self.aboutSprite:setZIndex(gModuleMenuZ + 1)
	
	local textW, textH = self.aboutSprite:getSize()
		
	local backgroundImage = generateModBackgroundWithShadow(textW+15, textH+15)
	local bgW, bgH = backgroundImage:getSize()
	
	self:setIgnoresDrawOffset(true)
	self:setImage(backgroundImage)
	if playdate.display.getScale() == 1 then
		self:moveTo(100, (height/2) + 5)
	elseif playdate.display.getScale() == 2 then
		self:moveTo(100,  60)
	end
	self:setZIndex(gModuleMenuZ)
	
	self.aboutPopupInputHandler = {
		
		BButtonDown = function()
			self:dismiss()
		end,
		
		AButtonDown = function()
			self:dismiss()
		end,
		
		leftButtonDown = function()
		end,
		
		rightButtonDown = function()
		end,
		
		upButtonDown = function()
		end,
		
		downButtonDown = function()
		end
	}
	
end

function ModAboutPopup:show()
	self:add()
	self.aboutSprite:add()
	playdate.inputHandlers.push(self.aboutPopupInputHandler)
end

function ModAboutPopup:dismiss()
	playdate.inputHandlers.pop()
	self.aboutSprite:remove()
	self:remove()
end