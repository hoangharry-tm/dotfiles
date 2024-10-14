" Enable folding based on headers
let g:vim_markdown_folding_disabled = 0

" Enable table of contents generation
let g:vim_markdown_toc_autofit = 1

" Don't conceal `*` or `#`
let g:vim_markdown_conceal = 0

augroup pencil
  autocmd!
  autocmd FileType markdown call pencil#init({'wrap': 'soft'})
augroup END
