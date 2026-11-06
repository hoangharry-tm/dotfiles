pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Design tokens. Colors are generated from the wallpaper by matugen
// (`wallpaper set`) into ~/.local/state/theme/quickshell.json and reloaded
// live; the defaults below only show until that file is read.
Singleton {
    id: root

    // Palette (Material You roles). Usage rules: DESIGN.md "Color".
    readonly property color primary: palette.primary
    readonly property color primaryText: palette.primaryText
    readonly property color primaryContainer: palette.primaryContainer
    readonly property color containerText: palette.containerText
    readonly property color secondary: palette.secondary
    readonly property color secondaryContainer: palette.secondaryContainer
    readonly property color tertiaryContainer: palette.tertiaryContainer
    readonly property color tertiary: palette.tertiary
    readonly property color error: palette.danger
    readonly property color surface: palette.surface
    readonly property color surfaceHigh: palette.surfaceContainerHigh
    readonly property color text: palette.text
    readonly property color textMuted: palette.textMuted
    readonly property color outline: palette.outline
    readonly property color outlineVariant: palette.outlineVariant

    // Surfaces: glass (niri blurs behind layer surfaces), hairlines, states.
    // Fills are the only separators inside a sheet; hairlines are reserved
    // for a sheet's own edge (see DESIGN.md "Surfaces").
    readonly property color glass: Qt.alpha(surface, 0.66)
    readonly property color glassSolid: Qt.alpha(surface, 0.92)
    readonly property color hairline: Qt.alpha(outlineVariant, 0.5)
    readonly property color tile: Qt.alpha(text, 0.06)
    readonly property color hover: Qt.alpha(text, 0.08)
    readonly property color pressed: Qt.alpha(text, 0.14)
    readonly property color selection: Qt.alpha(primary, 0.4)       // text selection highlight
    readonly property color primaryWash: Qt.alpha(primary, 0.16)    // quiet primary fill (selected row, chart area)
    readonly property color primaryRing: Qt.alpha(primary, 0.7)     // focus / current ring
    readonly property color scrim: Qt.alpha(surface, 0.35)          // dim behind full-screen overlays
    readonly property bool dark: surface.hslLightness < 0.5
    function mix(base, over, amount) {
        return Qt.tint(base, Qt.alpha(over, amount));
    }

    // Tonal-gradient recipe (Widgets/Surface). Every Control Center component
    // is a diagonal two-stop gradient derived from the wallpaper palette, so
    // it works with any wallpaper: rest = quiet low-chroma lift of the sheet,
    // on = richer container tone (analogous primary -> tertiary), accent =
    // vivid fills (sliders, play), recess = darker well one level below.
    readonly property color toneRestA: Qt.alpha(mix(surfaceHigh, primaryContainer, 0.30), 0.80)
    readonly property color toneRestB: Qt.alpha(mix(surface, primaryContainer, 0.16), 0.62)
    readonly property color toneOnA: mix(primaryContainer, primary, dark ? 0.10 : 0.30)
    readonly property color toneOnB: mix(mix(tertiaryContainer, primaryContainer, 0.40), tertiary, dark ? 0.08 : 0.20)
    readonly property color toneAccentA: mix(primary, primaryContainer, 0.20)
    readonly property color toneAccentB: mix(tertiary, primary, 0.35)
    readonly property color toneRecessA: Qt.rgba(0, 0, 0, dark ? 0.32 : 0.10)    // top: inner shadow
    readonly property color toneRecessB: Qt.rgba(0, 0, 0, dark ? 0.16 : 0.04)
    readonly property color toneRim: Qt.alpha(text, 0.10)
    readonly property color toneOnRim: Qt.alpha(primary, 0.45)
    readonly property color toneRecessRim: Qt.alpha(text, 0.05)
    readonly property color toneHover: Qt.alpha(text, 0.07)                      // overlay step, not a new colour
    readonly property color tonePress: Qt.alpha(text, 0.13)
    readonly property color onTone: containerText                                // text/glyph on "on" (AA on toneOn*)
    readonly property color onToneMuted: Qt.alpha(containerText, 0.90)
    readonly property color onAccent: primaryText                                // text/glyph on accent fills
    readonly property real grainOpacity: dark ? 0.35 : 0.25                      // baked tile is 9% alpha; this scales it
    readonly property int hairlineWidth: 1

    // Type: generic families; fontconfig (hh-nix-config fonts.nix) resolves
    // them to JetBrainsMono Nerd Font, which also provides every icon glyph.
    // Five steps, 4/2/2/5/12 apart; weight does the rest (Normal, DemiBold).
    readonly property string font: "sans-serif"
    readonly property string mono: "monospace"
    readonly property int textXs: 11        // meta: timestamps, keycaps, chips
    readonly property int textMd: 13        // body and controls (default)
    readonly property int textSm: textMd    // alias: secondary text differs by color, not size
    readonly property int textLg: 15        // titles, result names
    readonly property int textXl: 20        // headings, search input
    readonly property int textHero: 32      // display (power menu)
    readonly property int textDisplay: 96   // desktop clock (Light weight only)
    readonly property color textShadow: Qt.rgba(0, 0, 0, 0.45) // legibility on any wallpaper (desktop widgets)
    readonly property real lineHeight: 1.25 // wrapped body text only (single lines: leave 1, it shifts glyphs down)

    // Icons (glyph em-size): sit on the same optical size as body text + 3.
    readonly property int iconSm: 12        // dismiss marks, chevrons in dense rows
    readonly property int icon: 16          // default: bar, rows, buttons
    readonly property int iconLg: 20        // headers, sliders, tile badges
    readonly property int iconXl: 24        // launcher glyph results
    readonly property int iconHero: 32      // power menu
    readonly property int iconApp: 32       // app icon images in lists

    // Spacing: 4-pt scale. One name per step; semantic aliases below say what
    // each is *for* so call sites never pick a number.
    readonly property int spaceXs: 4
    readonly property int spaceSm: 8
    readonly property int spaceMd: 12
    readonly property int spaceLg: 16
    readonly property int spaceXl: 24
    readonly property int space2xl: 32

    readonly property int gapInline: spaceSm    // icon <-> label, siblings in a row
    readonly property int gapStack: spaceSm     // rows/cards stacked in a group
    readonly property int gapSection: spaceLg   // between groups inside a sheet
    readonly property int padControl: spaceMd   // horizontal padding of a chip/button
    readonly property int padCard: spaceLg      // inside a card / section
    readonly property int padSheet: spaceLg     // inside a sheet, to its content
    readonly property int pad: padSheet         // alias (legacy name)
    readonly property int gap: gapStack         // alias (legacy name)
    readonly property int edge: spaceSm         // sheet <-> screen edge / bar <-> sheet

    // Radius: nested = outer - padding (a card inset 4 in a 16 bar is 12).
    readonly property int radiusXs: 4           // keycaps
    readonly property int radiusSm: 8           // small controls, rows
    readonly property int radiusMd: 12          // cards, tiles, bar chips
    readonly property int radiusLg: 16          // bar, toasts, small sheets
    readonly property int radiusXl: 28          // large sheets (launcher, control center, calendar)
    readonly property int radiusFull: 999       // pills and circles (clamped by size)

    // Sizing: every interactive thing is on a 4-pt height; hit target >= 32.
    readonly property int controlSm: 24         // dismiss, small buttons
    readonly property int control: 32           // bar chips, icon buttons
    readonly property int controlLg: 40         // list rows, inputs in popovers
    readonly property int rowHeight: 40         // detail-list row (48 with subtitle)
    readonly property int rowHeightTall: 48
    readonly property int resultHeight: 56      // launcher result row
    readonly property int tileHeight: 64        // control-center tile
    readonly property int fieldHeight: 56       // launcher search field
    readonly property int trackHeight: 8        // slider / progress track
    readonly property int thumb: 16
    readonly property int sliderHeight: 48      // large pill slider (brightness, volume)
    readonly property int trackThin: 2          // progress hairline (media chip)
    readonly property int barHeight: control + 2 * barInset   // 48
    readonly property int barInset: spaceSm     // bar edge <-> chip, top and bottom (radiusLg - inset = chip radius)
    readonly property int barPadX: spaceMd      // bar edge <-> first/last chip, left and right (wider: the pill's curve eats space)
    readonly property int barGap: spaceSm       // between bar items
    readonly property int barMargin: edge       // bar <-> screen top (and sides)
    readonly property int panelWidth: 400
    readonly property int launcherWidth: 640
    readonly property int popoverWidth: 320     // bar hover cards
    readonly property int calendarWidth: 336
    readonly property int popoverGap: spaceSm   // bar bottom edge <-> any popover
    readonly property int popoverTop: barMargin + barHeight + popoverGap   // screen top <-> popover top

    // Motion
    readonly property int animFast: 120
    readonly property int anim: 220
    readonly property int animSlow: 340
    readonly property int animAmbient: 9000 // one drift of an "on" gradient (only while a sheet is open)
    readonly property int animSpin: 1000    // one turn of a busy spinner
    readonly property int hoverOpen: 350    // hover card appears after this long
    readonly property int hoverClose: 200   // ...and leaves this long after the pointer
    readonly property int animPulse: 1400   // slow breathing, e.g. privacy dot
    readonly property int easing: Easing.OutCubic
    readonly property int animInstant: 80  // press feedback: must feel immediate
    readonly property int animExit: 150     // leaving is quieter than entering
    // Curves mirror niri/look.kdl: decelerate = niri cubic-bezier 0.05 0.7 0.1 1
    // (entrances), accelerate = 0.3 0 0.8 0.15 (exits). Use with Easing.BezierSpline.
    readonly property var curveDecelerate: [0.05, 0.7, 0.1, 1, 1, 1]
    readonly property var curveAccelerate: [0.3, 0, 0.8, 0.15, 1, 1]
    readonly property real pressScale: 0.96   // pressed controls dip, then spring back
    readonly property real enterScale: 0.97   // content grows into its sheet from this
    readonly property int enterRise: spaceSm  // content slides this far while entering
    readonly property int stagger: 18         // delay per list item on entrance
    readonly property int staggerMax: 6       // items past this appear together (cheap)
    readonly property real springStiff: 3.2   // QML SpringAnimation: snappy, slight settle
    readonly property real springDamp: 0.32

    FileView {
        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/theme/quickshell.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: palette

            property string primary: "#b7c4ff"
            property string primaryText: "#1f2d61"
            property string primaryContainer: "#364479"
            property string containerText: "#dce1ff"
            property string secondaryContainer: "#424659"
            property string tertiaryContainer: "#5b3d57"
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
