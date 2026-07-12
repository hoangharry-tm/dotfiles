# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal Neovim configuration built on [LazyVim](https://lazyvim.github.io/) (v8). LazyVim provides the full base layer — LSP, treesitter, keymaps, formatters, and extras — and this repo customizes on top of it. Changes here are overrides and additions, not a from-scratch config.

## Architecture

**Entry point**: `init.lua` → `lua/config/lazy.lua` (bootstraps lazy.nvim and loads all specs)

**Load order enforced by LazyVim**:
1. `lua/config/options.lua` — loaded before lazy.nvim startup
2. `lua/config/lazy.lua` — plugin spec assembly
3. `lua/config/keymaps.lua` — on `VeryLazy` event
4. `lua/config/autocmds.lua` — on `VeryLazy` event
5. `lua/plugins/*.lua` — each file returns a plugin spec table; all auto-imported

**Customization pattern**: plugins in `lua/plugins/` either introduce new plugins (return a new spec) or override LazyVim defaults (return a spec with the same plugin name and `opts =` or `config =` to merge/replace). LazyVim extras are enabled via `lazyvim.json` (not in Lua).

**Key design decisions**:
- `version = false` globally — all plugins track latest git commit, not semver releases
- Colorscheme: `solarized-osaka` (set in `lazy.lua`); `sonokai` (andromeda style, transparent) also loaded
- Neovide: DankMono Nerd Font at h13, 90% opacity — configured at the bottom of `lazy.lua`
- Terminal font: DankMono Nerd Font, size 14 (kitty config at `~/.config/kitty/kitty.conf`)
- Completion engine: blink.cmp (LazyVim default — nvim-cmp is NOT installed)

## Active plugins (custom, beyond LazyVim base)

| File | Plugin(s) | Purpose |
|---|---|---|
| `neorg.lua` | nvim-neorg/neorg + luarocks.nvim | Note-taking; workspaces at `~/mh_notes` |
| `neorg.lua` | 3rd/image.nvim | Inline image rendering via kitty graphics protocol |
| `neorg.lua` | HakonHarnes/img-clip.nvim | Paste clipboard images into norg/markdown files |
| `neorg.lua` | michaelb/sniprun | Run code blocks inline |
| `neorg.lua` | folke/zen-mode.nvim + twilight.nvim | Distraction-free writing |
| `dbee.lua` | nvim-dbee | DB client; Postgres connection to BravoPGE dev |
| `vimtex.lua` | vimtex | LaTeX; viewer = zathura |
| `colorscheme.lua` | solarized-osaka, sonokai | Themes |
| `neo-tree.lua` | neo-tree | Shows dotfiles; hides .gitignored |
| `snacks-nvim.lua` | snacks.nvim | Picker searches hidden + gitignored files |
| `yamlls-blueprints.lua` | nvim-lspconfig (yamlls override) | Excludes "Quali Torque Blueprint Spec 2" from SchemaStore to suppress false YAML errors in Aethel Workspace `blueprints/` dirs |
| `ltex.lua` | barreiroleo/ltex_extra.nvim | Handles ltex-ls code actions (Add to dictionary, Add to library, Hide false positive); persists to `~/.local/share/ltex/` |
| `go.lua` | nvim-lspconfig override | Disables `golangci_lint_ls` auto-start — Mason has `golangci-lint-langserver` installed which conflicts with nvim-lint's `golangcilint` linter (both run golangci-lint, causing duplicate diagnostics) |

## LazyVim extras enabled (`lazyvim.json`)

Lang: Python, Go, TypeScript/VTSLS, Java, Lua, SQL, Markdown, YAML, Dart, Svelte, Vue, Tailwind, Clojure, C/CMake, Docker, Git
Tools: Prettier, ESLint, yanky, inc-rename, gh, gitui, mini-hipatterns, mini-animate, project, VSCode compat

## Formatting

StyLua is the Lua formatter. Config in `stylua.toml`:
- 2-space indentation
- 120-column width

Format a file: `stylua lua/plugins/myplugin.lua`
Check without writing: `stylua --check lua/`

## Custom keymaps

- `fd` (insert mode) → `<Esc>` (escape alias)
- `<LocalLeader>tt` → neorg todo cycle (remapped from `<C-Space>` to avoid tmux leader conflict)
- `<leader>z` → ZenMode toggle
- `<leader>ip` → PasteImage (img-clip) — pastes clipboard image, saves to `assets/`, inserts `.image` tag
- `<leader>sr/sc/sx` → SnipRun / SnipClose / SnipReset

## Prose formatting (norg + markdown)

`textwidth=80` with `formatoptions+=tqn` set in `autocmds.lua` — hard-wraps at 80
columns as you type. Use `gwip` (normal mode) to reflow the paragraph under the
cursor after edits. The `a` flag (auto-reflow on every keystroke) is deliberately
off — it destroys `@code ... @end` blocks in norg and fenced code blocks in markdown.

## Adding a plugin

Create `lua/plugins/<name>.lua` returning a spec table. It's auto-imported. To
override a LazyVim plugin, use the exact upstream plugin name and supply `opts`
(merged) or `config` (replaces). To enable a LazyVim extra, add it to the
`extras` array in `lazyvim.json` — do not add extra plugins in Lua for things
LazyVim already ships as an extra.

## Neorg setup

### Workspaces

| Workspace | Path | Purpose |
|---|---|---|
| `notes` | `~/mh_notes` | General notes, home index |
| `work` | `~/mh_notes/work` | Internship / work notes |
| `journal` | `~/mh_notes/journal` | Daily journal (`:Neorg journal today`) |

Home index: `~/mh_notes/index.norg` — links to all major sections.

### Notes structure

```
~/mh_notes/
  index.norg              ← home / hub
  CLAUDE.md               ← Claude context when working in notes
  learning/{dsa,systems,networking,os}/
  interview/{behavioral,technical,companies}/
  reports/
  resources/
  work/
  journal/daily/
```

### Completion

None. LazyVim uses blink.cmp; neorg has no blink.cmp integration. The
`core.integrations.nvim-cmp` and `core.completion` modules were removed to
prevent a startup crash. Do not re-add them without first installing nvim-cmp
or a neorg blink.cmp source.

### Treesitter parsers (norg + norg_meta)

These are not nvim-treesitter parsers — neorg ships them via luarocks. They
were manually copied to `~/.local/share/nvim/site/parser/` so Neovim finds
them on the runtimepath. If they break after a neorg update, re-copy:

```sh
cp ~/.local/share/nvim/lazy-rocks/tree-sitter-norg/lib/lua/5.1/parser/norg.so \
   ~/.local/share/nvim/site/parser/
cp ~/.local/share/nvim/lazy-rocks/tree-sitter-norg-meta/lib/lua/5.1/parser/norg_meta.so \
   ~/.local/share/nvim/site/parser/
```

### luarocks.nvim

The `dkjson` rock must be present in the plugin's `.rocks` tree. If the
"Unable to load the luarocks package loader" error reappears, run:

```sh
~/.local/share/nvim/lazy/luarocks.nvim/.rocks/bin/luarocks install dkjson \
  --tree ~/.local/share/nvim/lazy/luarocks.nvim/.rocks
```

### Image pasting and rendering (img-clip + image.nvim)

- **Paste**: copy image to clipboard → `<leader>ip` in a `.norg` file →
  saves to `assets/` relative to the note, inserts `.image assets/name.png`
- **Render**: image.nvim auto-renders `.image` infirm tags via the kitty
  graphics protocol. Works only in a raw kitty window — tmux does not forward
  the kitty graphics protocol and images will not appear there.
- **Clear images**: `:lua require("image").clear()`
- ImageMagick (v7) and the `magick` luarock are both installed and working.
