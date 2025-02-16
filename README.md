# Modular Play for Playdate

A pluggable modular-style music making playground with cables.

# Building

Download the Playdate SDK: [sdk.play.date](https://sdk.play.date/) and install [Nova](https://nova.app/). Open the repo in Nova and activate the *Playdate Simulator* task in Project Settings.

# Contributing

This beast of a project grew from a basic proof-of-concept where cables were dragged between a few modules and events propagated from one to another. The original developer did/does not know Lua well which should be obvious to anyone browsing the code. 

Each module follows some basic conventions instead of having tight contracts/interfaces (which may or may not be possible in Lua, I have no idea, I was having too much fun building this thing and didn't think to learn Lua properly), when hunting the root cause of bugs 90% can be found in a bad implementation of some core ideas, most likely they fail to detach a cable properly when deleting an attached module leaving things in a broken state (a lot of bugs can be replicated by following steps reported by users that generally involve adding, then deleting, a certain module). 

The save/load process is also a likely source of lots of bugs - modules serialise themselves to json and back again, any missteps in that logic will leave a newly opened patch in a bad state. 

Modular Play _really_ pushes the Playdate - as well as wrapping the audio engine the ui is complex and patches can have a few dozen modules each with multiple cables all in a scrollable canvas. Redraws should be minimised as much as possible (even down to step size on rotary encoders), and new modules should perform well as part of a larger patch. Live updates to the module ui should be avoided where possible to minimise the redraw load. 

The 'Granular' module is the latest (and buggiest) module, it's a good example of what not to do, has too much ui refreshing. In fact if I was doing this again I'd limit sample handling to a single simple module that plays a single sample when triggered, nothing more.  

The project will continue to be sold at [orllewin.itch.io/modularplay](https://orllewin.itch.io/modularplay) but for a reduced price (TBD, probably £5). **Licence also TBD**. If anyone contributes significantly I'm open to some kind of informal profit sharing in the future (but honestly it doesn't make much).   

## Modules

Each module has a parent `module_mod.lua` with a child `module_component.lua`. The module should generally handle ui, with the component handling the core functionality (clock events, audio, effects etc). 

### init

Each module has a init method with an x,y coordinate and a nullable modId:

```
function MyModule:init(xx, yy, modId)
  MyModule.super.init(self)
  
  if modId == nil then
    self.modId = modType .. playdate.getSecondsSinceEpoch()
  else
    self.modId = modId
  end
  
  ...
```

The modId is passed when resurrecting a module from a save file, otherwise a new unique Id is created (mod type plus epoch seconds). The rest of `init` depends on the module but as much of the ui should be pre-calculated here as possible. 

### turn

If the module has controls that can be cranked if should have a `turn` method with `x`, `y`, `change` parameters. The coordinates are used where a module has multiple encoders, so it can find which is closest to the global caret.

### handleModClick

Same as above. To handle button clicks, and also displaying the module menu.

### tryConnectGhostIn, tryConnectGhostOut

Cables are 'ghosts' before they're reified. The system will try and connect a ghost cable to the nearest socket and do some validation (is the signal type correct (you can't connect audio to a clock for example), are all sockets occupied already etc), using the Blackhole mod as an example:

```
function BlackholeMod:tryConnectGhostIn(x, y, ghostCable, sourceSubtype, onError)
  if sourceSubtype ~= "clock_router" and sourceSubtype ~= "midi" then 
    if onError ~= nil then onError("This input requires a clock or midi signal") end
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
```

### setInCable, setOutCable

When a cable is dropped with both its start and end connected the ghost cable becomes reified. 

### evaporate

When a module is deleted its `evaporate` method is called, the module should clean up here, calling any attached modules using the `onDetachConnected` callback with each cable (each attached module will have its `unplug` method called with a cable id, see below). Example from the main clock module:

```
function Clock2Mod:evaporate(onDetachConnected)
  print("Clock2Mod evaporate removing cables")
  self.component:stop()
  --first detach cables
  if self.component:aConnected() then
    onDetachConnected(self.outACable:getEndModId(), self.outACable:getCableId())
    self.component:unplugA()
    self.outACable:evaporate()
  end
  
  if self.component:bConnected() then
    onDetachConnected(self.outBCable:getEndModId(), self.outBCable:getCableId())
    self.component:unplugB()
    self.outBCable:evaporate()
  end
  
  if self.component:cConnected() then
    onDetachConnected(self.outCCable:getEndModId(), self.outCCable:getCableId())
    self.component:unplugC()
    self.outCCable:evaporate()
  end
  
  if self.component:dConnected() then
    onDetachConnected(self.outDCable:getEndModId(), self.outDCable:getCableId())
    self.component:unplugC()
    self.outDCable:evaporate()
  end
  
  --then remove sprites
  self.clockEncoder:evaporate()
  playdate.graphics.sprite.removeSprites({self.labelSprite})
  self.clockEncoder = nil
  self.labelSprite = nil
  self:remove()
end
```

### unplug

When a module is deleted all its attached modules should be told to unplug their connected cables first - this lets connected modules set themselves back into a suitable state. 

### ghostModule

When adding a new module it should generate a lightweight 'ghost' sprite so the user can position it on-screen without drawing all child elements/sprites. 

### toState, fromState

`toState` describes a module as a JSON object so it can be saved. This includes everything needed to resurrect it. Likewise `fromState` has a JSON object argument that should contain everything needed to resurrect itself. Here be dragons and a likely cause of bugs.

---

### Audio

Adding and removing audio modules is particularly complex; Modular Play is a wrapper around the Playdate audio engine, adding and removing effects and audio sources out of sequence creates a tricky problem where the system needs to propagate up and down the chain of modules and cables. Another source of bugs, there's plenty of improvements to be made here.


### Cable Routing

Module subtypes:
* `clock_router` - something that manipulates and emits clock signals
* `midi` - something that outputs midi notes
* `audio_gen` - something that makes sound, a synth or effect
* `audio_effect` - something that can receive audio, and also outputs audio
* `other` - something else

Some basic checks are done by the module manager to see if cables can be routed without asking the modules:

```
-- Audio sources can't output to clocks or sequencers
if self.cableOriginModSubtype == "audio_gen" and module.modSubtype == "clock_router" then return end
if self.cableOriginModSubtype == "audio_gen" and module.modSubtype == "midi" then return end
if self.cableOriginModSubtype == "audio_effect" and module.modSubtype == "clock_router" then return end
if self.cableOriginModSubtype == "audio_effect" and module.modSubtype == "midi" then return end
```

`tryConnectGhostOut` now has an additional final argument: `outConnect = module:tryConnectGhostIn(x, y, self.ghostCable, self.cableOriginModSubtype)`

The `cableOriginModSubtype` tells the target module what's at the other end of the cable, so it can decide whether it will allow the connection or not. Unfortunately this needs doing manually in every module and there's 40+ of them. It needs to be done this way because some modules might accept multiple input types.  eg. an effect may have an audio input, as well as value inputs to automate encoder turning.

### Misc

`find . -name '*.lua' | xargs wc -l` - get lines of code in the project

|  |  |
| --- | --- |
| ![](./readme_assets/annoying.jpg) | ![](./readme_assets/theory.png) |
 
