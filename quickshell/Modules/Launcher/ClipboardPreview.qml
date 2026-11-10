import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Right pane: the selected entry in full. Reads Clipboard.inspected*; the
// service decodes only this one entry (text) or thumbnails it (image).
Surface {
    id: root

    readonly property var entry: Clipboard.inspected
    readonly property string kind: entry?.kind ?? "text"
    readonly property string body: Clipboard.inspectedText || entry?.text || ""
    readonly property bool mono: kind === "code" || kind === "path"
    readonly property string meta: kind === "image" ? entry.meta : kind === "link" ? Clipboard.domain(body) : body.length + " chars" + (body.split("\n").length > 1 ? " · " + body.split("\n").length + " lines" : "")

    radius: Theme.radiusLg // sheet radius (28) - sheet inset (12)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.padCard
        spacing: Theme.gapStack
        visible: root.entry !== null

        RowLayout {
            spacing: Theme.gapInline

            Pill {
                text: Clipboard.kinds[root.kind].label + (root.entry?.pinned ? " · Pinned" : "")
            }

            Label {
                Layout.fillWidth: true
                text: root.meta
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
                font.features: { "tnum": 1 }
            }
        }

        // Colour: big swatch above its value.
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.tileHeight * 2
            visible: root.kind === "color"
            radius: Theme.radiusMd // card inside a card: 16 - padCard 16 would be 0, so step down one level
            color: visible ? Clipboard.toColor(root.body) : "transparent"
            border.width: Theme.hairlineWidth
            border.color: Theme.hairline
        }

        Image {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.kind === "image"
            source: root.kind === "image" && Clipboard.inspectedThumb ? "file://" + Clipboard.inspectedThumb : ""
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            sourceSize.width: Theme.launcherWidthWide // decode at preview size, not 4K
        }

        // Link: domain as the headline, URL below.
        Label {
            Layout.fillWidth: true
            visible: root.kind === "link"
            text: Clipboard.domain(root.body)
            font.pixelSize: Theme.textLg
            font.weight: Theme.weightTitle
        }

        Flickable {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.kind !== "image"
            clip: true
            contentHeight: bodyText.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ScrollIndicator {
                flick: scrollView
            }


            Label {
                id: bodyText

                width: parent.width
                text: root.body
                elide: Text.ElideNone
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                verticalAlignment: Text.AlignTop
                lineHeight: Theme.lineHeight
                font.family: root.mono || root.kind === "color" ? Theme.mono : Theme.font
                color: root.kind === "link" ? Theme.textMuted : Theme.text
                textFormat: Text.PlainText
            }
        }
    }
}
