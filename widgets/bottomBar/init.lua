local wibox   = require("wibox")
local awful   = require("awful")
local utils   = require('utils')
local gears   = require("gears")
local naughty = require('naughty')

local timer   = require("gears.timer")

M_bottom_bar  = {
  init               = function(screen)
    -- 如果当前的tag是第一个tag,则显示dock栏,否则显示create_bottom_line
    local bottom_nav_line = M_bottom_bar.create_bottom_line(screen)
    local bottom_dock = M_bottom_bar.create_bottom_dock(screen)
    M_bottom_bar.listen_event(bottom_nav_line, bottom_dock)
  end,
  --创建底部的dock栏

  create_bottom_line = function(screen)
    local bottom_nav_line = awful.wibar({
      position = "bottom",
      screen   = screen,
      stretch  = false,
      width    = utils.ui.dpiSize(720),
      height   = utils.ui.dpiSize(22),
      bg       = "#00000000",
      visible  = true,
      ontop    = false,
      widget   = wibox.widget({
        wibox.widget({
          bg = '#ffffff88',
          shape = gears.shape.rounded_bar,
          widget = wibox.container.background
        }),
        margins = utils.ui.dpiSize(7),
        widget = wibox.container.margin,
      })
    })

    bottom_nav_line:connect_signal("button::press", function(_, _, _, button)
      if button == 1 then
        fullScreenWidget:emit_signal("toggle")
      end
    end)

    return bottom_nav_line
  end,
  create_bottom_dock = function(screen)
    local bottom_dock = awful.wibar({
      position = "bottom",
      screen   = screen,
      stretch  = false,
      width    = '80%',
      height   = utils.ui.dpiSize(80),
      x        = 0,
      bg       = "#00000000",
      ontop    = true,
      widget   = M_bottom_bar.create_task_list(screen)
    })

    return bottom_dock
  end,
  create_task_list   = function(s)
    local full_dyminc_isloand = wibox.widget {
      wibox.widget {
        wibox.widget {
          wibox.widget {
            awful.widget.tasklist {
              screen = s,
              style = {
                bg_normal = "#00000000",
                align     = 'center',
                shape     = utils.ui.rounded_rect(utils.ui.dpiSize(12)),
              },
              layout = {
                spacing = utils.ui.dpiSize(12),
                layout  = wibox.layout.flex.horizontal
              },
              widget_template = {
                {
                  {
                    id     = "clienticon",
                    widget = awful.widget.clienticon,
                  },
                  margins = utils.ui.dpiSize(6),
                  widget  = wibox.container.margin,
                },
                id              = "background_role",
                forced_width    = utils.ui.dpiSize(52),
                forced_height   = utils.ui.dpiSize(52),
                widget          = wibox.container.background,
                create_callback = function(self, c, index, objects) --luacheck: no unused
                  self:get_children_by_id("clienticon")[1].client = c
                  -- 添加单击事件处理函数
                  self:buttons(gears.table.join(
                    awful.button({}, 1, nil, function()
                      c:jump_to()
                      c:raise()
                      -- awful.client.focus = c
                      -- self.visible = false
                    end)
                  ))
                end,
              },
              filter = awful.widget.tasklist.filter.allscreen
            },
            top = utils.ui.dpiSize(6),
            bottom = utils.ui.dpiSize(6),
            left = utils.ui.dpiSize(10),
            right = utils.ui.dpiSize(10),
            widget = wibox.container.margin,
          },
          bg = '#ffffff99',
          shape = utils.ui.rounded_rect(utils.ui.dpiSize(22)),
          widget = wibox.container.background
        },
        top = utils.ui.dpiSize(3),
        bottom = utils.ui.dpiSize(5),
        widget = wibox.container.margin,
      },
      halign = 'center',
      valign = 'center',
      widget = wibox.container.place
    }
    return full_dyminc_isloand
  end,
  listen_event       = function(bottom_nav_line, bottom_dock)
    --监听tag切换事件,如果是第一个tag,则显示dock栏,否则显示create_bottom_line
    local client_info_timer = gears.timer({ timeout = 0.5 })
    client_info_timer:connect_signal("timeout", function()
      local tag = awful.tag.selected()
      -- bottom_nav_line.visible = not bottom_nav_line.visible
      local index = tag.index
      if index == 1 then
        bottom_nav_line.visible = false
        bottom_dock.visible = true
      else
        bottom_nav_line.visible = true
        bottom_dock.visible = false
      end
    end)

    client_info_timer:start()
  end
}


return M_bottom_bar
