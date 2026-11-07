pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Quick capture: appends a timestamped bullet to a neorg inbox file. Used by
// the launcher's `+` mode. The target is Settings.notesInbox (default: the
// "notes" workspace of nvim's neorg config, ~/mh_notes).
Singleton {
    id: root

    function save(text) {
        const t = text.trim();
        if (t)
            writer.exec(["sh", "-c", script, "sh", Settings.notesInbox, t]);
    }

    // Creates the file (with a neorg metadata header) on first use, then
    // appends "- YYYY-MM-DD HH:MM text". The toast fires only on success.
    readonly property string script: 'f=$1; case "$f" in "~"/*) f=$HOME/${f#"~"/};; esac; ' + 'mkdir -p "$(dirname "$f")" || exit 1; ' + '[ -s "$f" ] || printf "@document.meta\\ntitle: Inbox\\n@end\\n\\n* Inbox\\n\\n" > "$f" || exit 1; ' + 'printf -- "- %s %s\\n" "$(date "+%Y-%m-%d %H:%M")" "$2" >> "$f" && ' + 'notify-send -a Notes -i document-edit-symbolic -t 3000 "Saved to inbox" "$2"'

    Process {
        id: writer

        onExited: code => {
            if (code !== 0)
                Quickshell.execDetached(["notify-send", "-a", "Notes", "-u", "critical", "Could not save note", Settings.notesInbox]);
        }
    }
}
