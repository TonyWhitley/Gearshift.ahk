; Gearshift.ahk - monitors a shifter and clutch and if a gear change is not
; done properly it repeatedly sends a "Neutral" key press to prevent the gear
; being selected.
; Designed for rFactor 2 but should work with any game. (Also tested on rFactor.)
;
; Inspired by http://www.richardjackett.com/grindingtranny
; I borrowed Grind_default.wav from there to make the noise of the grinding
; gears.
;
; The game has to have Numpad 0 mapped as "Neutral".
; This is a script for https://autohotkey.com/
; Install that then double click on Gearshift.ahk before loading rF2.
;
; V1.2 tjw 2017-12-11

#Persistent  ; Keep this script running until the user explicitly exits it.

; Shifter 1 = Joy9
; Shifter 2 = Joy10
; Shifter 3 = Joy11
; Shifter 4 = Joy12
; Shifter 5 = Joy13
; Shifter 6 = Joy14
; Shifter R = Joy15

ShifterNumber  =    1       ; Shifter port
ClutchNumber   =    1       ; Clutch port
ClutchEngaged  =    90      ; (0 - 100) the point in the travel where the clutch engages
doubleDeclutch =    false   ; Not yet implemented
reshift =           true    ; If true then neutral has to be selected before
                            ; retrying failed change. If false then just have
                            ; to de-clutch

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Nothing much to twiddle with from here on

global debug =      0       ; 0, 1, 2 or 3
;AutoRepeat = 0
;Neutral        =    Numpad0 ; The key used to force neutral, whatever the shifter says

; Gear change events
global clutchDisengage         = 100
global clutchEngage            = 101
global gearSelect              = 102
global gearDeselect            = 103

global graunchCount

SetTimer, WatchClutch, 10
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

graunch()
    {   ; Start the graunch noise and sending "Neutral"
        graunchCount = 0
        graunch2()
        if debug >= 2
        {
            msgBox GRAUNCH!
        }
    }
graunchStop()
    {
        SetTimer, graunch1, Delete  ; stop the timers
        SetTimer, graunch2, Delete
        SoundPlay, Nonexistent.wav  ; stop the noise
    }

graunch1()
    {   ; Send the "Neutral" key release
        Send, {Numpad0 up}
        SetTimer, graunch2, -20
    }

graunch2()
    {   ; Send the "Neutral" key press
        Send, {Numpad0 down}
        if graunchCount <= 0
            {   ; Start the noise again
                SoundPlay, Grind_default.wav
                graunchCount = 5
            }
        else
            graunchCount--
        SetTimer, graunch1, -100
        if debug >= 1
        {
            Send, {G}
        }
    }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gearStateMachine(event)
    {
    ; Gear change states
    static neutral                = 90
    static clutchDown             = 91
    static waitForDoubleDeclutchUp= 92
    static clutchDownGearSelected = 93
    static inGear                 = 94
    static graunching             = 95
    static graunchingClutchDown   = 96

    static gearState = neutral

    if debug >= 3
        msgBox gearState /%gearState%/ event /%event%/
    ; event check (debug)
    if      event = %clutchDisengage%
        {}
    else if event = %clutchEngage%
        {}
    else if event = %gearSelect%
        {}
    else if event = %gearDeselect%
        {}
    else
        {
            msgBox gearStateMachine() invalid event %event%
        }

    if      gearState = %neutral%
        {
        if event = %clutchDisengage%
            {
                gearState = %clutchDown%
                if debug >= 1
                    Send, {D}
            }
        else if event = %gearSelect%
            {
                graunch()
                gearState = %graunching%
            }
        }
    else if gearState = %clutchDown%
        {
        if event = %gearSelect%
            {
                gearState = %clutchDownGearSelected%
            }
        else if event = %clutchEngage%
            {
                gearState = %neutral%
                if debug >= 1
                    Send, {U}
            }
        }
    else if gearState = %waitForDoubleDeclutchUp%
        {
        if event = %clutchEngage%
            {
                gearState = %Neutral%
                if debug >= 2
                    msgBox Double declutch spin up the box
            }
        else if event = %gearSelect%
            {
                graunch()
                gearState = %graunching%
            }
    }
    else if gearState = %clutchDownGearSelected%
        {
        if event = %clutchEngage%
            {
                gearState = %inGear%
                if debug >= 2
                    msgBox In gear
            }
        else if event = %gearDeselect%
            {
                if doubleDeclutch
                    gearState = %waitForDoubleDeclutchUp%
                else
                    gearState = %clutchDown%
            }
        }
    else if gearState = %inGear%
        {
        if event = %gearDeselect%
            {
                gearState = %neutral%
                if debug >= 2
                    msgBox Knocked out of gear
            }
        else if event = %clutchDisengage%
            {
                gearState = %clutchDownGearSelected%
            }
        }
    else if gearState = %graunching%
        {
        if event = %clutchDisengage%
            {
                if reshift = false
                    {
                        if debug >= 1
                            Send, {R}
                        gearState = %clutchDownGearSelected%
                    }
                else
                    {
                        gearState = %graunchingClutchDown%
                    }
                graunchStop()
                if debug >= 1
                    Send, {G}
            }
        else if event = %clutchEngage%
            {
                graunch()   ; graunch again
            }
        else if event = %gearDeselect%
            {
                gearState = %neutral%
                graunchStop()
            }
        else if event = %gearSelect%
            {
                graunchStop()
                graunch()   ; graunch again
            }
        }
    else if gearState = %graunchingClutchDown%
        {
        if event = %clutchEngage%
            {
                graunch()   ; graunch again
                gearState = %graunching%
            }
        else if event = %gearDeselect%
            {
                gearState = %clutchDown%
                graunchStop()
            }
        }
    else
        {
           MsgBox Bad gearStateMachine() state %gearState%
        }
    if gearState != %graunching%
        graunchStop()   ; belt and braces - sometimes it gets stuck.
    }


WatchClutch:
    ; clutch
    Clutch = 1 ; engaged

    GetKeyState, JoyU, %ClutchNumber%JoyU
    ; JoyU 100 is up, 0 is down to the floor
    if JoyU < %ClutchEngaged%
        Clutch = 0  ; clutch is disengaged
    if Clutch != %ClutchPrev%
        {
        if Clutch = 0
            gearStateMachine(clutchDisengage)
        else
            gearStateMachine(clutchEngage)
        }
    ClutchPrev = %Clutch%


    GetKeyState, Joy9,  %ShifterNumber%Joy9
    GetKeyState, Joy10, %ShifterNumber%Joy10
    GetKeyState, Joy11, %ShifterNumber%Joy11
    GetKeyState, Joy12, %ShifterNumber%Joy12
    GetKeyState, Joy13, %ShifterNumber%Joy13
    GetKeyState, Joy14, %ShifterNumber%Joy14
    GetKeyState, Joy15, %ShifterNumber%Joy15

    KeyToHoldDownPrev = %KeyToHoldDown%  ; Prev now holds the key that was down before (if any).

    if       Joy9 = D
        KeyToHoldDown = Numpad1
    else if Joy10 = D
        KeyToHoldDown = Numpad2
    else if Joy11 = D
        KeyToHoldDown = Numpad3
    else if Joy12 = D
        KeyToHoldDown = Numpad4
    else if Joy13 = D
        KeyToHoldDown = Numpad5
    else if Joy14 = D
        KeyToHoldDown = Numpad6
    else if Joy15 = D
        KeyToHoldDown = Numpad9
    else
        KeyToHoldDown = Numpad0

    if KeyToHoldDown = %KeyToHoldDownPrev%  ; The button is already down (or no button is pressed).
    {
        ;if AutoRepeat && KeyToHoldDown
        ;   Send, {%KeyToHoldDown% down}  ; Auto-repeat the keystroke.
        return
    }

    if KeyToHoldDown = Numpad0
        {
            gearStateMachine(gearDeselect)
        }
    else
        {
            gearStateMachine(gearSelect)
        }

    ; Otherwise, release the previous key and press down the new key:
    SetKeyDelay -1  ; Avoid delays between keystrokes.
    if KeyToHoldDownPrev   ; There is a previous key to release.
        Send, {%KeyToHoldDownPrev% up}  ; Release it.
    return