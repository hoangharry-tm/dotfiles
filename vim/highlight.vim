" Applied after the colorscheme so these overrides always win
augroup HighlightOverrides
    autocmd!
    autocmd ColorScheme * call s:ApplyHighlights()
augroup END

function! s:ApplyHighlights() abort
    " ── retrobox palette helpers ──────────────────────────────────────────
    " bg=#1c1c1c  fg=#ebdbb2  red=#fb4934  green=#b8bb26
    " yellow=#fabd2f  blue=#83a598  magenta=#d3869b  cyan=#8ec07c
    " orange=#fe8019  gray=#928374  line=#3c3836

    " Search — retrobox warm tones
    highlight IncSearch ctermfg=black  ctermbg=yellow  guifg=#1c1c1c guibg=#fabd2f
    highlight Search    ctermfg=black  ctermbg=blue    guifg=#1c1c1c guibg=#83a598

    " Visual selection — subtle blue tint
    highlight Visual ctermfg=NONE ctermbg=23 guifg=NONE guibg=#2a4a5c

    " Git gutter — retrobox green/red/yellow
    highlight GitGutterAdd    guifg=#b8bb26 ctermfg=10
    highlight GitGutterChange guifg=#fabd2f ctermfg=11
    highlight GitGutterDelete guifg=#fb4934 ctermfg=9

    " Sign column — blend with retrobox dark background
    highlight SignColumn guibg=#1c1c1c ctermbg=NONE

    " Cursor line — subtle highlight
    highlight CursorLine   guibg=#3c3836 ctermbg=237
    highlight CursorColumn guibg=#3c3836 ctermbg=237

    " Line numbers — muted gray
    highlight LineNr       guifg=#928374 ctermfg=243
    highlight CursorLineNr guifg=#ebdbb2 guibg=#3c3836 ctermfg=229 ctermbg=237

    " Color column — subtle retrobox red-tinted
    highlight ColorColumn guibg=#282828 ctermbg=235

    " Spell — retrobox red underline
    highlight SpellBad   guisp=#fb4934 gui=undercurl ctermfg=9 cterm=underline
    highlight SpellCap   guisp=#83a598 gui=undercurl ctermfg=14 cterm=underline

    " Markdown headings — retrobox accent hierarchy
    highlight markdownH1 guifg=#fb4934 ctermfg=9   " red
    highlight markdownH2 guifg=#fe8019 ctermfg=208 " orange
    highlight markdownH3 guifg=#fabd2f ctermfg=11  " yellow
    highlight markdownH4 guifg=#b8bb26 ctermfg=10  " green
    highlight markdownH5 guifg=#83a598 ctermfg=12  " blue
    highlight markdownH6 guifg=#928374 ctermfg=243 " gray
endfunction

call s:ApplyHighlights()
