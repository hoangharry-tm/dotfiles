return {
  {
    -- Lua dependencies (incl. the norg treesitter parsers) are installed by
    -- lazy.nvim's built-in luarocks support into stdpath("data")/lazy-rocks —
    -- no luarocks.nvim needed.
    "nvim-neorg/neorg",
    lazy = false,
    version = "*",
    init = function()
      -- The parser rocks ship `parser/<lang>.so` under lib/lua/5.1, which
      -- isn't on the runtimepath by default; add it so treesitter finds them.
      for _, rock in ipairs({ "tree-sitter-norg", "tree-sitter-norg-meta" }) do
        vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy-rocks/" .. rock .. "/lib/lua/5.1")
      end
    end,
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
      filetypes = {
        -- image.nvim renders .image infirm tags in norg
        norg = {
          template = ".image $FILE_PATH",
        },
      },
    },
  },

  -- Render images inline (kitty only — disabled in Neovide)
  {
    "3rd/image.nvim",
    cond = not vim.g.neovide,
    event = { "BufReadPre *.norg", "BufReadPre *.md" },
    opts = {
      backend = "kitty",
      integrations = {
        neorg = {
          enabled = true,
          filetypes = { "norg" },
          only_render_image_at_cursor = false,
        },
        markdown = { enabled = true },
      },
      max_width_window_percentage = 50,
      max_height_window_percentage = 40,
      editor_only_render_when_focused = true,
      window_overlap_clear_enabled = true,
    },
  },

  -- Run code blocks inline from notes — great for learning
  {
    "michaelb/sniprun",
    branch = "master",
    build = "sh install.sh",
    cmd = { "SnipRun", "SnipClose", "SnipReset" },
    keys = {
      { "<leader>sr", "<cmd>SnipRun<cr>", mode = { "n", "v" }, desc = "SnipRun" },
      { "<leader>sc", "<cmd>SnipClose<cr>", desc = "SnipRun close" },
      { "<leader>sx", "<cmd>SnipReset<cr>", desc = "SnipRun reset" },
    },
    opts = {
      display = { "NvimNotify" },
      selected_interpreters = {},
      repl_enable = {},
    },
  },
}
