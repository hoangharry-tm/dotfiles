# Quickshell design system

Quiet, honest, lasting. This file is the art direction and the rules;
`Common/Theme.qml` holds the tokens. **No magic numbers** for spacing, radius,
size, shadow or color in `Widgets/` or `Modules/`: use a token, or add one here
and in Theme first. Text is Inter (`Theme.font`, "Inter Variable"); icons are
Material Symbols Rounded (`Theme.symbols`). Both come from Nix (`fonts.nix`).

Contents: 1 Direction · 2 Foundations · 3 Components · 4 Engineering · Sources

---

# 1. Direction

## Thesis
The desktop should feel like a well-made object, not a dashboard: calm at rest,
precise when touched, and still pleasant to look at in five years. Two
traditions guide it:

- **Muji / Kenya Hara.** Not minimalism as a style but *emptiness* as a
  condition: space that is ready to be filled by the person using it. Muji aims
  for "this will do", enough and no more, instead of "this is what I want".
  Plain, unadorned (*su*), no decoration that isn't the material itself.
- **Apple.** Clarity (legible, precise), deference (the UI serves the content
  and steps back), depth (layers and motion explain where things are). The
  shell's chrome defers to the windows and the wallpaper.

Luxury, here, comes from what is *absent* and from the precision of what
remains: exact alignment, consistent weights, unhurried spacing, nothing that
moves without a reason.

## Principles (with the theory behind each)
1. **Emptiness first (*ma*).** The rest state is mostly empty. Items appear
   when they matter (a meeting soon, music playing, recording, high load) and
   leave when they don't. An element must earn its place; if in doubt it lives
   one level deeper (Control Center, Settings). *Hara; Rams: "as little design
   as possible".*
2. **Calm, peripheral status.** Technology should inform without demanding
   attention and live in the periphery until needed. The bar is read in a
   glance: shapes before numbers (battery % only when low), nothing ticks or
   moves at idle. *Weiser and Brown, "calm technology"; Amber Case's principles.*
3. **One accent, by exception.** The item that differs is the one that's
   noticed, so difference is spent only where it means something.
   `primary` = *state you turned on* (filled badge, slider fill, selection).
   `error` / `tertiary` = *needs you* (low battery, recording, mic/camera,
   screen share). Everything else is `text` / `textMuted` on neutral fills.
   If two things are coloured at rest, one of them is wrong. *Von Restorff
   (isolation) effect.*
4. **One material.** Flat neutral fills on glass. No gradients, grain, rims or
   per-app hues; depth comes only from the sheet's blur and shadow (Elevation).
   *Rams: honest; Muji: su, the unadorned material.*
5. **One icon family, one weight.** Every symbol shares a stroke weight matched
   to the text beside it, so a row of icons reads as one line of type.
   `filled` means "on". *Gestalt similarity; the SF Symbols approach.*
6. **Group by space and region, not lines.** Gaps between groups are larger
   than gaps inside them, and identical items are always evenly spaced (unequal
   gaps between look-alike cards read as a mistake). Related rows share one
   surface (`Widgets/Group`, inset grouped) instead of each being a card; a
   shared fill groups before a border would. Hairlines only on a sheet's own
   edge. *Gestalt proximity, similarity, common region.*
7. **Deliberate proportion.** A sheet has a chosen shape, never "whatever
   space is left": height = width x the golden ratio (1.618), snapped to the
   grid (`Theme.panelHeight`: 400 -> 648), capped by the screen. Content
   scrolls inside a fixed sheet. Sizes come from one scale (4-pt grid, five
   type steps, icon = text + 3) so every measure relates to the others.
   *Golden ratio / modular scale; Le Corbusier's Modulor; Apple's sheets.*
8. **Fewer choices.** Decision time grows with the number of options: one
   Control Center layout, short menus, settings only where people truly differ
   (never to postpone a design decision). Complexity that can't be removed is
   absorbed by the system (auto-hide, appear-when-relevant), not handed to the
   user. *Hick's law; Tesler's law of conservation of complexity.*
9. **Easy targets.** Hit targets are at least `control` 32; the bar sits on the
   screen edge, which acts as an infinitely deep target. *Fitts's law.*
10. **Fast responses, unhurried motion.** Feedback within ~100 ms, results well
   under 400 ms; motion is short, decelerating, and only explains change.
   *Doherty threshold; Apple's motion guidance.*
11. **Familiar patterns.** People expect macOS/iOS idioms (Control Center
   tiles, menu-bar status cluster, dock), so the shell uses them rather than
   inventing new ones. *Jakob's law.*
12. **Steady numbers.** Clock, percentages and timers use tabular figures
   (`font.features: { "tnum": 1 }`) so digits don't jitter.
13. **Beauty is not a fix.** Attractive interfaces are perceived as easier and
   make friction forgivable; that is a reason to fix friction, not hide it.
   Judge a change by what it does, then by how it looks. *Aesthetic-usability
   effect.*

## Review checklist (before any UI change ships)
- What does this look like at rest? Could it be absent until it matters?
- How many coloured things are on screen now? (Target at rest: zero.)
- Is every value a token, every icon a symbol at the context's size?
- Do edges align and do radii nest (inner = outer - inset)?
- Does anything move or poll at idle? Does it respect `motionTier` and
  `lowPower`?
- Light *and* dark, laptop (1536 logical) *and* external (1920) output.

---

# 2. Foundations

## Grid and spacing (`Theme.space*`)
One 4-pt grid: every gap, padding, size and radius is a multiple of 4.

| Token | px | Semantic alias (use these) |
|---|---|---|
| spaceXs | 4 | tight stacks (title/subtitle), `barInset` (bar edge to chip) |
| spaceSm | 8 | `barGap` (between bar items), `popoverGap` (bar to popover), `gapInline` (icon-label, siblings in a row), `gapStack` (rows/cards in a group) |
| spaceMd | 12 | `barPadX` (bar ends to first chip), `padControl` (chip/button horizontal padding), row insets, `edge` (bar, sheets, windows to the screen edge = niri gaps) |
| spaceLg | 16 | `padCard`, `padSheet`, `gapSection` (between groups) |
| spaceXl | 24 | large section breaks |
| space2xl | 32 | page-level (power menu, OSD offset) |

Inside a group 8 (4 when tight), between groups 16. Content in a sheet shares
one left/right inset; icons sit in fixed square boxes so text starts on the
same x.

## Radius (`Theme.radius*`)
xs 4 keycaps | sm 8 small controls, bar chips, rows | md 12 cards, tiles, the
bar (`radiusBar`) | lg 16 bar popovers, toasts, launcher highlight | xl 28 big
sheets (launcher, Control Center, calendar) | full pills/circles.
Concentric: inner = outer - inset. Bar 12 - inset 4 = chip 8; sheet 28 - 16 =
card 12; launcher 28 - 12 = highlight 16.
**A niri layer rule's `geometry-corner-radius` must equal its sheet's radius.**

## Elevation and glass
Layer surfaces (bar, Control Center, calendar, launcher, OSD, popovers) get
blur and shadow from niri (`niri/rules.kdl`), drawn around the surface
rectangle with the rule's radius. So a sheet must fill its whole window (no
transparent margin), match the rule radius, and never be scaled, faded,
translated or resized per frame (the shadow would stay put, and niri re-blurs
the whole sheet on every resize). Open/close is instant. Shadows are wide,
low-alpha, zero spread: they blend, they don't outline.

| Level | Used by | softness | offset y | color |
|---|---|---|---|---|
| E1 | bar | 24 | 2 | #00000033 |
| E2 | Control Center, calendar, OSD, popovers, dock, tiled windows | 40 (windows 48) | 8 | #00000040 (windows #00000047) |
| E3 | launcher, switcher, polkit, keybinds, settings (modal) | 64 | 16 | #00000047 |

Glass: `Widgets/Glass`, fill `glass` (surface @ 0.78) over niri blur. 0.78
is computed, not chosen: the lowest alpha at which muted text keeps 4.5:1 and
body text 7:1 over the worst backdrop (dark glass on a white page, light glass
on black) in both modes. Legibility before translucency (the macOS Tahoe
lesson);
`glassSolid` (0.92) where there is no blur (tooltips, toasts), which also get
a `hairline` edge. App windows: translucent apps (Alacritty, dropdown, yazi)
and xdg-popup menus share one global `blur {}` in `niri/look.kdl` (radius 12,
menus at 0.94); opaque apps (browsers, video) are never blurred.

**Reduce transparency** (Settings > Appearance > Display, Apple's
accessibility setting): `glass` and `glassSolid` become the surface at alpha 1
and niri blur is off for `qs-*` layers via `niri-transparency.kdl`
(`Services/Transparency`, sharing `Services/NiriInclude` with low power).
Modules never read the setting; app windows are unaffected.

## Windows (niri)
- **One edge.** `Theme.edge` 12 = niri `gaps` 12: the bar, every sheet,
  toasts, the dock and every window share one left/right edge, and the space
  between the bar and windows, between windows, and around the screen is the
  same 12. (Measured before: the bar at x 8, windows at x 12.)
- **Focus = depth + one quiet ring.** The active window sits at E2
  (`shadow` softness 48, y 8, `#00000047`); inactive windows sit lower
  (`match is-active=false`: softness 24, y 4, `inactive-color` `#00000024`).
  The active window also carries a 2 px ring in matugen's `secondary`: the
  wallpaper's own hue with the chroma pulled down, at 80 % alpha, so it
  belongs to the image without shouting (`primary` stays for state). It is
  regenerated with every wallpaper and mode (dark spheres `#c2c5dd`, light
  peach `#715a41`), inactive windows have none (one ring on screen), and an
  urgent window's ring is `error`, the same rule as the urgent workspace dot.
- **Terminals on the grid.** kitty `window_padding_width 9` (pt) and
  alacritty `padding 12` (px) are both 12 px: the window radius and the
  shell's row padding, so terminal text starts on the shell's rhythm.

## Material
One material for everything on a sheet: `Widgets/Surface`, a flat rounded
fill. Variants keep their names, all neutral except `accent`:
- `rest`: resting card/track (`tile`).
- `on`: a slightly stronger neutral fill. The colour of "on" lives only in
  the icon badge (`IconBadge` filled with `primary`, glyph `onAccent`,
  `filled: true`), as in Apple's Control Center.
- `solid`: `fillSolid`, near-`text` neutral for *large* fills (slider level,
  play button, battery meter), like Apple's white slider; text `onSolid`. A
  full-width accent slab is too loud, so large areas never use `primary`.
- `accent`: flat `primary`, small marks only; text `onAccent`.
- `recessed`: a quieter well one level below its parent (child lists, tracks).
- Hover/press add a translucent text-colour overlay (`toneHover`/`tonePress`),
  never a new colour; colour steps use `animFast`, press dips use the
  `Clickable` spring.
No gradients, film grain, rims or per-app hues. Nothing about a surface
animates at idle.

## Hierarchy (parent and child)
A child must look like it belongs to its parent, one step lower, never like a
sibling. Three levels, never more:

| Level | What | Material |
|---|---|---|
| L0 | the sheet | `Glass` (niri blur) |
| L1 | a group / card | `Surface rest` (`tile`) |
| L2 | a child: disclosed detail, a list under its tile | `Surface recessed` (`fillRecess`), inside or directly under its parent |

- **Disclosure.** When a row expands, its detail opens in an L2 well directly
  under that row, inside the same group (proximity + common region). The
  parent row stays as the well's title. The child never repeats the parent's
  title or summary.
- **Two columns.** Every row has column A (the icon's left edge) and column B
  (the title's left edge = A + icon box + `gapInline`). Everything inside a
  child well starts on A or B; nothing floats between them.
- **Inner <= outer.** The padding inside an element is never larger than the
  space that separates it from its neighbours; otherwise it merges with them.
  A well's padding is `spaceMd` 12, and the gap after it is at least 12.
- **Concentric.** A well inside a group uses `rowRadius` (`radiusMd` - inset =
  `radiusSm`); its own children, if any, are square or `radiusXs`.

## Interaction boxes (hover, press, focus)
A hover wash is the element's own box, designed like any other box:
- Only real controls get a wash. Static text (a headline, a summary) is never
  interactive; a hidden action (tap a headline to refresh) becomes a visible
  control (a `refresh` icon button) - signifiers, not secrets (Norman).
- Box = content + `padControl` 12 left/right + at least `spaceXs` 4 top/bottom,
  and at least `control` 32 high (Fitts). The wash never touches its content.
- Hanging: the box extends *outward* (negative margins) so the content stays
  on its column; aligning the wash must never shift the text.
- Radius = container radius - distance to the container edge (concentric);
  a free-standing control is a pill (`radiusFull`).
- One button idiom (`Widgets/Button`): a `control` 32 pill, `padControl`,
  label `textMd`; `quiet` (no fill, wash on hover) or `tonal` (`tile` fill).
  Icon-only buttons are `control` 32 circles.

## Spacing roles
Every space in a sheet has exactly one of these roles; pick the role, the
token follows:

| Role | Token | Example |
|---|---|---|
| sheet inset | `padSheet` 16 | sheet edge to its groups |
| section gap | `gapSection` 16 | between top-level groups |
| stack gap | `gapStack` 8 | between sibling cards/tiles in a group |
| group inset | `spaceXs` 4 | group edge to its rows (rows carry their own padding) |
| row padding | `padControl` 12 | row edge to column A, and to its trailing item |
| inline gap | `gapInline` 8 | icon to label, label to meta |
| well padding | `spaceMd` 12 | L2 well edge to its content |
| tight stack | `spaceXs` 4 | title to subtitle |

## Lists and groups
One idiom for every list (Control Center modules, Wi-Fi, Bluetooth, sound,
notifications): `Widgets/Group`, one rest `Surface` (`radiusMd`, inset
`spaceXs`) holding rows that draw no resting fill, only a hover/press wash at
`rowRadius` (= `radiusSm`, concentric). Rows are separated by space only.
- Row (`Widgets/ListRow`): `rowHeight` 40, `rowHeightTall` 48 with a
  subtitle; leading symbol in a fixed `icon` box; title `text`, meta
  `textMuted` `textXs` with tabular figures; trailing action `iconSm`.
- Selected / connected: the icon goes `filled` and a trailing `check` appears;
  never a coloured row. In progress: a muted `progress_activity` spinner.
- Sections: a `textXs` muted label `spaceSm` above its group, only where a
  list truly has sections (Wi-Fi Known / Other networks, Sound Output / Apps /
  Input). Empty: one muted line centred in the group. `ListBlock` = heading +
  group + empty line; `DetailList` = header row (title, refresh/scan button)
  + blocks.
- Levels inside a list (per-app volume, input level) are `LevelRow`: mark,
  name, a thin `trackHeight` track with a `solid` fill, and the value (tap to
  mute). The large pill `Slider` is reserved for the sheet's two main levels
  (brightness, volume).
- Rows report `present` (default true); a `Group` with no present row hides.

## Color
Roles come from the wallpaper (matugen), so every rule is about *roles*.
**Neutral roles are nearly neutral**: `surface`, `surfaceHigh`, `outline*`
pass through `Theme.neutral()`, which keeps hue and lightness but caps
saturation at `neutralChroma` (0.08; text and muted text at half), so glass,
cards and greys read as paper and ink with only a whisper of the wallpaper.
Accent roles (`primary`, `tertiary`, `error`, containers) stay as matugen gives
them: the wallpaper speaks only through the accent.
- `text` primary content; `textMuted` secondary/inactive (>= 4.5:1 on glass;
  never mute below that).
- `primary` the single accent: *on* state and selection (see Principle 3).
  `primaryText`/`onAccent` is text on a primary fill. `primaryWash` (selected
  row), `primaryRing` (keyboard focus), `selection` (text selection).
- `tertiary` attention (privacy, recording, busy); `error` destructive / low
  battery / screen share.
- Fills: `tile` 6% resting, `hover` 8%, `pressed` 14%, `fillOn` 12% ("on"
  tile), `fillRecess` (well), `fillSolid` (large neutral fill); `scrim` dims
  behind full-screen overlays.
- **Data colours** the user chose (calendar colours) may appear as small marks
  (dots, a 4 px bar), never as fills.
Never raw hex or alpha literals in modules; derive in Theme.

**One palette style.** matugen always runs `scheme-tonal-spot` (Material's
calm default). Since the surfaces are neutralised, a style would only change
the accent, and ten ways to be slightly off are not a choice worth offering
(paradox of choice, Principle 8). The only colour choice is the mode.

**Both modes by construction.** `wallpaper mode light|dark|auto` (Settings >
Appearance) regenerates the palette; `Theme.dark` derives from `surface`
lightness. Every role is correct in both modes *in Theme*, so modules never
branch on the mode and never hardcode white, black or `Qt.rgba(0, 0, 0, ...)`.
Large fills (`fillSolid`) are the lightest neutral in both modes (Apple's
white slider), never the text colour. A change ships only after it has been
seen in both modes.

**Dynamic desktop: each mode keeps its own wallpaper.** Glass is a filter.
You see the backdrop through it as a *relative* change (Weber's law,
dL/L): under dark glass (low L) the wallpaper's light shows as a glow, but
under light glass (high L) a dark wallpaper's variation vanishes into a flat,
glaring haze. Light mode therefore needs a light backdrop, which is how
macOS pairs its wallpapers. `wallpaper` stores `wallpaper-light.*` and
`wallpaper-dark.*`; `wallpaper set` (and the Settings grid) sets the image for
the mode in use, `wallpaper pair light|dark <image>` sets either, and a mode
change, including Auto at sunrise and sunset, swaps the image with the
palette. A light partner should measure `luma` >= 0.5 (`brightness.json`).
App surfaces stay as matugen derives them from that light image: warm paper
around L* 95 (Apple's light grey is L* 96.5). Darker turns to mud; whiter
turns to glare.

**Text on the wallpaper follows the image, not the mode.** The desktop
widgets and the lock screen draw straight on the wallpaper, so their ink comes
from the image's brightness: `wallpaper` writes
`~/.local/state/theme/brightness.json` (`luma` of the whole image, `deskLuma`
of the desktop-widget corner) whenever the wallpaper changes, and Theme's
`onWallpaper*` tokens pick light ink with a dark shadow or dark ink with a
light one. Dark ink on a dark wallpaper is the failure this prevents.

## Typography (`Theme.text*`)
Inter, a screen-first grotesk close to Apple's SF, variable, shell-only (apps
keep fontconfig's `sans-serif`). One ratio, 1.25 (a major third), so every
size step feels related:

| Token | px | Use |
|---|---|---|
| textXs | 11 | meta: time, keycaps, value readouts |
| textMd | 13 | body, controls, bar text (default); `textSm` is an alias |
| textLg | 16 | titles, launcher result names |
| textXl | 20 | headings, search input |
| textHero | 32 | display (power menu) |
| textTimer | 40 | timer readout (Light, tabular) |
| textDisplay | 96 | desktop clock (Light only) |

`Widgets/Label` applies the optical size (`opsz` = px, Inter's text cut at 14,
display cut at 32) and Inter's dynamic tracking (`Theme.tracking(px)`:
-0.0223 + 0.185 e^(-0.1745 px) em; slightly open at 11, tight at display
sizes), so all UI text goes through `Label` (inputs set the same three
properties).
Weights: `weightTitle` (600) for titles at 16 px and up; `weightEmphasis`
(500) for emphasis at 13 / 11 px (Inter's 600 is too heavy that small);
Normal for body; Light only for display sizes. Never Bold.
Hierarchy = a size step *or* a muted colour, never both. Numbers that change
use tabular figures in the UI font (`font.features: { "tnum": 1 }`), never
the monospace font; `mono` is only for code-like values (`InfoRow.mono`).
Data is never shown raw: tool output (nvd's `[U.] #1 fd 10.5.0 -> 10.5.1`)
is parsed into a name and a muted detail. Line height: leave 1 for single lines (Qt shifts glyphs
down otherwise); `Theme.lineHeight` 1.25 only for wrapped body text.

## Icons
`Widgets/Icon`: `glyph` is a Material Symbols Rounded ligature name ("wifi",
"volume_up", see fonts.google.com/icons) rendered in `Theme.symbols` at
`Theme.iconWeight` (400, matched to Inter at `textMd`), optical size
following the box, grade `Theme.iconGrade` (-25 on dark: light strokes on
dark glass bloom, per Google's guidance); `filled: true` = state "on", and
the fill *grows in* over `animFast`: the shell's one signature
micro-interaction. Nerd Font codepoints still
render (private-use characters never collide with names) but only for brand or
app marks with no symbol. An unknown name renders as literal text, so check
new names on screen. The box is always size x size.
Sizes: iconSm 12 (dismiss, dense) | icon 16 (default: bar, rows) | iconLg 20
(headers, tile badges) | iconXl 24 (launcher) | iconHero 32 | `iconApp` 32 for
app images in lists, `icon` 16 in the bar. Icon-to-text gap `gapInline`. Icons
inherit text colour (muted when inactive).

## Sizing
Heights on the 4-pt grid; minimum hit target `control` 32.
controlSm 24 (dismiss, chips) | control 32 (bar chip, icon button) | controlLg
40 | controlXl 56 (the one primary round button of a card) | rowHeight 40 (48
with subtitle) | resultHeight 56 | fieldHeight 56 | tileHeight 64 |
trackHeight 8 | thumb 16 | sliderHeight 48.
Widths: panelWidth 400 (Control Center, toasts), launcherWidth 640 (880 in
two-pane mode), calendarWidth 336, popoverWidth 320.

## Motion
Purposeful, fast, one language across shell and compositor. Animate colour,
opacity, offset and scale of *content*, never a glass sheet.
- Durations: animInstant 80 (press), animFast 120 (hover wash), anim 220
  (state, entrances), animExit 150 (exits are quieter), animSlow 340 (theme
  change), animPulse 1400 (breathing; the only loop, and only while something
  needs you, e.g. an active screen share).
- Curves: entrances/moves `curveDecelerate` (= niri `cubic-bezier 0.05 0.7 0.1
  1`); exits `curveAccelerate` (= `0.3 0 0.8 0.15`); plain state changes
  `easing` (OutCubic). Springs (`springStiff`/`springDamp`) for press/release
  scale only (`pressScale`). Compositor spatial motion is a critically damped
  niri spring.
- Entrances: `Widgets/Enter` fades and lifts content `enterRise` into a sheet;
  lists stagger by `stagger` ms up to `staggerMax`. Once per open; nothing
  animates at idle.
- Windows: niri open 94% -> 100% + fade (220 ms decelerate), close 100% -> 96% +
  fade (150 ms accelerate). Wallpaper: awww `grow` from the centre, 1.2 s.

Rules from the final audit (Apple HIG Motion: purposeful, brief, never on
frequent interactions):
- Frequent interactions (hovering rows and chips, typing, scrolling) get at
  most an `animFast` colour/opacity step: no movement, no scale. Press
  feedback (`Clickable` spring, `pressScale`) stays.
- Exempt by name, because each explains space rather than decorating it: the
  dock's opt-in macOS magnification (a familiar idiom), the notification fan
  (disclosure, behind hover intent), and the power menu's 4 % lift of the
  chosen action (rare and modal). Nothing else moves on hover.
- Loops: only `animSpin` (a spinner while busy) and the stepped `animPulse`
  (while privacy / screencast / recording is live), plus the gated lock
  shader. Every loop is gated on `Theme.motionScale > 0`, so low power freezes
  it instead of spinning at zero duration.
- Exits use `animExit` + `curveAccelerate`; entrances `anim` +
  `curveDecelerate`; no literal curves (the dock hop now uses them too).

### Motion tiers
Same language everywhere; tiers change richness and cost. `motion-tier`
(modules/motion.nix) scores the machine: gpu (0 none, 2 older Intel/unknown, 4
Intel Xe/AMD APU, 6 Arc/NVIDIA/discrete AMD) + cpu (0 <8 threads, 1 >=8, 2
>=16) + ram (1 if >=16 GiB) - pixel penalty (Mpx/s of outputs: <=150 0, <=300
1, <=600 2, else 3). `low` <= 1, `balanced` 2-5, `high` >= 6. The T480 scores
3-4: balanced. Override in Settings > Appearance > Motion; `tier.json` and the
niri include (`~/.local/state/motion/`) are rewritten on change and hotplug.
- low: blur 1 pass, plain fades, stiffer springs; durations x0.7, no stagger,
  no rise, no cava.
- balanced: look.kdl as is; stagger 18 (max 6), rise `spaceSm`; workspace pill
  grows with its slot; toasts slide in.
- high: blur 4 passes, richer window open/close, stagger 22 (max 8), rise
  `spaceMd`, `Enter` also scales, animated lock background.
- On battery or power-saver the shell drops one tier. Tokens: `motionTier`,
  `motionLevel`, `motionAmbient` (balanced+), `motionRich` (high). Gate heavy
  effects on those flags, never on the tier name.

## Low power
`Services/PowerMode.lowPower` (Settings "Low power": auto = on battery, always,
never) is the single switch: `Theme.motionScale` 0 (all `anim*` collapse),
cava stops, the desktop now-playing line hides, a leaf shows in the bar status
cluster, the power-saver profile is set (and the previous one restored after),
and `~/.local/state/theme/niri-power.kdl` turns blur off and animations 5x
faster. Gate any new continuous work on it.

---

# 3. Components

## Bar
A 40 px glass pill (`barHeight` = control 32 + 2 x `barInset` 4, `radiusBar`
12, E1), `barMargin` from the screen top and sides, items `barGap` apart,
`barPadX` from its ends. Every item is a `BarChip` (32 high, `padControl`,
square when icon-only); nothing is hand-positioned. Active chip = neutral
`hover` wash.

Three zones, read left to right as *where · when · what's going on*:
- **Left, where:** workspaces as a page indicator, and nothing else (the
  focused app's name was redundant: you know what you're looking at; the
  space stays empty). The indicator is drawn to the pixel:
  - Dots `spaceSm` 8, edge-to-edge gaps a constant `spaceSm` 8 (centre
    spacing 16, the iOS page-control rhythm). The active workspace is a pill
    3 dots wide (24 = dot + gap + dot), so the row reads dot / gap / dot
    everywhere and neighbours glide when the pill moves (`Behavior on width`,
    decelerate, balanced+).
  - Meaning by value, not hue: active `text`, occupied `textMuted`, empty
    `textFaint`; urgent `error` (the only exception).
  - Hit targets tile without dead zones: each dot's target spans half the gap
    on both sides and the full bar height (Fitts). No hover box around a dot:
    hover lifts an inactive dot one value step.
  - Bilateral balance: the first dot's left edge sits as far from the bar's
    left end as the last status icon's *box* sits from the right end
    (`barPadX` + `padControl` = 24). Boxes align, not ink: the battery
    glyph's own side bearing puts its ink at 28, and per-glyph nudges would
    break whenever another icon ends the row.
  - Urgency is live (`WorkspaceUrgencyChanged` in `Services/Niri`).
- **Centre, when:** the clock, truly centred and never overlapped; the only
  full-contrast text on the bar; tabular figures. Last resort drops the
  weekday.
- **Right, what's going on**, two zones:
  1. *Context* chips that exist only while something is happening: next event
     (inside the Settings window before an event or while it runs), media,
     focus timer, recording, screen share, removable drive, input method (only
     when not the default layout), system (only under load).
  2. *Status cluster*, always present: Wi-Fi, volume, battery (percentage only
     below 20% and not charging, then `error`, tabular), Bluetooth only while
     connected, DND / low-power (`eco`, muted) marks only while on. No unread
     mark: the Control Center and toasts carry notifications. Symbol names are mapped from service state inside
     the chip. The privacy dot (mic/camera) and recording are `tertiary`, a
     screen share `error`; none of them collapse. Tray apps live in one
     `more_horiz` chip whose hover card holds the icons.
  Weather is not on the bar (Control Center and desktop show it).

Responsive priorities: `Widgets/ResponsiveRow` picks the lowest collapse level
whose summed item widths fit between the screen edge and the clock. Items
report `widthAt(level)` from content metrics, never laid-out sizes (no
feedback loop, no per-frame work). Right side, 6 levels: 1 titles shorten
(media, next event), 2 media is a glyph only, 3 input method, next event and
drive go, 4 system and focus timer go, 5 battery % goes. Left: the app name is
elastic (no levels). Last resort: the clock drops the
weekday. Status icons, recording, screen share and privacy never collapse.
Clock: Medium weight, tabular figures.

## Bar popovers
A popover's top is `popoverGap` below the bar (`popoverTop`), centred on its
trigger and clamped to `barMargin` from the screen sides; it never overlaps the
bar. Layer windows set `exclusionMode: ExclusionMode.Ignore` (otherwise niri
adds the bar's exclusive zone on top of the margin). `Widgets/Popover`
(namespace `qs-popover`, radius 16, E2): opens after `hoverOpen` 350 ms of
hover, closes `hoverClose` 200 ms after the pointer leaves; `interactive` cards
(media, system monitor) stay open under the pointer, passive ones let clicks
through. `Widgets/Tooltip` is for item-relative tips inside other sheets.

## Control Center
One layout (Apple-like, frequent first), all cards defined once in `CcCard`
(kind + visibility rule) and placed by the layout; never instantiate a card
directly:
1. Connectivity: Wi-Fi and Bluetooth side by side; their lists open full width
   below.
2. Quick toggles: compact `Tile`s whose column count keeps rows full (up to 5
   in one row, 6 as 3 x 2): Focus (hold for its menu), Awake, Mic, Night,
   Record, and Home-row mods when kanata is available. No Capture tile (the
   screenshot keys do that).
3. Sliders: brightness, volume.
4. Media, only while something plays.
5. Modules: one-line rows that expand in place, one at a time: Battery,
   Weather, Devices (when any), Updates (only with changes, a running check or
   a failure) and Backup (only when the last run failed or the last success is
   older than 3 days, `BackupStatus`). Visibility lives in `CcCard.wanted`, not
   in the layout.
6. Notifications.
7. Footer, pinned to the sheet's bottom edge (the content scrolls above it):
   Wallpaper, Settings, Lock, Power as bare muted icons, a fill only on hover.
Services expose symbol names directly (`Network.icon`, `Audio.volumeIcon`,
`Power.icon`, `BluetoothState.deviceIcon(d)`, ...); no module translates them.
Groups are `gapSection` apart, items `gapStack`; sheet `radiusXl` 28 with
`padSheet` 16, so cards are `radiusMd` 12. Modules are rows of one `Group`
and Notifications is its own `Group`, so the larger gap between them reads as
intended. The sheet is `panelHeight` (648, golden ratio) high, capped by the
screen; the default content fits without scrolling.

Wi-Fi and Bluetooth lists never scan on their own: opening one shows what is
known (NetworkManager's cache, paired devices). The refresh button in the list
header (bare 32 px round, neutral) scans for `Settings.scanWindow` (1 / 2 / 5
min, Settings > General); the glyph becomes a spinning `progress_activity` and
its tooltip shows the minutes left; pressing again stops. A scan also ends when
its window ends, its list closes or the Control Center closes (`ScanWindow`: one
single-shot timer per service, no idle polling).

Disclosure follows "Hierarchy": a module row opens an L2 recessed well
(`Section` flat, `spaceMd` padding, `rowRadius`) directly under it inside its
group, content on columns A/B, `spaceMd` after it; the Wi-Fi / Bluetooth /
Sound lists open as an L2 well (`DetailList`) right under the connectivity
row. Every control is a `Widgets/Button` (quiet / tonal pill, or a 32 circle
for icons); static headlines and summaries never react to hover.

Behaviour: the sheet has a fixed height and its content scrolls inside it; nothing inside may resize the window (each
layer-surface resize made niri re-blur and re-shadow the whole sheet: ~2x
quickshell and niri CPU and dropped frames on the T480). Scrolling is native
`Flickable` by default (`Settings.scrollStyle` "native"; `Widgets/SmoothWheel`
only when "smooth"); never bake the content into a layer texture while
scrolling (~40 ms stall at every scroll start). A 1x1 surface is mapped once at
startup so the first real open is cheap.

## Notifications (toasts and Control Center list)
One widget family: `NotificationGroup` (a stack per app) of
`NotificationCard`s, flat neutral cards over `glassSolid`, so toasts (no niri
blur) and Control Center cards read as one material.
- Card (Sonoma layout): leading app tile (`controlLg`, `radiusSm`, neutral
  `tile` backing, icon `iconApp` centred; a missing icon becomes the app's
  initial on the same neutral tile), then one text column: caption (`textXs`
  muted "App · time", close on hover), summary Medium, body muted (2 lines,
  full when open or hovered); thumbnail trailing (`radiusSm`), action pills. In
  the Control Center the group header names the app, so tile and name are
  dropped. Critical: a small `error` mark, never expires.
- Collapsed: newest card in front, up to `stackLayers` cards tucked beneath
  (`stackPeek` edge, `stackShrink` scale and `stackFade` opacity per layer;
  content hidden), "+N more" past that.
- Fan: toasts fan on hover; Control Center groups fan only after the pointer
  *rests* on them (the `opener` timer restarts on every pointer move, so
  sweeping across groups never opens them) and freeze while the list scrolls.
  Cards animate y, scale and height from tucked pose to slot, staggered,
  decelerate. Leaving collapses after `hoverClose`; expiry pauses while
  hovered; "Show all" pins a group open.
- Toast window: never animated per frame. It grows to the fanned height when a
  transition starts (transparent, click-through `mask`) and shrinks after the
  collapse ends. `qs-toasts` has no niri rule, so cards draw their own material
  and may fade/slide.
- Space budget: the toast column never exceeds the screen height minus bar and
  margins. A fanned group shows at most `fanCards` (4) and scrolls the rest
  under a `spaceXl` edge fade; at most `toastGroups` (4) stacks show (critical
  never fold), the rest fold into one "+M more apps" pill that opens the
  Control Center; one group fans at a time.
- Timers: none without toasts; relative time ticks once a minute only while a
  card is visible.

## Calendar
Today is the one filled accent day; a picked day is a neutral `fillOn` disc;
event dots are data colours. The agenda is one `Group` per day with a muted
header on column A; finished events are muted text (not faded). Header
chevrons and "Today" are `Button`s.
`Services/CalendarEvents` reads `~/.cache/quickshell/calendar.json` (written by
the `calendar-sync` user service from sops-held ICS feeds, view only). One
single-shot timer sleeps to the next boundary (start, end, reminder, chip
window, midnight; capped at 10 min for suspend); nothing polls. The dropdown
shows up to 3 `dot`s under a day with events (one per calendar colour, a data
colour; today is the primary-filled day and uses `primaryText`), and an agenda
under the grid: a 4 px colour bar, a `controlXl` time column, title and
location, a join glyph for meeting links. It takes the height the screen leaves
and scrolls past that; clicking a day filters to it. Reminders are toasts
through notify-send with a Join action, once per event id. The desktop line is
`textMd` muted under the weather, hidden when nothing is within 12 h.

## Focus timer
One countdown, no phases: set a length, Play/Pause, Reset. Focus (DND) is on
while it runs, never overriding a Focus the user set. `Widgets/TimerCard` is the
only UI: `textTimer` Light tabular time inside a `ProgressRing`, round `-`/`+`
(hold or scroll to repeat), preset chips, Reset (`controlLg`) and Play/Pause
(`controlXl`, the only filled control). Click the time to type minutes or
mm:ss. It lives in the bar chip's popover and, while idle, in
`Modules/FocusTimer/TimerPanel` under the clock (`qs-popover` rule); Mod+P, the
launcher and the Focus menu open it. Seconds tick only while a card or mm:ss is
visible; otherwise one single-shot timer fires at the end.

## Arrival and departure
The peak-end rule: a session is remembered by its peak and its end, so boot,
login, lock, unlock and power-off are designed as one continuous gesture.
- One clock lockup (`Modules/Desktop/ClockLockup`): Inter Light
  `textDisplay` 96, tabular figures, `Theme.tracking`, date at `textXl`. The
  desktop places it bottom-left in wallpaper ink (`onWallpaper*`); lock and
  greeter centre it in image ink (`onImage*`), because it's the only thing
  on those screens.
- One backdrop: the lock and the greeter use the same blurred wallpaper of
  the mode in use (`lock.jpg`, written by `wallpaper`); the greeter receives
  copies of the theme state (`brightness.json`, `wallpaper.jpg`, palette) from
  `scripts/system-setup.sh`.
- Cross-fades, never cuts: lock in = the sharp wallpaper dissolves to blur
  while content rises; unlock = content fades and the blur dissolves back to
  the sharp wallpaper (`animSlow`; 0 in low power). Content fades, never the
  glass.
- **Every cut lands on the same colour.** Greeter -> session crosses a
  compositor hand-off that is unavoidably blank, so the greeter fades its
  image *back to the surface* before it, and the session niri's
  `backdrop-color` is that same surface (matugen `niri.kdl`); the wallpaper
  then fades in (`wallpaper watch`, 0.8 s). Splash surface -> greeter ->
  surface -> niri surface -> wallpaper: in dark mode the gap disappears, in
  light mode it is a brief dip instead of a black flash between two bright
  images.
- Boot / power-off splash (Plymouth, `configs/plymouth/hh`): the palette
  surface and one slowly breathing dot, no spinner. `system-setup.sh` bakes
  the mode in use into it (`@SURFACE@`, `@TEXT@`, `dot.png` or `dot-ink.png`),
  since the initramfs can't read the mode; re-run it after changing mode for
  the splash to follow.

## Dock
Optional bottom dock (`Modules/Dock`, `Services/Dock.qml`, `qs-dock`): radius
`radiusLg` 16 (= rule), E2, padding `spaceSm`, icons `dockIconSize` (48,
32-64) in `+spaceSm` slots, a hairline divider between pinned and running.
Auto-hide *loads* the sheet when the pointer touches the 4 px
`qs-dock-trigger` strip (640 px wide, centred, clear of the hot corner) and
unloads it 350 ms after leaving; the sheet is never faded, scaled or moved;
only icons animate.
- Style (`dockStyle`): **macos** (default: cosine magnification up to +12%
  across `motionLevel + 1` neighbours, launch hop, drag to reorder pinned
  icons) or **minimal** (hover wash, hovered icon lifts +8%, no hop).
- Running: one dot per window (max 3) under the icon; `error` when urgent.
- Hop (macos, balanced+): rises `spaceSm` and falls, looping only while a
  launch is pending (max `hoverOpen * 12` ms) or a window is urgent; never at
  idle.
- Built-ins (`@settings`) are a neutral squircle (`radiusMd`) with the symbol
  at half the icon size. Name label: `Tooltip` after `hoverOpen`; context menu:
  app name, one row per window, hairline, then pin / new window / close all.

## Settings
Apple System Settings structure, Muji restraint (`Modules/Settings`).
- Sheet: `settingsHeight` 640 high, width = height x `ratio` (1036), capped by
  the screen; E3; never resized per frame.
- Sidebar: one `Group` of `ListRow`s, monochrome symbols (no coloured icon
  tiles); selected = neutral `fillOn` wash, `filled` icon, `weightEmphasis`.
  No accent in the sidebar.
- Page: title `textXl` `weightTitle` on column A (`Theme.columnA`); content
  capped at `launcherWidth` and left-aligned (empty space beyond, never
  stretched). The first group has no heading: the page title names it.
- `SettingsGroup` = muted `textXs` heading + `Group` + optional muted
  footnote / empty line. `SettingsRow` = title + one-line muted description
  on the left, exactly one control on the right (`SettingsSwitch`,
  `Segmented`, `SettingsSlider`, `SettingsField`, `Button`), dimmed to
  `disabledOpacity` when it can't act.
- Switch: Apple idiom, a `fillSolid` knob on a `track` when off, on the accent
  when on.
- No information-only rows: what isn't a setting is a footnote or nothing.
  Rare and destructive items sit at the bottom of their page or in About.
- Module components never share a basename with `Widgets/`, `Services/` or
  `Common/` (an explicit `import qs.Widgets` shadows the folder's own type and
  blanks the page; qmllint can't see it).

## Launcher
Selection is the only accent: the highlighted result and clipboard entry use
`primaryWash`, a selected wallpaper or emoji tile a `primary` ring. Mode
chips, kind pills and pins are neutral. Results are `ResultRow`
(launcher-only, so it lives in `Modules/Launcher`); the search glyph and the
result icons share one `iconApp` box on column A.
`launcherWidth` 640, highlight `radiusLg`. Prefixes: `>` run, `+` quick note
(Mod+Shift+N, appends `- YYYY-MM-DD HH:MM text` to the neorg inbox at
`Settings.notesInbox`, default `~/mh_notes/inbox.norg`, and toasts "Saved to
inbox"), `<` clipboard. Clipboard is two-pane (`launcherWidthWide` 880; the
window resizes, the sheet is never scaled): list 2/5 with `controlLg` rows
(colour entries show a swatch), preview 3/5 on `tile`, `radiusLg`, `padCard`;
fixed 8-row height so the preview never jumps; destructive confirm (clear all)
in `error` in the footer.

## System monitor
The bar's system chip hover card *is* the monitor (a glance shouldn't need a
click). An interactive `Popover`: CPU and memory `StatRow`s with sparklines,
network, `InfoRow`s for sensors, fan and load, then the top 5 processes by CPU
(`textXs` tabular %, an `error` "Quit" pill that sends SIGTERM; session-critical
processes, `System.protectedProcs`, get none). `Services/System` samples
cheaply every 2 s for the chip's visibility; the detail probe runs only while
the card is open. Sensors are chosen by hwmon driver name and label, never by
number; absent rows don't appear.

---

# 4. Engineering

## Performance budget (measured on the ThinkPad T480, UHD 620)
- Idle costs nothing: no polling, no looping animation, no ticking clock that
  isn't visible. Prefer one single-shot timer to the next boundary.
- Never resize, fade or scale a niri-blurred layer surface per frame.
- No `layer.enabled` / offscreen textures for scrolling or per card (measured
  worse).
- Lavish effects only behind `motionRich`; continuous work off in `lowPower`.
- Apps launched from the shell go through `Apps.run`/`Apps.start` (a systemd
  scope), so restarting quickshell never kills the user's terminals; icons via
  `Apps.iconFor` (absolute paths become `file://` URLs).

## Linting
`./lint.sh` runs qmllint over everything (a temp copy with generated qmldirs so
`import qs.*` resolves; needs `QS_QML` = Quickshell's `lib/qt-6/qml`, `QT_QML` =
qtdeclarative's, and `qmllint` on PATH). Warning levels live in `.qmllint.ini`:
Quickshell false positives are off, everything else (unused imports, id
shadowing, property overrides) must be clean. CI:
`.github/workflows/lint.yml` in the dotfiles repo.

## Known gaps (code not yet matching this direction)
- None known. Add here what you find, with the rule it breaks.

---

## Sources
- Kenya Hara on emptiness: [Quartz](https://qz.com/quartzy/1140182/mujis-design-philosophy-is-emptiness-not-minimalism-says-kenya-hara), [Design Anthology](https://designanthologymag.com/story/kenya-hara-conversation), [Muji, "The art of simple design"](https://www.muji.eu/pages/muji-stories/the-art-of-simple-design.html), ["this will do", via a reading of *Designing Design*](https://medium.com/@ulumills/a-manual-for-un-knowing-excavating-insights-from-kenya-haras-designing-design-551858182a32)
- Calm technology: [Wikipedia](https://en.wikipedia.org/wiki/Calm_technology), [Amber Case, O'Reilly](https://oreilly.com/content/principles-calm-technology-we-are-not-bad-at-technology-technology-is-bad-at-us)
- Laws (Hick, Fitts, Von Restorff, Jakob, Tesler, Doherty, aesthetic-usability, Gestalt): [Laws of UX](https://lawsofux.com/)
- Dieter Rams, ten principles of good design: [Vitsœ](https://www.vitsoe.com/us/about/good-design)
- Apple: Human Interface Guidelines (clarity, deference, depth); [macOS Tahoe menu bar and Control Center](https://www.macrumors.com/2025/06/11/macos-tahoe-all-the-little-changes/)
- Icons: [Material Symbols](https://fonts.google.com/icons)
