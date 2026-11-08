pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

// Design tokens. Colors are generated from the wallpaper by matugen
// (`wallpaper set`) into ~/.local/state/theme/quickshell.json and reloaded
// live; the defaults below only show until that file is read.
Singleton {
    id: root

    // Neutral roles keep the wallpaper's hue and lightness but cap HSL saturation:
    // grey surfaces with a whisper of warmth/coolness (paper and ink), never a
    // maroon or purple cast. One token governs it; accent roles stay as matugen
    // gives them. `k` scales the cap (text and muted text use half: ink).
    readonly property real neutralChroma: 0.08
    function neutral(c, k) {
        // Palette entries are strings (JsonAdapter); make a color first, or
        // hslHue is undefined and every neutral role turns black.
        const q = Qt.lighter(c, 1);
        return Qt.hsla(Math.max(0, q.hslHue), Math.min(q.hslSaturation, neutralChroma * (k || 1)), q.hslLightness, q.a);
    }

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
    readonly property color surface: neutral(palette.surface)
    readonly property color surfaceHigh: neutral(palette.surfaceContainerHigh)
    readonly property color text: neutral(palette.text, 0.5)
    readonly property color textMuted: neutral(palette.textMuted, 0.5)
    readonly property color textFaint: Qt.alpha(textMuted, 0.4)   // decorative only (empty-workspace dots); never for text
    readonly property color outline: neutral(palette.outline)
    readonly property color outlineVariant: neutral(palette.outlineVariant)

    // Surfaces: glass (niri blurs behind layer surfaces), hairlines, states.
    // Fills are the only separators inside a sheet; hairlines are reserved
    // for a sheet's own edge (see DESIGN.md "Surfaces").
    // 0.78: the lowest alpha where muted text keeps 4.5:1 and body text 7:1
    // even over the worst backdrop (dark glass on a white page, light glass on
    // black), computed for both modes. Legibility before translucency.
    // Reduce transparency (Settings, a11y): the same surface at alpha 1; the
    // one switch, like lowPower's motionScale. niri's blur is dropped to match.
    readonly property color glass: Qt.alpha(surface, Transparency.reduce ? 1 : 0.78)
    readonly property color glassSolid: Qt.alpha(surface, Transparency.reduce ? 1 : 0.92)
    // Light glass has less contrast between sheet and backdrop, so its edge is
    // drawn from `outline` (darker than outlineVariant) a little stronger.
    readonly property color hairline: dark ? Qt.alpha(outlineVariant, 0.5) : Qt.alpha(outline, 0.35)
    readonly property color tile: Qt.alpha(text, 0.06)
    readonly property color hover: Qt.alpha(text, 0.08)
    readonly property color pressed: Qt.alpha(text, 0.14)
    readonly property color selection: Qt.alpha(primary, 0.4)       // text selection highlight
    readonly property color primaryWash: Qt.alpha(primary, 0.16)    // quiet primary fill (selected row, chart area)
    readonly property color primaryRing: Qt.alpha(primary, 0.7)     // focus / current ring
    // Dim behind full-screen overlays: dark mode tints with the surface; light
    // mode dims with ink (a white veil would flatten the screen), but lighter.
    readonly property color scrim: dark ? Qt.alpha(surface, 0.35) : Qt.alpha(text, 0.22)
    readonly property bool dark: surface.hslLightness < 0.5
    function mix(base, over, amount) {
        return Qt.tint(base, Qt.alpha(over, amount));
    }

    // Flat material (Widgets/Surface): neutral fills, one accent. Colour is
    // for state only (DESIGN.md "Color").
    readonly property color fillOn: Qt.alpha(text, 0.12)                          // "on" tile: stronger neutral
    // Large fills (slider level, play button, meters): the LIGHTEST neutral in
    // both modes (Apple's white slider), over `fillTrack`, which is always
    // darker. The accent is too loud at this size; it stays on small "on" marks.
    // WCAG (surface/ink from the shipped palettes): onSolid on fillSolid 12.2
    // dark, 17.2 light; fillSolid vs fillTrack 12.6 dark, 1.53 light (non-text;
    // 3:1 would need a heavy grey track).
    readonly property color fillSolid: dark ? Qt.alpha(text, 0.92) : Qt.rgba(1, 1, 1, 1)
    readonly property color onSolid: dark ? surface : text                        // text/glyph on fillSolid
    readonly property color fillRecess: dark ? Qt.rgba(0, 0, 0, 0.24) : Qt.alpha(text, 0.07)  // well one level down: a soft ink wash in light
    readonly property color fillTrack: dark ? fillRecess : Qt.alpha(text, 0.18)   // slider/meter track under fillSolid
    readonly property color fillTrackInset: dark ? tile : fillTrack               // the same, inside a recessed well (dark: lifts off it)
    readonly property color toneHover: Qt.alpha(text, 0.07)                      // overlay step, not a new colour
    readonly property color tonePress: Qt.alpha(text, 0.13)
    readonly property color onAccent: primaryText                                // text/glyph on the accent
    readonly property int hairlineWidth: 1

    // Type: Inter (variable, hh-nix-config fonts.nix) for the shell's UI text;
    // `mono` resolves through fontconfig. Sizes follow one ratio (1.25, a
    // major third): 11 / 13 / 16 / 20 / 32 / 40 / 96 (32 x 1.25 = 40,
    // 40 x 1.25^4 ~ 96). Weight does the rest (Normal, DemiBold).
    readonly property string font: "Inter Variable"
    // Inter's dynamic metrics (rsms.me/inter/dynmetrics): tracking in em =
    // -0.0223 + 0.185 x e^(-0.1745 x px). Slightly open at 11, tight at
    // display sizes. Widgets/Label applies it with the optical size axis.
    function tracking(px) {
        return px * (-0.0223 + 0.185 * Math.exp(-0.1745 * px));
    }
    // Applies tracking + optical size to a Text/TextInput. Called from
    // onFontChanged, never as a binding: a binding on font.letterSpacing that
    // reads font.pixelSize loops (same font group). Writes only on change, so
    // the fontChanged it causes settles in one step. Other families (mono)
    // get no tracking.
    function fitType(t) {
        const ours = t.font.family === font;
        const px = t.font.pixelSize;
        const ls = ours ? tracking(px) : 0;
        if (Math.abs(t.font.letterSpacing - ls) > 0.01)
            t.font.letterSpacing = ls;
        const opsz = Math.max(14, Math.min(32, px));
        if (ours && t.font.variableAxes.opsz !== opsz)
            t.font.variableAxes = { "opsz": opsz };
    }
    // Weights: titles (16 px and up) 600; emphasis at 13 / 11 px 500 (Inter's
    // 600 is too heavy that small); body 400; Light only for display sizes.
    readonly property int weightTitle: Font.DemiBold
    readonly property int weightEmphasis: Font.Medium
    readonly property string mono: "monospace"
    readonly property string symbols: "Material Symbols Rounded" // UI icons (Widgets/Icon `name`)
    readonly property int iconWeight: 400   // symbol stroke: matches Inter Regular at textMd
    // Grade: light symbols on dark glass bloom; Google advises -25 there.
    readonly property int iconGrade: dark ? -25 : 0
    readonly property int textXs: 11        // meta: timestamps, keycaps, chips
    readonly property int textMd: 13        // body and controls (default)
    readonly property int textSm: textMd    // alias: secondary text differs by color, not size
    readonly property int textLg: 16        // titles, result names
    readonly property int textXl: 20        // headings, search input
    readonly property int textHero: 32      // display (power menu)
    readonly property int textTimer: 40     // timer readout (Light weight, tabular figures)
    readonly property int textDisplay: 96   // desktop clock (Light weight only)
    // Text drawn straight on the wallpaper follows the IMAGE's brightness, not
    // the mode: `wallpaper` writes brightness.json (luma of the whole image,
    // deskLuma of the corner the desktop widgets sit on). Dark image: light
    // ink + dark soft shadow; bright image: dark ink + light soft shadow.
    function inkOn(l) {
        return l < 0.5 ? Qt.rgba(1, 1, 1, 0.96) : Qt.rgba(0.07, 0.07, 0.09, 0.92);
    }
    function inkMutedOn(l) {
        return l < 0.5 ? Qt.rgba(1, 1, 1, 0.78) : Qt.rgba(0.07, 0.07, 0.09, 0.74);
    }
    function shadowOn(l) {
        return l < 0.5 ? Qt.rgba(0, 0, 0, 0.45) : Qt.rgba(1, 1, 1, 0.5);
    }
    readonly property color onWallpaper: inkOn(brightness.deskLuma)             // desktop widgets
    readonly property color onWallpaperMuted: inkMutedOn(brightness.deskLuma)
    readonly property color wallpaperShadow: shadowOn(brightness.deskLuma)
    readonly property color onImage: inkOn(brightness.luma)                     // whole image (lock screen)
    readonly property color onImageMuted: inkMutedOn(brightness.luma)
    readonly property color imageScrim: brightness.luma < 0.5 ? Qt.rgba(0, 0, 0, 0.25) : Qt.rgba(1, 1, 1, 0.25)
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
    // One screen margin for everything that meets a screen edge (bar, sheets,
    // toasts, dock) = niri `gaps` (niri/look.kdl), so the bar, the windows and
    // every sheet share one left/right edge and one rhythm. Was 8: windows
    // sat 4 px inside the bar on every screen.
    readonly property int edge: spaceMd

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
    readonly property int controlXl: 56         // the one primary round button of a card (timer play/pause)
    readonly property int rowHeight: 40         // detail-list row (48 with subtitle)
    readonly property int rowHeightTall: 48
    readonly property real agendaRows: 4.5     // calendar agenda height cap, in tall rows
    readonly property int resultHeight: 56      // launcher result row
    readonly property int tileHeight: 64        // control-center tile
    readonly property int fieldHeight: 56       // launcher search field
    readonly property int trackHeight: 8        // slider / progress track
    readonly property int thumb: 16
    readonly property int sliderHeight: 48      // large pill slider (brightness, volume)
    readonly property int dot: spaceXs          // event marker under a calendar day
    readonly property int trackThin: 2          // progress hairline (media chip)
    readonly property int barHeight: control + 2 * barInset   // 40
    readonly property int barInset: spaceXs     // bar edge <-> chip, top and bottom (radiusBar - inset = chip radius 8)
    readonly property int radiusBar: radiusMd   // the bar pill (= qs-bar layer rule); slimmer bar, quieter frame
    readonly property int barPadX: spaceMd      // bar edge <-> first/last chip, left and right (wider: the pill's curve eats space)
    readonly property int barGap: spaceSm       // between bar items
    readonly property int barMargin: edge       // bar <-> screen top (and sides)
    readonly property int panelWidth: 400
    readonly property int columnA: spaceXs + padControl   // icon column inside a Group: group inset + row padding
    readonly property real disabledOpacity: 0.5           // a control that can't act right now (dimmed, still legible)
    readonly property int settingsHeight: launcherWidth   // Settings sheet: 640 high, width = height x ratio
    // Sheet proportion: height = width x golden ratio, snapped to the 4-pt grid
    // (400 -> 648). A fixed, deliberate shape (never "whatever is left"); content
    // scrolls inside. Capped by the screen in the sheet itself.
    readonly property real ratio: 1.618
    function grid(px) {
        return Math.round(px / spaceXs) * spaceXs;
    }
    readonly property int panelHeight: grid(panelWidth * ratio)
    readonly property int launcherWidth: 640
    readonly property int launcherWidthWide: 880 // launcher in a two-pane mode (clipboard list + preview)
    readonly property int popoverWidth: 320     // bar hover cards
    readonly property int calendarWidth: 336
    readonly property int timerRing: 176        // timer card progress ring
    readonly property int popoverGap: spaceSm   // bar bottom edge <-> any popover
    readonly property int popoverTop: barMargin + barHeight + popoverGap   // screen top <-> popover top

    // Motion
    // 0 in low power (Services/PowerMode): every duration below collapses, in one place.
    // Hardware tier (PowerMode.tier: low | balanced | high, DESIGN.md "Motion"):
    // same language, different richness. Derived tokens below; gate new
    // continuous or heavy effects on these, never on the tier name.
    readonly property string motionTier: PowerMode.tier
    readonly property int motionLevel: PowerMode.tierLevel                  // 0 low, 1 balanced, 2 high
    readonly property bool motionAmbient: motionLevel >= 1                  // gradient drift, cava spectrum
    readonly property bool motionRich: motionLevel >= 2                     // extra polish (springy morphs, lock shader)
    readonly property real motionScale: PowerMode.lowPower ? 0 : (motionLevel === 0 ? 0.7 : 1)
    readonly property int animFast: Math.round(120 * motionScale)
    readonly property int anim: Math.round(220 * motionScale)
    readonly property int animSlow: Math.round(340 * motionScale)
    readonly property int driftIdle: 240000 // lock-screen shader stops after this long without pointer movement
    readonly property int animSpin: 1000    // one turn of a busy spinner
    readonly property int pressDelay: 120 // ms: Flickable press hold-off (scroll vs click)
    readonly property int holdDelay: 400    // press-and-hold: first repeat
    readonly property int holdRepeat: 80    // press-and-hold: repeat rate
    readonly property int hoverOpen: 350    // hover card appears after this long
    readonly property int hoverClose: 200   // ...and leaves this long after the pointer
    readonly property int animPulse: 1400   // slow breathing, e.g. privacy dot
    readonly property int easing: Easing.OutCubic
    readonly property int animInstant: Math.round(80 * motionScale)  // press feedback: must feel immediate
    readonly property int animExit: Math.round(150 * motionScale)     // leaving is quieter than entering
    // Curves mirror niri/look.kdl: decelerate = niri cubic-bezier 0.05 0.7 0.1 1
    // (entrances), accelerate = 0.3 0 0.8 0.15 (exits). Use with Easing.BezierSpline.
    readonly property var curveDecelerate: [0.05, 0.7, 0.1, 1, 1, 1]
    readonly property var curveAccelerate: [0.3, 0, 0.8, 0.15, 1, 1]
    readonly property real pressScale: 0.96   // pressed controls dip, then spring back
    readonly property real enterScale: 0.97   // content grows into its sheet from this
    readonly property int enterRise: [0, spaceSm, spaceMd][motionLevel] // content slides this far while entering
    readonly property int stagger: [0, 18, 22][motionLevel] // delay per list item on entrance
    readonly property int staggerMax: [0, 6, 8][motionLevel] // items past this appear together (cheap)
    // Notification stack: layers tucked under the front card, fanned into a list on hover.
    readonly property int stackLayers: 3      // cards that peek beneath the front one
    readonly property int stackPeek: spaceSm  // visible edge of each tucked card
    readonly property int fanCards: 4         // cards a fanned toast group shows before it scrolls (3 felt cramped, 5 fills half a laptop)
    readonly property int toastGroups: 4      // most app stacks shown as toasts; older fold into "+M more apps"
    readonly property int toastGroupEst: 112  // typical collapsed stack height, to budget how many groups fit
    readonly property real stackShrink: 0.04  // scale lost per layer
    readonly property real stackFade: 0.22    // material opacity lost per layer
    readonly property real springStiff: 3.2   // QML SpringAnimation: snappy, slight settle
    readonly property real springDamp: 0.32

    FileView {
        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/theme/brightness.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: brightness

            property real luma: 0.2
            property real deskLuma: 0.2
        }
    }

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
