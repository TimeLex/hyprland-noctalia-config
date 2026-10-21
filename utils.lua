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

function SelectMonitorForSwap()
  local storedSwapMonitor1 = os.getenv("SWAP_MONITOR_1")
  local currentMonitor = hl.get_active_monitor().name

  if storedSwapMonitor1 == currentMonitor then
    return
  end

  hl.env("SWAP_MONITOR_2", storedSwapMonitor1)
  hl.env("SWAP_MONITOR_1", currentMonitor)
  -- hl.exec_cmd("notify-send " .. "SWAP_MONITOR_1 " .. os.getenv("SWAP_MONITOR_1"))
  -- hl.exec_cmd("notify-send " .. "SWAP_MONITOR_2 " .. os.getenv("SWAP_MONITOR_2"))
end

function SwapMonitors()
  local monitor1 = os.getenv("SWAP_MONITOR_1")
  local monitor2 = os.getenv("SWAP_MONITOR_2")

  if monitor1 == nil or monitor2 == nil then
    hl.exec_cmd('notify-send "No Monitor Selected" "Select two Monitors by pressing CTRL when they are focused."')
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
