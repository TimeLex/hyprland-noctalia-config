-- Makes Qt/KDE apps (Dolphin, kcalc, ...) follow kdeglobals for
-- color scheme + use native KDE file/open-with dialogs under Hyprland
hl.env("QT_QPA_PLATFORMTHEME", "kde")

-- Plasma sets this in its session startup script; without it, KService/KSycoca
-- looks for a plain "applications.menu" that doesn't exist on this system
-- (only "plasma-applications.menu" does), so KOpenWithDialog etc. list no apps
hl.env("XDG_MENU_PREFIX", "plasma-")

-- for monitor swapping
hl.env("SWAP_MONITOR_1", "DP-1")
hl.env("SWAP_MONITOR_2", "DP-2")

browser = "firefox"
codeEditor = "code"
fileManager = "dolphin"
terminal = "kitty"

onscreen_keyboard = 'wvkbd-mobintl -L 200 --fn "DejaVu Sans 20" --hidden'
