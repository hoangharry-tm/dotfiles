pragma Singleton

import Quickshell
import Quickshell.Services.Polkit

// The session's polkit authentication agent (GUI privilege prompts: pkexec,
// settings apps, ...). Registers on start; the dialog lives in Modules/Polkit
// and is created only while a request is pending (`active`).
Singleton {
    readonly property PolkitAgent agent: PolkitAgent {}
    readonly property bool active: agent.isActive
    readonly property AuthFlow flow: agent.flow
}
