pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// THE place for user-tunable values. One JSON file, applied live:
//   ~/.local/state/quickshell/settings.json   (hand edits reload; the Settings
//   panel writes it). Defaults are the property values below; a missing key
//   falls back to them, so the file only ever needs the keys you changed.
//
// Schema (key: type = default, who reads it)
//   version          int    = 1        migration marker (legacy files imported once)
//   desktopWidgets   bool   = true     wallpaper-layer clock/weather      (DesktopState)
//   clock24h         bool   = true     bar clock format                   (Bar/Clock)
//   weatherFahrenheit bool  = false    forecast unit                      (Weather)
//   nightMode        string = "off"    "off" | "on" | "auto"              (NightLight)
//   nightWarmTemp    int    = 3500     K while tinted                     (NightLight)
//   nightDayTemp     int    = 6500     K in daylight, auto only           (NightLight)
//   locAutoDetect    bool   = true     IP lookup (ipinfo.io) wins when set (Location)
//   locLatitude/locLongitude real, locCity, locTimezone = Ho Chi Minh City (Location fallback)
//   scheduleEnabled  bool   = false    Focus on/off at the times below    (Notifications)
//   scheduleStart/End "HH:MM" = 22:00 / 07:00 (end may be earlier: overnight)
//   persistHistory   bool   = false    keep notifications across restarts (Notifications)
//   mediaGraceMs     int    = 10000    media UI lingers after a pause     (Media)
//   recDesktopAudio  bool   = false    record what the speakers play      (Recorder)
//   focusDefaultMin  real   = 25      Focus timer length; also the last one used (FocusTimer)
//   lowPower         string = "auto"   "auto" (on battery) | "always" | "never" (PowerMode)
//   motionTier       string = "auto"   "auto" | "low" | "balanced" | "high" (PowerMode, motion-tier)
//   reduceTransparency bool = false   solid sheets, no blur (a11y)         (Transparency, Theme.glass)
//   dockEnabled      bool   = true     bottom dock                        (Dock)
//   dockAutoHide     bool   = true     reveal at the bottom edge only     (Dock)
//   dockIconSize     int    = 48       app icon px                        (Dock)
//   dockStyle        string = "macos"  "macos" (wave, bounce, drag) | "minimal" (Dock)
//   calendarRemindMin int   = 10      reminder toast lead, 0 = off       (CalendarEvents)
//   calendarChipMin  int    = 30      bar chip shows this long before start (NextEventChip)
//   notesInbox       string = "~/mh_notes/inbox.norg"  launcher `+` quick-capture target (Notes)
//   scanWindow       int    = 60      seconds a Wi-Fi/Bluetooth refresh scans: 60 | 120 | 300 (Network, BluetoothState UI)
//   textSize         string = "default" "small" | "default" | "large"     (Theme.textScale)
//   dockPinned       list   = [...]    desktop-entry ids ("@settings" = built-in) (Dock)
//
// NOT here (owned by Nix, read-only in the panel): swayidle timings
// (modules/services.nix), wallpaper schedule (modules/wallpaper-schedule.nix),
// backups (modules/backup.nix). Runtime state (Focus timer, caches) keeps its
// own files.
Singleton {
    id: root

    readonly property string dir: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/quickshell"

    property alias desktopWidgets: data.desktopWidgets
    property alias clock24h: data.clock24h
    property alias weatherFahrenheit: data.weatherFahrenheit
    property alias nightMode: data.nightMode
    property alias nightWarmTemp: data.nightWarmTemp
    property alias nightDayTemp: data.nightDayTemp
    property alias locAutoDetect: data.locAutoDetect
    property alias locLatitude: data.locLatitude
    property alias locLongitude: data.locLongitude
    property alias locCity: data.locCity
    property alias locTimezone: data.locTimezone
    property alias scheduleEnabled: data.scheduleEnabled
    property alias scheduleStart: data.scheduleStart
    property alias scheduleEnd: data.scheduleEnd
    property alias persistHistory: data.persistHistory
    property alias mediaGraceMs: data.mediaGraceMs
    property alias recDesktopAudio: data.recDesktopAudio
    property alias dockEnabled: data.dockEnabled
    property alias dockAutoHide: data.dockAutoHide
    property alias dockIconSize: data.dockIconSize
    property alias dockStyle: data.dockStyle
    property alias dockPinned: data.dockPinned
    property alias focusDefaultMin: data.focusDefaultMin
    property alias lowPower: data.lowPower
    property alias motionTier: data.motionTier
    property alias scrollStyle: data.scrollStyle
    property alias reduceTransparency: data.reduceTransparency
    property alias calendarRemindMin: data.calendarRemindMin
    property alias calendarChipMin: data.calendarChipMin
    property alias notesInbox: data.notesInbox
    property alias scanWindow: data.scanWindow
    property alias textSize: data.textSize

    FileView {
        id: file

        path: root.dir + "/settings.json"
        blockLoading: true // services read their values at startup
        watchChanges: true
        printErrors: false // missing on first run
        atomicWrites: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoaded: if (data.version < 1)
            migrate.running = true
        onLoadFailed: migrate.running = true

        JsonAdapter {
            id: data

            property int version: 0
            property bool desktopWidgets: true
            property bool clock24h: true
            property bool weatherFahrenheit: false
            property string nightMode: "off"
            property int nightWarmTemp: 3500
            property int nightDayTemp: 6500
            property bool locAutoDetect: true
            property real locLatitude: 10.8
            property real locLongitude: 106.7
            property string locCity: "Ho Chi Minh City"
            property string locTimezone: "Asia/Ho_Chi_Minh"
            property bool scheduleEnabled: false
            property string scheduleStart: "22:00"
            property string scheduleEnd: "07:00"
            property bool persistHistory: false
            property int mediaGraceMs: 10000
            property bool recDesktopAudio: false
            property bool dockEnabled: true
            property bool dockAutoHide: true
            property int dockIconSize: 48
            property string dockStyle: "macos"
            property var dockPinned: ["Alacritty", "firefox", "spotify", "yazi", "@settings"]
            property real focusDefaultMin: 25
            property string lowPower: "auto"
            property string motionTier: "auto"
            property bool reduceTransparency: false
            property string scrollStyle: "native" // native (Qt Flickable) | smooth (Widgets/SmoothWheel)
            property int calendarRemindMin: 10
            property int calendarChipMin: 30
            property string notesInbox: "~/mh_notes/inbox.norg"
            property int scanWindow: 60
            property string textSize: "default"
        }
    }

    // One-time import of the pre-Settings state files, then delete the ones
    // that only held a setting (notifications.json keeps its Focus timer).
    Process {
        id: migrate

        command: ["sh", "-c", 'd=$1; n=$(cat "$d/nightlight" 2>/dev/null); w=$(cat "$d/desktopwidgets" 2>/dev/null); ' + 'j=$(cat "$2/notifications.json" 2>/dev/null); printf \'{"night":"%s","dw":"%s","notif":%s}\' "$n" "$w" "${j:-null}"; ' + 'rm -f "$d/nightlight" "$d/desktopwidgets"', "sh", root.dir, Quickshell.statePath(".")]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const m = JSON.parse(text);
                    if (m.night === "on" || m.night === "auto")
                        data.nightMode = m.night;
                    if (m.dw)
                        data.desktopWidgets = m.dw !== "off";
                    for (const k of ["scheduleEnabled", "scheduleStart", "scheduleEnd", "persistHistory"])
                        if (m.notif && m.notif[k] !== undefined)
                            data[k] = m.notif[k];
                } catch (e) {}
                data.version = 1; // also creates the file on first run
            }
        }
    }
}
