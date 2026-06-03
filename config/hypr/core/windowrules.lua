hl.window_rule({
  name = "suppress-maximize",
  match = { class = ".*" },
  suppress_event = "maximize",
})

hl.window_rule({
  name = "float-thunar-progress",
  match = { class = "Thunar", title = "File Operation Progress" },
  float = true,
})

hl.window_rule({
  name = "float-zen-pip",
  match = { class = "zen", title = "Picture-in-Picture" },
  float = true,
})

hl.window_rule({
  name = "pin-zen-pip",
  match = { class = "zen", title = "Picture-in-Picture" },
  pin = true,
})

hl.window_rule({
  name = "size-zen-pip",
  match = { class = "zen", title = "Picture-in-Picture" },
  size = "960 549",
})

hl.window_rule({
  name = "move-zen-pip",
  match = { class = "zen", title = "Picture-in-Picture" },
  move = "1086 602",
})

hl.window_rule({
  name = "float-steam-friends",
  match = { class = "steam", title = "Friends List" },
  float = true,
})

hl.window_rule({
  name = "float-steam-news",
  match = { class = "steam", title = "Steam - News" },
  float = true,
})

hl.window_rule({
  name = "float-pavucontrol",
  match = { class = "Pavucontrol" },
  float = true,
})

hl.window_rule({
  name = "float-blueman",
  match = { class = "Blueman-manager" },
  float = true,
})

hl.window_rule({
  name = "float-blender-render",
  match = { class = "blender", title = "Blender Render" },
  float = true,
})

hl.window_rule({
  name = "size-gsr-ui",
  match = { class = "gsr-ui" },
  size = "2560 1440",
})

hl.window_rule({
  name = "move-gsr-ui",
  match = { class = "gsr-ui" },
  move = "0 0",
})

hl.window_rule({
  name = "fullscreen-gtaiv",
  match = { class = "gtaiv%.exe" },
  fullscreen = true,
})

hl.window_rule({
  name = "input-gtaiv",
  match = { class = "gtaiv%.exe" },
  allows_input = true,
  stay_focused = true,
})

hl.window_rule({
  name = "nofocus-gtaiv",
  match = { class = "gtaiv%.exe", title = "^$" },
  no_focus = true,
  no_initial_focus = true,
})

hl.window_rule({
  name = "float-satty",
  match = { class = "com.gabm.satty" },
  float = true,
})

hl.window_rule({
  name = "center-satty",
  match = { class = "com.gabm.satty" },
  center = true,
})

hl.window_rule({
  name = "size-satty",
  match = { class = "com.gabm.satty" },
  size = "875 600",
})
