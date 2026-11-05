local vault = vim.fn.expand("~") .. "/Library/CloudStorage/OneDrive-Personal/mh_obsidian/personal"

return {
  {
    "obsidian-nvim/obsidian.nvim",
    lazy = true,
    event = {
      "BufReadPre " .. vault .. "/**.md",
      "BufNewFile " .. vault .. "/**.md",
    },
    opts = function()
      return {
        legacy_commands = false,
        workspaces = {
          {
            name = "personal",
            path = "~/Library/CloudStorage/OneDrive-Personal/mh_obsidian/personal",
          },
        },
        note_id_func = require("obsidian.builtin").title_id,
        new_notes_location = "current_dir",
        open_notes_in = "current",
        picker = {
          name = "snacks.picker",
        },
        completion = {
          min_chars = 2,
        },
        link = {
          style = "wiki",
          format = "shortest",
          auto_update = true,
        },
        attachments = {
          folder = "attachments",
        },
        ui = {
          enable = true,
        },
        frontmatter = {
          enabled = false,
        },
      }
    end,
    keys = {
      { "<leader>o", group = "obsidian" },
      { "<leader>oo", "<cmd>Obsidian<cr>", desc = "Commands" },
      { "<leader>on", "<cmd>Obsidian new<cr>", desc = "New note" },
      { "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "Quick switch" },
      { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search vault" },
      { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
      { "<leader>of", "<cmd>Obsidian follow_link<cr>", desc = "Follow link" },
      { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Rename note" },
      { "<leader>ol", "<cmd>Obsidian link<cr>", mode = "v", desc = "Link selection" },
      { "<leader>ot", "<cmd>Obsidian tags<cr>", desc = "Tags" },
      { "<leader>op", "<cmd>Obsidian paste_img<cr>", desc = "Paste image" },
    },
  },
}
