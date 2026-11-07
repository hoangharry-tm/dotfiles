import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services

// Read-only view of a Nix-owned setting. Changing it at runtime would break
// reproducibility, so the only action is opening the module that defines it.
Group {
    id: root

    property string file: "" // under modules/
    readonly property string path: Quickshell.env("HOME") + "/.config/home-manager/modules/" + file
    default property alias values: valueRows.data

    ColumnLayout {
        id: valueRows

        Layout.fillWidth: true
        spacing: 0
    }

    SettingRow {
        title: "Defined in modules/" + root.file
        subtitle: "Managed by Nix; edit, then run home-manager switch"

        ActionButton {
            glyph: "󰏫"
            text: "Open"
            onClicked: {
                Panels.close();
                Apps.run([Apps.terminal, "-e", "nvim", root.path]);
            }
        }
    }
}
