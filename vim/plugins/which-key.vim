" ── vim-which-key ────────────────────────────────────────────────────────
"
" Layer structure:
"   <Space> f  → Find/Search
"   <Space> b  → Buffer
"   <Space> g  → Git
"   <Space> e  → Explorer
"   <Space> x  → Save/Quit
"   <Space> r  → Run/Build
"   <Space> m  → Markdown
"   <Space> l  → LSP
"   <Space> a  → Code Action
"   <Space> c  → Config
"   <Space> h  → Utility
"   <Space> s  → Spell
"   <Space> =  → Format

call which_key#register('<Space>', "g:which_key_map")

nnoremap <silent> <leader> :<C-u>WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :<C-u>WhichKeyVisual '<Space>'<CR>

set timeoutlen=400

let g:which_key_map = {}

" ── f: Find ──────────────────────────────────────────────────────────────
let g:which_key_map.f = {
    \ 'name': '+find',
    \ 'f': [':Files',            'files'],
    \ 'g': [':Rg',               'grep'],
    \ 'b': [':Buffers',          'buffers'],
    \ 'r': [':History',          'recent'],
    \ 'c': [':Commands',         'commands'],
    \ '/': [':BLines',           'lines'],
    \ }

" ── b: Buffer ────────────────────────────────────────────────────────────
let g:which_key_map.b = {
    \ 'name': '+buffer',
    \ 'd': [':bd',               'delete'],
    \ 'D': [':bd!',              'force delete'],
    \ 'o': [':%bd\|e#\|bd#',    'close others'],
    \ }

" ── g: Git ──────────────────────────────────────────────────────────────
let g:which_key_map.g = {
    \ 'name': '+git',
    \ 'g': [':G',                'status'],
    \ 'c': [':Commits',          'commits'],
    \ 'b': [':G blame',          'blame'],
    \ 'd': [':Gdiffsplit',       'diff'],
    \ }

" ── e: Explorer ──────────────────────────────────────────────────────────
let g:which_key_map.e = {
    \ 'name': '+explorer',
    \ 'e': [':NERDTreeToggle',   'toggle'],
    \ 'f': [':NERDTreeFind',     'find'],
    \ }

" ── x: e[x]it ────────────────────────────────────────────────────────────
let g:which_key_map.x = {
    \ 'name': '+save/quit',
    \ 'w': [':w',                'save'],
    \ 'q': [':q',                'quit'],
    \ 'x': [':x',                'save & quit'],
    \ }

" ── r: Run ────────────────────────────────────────────────────────────────
let g:which_key_map.r = {
    \ 'name': '+run',
    \ 'r': [':w\|!go run %',         'run'],
    \ 't': [':w\|!go test ./...',    'test'],
    \ 'b': [':w\|!go build ./...',   'build'],
    \ 'p': [':w\|!python3 %',        'python'],
    \ }

" ── m: Markdown ──────────────────────────────────────────────────────────
let g:which_key_map.m = {
    \ 'name': '+markdown',
    \ 'p': [':MarkdownPreview',        'preview'],
    \ 'c': ['<Plug>(md-checkbox)',     'checkbox'],
    \ 't': [':TableModeToggle',        'table'],
    \ 'g': [':Goyo',                   'focus'],
    \ }

" ── l: LSP ──────────────────────────────────────────────────────────────
let g:which_key_map.l = {
    \ 'name': '+lsp',
    \ 'a': [':CocList diagnostics',    'diagnostics'],
    \ 'e': [':CocList extensions',     'extensions'],
    \ 'c': [':CocList commands',       'commands'],
    \ 'o': [':CocList outline',        'outline'],
    \ 's': [':CocList symbols',        'symbols'],
    \ 'f': [':Format',                 'format'],
    \ 'r': ['<Plug>(coc-rename)',      'rename'],
    \ 'q': ['<Plug>(coc-fix-current)', 'fix'],
    \ 'd': ['<Plug>(coc-codelens-action)', 'lens'],
    \ }

" ── a: Action ────────────────────────────────────────────────────────────
let g:which_key_map.a = {
    \ 'name': '+action',
    \ 'a': ['<Plug>(coc-codeaction-selected)',   'code action'],
    \ 'c': ['<Plug>(coc-codeaction-cursor)',     'cursor'],
    \ 's': ['<Plug>(coc-codeaction-source)',     'source'],
    \ 'r': ['<Plug>(coc-codeaction-refactor)',   'refactor'],
    \ }

" ── c: Config ────────────────────────────────────────────────────────────
let g:which_key_map.c = {
    \ 'name': '+config',
    \ 'e': [':e ~/.config/vim/.vimrc', 'edit vimrc'],
    \ }

" ── h: Utility ───────────────────────────────────────────────────────────
let g:which_key_map.h = {
    \ 'name': '+utility',
    \ 'h': [':noh',               'clear highlight'],
    \ }

" ── s: Spell ─────────────────────────────────────────────────────────────
let g:which_key_map.s = {
    \ 'name': '+spell',
    \ 's': [':setlocal spell!',   'toggle'],
    \ 'n': [':]s',                'next'],
    \ 'p': ['[s',                 'prev'],
    \ 'a': ['zg',                 'add word'],
    \ }

" ── =: Format ────────────────────────────────────────────────────────────
let g:which_key_map['=']  = [':Format', 'format']
