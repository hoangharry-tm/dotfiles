import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Widgets

// The floating glass pill at the top of each screen.
PanelWindow {
    id: bar

    required property ShellScreen modelData

    screen: modelData
    anchors.top: true
    anchors.left: true
    anchors.right: true
    margins.top: Theme.barMargin
    margins.left: Theme.barMargin
    margins.right: Theme.barMargin
    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight
    color: "transparent"
    WlrLayershell.namespace: "qs-bar"
    WlrLayershell.layer: WlrLayer.Top

    // Radius must equal the qs-bar layer rule in niri/rules.kdl.
    Glass {
        anchors.fill: parent
        radius: Theme.radiusLg
    }

    // Left: where you are
    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: Theme.barPadX
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.barGap

        Workspaces {
            output: bar.modelData.name
        }

        FocusedWindow {
            Layout.maximumWidth: 320 // content cap, not spacing
        }
    }

    // Center: when
    Clock {
        anchors.centerIn: parent
        screenName: bar.modelData.name
    }

    // Right: what's going on
    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: Theme.barPadX
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.barGap

        MediaChip {}

        PrivacyDot {}

        SystemChip {}

        Tray {
            bar: bar
        }

        StatusCluster {
            screenName: bar.modelData.name
        }
    }
}
