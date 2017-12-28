# Gearshift.ahk
Inspired by the "Grinding Tranny Mod" (http://www.richardjackett.com/grindingtranny) this is an AutoHotkey script that monitors a shifter and clutch and if a gear change is not done properly it repeatedly sends a "Neutral" key press to prevent the gear being selected and sounds a graunching noise. Designed for rFactor 2 but should work with any game (briefly tested with rFactor).

This was written as a "Proof of Concept" to test whether the gear shift in rF2 could be controlled, it is still in beta and is likely to stay that way (the AHK language is hard work), it works on my PC with my G25 but there may be issues when used in different environments (wheels, keyboard layouts, who knows?).  There is very limited reconfiguration provided, you can change shifter device number by editing the line
```
JoystickNumber =    1
```
and a couple of other tweaks but, for example, other shifters may require editing the script (it's not that complicated).

# Installation
Install https://autohotkey.com/ and follow the instructions https://autohotkey.com/docs/FAQ.htm#uac to get past UAC then double click on Gearshift.ahk (Grind_default.wav needs to be in the same folder) before loading rF2. In rF2 map Numpad 0 as "Neutral".

# Configuring
You have to edit the script to change the way Gearshift is set up
```
ForwardGears = 6            ; Plus reverse
Shifter1 = Joy9
Shifter2 = Joy10
Shifter3 = Joy11
Shifter4 = Joy12
Shifter5 = Joy13
Shifter6 = Joy14
ShifterR = Joy15
ClutchAxis = JoyU           ; R U V or Z

ShifterNumber  =    1       ; Shifter port
ClutchNumber   =    1       ; Clutch port
ReverseClutchAxis = false   ; If true then the clutch input goes from 100 (down) to 0 (up)

TestMode       =    false   ; If true then show shifter and clutch operation

ClutchEngaged  =    90      ; (0 - 100) the point in the travel where the clutch engages
                            ; if ReverseClutchAxis then ClutchEngaged = 10
doubleDeclutch =    false   ; Not yet implemented
reshift =           true    ; If true then neutral has to be selected before
                            ; retrying failed change. If false then just have
                            ; to de-clutch
```
# Test Mode
If TestMode = true then Gearshift switches into a test mode where it will display the state of the shifter and clutch as they have been configured, like this

```
Test Mode

Clutch: 100 engaged
Gear 1: Selected
Gear 2: 
Gear 3: 
Gear 4: 
Gear 5: 
Gear 6: 
Gear R: 
```
