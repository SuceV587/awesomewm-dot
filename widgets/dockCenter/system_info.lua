local wibox = require("wibox")
M_system_info = {
  init = function()
    local widgets = wibox.widget {
      text = "",
      widget = wibox.widget.textbox,
    }

    return widgets
  end
}

return M_system_info
