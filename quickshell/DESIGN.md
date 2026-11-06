# Quickshell design system

Calm, spacious, minimal. Source of truth: `Common/Theme.qml` (tokens) and this
file (rules). **No magic numbers** for spacing, radius, size, shadow or color
in `Widgets/` or `Modules/`: use a token, or add one here and in Theme first.
Text/icon metrics assume Noto Sans (`Theme.font`) and JetBrainsMono NF
(`Theme.mono`, icons only).

## Principles
1. One 4-pt grid. Every gap, padding, size and radius is a multiple of 4.
2. Whitespace before borders: separate with space and faint fills; hairlines
   only on a sheet's own edge (and tooltips/toasts, which have no blur).
3. Aligned edges: content in a sheet shares one left/right inset; icons sit in
   fixed square boxes so text starts on the same x.
4. Concentric corners: inner radius = outer radius - inset.
5. Compositor effects don't animate: never fade/scale/translate a sheet that
   niri blurs/shadows (see Elevation).

## Spacing (`Theme.space*`)
| Token | px | Semantic alias (use these) |
|---|---|---|
| spaceXs | 4 | tight stacks (title/subtitle) |
| spaceSm | 8 | `barInset` (bar top/bottom to chip), `barGap` (between bar items), `popoverGap` (bar to popover), `gapInline` (icon-label, siblings in a row), `gapStack` (rows/cards in a group), `edge` (sheet to screen, bar to screen) |
| spaceMd | 12 | `barPadX` (bar left/right to first chip), `padControl` (chip/button horizontal padding), launcher/CC row inset |
| spaceLg | 16 | `padCard` (inside cards), `padSheet` (sheet to content), `gapSection` (between groups) |
| spaceXl | 24 | large section breaks, text inset in launcher (12 + 12) |
| space2xl | 32 | page-level (power menu, OSD offset) |

Rule of thumb: gaps *between* groups > gaps *within* a group (Gestalt
proximity). Inside a group use 8 (4 for tight), between groups 16.

## Radius (`Theme.radius*`)
xs 4 keycaps | sm 8 small controls | md 12 cards, tiles | sm 8 also bar chips | lg 16 bar, bar popovers,
toasts, launcher highlight | xl 28 big sheets (launcher, control center,
calendar) | full pills/circles.
Nesting that holds today: bar 16 - inset 8 = chip 8; sheet 28 - inset 16 = card
12; launcher 28 - inset 12 = highlight 16.
**niri layer-rule `geometry-corner-radius` must equal the sheet's radius.**

## Elevation
Layer surfaces (bar, control center, calendar, launcher, OSD) get blur and
shadow from niri (`niri/rules.kdl`), drawn around the surface rectangle with the
rule's radius. Therefore a sheet must: fill its whole window (no transparent
margin), match the rule radius, and not be scaled/faded/translated (the shadow
would stay at full size: the old "weird launcher shadow"). Open/close is instant.
Shadows are wide, low-alpha, zero spread; they blend instead of outlining.

| Level | Used by | softness | offset y | color |
|---|---|---|---|---|
| E1 | bar | 24 | 2 | #00000033 |
| E2 | control center, calendar, OSD, tiled windows | 40 (windows 48) | 8 | #00000040 (windows #00000047) |
| E3 | launcher (modal) | 64 | 16 | #00000047 |

Bar popovers use E2 via `qs-popover`. Tooltips and toasts are QML-drawn (xdg popup / unruled), so they are flat:
`glassSolid` fill + hairline, no shadow.
Glass: fill `glass` (surface @ 0.66) over niri blur; `glassSolid` (0.92) when no
blur. Border = `hairline` 1px.

## Typography (`Theme.text*`)
| Token | px | Use |
|---|---|---|
| textXs | 11 | meta: time, keycaps, chips, value readouts |
| textMd | 13 | body, controls, bar text (default); `textSm` is an alias |
| textLg | 15 | titles, launcher result names |
| textXl | 20 | headings, search input |
| textHero | 32 | display (power menu) |
Weights: Normal, DemiBold (titles, emphasis), Light only for display. Hierarchy
= size step or muted color, not both. Line height: leave 1 for single lines
(Qt shifts glyphs down otherwise); `Theme.lineHeight` (1.25) only for wrapped
body text.

## Icons
`Icon` is always size x size (glyph widths vary; the box doesn't). Sizes:
iconSm 12 (dismiss, dense), icon 16 (default: bar, rows), iconLg 20 (headers),
iconXl 24 (launcher glyphs), iconHero 32; app icon images `iconApp` 32 in lists,
`icon` 16 in the bar. Icon-to-text gap = `gapInline`. Icons inherit text color
(muted for inactive).

## Sizing
Heights on the 4-pt grid; minimum hit target `control` 32.
controlSm 24 (dismiss, chips) | control 32 (bar chip, icon button) | controlLg
40 | rowHeight 40 (48 with subtitle) | resultHeight 56 | fieldHeight 56 |
tileHeight 64 | trackHeight 8 | thumb 16.
Bar: `barHeight` 48 = control 32 + 2 x barInset 8; horizontal inset `barPadX` 12
(wider than the vertical one: the pill's curve eats space), items `barGap` 8
apart. Every bar item is a `BarChip` (32 high, 12 padding, square when
icon-only); nothing is hand-positioned. Groups: workspaces + title left, clock
centered, status right.
Widths: panelWidth 400 (control center, toasts), launcherWidth 640,
calendarWidth 336, popoverWidth 320 (bar hover cards).

## Bar popovers
One placement rule: a popover's top is `popoverGap` (8) below the bar's bottom
edge (`popoverTop` from the screen top), centered on its trigger and clamped to
`barMargin` from the screen sides; it never overlaps the bar. Layer-shell
windows must set `exclusionMode: ExclusionMode.Ignore`, otherwise niri adds the
bar's exclusive zone on top of the margin (the old "too far away").
Hover cards are `Widgets/Popover.qml` (layer namespace `qs-popover`, radius 16,
E2, blurred like any sheet): open after 350 ms hover, close 200 ms after the
pointer leaves; `interactive` cards (media) stay open while the pointer is on
them. Passive cards let clicks through. `Widgets/Tooltip.qml` remains for
item-relative tooltips inside other sheets.

## Motion
Purposeful, fast, one language across shell and compositor. Animate color,
opacity, offset and scale of *content*; never a glass sheet (see Elevation).
- Durations: animInstant 80 (press), animFast 120 (hover wash), anim 220
  (state, entrances), animExit 150 (exits are quieter), animSlow 340 (theme
  color change), animPulse 1400 (breathing; the only looping animation).
- Curves: entrances/moves use `curveDecelerate` (Easing.BezierSpline) = niri
  `cubic-bezier 0.05 0.7 0.1 1`; exits use `curveAccelerate` = niri
  `cubic-bezier 0.3 0 0.8 0.15`; plain state changes use `easing` (OutCubic).
- Springs (`springStiff`/`springDamp`, SpringAnimation) for press/release
  scale only (`pressScale`, capped to a few px on wide rows). Compositor-side
  spatial motion (move, resize, scroll, workspace, overview) is a critically
  damped niri spring.
- Entrances: `Widgets/Enter` fades and lifts content `enterRise` into a sheet;
  list items stagger by `stagger` ms, capped at `staggerMax` items. Runs once
  per open, nothing animates at idle.
- Windows: niri `window-open` scales 94% -> 100% + fades (220 ms decelerate);
  `window-close` 100% -> 96% + fades (150 ms accelerate), via custom shaders.
- Wallpaper: awww `grow` from the screen center, 1.2 s, 60 fps.

## Color
Roles come from the wallpaper (matugen). text = primary content; textMuted =
secondary/inactive (>= 4.5:1 on glass; don't mute below that); primary = the
single accent (small marks: selected-row text, dots; `primaryText` is text on a primary fill); tertiary = attention (privacy, busy); error = destructive/low
battery. Fills: `tile` (6%) resting card/track, `hover` (8%), `pressed` (14%).
Never use raw hex or alpha literals in modules; derive in Theme.

### Material: tonal gradient + grain
Glass was dropped for Control Center components (hard to get right over a
blur). The sheet keeps `Widgets/Glass` + niri blur; every component on it is
one widget, `Widgets/Surface`: a diagonal two-stop gradient derived from the
matugen palette (so it works with any wallpaper), a static film-grain tile and
a 1px rim. Tokens are `Theme.tone*`, `onTone*`, `onAccent`, `grainOpacity`;
there are no per-component colours.
- `rest`: `toneRestA/B`, a quiet low-chroma lift (surfaceHigh/surface tinted
  with primaryContainer). Text `text`/`textMuted`.
- `on`: `toneOnA/B`, richer container tone (primaryContainer -> tertiary
  container, analogous). The tile's `IconBadge` fills with `primary` (the one
  vivid mark). Text `onTone` / `onToneMuted` (containerText; >= 4.5:1).
- `accent`: `toneAccentA/B` (primary -> tertiary) for slider/battery fills and
  the play button; text `onAccent` (primaryText, > 5.8:1).
- `recessed`: `toneRecessA/B`, black 32% -> 16% (inner shadow at the top) for
  tracks, segmented wells and child lists: one level below the parent.
- Hover/press add a translucent text-colour overlay (`toneHover/Press`), never
  a new colour. Press dips via Clickable spring; colour steps use `animFast`.
- Grain: `assets/grain.png` (96px, 9% alpha) tiled over the plain-rectangle
  part of the outline (middle band + strips between corner arcs, no mask).
  Static, so zero idle cost. Light themes use a lower `grainOpacity`.
- Motion: `on` and `accent` surfaces slide their gradient axis with
  `Ambient.phase` (`animAmbient` 9 s, InOutSine, loops). Ambient only runs
  while a Control Center is open (`Ambient.hold/release`); rest/recessed
  surfaces never move.
- `primary` otherwise stays for small marks (selected-row text, dots, spinner,
  media progress, password focus ring). Low battery/charging swap the fill for
  `error`/`tertiary`.
