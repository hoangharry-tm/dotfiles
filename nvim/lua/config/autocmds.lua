vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",
  callback = function()
    vim.b.cmp_enabled = false
    vim.b.codeium_enabled = false
  end,
})
