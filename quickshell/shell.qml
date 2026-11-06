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
import qs.Modules.Launcher
import qs.Modules.Notifications
import qs.Modules.Osd
import qs.Modules.PowerMenu

ShellRoot {
    // Per-screen surfaces
    Variants {
        model: Quickshell.screens

        Scope {
            id: perScreen

            required property ShellScreen modelData

            Scrim {
                modelData: perScreen.modelData
            }

            Bar {
                modelData: perScreen.modelData
            }

            Calendar {
                modelData: perScreen.modelData
            }

            ControlCenter {
                modelData: perScreen.modelData
            }

            Toasts {
                modelData: perScreen.modelData
            }

            Launcher {
                modelData: perScreen.modelData
            }

            PowerMenu {
                modelData: perScreen.modelData
            }

            Cheatsheet {
                modelData: perScreen.modelData
            }
        }
    }

    Osd {}

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
