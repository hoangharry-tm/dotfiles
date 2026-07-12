" ── MacVim GUI — Borland/DOS retro appearance ────────────────────────────

" Font: ProggyClean Nerd Font Mono — pixel-perfect DOS bitmap appearance
" (Nerd Font variant includes icons for NERDTree)
set guifont=DankMono\ Nerd\ Font:h12
set noantialias

" Strip down to a clean text IDE — no toolbar, no scrollbars
set guioptions-=T          " no toolbar
set guioptions-=r          " no right scrollbar
set guioptions-=R          " no right scrollbar on vsplit
set guioptions-=l          " no left scrollbar
set guioptions-=L          " no left scrollbar on vsplit
set guioptions-=e          " use text tabline instead of native GUI tabs
set guioptions+=c          " use console dialogs

" Default window geometry
set lines=45 columns=140

" Blinking block cursor — authentic DOS feel
set guicursor=n-v-c:block-Cursor-blinkon500-blinkoff500-blinkwait300,
            \i-ci:ver25-Cursor-blinkon400-blinkoff400,
            \r-cr:hor20-Cursor
