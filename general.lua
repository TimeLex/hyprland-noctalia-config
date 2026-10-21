hl.config({
  gestures = {
    workspace_swipe_distance = 700,
    workspace_swipe_cancel_ratio = 0.2,
    workspace_swipe_min_speed_to_force = 5,
    workspace_swipe_direction_lock = true,
    workspace_swipe_direction_lock_threshold = 10,
    workspace_swipe_create_new = true,
  },
  general = {
    -- Gaps and border
    gaps_in = 4,
    gaps_out = 5,
    gaps_workspaces = 50,

    resize_on_border = true
  },
  decoration = {
    -- 2 = circle, higher = squircle, 4 = very obvious squircle
    -- Fuck clearly visible squircles. 100% Apple brainrot.
    rounding_power = 2.5,
    rounding = 10,

    shadow = {
      enabled = false,
      range = 4,
      offset = { 0, 2 },
      render_power = 4,
      scale = 1.0
    },
    -- Dim
    dim_inactive = true,
    dim_strength = 0.05,
    dim_special = 0.2
  },
  animations = {
    enabled = true
  },
  cursor = {
    no_hardware_cursors = true,
  },
  input = {
    kb_layout = "de",
    kb_variant = "nodeadkeys",
    repeat_delay = 220,
    repeat_rate = 45,

    sensitivity = HOST_NAME == "Desktop-Tim" and -0.48 or 0.0,

    touchpad = {
      natural_scroll = true,
      scroll_factor = 0.75
    }
  },
  dwindle = {
    preserve_split = true
  },
  misc = {
    focus_on_activate = true
  }
})

hl.window_rule({
  -- Ignore maximize requests from all apps
  name = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize"
})

hl.window_rule({
  name = "float KCalc",
  match = { class = "^org.kde.kcalc$" },
  float = true,
})

-- Float dev builds (e.g. `tauri dev`): binaries running from a cargo target/debug dir
hl.on("window.open", function(window)
  if window.floating then
    return
  end

  local exe = io.popen("readlink /proc/" .. window.pid .. "/exe")
  if not exe then
    return
  end
  local path = exe:read("l") or ""
  exe:close()

  if path:find("/target/debug/", 1, true) then
    hl.dispatch(hl.dsp.window.float({
      action = "enable",
      window = window
    }))
  end
end)

hl.gesture({
  fingers = 3,
  direction = "up",
  action = ZoomIn
})
hl.gesture({
  fingers = 3,
  direction = "down",
  action = ZoomOut
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace"
})
