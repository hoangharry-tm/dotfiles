pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Design tokens. Colors are generated from the wallpaper by matugen
// (`wallpaper set`) into ~/.local/state/theme/quickshell.json and reloaded
// live; the defaults below only show until that file is read.
Singleton {
    id: root

    // Palette (Material You roles)
    readonly property color primary: palette.primary
    readonly property color primaryText: palette.primaryText
    readonly property color primaryContainer: palette.primaryContainer
    readonly property color secondary: palette.secondary
    readonly property color tertiary: palette.tertiary
    readonly property color error: palette.danger
    readonly property color surface: palette.surface
    readonly property color surfaceHigh: palette.surfaceContainerHigh
    readonly property color text: palette.text
    readonly property color textMuted: palette.textMuted
    readonly property color outline: palette.outline
    readonly property color outlineVariant: palette.outlineVariant

    // Surfaces: glass (niri blurs behind layer surfaces), hairlines, states
    readonly property color glass: Qt.alpha(surface, 0.62)
    readonly property color glassSolid: Qt.alpha(surface, 0.9)
    readonly property color hairline: Qt.alpha(outlineVariant, 0.55)
    readonly property color tile: Qt.alpha(text, 0.07)
    readonly property color hover: Qt.alpha(text, 0.08)
    readonly property color pressed: Qt.alpha(text, 0.14)

    // Type: generic families; fontconfig (hh-nix-config fonts.nix) resolves
    // them to JetBrainsMono Nerd Font, which also provides every icon glyph.
    readonly property string font: "sans-serif"
    readonly property string mono: "monospace"
    readonly property int textXs: 11
    readonly property int textSm: 12
    readonly property int textMd: 13
    readonly property int textLg: 15
    readonly property int textXl: 20
    readonly property int textHero: 34
    readonly property int icon: 15
    readonly property int iconLg: 20

    // Shape & rhythm
    readonly property int radiusSm: 8
    readonly property int radiusMd: 12
    readonly property int radiusLg: 18
    readonly property int radiusXl: 24
    readonly property int gap: 8
    readonly property int pad: 14
    readonly property int barHeight: 34
    readonly property int barMargin: 8
    readonly property int panelWidth: 380

    // Motion
    readonly property int animFast: 120
    readonly property int anim: 220
    readonly property int animSlow: 340
    readonly property int animPulse: 1400   // slow breathing, e.g. privacy dot
    readonly property int easing: Easing.OutCubic

    FileView {
        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/theme/quickshell.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: palette

            property string primary: "#b7c4ff"
            property string primaryText: "#1f2d61"
            property string primaryContainer: "#364479"
            property string secondary: "#c2c5dd"
            property string tertiary: "#e3bada"
            // Names avoid "error" (a signal here) and "on…" (QML reads those as
            // signal handlers), so Material's onSurface etc. are renamed.
            property string danger: "#ffb4ab"
            property string surface: "#121318"
            property string surfaceContainerHigh: "#292a2f"
            property string text: "#e3e1e9"
            property string textMuted: "#c6c5d0"
            property string outline: "#90909a"
            property string outlineVariant: "#45464f"
        }
    }
}
