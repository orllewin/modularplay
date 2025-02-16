class('MainMenuFactory').extends()

function MainMenuFactory:init()
	MainMenuFactory.super.init(self)
end

function MainMenuFactory:getMenuModList()
	
	local synths = {
			category = "Synths",
			mods = {
				{
					label = "Wavetable Synth",
					action = "WavetableSynthMod"
				},
				{
					label = "2D WT Synth",
					action = "WavetableSynth2DMod"
				},
				{
					label = "ORL Sample Synth",
					action = "SampleSynthMod"
				},
				{
					label = "ORL Synth",
					action = "SynthMod"
				},
				{
					label = "Noise Box",
					action = "NoiseBoxMod"
				},
				{
					label = "Micro Synth",
					action = "MicroSynthMod"
				},
				{
					label = "Stochastic Sine",
					action = "StochasticSineMod"
				},
				{
					label = "Stochastic Square",
					action = "StochasticSquareMod"
				},
				{
					label = "Stochastic Triangle",
					action = "StochasticTriMod"
				},
				{
					label = "Wavetable Sig-gen",
					action = "WavetableHzMod"
				}
			}
		}
	
	local ui = nil
	if gProdBuild then
		ui = {
			category = "UI",
			mods = {
				{
					label = "Label (Regular)",
					action = "LabelMod"
				},
				{
					label = "Label (Large)",
					action = "LargeLabelMod"
				},
				{
					label = "Label Arrow",
					action = "ArrowMod"
				}
			}
		}
	else
		ui = {
			category = "UI",
			mods = {
				{
					label = "Button",
					action = "ButtonMod"
				},
				{
					label = "Input Keyboard",
					action = "KeyboardMod"
				},
				{
					label = "Label (Regular)",
					action = "LabelMod"
				},
				{
					label = "Label (Large)",
					action = "LargeLabelMod"
				},
				{
					label = "Label Arrow",
					action = "ArrowMod"
				}
			}
		}
	end
	

--note removed NormalisedToMidiMod until it's all Norns scales have been added
--and ui reworked:
-- {
-- 	label = "Value-to-Midi",
-- 	action = "NormalisedToMidiMod"
-- },
-- removed, needs testing, can't remember how effective it is, may need tweaking:
-- {
-- 	label = "One Pole",
-- 	action = "OnePoleFilterMod"
-- },
	
	return {
		{
			category = "File",
			mods = {
				{
					label = "New",
					action = "setting_new_file"
				},
				{
					label = "Load",
					action = "setting_load_file"
				},
				{
					label = "Save",
					action = "setting_save_file"
				},
				{
					label = "Save as",
					action = "setting_saveas_file"
				},
				{
					label = "Delete",
					action = "setting_delete_file"
				}
			}
		},
		{
			category = "Clock",
			mods = {
				{
					label = "Clock",
					action = "Clock2Mod"
				},
				{
					label = "Bubble Chamber",
					action = "BouncingBallClockMod"
				},
				{
					label = "Delay",
					action = "ClockDelayMod"
				},
				{
					label = "Divider",
					action = "ClockDividerMod"
				},
				{
					label = "Coerce to Clock",
					action = "ToClockMod"
				}
			}
		},
		{
			category = "Core",
			mods = {
				{
					label = "Midi Keyboard",
					action = "MidiKeyboardMod"
				},
				{
					label = "Pedal",
					action = "PedalMod"
				},
				{
					label = "Random",
					action = "RandomMod"
				},
				{
					label = "Oscillator",
					action = "OscillatorMod"
				},
				{
					label = "Oscillator2",
					action = "Oscillator2Mod"
				},
				{
					label = "Merge x2",
					action = "Merge2Mod"
				},
				{
					label = "Bifurcate x2",
					action = "Bifurcate2Mod"
				},
				{
					label = "Bifurcate x4",
					action = "Bifurcate4Mod"
				},
				{
					label = "Blackhole",
					action = "BlackholeMod"
				},
				{
					label = "XY Tilt",
					action = "XYTiltMod"
				},
				{
					label = "Y Tilt",
					action = "YTiltMod"
				},
				{
					label = "Print/Log",
					action = "PrintMod"
				}
			}
		},
		{
			category = "Sequencers",
			mods = {
				{
					label = "Generative std.",
					action = "MidiGenMod"
				},
				{
					label = "Generative rnd.",
					action = "MidiGenBouncyBallMod"
				},
				{
					label = "Arpseq",
					action = "ArpMod"
				},
				{
					label = "Micro Sequencer",
					action = "SeqGridMod"
				},
				{
					label = "Droneseq",
					action = "DroneSeqMod"
				},
			}
		},
		{
			category = "Midi/Seq Utils",
			mods = {
				{
					label = "Random Repeater",
					action = "RandomRepeaterMod"
				},
				{
					label = "Random Shifter",
					action = "RandomShifterMod"
				},
				{
					label = "Linear Switch",
					action = "SwitchMod"
				},
				{
					label = "Dual Switch",
					action = "SwitchSPDTMod"
				},
				{
					label = "Timed Switch",
					action = "TimedSwitchMod"
				},
			}
		},
		{
			category = "Drums",
			mods = {
				{
					label = "Orl Drum Machine",
					action = "DrumMod"
				},
				{
					label = "OR-606",
					action = "OR606Mod"
				},
				{
					label = "OR-808",
					action = "OR808Mod"
				},
				{
					label = "OR-909",
					action = "OR909Mod"
				}
			}
		},
		synths,
		{
			category = "Samplers",
			mods = {
				{
					label = "Sample Record",
					action = "SamplerMod"
				},
				{
					label = "Sample Play",
					action = "SamplePlayMod"
				},
				{
					label = "Hexagram",
					action = "HexagramMod"
				},
				{
					label = "Granular",
					action = "GranularMod"
				},
				{
					label = "Looper",
					action = "LooperMod"
				},
			}
		},
		{
			category = "Effects",
			mods = {
				{
					label = "Krush",
					action = "BitcrusherMod"
				},
				{
					label = "Delay",
					action = "DelayMod"
				},
				{
					label = "Lo-pass",
					action = "LowpassMod"
				},
				{
					label = "Hi-pass",
					action = "HighpassMod"
				},
				{
					label = "Overdrive",
					action = "OverdriveMod"
				},
				{
					label = "Ring Modulator",
					action = "RingModulatorMod"
				},
			}
		},
		{
			category = "Output",
			mods = {
				{
					label = "Output Basic",
					action = "Mix1v2Mod"
				},
				{
					label = "Output Single",
					action = "Mix1Mod"
				},
				{
					label = "4 Channel",
					action = "Mix4Mod"
				},
				{
					label = "4 Channel Pro",
					action = "Mix4SliderMod"
				},
			}
		},
		ui,
		{
			category = "Serial Interface",
			mods = {
				{
					label = "Serial Bang Input",
					action = "SerialBangMod"
				},
				{
					label = "Serial Note Input",
					action = "SerialInMod"
				},
				{
					label = "Serial Clock Input",
					action = "SerialClockMod"
				},
			}
		},
		{
			category = "System",
			mods = {
				{
					label = "Show FPS",
					action = "prefs_show_fps",
					type = "checkbox",
					checked = gShowFPS
				},
				{
					label = "Play sound fx",
					action = "prefs_play_soundfx",
					type = "checkbox",
					checked = gPlaySoundEffects
				},
				{
					label = "Invert display",
					action = "prefs_invert_display",
					type = "checkbox",
					checked = gInvertDisplay
				},
				{
					label = "Open Tutorial",
					action = "setting_open_tutorial"
				},
				{
					label = "Screenshot",
					action = "setting_screenshot"
				},
				{
					label = "Pong",
					action = "PongMod"
				},
				{
					label = "Game of Life",
					action = "GameOfLifeMod"
				}
			}
		}
	}
end