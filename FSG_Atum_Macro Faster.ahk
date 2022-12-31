;;script created by PodX12 py by Specnr

#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetKeyDelay, 50

global next_seed := ""
global token := ""
global timestamp := 0

IfNotExist, fsg_tokens
    FileCreateDir, fsg_tokens

;UPDATE THIS TO YOUR MINECRAFT SAVES FOLDER
global SavesDirectory := "C:\MultiMC\instances\FSG\.minecraft\saves" ; Replace this with your minecraft saves
global titleScreenDelay := 0 ; 0 = GIGACHAD, increase if skips over title screen
global delay := 5 ; Fine tune for your PC/comfort level (Each screen needs to be visible for at least a frame)

;https://seedbankcustom.andynovo.repl.co/ to adjust your filter update inside filters.json
;TO EDIT YOUR FILTER
;GOTO https://seedbankcustom.andynovo.repl.co/
;SELECT YOUR FILTER AND GET A FILTER CODE e.g. 000A000A00000000000A000A00000000000A000A00000000000A000A000000000
;OPEN settings.json and update your filter and desired number of threads
;

;HOW TO GET YOUR TOKEN
;When you press your macro to GetSeed it will create a file called fsg_seed_token.txt
;This has the seed and the token.
;
;All past seeds and verification data will be stored into the folder fsg_tokens with the name
;fsg_seed_token followed by a date and time e.g. 123456789_2021261233.txt

RunHide(Command) {
    dhw := A_DetectHiddenWindows
    DetectHiddenWindows, On
    Run, %ComSpec%,, Hide, cPid
    WinWait, ahk_pid %cPid%
    DetectHiddenWindows, %dhw%
    DllCall("AttachConsole", "uint", cPid)

    Shell := ComObjCreate("WScript.Shell")
    Exec := Shell.Exec(Command)
    Result := Exec.StdOut.ReadAll()

    DllCall("FreeConsole")
    Process, Close, %cPid%
    Return Result
}

getMostRecentFile()
{
    counter := 0
    Loop, Files, %SavesDirectory%\*.*, D
    {
        if (A_LoopFileShortName == "speedrunigt")
            continue
        counter += 1
        if (counter = 1)
        {
            maxTime := A_LoopFileTimeModified
            mostRecentFile := A_LoopFileLongPath
        }
        if (A_LoopFileTimeModified >= maxTime)
        {
            maxTime := A_LoopFileTimeModified
            mostRecentFile := A_LoopFileLongPath
        }
    }
   if (counter == 0) {
      return "NO_SAVE"
   }
   recentFile := mostRecentFile
   return (recentFile)
}

onTitleScreen()
{
  lastWorld := getMostRecentFile()
  if (lastWorld == "NO_SAVE") { ; empty saves folder
    return true
  }
  lockFile := lastWorld . "\session.lock"
  FileRead, sessionlockfile, %lockFile%
  if (ErrorLevel = 0)
  {
    return true
  }
  return false
}

GenerateSeed() {
    fsg_seed_token := RunHide("wsl.exe python3 ./findSeed.py")
    timestamp := A_NowUTC
    fsg_seed_token_array := StrSplit(fsg_seed_token, ["Seed Found", "Temp Token"])
    fsg_seed_array := StrSplit(fsg_seed_token_array[2], A_Space)
    fsg_seed := Trim(fsg_seed_array[2])
    return {seed: fsg_seed, token: fsg_seed_token}
}

FindSeed(resetFromWorld){
    if (next_seed = "" || (A_NowUTC - timestamp > 30 && !resetFromWorld)) {
        ComObjCreate("SAPI.SpVoice").Speak("e")
        output := GenerateSeed()
        next_seed := output["seed"]
        token := output["token"]
        ComObjCreate("SAPI.SpVoice").Speak("Seed Found")
    }
    clipboard = %next_seed%

    WinActivate, Minecraft*
    FSGFastCreateWorld()
    if FileExist("fsg_seed_token.txt"){
        FileMoveDir, fsg_seed_token.txt, fsg_tokens\fsg_seed_token_%A_NowUTC%.txt, R
    }
    FileAppend, %token%, fsg_seed_token.txt
    output := GenerateSeed()
    next_seed := output["seed"]
    token := output["token"]
}

GetSeed() {
  WinGetActiveTitle, Title
  IfNotInString Title, -
    FindSeed(False)()
  else {
    ExitWorld()
    while (!onTitleScreen()) {
      Sleep, 1
    }
    FindSeed(True)
  }
}

FSGFastCreateWorld(){
    SetKeyDelay, 0
    send {Esc 3}
    send {Shift Down}{Tab}{Enter}{Shift Up}
    send ^a
    send ^v
    send {Tab 5}
    send {Enter}
    SetKeyDelay, delay
    send {Shift Down}{Tab}{Shift Up}{Enter}
}

ExitWorld()
{
    SetKeyDelay, 0
    send {Esc}{Tab 6}{Enter}+{Tab 3}{Enter}
}

#IfWinActive, Minecraft
    {
        PgDn::
            GetSeed()
        return
    }