return {
  -- luarocks.nvim is required by neorg for native Lua dependency management
  {
    "vhyrro/luarocks.nvim",
    priority = 1001,
    config = true,
  },
  {
    "nvim-neorg/neorg",
    dependencies = { "luarocks.nvim" },
    lazy = false,
    version = "*",
    config = function()
      require("neorg").setup({
        load = {
          ["core.defaults"] = {},
          ["core.concealer"] = {
            config = { icon_preset = "diamond" },
          },
          ["core.dirman"] = {
            config = {
              workspaces = {
                notes = "~/notes",
                work = "~/notes/work",
                journal = "~/notes/journal",
              },
              default_workspace = "notes",
              index = "index.norg",
            },
          },
          ["core.integrations.nvim-cmp"] = {},
          ["core.completion"] = {
            config = { engine = "nvim-compe" },
          },
          ["core.export"] = {},
          ["core.export.markdown"] = { config = { extensions = "all" } },
          ["core.summary"] = {},
          ["core.keybinds"] = { config = { default_keybinds = true } },
          ["core.ui.calendar"] = {},
          ["core.journal"] = {
            config = {
              workspace = "journal",
              journal_folder = "daily",
            },
          },
          ["core.highlights"] = {},
          ["core.looking-glass"] = {},
        },
      })
    end,
  },
}
