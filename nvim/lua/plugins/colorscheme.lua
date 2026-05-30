return {
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "sainnhe/sonokai",
    lazy = false,
    priority = 1000, -- Load this before everything else
    config = function()
      -- Enable transparency (1 = transparent, 2 = even more transparent)
      vim.g.sonokai_transparent_background = 1
      -- Optional: Choose your style (andromeda, atlantis, maia, espresso, shusia, etc.)
      vim.g.sonokai_style = "andromeda"
      -- Optional: Better performance
      vim.g.sonokai_better_performance = 1
    end,
  },
}
