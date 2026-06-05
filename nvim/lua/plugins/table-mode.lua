return {
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown", "norg", "org", "text" },
    init = function()
      vim.g.table_mode_corner = "|"
      vim.g.table_mode_header_fillchar = "-"
    end,
    keys = {
      { "<leader>tm", "<cmd>TableModeToggle<cr>", desc = "Table Mode Toggle" },
      { "<leader>tr", "<cmd>TableModeRealign<cr>", desc = "Realign Table" },
    },
  },
}
