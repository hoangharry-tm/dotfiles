return {
  "nvim-neorg/neorg",
  lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
  version = "*", -- Pin Neorg to the latest stable release
  run = ":Neorg sync-parsers",
  config = function()
    require("neorg").setup({
      load = {
        ["core.defaults"] = {},
        ["core.keybinds"] = {},
        ["core.concealer"] = {},
        ["core.summary"] = {},
        ["core.completion"] = {
          config = {
            engine = "nvim-cmp",
          },
        },
        ["core.dirman"] = {
          config = {
            index = "index.norg",
            workspaces = {
              base = "~/neorg/",
              base_personal = "~/neorg/personal/",
              base_todo = "~/neorg/todo/",
            },
          },
        },
        ["core.tangle"] = {},
      },
    })
  end,
}
