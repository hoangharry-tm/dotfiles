let mapleader=" "

nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>
nmap <leader>h :noh<CR>
nmap <leader><leader>e :e ~/.config/vim/.vimrc<CR>
nmap <leader>ff :Files<CR>
nmap <C-e> :E<CR>

nnoremap <Tab> :tabnext<CR>
nnoremap <S-Tab> :tabprevious<CR>

imap jj <Esc>

source ~/.config/vim/plugins/coc-mappings.vim
