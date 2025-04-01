call plug#begin('~/.vim/plugged')
    " Markdown Plugins
    " Plug 'preservim/vim-markdown'         " Markdown Syntax Highlighting
    Plug 'godlygeek/tabular'                " Align tables in markdown
    Plug 'preservim/vim-pencil'             " Improved writing experience
    Plug 'junegunn/goyo.vim'                " Distraction-free writing mode
    Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
    
    " FZF Search Files
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'  " FZF plugin for Vim
    
    Plug 'vim-airline/vim-airline'
    Plug 'git@github.com:vim-airline/vim-airline-themes.git'

    " Colorscheme(s)
    Plug 'arzg/vim-colors-xcode'
    Plug 'morhetz/gruvbox'
    Plug 'NLKNguyen/papercolor-theme'
    Plug 'ayu-theme/ayu-vim'

    " Plugins for Python Development
    Plug 'dense-analysis/ale'
    Plug 'davidhalter/jedi-vim'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}

    " Git
    Plug 'tpope/vim-fugitive'
    Plug 'stevearc/oil.nvim'
call plug#end()

syntax on
filetype indent on
filetype plugin on

colo ayu

source ~/.config/vim/settings.vim
source ~/.config/vim/mappings.vim
source ~/.config/vim/autocmd.vim
source ~/.config/vim/highlight.vim
source ~/.config/vim/globals.vim

" Plugins Configs
source ~/.config/vim/plugins/vim-airline.vim
source ~/.config/vim/plugins/markdown.vim
source ~/.config/vim/plugins/coc.vim
