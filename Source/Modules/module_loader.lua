class('ModuleLoader').extends()

function ModuleLoader:init()
	ModuleLoader.super.init(self)
	
	self.didScale = false
	
end

-- This is long-winded. 
-- 1. First add each module to screen
-- 2. callback with audio channels if needed
-- 3. then connected the cables
-- 4. then iterate the modules again and set state - and also call retrigger if available
	--[[
		if patchMod.type == "ArpMod" then
		local mod = ArpMod(patchMod.x, patchMod.y, patchMod.modId)
		if mod.fromState ~= nil then mod:fromState(patchMod) end
		self:addNew(mod)
		]]
function ModuleLoader:loadPatch(patch, modules, cables, audioManager)
	self.modules = modules
	self.cables = cables
	self.audioManager = audioManager
	
	gPatchName = patch.name
	
	print("ModuleLoader loading patch: " .. gPatchName)
		
	self.didScale = false
	local scale = patch.scale
	if scale ~= nil then
		if playdate.display.getScale() ~= scale then
			playdate.display.setScale(scale)
			self.didScale = true
		end
	else
		if playdate.display.getScale() ~= 1 then
			playdate.display.setScale(1)
			self.didScale = true
		end
	end
	
	--First run add the modules, add audio mods to audio manager
	local patchModules = patch.modules
	
	for i=1,#patchModules do
    local patchMod = patchModules[i]
    
    print("ModuleLoader loading module " .. i .. " of " .. #patchModules .. ": " .. patchMod.modId)
    
    local mod = nil
      
    -- clocks
    if patchMod.type == "Clock2Mod" then
      mod = Clock2Mod(patchMod.x, patchMod.y, patchMod.modId)
    elseif patchMod.type == "ToClockMod" then
      mod = ToClockMod(patchMod.x, patchMod.y, patchMod.modId)
    elseif patchMod.type == "Merge2Mod" then
      mod = Merge2Mod(patchMod.x, patchMod.y, patchMod.modId)
    elseif patchMod.type == "ClockDelayMod" then
      mod = ClockDelayMod(patchMod.x, patchMod.y, patchMod.modId)
    elseif patchMod.type == "ClockDividerMod" then
      mod = ClockDividerMod(patchMod.x, patchMod.y, patchMod.modId)
    end
    
    if mod ~= nil then goto continue end
		
		-- drums
		if patchMod.type == "DrumMod" then
			mod = DrumMod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
				self:addToAudioManager(modId, channel)
			end)
		elseif patchMod.type == "OR606Mod" then
			mod = OR606Mod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
						self:addToAudioManager(modId, channel)
			end)
		elseif patchMod.type == "OR808Mod" then
			mod = OR808Mod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
						self:addToAudioManager(modId, channel)
			end)
		elseif patchMod.type == "OR909Mod" then
			mod = OR909Mod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
						self:addToAudioManager(modId, channel)
			end)
		end
		
		if mod ~= nil then goto continue end
		
		-- effects and pedals
		if patchMod.type == "BitcrusherMod" then
			mod = BitcrusherMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "DelayMod" then
			mod = DelayMod(patchMod.x, patchMod.y, patchMod.modId)	
		elseif patchMod.type == "HighpassMod" then
			mod = HighpassMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "LowpassMod" then
			mod = LowpassMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "OnePoleFilterMod" then
			mod = OnePoleFilterMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "OverdriveMod" then
			mod = OverdriveMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "RingModulatorMod" then
			mod = RingModulatorMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "PedalMod" then
			mod = PedalMod(patchMod.x, patchMod.y, patchMod.modId)
		end
		
		if mod ~= nil then goto continue end
		
		-- midi
		if patchMod.type == "MidiGenMod" then
			mod = MidiGenMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "MidiGenBouncyBallMod" then
			mod = MidiGenBouncyBallMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "MidiKeyboardMod" then
			mod = MidiKeyboardMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "NormalisedToMidiMod" then
			mod = NormalisedToMidiMod(patchMod.x, patchMod.y, patchMod.modId)
		end
		
		-- mixers
		--todo - rename this mod type SpeakerMod is an old incorrect type
		if patchMod.type == "Mix1Mod" or patchMod.type == "SpeakerMod" then
			mod = Mix1Mod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "Mix1v2Mod" then
			mod = Mix1v2Mod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "Mix4Mod" then
			mod = Mix4Mod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "Mix4SliderMod" then
			mod = Mix4SliderMod(patchMod.x, patchMod.y, patchMod.modId)
		end
		
		--samplers 
		if patchMod.type == "GranularMod" then
			mod = GranularMod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
				self:addToAudioManager(modId, channel)
		end)  
		elseif patchMod.type == "HexagramMod" then
			mod = HexagramMod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
					self:addToAudioManager(modId, channel)
			end)
		elseif patchMod.type == "LooperMod" then
			mod = LooperMod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
					self:addToAudioManager(modId, channel)
			end)
		elseif patchMod.type == "SamplerMod" then
			mod = SamplerMod(patchMod.x, patchMod.y, patchMod.modId)

		elseif patchMod.type == "SamplePlayMod" then
			mod = SamplePlayMod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
					self:addToAudioManager(modId, channel)
			end)
		end
		
		if mod ~= nil then goto continue end
		
		--synths
		if patchMod.type == "NoiseBoxMod" then
			mod = NoiseBoxMod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
					self:addToAudioManager(modId, channel)
			end)
		elseif patchMod.type == "StochasticSineMod" then
			mod = StochasticSineMod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
					self:addToAudioManager(modId, channel)
			end)
		elseif patchMod.type == "StochasticSquareMod" then
			mod = StochasticSquareMod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
					self:addToAudioManager(modId, channel)
			end)
		elseif patchMod.type == "StochasticTriMod" then
			mod = StochasticTriMod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
				self:addToAudioManager(modId, channel)
			end)
		elseif patchMod.type == "MicroSynthMod" then
			mod = MicroSynthMod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
				self:addToAudioManager(modId, channel)
			end)
		elseif patchMod.type == "SynthMod" then
			mod = SynthMod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
				self:addToAudioManager(modId, channel)
			end)		
		elseif patchMod.type == "SampleSynthMod" then
			mod = SampleSynthMod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
				self:addToAudioManager(modId, channel)
			end)	
		elseif patchMod.type == "WavetableSynthMod" then
			mod = WavetableSynthMod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
				self:addToAudioManager(modId, channel)
			end)
		elseif patchMod.type == "WavetableSynth2DMod" then
			mod = WavetableSynth2DMod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
				self:addToAudioManager(modId, channel)
			end)		
		elseif patchMod.type == "WavetableHzMod" then
			mod = WavetableHzMod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
				self:addToAudioManager(modId, channel)
			end)
		end
		--end of synths
		
		--sequencers
		if patchMod.type == "DroneSeqMod" then
			mod = DroneSeqMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "RandomRepeaterMod" then
			mod = RandomRepeaterMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "RandomShifterMod" then
			mod = RandomShifterMod(patchMod.x, patchMod.y, patchMod.modId)
		end
		--end of sequencers
		
		if patchMod.type == "ArpMod" then
			mod = ArpMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "Bifurcate2Mod" then
			mod = Bifurcate2Mod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "Bifurcate4Mod" then
			mod = Bifurcate4Mod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "BlackholeMod" then
			mod = BlackholeMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "MicroSynthMod" then
			mod = MicroSynthMod(patchMod.x, patchMod.y, patchMod.modId, function(modId, channel)
				self:addToAudioManager(modId, channel)
			end)
		elseif patchMod.type == "OscillatorMod" then
			mod = OscillatorMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "Oscillator2Mod" then
			mod = Oscillator2Mod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "PrintMod" then
			mod = PrintModule(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "RandomMod" then
			mod = RandomMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "SequencerMod" then
			mod = SequencerMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "SeqGridMod" then
			mod = SeqGridMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "TimedSwitchMod" then
			mod = TimedSwitchMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "SwitchMod" then
			mod = SwitchMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "SwitchSPDTMod" then
			mod = SwitchSPDTMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "LabelMod" then
			mod = LabelMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "LargeLabelMod" then
			mod = LargeLabelMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "ArrowMod" then
			mod = ArrowMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "ImageMod" then
			mod = ImageMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "ButtonMod" then
			mod = ButtonMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "KeyboardMod" then
			mod = KeyboardMod(patchMod.x, patchMod.y, patchMod.modId)	
		elseif patchMod.type == "XYTiltMod" then
			mod = XYTiltMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "YTiltMod" then
			mod = YTiltMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "BouncingBallMod" then
			mod = BouncingBallMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "BouncingBallClockMod" then
			mod = BouncingBallClockMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "SerialInMod" then
			mod = SerialInMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "SerialClockMod" then
			mod = SerialClockMod(patchMod.x, patchMod.y, patchMod.modId)
		end
		
		--games
		if patchMod.type == "PongMod" then
			mod = PongMod(patchMod.x, patchMod.y, patchMod.modId)
		elseif patchMod.type == "GameOfLifeMod" then
			mod = GameOfLifeMod(patchMod.x, patchMod.y, patchMod.modId)
		end
		
    ::continue::
    
    if mod ~= nil then
      table.insert(modules, mod)
    end
  end
	
	
	local patchCables = patch.cables
	--todo - this cable management is copy/paste of the 1st go at it, can probably be much simplified
	for i=1,#patchCables do
		
		local cableState = patchCables[i]
		
		print("POP LOADING CABLEJSONNNN")
		printTable(cableState)
		print("POP LOADING CABLEJSONNNN")
		local reifiedCable = PatchCable(false, cableState.cableId)
		reifiedCable:fromState(cableState)
		
		local startModId = reifiedCable.startModId
		local endModId = reifiedCable.endModId
		local hostChannelModId = reifiedCable.hostAudioModId
		
		local channel = nil
		
		if hostChannelModId ~= nil then
			print(">>> Loading cable for audio channel mod: " .. hostChannelModId .. ": " .. i .. " of " .. #patchCables .. ": startModId: " .. reifiedCable.startModId .. " endModId: " .. reifiedCable.endModId)
			channel = self.audioManager:getChannel(hostChannelModId)
		else
			print(">>> Loading cable: " .. i .. " of " .. #patchCables .. ": startModId: " .. reifiedCable.startModId .. " endModId: " .. reifiedCable.endModId)
		end
		

		local startModSubtype = nil

		for i=1,#self.modules do
			local module = self.modules[i]
			if module.modId == startModId then
				print(">>> connecting start of cable to: " .. module.modId)
				module:setOutCable(reifiedCable)
				startModSubtype = module.modSubtype					
				break
			end
		end
		
		for i=1,#self.modules do
			local endMod = self.modules[i]
			if endMod.modId == endModId then
				print(">>> connecting end of cable to: " .. endMod.modId)
				
				if endMod.setChannel ~= nil then
				 	if channel ~= nil then
					 	print("LOAD:::: found setChannel - setting") 
					 	endMod:setChannel(channel)
				 	else
							print("LOAD:::: found setChannel but no channel available for mod: " .. endMod.modType)
							channel = self.audioManager:getChannel(reifiedCable:getHostAudioModId())
							endMod:setChannel(channel)
				 	end
			  end
				 
				endMod:setInCable(reifiedCable, startModSubtype)
			end
		end
		
		table.insert(self.cables, reifiedCable)
	end
	
	for p=1,#patchModules do
		local patchMod = patchModules[p]
		
		for m=1,#self.modules do
			local module = self.modules[m]
			
			if module.modId == patchMod.modId then
				if module.fromState ~= nil then module:fromState(patchMod) end
				if module.retrigger ~= nil then module:retrigger() end
			end
		end
	end		
end

function ModuleLoader:addToAudioManager(modId, channel)
	self.audioManager:addChannel(modId, channel)
end

function ModuleLoader:scaleChanged()
	return self.didScale
end