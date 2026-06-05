return {
  "kndndrj/nvim-dbee",
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
    require("dbee").setup({
      sources = {
        require("dbee.sources").MemorySource:new({
          {
            id = "bravo_pge_harryhoang",
            name = "BravoPGE",
            type = "postgres",
            url = "postgres://harryhoang:Bravo%401239@pge2-kt-dev.bravo.com.vn:21432/B10_PGE_HCM?sslmode=disable",
          },
        }),
      },
    })
  end,
}
