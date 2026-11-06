-- Wallpaper-driven colourscheme (opt-in: `:colorscheme matugen`).
-- matugen writes the base16 palette to ~/.local/state/theme/nvim.lua; the
-- file is absent on machines without the theme pipeline, so fall back.
local path = (vim.env.XDG_STATE_HOME or (vim.env.HOME .. "/.local/state")) .. "/theme/nvim.lua"
local ok, palette = pcall(dofile, path)
if not ok then
  vim.notify("matugen: no palette at " .. path, vim.log.levels.WARN)
  return
end

vim.cmd("highlight clear")
require("mini.base16").setup({ palette = palette, use_cterm = true })
vim.g.colors_name = "matugen"

-- `wallpaper set` sends SIGUSR1: re-read the palette while active.
if not vim.g.matugen_signal then
  vim.g.matugen_signal = true
  vim.api.nvim_create_autocmd("Signal", {
    pattern = "SIGUSR1",
    callback = function()
      if vim.g.colors_name == "matugen" then vim.cmd.colorscheme("matugen") end
    end,
  })
end
