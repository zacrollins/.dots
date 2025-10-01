-- pull in the wezterm API
local wezterm = require("wezterm")

return {
    adjust_window_size_when_changing_font_size = false,
    color_scheme = "Catppuccin Mocha",
    enable_tab_bar = false,
    font_size = 18,
    font = wezterm.font("JetBrainsMono Nerd Font"),
    macos_window_background_blur = 10,
    window_background_opacity = 0.9,
    window_decorations = "RESIZE",

    -- keybinds
    -- keys = {
    --     {
    --         key = "Enter",
    --         mods = "CMD",
    --         action = wezterm.action({ EmitEvent = "toggle-fullscreen" }),
    --     }
    -- }
}
