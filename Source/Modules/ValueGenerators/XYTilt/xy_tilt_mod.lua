--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/ValueGenerators/XYTilt/xy_tilt_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'

class('XYTiltMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 120
local moduleHeight = 120

local modType = "XYTiltMod"
local modSubtype = SourceTypes.normalised_value

function XYTiltMod:init(xx, yy, modId)
	XYTiltMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
		
	
	self:moveTo(xx, yy)
	self:add()
	
	self.component = XYTiltComponent(function(xAxis, yAxis) 
		local xx = self.x + map(xAxis, -1.0, 1.0, -50, 50)
		--xx = math.max(self.x - 50, xx)
		--xx = math.min(self.x + 50, xx)
		self.xSprite:moveTo(xx, self.y)
		
		local yy = self.y + map(yAxis, -1.0, 1.0, -50, 50)
		--yy = math.max(self.y - 50, yy)
		--yy = math.min(self.y + 50, yy)
		self.ySprite:moveTo(self.x, yy)
		
		self.cSprite:moveTo(xx, yy)
	end)

	local encoderY = yy + 12
	
	self.xValue = 0.5
	self.yValue = 0.5
	
	local cImage = gfx.image.new("Images/step")
	self.cSprite = gfx.sprite.new(cImage)
	self.cSprite:moveTo(xx,yy)
	self.cSprite:add()
	
	local xImage = gfx.image.new(1, moduleHeight - 12, playdate.graphics.kColorBlack)
	self.xSprite = gfx.sprite.new(xImage)
	self.xSprite:moveTo(xx,yy)
	self.xSprite:add()
	
	local yImage = gfx.image.new(moduleWidth - 12, 1, playdate.graphics.kColorBlack)
	self.ySprite = gfx.sprite.new(yImage)
	self.ySprite:moveTo(xx,yy)
	self.ySprite:add()
	
	self:redrawBackground()

	self.socketXOutVector = Vector	(xx - (moduleHeight/2), yy -15)
	self.socketYOutVector = Vector	(xx - (moduleHeight/2), yy +15)
end

function XYTiltMod:redrawBackground()
	self.redrawPending = false
	gEncoder:hide()
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	
	gfx.pushContext(backgroundImage)
	
	local xyGrid = gfx.image.new("Images/xy_grid")
	xyGrid:draw(18,18)
		
	gfx.drawTextAligned("X",  21, bgH/2 - 18, kTextAlignment.center)
	gfx.drawTextAligned("Y",  21, bgH/2 + 10, kTextAlignment.center)
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, bgH/2 -20)
	leftSocket:draw(10, bgH/2 + 5)
		
	gfx.popContext()
	
	self:setImage(backgroundImage)
end

function XYTiltMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function XYTiltMod:setOutCable(patchCable)
	if self.component:outXConnected() == false then 
		self.outXCable = patchCable
		patchCable:setStart(self.socketXOutVector.x, self.socketXOutVector.y, self.modId)
		self.component:setOutXCable(patchCable:getCable())
	elseif self.component:outYConnected() == false then 
		self.outYCable = patchCable
		patchCable:setStart(self.socketYOutVector.x, self.socketYOutVector.y, self.modId)
		self.component:setOutYCable(patchCable:getCable())
		return true
	else
		return false
	end
	
end

function XYTiltMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function XYTiltMod:tryConnectGhostIn(x, y, ghostCable)
	return false
end

function XYTiltMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outXConnected() == false then 
		ghostCable:setStart(self.socketXOutVector.x, self.socketXOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	elseif self.component:outYConnected() == false then 
		ghostCable:setStart(self.socketYOutVector.x, self.socketYOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	else
		return false
	end
end

function XYTiltMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Outputs values from 0.0 to 1.0 along two axis as you tilt the Playdate. Fairly intensive so only use one per patch.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end
	
function XYTiltMod:type() return modType end
function XYTiltMod:getModId() return self.modId end
function XYTiltMod:removeChannel(channel) self.component:removeChannel(channel) end
function XYTiltMod:unplug(cableId) self.component:unplug(cableId) end
function XYTiltMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function XYTiltMod:evaporate(onDetachConnected)
	
	self.component:stop()
	
	if self.component:outXConnected() then
		onDetachConnected(self.outXCable:getEndModId(), self.outXCable:getCableId())
		self.component:unplugOutX()
		self.outXCable:evaporate()
	end
	
	if self.component:outYConnected() then
		onDetachConnected(self.outYCable:getEndModId(), self.outYCable:getCableId())
		self.component:unplugOutY()
		self.outYCable:evaporate()
	end
	
	self.cSprite:remove()
	self.xSprite:remove()
	self.ySprite:remove()
	
	self.cSprite = nil
	self.xSprite = nil
	self.ySprite = nil
		
	self:remove()
end

function XYTiltMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y

	return modState
end

function XYTiltMod:fromState(modState)
 --noop
end