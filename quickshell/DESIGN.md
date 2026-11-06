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
| spaceXs | 4 | `barInset` (bar edge to chip), tight stacks (title/subtitle) |
| spaceSm | 8 | `gapInline` (icon-label, siblings in a row), `gapStack` (rows/cards in a group), `edge` (sheet to screen, bar to screen) |
| spaceMd | 12 | `padControl` (chip/button horizontal padding), launcher/CC row inset |
| spaceLg | 16 | `padCard` (inside cards), `padSheet` (sheet to content), `gapSection` (between groups) |
| spaceXl | 24 | large section breaks, text inset in launcher (12 + 12) |
| space2xl | 32 | page-level (power menu, OSD offset) |

Rule of thumb: gaps *between* groups > gaps *within* a group (Gestalt
proximity). Inside a group use 8 (4 for tight), between groups 16.

## Radius (`Theme.radius*`)
xs 4 keycaps | sm 8 small controls | md 12 cards, tiles, bar chips | lg 16 bar,
toasts, launcher highlight | xl 28 big sheets (launcher, control center,
calendar) | full pills/circles.
Nesting that holds today: bar 16 - inset 4 = chip 12; sheet 28 - inset 16 = card
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

Tooltips and toasts are QML-drawn (xdg popup / unruled), so they are flat:
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
Bar: `barHeight` 40 = control 32 + 2 x barInset 4. Every bar item is a `BarChip`
(32 high, 12 padding, square when icon-only) placed 4 apart on one row; nothing
is hand-positioned. Groups: workspaces + title left, clock centered, status right.
Widths: panelWidth 400 (control center, toasts), launcherWidth 640, calendar 336.
Sheets hang `popoverTop` below the screen top and `edge` from the side.

## Motion
animFast 120 (hover wash), anim 220 (state), animSlow 340 (theme color change),
animPulse 1400 (breathing); easing OutCubic. Animate color, width, rotation
inside a surface; never the surface itself (see Elevation).

## Color
Roles come from the wallpaper (matugen). text = primary content; textMuted =
secondary/inactive (>= 4.5:1 on glass; don't mute below that); primary = the
single accent (active, selected, progress, toggled-on fill; text on it is
`primaryText`); tertiary = attention (privacy, busy); error = destructive/low
battery. Fills: `tile` (6%) resting card/track, `hover` (8%), `pressed` (14%).
Never use raw hex or alpha literals in modules; derive in Theme.

## Checklist for new UI
Pick sizes from Sizing, gaps from Spacing aliases, radius by nesting, text from
the scale; use `BarChip`/`Clickable`/`Glass`/`Tile`/`ListRow`; if it is a layer
surface add a `layer-rule` with matching radius and an elevation level.
