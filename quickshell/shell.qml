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
import qs.Modules.Launcher
import qs.Modules.Lock
import qs.Modules.Notifications
import qs.Modules.Osd
import qs.Modules.Polkit
import qs.Modules.PowerMenu

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
                active: Panels.isOpen("keybinds", perScreen.modelData.name)

                Cheatsheet {
                    modelData: perScreen.modelData
                }
            }
        }
    }

    Osd {}

    LockScreen {}

    // Polkit prompt: exists only while a request is pending.
    LazyLoader {
        active: Polkit.active

        PolkitDialog {}
    }

    // qs ipc call shell launcher|wallpapers|control|calendar|power|keybinds|close
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

    // qs ipc call notifications dnd|clear
    IpcHandler {
        target: "notifications"

        function dnd(): void {
            Notifications.dnd = !Notifications.dnd;
        }

        function clear(): void {
            Notifications.clearAll();
        }
    }
}
