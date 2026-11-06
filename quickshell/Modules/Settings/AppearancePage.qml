import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Modules.Launcher
import qs.Services

ColumnLayout {
    id: root

    // Sources refresh on entering the page, like the launcher's modes.
    Component.onCompleted: Wallpapers.refresh()

    Group {
        title: "Wallpaper"

        WallpaperGrid {
            Layout.fillWidth: true
            model: Wallpapers.files.map(f => ({ title: f.name, image: f.thumb, path: f.path }))
            columns: 4
            maxRows: 3
            current: -1
            onChosen: i => Wallpapers.apply(model[i].path)
        }

        ReadOnlyRow {
            title: "Folder"
            value: "~/Pictures/Wallpapers"
        }
    }

    Group {
        title: "Colours"

        ReadOnlyRow {
            title: "Palette"
            value: "matugen, from the wallpaper"
        }

        ReadOnlyRow {
            title: "Neovim and Alacritty"
            value: "follow the palette"
        }
    }

    UnitText {
        id: schedule

        command: ["sh", "-c", 'cat "${XDG_CONFIG_HOME:-$HOME/.config}/wallpaper/schedule" 2>/dev/null']
    }

    NixNote {
        title: "Wallpaper by time of day"
        file: "wallpaper-schedule.nix"

        ReadOnlyRow {
            title: "Schedule"
            value: schedule.text.trim() ? schedule.text.trim().split("\n").map(l => l.split(" ")[0]).join("  ") : "off"
        }
    }

    spacing: Theme.gapSection
}
