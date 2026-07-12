let g:airline_theme = 'minimalist'

" ── Tabline ───────────────────────────────────────────────────────────────
let g:airline#extensions#tabline#enabled      = 1
let g:airline#extensions#tabline#formatter    = 'unique_tail'
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#show_tabs    = 1
let g:airline#extensions#tabline#tab_nr_type  = 1   " show tab number
let g:airline#extensions#tabline#left_sep     = ' '
let g:airline#extensions#tabline#left_alt_sep = '│'

" ── Extensions ────────────────────────────────────────────────────────────
let g:airline#extensions#ale#enabled         = 1
let g:airline#extensions#ale#error_symbol    = '✖ '
let g:airline#extensions#ale#warning_symbol  = '▲ '
let g:airline#extensions#coc#enabled         = 1
let g:airline#extensions#branch#enabled      = 1
let g:airline#extensions#branch#format       = 2   " trim long names

" ── Separators — solid vertical bars, no powerline glyphs ─────────────────
let g:airline_powerline_fonts = 0
let g:airline_left_sep        = '▌'
let g:airline_right_sep       = '▐'
let g:airline_left_alt_sep    = '│'
let g:airline_right_alt_sep   = '│'

" ── Symbols ───────────────────────────────────────────────────────────────
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.branch   = '⎇ '
let g:airline_symbols.readonly = '[RO]'
let g:airline_symbols.modified = '[+]'
let g:airline_symbols.paste    = 'PASTE'
let g:airline_symbols.notexists = '?'
let g:airline_symbols.whitespace = 'Ξ'

" ── Section layout ────────────────────────────────────────────────────────
" A: mode (auto)
" B: branch + diagnostics
" C: filepath + modified flag
" X: filetype
" Y: encoding + line endings
" Z: position
let g:airline_section_b = '%{airline#extensions#branch#get_head()}'
let g:airline_section_c = '%f%m%r'
let g:airline_section_x = '%{strlen(&filetype) ? &filetype : "none"}'
let g:airline_section_y = '%{&encoding}│%{&fileformat}'
let g:airline_section_z = '☰ %l/%L  :%c  %p%%'
