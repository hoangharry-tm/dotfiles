//@ pragma UseQApplication
//@ pragma IconTheme Papirus-Dark

// hh shell: bar, Control Center, notifications, OSD, launcher, power menu.
// Structure (inspired by DankMaterialShell, written our way):
//   Common/   design tokens (Theme) and popout state (Panels)
//   Services/ one singleton per subsystem; widgets only bind to these
//   Widgets/  small reusable pieces (Glass, Tile, Slider, …)
//   Modules/  the surfaces users see
//
// Control it from niri binds / scripts with `qs ipc call <target> <fn>`.
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Modules
import qs.Modules.Bar
import qs.Modules.Calendar
import qs.Modules.Cheatsheet
import qs.Modules.ControlCenter
import qs.Modules.Desktop
import qs.Modules.Dock
import qs.Modules.FocusTimer
import qs.Modules.Launcher
import qs.Modules.Lock
import qs.Modules.Notifications
import qs.Modules.Osd
import qs.Modules.Polkit
import qs.Modules.PowerMenu
import qs.Modules.Settings
import qs.Modules.Switcher

ShellRoot {
    // Per-screen surfaces
    Variants {
        model: Quickshell.screens

        Scope {
            id: perScreen

            required property ShellScreen modelData

            LazyLoader {
                active: Panels.open !== "" && Panels.open !== "power" && Panels.screen === perScreen.modelData.name

                Scrim {
                    modelData: perScreen.modelData
                }
            }

            Bar {
                modelData: perScreen.modelData
            }

            LazyLoader {
                active: DesktopState.enabled

                DesktopWidgets {
                    modelData: perScreen.modelData
                }
            }

            // Auto-hide dock: a 4 px edge strip is always there (zero idle
            // cost); the sheet is only loaded while revealed.
            LazyLoader {
                active: Settings.dockEnabled && Settings.dockAutoHide

                DockTrigger {
                    modelData: perScreen.modelData
                }
            }

            LazyLoader {
                active: Settings.dockEnabled && (!Settings.dockAutoHide || Dock.screen === perScreen.modelData.name)

                DockBar {
                    modelData: perScreen.modelData
                }
            }

            LazyLoader {
                active: Panels.isOpen("timer", perScreen.modelData.name)

                TimerPanel {
                    modelData: perScreen.modelData
                }
            }

            LazyLoader {
                active: Panels.isOpen("calendar", perScreen.modelData.name)

                Calendar {
                    modelData: perScreen.modelData
                }
            }

            ControlCenter {
                modelData: perScreen.modelData
            }

            LazyLoader {
                active: Notifications.toasts.length > 0 && Panels.focusedScreen() === perScreen.modelData.name

                Toasts {
                    modelData: perScreen.modelData
                }
            }

            LazyLoader {
                active: Panels.isOpen("launcher", perScreen.modelData.name)

                Launcher {
                    modelData: perScreen.modelData
                }
            }

            LazyLoader {
                active: Panels.isOpen("power", perScreen.modelData.name)

                PowerMenu {
                    modelData: perScreen.modelData
                }
            }

            LazyLoader {
                active: Panels.isOpen("settings", perScreen.modelData.name)

                SettingsWindow {
                    modelData: perScreen.modelData
                }
            }

            LazyLoader {
                active: Panels.isOpen("keybinds", perScreen.modelData.name)

                Cheatsheet {
                    modelData: perScreen.modelData
                }
            }
        }
    }

    Osd {}

    LockScreen {}

    // Alt+Tab strip: exists only while open (one on the focused output).
    LazyLoader {
        active: Switcher.open

        Switcher {}
    }

    // qs ipc call switcher next|prev (Alt+Tab / Alt+Shift+Tab in niri/binds.kdl)
    IpcHandler {
        target: "switcher"

        function next(): void {
            Switcher.step(1);
        }

        function prev(): void {
            Switcher.step(-1);
        }

        function cancel(): void {
            Switcher.close();
        }
    }

    // Polkit prompt: exists only while a request is pending.
    LazyLoader {
        active: Polkit.active

        PolkitDialog {}
    }

    // qs ipc call shell launcher|wallpapers|control|calendar|power|keybinds|settings|close
    IpcHandler {
        target: "shell"

        function launcher(): void {
            Panels.toggle("launcher");
        }

        // Launcher opened in wallpaper-picker mode (replaces `wallpaper pick`).
        function wallpapers(): void {
            Launch.seed = ":";
            Panels.toggle("launcher");
        }

        // Launcher in clipboard-history (`<`) / emoji (`.`) mode.
        function clipboard(): void {
            Launch.seed = "<";
            Panels.toggle("launcher");
        }

        function emoji(): void {
            Launch.seed = ".";
            Panels.toggle("launcher");
        }

        function pickColor(): void {
            Quickshell.execDetached(["pick-color"]);
        }

        function control(): void {
            Panels.toggle("control");
        }

        function calendar(): void {
            Panels.toggle("calendar");
        }

        function power(): void {
            Panels.toggle("power");
        }

        function keybinds(): void {
            Panels.toggle("keybinds");
        }

        function settings(): void {
            Panels.toggle("settings");
        }

        // Start/stop a screen recording (Mod+Alt+R in niri/binds.kdl).
        function record(): void {
            Recorder.toggle();
        }

        // Wallpaper-layer clock/weather widgets on/off (persisted).
        function desktopWidgets(): void {
            DesktopState.toggle();
        }

        // Session lock (swayidle / lock-screen); preview = same UI, no real lock.
        function lock(): void {
            Lock.lock();
        }

        function lockPreview(): void {
            Lock.showPreview();
        }

        function close(): void {
            Panels.close();
        }
    }

    // qs ipc call brightness up|down  (brightness keys; shows the OSD)
    IpcHandler {
        target: "brightness"

        function up(): void {
            Brightness.step(0.05);
        }

        function down(): void {
            Brightness.step(-0.05);
        }
    }

    // qs ipc call focus toggle|pause|resume|reset|open|set <minutes> (Focus timer).
    IpcHandler {
        target: "focus"

        function pause(): void {
            FocusTimer.pause();
        }

        // Play: starts from idle with the chosen duration.
        function resume(): void {
            FocusTimer.play();
        }

        function reset(): void {
            FocusTimer.reset();
        }

        function open(): void {
            FocusTimer.openCard();
        }

        function set(minutes: real): void {
            FocusTimer.setMinutes(minutes);
        }

        // One key for everything (niri Mod+P): open the card when idle, else
        // play/pause.
        function toggle(): void {
            if (FocusTimer.active)
                FocusTimer.toggle();
            else
                Panels.toggle("timer");
        }
    }

    // qs ipc call ime toggle (EN/VI). niri binds go through here, not
    // fcitx5-remote directly, so the bar chip updates on the keypress.
    IpcHandler {
        target: "ime"

        function toggle(): void {
            Ime.toggle();
        }
    }

    // qs ipc call notifications dnd|clear
    IpcHandler {
        target: "notifications"

        function dnd(): void {
            Notifications.dnd = !Notifications.dnd;
        }

        // Read-only check (the call above toggles): prints true/false.
        function isDnd(): bool {
            return Notifications.dnd;
        }

        function clear(): void {
            Notifications.clearAll();
        }
    }
}
