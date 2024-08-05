return {
  "stevearc/oil.nvim",
  opts = {
    float = {
      padding = 10,
    },
    view_options = {
      show_hidden = true,
    },
  },
  -- Optional dependencies
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  keys = {
    {
      "<leader>o",
      function()
        local oil = require("oil")
        oil.open_float(".")
      end,
      desc = "Open oil float window",
    },
  },
}
