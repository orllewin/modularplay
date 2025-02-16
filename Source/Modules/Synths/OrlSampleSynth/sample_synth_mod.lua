--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'Modules/Synths/OrlSampleSynth/sample_synth_component'
import 'Modules/mod_about_popup'
import 'Modules/module_menu'
import 'Coracle/math'

class('SampleSynthMod').extends(playdate.graphics.sprite)

local curveImage = playdate.graphics.image.new("Images/envelope_curve")

-- todo append recorded samples to a special category:  - so users can use recorded samples as synths
local sampleSynths = {
	{
		label = "Minimal >",
		category = "minimal",
		actions = {
			{
				label = "Sine 1",
				path = "Samples/pcm/minimal/sine_1"
			},
			{
				label = "Sine 2",
				path = "Samples/pcm/minimal/sine_2"
			},
			{
				label = "Sine 3",
				path = "Samples/pcm/minimal/sine_3"
			},
			{
				label = "Sine Glide",
				path = "Samples/pcm/minimal/sine_glide"
			},
			{
				label = "Saw 1",
				path = "Samples/pcm/minimal/saw_1"
			},
			{
				label = "Saw Vibrato",
				path = "Samples/pcm/minimal/saw_vibrato"
			},
			{
				label = "Square 1",
				path = "Samples/pcm/minimal/square_1"
			},
			{
				label = "Square 2",
				path = "Samples/pcm/minimal/square_2"
			},
		}
	},
	{
		label = "Combi >",
		category = "combi",
		actions = {
			{
				label = "Orl Combi 1",
				path = "Samples/pcm/combi/orl_combi_1"
			},
			{
				label = "Orl Combi 2",
				path = "Samples/pcm/combi/orl_combi_2"
			},
			{
				label = "Orl Combi 3",
				path = "Samples/pcm/combi/orl_combi_3"
			},
			{
				label = "Orl Combi 4",
				path = "Samples/pcm/combi/orl_combi_4"
			},
			{
				label = "Orl Combi 5",
				path = "Samples/pcm/combi/orl_combi_5"
			},
			{
				label = "Orl Combi 6",
				path = "Samples/pcm/combi/orl_combi_6"
			},
			{
				label = "Orl Combi 7",
				path = "Samples/pcm/combi/orl_combi_7"
			},
		}
	},
	{
		label = "Pads >",
		category = "pads",
		actions = {
			{
				label = "Airy"
			},
			{
				label = "Alder"
			},
			{
				label = "Alder2",
				path = "Samples/pcm/pads/alder2"
			},
			{
				label = "Amber",
				path = "Samples/pcm/pads/amber"
			},
			{
				label = "Bower Closes"
			},
			{
				label = "Celestial"
			},
			{
				label = "Celestial2"
			},
			{
				label = "Digi Noise Choir"
			},
			{
				label = "Dreh Moment",
				path = "Samples/pcm/pads/drehmoment"
			},
			{
				label = "Dronarium",
				path = "Samples/pcm/pads/dronarium"
			},
			{
				label = "Eiswind",
				path = "Samples/pcm/pads/eiswind"
			},
			{
				label = "Eno"
			},
			{
				label = "Ferrae",
				path = "Samples/pcm/pads/ferrae"
			},
			{
				label = "FM Cassini"
			},
			{
				label = "Hagelschlag",
				path = "Samples/pcm/pads/hagelschlag"
			},
			{
				label = "Hintergrund",
				path = "Samples/pcm/pads/hintergrund"
			},
			{
				label = "Inside Angel",
				path = "Samples/pcm/pads/inside_angel"
			},
			{
				label = "Iridium",
				path = "Samples/pcm/pads/iridium"
			},
			{
				label = "Lab",
				path = "Samples/pcm/pads/lab"
			},
			{
				label = "Landregen",
				path = "Samples/pcm/pads/landregen"
			},
			{
				label = "Obj. Drone",
				path = "Samples/pcm/pads/object_drone"
			},
			{
				label = "Mindful",
				path = "Samples/pcm/pads/mindful"
			},
			{
				label = "Neutron",
				path = "Samples/pcm/pads/neutron"
			},
			{
				label = "Neutron II",
				path = "Samples/pcm/pads/neutron2"
			},
			{
				label = "Peerlon",
				path = "Samples/pcm/pads/peerlon"
			},
			{
				label = "Perception"
			},
			{
				label = "Pitched Amb.",
				path = "Samples/pcm/pads/pitched_amb"
			},
			{
				label = "Radius",
				path = "Samples/pcm/pads/radius"
			},
			{
				label = "Sandman"
			},
			{
				label = "Schleifend",
				path = "Samples/pcm/pads/schleifend"
			},
			{
				label = "Seashore",
				path = "Samples/pcm/pads/seashore"
			},
			{
				label = "Seitanband",
				path = "Samples/pcm/pads/seitanband"
			},
			{
				label = "Sitar Smooth",
				path = "Samples/pcm/pads/sitar_smooth"
			},
			{
				label = "Sitar S.track"
			},
			{
				label = "Sitar Space",
				path = "Samples/pcm/pads/sitar_space"
			},
			{
				label = "Sodium",
				path = "Samples/pcm/pads/sodium"
			},
			{
				label = "Sommernacht",
				path = "Samples/pcm/pads/sommernacht"
			},
			{
				label = "Spectrum",
				path = "Samples/pcm/pads/spectrum"
			},
			{
				label = "Starshower"
			},
			{
				label = "Strahlend",
				path = "Samples/pcm/pads/strahlend"
			},
			{
				label = "Traum",
				path = "Samples/pcm/pads/trsaum"
			},
			{
				label = "Umbra",
				path = "Samples/pcm/pads/umbra"
			},
			{
				label = "Varianz 2",
				path = "Samples/pcm/pads/varianz"
			},
			{
				label = "Varianz",
				path = "Samples/pcm/pads/varianz2"
			},
			{
				label = "Ventricol",
				path = "Samples/pcm/pads/ventricol"
			},
		}
	},
	{
		label = "Piano >",
		category = "piano",
		actions = {
			{
				label = "Dulcimatica",
				path = "Samples/pcm/pianos/dulcimatica"
			},
			{
				label = "E-Piano Basic",
				path = "Samples/pcm/pianos/epiano_basic"
			},
			{
				label = "E-Piano Cheap",
				path = "Samples/pcm/pianos/epiano_cheap"
			},
			{
				label = "E-Piano Face",
				path = "Samples/pcm/pianos/epiano_face"
			},
			{
				label = "E-Piano Float",
				path = "Samples/pcm/pianos/epiano_float"
			},
			{
				label = "E-Piano Rust",
				path = "Samples/pcm/pianos/epiano_rust"
			},
			{
				label = "Grand Reverb",
				path = "Samples/pcm/piano/grand_reverb"
			}
		}
	},
	{
		label = "Bass >",
		category = "bass",
		actions = {
			{
				label = "303",
				path = "Samples/pcm/bass/303"
			},
			{
				label = "Hopped",
				path = "Samples/pcm/bass/hopped"
			},
			{
				label = "New Old Sub",
				path = "Samples/pcm/bass/new_old_sub"
			},
			{
				label = "Upright",
				path = "Samples/pcm/bass/upright"
			},
		}
	},
	{
		label = "Bells >",
		category = "bells",
		actions = {
			{
				label = "Ambient Bell"
			},
			{
				label = "Analog Chime"
			},
			{
				label = "Basic Bell"
			},
			{
				label = "Brushed Bells",
				path = "Samples/pcm/brushed_bells"
			},
			{
				label = "Fear Gong",
				path = "Samples/pcm/fear_gong"
			},
			{
				label = "FM Bell",
				path = "Samples/pcm/fm_bell"
			},
			{
				label = "Island",
				path = "Samples/pcm/island_bells"
			},
			{
				label = "Obelisk",
				path = "Samples/pcm/obelisk_bell"
			},
			{
				label = "Outland Bells",
				path = "Samples/pcm/outland_bells"
			}
		}
	},
	{
		label = "Wood >",
		category = "mallets",
		actions = {
			{
				label = "Bright Marimba"
			},
			{
				label = "Dhalia",
				path = "Samples/pcm/wood/dhalia"
			},
			{
				label = "Formbar",
				path = "Samples/pcm/wood/formbar"
			},
			{
				label = "Metallofon",
				path = "Samples/pcm/wood/metallofon"
			},
		}
	},
	{
		label = "Plucked >",
		category = "plucked",
		actions = {
			{
				label = "Flange Harp"
			},
			{
				label = "Guzheng"
			},
			{
				label = "Key"
			},
			{
				label = "Shamisen"
			},
			{
				label = "Cave"
			},
			{
				label = "Lift Delay"
			},
			{
				label = "Palm Guitar"
			}
		}
	},
	{
		label = "Strings >",
		category = "strings",
		actions = {
			{
				label = "Cruiser"
			},
			{
				label = "Feedback"
			},
			{
				label = "Magnetic"
			},
			{
				label = "MTron"
			},
			{
				label = "Off World"
			},
			{
				label = "Synthetic"
			},
			{
				label = "Synth Choir"
			},
			{
				label = "Stellar"
			}
		}
	}
}

local gfx <const> = playdate.graphics

local moduleWidth = 85
local moduleHeight = 140

local modType = "SampleSynthMod"
local modSubtype = SourceTypes.audio_gen

function SampleSynthMod:init(xx, yy, modId, onInit)
	SampleSynthMod.super.init(self)
	
	if modId == nil then
		self.modId = modType .. playdate.getSecondsSinceEpoch()
	else
		self.modId = modId
	end
	
	self.onInit = onInit
	
	self.modType = modType
	self.modSubtype = modSubtype
	
	self.menuIndex = 1
	
	--inject recorded samples
	local samples = playdate.file.listFiles("Recorded/")
	local recorded = {}
	if samples ~= nil then
		for s=1,#samples do
			local entry = {
				label = replace("" .. samples[s], ".pda", "")
			}
			table.insert(recorded, entry)
		end
	end
	local recordedCategory = {
		label = "User >",
		category = "user",
		actions = recorded
	}
	table.insert(sampleSynths, recordedCategory)
	
		
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)
	local bgW, bgH = backgroundImage:getSize()
	self.bgW = bgW
	self.bgH = bgH
	gfx.pushContext(backgroundImage)
	
	local catIcon = gfx.image.new("Images/sample_synth_cat_icon")
	catIcon:draw(46, 59)
		
	local div = gfx.image.new("Images/standard_synth_div")
	div:draw(21, 50)
	
	--ADSR
	gfx.drawTextAligned("A",  30, 80, kTextAlignment.center)
	gfx.drawTextAligned("D",  55, 80, kTextAlignment.center)
	gfx.drawTextAligned("S",  30, 115, kTextAlignment.center)
	gfx.drawTextAligned("R",  55, 115, kTextAlignment.center)
	
	curveImage:draw(73, 89)
		
	local leftSocket = assets:image("side_socket_left")
	leftSocket:draw(10, 100)
	
	local rightSocket = assets:image("side_socket_right")
	rightSocket:draw(97, 100)
		
	gfx.popContext()
	
	self.backgroundImage = backgroundImage
	
	self:moveTo(xx, yy)
	self:add()
	
	self.component = SampleSynthComponent(function(channel)
		self.onInit(self.modId, channel)
	end)
	
	local encoderLeftX = xx - (moduleWidth/2) + 18
	
	self.categoryEncoderVector = Vector(encoderLeftX, yy - (moduleHeight/2) + 50)
	self.categoryEncoderValue = 0.0
	
	self.synthEncoderVector = Vector(xx + (moduleWidth/2) - 18, yy - (moduleHeight/2) + 90)
	self.synthEncoderValue = 0.0
	
	--ADSR alignment
	local adsrColWidth = moduleWidth/4
	local adsrEncoderY1 = yy - (bgH/2) + 100
	local adsrEncoderY2 = yy - (bgH/2) + 135
	local shadowPadding = (bgW - moduleWidth)/2
	
	local encoderLeftX = xx - (moduleWidth/2) + 18
	local encoderMidX = xx
	local encoderRightX = xx + (moduleWidth/2) - 18
	
	self.attackEncoderVector = Vector(encoderLeftX, adsrEncoderY1)
	self.attackEncoderValue = 0.1
	
	self.decayEncoderVector = Vector(encoderMidX, adsrEncoderY1)
	self.decayEncoderValue = 0.1
	
	self.sustainEncoderVector = Vector(encoderLeftX, adsrEncoderY2)
	self.sustainEncoderValue = 0.8
	
	self.releaseEncoderVector = Vector(encoderMidX, adsrEncoderY2)
	self.releaseEncoderValue = 0.6
	
	self.curveEncoderVector = Vector(encoderRightX, adsrEncoderY2 - 20)
	self.envelopeCurveEncoderValue = 0.5
	
	self.encoderVectors = {
		self.categoryEncoderVector,
		self.synthEncoderVector,
		self.attackEncoderVector,
		self.decayEncoderVector,
		self.sustainEncoderVector,
		self.releaseEncoderVector,
		self.curveEncoderVector
	}
	
	self.noteInVector = Vector(xx - (moduleWidth/2)-2, yy - (moduleHeight/2) + 100)	
	self.socketOutVector = Vector	(xx + (moduleWidth/2)+2, yy - (moduleHeight/2) + 100)

	self.inSocketVectors = {
		self.noteInVector
	}
	
	self.selectedCategoryIndex = 1
	self.categoryLabel = sampleSynths[self.selectedCategoryIndex].label
	
	self.selectedSynthIndex = 1
	self.synthLabel = sampleSynths[self.selectedCategoryIndex].actions[self.selectedSynthIndex].label
	
	self:redrawBackground()
end

function SampleSynthMod:redrawBackground()
	gEncoder:hide()
	local backgroundImage = generateModBackgroundWithShadow(moduleWidth, moduleHeight)	
	local bgW, bgH = self.backgroundImage:getSize()

	gfx.pushContext(backgroundImage)
	
	self.backgroundImage:draw(0, 0)
	
	local encoderLeftX = 22
	local encoderMidX = 46
	local encoderRightX = 71
	
	--category
	local synthLabel = "" .. self.categoryLabel .. " " .. self.synthLabel
	gfx.drawTextInRect(synthLabel, 22, 21, moduleWidth - 18, 27, nil, "...")
		
	gEncoder:setValue(self.categoryEncoderValue)
	local categoryEncoderImage = gEncoder:getImage()
	categoryEncoderImage:draw(encoderLeftX, 54)
	
	--synth
	gEncoder:setValue(self.synthEncoderValue)
	local synthEncoderImage = gEncoder:getImage()
	synthEncoderImage:draw(71, 54)
	
	--Attack
	gEncoder:setValue(self.attackEncoderValue)
	local attackEncoderImage = gEncoder:getImage()
	attackEncoderImage:draw(encoderLeftX, 90)
	
	--Decay
	gEncoder:setValue(self.decayEncoderValue)
	local decayEncoderImage = gEncoder:getImage()
	decayEncoderImage:draw(encoderMidX, 90)
	
	--Sustain
	gEncoder:setValue(self.sustainEncoderValue)
	local sustainEncoderImage = gEncoder:getImage()
	sustainEncoderImage:draw(encoderLeftX, 125)
	
	--Release
	gEncoder:setValue(self.releaseEncoderValue)
	local releaseEncoderImage = gEncoder:getImage()
	releaseEncoderImage:draw(encoderMidX, 125)
	
	--Curve
	gEncoder:setValue(self.envelopeCurveEncoderValue)
	local curveEncoderImage = gEncoder:getImage()
	curveEncoderImage:draw(encoderRightX, 105)
	
	gfx.popContext()
	
	self:setImage(backgroundImage)
	self.redrawPending = false
end

function SampleSynthMod:turn(x, y, change)
	local encoderVector = nil
	if x ~= self.lastEncoderX or y ~= self.lastEncoderY then
		encoderVector = self:findClosestEncoderVector(x, y)
		self.lastEncoderX = x
		self.lastEncoderY = y
		self.lastEncoderVector = encoderVector
	else
		encoderVector = self.lastEncoderVector
	end
	
	if encoderVector == self.categoryEncoderVector then
		local prevIndex = self.selectedCategoryIndex
		gEncoder:setValue(self.categoryEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.categoryEncoderVector.x, self.categoryEncoderVector.y)
		gEncoder:turn(change)
		self.categoryEncoderValue = gEncoder:getValue()
		
		self.selectedCategoryIndex = math.floor(map(self.categoryEncoderValue, 0.0, 1.0, 1, #sampleSynths))		
		self.categoryLabel = sampleSynths[self.selectedCategoryIndex].label
		
		if prevIndex ~= self.selectedCategoryIndex then
			self.synthEncoderValue = 0.0
			self.selectedSynthIndex = 1
			self:setSynthSample()
		end

		self:redrawBackground()
	elseif encoderVector == self.synthEncoderVector then
		gEncoder:setValue(self.synthEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.synthEncoderVector.x, self.synthEncoderVector.y)
		gEncoder:turn(change)
		self.synthEncoderValue = gEncoder:getValue()
		local category = sampleSynths[self.selectedCategoryIndex]
		self.selectedSynthIndex = math.floor(map(self.synthEncoderValue, 0.0, 1.0, 1, #category.actions))
		self:setSynthSample()
		self:redrawBackground()
	elseif encoderVector == self.attackEncoderVector then
		gEncoder:setValue(self.attackEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.attackEncoderVector.x, self.attackEncoderVector.y)
		gEncoder:turn(change)
		self.attackEncoderValue = gEncoder:getValue()
		self.component:setAttack(self.attackEncoderValue)
	elseif encoderVector == self.decayEncoderVector then
		gEncoder:setValue(self.decayEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.decayEncoderVector.x, self.decayEncoderVector.y)
		gEncoder:turn(change)
		self.decayEncoderValue = gEncoder:getValue()
		self.component:setDecay(self.decayEncoderValue)
	elseif encoderVector == self.sustainEncoderVector then
		gEncoder:setValue(self.sustainEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.sustainEncoderVector.x, self.sustainEncoderVector.y)
		gEncoder:turn(change)
		self.sustainEncoderValue = gEncoder:getValue()
		self.component:setSustain(self.sustainEncoderValue)
	elseif encoderVector == self.releaseEncoderVector then
		gEncoder:setValue(self.releaseEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.releaseEncoderVector.x, self.releaseEncoderVector.y)
		gEncoder:turn(change)
		self.releaseEncoderValue = gEncoder:getValue()
		self.component:setRelease(self.releaseEncoderValue)
	elseif encoderVector == self.curveEncoderVector then
		gEncoder:setValue(self.envelopeCurveEncoderValue)
		gEncoder:show()
		gEncoder:moveTo(self.curveEncoderVector.x, self.curveEncoderVector.y)
		gEncoder:turn(change)
		self.envelopeCurveEncoderValue = gEncoder:getValue()
		self.component:setEnvelopeCurve(self.envelopeCurveEncoderValue)
	end
	print("set redraw true")
	self.redrawPending = true
end

function SampleSynthMod:invalidate()
	if self.redrawPending then
		self:redrawBackground()
	end
end

function SampleSynthMod:findClosestEncoderVector(x, y)
	local reticleVector = Vector(x, y)
	local closestDistance = 1000
	local closestIndex = -1
	for i=1,#self.encoderVectors do
		local encoderVector = self.encoderVectors[i]
		local distance = reticleVector:distance(encoderVector)
		if distance < closestDistance then
			closestDistance = distance
			closestIndex = i
		end
	end
	
	return self.encoderVectors[closestIndex]
end


function SampleSynthMod:setInCable(patchCable)
	local closestInVector = self:findClosestInVector(patchCable:getEndX(), patchCable:getEndY())
	
	if closestInVector == self.pedalInVector then
		patchCable:setEnd(self.pedalInVector.x, self.pedalInVector.y, self.modId)
		self.pedalInCable = patchCable
		self.component:setPedalInCable(patchCable:getCable())
	elseif closestInVector == self.noteInVector then
		patchCable:setEnd(self.noteInVector.x, self.noteInVector.y, self.modId)
		self.noteInCable = patchCable
		self.component:setNoteInCable(patchCable:getCable())
	end
end

function SampleSynthMod:setOutCable(patchCable)
	self.outCable = patchCable
	patchCable:setStart(self.socketOutVector.x, self.socketOutVector.y, self.modId)
	self.component:setOutCable(patchCable:getCable())
end

function SampleSynthMod:collision(x, y)
	if x > self.x - (moduleWidth/2) and x < self.x + (moduleWidth/2) and y > self.y - (moduleHeight/2) and y < self.y + (moduleHeight/2) then
		return true
	else
		return false
	end
end

function SampleSynthMod:findClosestInVector(x, y)
	print("Recticle x: " .. x .. " y: " .. y)
	local reticleVector = Vector(x, y)
	local closestDistance = 1000
	local closestIndex = -1
	for i=1,#self.inSocketVectors do
		local aSocketVector = self.inSocketVectors[i]
		local distance = reticleVector:distance(aSocketVector)
		if distance < closestDistance then
			closestDistance = distance
			closestIndex = i
		end
	end
	return self.inSocketVectors[closestIndex]
end

function SampleSynthMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype, onError)
	local closestInVector = self:findClosestInVector(x, y)
	
	if closestInVector == self.pedalInVector then
		if sourceSubtype ~= "clock_router" then
			if onError ~= nil then onError("This input requires a clock signal") end
				return false 
	 	elseif ghostCable:getStartModId() == self.modId then
			print("Can't connect a mod to itself...")
			return false
		elseif self.component:pedalInConnected() then
			return false
		else
			ghostCable:setEnd(self.pedalInVector.x, self.pedalInVector.y)
			ghostCable:setGhostReceiveConnected()
			return true
		end
	elseif closestInVector == self.noteInVector then
		if sourceSubtype ~= "midi" and sourceSubtype ~= "clock_router_or_midi" then
			if onError ~= nil 
				then onError("This input requires a midi/note signal") 		
			end
			return false 
		elseif ghostCable:getStartModId() == self.modId then
			print("Can't connect a mod to itself...")
			return false
		elseif self.component:noteInConnected() then
			return false
		else
			ghostCable:setEnd(self.noteInVector.x, self.noteInVector.y)
			ghostCable:setGhostReceiveConnected()
			return true
		end
	end
end

function SampleSynthMod:tryConnectGhostOut(x, y, ghostCable)
	if self.component:outConnected() then
		return false
	else
		ghostCable:setStart(self.socketOutVector.x, self.socketOutVector.y)
		ghostCable:setGhostSendConnected()
		return true
	end
end

function SampleSynthMod:setSynthSample()
	local category = sampleSynths[self.selectedCategoryIndex]
	self.categoryLabel = category.label
	print("setSynthSample() Category: " .. self.categoryLabel)
	local sample = category.actions[self.selectedSynthIndex]
	if sample ~= nil then
		if category.actions[self.selectedSynthIndex].path ~= nil then
			self.synthLabel = category.actions[self.selectedSynthIndex].label
			self:setSynthSampleByPath(category.actions[self.selectedSynthIndex].path)
		else
			local name = category.actions[self.selectedSynthIndex].label
			self.synthLabel = name
			self:setSynthSampleByName(name)
		end
	else
		print("setSynthSample() No synth found at index " .. self.selectedSynthIndex)
		self.synthLabel = "None found"
	end
end

function SampleSynthMod:setSynthSampleByPath(path)
	self.component:load(path, nil, nil)
end

function SampleSynthMod:setSynthSampleByName(name)
	if name == "Airy" then
		self.component:loadWithSamplesSustain("Samples/pcm/airy_pad", 16515, 65161)
	elseif name == "Alder" then
		self.component:load("Samples/pcm/alder_pad", nil, nil)
	elseif name == "Bower Close" then
		self.component:load("Samples/pcm/bowser_close", nil, nil)
	elseif name == "Celestial" then
		self.component:load("Samples/pcm/celestial_pad", nil, nil)
	elseif name == "Celestial2" then
		self.component:load("Samples/pcm/celestial_pad2", nil, nil)
	elseif name == "Digi Noise Choir" then
		self.component:load("Samples/pcm/digi_noise_choir", 1.25, 1.95)	
	elseif name == "Eno" then
		self.component:load("Samples/pcm/eno_pad", nil, nil)
	elseif name == "FM Cassini" then
		self.component:load("Samples/pcm/fm_cassini_pad", 0.635, 1.972)	
	elseif name == "Perception" then
		self.component:loadWithSamplesSustain("Samples/pcm/perception_pad", 33448, 97152)	
	elseif name == "Sandman" then
		self.component:loadWithSamplesSustain("Samples/pcm/sandman_pad", 40805, 125325)	
	elseif name == "Sitar Soundtrack" then
		self.component:loadWithSamplesSustain("Samples/pcm/sitar_soundtrack_pad", 38861, 79491)	
	elseif name == "Starshower" then
		self.component:loadWithSamplesSustain("Samples/pcm/starshower_pad", 6454, 51213)	
	elseif name == "Ambient Bell" then
		self.component:loadWithSamplesSustain("Samples/pcm/ambient_computer_bell", 38653, 79318)	
	elseif name == "Basic Bell" then
		self.component:load("Samples/pcm/basic_bell")	
	elseif name == "Bright Marimba" then
		self.component:load("Samples/pcm/bright_marimba")	
	elseif name == "Flange Harp" then
		self.component:load("Samples/pcm/flange_harp")	
	elseif name == "Guzheng" then
		self.component:load("Samples/pcm/guzheng")	
	elseif name == "Shamisen" then
		self.component:load("Samples/pcm/shamisen")
	elseif name == "Cave" then
		self.component:load("Samples/pcm/cave_pluck")		
	elseif name == "Lift Delay" then
		self.component:load("Samples/pcm/lift_delay")	
	elseif name == "Palm Guitar" then
		self.component:load("Samples/pcm/palm_guitar")	
	elseif name == "Cruiser" then
		self.component:loadWithSamplesSustain("Samples/pcm/cruiser_strings", 9715, 70921)	
	elseif name == "Synthetic" then
		self.component:load("Samples/pcm/synthetic_strings"	)	
	elseif name == "Synth Choir" then
		self.component:load("Samples/pcm/synth_choir_strings"	)	
	elseif name == "Stellar" then
		self.component:load("Samples/pcm/stellar_strings"	)	
	elseif name == "Off World" then
		self.component:load("Samples/pcm/off_world_strings"	)	
	elseif name == "Magnetic" then
		self.component:load("Samples/pcm/magnetic_strings"	)	
	elseif name == "MTron" then
		self.component:load("Samples/pcm/mtron_strings"	)	
	elseif name == "Feedback" then
		self.component:load("Samples/pcm/feedback_strings"	)	
	elseif name == "Key" then
		self.component:load("Samples/pcm/pluck_key"	)	
	elseif name == "Analog Chime" then
		self.component:load("Samples/pcm/analog_chime"	)	
	elseif name == "Brushed Bells" then
		self.component:load("Samples/pcm/brushed_bells"	)	
	else
		if playdate.file.exists("Recorded/" .. name .. ".pda") then
			self.component:load("Recorded/" .. name)	
		else
			print("No sample available with name: " .. name)
		end
	end
end	

function SampleSynthMod:handleModClick(tX, tY, listener)
	self.menuListener = listener

	local actions = {}
	table.insert(actions, {label="About"})
	table.insert(actions, {label="Move"})
	table.insert(actions, {label="Remove"})

	local contextMenu = ModuleMenu(actions)
	contextMenu:show(function(action, index) 
		self.menuIndex = index

		if action == "About" then
			local aboutPopup = ModAboutPopup("Sample based synth. You may get clicks and pops due to bugs in the Playdate audio API - sorry.")
			aboutPopup:show()
		elseif action == "Move" then
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		elseif action == "Remove" then
			if self.menuListener ~= nil then 
				self.menuListener(action) 
			end
		else
			self:setSynthSampleByName(action)
		end
		
		self:redrawBackground()
	end, self.menuIndex)
end

function SampleSynthMod:repositionBy(x, y)
	self:moveBy(x, y)
end

function SampleSynthMod:moveFinish()
	local encoderLeftX = self.x - (moduleWidth/2) + 18
	
	self.categoryEncoderVector = Vector(encoderLeftX, self.y - (moduleHeight/2) + 50)	
	self.synthEncoderVector = Vector(self.x + (moduleWidth/2) - 18, self.y - (moduleHeight/2) + 90)
	
	--ADSR alignment
	local adsrColWidth = moduleWidth/4
	local adsrEncoderY1 = self.y - (self.bgH/2) + 100
	local adsrEncoderY2 = self.y - (self.bgH/2) + 135
	local shadowPadding = (self.bgW - moduleWidth)/2
	
	local encoderLeftX = self.x - (moduleWidth/2) + 18
	local encoderMidX = self.x
	local encoderRightX = self.x + (moduleWidth/2) - 18
	
	self.attackEncoderVector = Vector(encoderLeftX, adsrEncoderY1)	
	self.decayEncoderVector = Vector(encoderMidX, adsrEncoderY1)
	self.sustainEncoderVector = Vector(encoderLeftX, adsrEncoderY2)
	self.releaseEncoderVector = Vector(encoderMidX, adsrEncoderY2)
	self.curveEncoderVector = Vector(encoderRightX, adsrEncoderY2 - 20)
	
	self.encoderVectors = {
		self.categoryEncoderVector,
		self.synthEncoderVector,
		self.attackEncoderVector,
		self.decayEncoderVector,
		self.sustainEncoderVector,
		self.releaseEncoderVector,
		self.curveEncoderVector
	}
	
	self.noteInVector = Vector(self.x - (moduleWidth/2)-2, self.y - (moduleHeight/2) + 100)	
	self.socketOutVector = Vector	(self.x + (moduleWidth/2)+2, self.y - (moduleHeight/2) + 100)
	
	self.inSocketVectors = {
		self.noteInVector
	}
	
end

function SampleSynthMod:evaporate(onDetachConnected)
	--first stop any notes playing:
	self.component:stopAll()

	--first detach cables
	if self.component:noteInConnected() then
		onDetachConnected(self.noteInCable:getStartModId(), self.noteInCable:getCableId())
		self.component:unplugNoteIn()
		self.noteInCable:evaporate()
	end
	
	if self.component:outConnected() then
		onDetachConnected(self.outCable:getEndModId(), self.outCable:getCableId())
		self.component:unplugOut()
		self.outCable:evaporate()
	end
	

	
	--then remove sprites
	self:remove()
end

function SampleSynthMod:type() return modType end
function SampleSynthMod:getModId() return self.modId end
function SampleSynthMod:unplug(cableId) self.component:unplug(cableId) end
function SampleSynthMod.ghostModule() return buildGhostModule(moduleWidth, moduleHeight) end

function SampleSynthMod:toState()
	local modState = {}
	modState.modId = self.modId
	modState.type = self:type()
	modState.x = self.x
	modState.y = self.y	

	modState.attackEncoderValue = self.attackEncoderValue
	modState.decayEncoderValue = self.decayEncoderValue
	modState.sustainEncoderValue = self.sustainEncoderValue
	modState.releaseEncoderValue = self.releaseEncoderValue
	modState.envelopeCurveEncoderValue = self.envelopeCurveEncoderValue
	
	modState.categoryEncoderValue = self.categoryEncoderValue
	modState.synthEncoderValue = self.synthEncoderValue
	return modState
end

function SampleSynthMod:fromState(modState)
	self.categoryEncoderValue = modState.categoryEncoderValue
	self.selectedCategoryIndex = math.floor(map(self.categoryEncoderValue, 0.0, 1.0, 1, #sampleSynths))		
	self.categoryLabel = sampleSynths[self.selectedCategoryIndex].label
	
	self.synthEncoderValue = modState.synthEncoderValue
	local category = sampleSynths[self.selectedCategoryIndex]
	self.selectedSynthIndex = math.floor(map(self.synthEncoderValue, 0.0, 1.0, 1, #category.actions))
	self:setSynthSample()
	
	self.attackEncoderValue = modState.attackEncoderValue
	self.component:setAttack(self.attackEncoderValue)
	
	self.decayEncoderValue = modState.decayEncoderValue
	self.component:setDecay(self.decayEncoderValue)
	
	self.sustainEncoderValue = modState.sustainEncoderValue
	self.component:setSustain(self.sustainEncoderValue)
	
	self.releaseEncoderValue = modState.releaseEncoderValue
	self.component:setRelease(self.releaseEncoderValue)
	
	self.envelopeCurveEncoderValue = modState.envelopeCurveEncoderValue
	self.component:setEnvelopeCurve(self.envelopeCurveEncoderValue)
	
	self:redrawBackground()
end