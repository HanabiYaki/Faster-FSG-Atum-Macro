;;Made by PodX12
;;
;;HOW THIS WORKS
;;This macro listens to when you press CTRL + C on the AAFSG website
;;then tabs into Minecraft* and puts the seed in using the Atum mod
;;
;;REQUIRES Atum mod
;;
;;This does not leave worlds it just simply creates them.

#SingleInstance, Force

global delay := 50 ; if something is not working try increasing this.
#IfWinActive, AAFSG
{
    ^c::
        WinActivate, Minecraft*
        SetKeyDelay, delay
        send {Esc 3}
        send {Shift Down}{Tab}{Enter}{Shift Up}
        send ^a
        send ^v
        send {Tab 5}
        send {Enter}
        SetKeyDelay, delay
        send {Shift Down}{Tab}{Shift Up}{Enter}
    return
}