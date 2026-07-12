" ALE: diagnostics only — coc.nvim handles completion and formatting
let g:ale_completion_enabled = 0
let g:ale_fix_on_save         = 0    " coc handles formatting
let g:ale_linters_explicit    = 1
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave  = 1

let g:ale_linters = {
    \ 'python':             ['flake8', 'mypy'],
    \ 'go':                 ['golangci-lint', 'staticcheck'],
    \ 'javascript':         ['eslint'],
    \ 'typescript':         ['eslint'],
    \ 'javascriptreact':    ['eslint'],
    \ 'typescriptreact':    ['eslint'],
    \ 'vue':                ['eslint'],
    \ 'c':                  ['clangd'],
    \ 'cpp':                ['clangd'],
    \ 'lua':                ['luacheck'],
    \ 'elixir':             ['credo'],
    \ 'yaml':               ['yamllint'],
    \ 'sh':                 ['shellcheck'],
    \ 'dockerfile':         ['hadolint'],
    \ }

" ── Fixers (invoked via :ALEFix or <leader>af) ────────────────────────────
let g:ale_fixers = {
    \ 'python': ['black', 'isort', 'remove_trailing_lines', 'trim_whitespace'],
    \ 'go':     ['gofmt', 'goimports'],
    \ }

let g:ale_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰', '│', '─']
let g:ale_sign_error   = '✖'
let g:ale_sign_warning = '▲'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
