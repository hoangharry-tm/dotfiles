local opts = { noremap = true, silent = true }

-- Map jj to Esc key
vim.keymap.set("i", "jj", "<ESC>", { silent = true })

-- Tabs
vim.keymap.set("n", "<tab>", ":tabnext<Return>", opts)
vim.keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)

-- Split window
vim.keymap.set("n", "ss", ":split<Return>", opts)
vim.keymap.set("n", "sv", ":vsplit<Return>", opts)
