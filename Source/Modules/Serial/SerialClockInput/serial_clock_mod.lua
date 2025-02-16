--[[
	© 2023 Orllewin - All Rights Reserved.
]]
import 'Modules/Serial/SerialClockInput/serial_clock_component'

class('SerialClockMod').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local usbImage = gfx.image.new("Images/usb")

local moduleWidth = 58
local moduleHeight = 85

local ledYStart = 50
local ledXStart = 25
local ledIncrement = 12
local ledDiam = 5

local modType = "SerialClockMod"
local modSubtype = "midi"

function SerialClockMod:init(xx, yy, modId)
	SerialClockMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.beat = 1
	
	self:redrawBackground()

	self:moveTo(xx, yy)
	self:add()
	
	self.socketOutVector = Vector(xx + moduleWidth/2, 	yy)
	
	self.component = SerialClockComponent(function(beat)
		print("self.component = SerialClockComponent(function(beat)" .. beat)
		self.beat = beat
		if beat == 1 then
			self:setImage(self.beat1Image)
		elseif beat == 2 then
			self:setImage(self.beat2Image)
		elseif beat == 3 then
			self:setImage(self.beat3Image)
		elseif beat == 4 then
			self:setImage(self.beat4Image)
		elseif beat == 5 then
			self:setImage(self.beat5Image)
		elseif beat == 6 then
			self:setImage(self.beat6Image)
		elseif beat == 7 then
			self:setImage(self.beat7Image)
		elseif beat == 8 then
			self:setImage(self.beat8Image)
		elseif beat == 9 then
			self:setImage(self.beat9Image)
		elseif beat == 10 then
			self:setImage(self.beat10Image)
		elseif beat == 11 then
			self:setImage(self.beat11Image)
		elseif beat == 12 then
			self:setImage(self.beat12Image)
		elseif beat == 13 then
			self:setImage(self.beat13Image)
		elseif beat == 14 then
			self:setImage(self.beat14Image)
		elseif beat == 15 then
			self:setImage(self.beat15Image)
		elseif beat == 16 then
			self:setImage(self.beat16Image)
		end
	end)
end

function SerialClockMod:clock(beat)
	self.component:clock(beat)
end

function SerialClockMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function SerialClockMod:redrawBackground()
	self.backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = self.backgroundImage:getSize()
	
	gfx.pushContext(self.backgroundImage)
		
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(bgW - 16, bgH/2 - 8)
	--gfx.drawTextAligned("WIP", bgW/2, bgH/2 - 15, kTextAlignment.center)
	--gfx.drawTextAligned("Midi in", bgW/2, bgH/2, kTextAlignment.center)
	
	usbImage:drawScaled(30, 22, 0.5)
	
		
	gfx.popContext()

	self.beat0Image = self.backgroundImage:copy()
	gfx.pushContext(self.beat0Image)
	gfx.setColor(gfx.kColorBlack) 
	gfx.drawCircleAtPoint(ledXStart, ledYStart, ledDiam)
	gfx.drawCircleAtPoint(ledXStart + ledIncrement, ledYStart, ledDiam)
	gfx.drawCircleAtPoint(ledXStart + (ledIncrement * 2), ledYStart, ledDiam)
	gfx.drawCircleAtPoint(ledXStart + (ledIncrement * 3), ledYStart, ledDiam)
	
	gfx.drawCircleAtPoint(ledXStart, ledYStart + ledIncrement, ledDiam)
	gfx.drawCircleAtPoint(ledXStart + ledIncrement, ledYStart + ledIncrement, ledDiam)
	gfx.drawCircleAtPoint(ledXStart + (ledIncrement * 2), ledYStart + ledIncrement, ledDiam)
	gfx.drawCircleAtPoint(ledXStart + (ledIncrement * 3), ledYStart + ledIncrement, ledDiam)
	
	gfx.drawCircleAtPoint(ledXStart, ledYStart + (ledIncrement * 2), ledDiam)
	gfx.drawCircleAtPoint(ledXStart + ledIncrement, ledYStart + (ledIncrement * 2), ledDiam)
	gfx.drawCircleAtPoint(ledXStart + (ledIncrement * 2), ledYStart  + (ledIncrement * 2), ledDiam)
	gfx.drawCircleAtPoint(ledXStart + (ledIncrement * 3), ledYStart  + (ledIncrement * 2), ledDiam)
	
	gfx.drawCircleAtPoint(ledXStart, ledYStart + (ledIncrement * 3), ledDiam)
	gfx.drawCircleAtPoint(ledXStart + ledIncrement, ledYStart + (ledIncrement * 3), ledDiam)
	gfx.drawCircleAtPoint(ledXStart + (ledIncrement * 2), ledYStart  + (ledIncrement * 3), ledDiam)
	gfx.drawCircleAtPoint(ledXStart + (ledIncrement * 3), ledYStart  + (ledIncrement * 3), ledDiam)
	gfx.popContext()
	self:setImage(self.beat0Image)
	
	self.beat1Image = self.beat0Image:copy()
	gfx.pushContext(self.beat1Image)
	gfx.setColor(gfx.kColorBlack) 
	gfx.fillCircleAtPoint(ledXStart, ledYStart, ledDiam)
	gfx.popContext()
	
	self.beat2Image = self.beat1Image:copy()
	gfx.pushContext(self.beat2Image)
	gfx.setColor(gfx.kColorBlack) 
	gfx.fillCircleAtPoint(ledXStart + ledIncrement, ledYStart, ledDiam)
	gfx.popContext()
	
	self.beat3Image = self.beat2Image:copy()
	gfx.pushContext(self.beat3Image)
	gfx.setColor(gfx.kColorBlack) 
	gfx.fillCircleAtPoint(ledXStart + (ledIncrement * 2), ledYStart, ledDiam)
	gfx.popContext()
	
	self.beat4Image = self.beat3Image:copy()
	gfx.pushContext(self.beat4Image)
	gfx.setColor(gfx.kColorBlack) 
	gfx.fillCircleAtPoint(ledXStart + (ledIncrement * 3), ledYStart, ledDiam)
	gfx.popContext()
	
	self.beat5Image = self.beat4Image:copy()
	gfx.pushContext(self.beat5Image)
	gfx.setColor(gfx.kColorBlack) 
	gfx.fillCircleAtPoint(ledXStart, ledYStart + ledIncrement, ledDiam)
	gfx.popContext()
	
	self.beat6Image = self.beat5Image:copy()
	gfx.pushContext(self.beat6Image)
	gfx.setColor(gfx.kColorBlack) 
	gfx.fillCircleAtPoint(ledXStart + ledIncrement, ledYStart + ledIncrement, ledDiam)
	gfx.popContext()
	
	self.beat7Image = self.beat6Image:copy()
	gfx.pushContext(self.beat7Image)
	gfx.setColor(gfx.kColorBlack) 
	gfx.fillCircleAtPoint(ledXStart + (ledIncrement * 2), ledYStart + ledIncrement, ledDiam)
	gfx.popContext()
	
	self.beat8Image = self.beat7Image:copy()
	gfx.pushContext(self.beat8Image)
	gfx.setColor(gfx.kColorBlack) 
	gfx.fillCircleAtPoint(ledXStart + (ledIncrement * 3), ledYStart + ledIncrement, ledDiam)
	gfx.popContext()
	
	self.beat9Image = self.beat8Image:copy()
	gfx.pushContext(self.beat9Image)
	gfx.setColor(gfx.kColorBlack) 
	gfx.fillCircleAtPoint(ledXStart, ledYStart + (ledIncrement * 2), ledDiam)
	gfx.popContext()
	
	self.beat10Image = self.beat9Image:copy()
	gfx.pushContext(self.beat10Image)
	gfx.setColor(gfx.kColorBlack) 
	gfx.fillCircleAtPoint(ledXStart + ledIncrement, ledYStart + (ledIncrement * 2), ledDiam)
	gfx.popContext()
	
	self.beat11Image = self.beat10Image:copy()
	gfx.pushContext(self.beat11Image)
	gfx.setColor(gfx.kColorBlack) 
	gfx.fillCircleAtPoint(ledXStart + (ledIncrement * 2), ledYStart  + (ledIncrement * 2), ledDiam)
	gfx.popContext()
	
	self.beat12Image = self.beat11Image:copy()
	gfx.pushContext(self.beat12Image)
	gfx.setColor(gfx.kColorBlack) 
	gfx.fillCircleAtPoint(ledXStart + (ledIncrement * 3), ledYStart  + (ledIncrement * 2), ledDiam)
	gfx.popContext()
	
	self.beat13Image = self.beat12Image:copy()
	gfx.pushContext(self.beat13Image)
	gfx.setColor(gfx.kColorBlack) 
	gfx.fillCircleAtPoint(ledXStart, ledYStart + (ledIncrement * 3), ledDiam)
	gfx.popContext()
	
	self.beat14Image = self.beat13Image:copy()
	gfx.pushContext(self.beat14Image)
	gfx.setColor(gfx.kColorBlack) 
	gfx.fillCircleAtPoint(ledXStart + ledIncrement, ledYStart + (ledIncrement * 3), ledDiam)
	gfx.popContext()
	
	self.beat15Image = self.beat14Image:copy()
	gfx.pushContext(self.beat15Image)
	gfx.setColor(gfx.kColorBlack) 
	gfx.fillCircleAtPoint(ledXStart + (ledIncrement * 2), ledYStart  + (ledIncrement * 3), ledDiam)
	gfx.popContext()
	
	self.beat16Image = self.beat15Image:copy()
	gfx.pushContext(self.beat16Image)
	gfx.setColor(gfx.kColorBlack) 
	gfx.fillCircleAtPoint(ledXStart + (ledIncrement * 3), ledYStart  + (ledIncrement * 3), ledDiam)
	gfx.popContext()
end

function SerialClockMod:setOutCable(patchCable)
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.outCable = patchCable
	self.component:setOutCable(patchCable:getCable())
end

function SerialClockMod:type() return modType end
function SerialClockMod:getModId() return self.modId end
function SerialClockMod:tryConnectGhostIn(x, y, ghostCable) return false end
function SerialClockMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end
function SerialClockMod:unplug(cableId) self.component:unplug(cableId) end

function SerialClockMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function SerialClockMod:moveFinish()
	self.socketOutVector = Vector(self.x + moduleWidth/2, self.y)
end

function SerialClockMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
	
	self:remove()
end

function SerialClockMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function SerialClockMod:handleModClick(tX, tY, listener)
	self.menuListener = listener
	local actions = nil
	
	actions = {
		{label = "About"},
		{label = "Move"},
		{label = "Remove"}
	}
	 
	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action) 
		if action == "About" then
			local aboutPopup = ModAboutPopup("Midi note input - requires Midi Bus project running on a computer, see website for more details.")
			aboutPopup:show()
		else
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		end
	end)
end

function SerialClockMod:evaporate(onDetachConnected)
	--first detach cables
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end

	self:remove()
end
	