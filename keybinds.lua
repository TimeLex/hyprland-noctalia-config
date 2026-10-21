-- ====== General ======
--
hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"), {
  description = "Toggle Control Center"
})
hl.bind("SUPER + V", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"), {
  description = "Toggle Clipboard"
})

hl.bind("SUPER + L", hl.dsp.exec_cmd("noctalia msg session lock"), {
  description = "Lock Session"
})

hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("noctalia msg panel-toggle session"), {
  description = "Manage Session"
})

-- Single Key Shortcuts

hl.bind("KP_UP", SwapMonitors, {
  description = "Swap Monitors (slect by tapping CTRL on both monitors)"
})

hl.bind("Control_L", SelectMonitorForSwap, {
  non_consuming = true,
})

hl.bind("KP_Delete", hl.dsp.exec_cmd("xdg-open https://search.nixos.org/packages?channel=unstable"), {
  repeating = true,
  description = "Open NixOS Search"
})
hl.bind("KP_Insert", hl.dsp.exec_cmd("code --new-window ~/nixos-config ~/nixos-config/home/timelex.nix"), {
  repeating = true,
  description = "Open NixOS Config"
})
hl.bind("KP_Prior", function()
  local activeMonitor = hl.get_active_monitor().name
  for _, monitor in ipairs(hl.get_monitors()) do
    hl.dispatch(hl.dsp.focus({
      monitor = monitor.name
    }))
    hl.dispatch(hl.dsp.focus({
      workspace = "emptyn"
    }))
  end
  hl.dispatch(hl.dsp.focus({
    monitor = activeMonitor
  }))
end, {
  description = "Workspace: Focus next empty on all monitors"
})
-- code:81 = Numpad 9 (Shift turns KP_Prior into KP_9, so bind the keycode)
hl.bind("SHIFT + code:81", function()
  local id = hl.get_active_workspace().id
  ShiftWorkspaceRight(id)
  hl.dispatch(hl.dsp.focus({
    workspace = id
  }))
end, {
  description = "Workspace: Shift right (pushing occupied ones along)"
})

local brightnessToggleShortcuts = {}

if HOST_NAME == "Desktop-Tim" then
  table.insert(brightnessToggleShortcuts, "KP_Home")

  hl.bind("KP_Left", hl.dsp.exec_cmd("playerctl previous"), {
    description = "Media: Previous"
  })
  hl.bind("KP_Begin", hl.dsp.exec_cmd("playerctl play-pause"), {
    description = "Media: Play/Pause"
  })
  hl.bind("KP_Right", hl.dsp.exec_cmd("playerctl next"), {
    description = "Media: Next"
  })
end

if HOST_NAME == "Laptop-Tim" then
  table.insert(brightnessToggleShortcuts, "SUPER + SHIFT + code:201")
end

for _, shortcut in ipairs(brightnessToggleShortcuts) do
  hl.bind(shortcut, hl.dsp.exec_cmd("noctalia msg theme-mode-toggle"), {
    description = "Toggle Brightness"
  })
end

-- ====== Workspace / Window Control ======
hl.bind("SUPER + Q", hl.dsp.window.close(), {
  description = "Window: Close"
})

hl.bind("SUPER + Space", hl.dsp.window.float({
  action = "toggle"
}), {
  description = "Window: Float/Tile"
})

-- Focus Adjacent Window
for i = 1, 4 do
  local arrowkey = { "Left", "Right", "Up", "Down" }
  local focusdir = { "l", "r", "u", "d" }
  hl.bind("SUPER + SHIFT + " .. arrowkey[i], hl.dsp.window.move({
    direction = focusdir[i]
  }), {
    description = "Window: Move " .. arrowkey[i]
  })
end

-- Move Active Window
for i = 1, 4 do
  local arrowkey = { "Left", "Right", "Up", "Down" }
  local focusdir = { "l", "r", "u", "d" }
  hl.bind("SUPER + " .. arrowkey[i], hl.dsp.focus({
    direction = focusdir[i]
  }), {
    description = "Window: Focus " .. arrowkey[i]
  })
end

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), {
  mouse = true,
  description = "Window: Move"
})
hl.bind("SUPER + mouse:274", hl.dsp.window.drag(), {
  mouse = true
})
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), {
  mouse = true,
  description = "Window: Resize"
})

hl.bind("SUPER + D", hl.dsp.window.fullscreen({
  mode = "maximized",
  action = "toggle"
}), {
  description = "Window: Maximize"
})
hl.bind("SUPER + F", hl.dsp.window.fullscreen({
  mode = "fullscreen",
  action = "toggle"
}), {
  description = "Window: Fullscreen"
})

hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("special"), {
  description = "Workspace: Toggle scratchpad"
})

-- Move To Adjacent Workspace
for i = 1, 2 do
  local keys = { "Left", "Right" }
  local prefix = { "r-", "r+" }
  local descdir = { "left", "right" }
  hl.bind("CTRL + SUPER + " .. keys[i], hl.dsp.focus({
    workspace = prefix[i] .. "1"
  }), {
    description = "Workspace: Focus " .. descdir[i]
  })
  hl.bind("CTRL + SHIFT + SUPER + " .. keys[i], hl.dsp.window.move({
    workspace = prefix[i] .. "1",
    follow = true
  }), {
    description = "Window: Move to workspace " .. descdir[i]
  })
end

local numberCodes = { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }
for i = 1, 10 do
  hl.bind("SUPER + SHIFT + " .. (i % 10), function()
    hl.dispatch(hl.dsp.window.move({
      workspace = Workspace_in_group(i),
      follow = true
    }))
  end)
  hl.bind("SUPER + CTRL + " .. (i % 10), function()
    hl.dispatch(hl.dsp.window.move({
      workspace = Workspace_in_group(i),
      follow = false
    }))
  end)
end
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({
  workspace = "special:special",
  follow = true
}), {
  description = "Window: Send to scratchpad"
})
hl.bind("SUPER + CTRL + S", hl.dsp.window.move({
  workspace = "special:special",
  follow = false
}), {
  description = "Window: Send to scratchpad"
})

for i = 1, 10 do
  hl.bind("SUPER + " .. (i % 10), function()
    hl.dispatch(hl.dsp.focus({
      workspace = Workspace_in_group(i)
    }))
  end, {
    description = "Workspace: Focus " .. i
  })
end

for i = 1, 10 do
  hl.bind("SUPER + ALT + " .. (i % 10), function()
    SwapWorkspaces(hl.get_active_workspace().id, Workspace_in_group(i))
  end, {
    description = "Workspace: Swap with " .. i
  })
end

-- ====== Apps ======

hl.bind("SUPER + B", hl.dsp.exec_cmd(browser), {
  description = "App: Browser"
})
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager), {
  description = "App: File Manager"
})
hl.bind("SUPER + C", hl.dsp.exec_cmd(codeEditor), {
  description = "App: Code Editor"
})
hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal), {
  description = "App: Terminal"
})
hl.bind("SUPER + O", hl.dsp.exec_cmd("obsidian"), {
  description = "App: Obsidian"
})
hl.bind("SUPER + T", ExecOrFocus("class:^(vesktop)$", "vesktop"), {
  description = "App: Vesktop"
})
hl.bind("SUPER + Escape", hl.dsp.exec_cmd("plasma-systemmonitor"), {
  description = "App: System Monitor"
})

-- ====== Zoom ======

hl.bind("SUPER + Plus", ZoomIn, {
  repeating = true,
  description = "Screen: Zoom in"
})
hl.bind("SUPER + Minus", ZoomOut, {
  repeating = true,
  description = "Screen: Zoom out"
})
hl.bind("SUPER + Escape", function()
  hl.config({
    cursor = {
      zoom_factor = 1.0
    }
  })
end, {
  description = "Screen: Reset zoom"
})

-- ====== Special Keys ======

hl.bind("Print", hl.dsp.exec_cmd("noctalia msg screenshot-annotate"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("noctalia msg screenshot-region"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("noctalia msg screenshot-fullscreen"))

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("noctalia msg brightness-up || brightnessctl s 5%+"), {
  locked = true,
  repeating = true
})
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("noctalia msg brightness-down || brightnessctl s 5%-"), {
  locked = true,
  repeating = true
})
hl.bind("XF86AudioRaiseVolume",
  hl.dsp.exec_cmd("noctalia msg volume-up || wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.5"), {
    locked = true,
    repeating = true
  })
hl.bind("XF86AudioLowerVolume",
  hl.dsp.exec_cmd("noctalia msg volume-down || wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), {
    locked = true,
    repeating = true
  })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), {
  locked = true
})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), {
  locked = true
})
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), {
  locked = true
})
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), {
  locked = true
})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle"), {
  locked = true
})
