local beautiful = require("beautiful")
local awful     = require("awful")
local utils     = require("utils")
local wibox     = require("wibox")
local gears     = require("gears")

client_status   = {
  init = function()
    local widget_wrap = wibox.widget {
      wibox.widget {
        client_status.running_status_widget,
        client_status.float_status_widget,
        client_status.ontop_status_widget,
        horizontal_offset = utils.ui.dpiSize(14),
        layout            = wibox.layout.stack,
      },
      forced_width = utils.ui.dpiSize(65),
      widget = wibox.container.background
    }

    return widget_wrap
  end,
  running_status_widget = wibox.widget {
    wibox.widget {
      text = " M ",
      align = "center",
      valign = "center",
      widget = wibox.widget.textbox,
      font = "sans 8",
    },
    shape = gears.shape.circle,
    bg = "#2e8b57",
    fg = "#FFFFFF",
    widget = wibox.container.background
  },
  -- 是否浮动
  float_status_widget = wibox.widget {
    wibox.widget {
      text = " f ",
      align = "center",
      valign = "center",
      widget = wibox.widget.textbox,
      font = "z003,italic 10",
    },
    shape = gears.shape.circle,
    bg = "#cccccc80",
    fg = "#FFFFFF",
    widget = wibox.container.background
  },
  -- 是否ontop
  ontop_status_widget = wibox.widget {
    wibox.widget {
      text = " t ",
      align = "center",
      valign = "center",
      widget = wibox.widget.textbox,
      font = "z003 12",
    },
    shape = gears.shape.circle,
    bg = "#cccccc60",
    fg = "#FFFFFF",
    widget = wibox.container.background
  }
}

return client_status
