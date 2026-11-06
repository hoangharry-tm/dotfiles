import Quickshell
import qs.Modules

// Greeter shell, run by niri inside greetd (see greeter-session). It reuses
// the desktop shell's Theme/Widgets: system-setup.sh copies those next to
// this file, so the look never drifts from the shell.
// Preview in your session: GREETER_PREVIEW=1 qs -p <staged dir>
// (system-setup.sh --stage-greeter DIR); nothing talks to greetd then.
ShellRoot {
    Variants {
        model: Quickshell.screens

        Greeter {}
    }
}
