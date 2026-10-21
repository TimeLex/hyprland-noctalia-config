#!/usr/bin/env bash
# Works around two issues that only show up when running KDE apps/portals
# under Hyprland instead of a real Plasma session:
#
# 1. https://github.com/NixOS/nixpkgs/issues/182505 - xdg-desktop-portal-kde's
#    wrapper computes the QML import paths it needs into
#    NIXPKGS_QT6_QML_IMPORT_PATH but never merges them into the QML2_IMPORT_PATH
#    Qt actually reads, so its "Open With" (AppChooser) dialog fails to load.
#    We extract that value from the wrapper binary itself (so it stays correct
#    across nixos-rebuilds/store path changes) and push it into QML2_IMPORT_PATH.
#
# 2. KSycoca (the KDE app database) caches its result per XDG_DATA_DIRS+locale
#    combination and never notices when the Nix store paths behind those dirs
#    change (Nix always reports mtime 1), so a cache built before
#    XDG_MENU_PREFIX was set correctly can get stuck around forever with zero
#    applications in it. We just wipe the caches so everything rebuilds fresh.

set -euo pipefail

# hl.env() in variables.lua sets these for Hyprland's own process tree, but
# does not reliably reach systemd --user's default environment, which is what
# D-Bus/systemd-activated services (like the portal below) actually inherit.
# Set them here explicitly so the portal always sees them regardless.
systemctl --user set-environment QT_QPA_PLATFORMTHEME=kde XDG_MENU_PREFIX=plasma-

rm -f "$HOME"/.cache/ksycoca6_*
kbuildsycoca6 --noincremental >/dev/null 2>&1 || true

portal_bin="$(systemctl --user show plasma-xdg-desktop-portal-kde.service -p ExecStart --value 2>/dev/null | grep -oE 'path=[^ ;]+' | head -1 | cut -d= -f2-)"
if [ -n "$portal_bin" ]; then
  # The wrapper only embeds its makeWrapper invocation as text (one --prefix
  # line per path), it never assembles NAME=value as one string, so we have
  # to reconstruct the list from those individual --prefix lines.
  kde_qml_path="$(strings "$portal_bin" 2>/dev/null \
    | sed -n "s/.*--prefix 'NIXPKGS_QT6_QML_IMPORT_PATH' ':' '\([^']*\)'.*/\1/p" \
    | paste -sd: -)"
  if [ -n "$kde_qml_path" ]; then
    systemctl --user set-environment QML2_IMPORT_PATH="${kde_qml_path}:${QML2_IMPORT_PATH:-}"
  fi
fi

systemctl --user restart plasma-xdg-desktop-portal-kde.service >/dev/null 2>&1 || true
