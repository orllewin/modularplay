--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'Modules/ValueGenerators/YTilt/y_tilt_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'

class('YTiltMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 120
local moduleHeight = 40

local modType = "YTiltMod"
local modSubtype = SourceTypes.normalised_value

function YTiltMod:init(xx, yy, modId)
	YTiltMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
		
	self:moveTo(xx, yy)
	self:add()
	
	self.component = YTiltComponent(function(yAxis) 		
		local xx = self.x + map(yAxis, -1.0, 1.0, -50, 50)
		self.ySprite:moveTo(xx, self.y)
		self.cSprite:moveTo(xx, yy)
	end)

	local encoderY = yy + 12
	
	self.yValue = 0.5
	
	local cImage = gfx.image.new("Images/step")
	self.cSprite = gfx.sprite.new(cImage)
	self.cSprite:moveTo(xx,yy)
	self.cSprite:add()
		
	local yImage = gfx.image.new(1, 32, playdate.graphics.kColorBlack)
	self.ySprite = gfx.sprite.new(yImage)
	self.ySprite:moveTo(xx,yy)
	self.ySprite:add()
	
	self:redrawBackground()

	self.socketYOutVector = Vector	(xx - (moduleWidth/2), yy)
end

function YTiltMod:redrawBackground()
	self.redrawPending = false
	gEncoder:hide()
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	
	gfx.pushContext(backgroundImage)
	
	local xyGrid = gfx.image.new("Images/y_grid")
	xyGrid:draw(18,21)
		
	gfx.drawTextAligned("Y",  21, bgH/2 - 3, kTextAlignment.center)

	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, bgH/2 - 8)
		
	gfx.popContext()
	
	self:setImage(backgroundImage)
end

function YTiltMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function YTiltMod:setOutCable(patchCable)
	if self.component:outYConnected() == false then 
		self.outYCable = patchCable
		patchCable:setStart(self.socketYOutVector.x, self.socketYOutVector.y, self.modId)
		self.component:setOutYCable(patchCable:getCable())
		return true
	else
		return false
	end
	
end

function YTiltMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function YTiltMod:tryConnectGhostIn(x, y, ghostCable)
	return false
end

function YTiltMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outYConnected() == false then 
		ghostCable:setStart(self.socketYOutVector.x, self.socketYOutVector.y, self.modId)
		ghostCable:setGhostSendConnected()
		return true
	else
		return false
	end
end

function YTiltMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Outputs values from 0.0 to 1.0 along one axis as you tilt the Playdate. Fairly intensive so only use one per patch.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end
	
function YTiltMod:type() return modType end
function YTiltMod:getModId() return self.modId end
function YTiltMod:removeChannel(channel) self.component:removeChannel(channel) end
function YTiltMod:unplug(cableId) self.component:unplug(cableId) end
function YTiltMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function YTiltMod:repositionBy(x, y)
	self:moveBy(x, y)
	self.cSprite:moveBy(x, y)
	self.ySprite:moveBy(x, y)
end

function YTiltMod:moveFinish()
	self.socketYOutVector = Vector(self.x - (moduleWidth/2), self.y)
end

function YTiltMod:evaporate(onDetachConnected)
	
	self.component:stop()
		
	if self.component:outYConnected() then
		onDetachConnected(self.outYCable:getEndModId(), self.outYCable:getCableId())
		self.component:unplugOutY()
		self.outYCable:evaporate()
	end
	
	self.cSprite:remove()
	self.ySprite:remove()
	
	self.cSprite = nil
	self.ySprite = nil
		
	self:remove()
end

function YTiltMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y
	
	return modState
end

function YTiltMod:fromState(modState)
 --noop
end