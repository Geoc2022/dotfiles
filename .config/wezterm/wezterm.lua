-- Pull in WezTerm API
local wezterm = require("wezterm")

-- Returns color scheme dependent on operating system theme setting (dark/light)
local function color_scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Sonokai (Gogh)"
	else
		return "Ayu Light (Gogh)"
	end
end

-- Build tab bar colors from theme
local function tab_bar_from_scheme(scheme_name)
	local schemes = wezterm.color.get_builtin_schemes()
	local scheme = schemes[scheme_name]
	if not scheme then
		wezterm.log_error("No scheme named " .. scheme_name)
		return {}
	end

	local bg = scheme.background
	local fg = scheme.foreground
	local darker_bg = wezterm.color.parse(bg):darken(0.1)
	local lighter_fg = wezterm.color.parse(fg):lighten(0.2)

	return {
		background = darker_bg,
		active_tab = {
			bg_color = bg,
			fg_color = lighter_fg,
			intensity = "Bold",
			underline = "None",
		},
		inactive_tab = {
			bg_color = darker_bg,
			fg_color = lighter_fg,
		},
		inactive_tab_hover = {
			bg_color = darker_bg,
			fg_color = lighter_fg,
			italic = true,
		},
		new_tab = {
			bg_color = darker_bg,
			fg_color = lighter_fg,
		},
		new_tab_hover = {
			bg_color = darker_bg,
			fg_color = lighter_fg,
		},
	}
end

-- Initialize actual config
local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- -- Start tmux when opening WezTerm
-- config.default_prog = { "/bin/zsh", "-l", "-c", "--", "tmux new -As base" }
-- -- Skip closing confirmation when tmux is running
-- config.skip_close_confirmation_for_processes_named = { "tmux" }

-- Appearance
config.font_size = 16.0
config.color_scheme = color_scheme_for_appearance(wezterm.gui.get_appearance())
config.colors = {
	tab_bar = tab_bar_from_scheme(config.color_scheme),
	cursor_bg = "#e2e2e3",
	cursor_fg = "#e2e2e3",
}
config.window_decorations = "RESIZE"
config.scrollback_lines = 5000
config.hide_tab_bar_if_only_one_tab = true
config.native_macos_fullscreen_mode = false
config.use_fancy_tab_bar = false
config.max_fps = 240 -- Above 120 but works better for smooth scrolling
config.font = wezterm.font("JetBrains Mono", { weight = "Medium" })
config.window_padding = {
	left = "0.5cell",
	bottom = "0.4cell",
}
config.warn_about_missing_glyphs = false

-- Keybindings:

-- smart-splits.nvim
-- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end
local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}
local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "META" or "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

config.keys = {
	{
		key = "A",
		mods = "CTRL|SHIFT",
		action = wezterm.action.QuickSelect,
	},
	-- Use the same keybind as in iTerm2 to create splits
	{ key = "d", mods = "SHIFT|CMD", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "CMD", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	-- { key = "DownArrow", mods = "SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },
	-- { key = "UpArrow", mods = "SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
	-- { key = "LeftArrow", mods = "SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
	-- { key = "RightArrow", mods = "SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },

	-- Smart-splits.nvim
	-- move between split panes
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),
	-- resize panes
	split_nav("resize", "h"),
	split_nav("resize", "j"),
	split_nav("resize", "k"),
	split_nav("resize", "l"),

	-- Clear Terminal
	{ key = "l", mods = "CMD", action = wezterm.action.ClearScrollback("ScrollbackAndViewport") },

	-- Toggle to top
	{
		key = "t",
		mods = "CMD|SHIFT",
		action = wezterm.action.ToggleAlwaysOnTop,
	},
}

-- Add toggle for light/dark theme
local function toggle_color_scheme(window, pane)
	local overrides = window:get_config_overrides() or {}
	if overrides.color_scheme == "Sonokai (Gogh)" or overrides.color_scheme == nil then
		overrides.color_scheme = "Ayu Light (Gogh)"
		overrides.colors = { tab_bar = tab_bar_from_scheme("Ayu Light (Gogh)") }
	else
		overrides.color_scheme = "Sonokai (Gogh)"
		overrides.colors = { tab_bar = tab_bar_from_scheme("Sonokai (Gogh)") }
	end
	window:set_config_overrides(overrides)
end
-- Add to CommandPalette
wezterm.on("augment-command-palette", function(window, pane)
	return {
		{
			brief = "Toggle Color Scheme",
			icon = "fa_adjust",
			action = wezterm.action_callback(toggle_color_scheme),
		},
	}
end)

wezterm.on("trigger-nvim-colorscheme", function(window, pane, scheme)
	pane:send_text(string.format(":colorscheme %s\n", scheme))
end)

-- Return config to WezTerm
return config
