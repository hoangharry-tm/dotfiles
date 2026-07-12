" ── NERDTree ─────────────────────────────────────────────────────────────
let g:NERDTreeShowHidden       = 1
let g:NERDTreeMinimalUI        = 1
let g:NERDTreeDirArrowExpandable  = '▶'
let g:NERDTreeDirArrowCollapsible = '▼'
let g:NERDTreeWinPos           = 'left'
let g:NERDTreeWinSize          = 30
let g:NERDTreeIgnore           = ['\~$', '\.git$', '__pycache__$', '\.pyc$',
                                 \'node_modules$', '\.DS_Store$', '\.class$']
let g:NERDTreeStatusline       = ''

" Auto-open NERDTree when vim is started with a directory (e.g. `mvim .`)
autocmd StdinReadPre * let s:std_in = 1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in')
            \ | execute 'NERDTree' argv()[0]
            \ | wincmd p
            \ | enew
            \ | execute 'cd' argv()[0]
            \ | endif

" Close vim if NERDTree is the only open window
autocmd BufEnter * if tabpagenr('$') == 1
            \ && winnr('$') == 1
            \ && exists('b:NERDTree')
            \ && b:NERDTree.isTabTree()
            \ | quit | endif

" ── vim-devicons ──────────────────────────────────────────────────────────
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose        = 1
let g:webdevicons_enable_nerdtree           = 1
