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
                notes = "~/mh_notes",
                work = "~/mh_notes/work",
                journal = "~/mh_notes/journal",
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
          ["core.keybinds"] = {
            config = {
              default_keybinds = true,
              hook = function(keybinds)
                -- <C-Space> conflicts with tmux leader; remap todo cycle
                keybinds.remap_event("norg", "n", "<C-Space>", "<LocalLeader>tt")
              end,
            },
          },
          ["core.ui.calendar"] = {},
          ["core.journal"] = {
            config = {
              workspace = "journal",
              journal_folder = "daily",
            },
          },
          ["core.highlights"] = {},
          ["core.looking-glass"] = {},
          ["core.presenter"] = {
            config = { zen_mode = "zen-mode" },
          },
        },
      })
    end,
  },

  -- Distraction-free writing (integrates with neorg presenter)
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
    opts = {
      window = { width = 90 },
      plugins = { twilight = { enabled = true } },
    },
  },

  -- Dims inactive code/text — pairs with zen-mode
  {
    "folke/twilight.nvim",
    cmd = { "Twilight", "TwilightEnable", "TwilightDisable" },
    opts = { dimming = { alpha = 0.25 } },
  },

  -- Paste images directly into .norg files
  {
    "HakonHarnes/img-clip.nvim",
    event = "BufEnter",
    keys = {
      { "<leader>ip", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
    },
    opts = {
      default = {
        dir_path = "assets",
        use_absolute_path = false,
        relative_to_current_file = true,
      },
    },
  },

  -- Render images inline (requires ImageMagick + ueberzugpp or kitty protocol)
  {
    "3rd/image.nvim",
    lazy = false,
    opts = {
      backend = "kitty", -- kitty terminal supports this natively
      integrations = {
        neorg = { enabled = true, filetypes = { "norg" } },
        markdown = { enabled = true },
      },
      max_width_window_percentage = 50,
      max_height_window_percentage = 40,
    },
  },

  -- Run code blocks inline from notes — great for learning
  {
    "michaelb/sniprun",
    branch = "master",
    build = "sh install.sh",
    cmd = { "SnipRun", "SnipClose", "SnipReset" },
    keys = {
      { "<leader>sr", "<cmd>SnipRun<cr>",   mode = { "n", "v" }, desc = "SnipRun" },
      { "<leader>sc", "<cmd>SnipClose<cr>",              desc = "SnipRun close" },
      { "<leader>sx", "<cmd>SnipReset<cr>",              desc = "SnipRun reset" },
    },
    opts = {
      display = { "NvimNotify" },
      selected_interpreters = {},
      repl_enable = {},
    },
  },
}
