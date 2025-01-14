local virtual_text = require("codeium.virtual_text")
return {
  "Exafunction/codeium.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  config = function()
    require("codeium").setup({
      virtual_text = {
        enable = true,
        key_bindings = {
          -- Accept the current completion.
          accept = "<Tab>",
          -- Accept the next word.
          accept_word = true,
          -- Accept the next line.
          accept_line = true,
          -- Clear the virtual text.
          clear = false,
          -- Cycle to the next completion.
          next = "<M-]>",
          -- Cycle to the previous completion.
          prev = "<M-[>",
        },
      },
    })
  end,
  opts = {},
}
