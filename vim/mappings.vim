let mapleader=" "

" ── Escape aliases ────────────────────────────────────────────────────────
imap jj <Esc>
imap fd <Esc>

" ── Window navigation (matching neovim defaults) ───────────────────────────
nmap <silent> <C-k> :wincmd k<CR>
nmap <silent> <C-j> :wincmd j<CR>
nmap <silent> <C-h> :wincmd h<CR>
nmap <silent> <C-l> :wincmd l<CR>

" ── Tab navigation ────────────────────────────────────────────────────────
nnoremap <Tab>   :tabnext<CR>
nnoremap <S-Tab> :tabprevious<CR>

" ── <leader>f: Find ──────────────────────────────────────────────────────
nmap <leader>ff :Files<CR>
nmap <leader>fg :Rg<CR>
nmap <leader>fb :Buffers<CR>
nmap <leader>fr :History<CR>
nmap <leader>fc :Commands<CR>
nmap <leader>f/ :BLines<CR>

" ── <leader>b: Buffer ────────────────────────────────────────────────────
nmap <leader>bd :bd<CR>
nmap <leader>bD :bd!<CR>
nmap <leader>bo :%bd\|e#\|bd#<CR>

" Shift+H/L: previous/next buffer
nnoremap <S-h> :bprevious<CR>
nnoremap <S-l> :bnext<CR>

" Don't quit Vim when closing the last buffer — create a new empty one instead
augroup no_quit_on_empty
  autocmd!
  autocmd BufDelete * if empty(getbufinfo({'buflisted':1})) | enew | endif
augroup END

" ── <leader>g: Git ───────────────────────────────────────────────────────
nmap <leader>gg :G<CR>
nmap <leader>gc :Commits<CR>
nmap <leader>gb :G blame<CR>
nmap <leader>gd :Gdiffsplit<CR>

" ── <leader>e: Explorer ──────────────────────────────────────────────────
nmap <leader>ee :NERDTreeToggle<CR>
nmap <leader>ef :NERDTreeFind<CR>

" ── <leader>x: Save/Quit ─────────────────────────────────────────────────
nmap <leader>xw :w<CR>
nmap <leader>xq :q<CR>
nmap <leader>xx :x<CR>

" ── <leader>r: Run ───────────────────────────────────────────────────────
nmap <leader>rr :w<CR>:!go run %<CR>
nmap <leader>rt :w<CR>:!go test ./...<CR>
nmap <leader>rb :w<CR>:!go build ./...<CR>
nmap <leader>rp :w<CR>:!python3 %<CR>

" ── <leader>h: Utility ───────────────────────────────────────────────────
nmap <leader>hh :noh<CR>

" ── <leader>s: Spell ─────────────────────────────────────────────────────
nmap <leader>ss :setlocal spell!<CR>
nmap <leader>sn :]s<CR>
nmap <leader>sp [s
nmap <leader>sa zg

" ── <leader>c: Config ────────────────────────────────────────────────────
nmap <leader>ce :e ~/.config/vim/.vimrc<CR>

" ── Format ────────────────────────────────────────────────────────────────
nmap <leader>= :Format<CR>

" ── LSP mappings loaded from coc-mappings ─────────────────────────────────
source ~/.config/vim/plugins/coc-mappings.vim
