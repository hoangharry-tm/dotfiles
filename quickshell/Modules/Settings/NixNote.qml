import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

// A Nix-owned setting, read-only here (changing it at runtime would break
// reproducibility). The values are rows; the last row opens the module that
// defines it.
SettingsGroup {
    id: root

    property string file: "" // under modules/
    readonly property string path: Quickshell.env("HOME") + "/.config/home-manager/modules/" + file
    default property alias values: valueRows.data

    ColumnLayout {
        id: valueRows

        Layout.fillWidth: true
        spacing: 0
    }

    SettingsRow {
        title: "Defined in modules/" + root.file
        description: "Edit it, then run home-manager switch"

        Button {
            glyph: "edit"
            text: "Open"
            onClicked: {
                Panels.close();
                Apps.run([Apps.terminal, "-e", "nvim", root.path]);
            }
        }
    }
}
