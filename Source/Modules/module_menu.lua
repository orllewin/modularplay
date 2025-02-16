--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils'
import 'CoracleViews/text_list'

class('ModuleMenu').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local width = 175
local height = 220

function ModuleMenu:init(actions)
	ModuleMenu.super.init(self)
	
	self.actions = actions
		
	self.ww = width
	self.hh = height
	
	self.crankDelta = 0.0
	
	if playdate.display.getScale() == 2 then
		self.ww = 200
		self.hh = 120
	end
	
	local backgroundImage = generateModBackgroundWithShadow(self.ww, self.hh)	
	local bgW, bgH = backgroundImage:getSize()	
	self:setIgnoresDrawOffset(true)
	self:setImage(backgroundImage)
	
	if xx ~= nil and yy ~= nil then
		self:moveTo(xx, yy)
	else
		if playdate.display.getScale() == 1 then
			self:moveTo(305, 120)
		else
			self:moveTo(100, 60)
		end
	end
	
	self:setZIndex(gModuleMenuZ)
	
end

function ModuleMenu:show(onAction, selectedIndex)
	self:add()
	
	gScrollLock = true
	
	self.actionList = TextList(self.actions, self.x - self.ww/2 + 8, self.y - self.hh/2 + 8, self.ww - 16, self.hh-5, 20, nil, function(index)
		if self.actions[index].category ~= nil then
			print("Found category - display sublist: " .. self.actions[index].category)
			local subActions = self.actions[index].actions
			self.actions = subActions
			self.actionList:updateItems(self.actions)
		else
			if self.actions[index].type == "checkbox" then
				print("item: " .. self.actions[index].label)
				local selectedAction = self.actions[index].label
				onAction(selectedAction, index, self.actions[index])
			else
				self:dismiss()
				local selectedAction = self.actions[index].label
				onAction(selectedAction, index, self.actions[index])
			end
		end
	end, gModuleMenuZ + 1)
	
	self:setSelected(selectedIndex)
	
	self.actionMenuInputHandler = {
		
		BButtonDown = function()
			self:dismiss()
		end,
		
		AButtonDown = function()
			self.actionList:tapA()
		end,
		
		leftButtonDown = function()
	
		end,
		
		rightButtonDown = function()
	
		end,
		
		upButtonDown = function()
			self.actionList:goUp()
		end,
		
		downButtonDown = function()
			self.actionList:goDown()
		end,
		
		cranked = function(change, acceleratedChange)
				self.crankDelta += change
				if self.crankDelta < -20 then
					self.crankDelta = 0.0
					self.actionList:goUp()
				elseif self.crankDelta > 20 then
					self.crankDelta = 0.0
					self.actionList:goDown()
				end
		end,
	}
	playdate.inputHandlers.push(self.actionMenuInputHandler )
end

function ModuleMenu:setSelected(index)
	self.actionList:setSelected(index)
end

function ModuleMenu:dismiss()
	playdate.inputHandlers.pop()
	gScrollLock = false
	self.actionList:removeAll()
	self:remove()
end