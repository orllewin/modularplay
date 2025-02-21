--[[
	© 2023 Orllewin - All Rights Reserved.
]]

import 'global'
import 'Coracle/string_utils'
import 'Audio/audio_manager'
import 'Modules/module_loader'

class('ModuleManager').extends()

local gfx <const> = playdate.graphics
function ModuleManager:init(xx, yy)
	ModuleManager.super.init(self)
	
	self.ghostCable = PatchCable(true)
	self.ghostCable:hide()
	
	self.jackSound = playdate.sound.sampleplayer.new("Samples/ui_click")
	self.jackSound:setVolume(0.5)
	
	self.humSound1 = playdate.sound.sampleplayer.new("Samples/ui_hum1")
	self.humSound1:setVolume(0.6)
	self.humSound2 = playdate.sound.sampleplayer.new("Samples/ui_hum2")
	self.humSound2:setVolume(0.6)
	
	self.dropSound = playdate.sound.sampleplayer.new("Samples/ui_drop")
	
	self.serialModule = nil
	self.serialClockModule = nil
	self.x = -1
	self.y = -1
	self.lastMod = nil
	
	self.audioManager = AudioManager()
	self.loader = ModuleLoader()
	
	self.modules = {}
	self.cables = {}
	self.granularMods = {}
	self.bangMods = {}
end

function ModuleManager:mn(midiNote)
	if self.serialModule ~= nil then self.serialModule:mn(midiNote) end
end

function ModuleManager:clock(beat)
	if self.serialClockModule ~= nil then self.serialClockModule:clock(beat) end
end

function ModuleManager:bang(id)
	print("ModuleManager:bang(id): " .. id)
	for i=1, #self.bangMods do
		local bangMod = self.bangMods[i]
		if bangMod:bangId() == id then
			print("calling bangMod:bang()")
			bangMod:bang()
			return
		end
	end
end

function ModuleManager:updateGranulars()
	for i=1, #self.granularMods do
		local granularMod = self.granularMods[i]
		granularMod:doUpdate()
	end
end

function ModuleManager:removeCable(cableId)
	for i=1,#self.cables do
		if self.cables[i]:getCableId() == cableId then
			table.remove(self.cables, i)
			break
		end
	end
end

function ModuleManager:deleteAll()
	local moduleCount = #self.modules
	print("ModuleManager:deleteAll() modules to delete: " .. moduleCount)
	if moduleCount == 0 then
		print("No modules to delete")
		return
	end
	for m=#self.modules, 1, -1 do
		print("Deleting " .. m .. " of " .. moduleCount)
		local oldMod = self.modules[m]
		print("Removing mod: " .. oldMod.modId)
		oldMod:evaporate(function(moduleId, cableId)
				--remove a cable from attached module
				print("Remove " .. cableId .. " cable from " .. moduleId)
				local module = self:getById(moduleId)
				if module~= nil and module.unplug ~= nil then module:unplug(cableId) end
		end)
		table.remove(self.modules, m)
	end
	
	for k,v in pairs(self.cables) do self.cables[k]=nil end
	self.audioManager:purge()
end

function ModuleManager:removeEvaporatedModule(index)
	table.remove(self.modules, index)
end

function ModuleManager:loadPatch(path, onLoaded)
	
	print("ModuleManager:loadPatch(): " .. path)
	
	--Remove old
	self:deleteAll()
	
	assert(#self.modules == 0, "Not all modules deleted")
	
	-- Load new
	local patch = json.decodeFile(path)
	
	if patch == nil then
		print("Patch at " .. path .. " does not exist")
		return
	end
	
	print("Patch:\n" .. json.encodePretty(patch))
	
	self.loader:loadPatch(patch, self.modules, self.cables, self.audioManager, function(modId, channel) 
		--add to audio manager
		self:addToAudioManager(modId, channel)
	end)

	globalXDrawOffset = patch.globalX
	globalYDrawOffset = patch.globalY
	
	if globalXDrawOffset ~= nil and globalYDrawOffset ~= nil then
		local xLocation = (-1 * globalXDrawOffset) + 200
		local yLocation = (-1 * globalYDrawOffset) + 120
		self:move(xLocation, yLocation)
	end
		
	if onLoaded ~= nil then onLoaded(self.loader:scaleChanged()) end
end

function ModuleManager:saveCurrent()
	print("Save current: " .. gPatchName)
	self:savePatch(gPatchName)
end

function ModuleManager:savePatch(name)
	print("ModuleManager:savePatch(): " .. name)
	
	local patch = {}
	
	
	assert(name ~= nil, "Patch name cannot be nil")
	
	patch.name = name
	patch.globalX = globalXDrawOffset
	patch.globalY = globalYDrawOffset
	
	-- Modules ---------------------------
	
	local moduleStates = {}
	
	for i=1,#self.modules do
		local module = self.modules[i]
		print("Checking module: " .. module.modId)
		if module.toState ~= nil then
			print("building mod state")
			local modState = module:toState()
			table.insert(moduleStates, modState)
		end
	end
	
	patch.modules = moduleStates
	
	-- Cables ---------------------------
	
	local cableStates = {}
	
	for i=1,#self.cables do
		local cable = self.cables[i]
		print("Checking cable: " .. cable.cableId)
		print("building cable state")
		local cableState = cable:toState()
		table.insert(cableStates, cableState)
	end
	
	patch.cables = cableStates
	
	local patchJson = json.encodePretty(patch)
	
	print("modulesJson:\n" .. patchJson)
	
	--todo - turn name into filename
	local filename = replace(name, " ",  "_")
	
	json.encodeToFile(filename .. ".orlam", true, patch)
end

local debounce = false

function ModuleManager:move(x, y)
	self:invalidate()
	if not debounce then
    --debounce = true
		if self.ghostCable:isShowing() then
			self.ghostCable:setEnd(x, y)
		end
		
		-- playdate.timer.performAfterDelay(50, function() 
		-- 	debounce = false
		-- end)
	end
end

function ModuleManager:nearestModuleVector(x, y)
	if #self.modules == 1 then
		return self.modules[1]
	else
		local reticleVector = Vector(x, y)
		local closestDistance = 1000
		local closestIndex = -1
		for i=1,#self.modules do
			local module = self.modules[i]
			local moduleVector = Vector(module.x, module.y)
			local distance = reticleVector:distance(moduleVector)
			if distance < closestDistance then
				closestDistance = distance
				closestIndex = i
			end
		end
		
		local nearestModVector = Vector(self.modules[closestIndex].x, self.modules[closestIndex].y)
		
		return nearestModVector
	end
end

function ModuleManager:invalidate()
	if self.lastMod ~= nil and self.lastMod.invalidate ~= nil then self.lastMod:invalidate() end
end

function ModuleManager:handleCrankTurn(x, y, change)
	if x ~= self.x or y ~= self.y then
		self.x = x
		self.y = y
		self.lastMod = self:moduleAt(x, y)
	end 
	if self.lastMod ~= nil and self.lastMod.turn ~= nil then
		self.lastMod:turn(x, y, change)
	end
end

function ModuleManager:ghostCableShowing()
	return self.ghostCable:isShowing()
end

function ModuleManager:dropCable()
	self.cableStartModule = nil
	self.ghostCable:remove()
	self.ghostCable = PatchCable(true)
	self.ghostCable:hide()
end

function ModuleManager:handleCableAt(x, y, onMessage)
	local module = self:moduleAt(x, y)
	if module ~= nil then
		if self.ghostCable:inFree() then
			self.cableOriginModSubtype = module.modSubtype
			print("Ghost cable setting IN to OUT of module " .. module:type())
			if module.tryConnectGhostOut ~= nil then
				local inConnect = module:tryConnectGhostOut(x, y, self.ghostCable)
				if inConnect then
					self.cableStartModule = module
					self.ghostCable:setEnd(x+1, y+1)--avoid same start and end
					self.ghostCable:show()
					self:playJackSound()
				end
			end
		elseif self.ghostCable:outFree() then
			print("Ghost cable setting OUT to IN of module " .. module.modSubtype .. " source type: " .. self.cableOriginModSubtype)
			-- First check if the socket can accept the signal from the source module:
			-- Audio sources can't output to clocks or sequencers
			if self.cableOriginModSubtype == "audio_gen" and module.modSubtype == "clock_router" then 
				if onMessage ~= nil then onMessage("This input requires a clock/value signal") end
				return 
			elseif self.cableOriginModSubtype == "audio_gen" and module.modSubtype == "midi" then
				if onMessage ~= nil then onMessage("This input requires a clock/value signal") end
				return 
		 	elseif self.cableOriginModSubtype == "audio_effect" and module.modSubtype == "clock_router" then
				if onMessage ~= nil then onMessage("This input requires a clock/value signal") end
			  return 
			elseif self.cableOriginModSubtype == "audio_effect" and module.modSubtype == "midi" then 
				if onMessage ~= nil then onMessage("This input requires a clock/value signal") end
				return 
			end
			
			--Now let target module decide if it wants the cable:
			local outConnect = false
			if module.tryConnectGhostIn ~= nil then
				outConnect = module:tryConnectGhostIn(x, y, self.ghostCable, self.cableOriginModSubtype, function(message) 
					print("Mod tryConnectIn message: " .. message)
					if onMessage ~= nil then onMessage(message) end
				end)
			end
			if outConnect then
				local reifiedCable = PatchCable(false)
				self.ghostCable:clone(reifiedCable)
				
				reifiedCable:setStartModId(self.cableStartModule.modId)
				self.cableStartModule:setOutCable(reifiedCable)
				
				print("cableStartModule MOD TYPE: " .. self.cableStartModule.modSubtype)
				
				if self.cableStartModule.modSubtype == "audio_gen" then
					print("... found audio_gen, setting setStartAudioModId to " .. self.cableStartModule.modId)
					reifiedCable:setStartAudioModId(self.cableStartModule.modId)
					local channel = self.audioManager:getChannel(self.cableStartModule.modId)
					if module.setChannel ~= nil then 
						module:setChannel(channel, function(nextAudioModId) 
							self:setModChannel(nextAudioModId, channel)
						end) 
					end
					
				elseif self.cableStartModule.modSubtype == "audio_effect" then 
					local hostModId = self.cableStartModule:getHostAudioModId()
					print("... found audio_effect: " .. self.cableStartModule.modId)
					if hostModId ~= nil then
						print("... origin audio gen mod: " .. hostModId)
						local channel = self.audioManager:getChannel(hostModId)
						reifiedCable:setStartAudioModId(hostModId)
						if module.setChannel ~= nil then 
							module:setChannel(channel, function(nextAudioModId) 
									self:setModChannel(nextAudioModId, channel)
							end) 
						end
					else
						print("... No origin audio host available")
					end

				else
					print("... found OTHER")
					reifiedCable:setStartModId(self.cableStartModule.modId)
				end
			
				reifiedCable:setEndModId(module.modId)
				module:setInCable(reifiedCable)
				
				self:playJackSound()
				
				table.insert(self.cables, reifiedCable)
			
				self.ghostCable:remove()
				self.ghostCable = PatchCable(true)
				self.ghostCable:hide()
			end
		end
	end
end

function ModuleManager:moveModule(module, x, y)
	if module.repositionBy ~= nil then
		module:repositionBy(x, y)
		self:moveCables(module, x, y)
	end
end

function ModuleManager:moveCables(module, x, y)
	for i=1,#self.cables do
		local cable = self.cables[i]
		if cable:getStartModId() == module:getModId() then
			cable:repositionStart(x, y)
		elseif cable:getEndModId() == module:getModId() then
			cable:repositionEnd(x, y)
		end
	end
end

function ModuleManager:finishMove(module)
	for i=1,#self.cables do
		local cable = self.cables[i]
		if cable:getStartModId() == module:getModId() then
			cable:finishReposition()
		elseif cable:getEndModId() == module:getModId() then
			cable:finishReposition()
		end
	end
end

function ModuleManager:playDropSound()
	if gPlaySoundEffects then
		local rate = math.random(7, 12)/10.0
		self.dropSound:setRate(rate)
		self.dropSound:play()
	end
end

function ModuleManager:playJackSound()
	if gPlaySoundEffects then
		local rate = math.random(5, 12)/10.0
		self.jackSound:setRate(rate)
		self.jackSound:play()
		
		if math.random() < 0.25 then
			if math.random() < 0.5 then
				self.humSound1:play()
			else
				self.humSound2:play()
			end
		end
	end
end

function ModuleManager:setModChannel(modId, channel)
	print("Setting channel for id " .. modId)
	local module = self:getById(modId)
	if module ~= nil then
		if module.setChannel ~= nil then
			module:setChannel(channel, function(nextModId, channel)
				self:setModChannel(nextModId, channel)
			end)
		end
	else
		print("setModChannel() no mod for id: " .. modId)
	end
end

function ModuleManager:getById(moduleId)
	print("getById() looking for " .. moduleId)
	for i=1,#self.modules do
		local aModule = self.modules[i]
		print("getById() comparing " .. aModule:getModId())
		if aModule.getModId ~= nil and aModule:getModId() == moduleId then
			return aModule, i
		end
	end
	print("getById() did not find id: " .. moduleId)
	return nil
end

function ModuleManager:moduleAt(x, y)
	for i=1,#self.modules do
		local aModule = self.modules[i]
		if aModule:collision(x, y) then
			return aModule, i
		end
	end
	
	return nil
end

function ModuleManager:collides(x, y)
	for i=1,#self.modules do
		local aModule = self.modules[i]
		if aModule:collision(x, y) then
			return true
		end
	end
	
	return false
end

function ModuleManager:getGhostSprite(type)
	local name = type
	
	--samplers
	if name == "HexagramMod" then
		return HexagramMod.ghostModule()
	elseif name == "MidiKeyboardMod" then
		return MidiKeyboardMod.ghostModule()
	elseif name == "SamplePlayMod" then
		return SamplePlayMod.ghostModule()
	elseif name == "SamplerMod" then
		return SamplerMod.ghostModule()
	elseif name == "LooperMod" then
		return LooperMod.ghostModule()
	elseif name == "GranularMod" then
		return GranularMod.ghostModule()
	end
	
	if name == "PedalMod" then
		return PedalMod.ghostModule()
	elseif name == "SerialBangMod" then
		return SerialBangMod.ghostModule()
	elseif name == "ToClockMod" then
		return ToClockMod.ghostModule()
	end
	
	--synths
	if name == "SynthMod" then
		return SynthMod.ghostModule()
	elseif name == "SampleSynthMod" then
		return SampleSynthMod.ghostModule()
	elseif name == "WavetableSynthMod" then
		return WavetableSynthMod.ghostModule()
	elseif name == "WavetableSynth2DMod" then
		return WavetableSynth2DMod.ghostModule()
	elseif name == "WavetableHzMod" then
		return WavetableHzMod.ghostModule()
	elseif name == "MicroSynthMod" then
		return MicroSynthMod.ghostModule()
	elseif name == "NoiseBoxMod" then
		return NoiseBoxMod.ghostModule()
	elseif name == "StochasticSineMod" then
		return StochasticSineMod.ghostModule()
	elseif name == "StochasticSquareMod" then
		return StochasticSquareMod.ghostModule()
	elseif name == "StochasticTriMod" then
		return StochasticTriMod.ghostModule()
	end
	
	--sequencers
	if name == "SeqGridMod" then
		return SeqGridMod.ghostModule()
	elseif name == "DroneSeqMod" then
		return DroneSeqMod.ghostModule()
	elseif name == "RandomRepeaterMod" then
		return RandomRepeaterMod.ghostModule()
	elseif name == "RandomShifterMod" then
		return RandomShifterMod.ghostModule()
	elseif name == "BouncingBallClockMod" then
		return BouncingBallClockMod.ghostModule()
	end
	
	--midi
	if name == "MidiNoteEmitterMod" then
		return MidiNoteEmitterMod.ghostModule()
	end
	
	if name == "ArpMod" then
		return ArpMod.ghostModule()
	elseif name == "Merge2Mod" then
		return Merge2Mod.ghostModule()
	elseif name == "Bifurcate2Mod" then
		return Bifurcate2Mod.ghostModule()
	elseif name == "Bifurcate4Mod" then
		return Bifurcate4Mod.ghostModule()
	elseif name == "BitcrusherMod" then
		return BitcrusherMod.ghostModule()
	elseif name == "BlackholeMod" then
		return BlackholeMod.ghostModule()
	elseif name == "Clock2Mod" then
		return Clock2Mod.ghostModule()
	elseif name == "ClockDelayMod" then
		return ClockDelayMod.ghostModule()
	elseif name == "DelayMod" then
		return DelayMod.ghostModule()
	elseif name == "DrumMod" then
		return DrumMod.ghostModule()
	elseif name == "HighpassMod" then
		return HighpassMod.ghostModule()
	elseif name == "LowpassMod" then
		return LowpassMod.ghostModule()
	elseif name == "MidiGenMod" then
		return MidiGenMod.ghostModule()
	elseif name == "MidiGenBouncyBallMod" then
		return MidiGenBouncyBallMod.ghostModule()
	elseif name == "Mix1Mod" then
		return Mix1Mod.ghostModule()
	elseif name == "Mix1v2Mod" then
		return Mix1v2Mod.ghostModule()
	elseif name == "Mix4SliderMod" then
		return Mix4SliderMod.ghostModule()
	elseif name == "Mix4Mod" then
		return Mix4Mod.ghostModule()
	elseif name == "OscillatorMod" then
		return OscillatorMod.ghostModule()	
	elseif name == "Oscillator2Mod" then
		return Oscillator2Mod.ghostModule()	
	elseif name == "OnePoleFilterMod" then
		return OnePoleFilterMod.ghostModule()
	elseif name == "OR606Mod" then
		return OR606Mod.ghostModule()
	elseif name == "OR808Mod" then
		return OR808Mod.ghostModule()
	elseif name == "OR909Mod" then
		return OR909Mod.ghostModule()
	elseif name == "OverdriveMod" then
		return OverdriveMod.ghostModule()
	elseif name == "RingModulatorMod" then
		return RingModulatorMod.ghostModule()
	elseif name == "NormalisedToMidiMod" then
		return NormalisedToMidiMod.ghostModule()	
	elseif name == "ClockDividerMod" then
		return ClockDividerMod.ghostModule()
	elseif name == "PrintMod" then
		return PrintModule.ghostModule()
	elseif name == "RandomMod" then
		return RandomMod.ghostModule()
	elseif name == "SwitchMod" then
		return SwitchMod.ghostModule()
	elseif name == "TimedSwitchMod" then
		return TimedSwitchMod.ghostModule()
	elseif name == "SwitchSPDTMod" then
		return SwitchSPDTMod.ghostModule()
	elseif name == "LabelMod" then
		return LabelMod.ghostModule()
	elseif name == "LargeLabelMod" then
		return LargeLabelMod.ghostModule()
	elseif name == "ArrowMod" then
		return ArrowMod.ghostModule()
	elseif name == "ImageMod" then
		return ImageMod.ghostModule()
	elseif name == "ButtonMod" then
		return ButtonMod.ghostModule()
	elseif name == "KeyboardMod" then
		return KeyboardMod.ghostModule()
	elseif name == "XYTiltMod" then
		return XYTiltMod.ghostModule()
	elseif name == "YTiltMod" then
		return YTiltMod.ghostModule()
	elseif name == "SerialInMod" then
		return SerialInMod.ghostModule()
	elseif name == "SerialClockMod" then
		return SerialClockMod.ghostModule()
	elseif name == "PongMod" then
		return PongMod.ghostModule()
	elseif name == "GameOfLifeMod" then
		return GameOfLifeMod.ghostModule()
	end
end

function ModuleManager:addNewLabelAt(type, label, x, y)
	self.label = label
	self:addNewAt(type, x, y)
end

function ModuleManager:addNewAt(type, x, y)
	print("ADD NEW " .. type)
	local name = type
	self:playDropSound()
	--samplers
	if name == "HexagramMod" then
		self:addNew(HexagramMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
		return
	elseif name == "MidiKeyboardMod" then
		self:addNew(MidiKeyboardMod(x, y, nil))
		return
	elseif name == "SamplerMod" then
		self:addNew(SamplerMod(x, y, nil))
		return
	elseif name == "LooperMod" then
		self:addNew(LooperMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
		return
	elseif name == "SamplePlayMod" then
		self:addNew(SamplePlayMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
		return
	elseif name == "GranularMod" then
		local granularMod = GranularMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end)
		table.insert(self.granularMods, granularMod)
		self:addNew(granularMod)
		return
	elseif name == "SerialBangMod" then
		local bangMod = SerialBangMod(x, y, nil)
		table.insert(self.bangMods, bangMod)
		self:addNew(bangMod)
		return
	end
	
	if name == "PedalMod" then
		self:addNew(PedalMod(x, y, nil))
		return
	end
	
	if name == "ToClockMod" then
		self:addNew(ToClockMod(x, y, nil))
		return
	end
	
	--synths
	if name == "SynthMod" then
		self:addNew(SynthMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
		return
	elseif name == "SampleSynthMod" then
		self:addNew(SampleSynthMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
		return
	elseif name == "WavetableSynthMod" then
		self:addNew(WavetableSynthMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
		return
	elseif name == "WavetableSynth2DMod" then
		self:addNew(WavetableSynth2DMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
		return
	elseif name == "WavetableHzMod" then
		self:addNew(WavetableHzMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
		return
	elseif name == "MicroSynthMod" then
		self:addNew(MicroSynthMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
		return
	elseif name == "NoiseBoxMod" then
		self:addNew(NoiseBoxMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
		return
	elseif name == "StochasticSineMod" then
		self:addNew(StochasticSineMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
		return
	elseif name == "StochasticSquareMod" then
		self:addNew(StochasticSquareMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
		return
	elseif name == "StochasticTriMod" then
		self:addNew(StochasticTriMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
		return
	end
	
	--Sequencers
	if name == "ArpMod" then
		self:addNew(ArpMod(x, y))
		return
	elseif name == "SeqGridMod" then
		self:addNew(SeqGridMod(x, y, nil))
		return
	elseif name == "DroneSeqMod" then
		self:addNew(DroneSeqMod(x, y, nil))
		return
	elseif name == "RandomRepeaterMod" then
		self:addNew(RandomRepeaterMod(x, y, nil))
		return
	elseif name == "RandomShifterMod" then
		self:addNew(RandomShifterMod(x, y, nil))
		return
	elseif name == "BouncingBallClockMod" then
		self:addNew(BouncingBallClockMod(x, y, nil))
		return
	end
	
	--Drum machines
	if name == "OR606Mod" then
		self:addNew(OR606Mod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
		return
	elseif name == "OR808Mod" then
		self:addNew(OR808Mod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
		return
	elseif name == "OR909Mod" then
		self:addNew(OR909Mod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
		return
	end
	
	if name == "Bifurcate2Mod" then
		self:addNew(Bifurcate2Mod(x, y))
	elseif name == "Merge2Mod" then
		self:addNew(Merge2Mod(x, y))
	elseif name == "Bifurcate4Mod" then
		self:addNew(Bifurcate4Mod(x, y))
	elseif name == "BitcrusherMod" then
		self:addNew(BitcrusherMod(x, y))
	elseif name == "BlackholeMod" then
		self:addNew(BlackholeMod(x, y))
	elseif name == "Clock2Mod" then
		self:addNew(Clock2Mod(x, y))
	elseif name == "ClockDelayMod" then
		self:addNew(ClockDelayMod(x, y))
	elseif name == "DelayMod" then
		self:addNew(DelayMod(x, y))
	elseif name == "DrumMod" then
		self:addNew(DrumMod(x, y, nil, function(modId, channel) 
			self:addToAudioManager(modId, channel)
		end))
	elseif name == "HighpassMod" then
		self:addNew(HighpassMod(x, y))
	elseif name == "LowpassMod" then
		self:addNew(LowpassMod(x, y))
	elseif name == "MidiGenMod" then
		self:addNew(MidiGenMod(x, y))
	elseif name == "MidiGenBouncyBallMod" then
		self:addNew(MidiGenBouncyBallMod(x, y))
	elseif name == "Mix1Mod" then
		self:addNew(Mix1Mod(x, y))
	elseif name == "Mix1v2Mod" then
		self:addNew(Mix1v2Mod(x, y))
	elseif name == "Mix4Mod" then
		self:addNew(Mix4Mod(x, y))
	elseif name == "Mix4SliderMod" then
		self:addNew(Mix4SliderMod(x, y))
	elseif name == "OscillatorMod" then
		self:addNew(OscillatorMod(x, y))
	elseif name == "Oscillator2Mod" then
		self:addNew(Oscillator2Mod(x, y))
	elseif name == "OnePoleFilterMod" then
		self:addNew(OnePoleFilterMod(x, y))
	elseif name == "OverdriveMod" then
		self:addNew(OverdriveMod(x, y))
	elseif name == "RingModulatorMod" then
		self:addNew(RingModulatorMod(x, y))
	elseif name == "NormalisedToMidiMod" then
		self:addNew(NormalisedToMidiMod(x, y))
	elseif name == "ClockDividerMod" then
		self:addNew(ClockDividerMod(x, y))
	elseif name == "PrintMod" then
		self:addNew(PrintModule(x, y))
	elseif name == "RandomMod" then
		self:addNew(RandomMod(x, y))
	elseif name == "SeqGridMod" then
		self:addNew(SeqGridMod(x, y))
	elseif name == "SwitchMod" then
		self:addNew(SwitchMod(x, y))
	elseif name == "TimedSwitchMod" then
		self:addNew(TimedSwitchMod(x, y))
	elseif name == "SwitchSPDTMod" then
		self:addNew(SwitchSPDTMod(x, y))
	elseif name == "LabelMod" then
		local labelMod = LabelMod(x, y)
		labelMod:setLabel(self.label)
		self:addNew(labelMod)
	elseif name == "LargeLabelMod" then
		local largeLabelMod = LargeLabelMod(x, y)
		largeLabelMod:setLabel(self.label)
		self:addNew(largeLabelMod)
	elseif name == "ArrowMod" then
		self:addNew(ArrowMod(x, y))
	elseif name == "ImageMod" then
		self:addNew(ImageMod(x, y))
	elseif name == "ButtonMod" then
		self:addNew(ButtonMod(x, y))
	elseif name == "KeyboardMod" then
		self:addNew(KeyboardMod(x, y))	
	elseif name == "XYTiltMod" then
		self:addNew(XYTiltMod(x, y))
	elseif name == "YTiltMod" then
		self:addNew(YTiltMod(x, y))
	elseif name == "SerialInMod" then
		local serialInMod = SerialInMod(x, y)
		self.serialModule = serialInMod
		self:addNew(serialInMod)
	elseif name == "SerialClockMod" then
		local serialClockMod = SerialClockMod(x, y)
		self.serialClockModule = serialClockMod
		self:addNew(serialClockMod)
	elseif name == "PongMod" then
		self:addNew(PongMod(x, y))
	elseif name == "GameOfLifeMod" then
		self:addNew(GameOfLifeMod(x, y))
	end
	
	--midi
	if name == "MidiNoteEmitterMod" then
		self:addNew(MidiNoteEmitterMod(x, y))
	end
end

function ModuleManager:addToAudioManager(modId, channel)
	if channel == nil then
		print("ModId: " .. modId .. " NO CHANNEL")
	else
		print("ModId: " .. modId .. " HAS CHANNEL!")
	end
	self.audioManager:addChannel(modId, channel)
end

function ModuleManager:addNew(module)
	table.insert(self.modules, module)
end

function ModuleManager:removeModule(index)
	print("ModuleManager:removeModule() XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
	print("ModuleManager:removeModule() index: " .. index)
	for i=1, #self.modules do
		print("ModuleManager:removeModule() current modules: modId: " .. self.modules[i].modId)
	end
	table.remove(self.modules, index)
	print("ModuleManager:removeModule() index: " .. index .. " removed")
	for i=1, #self.modules do
		print("ModuleManager:removeModule() remaining modules: modId: " .. self.modules[i].modId)
	end
	print("ModuleManager:removeModule() XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
end

function ModuleManager:map(onMap)
	print("Preparing map")
	self:screenshot(function(mapFile) 
		if mapFile~= nil then
			local screenshot = gfx.image.new("images/map") 
			local sW, sH = screenshot:getSize()
			
			print("Map source width " .. sW .. " source height: " .. sH)
			local mapImage = nil
			if sW < sH or sW == sH then
				local scaleFactor = 240.0/sH
				scaleFactor = 0.5
				print("Using height scale factor for map: " .. scaleFactor)
				mapImage = screenshot:scaledImage(scaleFactor)
			else
				local scaleFactor = 400.0/sW
				scaleFactor = 0.5
				print("Using width scale factor for map: " .. scaleFactor)
				mapImage = screenshot:scaledImage(scaleFactor)
			end 
			
			
			local scaledW, scaleH = mapImage:getSize()
			print("Map scaled width " .. scaledW .. " scaled height: " .. scaleH)
			
			-- local scale = math.ceil(400 / sW)
			-- mapImage = screenshot:scaledImage(scale)
			
			onMap(mapImage)
		end
	end)
end

function ModuleManager:screenshot(onScreenshotComplete)
	if #self.modules == 0 then
		print("Nothing to screenshot")
		onScreenshotComplete()
		return
	end
	
	self.onScreenshotComplete = onScreenshotComplete
	
	self.shutterPlayer = playdate.sound.sampleplayer.new("shutter")
	local minX =  100000
	local maxX = -100000
	local minY =  100000
	local maxY = -100000
	local minWidth = 50
	local minHeight = 50
	local maxWidth = 50
	local maxHeight = 50
	for i=1,#self.modules do
		local module = self.modules[i]
		local pX, pY = module:getPosition()
		local mX = module.x
		local mY = module.y
		local mW = module.width
		local mH = module.height
		
		print("Module: pX: " .. pX .. " pY: " .. pY.. " mX: " .. mX .. " mY: " .. mY)
		
		if mX < minX then minX = mX end 
		if mX > maxX then maxX = mX end 
		if mY < minY then minY = mY end
		if mY > maxY then maxY = mY end
	end
	
	self.initXOffset = globalXDrawOffset
	self.initYOffset = globalYDrawOffset
		
	self.minXLoc = (-1 * minX) + 200
	self.minYLoc = (-1 * minY) + 120
	
	self.maxXLoc = (-1 * maxX) + 200
	self.maxYLoc = (-1 * maxY) + 120

	
	local heightDiff =	minY -  maxY 
	local rows = math.abs(math.floor(heightDiff/240)) + 1

	
	local widthDiff = minX -  maxX
	local columns = math.abs(math.floor(widthDiff/400)) + 1

	self.screenshotRows = rows
	self.screenshowColumns = columns
	
	self.screenshotRow = 1
	self.screenshowColumn = 1
	
	self.screenshotFilenames = {}
	
	gSuppressToast = true
	
	self:nextScreenshot()
end

function ModuleManager:processScreenshotQueue()
	if self.screenshowColumn < self.screenshowColumns then
		self.screenshowColumn +=1
		self:nextScreenshot()
	else
		self.screenshowColumn = 1
		self.screenshotRow += 1
		
		if self.screenshotRow > self.screenshotRows then
			print("Screenshots FINISHED")
			gSuppressToast = false
			--todo - now what....
			local outputImage = playdate.graphics.image.new((self.screenshowColumns) * 400, (self.screenshotRows) * 240)
			playdate.graphics.pushContext(outputImage)
			
			local filenameIndex = 1
			for r = 1, self.screenshotRows do
			for c = 1, self.screenshowColumns do
				
					local filename = self.screenshotFilenames[filenameIndex]
					filenameIndex += 1
					local imagePath = "images/" .. filename:gsub("%.pdi", "")
					
					local img = playdate.graphics.image.new(imagePath)
					local iX = (c-1) * 400
					local iY = (r-1) * 240
					print("r=" .. r .. " c=" .. c .." Drawing " .. imagePath .. " at x: " .. iX .. " y: " .. iY)
					img:draw(iX, iY)
				end
			end
			
			playdate.graphics.popContext()
			
			local epoch = playdate.epochFromTime(playdate.getTime())
			local outputFile = "patch-" .. epoch .. ".gif"
			local mapFile = "map.pdi"
			playdate.datastore.writeImage(outputImage, outputFile)
			playdate.datastore.writeImage(outputImage, mapFile)
			playdate.datastore.writeImage(outputImage, "map_check.gif")
			
			for i=1, #self.screenshotFilenames do
				local filename = self.screenshotFilenames[i]
				local imagePath = "images/" .. filename
				print("Deleting: " .. imagePath)
				playdate.file.delete(imagePath)
			end
			self.screenshotFilenames = {}

			playdate.graphics.setDrawOffset(self.initXOffset, self.initYOffset)
			
			self.shutterEndPlayer = playdate.sound.sampleplayer.new("shutter_end")
			self.shutterEndPlayer:play()
			
			if self.onScreenshotComplete ~= nil then self.onScreenshotComplete(outputFile) end
		else
			self:nextScreenshot()
		end
	end
end

function ModuleManager:nextScreenshot()
	
		local xxx = self.minXLoc - ((self.screenshowColumn-1) * 400)
		local yyy = self.minYLoc - ((self.screenshotRow-1) * 240)

		playdate.graphics.setDrawOffset(xxx, yyy)
		
		playdate.timer.performAfterDelay(150, function() 
			local panel = playdate.graphics.getDisplayImage()
			local filename = "panel_" .. self.screenshotRow .. "_" .. self.screenshowColumn .. ".pdi"
			playdate.datastore.writeImage(panel, filename)
			table.insert(self.screenshotFilenames, filename)
			self:processScreenshotQueue()
			self.shutterPlayer:play()
		end)
end