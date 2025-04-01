return {
  {
    "sainnhe/sonokai",
    priority = 1000,
    config = function()
      vim.g.sonokai_transparent_background = "1"
      vim.g.sonokai_enable_italic = "1"
      vim.g.sonokai_style = "default"
    end,
  },
  {
    "nordtheme/vim",
  },
  {
    "NLKNguyen/papercolor-theme",
  },
  {
    "Mofiqul/vscode.nvim",
    config = function()
      require("vscode").setup({
        transparent = true,
        italic_comment = true,
        disable_nvimtree_bg = true,
      })
    end,
  },
}
