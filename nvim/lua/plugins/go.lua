return {
  -- LazyVim's go extra already lints via nvim-lint (golangcilint).
  -- golangci-lint-langserver is installed in Mason, which causes mason-lspconfig's
  -- automatic_enable to also start golangci_lint_ls — doubling diagnostics and
  -- creating race conditions. Disable the LSP server; keep nvim-lint as the sole
  -- golangci-lint integration.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        golangci_lint_ls = { enabled = false },
      },
      -- LazyVim's gopls workaround (go.lua:60) indexes
      -- client.config.capabilities.textDocument.semanticTokens without a nil
      -- check. With blink.cmp the field can be absent, crashing the handler.
      -- Re-implement the same workaround with a guard.
      setup = {
        gopls = function(_, _)
          Snacks.util.lsp.on({ name = "gopls" }, function(_, client)
            if not client.server_capabilities.semanticTokensProvider then
              local caps = client.config.capabilities
              local semantic = caps
                and caps.textDocument
                and caps.textDocument.semanticTokens
              if not semantic then
                return
              end
              client.server_capabilities.semanticTokensProvider = {
                full = true,
                legend = {
                  tokenTypes = semantic.tokenTypes,
                  tokenModifiers = semantic.tokenModifiers,
                },
                range = true,
              }
            end
          end)
        end,
      },
    },
  },
}
