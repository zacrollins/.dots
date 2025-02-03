-- pull in the wezterm API
local wezterm = require("wezterm")

-- this will hold the configuration
local config = wezterm.config_builder()

config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 18

config.color_scheme = "Catppuccin Mocha"

config.window_background_opacity = 0.9
config.macos_window_background_blur = 10

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

-- return config
return config
