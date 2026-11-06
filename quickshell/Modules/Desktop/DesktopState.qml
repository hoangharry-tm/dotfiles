pragma Singleton

import QtQuick
import Quickshell
import qs.Services

// Whether the desktop widgets show; persisted in Services/Settings.qml.
Singleton {
    readonly property bool enabled: Settings.desktopWidgets

    function toggle() {
        Settings.desktopWidgets = !Settings.desktopWidgets;
    }
}
