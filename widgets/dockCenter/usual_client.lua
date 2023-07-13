local utils           = require("utils")
local wibox           = require("wibox")
local beautiful       = require("beautiful")
local gears           = require("gears")
local constants       = require("constants")
local naughty         = require("naughty")
local specity_desktop = require('widgets.dockCenter.utils.specity_desktop')
local awful           = require("awful")
local gears           = require("gears")
local dosktop_util    = require("widgets.dockCenter.utils.desktop")
--这里放置常用的软件,组件
M_usualClient         = {
  init = function()
    --创建上下两个部分
    local widget_main = wibox.layout.fixed.vertical()
    widget_main.spacing = utils.ui.dpiSize(5)
    local widget_margin_main = wibox.widget {
      -- forced_width  = utils.ui.dpiSize(200),
      forced_height = utils.ui.dpiSize(190),
      margins       = utils.ui.dpiSize(20),
      widget        = wibox.container.margin,
    }

    local widget_bg_main = wibox.widget {
      bg     = '#00000099',
      shape  = utils.ui.rounded_rect(utils.ui.dpiSize(20)),
      widget = wibox.container.background,
    }

    --设置三行三列的网格布局
    local rows_grid = wibox.widget {
      forced_num_cols = 6,
      forced_num_rows = 2,
      orientation     = "vertical",
      homogeneous     = true,
      expand          = true,
      spacing         = utils.ui.dpiSize(15),
      layout          = wibox.layout.grid
    }

    --循环当前所有的软件,如果是常用的软件,就放到网格布局里面,并且添加点击事件
    M_usualClient.loop_usual_client(rows_grid)
    widget_margin_main:set_widget(rows_grid)
    widget_bg_main:set_widget(widget_margin_main)
    widget_main:add(widget_bg_main)

    --创建下面部分,居中显示标题,加上背景阴影
    local widget_title = wibox.widget {
      wibox.widget {
        wibox.widget {
          wibox.widget {
            text = "常用软件",
            font = beautiful.jetBrains .. '10',
            widget = wibox.widget.textbox,
          },
          margins = 2,
          widget = wibox.container.margin,
        },
        fg = '#ffffff',
        shape = utils.ui.rounded_rect(utils.ui.dpiSize(2)),
        widget = wibox.container.background,
      },
      valign = "center",
      halign = "center",
      widget = wibox.container.place
    }
    widget_main:add(widget_title)

    return widget_main
  end,
  loop_usual_client = function(grid_widget)
    local usual = specity_desktop.get_usual_client()
    --循环当前所有的软件,如果是常用的软件,就放到网格布局里面,并且添加点击事件
    for _, c in ipairs(usual) do
      local default_icon = c.icon_path
      if c.icon_path == nil then
        local name =c.Name:lower()
        naughty.notify({
          preset = naughty.config.presets.critical,
          title = "Oops, an error happened!",
          text = "没有找到图标" .. name,
        })
        default_icon = dosktop_util.lookup_icon({ icon = c.Name:lower() })
      end

      local widget = wibox.widget {
        image = default_icon,
        resize = true,
        widget = wibox.widget.imagebox
      }
      --双击打开软件
      local last_click = 0 -- 用于记录上一次点击的时间
      widget:connect_signal("button::press", function()
        --避免重复点击,三秒内只能点击一次
        if os.time() - last_click < 5 then
          return
        end

        awful.spawn.with_shell(c.cmdline)
        last_click = os.time()


        -- local time_since_last_click = os.time() - last_click
        -- if time_since_last_click < 1 then -- 时间间隔小于 1 秒，判断为双击事件
        --   awful.spawn.with_shell(c.cmdline)
        -- end
        -- last_click = os.time()
      end)
      grid_widget:add(widget)
    end
  end
}

return M_usualClient
