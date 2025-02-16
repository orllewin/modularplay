print("8888ba.88ba                 dP          dP")                
print("88  '8b  '8b                88          88")                 
print("88   88   88 .d8888b. .d888b88 dP    dP 88 .d8888b. 88d888b.") 
print("88   88   88 88'  '88 88'  '88 88    88 88 88'  '88 88'  '88") 
print("88   88   88 88.  .88 88.  .88 88.  .88 88 88.  .88 88")       
print("dP   dP   dP '88888P' '88888P8 '88888P' dP '88888P8 dP") 
print("")
print(" 888888ba  dP  ")                  
print(" 88    `8b 88  ")                  
print("a88aaaa8P' 88 .d8888b. dP    dP ") 
print(" 88        88 88'  `88 88    88 ") 
print(" 88        88 88.  .88 88.  .88 ") 
print(" dP        dP `88888P8 `8888P88 ") 
print("                            .88 ") 
print("                       d8888P ") 
print("")
print("> importing dependencies...")

-- Playdate API
import 'CoreLibs/object'
import 'CoreLibs/frameTimer'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'
import 'CoreLibs/animator'

print("> import: main playdate api done")

import 'Coracle/vector'
import 'CoracleViews/block'
import 'CoracleViews/divider_horizontal'
import 'CoracleViews/rotary_encoder'
import 'CoracleViews/vertical_slider'

print("> import: coracle done")

import 'AudioIn/audio_source'
import 'Audio/orl_sample'

print("> import: audio source and orlsample done")

import 'assets'
import 'prefs'
import 'logger'
import 'global'

print("> import: assets, prefs, logger, global done")

-- Core
import 'Core/event'
import 'Core/socket'
import 'Core/source_types'
import 'Core/patch_cable'

print("> import: core done")

import 'Interface/text_input_screen'

print("> import: text input done")

-- MODULES
-- Modules - normalised value generators
import 'Modules/ValueGenerators/Oscillator/oscillator_mod' 
import 'Modules/ValueGenerators/Oscillator2/oscillator2_mod' 
import 'Modules/ValueGenerators/Random/random_mod'
import 'Modules/ValueGenerators/XYTilt/xy_tilt_mod'
import 'Modules/ValueGenerators/YTilt/y_tilt_mod'
print("> import: value generator modules done")

-- Modules - Pedals (mostly effects)
import 'Modules/Pedals/Bitcrusher/bitcrusher_mod'
import 'Modules/Pedals/Delay/delay_mod'
import 'Modules/Pedals/Highpass/highpass_mod'
import 'Modules/Pedals/Lowpass/lowpass_mod'
import 'Modules/Pedals/OnePoleFilter/one_pole_filter_mod'
import 'Modules/Pedals/Overdrive/overdrive_mod'
import 'Modules/Pedals/RingModulator/ring_modulator_mod'
import 'Modules/Pedals/Pedal/pedal_mod'

print("> import: effects modules done")

print("ModularScreen import: tilt mods done")

-- Components
import 'Interface/modular_screen'

print("> import: main modular screen done")

print("> imports finished")
print("----------------------------------")

local gfx <const> = playdate.graphics

print("> initialising assets, prefs, logger")

--Global
assets = Assets()
prefs = Prefs()
log = Logger()

print("> reading prefs")
gShowFPS = prefs:get("gShowFPS", false)
gPlaySoundEffects = prefs:get("gPlaySoundEffects", false)
gInvertDisplay = prefs:get("gInvertDisplay", true)
playdate.display.setInverted(gInvertDisplay)


print("> setting font")
local font = gfx.font.new("Fonts/parodius_ext")
gfx.setFont(font)

print("> initialising AudioSource")
local audioSource = AudioSource()


print("> initialising global encoders")
--These are used everywhere, so keep as global:
gEncoder = RotaryEncoder(10000, 10000, nil)
gEncoder:setZIndex(28888)--below reticle
gEncoder:show()

gSlider = VerticalSlider(10000, 10000, 0.0, nil)
gSlider:setZIndex(28888)--below reticle
gSlider:show()

print("> initialising screens and menu")
--Main Screen:
local textInputScreen = nil
local modularScreen = ModularScreen()

local inverted = false
local menu = playdate.getSystemMenu()

print("> setting menu image")
playdate.setCrankSoundsDisabled(true)
playdate.setMenuImage(gfx.image.new("Images/menu_poster_image"), 100)

print("> checking 'Recorded' dir")
if playdate.file.isdir("Recorded") == false then
	playdate.file.mkdir("Recorded")	
end

function load()
	print("OPENING")
	--todo - show chooser
	local patchFiles = {}
	local files = playdate.file.listFiles()
	for f=1, #files do
		local file = files[f]	
		print("Load: inspecting file: " .. file)
		if endswith(file, ".orlam") and not startswith(file, "_") then
			local patchFile = {
				label="".. replace(file, ".orlam", ""),
				file=file
			}
			table.insert(patchFiles, patchFile)
			print("Found patch: " .. file)
		end
	end
	
	for f=1,#patchFiles do
		print("file " .. f ..": " .. patchFiles[f].label)
	end
	
	if #patchFiles > 0 then
		local dividerMenuItem = {
			label="--------------",
			file=nil
		}
		table.insert(patchFiles, dividerMenuItem)
	end
	
	local zoomPatch = {
		label="Zoom Hint",
		file="_Zoom_Hint.orlam"
	}
	table.insert(patchFiles, zoomPatch)
	
	local wavesPatch = {
		label="Stormy Wind",
		file="_Wind.orlam"
	}
	table.insert(patchFiles, wavesPatch)
	
	local bedtimePatch = {
		label="Bedtime noise",
		file="_Bedtime.orlam"
	}
	table.insert(patchFiles, bedtimePatch)
	
	local melodicPatch = {
		label="Dorian Melodic",
		file="_Melodic.orlam"
	}
	table.insert(patchFiles, melodicPatch)
	
	
	local samplerPatch = {
		label = "Sampler",
		file = "_Sampler.orlam"
	}
	table.insert(patchFiles, samplerPatch)
	
	local droneScapePatch = {
		label="Drone",
		file="_DroneScape.orlam"
	}
	table.insert(patchFiles, droneScapePatch)
	
	local hexagramPatch = {
		label="Hexagram",
		file="_Hexagram.orlam"
	}
	table.insert(patchFiles, hexagramPatch)
	
	local pongPatch = {
		label="Pong",
		file="_Pong.orlam"
	}
	table.insert(patchFiles, pongPatch)
		
	local loadPatchMenu = ModuleMenu(patchFiles)
	loadPatchMenu:show(function(selected, index) 
		if modularScreen:isShowing() then	modularScreen:loadPatch(patchFiles[index].file) end
	end, 1)	
end

print("Adding 'map' menu item")
menu:addMenuItem("Map", function() 
	print("MAP MENU")
	if modularScreen:isShowing() then modularScreen:map() end
end)

function save()
	textInputScreen = TextInputScreen()
	gModularRunning = false
	textInputScreen:push("Enter patch name:", function(name)
		if modularScreen:isShowing() then	modularScreen:savePatch(name) end
		gModularRunning = true
		textInputScreen = nil
	end)
end

print("Checking first run")
if prefs:get("firstRun") == nil then
	--first run, show tutorial
	prefs:put("firstRun", false)
	modularScreen:push(gIntroPatch, function(action) 
		if action ~= nil and action == "load" then
			load()
		elseif action ~= nil and action == "saveas" then
			save()
		end
	end)
else
	print("Not first run - pushing main screen")
	modularScreen:push(gStartPatch, function(action) 
		if action ~= nil and action == "load" then
			load()
		elseif action ~= nil and action == "saveas" then
			save()
		end
	end)
end

print("Importing intro")
import 'intro'
local intro = Intro()
local showIntro = gShowIdent
introTime = true --global
local fadeInTime = false

if showIntro then
	local identPlayer = playdate.sound.fileplayer.new("Audio/ident")
	identPlayer:setVolume(0.35)
	identPlayer:play()
end

local duration = 1500
local animator = nil
local blackImage = playdate.graphics.image.new(400, 240, playdate.graphics.kColorWhite)
local fadetoImage = nil

if showIntro then
	playdate.timer.performAfterDelay(3500, function() 
		introTime = false
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
		fadeInTime = true
		animator = playdate.graphics.animator.new(duration, 100,0)
	end)
else
	introTime = false
	playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
end
	
function playdate.serialMessageReceived(msg)
	if startswith(msg, "m") then
		mn(tonumber(msg:sub(2)))
	elseif startswith(msg, "c") then
		clock(tonumber(msg:sub(2)))
	elseif startswith(msg, "b") then
		bang(tonumber(msg:sub(2)))
	end
end

function bang(bangId)
	if modularScreen ~= nil and modularScreen:isShowing() then	modularScreen:bang(bangId) end
end

function mn(midiNote)
	if modularScreen ~= nil and modularScreen:isShowing() then	modularScreen:mn(midiNote) end
end

function clock(beat)
	if modularScreen ~= nil and modularScreen:isShowing() then	modularScreen:clock(beat) end
end

local updateLogged = false

function playdate.update()	
	if updateLogged == false then
		print("playdate.update() - start")
	end
	playdate.timer.updateTimers()
	playdate.frameTimer.updateTimers()
	playdate.graphics.sprite.update()
	
	if gModularRunning == false then return end
	if textInputScreen == nil then
		if modularScreen ~= nil and modularScreen:isShowing() then	modularScreen:draw() end
	else
		if textInputScreen:isShowing() == false then
			if modularScreen ~= nil and modularScreen:isShowing() then	modularScreen:draw() end
		end
	end
	
	if showIntro and introTime then intro:update() end
	
	if fadeInTime then
		local xx = (-1 * globalXDrawOffset) 
		local yy = (-1 * globalYDrawOffset) 
		alpha = animator:currentValue()
		blackImage:drawFaded(xx, yy, alpha/100.0, playdate.graphics.image.kDitherTypeBayer8x8)
		if alpha == 0 then fadeInTime = false end
	end
	
	if gShowFPS then
		playdate.drawFPS(5, 5)
	end
	
	if gHexagramRunning then
		if audioSource:isRecording() == false then
			audioSource:recordSample()
		end
	end
	
	if updateLogged == false then
		print("playdate.update() - end")
		updateLogged = true
	end
end