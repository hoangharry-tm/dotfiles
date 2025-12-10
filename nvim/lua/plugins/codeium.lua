return {
  {
    "Exafunction/codeium.nvim",
    config = function()
      -- Create an autocommand that fires when the filetype is 'oil'
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("CodeiumOilDisable", { clear = true }),
        pattern = "oil",
        callback = function()
          -- Use a buffer-local variable to disable Codeium for this buffer
          vim.b.codeium_enabled = false
        end,
      })
    end,
  },
}
