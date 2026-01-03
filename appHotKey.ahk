#Requires AutoHotkey v2.0

; ============================================================================
; CONFIGURATION
; ============================================================================

; Toggle debug logging - set to true to enable, false to disable
DEBUG_MODE := false

; Application configuration map
; Key: Slot number (1-5)
; Value: Object with Name, Path, Window, and optional TitlePattern
Apps := Map(
    "1", {Name: "Chrome", Path: "chrome.exe", Window: "ahk_exe chrome.exe", TitlePattern: ".* - Google Chrome$"},
    "2", {Name: "Terminal", Path: "wt.exe", Window: "ahk_exe WindowsTerminal.exe"},
    "3", {Name: "Discord", Path: 'cmd.exe /c "%LOCALAPPDATA%\Discord\Update.exe --processStart Discord.exe"', Window: "ahk_exe Discord.exe"},
    "4", {Name: "YouTube Music", Path: "chrome.exe --app=https://music.youtube.com", Window: "ahk_exe chrome.exe", TitlePattern: "YouTube Music"}
)

; ============================================================================
; INITIALIZATION
; ============================================================================

; Position tooltips relative to screen
CoordMode "ToolTip", "Screen"

; ============================================================================
; LOGGING FUNCTION
; ============================================================================

Log(message) {
    if (DEBUG_MODE) {
        timestamp := FormatTime(A_Now, "HH:mm:ss")
        logFile := A_ScriptDir . "\debug.log"
        FileAppend "[" . timestamp . "] " . message . "`n", logFile
    }
}

; ============================================================================
; HOTKEY: Alt+Space triggers InputHook for keys 1-5
; ============================================================================

!Space::{
    ; Wait for a single key press (1 character), timeout after 1 second
    ih := InputHook("L1 T1")
    ih.Start()
    ih.Wait()

    ; Validate input: must be non-empty and between 1-5
    if (ih.Input != "" && ih.Input ~= "^[1-5]$") {
        ; Check if this slot has a configured app
        if (!Apps.Has(ih.Input)) {
            Log("No app configured for slot " . ih.Input)
            return
        }

        app := Apps[ih.Input]
        Log("Processing slot " . ih.Input . ": " . app.Name)

        ToolTip "Opening " . app.Name, A_ScreenWidth - 150, 50
        SmartActivate(app.Window, app.Path, app.Name, app.HasProp("TitlePattern") ? app.TitlePattern : "")
        SetTimer RemoveToolTip, -2000
    } else if (ih.Input != "") {
        ; Input was provided but not 1-5
        Log("Invalid slot: " . ih.Input)
    }
}

; ============================================================================
; CORE FUNCTION: SmartActivate
; Handles focus-or-launch logic with optional title pattern matching
; ============================================================================

SmartActivate(windowId, filePath, appName, titlePattern := "") {
    if (titlePattern != "") {
        ; Get all windows matching the window criteria
        windows := WinGetList(windowId)

        ; Loop through windows to find first matching title pattern
        for index, hwnd in windows {
            title := WinGetTitle("ahk_id " . hwnd)
            if RegExMatch(title, titlePattern) {
                if WinActive("ahk_id " . hwnd) {
                    Log("Already active: " . appName)
                    return
                } else {
                    WinActivate("ahk_id " . hwnd)
                    Log("Focused existing: " . appName)
                    return
                }
            }
        }
        ; No matching window found with title pattern → launch application
        Log("No matching window, launching: " . appName)
        try {
            Run filePath
            if WinWait(windowId, , 3) {
                WinActivate(windowId)
                Log("Launched and focused: " . appName)
            } else {
                Log("WinWait timeout for: " . appName)
            }
        } catch Error as e {
            errorMsg := "Could not launch: " . appName . " (" . filePath . ") - " . e.Message
            Log("ERROR: " . errorMsg)
            MsgBox errorMsg
        }
        return
    }

    ; No title pattern: use simple WinExist/WinActivate
    if WinExist(windowId) {
        if WinActive(windowId) {
            Log("Already active: " . appName)
            return
        } else {
            WinActivate(windowId)
            Log("Focused existing: " . appName)
        }
    } else {
        Log("Not running, launching: " . appName)
        try {
            Run filePath
            if WinWait(windowId, , 3) {
                WinActivate(windowId)
                Log("Launched and focused: " . appName)
            } else {
                Log("WinWait timeout for: " . appName)
            }
        } catch Error as e {
            errorMsg := "Could not launch: " . appName . " (" . filePath . ") - " . e.Message
            Log("ERROR: " . errorMsg)
            MsgBox errorMsg
        }
    }
}

; ============================================================================
; UTILITY FUNCTION: RemoveToolTip
; Cleans up tooltip after delay
; ============================================================================

RemoveToolTip() {
    ToolTip
}
