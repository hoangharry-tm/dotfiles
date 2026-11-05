local wezterm = require("wezterm")

local config = {
	font = wezterm.font("JetBrainsMono Nerd Font"),
	font_size = 13,
	line_height = 1.2,
}

-- Gruvbox Dark palette
local g = {
	bg0 = "#1d2021",
	bg1 = "#282828",
	bg2 = "#32302f",
	bg3 = "#3c3836",
	fg = "#ebdbb2",
	red = "#cc241d",
	green = "#98971a",
	yellow = "#d79921",
	blue = "#458588",
	purple = "#b16286",
	aqua = "#689d6a",
	orange = "#d65d0e",
	gray = "#928374",
}

config.colors = {
	foreground = g.fg,
	background = g.bg0,
	cursor_bg = g.fg,
	cursor_fg = g.bg0,
	selection_bg = g.bg3,
	selection_fg = g.fg,
	ansi = {
		g.bg3, -- black
		g.red, -- red
		g.green, -- green
		g.yellow, -- yellow
		g.blue, -- blue
		g.purple, -- magenta
		g.aqua, -- cyan
		g.fg, -- white
	},
	brights = {
		g.gray, -- bright black
		g.red, -- bright red
		g.green, -- bright green
		g.yellow, -- bright yellow
		g.blue, -- bright blue
		g.purple, -- bright magenta
		g.aqua, -- bright cyan
		"#ffffff", -- bright white
	},
	tab_bar = {
		background = g.bg0,
		active_tab = {
			bg_color = g.blue,
			fg_color = g.bg0,
		},
		inactive_tab = {
			bg_color = g.bg2,
			fg_color = g.gray,
		},
		inactive_tab_hover = {
			bg_color = g.bg3,
			fg_color = g.fg,
		},
	},
}

-- No window title bar (traffic lights integrated into tab bar)
config.window_decorations = "RESIZE"

-- Tab bar: Hyprland-style numbered pills
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.show_tab_index_in_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

wezterm.on("format-tab-title", function(tab, hover)
	local label = tostring((tab.tab_index + 1) % 10)

	if tab.is_active then
		return {
			{ Background = { Color = g.blue } },
			{ Foreground = { Color = g.bg0 } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = " " .. label .. " " },
		}
	elseif hover then
		return {
			{ Background = { Color = g.bg3 } },
			{ Foreground = { Color = g.fg } },
			{ Text = " " .. label .. " " },
		}
	else
		return {
			{ Background = { Color = g.bg2 } },
			{ Foreground = { Color = g.gray } },
			{ Text = " " .. label .. " " },
		}
	end
end)

wezterm.on("update-status", function(window, pane)
	window:set_right_status("")

	local ok_t, tabs = pcall(function()
		return window:mux_window():tabs_with_info()
	end)
	if not ok_t then
		return
	end

	local n = #tabs
	if n <= 1 then
		window:set_left_status("")
		return
	end

	local ok_d, d = pcall(function()
		return pane:get_dimensions()
	end)
	if not ok_d or not d or not d.cols then
		return
	end

	local pad = math.max(0, math.floor((d.cols - n * 2.5) / 2))
	window:set_left_status(string.rep(" ", pad))
end)
config.window_background_opacity = 0.80
config.macos_window_background_blur = 0

config.window_padding = {
	left = 8,
	right = 8,
	top = 4,
	bottom = 4,
}

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{ key = "t", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "LEADER", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
	{ key = "[", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "]", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "1", mods = "LEADER", action = wezterm.action.ActivateTab(0) },
	{ key = "2", mods = "LEADER", action = wezterm.action.ActivateTab(1) },
	{ key = "3", mods = "LEADER", action = wezterm.action.ActivateTab(2) },
	{ key = "4", mods = "LEADER", action = wezterm.action.ActivateTab(3) },
	{ key = "5", mods = "LEADER", action = wezterm.action.ActivateTab(4) },
	{ key = "6", mods = "LEADER", action = wezterm.action.ActivateTab(5) },
	{ key = "7", mods = "LEADER", action = wezterm.action.ActivateTab(6) },
	{ key = "8", mods = "LEADER", action = wezterm.action.ActivateTab(7) },
	{ key = "9", mods = "LEADER", action = wezterm.action.ActivateTab(8) },
	{ key = "0", mods = "LEADER", action = wezterm.action.ActivateTab(9) },
	{ key = "-", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "=", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
}

return config
