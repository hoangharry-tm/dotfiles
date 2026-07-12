" ── preservim/vim-markdown ──────────────────────────────────────────────────
" Conceal markdown syntax — renders **bold**, *italic*, `code`, ~~strike~~, etc.
let g:vim_markdown_conceal = 1
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_emphasis_multiline = 1
let g:vim_markdown_strikethrough_conceal = 1

" Folding by headings
let g:vim_markdown_folding_disabled = 0
let g:vim_markdown_folding_level = 6

" Table of contents
let g:vim_markdown_toc_autofit = 1

" Auto-write TOC on save
let g:vim_markdown_toc_autofit_onwrite = 1

" Front-matter (YAML) handling
let g:vim_markdown_frontmatter = 1

" ── conceallevel + org-mode style conceal ─────────────────────────────────
" Syntax match conceal rules are in ~/.vim/after/syntax/markdown.vim
" (loaded automatically after vim-markdown's syntax — cleaner and more
"  reliable than creating them via autocmd)

" Highlight links for the conceal groups created in after/syntax
highlight default link mkdownOrgH1 Title
highlight default link mkdownOrgH2 PreProc
highlight default link mkdownOrgH3 String
highlight default link mkdownOrgH4 Identifier
highlight default link mkdownOrgH5 Type
highlight default link mkdownOrgH6 Comment
highlight default link mkdownOrgBullet Comment
highlight default link mkdownOrgCheckbox Identifier
highlight default link mkdownOrgQuote Comment

" ── preservim/vim-pencil ───────────────────────────────────────────────────
let g:pencil#conceallevel = 1
let g:pencil#concealcursor = 'nc'

augroup pencil
  autocmd!
  autocmd FileType markdown call pencil#init({'wrap': 'soft'})
augroup END

" ── dhruvasagar/vim-table-mode ──────────────────────────────────────────────
let g:table_mode_corner = '|'
let g:table_mode_border_left = '|'
let g:table_mode_border_right = '|'
let g:table_mode_fillchar = '-'

" ── Checkbox cycling ──────────────────────────────────────────────────────
function! s:toggle_checkbox() range
  let l:lnum = a:firstline
  while l:lnum <= a:lastline
    let l:line = getline(l:lnum)
    if l:line =~# '\[ \]'
      call setline(l:lnum, substitute(l:line, '\[ \]', '[x]', ''))
    elseif l:line =~# '\[x\]'
      call setline(l:lnum, substitute(l:line, '\[x\]', '[ ]', ''))
    endif
    let l:lnum += 1
  endwhile
endfunction

nnoremap <silent> <Plug>(md-checkbox) :call <SID>toggle_checkbox()<CR>:noh<CR>
xnoremap <silent> <Plug>(md-checkbox) :call <SID>toggle_checkbox()<CR>:noh<CR>

" ── <leader>m*: Markdown group ───────────────────────────────────────────
nmap <leader>mp :MarkdownPreview<CR>
nmap <leader>mc <Plug>(md-checkbox)
xmap <leader>mc <Plug>(md-checkbox)
nmap <leader>mt :TableModeToggle<CR>
nmap <leader>mg :Goyo<CR>
