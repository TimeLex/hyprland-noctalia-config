-- HOST
--
local function get_hostname()
  local f = io.open("/proc/sys/kernel/hostname", "r")
  if f == nil then
    return nil
  end
  local name = f:read("l")
  f:close()
  return name
end

HOST_NAME = get_hostname()

-- Monitor Swap

-- The two most recently focused (distinct) monitors, newest first.
local lastMonitors = {}

---@param name string|nil
local function rememberFocusedMonitor(name)
  if name == nil or name == lastMonitors[1] then
    return
  end
  lastMonitors[2] = lastMonitors[1]
  lastMonitors[1] = name
end

local initialMonitor = hl.get_active_monitor()
rememberFocusedMonitor(initialMonitor and initialMonitor.name)

-- With exactly two monitors there is nothing to choose, so the other one is
-- known right away (e.g. after a config reload, before any focus change).
if lastMonitors[2] == nil then
  local monitors = hl.get_monitors()
  if #monitors == 2 then
    for _, monitor in ipairs(monitors) do
      if monitor.name ~= lastMonitors[1] then
        lastMonitors[2] = monitor.name
      end
    end
  end
end

-- The event fires before Hyprland updates the active monitor, so
-- hl.get_active_monitor() would still return the previous one here. Use the
-- newly focused monitor passed to the callback instead.
-- HL.Monitor is a userdata object, not a table, so read .name directly
-- (guarded, in case the event ever passes something without that field).
hl.on("monitor.focused", function(monitor)
  if type(monitor) == "string" then
    rememberFocusedMonitor(monitor)
    return
  end
  local ok, name = pcall(function()
    return monitor.name
  end)
  if ok and type(name) == "string" then
    rememberFocusedMonitor(name)
  end
end)

function SwapMonitors()
  local monitor1, monitor2 = lastMonitors[1], lastMonitors[2]

  if monitor1 == nil or monitor2 == nil then
    hl.exec_cmd('notify-send "Monitor Swap" "Focus two different monitors first."')
    return
  end

  hl.dispatch(hl.dsp.workspace.swap_monitors({
    monitor1 = monitor1,
    monitor2 = monitor2,
  }))
end

-- ZOOM

function ZoomByFactor(factor)
  local current = hl.get_config("cursor:zoom_factor")
  hl.config({
    cursor = {
      zoom_factor = math.max(1.0, math.min(10.0, current * factor))
    }
  })
end

function ZoomIn()
  ZoomByFactor(1.4)
end

function ZoomOut()
  ZoomByFactor(1 / 1.4)
end

-- APPS

function ExecOrFocus(windowSelector, execCommand)
  return function()
    if hl.get_window(windowSelector) then
      hl.dispatch(hl.dsp.focus({
        window = windowSelector
      }))
    else
      hl.dispatch(hl.dsp.exec_cmd(execCommand))
    end
  end
end

-- WORKSPACE

local workspaceGroupSize = 10
function Workspace_in_group(i)
  local curr = hl.get_active_workspace().id
  return math.floor((curr - 1) / workspaceGroupSize) * workspaceGroupSize + i
end

-- Hyprland has no dispatcher that swaps two workspaces directly, so this
-- swaps their numbered IDs instead (via an unused temporary ID, since an ID
-- can't be assigned while another workspace already holds it). Windows are
-- never touched, so each workspace's layout tree stays exactly as it was.
local SWAP_TEMP_ID = 2000000000

---@param first integer
---@param second integer
function SwapWorkspaces(first, second)
  if first == second then
    return
  end

  hl.dispatch(hl.dsp.workspace.change_id({
    workspace = first,
    id = SWAP_TEMP_ID
  }))
  hl.dispatch(hl.dsp.workspace.change_id({
    workspace = second,
    id = first
  }))
  hl.dispatch(hl.dsp.workspace.change_id({
    workspace = SWAP_TEMP_ID,
    id = second
  }))
end

-- Puts every monitor on an empty workspace behind all occupied ones. A
-- monitor that already shows such a workspace keeps it. The IDs are computed
-- up front instead of using "emptyn", which is resolved per dispatch and
-- could hand two monitors the same workspace or skip past an empty one.
function FocusEmptyWorkspaceOnAllMonitors()
  local lastUsed = 0
  local taken = {}
  for _, workspace in ipairs(hl.get_workspaces()) do
    if workspace.id > 0 then
      taken[workspace.id] = true
      if workspace.windows > 0 then
        lastUsed = math.max(lastUsed, workspace.id)
      end
    end
  end

  local targets = {}
  for _, monitor in ipairs(hl.get_monitors()) do
    local active = monitor.active_workspace
    if active == nil or active.windows > 0 or active.id <= lastUsed then
      table.insert(targets, monitor.name)
    end
  end

  local activeMonitor = hl.get_active_monitor().name
  local free = lastUsed
  for _, monitorName in ipairs(targets) do
    repeat
      free = free + 1
    until not taken[free]
    taken[free] = true

    hl.dispatch(hl.dsp.focus({
      monitor = monitorName
    }))
    hl.dispatch(hl.dsp.focus({
      workspace = free
    }))
  end
  hl.dispatch(hl.dsp.focus({
    monitor = activeMonitor
  }))
end

-- Shifts the given workspace one ID to the right. If that ID is taken, the
-- workspace there is shifted as well (recursively), so the IDs are renamed
-- from the first free one backwards.
---@param id integer
function ShiftWorkspaceRight(id)
  local free = id + 1
  while hl.get_workspace(free) ~= nil do
    free = free + 1
  end

  for j = free - 1, id, -1 do
    hl.dispatch(hl.dsp.workspace.change_id({
      workspace = j,
      id = j + 1
    }))
  end
end
