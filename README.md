# Gearshift.ahk
Inspired by the "Grinding Tranny Mod" (http://www.richardjackett.com/grindingtranny) this is an AutoHotkey script that monitors a shifter and clutch and if a gear change is not done properly it repeatedly sends a "Neutral" key press to prevent the gear being selected and sounds a graunching noise. Designed for rFactor 2 but should work with any game (briefly tested with rFactor).

This was written as a "Proof of Concept" to test whether the gear shift in rF2 could be controlled, it is still in beta and is likely to stay that way (the AHK language is hard work), it works on my PC with my G25 but there may be issues when used in different environments (wheels, keyboard layouts, who knows?).  There is very limited reconfiguration provided, you can change shifter device number by editing the line
JoystickNumber =    1
and a couple of other tweaks but, for example, other shifters may require editing the script (it's not that complicated).

# Installation
Install https://autohotkey.com/ and follow the instructions https://autohotkey.com/docs/FAQ.htm#uac to get past UAC then double click on Gearshift.ahk (Grind_default.wav needs to be in the same folder) before loading rF2. In rF2 map Numpad 0 as "Neutral".
