-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Obsidian vault, reachable via the ~/OneDrive symlink or its real path.
local obsidian_roots = {
  vim.fn.expand("~") .. "/OneDrive/mh_obsidian/",
  vim.fn.expand("~") .. "/Library/CloudStorage/OneDrive-Personal/mh_obsidian/",
}

---@param file string absolute buffer path
---@return boolean true when the buffer lives inside the Obsidian vault
local function in_obsidian(file)
  if file == "" then
    return false
  end
  for _, root in ipairs(obsidian_roots) do
    if vim.startswith(file, root) then
      return true
    end
  end
  return false
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true -- break at word boundaries
  end,
})

-- Prose formatting for norg + markdown.
-- fo flags:
--   t = auto-wrap while typing (HARD wrap)
--   q = allow gq/gw to reflow paragraphs
--   n = recognise numbered lists so gq doesn't break them
-- 'a' (auto-reflow on edit) is intentionally omitted — it destroys code blocks.
--
-- Obsidian notes get SOFT wrap only. We set textwidth=0 rather than trying to
-- keep `t` out of formatoptions: `t` is re-added by plugins reloading on the
-- markdown filetype (render-markdown via LazyVim's `do FileType`), which makes
-- any "remove t" race against autoload order. textwidth=0 is deterministic —
-- with no width, hard wrap can never fire regardless of what's in formatoptions.
-- Soft display wrap still works via `wrap`+`linebreak`. To reflow a paragraph
-- at a fixed width: `:set tw=80 | gwip | set tw=0`.
local function apply_obsidian(bufnr)
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.diagnostic.enable(false, { bufnr = bufnr })
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true -- break at word boundaries
  vim.opt_local.textwidth = 0 -- never hard-wrap, immune to `t` being re-added
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "norg", "markdown" },
  callback = function()
    if in_obsidian(vim.api.nvim_buf_get_name(0)) then
      -- Defer until after any plugins that also react to this FileType event
      -- (e.g. render-markdown's `do FileType` reload) have run.
      vim.schedule(function()
        apply_obsidian(0)
      end)
    else
      vim.opt_local.textwidth = 80
      vim.opt_local.formatoptions:append("tqn")
      vim.opt_local.formatoptions:remove("l") -- don't skip already-long lines
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true
    end
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(ev)
    if in_obsidian(vim.api.nvim_buf_get_name(ev.buf)) then
      apply_obsidian(ev.buf)
    end
  end,
})

-- The buffer given to `nvim <vault-note>.md` is entered while this file is
-- still loading (it runs on the VeryLazy event), so the BufEnter autocmd above
-- has not been registered yet for it and never fires. Apply the settings to the
-- current buffer once it is settled; then defer a retry so it lands after any
-- plugin reload. Once textwidth=0 is set it cannot be re-triggered anyway, and
-- later buffers are covered by the BufEnter autocmd.
local function apply_current()
  if in_obsidian(vim.api.nvim_buf_get_name(0)) then
    apply_obsidian(0)
  end
end
vim.defer_fn(apply_current, 0)
vim.defer_fn(apply_current, 500)

vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "none" })
