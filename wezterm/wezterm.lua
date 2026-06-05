local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- ── Core ──────────────────────────────────────────────────────────────────────
config.font = wezterm.font("Iosevka Nerd Font")
config.font_size = 15
config.color_scheme = "Gruvbox dark, hard (base16)"
config.window_background_opacity = 0.92
config.macos_window_background_blur = 12

-- ── Tab bar ───────────────────────────────────────────────────────────────────
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 36
config.show_new_tab_button_in_tab_bar = true

-- Gruvbox Dark Hard palette — mirrors tmux theme
local TAB_BG = "#1d2021" -- hard charcoal base
local ACTIVE_BG = "#504945" -- medium wood (active tab)
local ACTIVE_FG = "#ebdbb2" -- cream
local INACTIVE_BG = "#3c3836" -- dark wood (inactive tab)
local INACTIVE_FG = "#928374" -- muted gray
local HOVER_BG = "#665c54" -- lighter wood hover
local ORANGE = "#fe8019" -- warm accent
local NEW_BTN_FG = "#fe8019"

config.colors = {
	tab_bar = {
		background = TAB_BG,
		new_tab = { bg_color = TAB_BG, fg_color = NEW_BTN_FG },
		new_tab_hover = { bg_color = HOVER_BG, fg_color = NEW_BTN_FG },
		active_tab = { bg_color = ACTIVE_BG, fg_color = ACTIVE_FG, intensity = "Bold" },
		inactive_tab = { bg_color = INACTIVE_BG, fg_color = INACTIVE_FG },
		inactive_tab_hover = { bg_color = HOVER_BG, fg_color = ACTIVE_FG },
	},
}

-- Rounded powerline caps (Nerd Fonts e0b4 / e0b6)
local CAP_R = utf8.char(0xe0b4) -- right-pointing  — opens tab on the left
local CAP_L = utf8.char(0xe0b6) -- left-pointing   — closes tab on the right

-- Icon map: process name → nerd font glyph
local ICONS = {
	nvim = "  ",
	vim = "  ",
	zsh = "  ",
	bash = "  ",
	fish = "  ",
	python = "  ",
	python3 = "  ",
	node = "  ",
	lua = "  ",
	git = "  ",
	ssh = "  ",
	htop = "  ",
	btop = "  ",
	lazygit = "  ",
	cargo = "  ",
	go = "  ",
	docker = "  ",
}

local function tab_icon(tab)
	local proc = tab.active_pane.foreground_process_name or ""
	proc = proc:match("([^/\\]+)$") or proc
	return ICONS[proc] or "  "
end

local function tab_title(tab)
	local title = tab.tab_title
	if title and #title > 0 then
		return title
	end
	local pane = tab.active_pane
	local proc = pane.foreground_process_name or ""
	proc = proc:match("([^/\\]+)$") or "zsh"
	local cwd = pane.current_working_dir and pane.current_working_dir.file_path or ""
	cwd = cwd:gsub(os.getenv("HOME") or "", "~")
	local parts = {}
	for p in cwd:gmatch("[^/]+") do
		table.insert(parts, p)
	end
	local short_cwd = #parts >= 2 and parts[#parts - 1] .. "/" .. parts[#parts] or (parts[#parts] or "~")
	return proc .. "  " .. short_cwd
end

wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
	local is_active = tab.is_active
	local bg = is_active and ACTIVE_BG or (hover and HOVER_BG or INACTIVE_BG)
	local fg = is_active and ACTIVE_FG or (hover and ACTIVE_FG or INACTIVE_FG)

	local icon = tab_icon(tab)
	local title = tab_title(tab)
	-- Active tab: index in orange; inactive: index in normal fg
	local idx_fg = is_active and ORANGE or INACTIVE_FG
	local idx = tostring(tab.tab_index + 1)

	local label = icon .. title
	local max = max_width - 6
	if #label > max then
		label = label:sub(1, max - 1) .. "…"
	end

	return {
		{ Background = { Color = TAB_BG } },
		{ Foreground = { Color = bg } },
		{ Text = CAP_L },
		{ Background = { Color = bg } },
		{ Foreground = { Color = idx_fg } },
		{ Attribute = { Intensity = is_active and "Bold" or "Normal" } },
		{ Text = " " .. idx .. " " },
		{ Foreground = { Color = fg } },
		{ Text = label .. " " },
		{ Background = { Color = TAB_BG } },
		{ Foreground = { Color = bg } },
		{ Text = CAP_R },
	}
end)

-- ── Key maps (uncomment to use) ───────────────────────────────────────────────
-- config.leader = { key = "Space", mods = "CTRL" }
-- config.keys = {
--   { key = "\\", mods = "LEADER", action = wezterm.action.SplitPane({ direction = "Right" }) },
--   { key = "-",  mods = "LEADER", action = wezterm.action.SplitPane({ direction = "Down" }) },
--   { key = "h",  mods = "CTRL",   action = wezterm.action.ActivatePaneDirection("Left") },
--   { key = "l",  mods = "CTRL",   action = wezterm.action.ActivatePaneDirection("Right") },
--   { key = "k",  mods = "CTRL",   action = wezterm.action.ActivatePaneDirection("Up") },
--   { key = "j",  mods = "CTRL",   action = wezterm.action.ActivatePaneDirection("Down") },
--   { key = "x",  mods = "CTRL",   action = wezterm.action.CloseCurrentPane({ confirm = true }) },
-- }

return config
