print("ModularScreen import")
import 'Interface/reticle_sprite'
import 'Interface/map_sprite'
import 'Interface/module_popup'
import 'Interface/modal_dialog'

print("ModularScreen import: interface done")

import 'Modules/mod_utils'
import 'Modules/mod_about_popup'

print("ModularScreen import: modutils, mod about popup done")

import 'Modules/module_menu'
import 'Modules/module_manager'

print("ModularScreen import: mod menu, mod manager done")

import 'Coracle/math'
import 'Coracle/vector'
import 'CoracleViews/rotary_encoder'

print("ModularScreen import: Coracle done")

--Games
import 'Modules/Games/Pong/pong_mod'
import 'Modules/Games/GameOfLife/game_of_life_mod'

print("ModularScreen import: games done")


import 'Modules/Sprites/bang_sprite'
import 'Modules/Sprites/socket_sprite'

print("ModularScreen import: deprecated sprites done")

--Experimental
import 'Modules/Clocks/BouncingBallClock/bouncing_ball_clock_mod'

print("ModularScreen import: modules BouncingBall clock done")

--Sequencers
import 'Modules/Sequencers/DroneSequencer/drone_seq_mod'
import 'Modules/Sequencers/SequencerGrid/seq_grid_mod'
import 'Modules/Sequencers/Arpeggiator/arp_mod'
import 'Modules/Sequencers/RandomRepeater/random_repeater_mod'
import 'Modules/Sequencers/RandomShifter/random_shifter_mod'

print("ModularScreen import: modules sequencers done")

--Clock Mods
import 'Modules/Clocks/Merge2/merge2_mod'
import 'Modules/Clocks/Bifurcate2/bifurcate2_mod'
import 'Modules/Clocks/Bifurcate4/bifurcate4_mod'
import 'Modules/Clocks/Blackhole/blackhole_mod'
import 'Modules/Clocks/Clock2/clock2_mod'
import 'Modules/Clocks/ClockDelay/clock_delay_mod'
import 'Modules/Clocks/ClockDivider/clock_divider_mod'
import 'Modules/Clocks/ToClock/to_clock_mod'

print("ModularScreen import: modules clocks done")

--Drums
import 'Modules/Drums/DrumMachine/drum_mod'
import 'Modules/Drums/OR606/or606_mod'
import 'Modules/Drums/OR808/or808_mod'
import 'Modules/Drums/OR909/or909_mod'

print("ModularScreen import: modules drums done")



print("ModularScreen import: modules midigen done")

--Output/Mixers
import 'Modules/Mixers/Mixer1/mix1_mod'
import 'Modules/Mixers/Mixer1v2/mix1v2_mod'
import 'Modules/Mixers/Mixer4/mix4_mod'
import 'Modules/Mixers/Mixer4Sliders/mix4sliders_mod'


print("ModularScreen import: modules mixers done")


import 'Modules/Switches/Timed/timed_switch_mod'
import 'Modules/Switches/SwitchSPST/switch_mod'
import 'Modules/Switches/SwitchSPDT/switch_spdt_mod'

print("ModularScreen import: modules switches done")

--Synths
import 'Modules/Synths/MicroSynth/micro_synth_mod'
import 'Modules/Synths/NoiseBox/noise_box_mod'
import 'Modules/Synths/StochasticTriangle/stochastic_triangle_mod'
import 'Modules/Synths/StochasticSquare/stochastic_square_mod'
import 'Modules/Synths/StochasticSine/stochastic_sine_mod'
import 'Modules/Synths/OrlSynth/synth_mod'
import 'Modules/Synths/OrlSampleSynth/sample_synth_mod'
import 'Modules/Synths/WaveTableSynth/wavetable_synth_mod'
import 'Modules/Synths/WaveTableSynth2D/wavetable_synth2d_mod'
import 'Modules/Synths/WavetableHz/wavetable_hz_mod'

print("ModularScreen import: modules synths done")

--Samplers
import 'Modules/Samplers/Hexagram/hexagram_mod'
print("ModularScreen import samplers: hexagram done")

import 'Modules/Samplers/Sampler/sampler_mod'
print("ModularScreen import samplers: sampler done")

import 'Modules/Samplers/Looper/looper_mod'
print("ModularScreen import samplers: looper done")

import 'Modules/Samplers/SamplePlay/sample_play_mod'
print("ModularScreen import samplers: sample player done")

import 'Modules/Samplers/Granular/granular_mod'
print("ModularScreen import samplers: granular done")

print("ModularScreen import: modules samplers done")

import 'Modules/Midi/MidiGen/midi_gen_mod'
import 'Modules/Midi/MidiGenBouncyBall/midi_gen_bouncy_ball_mod'
import 'Modules/Midi/NormalisedToMidi/normalised_to_midi_mod'
import 'Modules/Midi/MidiKeyboard/midi_keyboard_mod'

print("ModularScreen import: modules midi done")

--UI
import 'Modules/UI/Keyboard/keyboard_mod'
import 'Modules/UI/Image/image_mod'
import 'Modules/UI/Arrow/arrow_mod'
import 'Modules/UI/Button/button_mod'
import 'Modules/UI/LabelRegular/label_mod'
import 'Modules/UI/LabelLarge/large_label_mod'
import 'Modules/UI/Print/print_module'

print("ModularScreen import: modules ui done")


import 'Modules/Serial/SerialMidiNoteInput/serial_in_mod'
import 'Modules/Serial/SerialClockInput/serial_clock_mod'
import 'Modules/Serial/SerialBang/serial_bang_mod'

print("ModularScreen import: modules pedal and serial in done")

import 'CoracleViews/rotary_encoder'

print("ModularScreen import: modules rotary encoder done")

class('ModularScreen').extends()

local gfx <const> = playdate.graphics

globalXDrawOffset = 800
globalYDrawOffset = 0

local modeStandard = 1
local modeGhostModule = 2

local globalScrollStep = 8
local smallScrollStep = 4
local modulePopup = nil

local isMovingMod = false
local movingMod = nil

function ModularScreen:init()
	ModularScreen.super.init(self)
	
	print("ModularScreen init()")
	
	self.showing = false
	self.allowScroll = true
	
	self.mode = modeStandard
	
	self.lastTopLevelMenuIndex = 1
	self.scale = 1
	
	
	self.modules = ModuleManager()
	
	print("ModularScreen init() module manager created")
	
	self.ghostSprite = nil--used when adding new modules
	
	--local backgroundTable = gfx.imagetable.new("Images/background-table-64-64")
	local backgroundTable = gfx.imagetable.new("Images/background_lite-table-64-64")
	self.tilemap = gfx.tilemap.new()
	self.tilemap:setImageTable(backgroundTable)
	self.tilemap:setSize(50,40)
	
	for y = 0,40 do
		for x = 0,50 do
			self.tilemap:setTileAtPosition(x,y,1)
		end
	end	
	
	self.backgroundSprite = gfx.sprite.new(self.tilemap)
	self.backgroundSprite:moveTo(0, 0)
	self.backgroundSprite:add()
		
	self.reticle = ReticleSprite()
	
	self:move()
	
	self.scrollhandled = false
	
	print("ModularScreen init() - done")
end

function ModularScreen:updateGranulars()
	self.modules:updateGranulars()
end

function ModularScreen:bang(bangId) self.modules:bang(bangId) end
function ModularScreen:mn(midiNote) self.modules:mn(midiNote) end
function ModularScreen:clock(beat) self.modules:clock(beat) end

function ModularScreen:new()
	local newDialog = ModalDialog("Discard unsaved changes")
	newDialog:show(function(confirm) 
		if confirm == true then
			gPatchPath = nil
			self.modules:deleteAll()
		end
	end)
end

function ModularScreen:loadPatch(path, overrideCheck)
	if path == nil then
		print("Can't load nil patch")
		return
	end
	if overrideCheck ~= nil and overrideCheck == true then
		gPatchPath = path
		self.modules:loadPatch(path, function(didScale) 
			self:move()
			if didScale then self:scaleChanged() end
		end)
	else
		local newDialog = ModalDialog("Discard unsaved changes")
		newDialog:show(function(confirm) 
			if confirm == true then
				gPatchPath = path
				self.modules:loadPatch(path, function(didScale) 
					self:move()
					if didScale then self:scaleChanged() end
				end)
			end
		end)
	end
	
end

function ModularScreen:saveCurrentPatch()
	self.modules:saveCurrent()
end

function ModularScreen:savePatch(name)
	if name == nil then return end
	print("Save Patch... " .. name)
	self.modules:savePatch(name)
end

function ModularScreen:deletePatch(patch)
	local newDialog = ModalDialog("Delete " .. patch, "(B) No", "(A) Yes")
	newDialog:show(function(confirm) 
		if confirm == true then
			gPatchPath = nil
			self.modules:deleteAll()
			playdate.file.delete(patch)
		end
	end)
end

--https://sdk.play.date/inside-playdate/#_querying_buttons_directly
function ModularScreen:push(patchPath, onFileMenu)
	self.onFileMenu = onFileMenu
	self.inputHandler = {
		
		cranked = function(change, acceleratedChange)
			self.scrollhandled = false
			self.didScale = false
			if playdate.buttonIsPressed(playdate.kButtonLeft) or playdate.buttonIsPressed(playdate.kButtonRight) then
				globalXDrawOffset += change
				self.scrollhandled = true
			end
			if playdate.buttonIsPressed(playdate.kButtonUp) or playdate.buttonIsPressed(playdate.kButtonDown) then
				globalYDrawOffset += change
				self.scrollhandled = true
			end
			
			if self.scrollhandled == false then
				local xLocation = (-1 * globalXDrawOffset) + 200
				local yLocation = (-1 * globalYDrawOffset) + 120
				if self.scale == 2 then
					xLocation = (-1 * globalXDrawOffset) + 100
					yLocation = (-1 * globalYDrawOffset) + 60
				end
				self.modules:handleCrankTurn(xLocation, yLocation, change)
			else
				if self.didScale == false then
					self:move()
				end
			end
		end,
		
		leftButtonUp = function() self:checkReticleLocation() end,
		rightButtonUp = function() self:checkReticleLocation() end,
		upButtonUp = function() self:checkReticleLocation() end,
		downButtonUp = function() self:checkReticleLocation() end,
		
		BButtonDown = function()
			if introTime then return end--do nothing if intro is displaying
			if self.mode == modeGhostModule then
				self.ghostSprite:remove()
				self.ghostSprite = nil
				self.mode = modeStandard
			else
				local xLocation = (-1 * globalXDrawOffset) + 200
				local yLocation = (-1 * globalYDrawOffset) + 120
				
				if self.scale == 2 then
					xLocation = (-1 * globalXDrawOffset) + 100
					yLocation = (-1 * globalYDrawOffset) + 60
				end
				
				if self.modules:collides(xLocation, yLocation) then
					self.modules:handleCableAt(xLocation, yLocation, function(message) 
						self:toast(message, 2000)
					end)
				elseif self.modules:ghostCableShowing() then
					self.modules:dropCable()
				else
					if self:noDirectionsPressed() then
						--toggle scale
						if playdate.display.getScale() ~= 1  then
							playdate.display.setScale(1)
							self:scaleChanged()
						elseif playdate.display.getScale() ~= 2 then
							playdate.display.setScale(2)
							self:scaleChanged()
						end
						
						self.didScale = true
					end
				end
			end
		end,
		
		AButtonUp = function()
			if introTime then return end--do nothing if intro is displaying
			local xLocation = (-1 * globalXDrawOffset) + 200
			local yLocation = (-1 * globalYDrawOffset) + 120
			
			if self.scale == 2 then
				xLocation = (-1 * globalXDrawOffset) + 100
				yLocation = (-1 * globalYDrawOffset) + 60
			end
			
			if self.mode == modeStandard then
				if self.modules:collides(xLocation, yLocation) then
					self:handleModClickUp(xLocation, yLocation)
				end
			end
		end,
		
		AButtonDown = function()
			if introTime then return end--do nothing if intro is displaying
				
			if isMovingMod then
				isMovingMod = false
				if movingMod.moveFinish ~= nil then
					movingMod:moveFinish()
					self.modules:finishMove(movingMod)
				end
				return
			end	
				
			local xLocation = (-1 * globalXDrawOffset) + 200
			local yLocation = (-1 * globalYDrawOffset) + 120
			
			if self.scale == 2 then
				xLocation = (-1 * globalXDrawOffset) + 100
				yLocation = (-1 * globalYDrawOffset) + 60
			end
			
			if self.mode == modeStandard then
				if self.modules:collides(xLocation, yLocation) then
					self:handleModClick(xLocation, yLocation)
				else
					modulePopup = ModulePopup()
					gScrollLock = true
					modulePopup:show(function(module, index) 
						if module.type ~= nil then
							if module.type == "checkbox" then
								if module.action == "prefs_show_fps" then
									gShowFPS = module.checked
									prefs:put("gShowFPS", gShowFPS)
								elseif module.action == "prefs_play_soundfx" then 
									gPlaySoundEffects = module.checked
									prefs:put("gPlaySoundEffects", gPlaySoundEffects)
								elseif module.action == "prefs_invert_display" then
									gInvertDisplay = module.checked
									playdate.display.setInverted(gInvertDisplay)
									prefs:put("gInvertDisplay", gInvertDisplay)
								else 
									print("Unimplemented checkbox action: " .. module.action)
								end
							end
							return
						end
						self.lastTopLevelMenuIndex = index
						gScrollLock = false
						print("Selected:::::: " .. module.action)
						if startswith(module.action, "setting_") then
							print("Set setting: " .. module.action)
							if module.action == "setting_new_file" then
								self:new()
							elseif module.action == "setting_load_file" then
								self.onFileMenu("load")
							elseif module.action == "setting_save_file" then
								if gPatchPath ~= nil then
									--overwrite
									self:saveCurrentPatch()
								else
									self.onFileMenu("saveas")
								end
							elseif module.action == "setting_saveas_file" then
								self.onFileMenu("saveas")
							elseif module.action == "setting_delete_file" then
								self:deletePatch(gPatchPath)	
							elseif module.action == "setting_screenshot" then
								self:screenshot()
							elseif module.action == "setting_show_map" then
								self:map()
							elseif module.action == "setting_open_tutorial" then
								self:loadPatch("_Introduction_1.orlam")
							end
							return
						end
						self.ghostModuleType = module.action
						self.ghostSprite = self.modules:getGhostSprite(module.action)
						if self.ghostSprite ~= nil then
							self.ghostSprite:setIgnoresDrawOffset(true)
							if self.scale == 1 then
								self.ghostSprite:moveTo(200, 120)
							elseif self.scale == 2 then
								self.ghostSprite:moveTo(100, 60)
							end
							
							self.ghostSprite:add()
							self.mode = modeGhostModule
						else
							-- just add for now
							print("No ghost - adding: " .. module.action)
							self.modules:addNewAt(module.action, xLocation, yLocation)
							self.mode = modeStandard
						end
					end, self.lastTopLevelMenuIndex, self.scale)
				end
			elseif self.mode == modeGhostModule then
				print("GHOST MOD TYPE " .. self.ghostModuleType)
				if self.ghostModuleType == "LabelMod" or self.ghostModuleType == "LargeLabelMod" or self.ghostModuleType == "ButtonMod" then
					self.textInputScreen = TextInputScreen()
					gModularRunning = false
					self.textInputScreen:push("Enter label:", function(name)
						self.ghostSprite:remove()
						self.ghostSprite = nil
						self.modules:addNewLabelAt(self.ghostModuleType, name, xLocation, yLocation)
						self.mode = modeStandard
						gModularRunning = true
						self.textInputScreen = nil
					end)
				else
					self.ghostSprite:remove()
					self.ghostSprite = nil
					self.modules:addNewAt(self.ghostModuleType, xLocation, yLocation)
					self.mode = modeStandard
					self:move()--force check for active module
				end
			end
		end
	}
	playdate.inputHandlers.push(self.inputHandler)
	self.showing = true
	
	if patchPath ~= nil then
		self:loadPatch(patchPath, true)
	end
end

function ModularScreen:scaleChanged()
	if playdate.display.getScale()  == 1 then
		self.reticle:moveTo(200, 120)
		self.scale = 1
		globalXDrawOffset += 100
		globalYDrawOffset += 60
		self:move()
	else
		self.reticle:moveTo(100, 60)
		self.scale = 2
		globalXDrawOffset -= 100
		globalYDrawOffset -= 60
		self:move()
	end
end

function ModularScreen:checkReticleLocation()
	local xLocation = (-1 * globalXDrawOffset) + 200
	local yLocation = (-1 * globalYDrawOffset) + 120
end

function ModularScreen:handleModClickUp(x, y)
	local module, moduleIndex = self.modules:moduleAt(x, y)
	if module.handleModClickUp ~= nil then
		module:handleModClickUp(x, y)
	end
end

function ModularScreen:handleModClick(x, y)
	local module, moduleIndex = self.modules:moduleAt(x, y)
	if module.type == "ButtonMod" then
		local destination = module:getDestination()
		print("Destination: " .. destination)
	elseif module.handleModClick ~= nil then
		module:handleModClick(x, y, function(action) 
				if action == "nav" then
					print("modular screen - get nav from mod and navigate")
					if module.getNavTarget ~= nil then 
						local navTarget = module:getNavTarget()
						if navTarget ~= nil then
							self:loadPatch(navTarget, true)
						else
							print("Nav target is NIL")
						end
					end
				elseif action == "Move" then
					-- ........ I LIKE TO MOVE IT MOVE IT
					isMovingMod = true
				  movingMod = module
					
					if module.movePrepare ~= nil then
						module.movePrepare()
					end
				elseif action == "Remove" then
					print("-------------------removing mod: " .. module:getModId())
					--todo modal confirmation
					if module.evaporate ~= nil then
						module:evaporate(function(moduleId, cableId)  
							--remove a cable from attached module
							local connectedMod = self.modules:getById(moduleId)
							
							if connectedMod ~= nil then
								print("Found mod: " .. connectedMod.modId)
								if connectedMod.unplug == nil then
									print("!!!!!!!!!!!!!!!!!!!!!!!!!!!! " .. connectedMod:type() .. " does NOT have unplug(cableId)")
								end
							end
							
							if connectedMod ~= nil and connectedMod.unplug ~= nil then 
								print("-------------------removing cable from connected mod: " .. connectedMod:getModId())
								connectedMod:unplug(cableId) 
							end
							
							--todo remove cable from array
							self.modules:removeCable(cableId)
						end)
						self.modules:removeEvaporatedModule(moduleIndex)
					else
						self:toast("Module " .. module.type() .. " does not have evaporate()")
					end
					--todo cleanup cables

				end
			end)
	else
		self:toast("No menu implemented for " .. module:type())
	end
end

function ModularScreen:toast(message, ms)
	if gSuppressToast then return end
	if ms == nil then
		ms = 2000
	end
	local toastSprite = gfx.sprite.spriteWithText(string.upper(message), 390, 10, playdate.graphics.kColorWhite)
	
	-- I don't know why but the above returns nil and crashes below if the save dialog is showing:
	if toastSprite == nil then return end
	
	toastSprite:moveTo(3 + (toastSprite.width/2), 240 - (toastSprite.height + 1))
	toastSprite:setIgnoresDrawOffset(true)
	toastSprite:add()
	playdate.timer.performAfterDelay(ms, function()  
		toastSprite:remove()
		toastSprite = nil
	end)
end

function ModularScreen:move()
	gfx.setDrawOffset(globalXDrawOffset, globalYDrawOffset)
	local xLocation = (-1 * globalXDrawOffset) + 200
	local yLocation = (-1 * globalYDrawOffset) + 120
	if self.scale == 2 then
		xLocation = (-1 * globalXDrawOffset) + 100
		yLocation = (-1 * globalYDrawOffset) + 60
	end
	self.modules:move(xLocation, yLocation)
	
	if playdate.getFPS() < 20 then
		smallScrollStep = 6
	else
		smallScrollStep = 4
	end
end

function ModularScreen:pop()
	playdate.inputHandlers.pop()
	self.showing = false
end

function ModularScreen:isShowing()
	return self.showing
end	

function ModularScreen:draw()
	if gMapShowing == true then 
		self.mapSprite:draw()
		return
	end
	if playdate.buttonIsPressed(playdate.kButtonLeft) then
		if gScrollLock == true then return end
		if isMovingMod then self.modules:moveModule(movingMod, -smallScrollStep, 0) end
		if playdate.buttonIsPressed(playdate.kButtonB) then
			globalXDrawOffset += globalScrollStep
		else
			globalXDrawOffset += smallScrollStep
		end
		
		self:move()
	elseif playdate.buttonIsPressed(playdate.kButtonRight) then
		if gScrollLock == true then return end
		if isMovingMod then self.modules:moveModule(movingMod, smallScrollStep, 0) end
		if playdate.buttonIsPressed(playdate.kButtonB) then
			globalXDrawOffset -= globalScrollStep
		else
			globalXDrawOffset -= smallScrollStep
		end
		
		self:move()
	end
		
	if playdate.buttonIsPressed(playdate.kButtonUp) then
		if gScrollLock == true then return end
		if isMovingMod then self.modules:moveModule(movingMod, 0, -smallScrollStep) end
		if playdate.buttonIsPressed(playdate.kButtonB) then
			globalYDrawOffset += globalScrollStep
		else
			globalYDrawOffset += smallScrollStep
		end
		
		self:move()
	elseif playdate.buttonIsPressed(playdate.kButtonDown) then
		if gScrollLock == true then return end
		if isMovingMod then self.modules:moveModule(movingMod, 0, smallScrollStep) end
		if playdate.buttonIsPressed(playdate.kButtonB) then
			globalYDrawOffset -= globalScrollStep
		else
			globalYDrawOffset -= smallScrollStep
		end
		self:move()
	end
end

function ModularScreen:noDirectionsPressed()
	if playdate.buttonIsPressed(playdate.kButtonUp)
	or playdate.buttonIsPressed(playdate.kButtonDown)
	or playdate.buttonIsPressed(playdate.kButtonLeft)
	or playdate.buttonIsPressed(playdate.kButtonRight) then
		return false
	else
		return true
	end
end

function ModularScreen:map()
	self.reticle:remove()
	self.modules:map(function(mapImage)
		self.reticle:add()
		if mapImage ~= nil then
			self.mapSprite = MapSprite(mapImage)
			self.mapSprite:show()
		end
	end)
end

function ModularScreen:screenshot()
	self.reticle:remove()
	self.modules:screenshot(function(filename)
		self.reticle:add()
		if filename == nil then
			self:toast("No patch to screenshot")
		else
			self:toast("" .. filename .. " saved")
		end
	end)
end
