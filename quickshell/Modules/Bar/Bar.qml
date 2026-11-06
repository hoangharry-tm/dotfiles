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
    margins.left: 10
    margins.right: 10
    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight
    color: "transparent"
    WlrLayershell.namespace: "qs-bar"
    WlrLayershell.layer: WlrLayer.Top

    Glass {
        anchors.fill: parent
        radius: 14
    }

    // Left: where you are
    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Workspaces {
            output: bar.modelData.name
        }

        FocusedWindow {
            Layout.maximumWidth: 320
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
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

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
