return {
  {
    "barreiroleo/ltex_extra.nvim",
    ft = { "bib", "gitcommit", "markdown", "org", "plaintex", "rst", "tex", "norg" },
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
      -- Where to persist dictionary/disabled-rules/false-positives files.
      path = vim.fn.expand("~/.local/share/ltex"),
      init_check = false, -- disable immediate load; we reload on LspAttach instead
      log_level = "none",
    },
    config = function(_, opts)
      require("ltex_extra").setup(opts)
      -- Reload dictionaries only after ltex actually attaches to a buffer,
      -- avoiding the race condition where catch_ltex() finds no client.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and (client.name == "ltex" or client.name == "ltex_plus") then
            require("ltex_extra").reload()
          end
        end,
      })
    end,
  },

  -- Override the ltex-ls server config to load via ltex_extra instead of
  -- plain lspconfig, so the custom word/rule handlers are registered.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ltex = {
          settings = {
            ltex = {
              language = "en-US",
              -- ltex_extra manages these — do not set them here
            },
          },
        },
      },
    },
  },
}
