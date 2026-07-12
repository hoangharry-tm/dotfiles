set nocompatible
set autoindent
set smartindent
set smarttab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set textwidth=100
set fileformat=unix
set encoding=utf-8
set termencoding=utf-8

set number
set relativenumber
set ruler
set showcmd
set showmode
set laststatus=2
set showtabline=2

set hlsearch
set incsearch
set ignorecase
set smartcase

set wrap
set linebreak
set nolist

set hidden
set splitright
set splitbelow
set scrolloff=5
set sidescrolloff=8

set mouse=a
set ttymouse=sgr
set clipboard=unnamed

set backspace=indent,eol,start
set ma
set noswapfile
set nobackup
set nowritebackup
set updatetime=300
set signcolumn=yes
set novisualbell
set t_vb=

set wildmenu
set wildmode=longest:full,full

set background=dark
set termguicolors

set lazyredraw
set ttyfast

" ── Persistent undo (cross-session) ───────────────────────────────────────
set undofile
set undodir=~/.vim/undodir

" ── Completion menu ───────────────────────────────────────────────────────
set completeopt=menu,menuone,noselect
set shortmess+=c

" ── Whitespace visibility ─────────────────────────────────────────────────
set list listchars=tab:▸\ ,trail:·,nbsp:␣,extends:❯,precedes:❮

" ── Code folding (start unfolded) ─────────────────────────────────────────
set foldmethod=indent
set foldlevel=99
set foldlevelstart=99

" ── Live preview of substitutions (requires Vim 8.1.1946+) ────────────────
" set inccommand=nosplit   " uncomment if your Vim build supports it
set splitkeep=cursor
set confirm

" ── Better diffing ────────────────────────────────────────────────────────
set diffopt=internal,filler,vertical,algorithm:histogram,indent-heuristic
