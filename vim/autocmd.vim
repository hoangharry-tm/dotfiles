augroup FileTypeSettings
    autocmd!

    " ── Markdown ────────────────────────────────────────────────────────────
    autocmd BufRead,BufNewFile *.md setlocal filetype=markdown
    autocmd FileType markdown setlocal wrap textwidth=80 spell spelllang=en_us

    " ── Go — tabs (idiomatic), no auto-comment leader, format on save ─────
    autocmd FileType go setlocal noexpandtab tabstop=4 shiftwidth=4
    autocmd FileType go setlocal formatoptions-=c formatoptions-=r formatoptions-=o
    autocmd FileType go nnoremap <silent><buffer> <F5>  :w<CR>:!go run %<CR>
    autocmd FileType go nnoremap <silent><buffer> <F6>  :w<CR>:!go test ./...<CR>
    autocmd FileType go nnoremap <silent><buffer> <F7>  :w<CR>:!go build ./...<CR>
    autocmd FileType go nnoremap <silent><buffer> <F8>  :CocCommand go.test.generate-unittests-for-function<CR>
    autocmd FileType go nnoremap <silent><buffer> <F9>  :CocCommand go.impl.cursor<CR>
    autocmd FileType go nnoremap <silent><buffer> <F10> :CocCommand go.tags.add<CR>
    autocmd FileType go autocmd BufWritePre <buffer> call CocActionAsync('format')

    " ── Python — 4 spaces, PEP 8, trim trailing whitespace, format on save ─
    autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4
    autocmd FileType python setlocal textwidth=99 colorcolumn=99
    autocmd FileType python setlocal formatoptions-=c formatoptions-=r formatoptions-=o
    autocmd FileType python autocmd BufWritePre <buffer> call CocActionAsync('format')
    autocmd BufWritePre *.py :%s/\s\+$//e
    autocmd FileType python nnoremap <silent><buffer> <F5> :w<CR>:!python3 %<CR>
    autocmd FileType python nnoremap <silent><buffer> <F6> :CocCommand python.execInTerminal<CR>

    " ── Web / config — 2-space indent ──────────────────────────────────────
    autocmd FileType javascript,typescript,javascriptreact,typescriptreact,
                   \vue,html,css,scss,json,yaml,toml,lua,elixir
                   \ setlocal tabstop=2 shiftwidth=2 softtabstop=2

    " ── Java — 4 spaces (already default, explicit) ────────────────────────
    autocmd FileType java setlocal tabstop=4 shiftwidth=4

    " ── Dockerfiles ────────────────────────────────────────────────────────
    autocmd BufRead,BufNewFile Dockerfile* setlocal filetype=dockerfile
    autocmd BufRead,BufNewFile docker-compose*.yml setlocal filetype=yaml

    " ── Terraform / HCL ────────────────────────────────────────────────────
    autocmd BufRead,BufNewFile *.tf,*.hcl setlocal filetype=hcl tabstop=2 shiftwidth=2

    " ── Shell ──────────────────────────────────────────────────────────────
    autocmd FileType sh,bash,zsh setlocal tabstop=2 shiftwidth=2

    " ── Elixir ─────────────────────────────────────────────────────────────
    autocmd FileType elixir,eelixir setlocal tabstop=2 shiftwidth=2

    " ── Close certain windows with q ───────────────────────────────────────
    autocmd FileType help,qf,fugitive,startify nnoremap <buffer> q :q<CR>

    " ── Auto-open quickfix when ALE/COC populates it ──────────────────────
    autocmd User ALELintPost if len(g:ale_buffer_info) | cwindow | endif

    " ── Return to last edit position ───────────────────────────────────────
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$")
                       \| exe "normal! g'\""
                       \| endif
augroup END
