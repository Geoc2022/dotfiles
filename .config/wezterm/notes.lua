-- Use wezterm --config-file ~/.config/wezterm/notes.lua to load a notes file

local wezterm = require("wezterm")
local mux = wezterm.mux

local main_config = dofile(os.getenv("HOME") .. "/.config/wezterm/wezterm.lua")
local config = main_config

local notes_dir = os.getenv("NOTES_DIRECTORY") or (os.getenv("HOME") .. "/Documents/notes")

config.initial_cols = 42
config.initial_rows = 18

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window({
		cwd = notes_dir,
		args = { "zsh", "-il", "-c", "nvim" },
	})

	local gui_window = window:gui_window()

	gui_window:perform_action(wezterm.action.ToggleAlwaysOnTop, pane)

	-- pane:send_text("nvim\n")
end)

config.set_environment_variables = {
	PATH = os.getenv("PATH"),
}

return config
