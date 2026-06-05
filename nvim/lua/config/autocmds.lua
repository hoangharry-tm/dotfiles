-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true -- break at word boundaries
  end,
})

-- Hard wrap at 80 for prose filetypes.
-- fo flags used:
--   t = auto-wrap while typing
--   q = allow gq/gw to reflow paragraphs
--   n = recognise numbered lists so gq doesn't break them
-- 'a' (auto-reflow on edit) is intentionally omitted — it destroys code blocks.
-- Use gw ip  to reflow the current paragraph after editing.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "norg", "markdown" },
  callback = function()
    vim.opt_local.textwidth = 80
    vim.opt_local.formatoptions:append("tqn")
    vim.opt_local.formatoptions:remove("l") -- don't skip already-long lines
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})
