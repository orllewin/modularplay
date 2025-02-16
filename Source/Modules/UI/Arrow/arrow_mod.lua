--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'

class('ArrowMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local dir_up = 1
local dir_down = 2
local dir_left = 3
local dir_right = 4
local dir_up_left = 5
local dir_up_right = 6
local dir_down_left = 7
local dir_down_right = 8

local modType = "ArrowMod"
local modSubtype = "other"

function ArrowMod:init(xx, yy, modId)
	ArrowMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.direction = dir_up
	
	self:updateImage()
	self:moveTo(xx, yy)
	self:add()
end

function ArrowMod:updateImage()
	if self.direction == dir_up then
		self:setImage(gfx.image.new('Images/dir_up'))
	elseif self.direction == dir_down then
		self:setImage(gfx.image.new('Images/dir_down'))
	elseif self.direction == dir_left then
		self:setImage(gfx.image.new('Images/dir_left'))
	elseif self.direction == dir_right then
		self:setImage(gfx.image.new('Images/dir_right'))
	elseif self.direction == dir_up_left then
		self:setImage(gfx.image.new('Images/dir_up_left'))
	elseif self.direction == dir_up_right then
		self:setImage(gfx.image.new('Images/dir_up_right'))
	elseif self.direction == dir_down_left then
		self:setImage(gfx.image.new('Images/dir_down_left'))
	elseif self.direction == dir_down_right then
		self:setImage(gfx.image.new('Images/dir_down_right'))
	end
end

function ArrowMod:type()
	return modType
end

function ArrowMod:getModId()
	return self.modId
end

function ArrowMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		
		{label = "Up"},
		{label = "Down"},
		{label = "Left"},
		{label = "Right"},
		{label = "Up-left"},
		{label = "Up-right"},
		{label = "Down-left"},
		{label = "Down-right"},
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("An on-screen label.")
			aboutPopup:show()
		elseif action == "Up" then
			self.direction = dir_up
			self:updateImage()
		elseif action == "Down" then
			self.direction = dir_down
			self:updateImage()	
		elseif action == "Left" then
			self.direction = dir_left
			self:updateImage()	
		elseif action == "Right" then
			self.direction = dir_right
			self:updateImage()
		elseif action == "Up-left" then
			self.direction = dir_up_left
			self:updateImage()
		elseif action == "Up-right" then
			self.direction = dir_up_right
			self:updateImage()
		elseif action == "Down-left" then
			self.direction = dir_down_left
			self:updateImage()
		elseif action == "Down-right" then
			self.direction = dir_down_right
			self:updateImage()	
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function ArrowMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function ArrowMod:moveFinish()
	--NOOP
end

function ArrowMod:evaporate(onDetachConnected)
	self:remove()
end

function ArrowMod:collision(x, y)
	if x > self.x - 10 and x < self.x + 10 and y > self.y - 10 and y < self.y + 10 then
		return true
	else
		return false
	end
end

function ArrowMod.ghostModule()
	return buildGhostModule(40, 40)
end

function ArrowMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.direction = self.direction
	
	return modState
end

function ArrowMod:fromState(modState)
	self.direction = modState.direction
	self:updateImage()
end