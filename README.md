# App Hot Key

A simple AutoHotkey script for quickly launching or switching to your applications using keyboard shortcuts.

## Requirements

- Windows operating system
- AutoHotkey v2.0+

## Installation

1. Install [AutoHotkey v2](https://www.autohotkey.com/download/)
2. Download the script
   - Clone the repo: `git clone https://github.com/username/repo.git`
   - Or download the `.ahk` file directly from GitHub
3. Double-click the script to run it

## Auto-start at Startup

Press `Win + R`, type `shell:startup`, and press Enter

Then either:
- Copy the `.ahk` file into the Startup folder
- Or create a shortcut to the `.ahk` file and move it there

The script will now launch automatically when you sign in

## Usage

Press `<leader>` followed by a key to launch or focus an application

Examples:
- `<leader>` + 1 → Chrome
- `<leader>` + 2 → VS Code
- `<leader>` + 3 → Discord
- `<leader>` + 4 → Spotify
- `<leader>` + 5 → Terminal

How it works:
- If the app is already running, it brings it to the foreground
- If the app is not running, it launches it
- You can customize which key maps to which app (see Customization)

## Configuration

### Default

```ahk
LEADER_KEY := "!Space"   ; Change this to remap the hotkey
DEBUG_MODE   := false    ; Set to true to enable logging to debug_log.txt
```

How to change defaults:

**Change the leader key**
- Find the hotkey definition at the top of the script (e.g., `!Space::`)
- Replace with your preferred key combination

**Add or change apps**
- Find the `Apps` Map in the script
- Each entry uses the format: `"key", {Name: "...", Path: "...", Window: "...", TitlePattern: "..."}`
- Properties:
  - **Name** (required): Display name
  - **Path** (required): Command to execute (can include arguments)
  - **Window** (required): AHK window identifier (typically `ahk_exe process.exe`)
  - **TitlePattern** (optional): Regex for matching window titles

Example:
```autohotkey
"1", {Name: "Chrome", Path: "chrome.exe", Window: "ahk_exe chrome.exe", TitlePattern: ".* - Google Chrome$"}
"2", {Name: "Discord", Path: 'cmd.exe /c "%LOCALAPPDATA%\Discord\Update.exe --processStart Discord.exe"', Window: "ahk_exe Discord.exe"}
```

**Change slot keys**
- To use different keys (e.g., letters instead of numbers), change the Map keys and the input validation regex
- Example: Change `"1"` to `"a"` and update the regex `^[1-5]$` to `^[a-e]$`

**Enable debug mode**
- Set `DEBUG_MODE` to `true` at the top of the script
- Debug logs are written to a log file in the script's directory
- Check the log file for troubleshooting information

## License

Free to use and modify for personal purposes.
