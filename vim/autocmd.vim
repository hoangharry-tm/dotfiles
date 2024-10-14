" Check file type
autocmd BufRead,BufNewFile *.md setlocal filetype=markdown

" Enable line wrapping for Markdown
autocmd FileType markdown setlocal wrap textwidth=80

" Set text width to 80 characters for better readability
autocmd FileType markdown setlocal textwidth=80

" Enable spell checking in Markdown
autocmd FileType markdown setlocal spell spelllang=en_us
