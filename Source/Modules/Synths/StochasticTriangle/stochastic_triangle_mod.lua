--[[

]]--
import 'Modules/mod_utils.lua'
import 'Modules/Synths/StochasticTriangle/stochastic_triangle_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'

class('StochasticTriMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local moduleWidth = 50
local moduleHeight = 50

local triangleImage = playdate.graphics.image.new("Images/triangle")

local modType = "StochasticTriMod"
local modSubtype = SourceTypes.audio_gen

function StochasticTriMod:init(xx, yy, modId, onInit)
	StochasticTriMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.onInit = onInit
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.menuIndex = 1
		
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	gfx.pushContext(backgroundImage)
	
	triangleImage:draw(26, 27)
	
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 32)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(62, 32)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self:moveTo(xx, yy)
	self:add()
		
	self.component = StochasticTriangleComponent(function(channel)
			self.onInit(self.modId, channel)
		end)
		
	self.socketInVector = Vector(xx - 25, yy + 8)
	self.socketOutVector = Vector(xx + 25, yy + 8)
end

function StochasticTriMod:setInCable(patchCable)
	patchCable:setEnd(self.socketInVector.x, self.socketInVector.y, self.modId)
	self.inCable = patchCable
	self.component:setInCable(patchCable:getCable())
end

function StochasticTriMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function StochasticTriMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function StochasticTriMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype, onError)
	if sourceSubtype ~= "clock_router" then 
		if onError ~= nil then onError("This input requires a clock signal") end
		return false 
	elseif ghostCable:getStartModId() == self.modId then
		print("Can't connect a mod to itself...")
		return false
	elseif self.component:inConnected() then
		return false
	else
		ghostCable:setEnd(self.socketInVector.x, self.socketInVector.y)
		ghostCable:setGhostReceiveConnected()
		return true
	end
end

function StochasticTriMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function StochasticTriMod:type()
	return modType
end

function StochasticTriMod:getModId()
	return self.modId
end

function StochasticTriMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = {
		{label = "About"},
		{label = "Pitch Up"},
		{label = "Pitch Down"},
		{label = "Remove"}
	}
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action, index) 
		self.menuIndex = index
		if action == "About" then
			local aboutPopup = ModAboutPopup("A special synth that only needs a clock input. Internally the module includes the same features as Clock Delay, Blackhole, random number, number to midi, a triangle wave synth, and a delay.")
			aboutPopup:show()
		elseif action == "Pitch Up" then
			self.component:pitchUp()
		elseif action == "Pitch Down" then
			self.component:pitchDown()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end, self.menuIndex)
end

function StochasticTriMod:unplug(cableId)
	self.component:unplug(cableId)
end

function StochasticTriMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function StochasticTriMod:moveFinish()
	self.socketInVector = Vector(self.x - 25, self.y + 8)
	self.socketOutVector = Vector(self.x + 25, self.y + 8)
end

function StochasticTriMod:evaporate(onDetachConnected)
	--first stop any notes playing:
	self.component:stopAll()
	
	--first detach cables
	if self.component:inConnected() then
		onDetachConnected(self.inCable:getStartModId(), self.inCable:getCableId())
		self.component:unplugIn()
		self.inCable:evaporate()
	end
	
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end

	--then remove sprites
	playdate.graphics.sprite.removeSprites({self.waveformSprite})
	self:remove()
end

function StochasticTriMod.ghostModule()
	return buildGhostModule(moduleWidth, moduleHeight)
end

function StochasticTriMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y	
	return modState
end

function StochasticTriMod:fromState(modState)
	--noop
end