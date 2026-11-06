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
| E3 | launcher, switcher, polkit, keybinds, settings (modal) | 64 | 16 | #00000047 |

Material: app windows. Translucent apps (Alacritty, dropdown, yazi) and
xdg-popup menus get the same frosted glass as the sheets: one global `blur {}`
in `niri/look.kdl` (passes 3, offset 3, noise 0.02, saturation 1.4), window
radius 12 (match `geometry-corner-radius`), menus radius 12 at opacity 0.94.
Opaque apps (browsers, video) are never blurred. `blur { off }` disables it all.

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

## Bar: responsive priorities
The clock is truly centred and never overlapped. Each side gets the room
between its screen edge and the clock, minus `barGap`; `Widgets/ResponsiveRow`
picks the lowest collapse level whose summed item widths fit. Items report
`widthAt(level)` from content metrics (never laid-out sizes), so there is no
feedback loop and no per-frame work; it re-runs only when a width input
changes (tray icon, track title, scale, output). Labels that can grow elide
right. Levels, least important first:
- Right (0-9): 1 weather drops its temperature, 2 media title shortens,
  3 visualiser goes, 4 media is a glyph only, 5 weather chip goes (the Control
  Center has it), 6 input-method chip goes, 7 tray folds into a "..." chip,
  8 system chip goes, 9 battery % goes. Wi-Fi/Bluetooth/volume/battery icons,
  recording, screen-share (`ScreencastChip`, error-coloured, pulses only
  while a niri cast is active; hover lists casts with Stop / Stop all) and
  privacy (mic/camera) indicators never collapse. The Focus-timer chip (only
  while the timer runs or is paused; paused is dimmed and static) drops its
  mm:ss at level 5 (ring only) and disappears at 8, so the ring outlives the
  tray fold at 7.
- Left (0-2): workspace pills show 3, 2, then 1 icon; the window title is
  elastic and elides first, keeping a minimum of `control * 3`.
- Last resort: the clock drops the weekday ("6 Nov · 09:57").
Workspace pills: the active pill with icons is a `hairlineWidth` primary ring
(no fill); empty workspaces stay dots.

## Timer
One countdown, no phases: set a length, Play/Pause, Reset. Focus (DND) is on
while it is active, never overriding a Focus the user set. `Widgets/TimerCard`
is the single UI: `textTimer` Light tabular time inside a `ProgressRing`
(`timerRing`, `spaceXs` stroke, shows time remaining), round `-`/`+` (hold or
scroll to repeat), preset chips, Reset (`controlLg`) and Play/Pause (`controlXl`,
the only filled control). Click the time to type minutes or mm:ss. It lives in
the bar chip's popover and, when the chip is hidden (idle), in
`Modules/FocusTimer/TimerPanel` under the clock (shares the `qs-popover` niri
rule); Mod+P, the launcher and the Focus menu open it. Seconds tick only while
a card or mm:ss is visible; otherwise one single-shot timer fires at the end.

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

## Dock
Optional bottom dock (`Modules/Dock`, `Services/Dock.qml`, namespace `qs-dock`).
Sheet: radius `radiusLg` 16 (= niri rule), E2, padding `spaceSm`, icons
`dockIconSize` (default 48, 32-64) in `+spaceSm` wash slots, running dot
`spaceXs`, accent when focused. Auto-hide reveals by *loading* the sheet
(LazyLoader) when the pointer touches the 4 px `qs-dock-trigger` strip, and
unloads it 350 ms after the pointer leaves; the sheet is never faded, scaled
or moved, so niri's blur and shadow stay exact. Only the icons rise in
(`Enter`) and magnify (+12% on the hovered icon, +6% neighbours, spring).
The strip is 640 px wide, centred: clear of the bottom-right hot corner.

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
Never use raw hex or alpha literals in modules; derive in Theme. Shared
alpha tokens: `selection` (text selection), `primaryWash` (quiet primary
fill), `primaryRing` (focus/current ring), `scrim` (dim behind full-screen
overlays). Timing tokens beyond Motion: `animSpin` (busy spinner turn),
`hoverOpen`/`hoverClose` (hover card delays).

Light and dark: `wallpaper mode light|dark|auto` and `wallpaper scheme <style>`
(Settings > Appearance) regenerate the palette; `Theme.dark` derives from
`surface` lightness, so glass, text and shadows adapt with no per-mode
colours in modules. Light glass carries dark `text`; never hardcode white or
black text, use `text` / `onTone` / `onAccent`.

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

## Linting
`./lint.sh` runs qmllint over everything (it builds a temp copy with
generated qmldirs so `import qs.*` resolves; needs `QS_QML` = Quickshell's
`lib/qt-6/qml`, `QT_QML` = qtdeclarative's, and `qmllint` on PATH). Warning
levels are in `.qmllint.ini`: Quickshell-specific false positives
(uncreatable PanelWindow, anchors, `.values`, unqualified ids) are off;
everything else, including unused imports, id shadowing and property
overrides, must be clean. CI: `.github/workflows/lint.yml` in the dotfiles repo.

## Low power
`Services/PowerMode.lowPower` (Settings "Low power": auto = on battery,
always, never) is the single switch. It sets `Theme.motionScale` to 0 (all
`anim*` durations collapse), freezes `Ambient`, stops cava, hides the desktop
now-playing line, shows a leaf in the bar status cluster, switches to the
power-saver profile (restoring the previous one after, unless the user changed
it meanwhile) and writes `~/.local/state/theme/niri-power.kdl` (blur off,
animations 5x faster), included last by niri. Gate new continuous work on it.

## Launcher two-pane mode (clipboard)
`Theme.launcherWidthWide` (880) replaces `launcherWidth` while in `<` mode; the window resizes, the sheet is
never scaled. Left list 2/5: `controlLg` rows, glyph `icon` (colour entries show a swatch), highlight radius
`radiusLg`. Right preview 3/5: `tile` fill, `radiusLg`, `padCard` inset, type chip = `primaryWash` pill.
Fixed 8-row height so the preview never jumps. Destructive confirm (clear all) uses `Theme.error` in the footer.

## Notifications (toasts and Control Center list)
One widget family: `NotificationGroup` (a stack per app) of `NotificationCard`s on `Surface` (the CC tonal gradient
and grain) over a `glassSolid` base, so toasts (no niri blur) and CC cards read as one material.
- Collapsed: newest card in front, up to `stackLayers` real cards tucked beneath (`stackPeek` edge, `stackShrink`
  scale and `stackFade` opacity per layer; their content is hidden), "+N more" pill past that.
- Hover fans the stack into a list (`gapStack`): each card animates y, scale and height from tucked pose to slot,
  staggered by `stagger` (capped at `staggerMax`), decelerate, ending together with the stack height. Leaving
  collapses after `hoverClose`. Expiry pauses while hovered; CC "Show all" pins it open.
- A toast window is never animated per frame: it grows to the fanned height when the transition starts (`slack`
  in Toasts.qml, transparent and click-through via `mask`) and shrinks after the collapse ends. `qs-toasts` has no
  niri layer rule, so the transparent margins show the desktop; each card draws its own material and is never
  blurred, so fade/slide in QML is fine.
- Aurora variant (`Surface variant: "aurora"`, notification cards in toasts and the Control Center): a
  diagonal three-stop gradient secondary -> primary -> tertiary container each mixed 35-40% into `surfaceHigh`, alpha 0.85 (`toneAurora*`), plus two radial blooms
  (primary/tertiary container at `bloomA`/`bloomB` alpha; muted roles so the lightness spread stays under ~10% and the card matches the CC cards' luminance) on opposite
  top/bottom edges. `seed = Theme.hash(appName)` turns every hue +-30 degrees and places the blooms, so apps differ
  but share the palette. Grain and rim are unchanged. Static: no drift or animation beyond the hover wash.
- Card (Sonoma layout): leading app tile (`controlLg`, `radiusSm`, `tile` backing, icon `iconApp` centred so odd
  shapes look uniform; a missing or failed icon becomes the app's initial on `primaryContainer`), then one text
  column: caption (`textXs` muted: "App · time", close on hover, critical glyph), summary Medium, body muted (2
  lines, full when the group is open or the card hovered); thumbnail trailing (`radiusSm`), pills. In the Control
  Center the group header names the app, so the tile and app name are dropped. Critical: `trackThin` tertiary rim
  plus glyph, never expires. Enter slides/fades from the top-right; exit (swipe, x, actions) slides right.
- Space budget (toasts): the column never exceeds screen height minus bar and margins (`avail` in Toasts.qml).
  1. A fanned group shows at most `fanCards` (4) cards, fewer if `maxFanH` is smaller; the rest scroll inside it
     (wheel, half a card a notch) under a `spaceXl` edge fade (a mask, layered only while it overflows). Hover
     holds, so scrolling keeps it open and expiry paused. 4: 3 hides too much of a burst, 5 takes half a laptop.
  2. At most `toastGroups` (4) stacks show, fewer on a short screen (always leaving the fanned one room for two
     cards): newest first, critical ones never fold. The rest become one "+M more apps" pill that opens the
     Control Center.
  3. One group fans at a time (taking the hover releases the others). The others keep their collapsed height and
     the fanned one is capped to what remains, scrolling inside; nothing else moves. The window height is clamped
     to `avail` and still only changes when a transition starts or ends.
- Timers: none without toasts; relative time ticks once a minute only while a card is visible.
