import 'Interface/main_menu_factory'
import 'CoracleViews/text_list'

class('ModulePopup').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local width = 175
local height = 122

function ModulePopup:init()
	ModulePopup.super.init(self)
	
	self.menuFactory = MainMenuFactory()
	
	self.crankDelta = 0.0
	
	local backgroundImage = generateModBackgroundWithShadow(width, height)
	local bgW, bgH = backgroundImage:getSize()	
	self:setIgnoresDrawOffset(true)
	self:setZIndex(gModuleMenuZ)
	self:setImage(backgroundImage)
	self:moveTo(295, 175)
	
	self.selectedSamplePlayer = playdate.sound.sampleplayer.new("Samples/ui_blip")
end

function ModulePopup:show(onSelect, selectedIndex, scale)
	self:add()
	
	self.topLevelIndex = selectedIndex
	
	if scale ~= nil then
		if scale == 1 then
			self:moveTo(305, 170)
		elseif scale == 2 then
			self:moveTo(100, 60)
		end
	end
	
	self.mods = self.menuFactory:getMenuModList()
	
	self.moduleList = TextList(self.mods, self.x - width/2 + 8, self.y - height/2 + 8, width - 16, height-2, 18, nil, function(index, item)
		if item.category ~= nil then
			print("Selected " .. item.category)
			self.topLevelIndex = index
			self:updateCategory(item)
			self:playSelectedSound()
		else
			if item.type == "checkbox" then
				self:playSelectedSound()
				onSelect(item, self.topLevelIndex)
			else
				print("Mod Selected: " .. item.label .. " action: " .. item.action)
				self:playSelectedSound()
				self:dismiss()
				playdate.timer.performAfterDelay(100, function() 
					onSelect(item, self.topLevelIndex)
				end)
			end
			
		end

	end, gModuleMenuZ + 1)
	
	self:setSelected(selectedIndex)
	
	self.modulePopupInputHandler = {
		
		BButtonDown = function()
			gScrollLock = false
			self:dismiss()
		end,
		
		AButtonDown = function()
			self.moduleList:tapA()
		end,
		
		leftButtonDown = function()
	
		end,
		
		rightButtonDown = function()
	
		end,
		
		upButtonDown = function()
			self.moduleList:goUp()
		end,
		
		downButtonDown = function()
			self.moduleList:goDown()
		end,
		
		cranked = function(change, acceleratedChange)
			self.crankDelta += change
			if self.crankDelta < -20 then
				self.crankDelta = 0.0
				self.moduleList:goUp()
			elseif self.crankDelta > 20 then
				self.crankDelta = 0.0
				self.moduleList:goDown()
			end
		end,
	}
	playdate.inputHandlers.push(self.modulePopupInputHandler)
end

function ModulePopup:updateCategory(category)
	self.moduleList:updateItems(category.mods)
end

-- turned off doesn't sounds quite right, needs different sample
function ModulePopup:playSelectedSound()
	if gPlaySoundEffects then
		-- local rate = math.random(5, 12)/10.0
		-- self.selectedSamplePlayer:setRate(rate)
		-- self.selectedSamplePlayer:play()
	end
end

function ModulePopup:setSelected(index)
	self.moduleList:setSelected(index)
end

function ModulePopup:dismiss()
	print("ModulePopup:dismiss()")
	playdate.inputHandlers.pop()
	self.moduleList:removeAll()
	self:remove()
end