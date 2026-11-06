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
| `neorg.lua` | nvim-neorg/neorg | Note-taking; workspaces at `~/mh_notes` (Lua deps via lazy.nvim's built-in luarocks) |
| `neorg.lua` | 3rd/image.nvim | Inline image rendering via kitty graphics protocol |
| `neorg.lua` | HakonHarnes/img-clip.nvim | Paste clipboard images into norg/markdown files |
| `neorg.lua` | michaelb/sniprun | Run code blocks inline |
| `neorg.lua` | folke/zen-mode.nvim + twilight.nvim | Distraction-free writing |
| `dbee.lua` | nvim-dbee | DB client; Postgres connection to BravoPGE dev |
| `vimtex.lua` | vimtex | LaTeX; viewer = sioyek |
| `colorscheme.lua` | solarized-osaka, sonokai | Themes |
| `neo-tree.lua` | neo-tree | Shows dotfiles; hides .gitignored |
| `snacks-nvim.lua` | snacks.nvim | Picker searches hidden + gitignored files |
| `yamlls-blueprints.lua` | nvim-lspconfig (yamlls override) | Excludes "Quali Torque Blueprint Spec 2" from SchemaStore to suppress false YAML errors in Aethel Workspace `blueprints/` dirs |
| `disable-lsp-servers.lua` | nvim-lspconfig override | Disables `ltex` (grammar checker) and `texlab` (LaTeX LSP) — LaTeX support comes from VimTeX alone |
| `render-markdown.lua` | render-markdown.nvim override | `pipe.border_virtual = true` — table borders render on virtual lines so a table at the end of a note doesn't overflow into the footnote |
| `go.lua` | nvim-lspconfig override | Disables `golangci_lint_ls` auto-start — Mason has `golangci-lint-langserver` installed which conflicts with nvim-lint's `golangcilint` linter (both run golangci-lint, causing duplicate diagnostics) |
| `obsidian.lua` | obsidian-nvim/obsidian.nvim (main) | Obsidian vault integration — wikilink nav, backlinks, search, rename, embedded `obsidian-ls` LSP completion, paste_img |
| `ruby.lua` | nvim-lspconfig + neotest overrides | Enables `ruby_lsp` + `rubocop` (installed via rbenv, not Mason); bundle-aware LSP cmds; neotest-rspec + neotest-minitest adapters |

## LazyVim extras enabled (`lazyvim.json`)

Lang: Python, Go, TypeScript/VTSLS, Java, SQL, Markdown, YAML, Dart, Svelte, Vue, Tailwind, Clojure, C/CMake, Docker, Git, Ruby
(Lua has no extra — LazyVim's base layer already sets up `lua_ls`.)
Tools: Prettier, ESLint, mini-surround, yanky, inc-rename, gh, gitui, mini-hipatterns, mini-animate, project, VSCode compat
Test: core (neotest + `<leader>t` keymaps)

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
- `<leader>o*` → Obsidian (group): `<leader>oo` commands picker, `on` new note, `oq` quick switch, `os` search, `ob` backlinks, `of` follow link, `or` rename, `ol` (visual) link selection, `ot` tags, `op` paste image
- In-vault buffer maps (obsidian.nvim defaults): `<CR>` smart action (follow/toggle), `]o`/`[o` next/prev link

## Prose formatting (norg + markdown)

Non-Obsidian `norg`/`markdown` buffers use `textwidth=80` with
`formatoptions+=tqn` in `autocmds.lua` — hard-wraps at 80 columns as you type.
Use `gwip` (normal mode) to reflow the paragraph under the cursor after edits.
The `a` flag (auto-reflow on every keystroke) is deliberately off — it destroys
`@code ... @end` blocks in norg and fenced code blocks in markdown.

**Obsidian vault notes are the exception: soft wrap only.** They set
`textwidth=0` (see the soft-wrap bullet under "Obsidian setup"), so they never
hard-wrap no matter what `formatoptions` contains. To reflow one at a fixed
width: `:set tw=80 | gwip | set tw=0`.

## Adding a plugin

Create `lua/plugins/<name>.lua` returning a spec table. It's auto-imported. To
override a LazyVim plugin, use the exact upstream plugin name and supply `opts`
(merged) or `config` (replaces). To enable a LazyVim extra, add it to the
`extras` array in `lazyvim.json` — do not add extra plugins in Lua for things
LazyVim already ships as an extra.

## Ruby / Rails setup

Laptop: Ruby + Rails managed via **rbenv** (Homebrew-installed). Init lines are
in `~/.zshrc` (`export PATH="$HOME/.rbenv/bin:$PATH"` +
`eval "$(rbenv init - zsh)"`). Global version: `4.0.6`; Rails `8.1.3.1`
installed as a gem. `ruby-lsp` and `rubocop` gems are installed globally via
rbenv — **not** through Mason.

Neovim (`lua/plugins/ruby.lua` overrides the `lang.ruby` extra):
- `ruby_lsp` + `rubocop` LSPs are enabled with `mason = false` (mason-lspconfig
  only auto-enables servers it installed). Both use a `cmd` factory
  (`vim.lsp.rpc.start`): if the gem is in the project's `Gemfile` **and**
  `Gemfile.lock`, they run via `bundle exec` (so `ruby-lsp-rails` and the
  project's rubocop config load); otherwise they fall back to the global
  binary. Spawn cwd is `config.root_dir`.
- Formatting (from the extra): conform runs `rubocop` for ruby and
  `erb_format` for eruby; mason installs `erb-formatter`/`erb-lint`.
- Tests via neotest (`<leader>t` group, `test.core` extra): `neotest-rspec`
  forced to `bundle exec rspec`; `neotest-minitest` uses `bin/rails test` when
  `bin/rails` exists, else `bundle exec ruby -Itest`.

Per-project Rails app: `bundle add ruby-lsp ruby-lsp-rails` (then reopen) to
get Rails-aware features; RuboCop config comes from
`rubocop-rails-omakase` (already in the Rails 8 default Gemfile).

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

These are not nvim-treesitter parsers — neorg's rockspec pulls them in as the
`tree-sitter-norg` / `tree-sitter-norg-meta` rocks, which lazy.nvim installs
into `~/.local/share/nvim/lazy-rocks/`. The rocks put the parser at
`lib/lua/5.1/parser/<lang>.so`, which is not on the runtimepath by default, so
neorg's `init` in `neorg.lua` appends those dirs. No manual copying needed.

On the Arch/Nix machine, Home Manager (hh-nix-config,
`modules/programs/neovim.nix`) additionally links Nix-built parsers into
`~/.local/share/nvim/site/parser/`, which comes first on the runtimepath. The
rock binaries are prebuilt on Ubuntu and need `libstdc++`, which Nix's Neovim
can't load on a non-NixOS system.

### luarocks

No `luarocks.nvim`: it built its own luarocks from upstream HEAD (unpinned)
and broke when luarocks 3.13 started requiring `dkjson`. lazy.nvim's built-in
rocks support is used instead; it needs a Lua 5.1 `luarocks` on PATH (Nix:
`luajitPackages.luarocks`) or falls back to installing `hererocks`.

### Image pasting and rendering (img-clip + image.nvim)

- **Paste**: copy image to clipboard → `<leader>ip` in a `.norg` file →
  saves to `assets/` relative to the note, inserts `.image assets/name.png`
- **Render**: image.nvim auto-renders `.image` infirm tags via the kitty
  graphics protocol. Works only in a raw kitty window — tmux does not forward
  the kitty graphics protocol and images will not appear there.
- **Clear images**: `:lua require("image").clear()`
- ImageMagick (v7) and the `magick` luarock are both installed and working.

## Obsidian setup

`obsidian.lua` wires obsidian.nvim (tracking `main`, the 4.0 rewrite) to the
OneDrive Obsidian vault:

- Vault: `~/Library/CloudStorage/OneDrive-Personal/mh_obsidian/personal`
- Workspace name: `personal`. Plugin lazy-loads only for `*.md` inside that vault.
- **Completion** is the embedded `obsidian-ls` in-process LSP server (no
  nvim-cmp / blink.compat). Works with blink.cmp's `lsp` source; starts on
  BufEnter of a vault note. `:Obsidian check` verifies setup.
- Picker: `snacks.picker` (no telescope/fzf needed on main).
- `frontmatter.enabled = false` — vault notes use custom YAML (e.g.
  `type: "[[🗼 Store]]"`) so obsidian must NOT rewrite frontmatter. New notes are
  created as plain markdown; do not re-enable without testing a save first.
- `note_id_func = title_id` — new notes get readable slug filenames.
- Keymaps: `<leader>o` group + default buffer maps `<CR>`, `]o`, `[o`.
- macOS deps: `pngpaste` (for `:Obsidian paste_img`); `fzf`/`rg` not required
  but present.
- Vault editing quirks (in `autocmds.lua`): for any `*.md` under
  `~/OneDrive/mh_obsidian/` (or its real path) line numbers are off and
  diagnostics are muted — markdownlint's MD013/MD041 are noise in notes.
  Completion is unaffected.
- Vault notes soft-wrap: `wrap` + `linebreak` + `textwidth=0` — display wraps
  at word boundaries and typing never hard-wraps. `textwidth=0` is used (not
  just removing the `t` formatoptions flag) because plugins reloading on the
  markdown filetype (render-markdown via LazyVim's `do FileType`) re-add `t`;
  with no width, hard wrap can't fire regardless. To reflow a paragraph at 80:
  `:set tw=80 | gwip | set tw=0`. Applied via BufEnter, a `vim.schedule` re-apply
  in the FileType autocmd, and two deferred re-applies for the arg-started buffer.
