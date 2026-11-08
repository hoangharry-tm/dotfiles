import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// What the weekly `updates` check (flake update in a scratch copy; nothing is
// applied) would change. The parent row already says "Updates" and the count,
// so this shows when it was checked, what would change, and "Check now".
Section {
    id: root

    // "[U.]  #4  kitty  0.49.2 x2, 0.49.2-terminfo -> 0.50.0 x2, ..." ->
    // { name: "kitty", change: "0.49.2 → 0.50.0" } (first version per side).
    function parse(line) {
        const m = line.match(/^\[[^\]]*\]\s+#\d+\s+(\S+)\s+(.*)$/);
        if (!m)
            return { name: line, change: "" };
        const first = v => v.split(",")[0].replace(/\s+x\d+$/, "").trim();
        const [from, to] = m[2].split(" -> ");
        return { name: m[1], change: to === undefined ? first(from) : first(from) + "  \u2192  " + first(to) };
    }

    property real now: Date.now() / 1000

    function ago(secs) {
        if (secs <= 0)
            return "never";
        const d = Math.max(0, root.now - secs);
        if (d < 3600)
            return "just now";
        if (d < 86400)
            return Math.floor(d / 3600) + " h ago";
        return Math.floor(d / 86400) + " d ago";
    }

    Timer {
        interval: 60000
        running: root.visible
        repeat: true
        onTriggered: root.now = Date.now() / 1000
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.gapInline

        Label {
            Layout.fillWidth: true
            elide: Text.ElideRight
            color: Theme.textMuted
            font.pixelSize: Theme.textSm
            text: !Updates.known ? "Weekly, on AC power" : "Checked " + root.ago(Updates.checkedAt) + (Updates.nixpkgsDays >= 0 ? "  ·  nixpkgs " + Updates.nixpkgsDays + " d old" : "")
        }

        Button {
            variant: "tonal"
            text: Updates.checking ? "Checking…" : "Check now"
            enabled: !Updates.checking
            onClicked: Updates.check()
        }
    }

    Label {
        visible: root.visible && Updates.known && !Updates.ok
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        maximumLineCount: 3
        elide: Text.ElideRight
        text: Updates.message
        color: Theme.error
        font.pixelSize: Theme.textXs
    }

    ColumnLayout {
        visible: Updates.count > 0
        Layout.fillWidth: true
        spacing: Theme.spaceXs

        // One row per package: name, then the version change, muted and
        // tabular. nvd's raw line ("[U.]  #1  fd  10.5.0 -> 10.5.1") is parsed,
        // never printed: marker and index carry nothing for the reader.
        Repeater {
            model: Updates.summary.map(root.parse)

            RowLayout {
                required property var modelData

                Layout.fillWidth: true
                spacing: Theme.gapInline

                Label {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: modelData.name
                }

                Label {
                    text: modelData.change
                    color: Theme.textMuted
                    font.pixelSize: Theme.textXs
                    font.features: {
                        "tnum": 1
                    }
                }
            }
        }

        Label {
            Layout.fillWidth: true
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
            text: "Apply: nix flake update && nh home switch"
        }
    }
}
