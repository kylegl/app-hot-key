#Requires AutoHotkey v2.0

; ============================================================================
; CONFIGURATION
; ============================================================================

; Toggle debug logging - set to true to enable, false to disable
DEBUG_MODE := false

; Leader key - change this to remap the hotkey trigger
LEADER_KEY := "!Space"  ; Examples: "^Space" (Ctrl+Space), "#Space" (Win+Space)

; Input timeout - how long (in seconds) to wait for a key press after leader
INPUT_TIMEOUT := 1

; Log file name - name of the debug log file (created in script directory)
LOG_FILE_NAME := "debug.log"

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

; Set up the leader key hotkey
Hotkey LEADER_KEY, (*) => LeaderKeyPressed()

; Position tooltips relative to screen
CoordMode "ToolTip", "Screen"

; ============================================================================
; HOTKEY HANDLER
; ============================================================================

LeaderKeyPressed() {
    ; Wait for a single key press, timeout after configured duration
    ih := InputHook("L1 T" . INPUT_TIMEOUT)
    ih.Start()
    ih.Wait()

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
}

; ============================================================================
; LOGGING FUNCTION
; ============================================================================

Log(message) {
    if (DEBUG_MODE) {
        timestamp := FormatTime(A_Now, "HH:mm:ss")
        logFile := A_ScriptDir . "\" . LOG_FILE_NAME
        FileAppend "[" . timestamp . "] " . message . "`n", logFile
    }
}



; ============================================================================
; HELPER FUNCTION: FindTargetWindow
; Finds the target window handle (hwnd) or returns 0 if not found
; ============================================================================

FindTargetWindow(windowId, titlePattern := "") {
    if (titlePattern == "") {
        ; No pattern: return first matching window
        return WinExist(windowId)
    }

    ; With pattern: find first window matching the title regex
    windows := WinGetList(windowId)
    for hwnd in windows {
        title := WinGetTitle("ahk_id " . hwnd)
        if RegExMatch(title, titlePattern) {
            return hwnd
        }
    }
    return 0  ; No matching window found
}

; ============================================================================
; HELPER FUNCTION: PollForWindow
; Debug-only polling to verify window appears after launch
; ============================================================================

PollForWindow(windowId, titlePattern, appName) {
    maxAttempts := 10  ; 10 checks × 500ms = 5 seconds
    found := false

    Loop maxAttempts {
        if (FindTargetWindow(windowId, titlePattern)) {
            found := true
            break
        }
        Sleep 500
    }

    if (found) {
        Log("DEBUG: Window appeared: " . appName)
    } else {
        Log("DEBUG: Window did not appear within 5 seconds: " . appName)
    }
}

; ============================================================================
; CORE FUNCTION: SmartActivate
; Handles focus-or-launch logic with optional title pattern matching
; ============================================================================

SmartActivate(windowId, filePath, appName, titlePattern := "") {
    ; Find the target window
    targetHwnd := FindTargetWindow(windowId, titlePattern)

    ; If window exists, activate it
    if (targetHwnd) {
        WinActivate("ahk_id " . targetHwnd)
        Log("Focused existing: " . appName)
        return
    }

    ; Window not found, launch it
    try {
        Run(filePath)
        Log("Launching: " . appName)

        ; Debug mode: poll for window appearance
        if (DEBUG_MODE) {
            PollForWindow(windowId, titlePattern, appName)
        }
    } catch Error as e {
        errorMsg := "Could not launch: " . appName . " (" . filePath . ") - " . e.Message
        Log("ERROR: " . errorMsg)
        MsgBox errorMsg
    }
}

; ============================================================================
; UTILITY FUNCTION: RemoveToolTip
; Cleans up tooltip after delay
; ============================================================================

RemoveToolTip() {
    ToolTip
}
