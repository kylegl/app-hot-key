# App Hot Key

## Description

A simple AutoHotkey script for quickly launching or switching to your applications using keyboard shortcuts.

### Why

I wanted Vim-style chorded keys to jump between the apps I use all day. Windows doesn't really have a good answer for that, and alt tab is for normies <3

## Requirements

- Windows operating system
- AutoHotkey v2.0+

## Installation

1. Install [AutoHotkey v2](https://www.autohotkey.com/download/)
2. Download the script
   - Clone the repo: 
   ```
   git clone https://github.com/kylegl/app-hot-key.git
   ```
   - Or download [appHotKey.ahk](https://raw.githubusercontent.com/kylegl/app-hot-key/main/appHotKey.ahk) directly
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

## Configuration

**Default Configuration**

```ahk
LEADER_KEY := "!Space"   ; Change this to remap the hotkey trigger
DEBUG_MODE := false      ; Set to true to enable debug logging
INPUT_TIMEOUT := 1       ; How long (seconds) to wait for key press
LOG_FILE_NAME := "debug.log"  ; Debug log filename
```

### Customization

**Change the leader key**
- Modify `LEADER_KEY` at the top of the script
- Example: Change `"!Space"` to `"^Space"` for Ctrl+Space

**Add or change apps**
- Edit the `Apps` Map in the script
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
- Change the `Apps` map keys
- Example: Change `"1"` to `"a"` to use the letter 'a' as a slot key

**Enable debug mode**
- Set `DEBUG_MODE` to `true` at the top of the script
- Debug logs are written to `debug.log` in the script's directory
- Check the log file for troubleshooting information

## License

[MIT](./LICENSE) License © [Kyle Lauber](https://github.com/kylegl)
