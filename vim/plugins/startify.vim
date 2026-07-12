let g:startify_custom_header = [
    \ '   ┌──────────────────────────────────────┐',
    \ '   │  __   _____ __  __                   │',
    \ '   │  \ \ / /_ _|  \/  |                  │',
    \ '   │   \ V / | || |\/| |                  │',
    \ '   │    \_/ |___|_|  |_|                  │',
    \ '   │              retrobox 9.2            │',
    \ '   └──────────────────────────────────────┘',
    \ '   <Space>ff  Find File    <Space>fg  Live Grep',
    \ '   <Space>e   File Tree    <Space>fb  Buffers',
    \ '   <Space>gg  Git Status   <Space>Rr  Go Run',
    \ '   <Space>Rp  Python Run   <Space>Rt  Go Test',
    \ ]

let g:startify_lists = [
    \ { 'type': 'files',     'header': ['   Recent Files']    },
    \ { 'type': 'dir',       'header': ['   Current Dir: '. getcwd()] },
    \ { 'type': 'sessions',  'header': ['   Sessions']        },
    \ { 'type': 'bookmarks', 'header': ['   Bookmarks']       },
    \ ]

let g:startify_bookmarks = [
    \ { 'v': '~/.config/vim/.vimrc' },
    \ { 'z': '~/.zshrc' },
    \ ]

let g:startify_session_autoload    = 1
let g:startify_session_persistence = 1
let g:startify_change_to_dir       = 0
let g:startify_enable_special      = 0
