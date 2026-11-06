return {
  "kndndrj/nvim-dbee",
  cmd = "Dbee", -- lazy.lua defaults to lazy=false; this plugin cost ~33 ms at startup
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  build = function()
    -- Install tries to automatically detect the install method.
    -- if it fails, try calling it with one of these parameters:
    --    "curl", "wget", "bitsadmin", "go"
    require("dbee").install()
  end,
  config = function()
    -- Connection string comes from a sops-nix secret (path in $DBEE_URL_FILE);
    -- no file (e.g. macOS) means no preconfigured connection.
    local sources = {}
    local path = vim.env.DBEE_URL_FILE
    local f = path and io.open(path, "r")
    if f then
      local url = f:read("*l")
      f:close()
      if url and url ~= "" then
        table.insert(sources, require("dbee.sources").MemorySource:new({
          { id = "bravo_pge_harryhoang", name = "BravoPGE", type = "postgres", url = url },
        }))
      end
    end
    require("dbee").setup({ sources = sources })
  end,
}
