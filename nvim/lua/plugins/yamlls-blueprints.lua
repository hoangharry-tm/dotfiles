-- Fix: "Quali Torque Blueprint Spec 2" in SchemaStore has
--   fileMatch = "**/blueprints/**.yaml"
-- which collides with every YAML file in Aethel Workspace's blueprints/
-- directory and produces false-positive errors like "Missing property
-- spec_version" and "Property X is not allowed".
--
-- Solution: replace LazyVim's yamlls before_init hook with one that loads
-- the same SchemaStore catalog but ignores the Quali Torque entry.
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local yamlls = opts.servers.yamlls or {}

      yamlls.before_init = function(_, config)
        config.settings = config.settings or {}
        config.settings.yaml = config.settings.yaml or {}
        config.settings.yaml.schemas = require("schemastore").yaml.schemas({
          ignore = { "Quali Torque Blueprint Spec 2" },
        })
      end

      opts.servers.yamlls = yamlls
    end,
  },
}
