--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'

class('ImageMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local modType = "ImageMod"
local modSubtype = "other"

function ImageMod:init(xx, yy, modId)
	ImageMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.imagePath = nil
	self.alpha = 1.0
	
	self:updateImage()
	self:moveTo(xx, yy)
	self:add()
end

function ImageMod:updateImage()
	if self.imagePath ~= nil then
		if self.alpha == 1.0 then
			self:setImage(gfx.image.new(self.imagePath))
		else
			local image = gfx.image.new(self.imagePath)
			local imageWidth, imageHeight = image:getSize()
			local base = gfx.image.new(imageWidth, imageHeight)
			gfx.pushContext(base)
			image:drawFaded(0, 0, self.alpha, gfx.image.kDitherTypeBayer2x2)
			gfx.popContext()
			self:setImage(base)
		end
	end
end

function ImageMod:type()
	return modType
end

function ImageMod:getModId()
	return self.modId
end

function ImageMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
	end)
end

function ImageMod:evaporate(onDetachConnected)
	self:remove()
end

function ImageMod:collision(x, y)
	if x > self.x - 10 and x < self.x + 10 and y > self.y - 10 and y < self.y + 10 then
		return true
	else
		return false
	end
end

function ImageMod.ghostModule()
	return buildGhostModule(40, 40)
end

function ImageMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.imagePath = self.imagePath
	modState.alpha = self.alpha
	
	return modState
end

function ImageMod:fromState(modState)
	self.imagePath = modState.imagePath
	self.alpha = modState.alpha
	self:updateImage()
end