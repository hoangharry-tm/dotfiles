let g:netrw_liststyle = 3
let g:netrw_banner    = 0

" ── Python venv detection ──────────────────────────────────────────────────
let g:python3_host_prog = trim(system('which python3 2>/dev/null || echo python3'))

" ── Go module awareness ───────────────────────────────────────────────────
let g:go_def_mapping_enabled = 0   " coc.nvim handles GoToDef

" ── Node.js PATH (nvm) ─────────────────────────────────────────────────────
let $PATH = '/Users/hoangharry/.nvm/versions/node/v22.19.0/bin:' . $PATH
