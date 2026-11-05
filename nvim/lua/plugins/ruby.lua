-- ruby-lsp and rubocop are installed globally via rbenv (not through Mason),
-- so mason-lspconfig's `automatic_enable` never enables them. `mason = false`
-- makes LazyVim enable them directly.
--
-- Both use a cmd factory (vim.lsp.rpc.start) so that in a project with the gem
-- in its Gemfile they run via `bundle exec` — loading ruby-lsp-rails / the
-- project's rubocop-rails-omakase config.
local function gem_in_bundle(root, name)
  if not root then
    return false
  end
  local gemfile = root .. "/Gemfile"
  if vim.fn.filereadable(gemfile) == 1 then
    for _, line in ipairs(vim.fn.readfile(gemfile)) do
      local g = line:match('gem%s+"([%w%._-]+)"') or line:match("gem%s+'([%w%._-]+)'")
      if g == name then
        return true
      end
    end
  end
  -- Only prefer `bundle exec` once the bundle is actually resolved, so a
  -- Gemfile that mentions the gem but has no installed bundle falls back to
  -- the global binary instead of failing to start.
  local lock = root .. "/Gemfile.lock"
  if vim.fn.filereadable(lock) == 1 then
    for _, line in ipairs(vim.fn.readfile(lock)) do
      if line:match("^%s+" .. name .. "%s+%(") then
        return true
      end
    end
  end
  return false
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = {
          mason = false,
          cmd = function(dispatchers, config)
            local root = config.root_dir
            local argv = { "ruby-lsp" }
            if gem_in_bundle(root, "ruby-lsp") then
              argv = { "bundle", "exec", "ruby-lsp" }
            end
            return vim.lsp.rpc.start(argv, dispatchers, { cwd = config.cmd_cwd or root })
          end,
        },
        rubocop = {
          mason = false,
          cmd = function(dispatchers, config)
            local root = config.root_dir
            local argv = { "rubocop", "--lsp" }
            if gem_in_bundle(root, "rubocop") then
              argv = { "bundle", "exec", "rubocop", "--lsp" }
            end
            return vim.lsp.rpc.start(argv, dispatchers, { cwd = config.cmd_cwd or root })
          end,
        },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "zidhuss/neotest-minitest",
    },
    opts = {
      adapters = {
        -- Default rspec_cmd uses the system-wide rspec; force the project bundle.
        ["neotest-rspec"] = {
          rspec_cmd = function()
            return { "bundle", "exec", "rspec" }
          end,
        },
        -- neotest-minitest: use `bin/rails test` in Rails apps, plain bundler
        -- minitest otherwise. The string-key form defers require() until the
        -- neotest plugin loads, so this works before the dep is installed.
        ["neotest-minitest"] = {
          test_cmd = function()
            if vim.fn.filereadable("bin/rails") == 1 then
              return { "bin/rails", "test" }
            end
            return { "bundle", "exec", "ruby", "-Itest" }
          end,
        },
      },
    },
  },
}
