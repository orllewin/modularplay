--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/mod_utils.lua'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'

class('ButtonMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local maxLabelWidth = 120
local maxLabelHeight = 200
local moduleWidth = 80
local moduleHeight = 20

local modType = "ButtonMod"
local modSubtype = "other"

function ButtonMod:init(xx, yy, modId)
	ButtonMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.navTarget = nil
	
	self.label = "------"
	
	local labelImage = gfx.imageWithText(self.label, maxLabelWidth, maxLabelHeight)
	local labelW, labelH = labelImage:getSize()
	
	self.moduleWidth = labelW +10
	self.moduleHeight = labelH + 10
	
	self:redraw(self.label)
	self:moveTo(xx, yy)
	self:add()
end

function ButtonMod:setLabel(label)
	self:redraw(label)
end

function ButtonMod:redraw(label)
	self.label = label
	
	local labelImage = gfx.imageWithText(self.label, maxLabelWidth, maxLabelHeight)
	local labelW, labelH = labelImage:getSize()
	
	self.moduleWidth = labelW + 20
	self.moduleHeight = labelH + 20
	
	local backgroundImage = generateButtonModBackground(self.moduleWidth,	self.moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	gfx.pushContext(backgroundImage)
	labelImage:draw((bgW-labelW)/2, (bgH - labelH)/2)
	gfx.popContext()
	
	self:setImage(backgroundImage)
end

function ButtonMod:type()
	return modType
end

function ButtonMod:getModId()
	return self.modId
end

function ButtonMod:getNavTarget()
	return self.navTarget
end

function ButtonMod:handleModClick(tX, tY, listener)
	
	
	self:moveBy(0, 2)
	playdate.timer.performAfterDelay(150, function() 
		self:moveBy(0, -2)
		if listener ~= nil then listener("nav") end
	end)
	-- self.menuListener = listener
	-- local actions = {
	-- 	{label = "About"},
	-- 	{label = "Edit"},
	-- 	{label = "Remove"}
	-- }
	-- local contextMenu = ModuleMenu(actions)
	-- contextMenu:show(function(action) 
	-- 	if action == "About" then
	-- 		local aboutPopup = ModAboutPopup("An on-screen label.")
	-- 		aboutPopup:show()
	-- 	elseif action == "Edit" then
	-- 		self.textInputScreen = TextInputScreen(self.label)
	-- 		gModularRunning = false
	-- 		self.textInputScreen:push("Edit label:", function(name)
	-- 			gModularRunning = true
	-- 			self:setLabel(name)
	-- 			self.textInputScreen = nil
	-- 		end)
	-- 	else
	-- 		if self.menuListener ~= nil then 
	-- 			self.menuListener(action) 
	-- 		end
	-- 	end
	-- end)
end

function ButtonMod:evaporate(onDetachConnected)
	self:remove()
end

function ButtonMod:collision(x, y)
	if x > self.x - (self.moduleWidth/2) and x < self.x + (self.moduleWidth/2) and y > self.y - (self.moduleHeight/2) and y < self.y + (self.moduleHeight/2) then
		return true
	else
		return false
	end	
end

function ButtonMod:tryConnectGhostOut(x, y, ghostCable)
	return false
end

function ButtonMod.ghostModule()
	return buildGhostModule(100, 40)
end

function ButtonMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	modState.label = self.label
	modState.navTarget = self.navTarget
	return modState
end

function ButtonMod:fromState(modState)
	self.navTarget = modState.navTarget
	self:redraw(modState.label)
end