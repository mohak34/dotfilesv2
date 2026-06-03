hl.config({
  general = {
    col = {
      active_border = "rgba({{colors.primary.dark.hex | replace: "#", ""}}cc)",
      inactive_border = "rgba({{colors.outline_variant.dark.hex | replace: "#", ""}}66)",
    },
  },
})
