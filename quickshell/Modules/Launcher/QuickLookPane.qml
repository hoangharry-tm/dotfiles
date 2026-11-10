import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

// Quick Look: preview of the selected file beside the results (file mode).
// Nothing runs while `active` is false. Selection changes restart one
// debounced stat+mime probe, then one body job (text head, directory listing,
// PDF first page via pdftoppm into the cache); superseded jobs are killed
// (Debounced). Missing tools degrade to the icon + metadata card.
Surface {
    id: root

    property string path: ""
    property string iconName: "" // freedesktop icon of the result, for the fallback card
    property bool active: false

    // Read budgets (data limits, not visual measures, so not Theme tokens).
    readonly property int textLines: 60
    readonly property int dirEntries: 40
    readonly property string cacheDir: FileSearch.home + "/.cache/quickshell/quicklook"

    property var info: null // { size, mtime, mime }
    property string body: ""   // text / directory listing
    property string thumb: ""  // rendered PDF page
    readonly property string kind: !info ? "" : info.mime === "inode/directory" ? "dir" : info.mime.startsWith("image/") ? "image" : info.mime === "application/pdf" ? "pdf" : (info.mime.startsWith("text/") || /json|xml|javascript|x-empty|x-shellscript|x-sh$|toml|yaml/.test(info.mime)) ? "text" : "other"
    readonly property var labels: ({ dir: "Folder", image: "Image", pdf: "PDF", text: "Text", other: "File" })
    readonly property string meta: !info ? "" : (kind === "dir" ? "" : humanSize(info.size) + " · ") + Qt.formatDateTime(new Date(info.mtime * 1000), "d MMM yyyy, HH:mm")
    readonly property string name: path.slice(path.lastIndexOf("/") + 1)

    function humanSize(n) {
        const u = ["B", "KB", "MB", "GB", "TB"];
        let i = 0;
        while (n >= 1024 && i < u.length - 1) {
            n /= 1024;
            i++;
        }
        return (i === 0 ? n : n.toFixed(n < 10 ? 1 : 0)) + " " + u[i];
    }

    function load() {
        info = null;
        body = "";
        thumb = "";
        statJob.cancel();
        bodyJob.cancel();
        if (active && path)
            statJob.run(["sh", "-c", "stat -L -c '%s|%Y' -- \"$1\" && file -L -b --mime-type -- \"$1\"", "sh", path], path);
    }

    onPathChanged: load()
    onActiveChanged: load()

    // Stat + mime answered: pick the body job for this kind.
    function probed(out, tag) {
        if (tag !== path)
            return;
        const l = out.split("\n");
        const st = (l[0] ?? "").split("|");
        if (st.length < 2)
            return;
        info = { size: Number(st[0]), mtime: Number(st[1]), mime: l[1] ?? "" };
        if (kind === "text")
            bodyJob.run(["sh", "-c", "head -c 8192 -- \"$1\" | head -n " + textLines, "sh", path], path);
        else if (kind === "dir")
            bodyJob.run(["sh", "-c", "ls -1Ap --group-directories-first -- \"$1\" | head -n " + dirEntries, "sh", path], path);
        else if (kind === "pdf")
            bodyJob.run(["sh", "-c", "d=\"$1\"; mkdir -p \"$d\"; k=$(printf '%s' \"$2:$3\" | sha1sum | cut -c1-40); [ -s \"$d/$k.png\" ] || pdftoppm -png -f 1 -l 1 -singlefile -scale-to \"$4\" -- \"$2\" \"$d/$k\" >/dev/null 2>&1; [ -s \"$d/$k.png\" ] && { touch \"$d/$k.png\"; echo \"$d/$k.png\"; }; find \"$d\" -type f -mtime +14 -delete 2>/dev/null", "sh", cacheDir, path, String(info.mtime), String(Theme.launcherWidthWide)], path);
    }

    function bodied(out, tag) {
        if (tag !== path)
            return;
        if (kind === "pdf")
            thumb = out.trim();
        else
            body = out;
    }

    Debounced {
        id: statJob

        onDone: (out, tag) => root.probed(out, tag)
    }

    Debounced {
        id: bodyJob

        delay: 0
        onDone: (out, tag) => root.bodied(out, tag)
    }

    radius: Theme.radiusLg // sheet radius (28) - sheet inset (12)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.padCard
        spacing: Theme.gapStack
        visible: root.info !== null

        RowLayout {
            spacing: Theme.gapInline

            Pill {
                text: root.labels[root.kind] ?? ""
            }

            Label {
                Layout.fillWidth: true
                text: root.meta
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
                font.features: { "tnum": 1 }
            }
        }

        Image {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: source !== ""
            source: root.kind === "image" ? "file://" + root.path : root.kind === "pdf" && root.thumb ? "file://" + root.thumb : ""
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            sourceSize.width: Theme.launcherWidthWide // decode at preview size, not 4K
        }

        // Fallback card: icon + name (no thumbnail yet, or a binary file).
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.kind === "other" || (root.kind === "pdf" && !root.thumb)
            spacing: Theme.gapStack

            Item {
                Layout.fillHeight: true
            }

            IconImage {
                Layout.alignment: Qt.AlignHCenter
                implicitSize: Theme.iconApp
                source: root.iconName ? (Apps.iconSource(root.iconName) || Apps.iconSource("application-x-executable")) : ""
            }

            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: root.name
                font.pixelSize: Theme.textLg
                font.weight: Theme.weightTitle
            }

            Item {
                Layout.fillHeight: true
            }
        }

        // Text head or directory entries.
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.kind === "text" || root.kind === "dir"
            clip: true

            Label {
                width: parent.width
                text: root.body
                elide: Text.ElideRight
                maximumLineCount: root.textLines
                wrapMode: Text.NoWrap
                verticalAlignment: Text.AlignTop
                lineHeight: Theme.lineHeight
                font.family: root.kind === "text" ? Theme.mono : Theme.font
                font.pixelSize: Theme.textSm
                textFormat: Text.PlainText
            }
        }
    }
}
