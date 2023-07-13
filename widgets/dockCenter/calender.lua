local utils             = require("utils")
local wibox             = require("wibox")
local beautiful         = require("beautiful")
local gears             = require("gears")
local solar2LunarByTime = require("utils.lunar")


M_cal = {
  init = function()
    -- 创建一个日历,分为左右两边
    local calender = wibox.widget {
      M_cal.left(),
      M_cal.right(),
      spacing = utils.ui.dpiSize(10),
      layout = wibox.layout.flex.horizontal
    }

    return calender
  end,
  -- 左边日历详情
  left = function()
    local widget_bg = wibox.widget {
      bg     = '#ffffff',
      shape  = utils.ui.rounded_rect(utils.ui.dpiSize(20)),
      widget = wibox.container.background
    }

    local content_widget = wibox.layout.flex.vertical()
    content_widget.spacing = utils.ui.dpiSize(10)

    local top_widget = {
      wibox.widget {
        wibox.widget {
          format = "%y年%m月",
          widget = wibox.widget.textclock,
          font   = beautiful.jetBrains .. '14',
        },
        valign = 'center',
        halign = 'center',
        widget = wibox.container.place
      },
      bg            = '#ff5a5d',
      fg            = '#ffffff',
      widget        = wibox.container.background
    }
    content_widget:add(top_widget)
    --添加中间的内容
    local center_widget = {
      wibox.widget {
        wibox.widget {
          format = "%d日",
          widget = wibox.widget.textclock,
          font   = beautiful.jetBrains .. '32',
        },
        valign = 'center',
        halign = 'center',
        widget = wibox.container.place
      },
      fg            = '#000000',
      bg            = '#00000000',
      widget        = wibox.container.background
    }
    content_widget:add(center_widget)

    --获取当前的时间戳
    local now = os.time()
    --通过时间戳获取当前的年月日
    local lunran = solar2LunarByTime(now)
    local bottom_widget = {
      wibox.widget {
        wibox.widget {
          text   = "周" .. os.date("%w") .. '  ' .. lunran.month_shuXu .. '月' .. lunran.day_shuXu .. '日',
          widget = wibox.widget.textbox,
          font   = beautiful.jetBrains .. '12',
        },
        valign = 'center',
        halign = 'center',
        widget = wibox.container.place
      },
      fg            = '#000000',
      widget        = wibox.container.background
    }
    content_widget:add(bottom_widget)
    -- 获取天干地支等信息


    widget_bg:set_widget(content_widget)
    return widget_bg
  end,
  right = function()
    local cal = wibox.widget {
      date          = os.date("*t"),
      font          = beautiful.jetBrains .. "9",
      spacing       = 0,
      long_weekdays = true,
      start_sunday  = true,
      widget        = wibox.widget.calendar.month,
      fn_embed      = function(widget, flag, date)
        local wg = widget
        local fg = '#000000'
        if flag == "focus" then
          fg = '#ff5a5d'
        end

        if flag == "header" then
          fg = '#ff5a5d'
        end

        return wibox.widget({
          {
            wg,
            left = utils.ui.dpiSize(6),
            right = utils.ui.dpiSize(8),
            top = 0,
            bottom = 0,
            widget = wibox.container.margin,
          },
          fg     = fg,
          widget = wibox.container.background,
        })
      end,
    }

    local widget_cal = wibox.widget {
      wibox.widget {
        cal,
        valign = 'center',
        halign = 'center',
        widget = wibox.container.place
      },
      bg    = '#ffffff',
      shape = utils.ui.rounded_rect(utils.ui.dpiSize(20)),
      widget = wibox.container.background,
    }
    return widget_cal
  end
}

return M_cal
