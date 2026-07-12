call plug#begin('~/.vim/plugged')

" ── Retrobox theme ──────────────────────────────────────────────────────
" Built-in as of Vim 9.0 (a gruvbox8 remake with retro CRT vibes)

" ── Statusline ────────────────────────────────────────────────────────────
Plug 'vim-airline/vim-airline'
Plug 'git@github.com:vim-airline/vim-airline-themes.git'

" ── File tree ─────────────────────────────────────────────────────────────
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'

" ── Fuzzy finder ──────────────────────────────────────────────────────────
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" ── LSP & Completion ──────────────────────────────────────────────────────
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" ── Linting ───────────────────────────────────────────────────────────────
Plug 'dense-analysis/ale'

" ── Git ───────────────────────────────────────────────────────────────────
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" ── Editing utilities ─────────────────────────────────────────────────────
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'

" ── Markdown ──────────────────────────────────────────────────────────────
Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'
Plug 'preservim/vim-pencil'
Plug 'junegunn/goyo.vim'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
Plug 'dhruvasagar/vim-table-mode'

" ── Start screen ──────────────────────────────────────────────────────────
Plug 'mhinz/vim-startify'

" ── Which-key popup ───────────────────────────────────────────────────────
Plug 'liuchengxu/vim-which-key'

call plug#end()

" ── Core ──────────────────────────────────────────────────────────────────
syntax on
filetype indent on
filetype plugin on

colorscheme retrobox

source ~/.config/vim/settings.vim
source ~/.config/vim/mappings.vim
source ~/.config/vim/autocmd.vim
source ~/.config/vim/highlight.vim
source ~/.config/vim/globals.vim

" ── Plugin configs ────────────────────────────────────────────────────────
source ~/.config/vim/plugins/vim-airline.vim
source ~/.config/vim/plugins/coc.vim
source ~/.config/vim/plugins/ale_linters.vim
source ~/.config/vim/plugins/nerdtree.vim
source ~/.config/vim/plugins/fzf-config.vim
source ~/.config/vim/plugins/startify.vim
source ~/.config/vim/plugins/markdown.vim
source ~/.config/vim/plugins/which-key.vim

" ── MacVim GUI ────────────────────────────────────────────────────────────
if has('gui_running')
    source ~/.config/vim/gui.vim
endif
