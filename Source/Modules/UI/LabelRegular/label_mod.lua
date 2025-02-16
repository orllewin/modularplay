--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'

class('LabelMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local maxLabelWidth = 110
local maxLabelHeight = 200
local moduleWidth = 80
local moduleHeight = 20

local modType = "LabelMod"
local modSubtype = "other"

function LabelMod:init(xx, yy, modId)
	LabelMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.label = "----"
	
	local labelImage = gfx.imageWithText(self.label, maxLabelWidth, maxLabelHeight)
	local labelW, labelH = labelImage:getSize()
	
	self.moduleWidth = labelW +10
	self.moduleHeight = labelH + 10
	
	self:redraw("Hello, World!")
	self:moveTo(xx, yy)
	self:add()
end

function LabelMod:setLabel(label)
	self:redraw(label)
end

function LabelMod:redraw(label)
	if label == nil then return end
	self.label = label
	
	local labelImage = gfx.imageWithText(self.label, maxLabelWidth, maxLabelHeight)
	local labelW, labelH = labelImage:getSize()
	
	self.moduleWidth = labelW + 20
	self.moduleHeight = labelH + 20
	
	local backgroundImage = generateModBackground(self.moduleWidth,	self.moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	gfx.pushContext(backgroundImage)
	labelImage:draw((bgW-labelW)/2, (bgH - labelH)/2)
	gfx.popContext()
	
	self:setImage(backgroundImage)
end

function LabelMod:type()
	return modType
end

function LabelMod:getModId()
	return self.modId
end

function LabelMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Edit"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("An on-screen label.")
			aboutPopup:show()
		elseif action == "Edit" then
			self.textInputScreen = TextInputScreen(self.label)
			gModularRunning = false
			self.textInputScreen:push("Edit label:", function(name)
				gModularRunning = true
				self:setLabel(name)
				self.textInputScreen = nil
			end)
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function LabelMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function LabelMod:moveFinish()
	--NOOP
end

function LabelMod:evaporate(onDetachConnected)
	self:remove()
end

function LabelMod:collision(x, y)
	if x > self.x - (self.moduleWidth/2) and x < self.x + (self.moduleWidth/2) and y > self.y - (self.moduleHeight/2) and y < self.y + (self.moduleHeight/2) then
		return true
	else
		return false
	end
end

function LabelMod.ghostModule()
	return buildGhostModule(100, 40)
end

function LabelMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.label = self.label
	
	return modState
end

function LabelMod:fromState(modState)
	self:setLabel(modState.label)
end