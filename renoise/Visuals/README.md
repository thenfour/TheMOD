GIT:
any assets you need to track, put "TheMod" in the name somewhere.
otherwise you need to add it to here manually.


# setup

atebit

transitions happen on the downbeat. so BPM and BeatsPerMeasure are both very relevant to timings. For snappy transitions, beats=1, BPM=high.
transition time is measured in beats, not time. So the only way to make this sensible is to pick a BPM that will make it so.
60 BPM would mean that 1 beat = 1 second. 60 is pretty slow though. How about 600, so 1 beat = .1 seconds. But it doesn't really matter that much.

by default the "advance to next module" trigger is set to LFO which observes the BPM. so actually, you can change this

themodlivevisuals renoise tool
osc is always UDP

- "M" is for Mute. Green = not muted.
- "A" is for Active, but is actually the exact same as "Mute". Weird huh.
- "U" if green, updates the item even when it's mute/inactive
- "P" is for properties. click it to select it / show properties.

Channel->Layer->Module

Layers don't have transitions between them. Transitions are only available between Modules.
Layers can only have 1 module active at a time.
Since we need at least a fadeout between songs, we will have 1 "empty module" for each layer.
each layer will likely just have 2 modules: ON(shader) and OFF(empty module)

OSC commands:

in order to automate via OSC, you can either create your own OSC trigger, my selecting OSC next to the parameter
and configuring that.

OR, there is a shortcut:
- "Channel A/My layer/Module 3/PositionX 0.5"

though I never actually got that to work. not required anyway.

# launch

- open renoise, load visuals project
- open atebit


# use it

- full screen
- projector usage

# setup concept

there are 7 modules, 6 layers, 2 channels, 1 output
