hl.on("hyprland.start", function()
  -- see scripts/fix-kde-portal.sh for why this is needed
  hl.exec_cmd("bash ~/.config/hypr/scripts/fix-kde-portal.sh")

  -- unlock kwallet so Apps depending on Secret Service (ex. Noctalia clipboard history) work
  hl.exec_cmd("/run/current-system/sw/libexec/pam_kwallet_init")

  hl.exec_cmd(onscreen_keyboard)

  -- LC_NUMERIC=en_US.UTF makes that "." is interpreted as a comma for calculations
  hl.exec_cmd("env LC_NUMERIC=en_US.UTF-8 noctalia")
end)
