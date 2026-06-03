hl.config({
  input = {
    kb_layout = "us",
    kb_options = "ctrl:nocaps",
    follow_mouse = 1,
    touchpad = {
      natural_scroll = true,
    },
    sensitivity = 0,
    force_no_accel = 1,
    numlock_by_default = true,
  },
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

hl.device({
  name = "epic-mouse-v1",
  sensitivity = -0.5,
})
