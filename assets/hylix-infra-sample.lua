-- settings
hl.config({
  debug = {
    suppress_errors = true,
    watchdog_timeout = 0,
  },
  decoration = {
    active_opacity = 0.95,
    blur = {
      input_methods = true,
      passes = 2,
      popups = true,
      size = 16,
    },
    inactive_opacity = 0.95,
    rounding = 0,
  },
  dwindle = {
    preserve_split = true,
    special_scale_factor = 0.8,
  },
  ecosystem = {
    enforce_permissions = true,
    no_donation_nag = true,
    no_update_news = true,
  },
  general = {
    gaps_in = 4,
    gaps_out = 4,
    hover_icon_on_border = false,
  },
  input = {
    accel_profile = "flat",
    kb_options = "caps:swapescape",
    mouse_refocus = false,
    touchdevice = {
      enable = false,
    },
  },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    enable_swallow = true,
    force_default_wallpaper = 0,
    initial_workspace_tracking = 2,
    render_unfocused_fps = 1,
    swallow_regex = "^com\\.mitchellh\\.ghostty$",
    vrr = 1,
  },
  plugin = {
    hyprfocus = {
      keyboard_focus_animation = "shrink",
      mouse_focus_animation = "shrink",
      shrink_percentage = 0.995,
    },
  },
  xwayland = {
    force_zero_scaling = true,
  },
})

-- monitors
hl.monitor({
  mode = "1920x1080@144",
  output = "DP-1",
  position = "-1920x96",
  scale = 1,
  vrr = 0,
})
hl.monitor({
  mode = "1920x1080@60",
  output = "eDP-1",
  position = "0x0",
  scale = 1,
})

-- animations.curves
hl.curve("fadeGeneric", {
  points = {
    {
      0.0,
      0.0,
    },
    {
      0.2,
      1.0,
    },
  },
  type = "bezier",
})
hl.curve("springWindow", {
  dampening = 12,
  mass = 1,
  stiffness = 45,
  type = "spring",
})

-- animations.animations
hl.curve("hylix_windows_springWindow", {
  dampening = 30.0,
  mass = 1,
  stiffness = 281.25,
  type = "spring",
})
hl.animation({
  bezier = "fadeGeneric",
  enabled = true,
  leaf = "fade",
  speed = 3.03,
})
hl.animation({
  enabled = true,
  leaf = "windows",
  speed = 4,
  spring = "hylix_windows_springWindow",
  style = "popin",
})

-- rules.window
hl.window_rule({
  float = true,
  match = {
    class = "steam",
    title = "Friends List",
  },
  size = {
    380,
    540,
  },
})
hl.window_rule({
  center = true,
  float = true,
  match = {
    class = "me.iepure.devtoolbox",
  },
  size = {
    1130,
    750,
  },
})

-- rules.layer
hl.layer_rule({
  blur = true,
  blur_popups = true,
  ignore_alpha = 0.94,
  match = {
    namespace = "overzicht",
  },
})

-- permissions
hl.permission({
  binary = ".*/libhyprfocus\\.so$",
  mode = "allow",
  type = "plugin",
})
hl.permission({
  binary = "/nix/store/example-grim/bin/grim",
  mode = "allow",
  type = "screencopy",
})

-- gestures
hl.gesture({
  action = "workspace",
  direction = "horizontal",
  fingers = 3,
})
hl.gesture({
  action = "exec",
  direction = "pinchout",
  exec = "overzicht ipc call overview close",
  fingers = 3,
})

local MAX_ZOOM = 3
local MIN_ZOOM = 1

local function zoom_reset()
    hl.config({ cursor = { zoom_factor = MIN_ZOOM } })
end

-- binds
-- 1. Applications
hl.bind("SUPER + Return", hl.dsp.exec_cmd("runapp ghostty --initial-window=false +new-window"), {
  description = "Terminal",
})
-- 2. Window Management
hl.bind("SUPER + SHIFT + minus", zoom_reset, {
  description = "Reset zoom",
})
hl.bind("SUPER + V", hl.dsp.window.float({
  action = "toggle",
}), {
  description = "Toggle floating",
})
