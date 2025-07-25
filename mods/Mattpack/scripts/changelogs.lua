DeadSeaScrollsMenu.AddChangelog("Lazy MattPack", "V1.1", [[
{FSIZE3} misc
- item conversions will now stop all 
item cycling effects on the pedestal

- removed the repentance_plus check 
for the Repentogon error message

{FSIZE3} tech omega
- fixed the player keeping a permanent 
copy of technology after losing
Tech Omega

- fixed tech omega's laser and sound 
effect staying permanently after
losing the item while shooting

{FSIZE3} boulder bottom
- added holy mantle to the Boulder 
Bottom effects blacklist

{FSIZE3} benighted heart
- increased the force and decreased 
the delay of benighted heart
tears' attraction effect
]]
)

DeadSeaScrollsMenu.AddChangelog("Lazy MattPack", "V1.2", [[{FSIZE3} misc
- added save manager, preventing boulder 
bottom's effects from clearing and 
devil's yo-yo items from re-duping upon
restarting/rewinding

- items can no longer be picked up 
mid-transformation

- rerolled active items no longer 
almost always reroll into f key
((for some reason))

{FSIZE3} knife bender
- homing lasers can now transform
mom's knife into knife bender

{FSIZE3} balor
- balor tears are more consistent, and 
die upon hitting an enemy with the
holy light effect if not piercing

- fixed the balor + ludo tear offset 
being way too low after hitting an enemy

{FSIZE3} multi mush
- multi mush now properly multiplies 
player size

{FSIZE3} boulder bottom
- fixed the boulder bottom blacklist 
not consistently working

- boulder bottom will no longer 
duplicate items that give extra lives

- boulder bottom now swallows trinkets 
added to the inventory by means other
than touching

- boulder bottom now keeps and items 
given by modeling clay, as well as
temporary tear flags from items like
3 dollar bill

{FSIZE3} comically large
{FSIZE3} spoon bender
- clsb ludovico tears no longer stay 
midair forever upon splitting, instead
gaining the eye of the occult effect
with limited airtime

- capped clsb tears' homing strength at 
close enough distances to reduce jank
with piercing

- reduced knockback of tears split by 
clsb

- reduced homing strength of tears split 
more than once by clsb
]]
)

DeadSeaScrollsMenu.AddChangelog("Lazy MattPack", "V1.2.1", [[{FSIZE3} a single fix
fixed devil's yo-yo + damocles
infinitely spawning items
oops it was me who had the mod that
made it impossible to replicate
my bad
]]
)

DeadSeaScrollsMenu.AddChangelog("Lazy MattPack", "V1.2.2", [[{FSIZE3} fixes
- fixed benighted heart's shop price 
being 15 cents rather than 30

- fixed tech omega not firing with 
lilith (temporary fix, not parented
to incubus)

- added damocles api support 

- fixed damocles not working on 
its own, oops

- fixed boulder bottom breaking 
dark esau
]]
)

DeadSeaScrollsMenu.AddChangelog("Lazy MattPack", "V1.3 (Bloated Body!)", [[
{FSIZE3} new item!
{FSIZE2} - bloated body -
{FSIZE2} limitless bursting

- tears will split in 4 on hit 
- split tears will continue splitting on 
hit until they run out of range

- obtained by using jera on cricket's body 
{FSIZE2} --------------------

{FSIZE3} additions
- added "balor screenshake" option 
to the dss config

- knife bender can now absorb a few 
more tear effects based on 
projectile variant

- added mom's knife synergy for 
tech omega

- added character costume functionality 
for kitchen knife

- added kitchen knife costumes for 
dark judas and the forgotten

{FSIZE3} tweaks
- rebalanced balor to have a far less 
punishing tear rate modifier

- tech omega lasers burst out of enemies 
no longer give tech charge to other
segments of the same enemy

- multi mush and balor now icnrease 
their stats further with multiple copies

- reimplemented attractor effect of 
benighted heart lasers

- reduced angle variance of tech omega 
bursts when using the wiz

- improved the look of devil's yo-yo 
during spawning and room changes

- devil's yo-yo now gives one more 
item if a player has damocles

- improved clsb tech x homing distance

- boulder bottom now makes the effects 
of mega blast, red stew, and metronome 
permanent

- reduced damage reduction for non-tech 
omega lasers when holding tech omega

- improved the look of eid hints

{{FSIZE3}} fixes
- fixed issues with damoclesapi + 
devil's yo-yo

- fixed clsb tears sometimes splitting 
to hit a single enemy

- added missing holy card effect to 
boulder bottom blacklist

- fixed errors with balor lasers

- fixed balor knives breakaing after 
the final pierce

- fixed conflict with tech omega and 
tech 5090

- fixed general savedata issues

- fixed non-player balor tears applying 
knockback to the player

- removed (not repentance_plus) check
]])

DeadSeaScrollsMenu.AddChangelog("Lazy MattPack", "V1.3.1", [[
- fixed damoclesapi incompatibility

- fixed some weirdness with boulder
 bottom in the mom's shadow chase

 - added a few eid synergy notes

- forced compatibility with 
[q5] golden brimstone
]])

DeadSeaScrollsMenu.AddChangelog("Lazy MattPack", "V1.3.2", [[
- fixed crash with tainted eden

- fixed various issues with tech omega 
giving permanent technology

- fixed issues when using fiend folio 
with kitchen knife
]])


DeadSeaScrollsMenu.AddChangelog("Lazy MattPack", "V1.4 (Dead Litter!)", [[
{FSIZE3} new item!
{FSIZE2} - dead litter -
{FSIZE2} now where's that
{FSIZE2} fourth one?

- 1.66x damage multiplier
- each shot has a luck-based chance
to be accompanied by one of three
cat-themed effects
(guppy, tammy, or cricket)

- obtained by storing three cat parts
in Moving Box 
{FSIZE2} --------------------

{FSIZE3} additions
- added basic mom's knife synergy 
to bloated body

{FSIZE3} tweaks
- improved implementation of 
mutant mycelium

- explosions caused by the tech 5090 
laser can no longer damage players, 
and have greatly reduced damage 
towards enemies

- tech 5090 laser damage frequency 
is now tied to fire delay

- increased item pool weights of 
quality 5s to be equal to mega 
blast, rather than half of it 
(when the item pool config is set 
to "all items")

- quality 5s that have already been 
spawned by their conditions can no 
longer appear in item pools later 
in the same run (when the item pool 
config is set to "all items")

- tweaked costume priorities of 
various items

- added benighted heart to devil pools 
when "all items" is selected in the 
item pool config

- removed "summonale" tag from balor 
and bloated body

{{FSIZE3}} fixes
- fixed devil's yo-yo infinitely 
damaging the keeper

- fixed devil's yo-yo not 
accounting for bone hearts

- fixed boulder bottom making 
tainted eve instantly re-absorb 
her blood clots if she has used 
Sumptorium at least once
]])


DeadSeaScrollsMenu.AddChangelog("Lazy MattPack", "V1.5 (Divine Heart!)", [[
{FSIZE3} new item!
{FSIZE2} - divine heart -
{FSIZE2} lingering faith

- x1.5 damage multiplier 
- x0.66 fire rate multiplier 
- x0.5 shot speed multiplier 
- piercing + spectral tears 

- tears will leave a faint trail 
along the path they've traveled 
- upon the death of the tear, a 
damaging beam of light will appear 
along the trail 

- obtained by sacrificing an 
eternal heart in front of 
sacred heart 
{FSIZE2} --------------------

{FSIZE3} additions
- tech omega can now be fired 
with mouse controls 

{FSIZE3} tweaks
- devil's yo-yo no longer 
multiplies items in the death
certificate area

{{FSIZE3}} fixes
- added scapular and tooth and 
nail to the boulder bottom 
invincibility blacklist

- fixed settings sometimes not 
saving on mod reload 

- fixed camo undies decloak 
being spammed when shooting 
with boulder bottom 
]])


DeadSeaScrollsMenu.AddChangelog("Lazy MattPack", "V1.5.1", [[
- added divine heart to angel 
pools when the itempool config 
is set to "all items" 
]])


DeadSeaScrollsMenu.AddChangelog("Lazy MattPack", "V1.6 (Warped Legion!)", [[
{FSIZE3} new item!
{FSIZE2} - warped legion -
{FSIZE2} build your army

- killed enemies will give 
orbiting, 1/12 damage 
mini-incubus familiars for 
the floor

- obtained by using jera on 
twisted pair 
{FSIZE2} --------------------

{{FSIZE3}} fixes
- fixed an incompatibility 
with epiphany 
]], false, true, true)

DeadSeaScrollsMenu.AddChangelog("Lazy MattPack", "V1.6.1", [[
{{FSIZE3}} tweaks
- improved warped legion's 
behavior when checking familiars

- reduced quality of kitchen 
knife to quality 3

- randomized orbit angle 
of newly spawned/respawned 
mincubus familiars

- removed smoke cloud from 
respawned mincubus familiars

{{FSIZE3}} fixes
- fixed a seizure hazard 
]])

DeadSeaScrollsMenu.AddChangelog("Lazy MattPack", "V1.6.2", [[
{{FSIZE3}} tweaks
- adjusted various item weights

- reduced volume of Divine Heart 
laser spawns

{{FSIZE3}} fixes
- fixed a few issues with the 
"all items" item pool config, 
making warped legion and 
bloated body accessible now

- fixed mini-incubi not working 
properly with bffs
]])