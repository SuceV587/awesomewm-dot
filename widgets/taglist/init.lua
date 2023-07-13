local gears     = require("gears")
local awful     = require("awful")
local wibox     = require("wibox")
local naughty   = require("naughty")
local utils     = require("utils")
local beautiful = require("beautiful")

M_tag_list      = {
  init = function()
    local talg_list_main = M_tag_list.loopTagList()
    local widget_wrap = wibox.widget {
      talg_list_main,
      valign       = 'center',
      halign       = 'center',
      forced_width = utils.ui.dpiSize(30),
      widget       = wibox.container.place,
    }
    return widget_wrap
  end,
  loopTagList = function()
    local widget_wrap = wibox.widget {
      spacing = utils.ui.dpiSize(3),
      layout = wibox.layout.flex.horizontal
    }
    widget_wrap:reset()
    for _, t in ipairs(awful.screen.focused().tags) do
      local widget_one = wibox.widget {
        wibox.widget {
          text   = " ",
          font   = beautiful.jetBrains .. '5',
          valign = 'center',
          align  = 'center',
          widget = wibox.widget.textbox
        },
        bg     = '#00000030',
        shape  = gears.shape.circle,
        widget = wibox.container.background
      }
      -- update
      -- M_tag_list.taglist_update_widget(t, widget_one)

      M_tag_list.listen_event(t, widget_one)
      -- 添加鼠标交互操作，单击可以切换到该标签
      widget_one:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
          t:view_only()
          return
        end
        -- 将 circle widget 绑定到相应的 tag 并根据状态更新它们的颜色和样式
      end)
      -- 更新 widget 的内容，以反映 AwesomeWM 中标签状态的变化
      widget_wrap:add(widget_one)
    end

    return widget_wrap
  end,
  --更新颜色样式
  taglist_update_widget = function(t, widget)
    local bg_color = nil
    if t.selected then
      bg_color = '#ffffff99'
    elseif t.urgent then
      bg_color = '#07a'
    -- elseif #t:clients() > 0 then
    --   bg_color = '#ffffff88'
    else
      bg_color = '#00000030'
    end

    widget.bg = bg_color
  end,
  -- 定时更新tag状态
  listen_event = function(t, widget)
    -- 更新 widget 的内容，以反映 AwesomeWM 中标签状态的变化
    t:connect_signal("property::selected", function() M_tag_list.taglist_update_widget(t, widget) end)
    t:connect_signal("property::activated", function() M_tag_list.taglist_update_widget(t, widget) end)
    t:connect_signal("property::urgent", function() M_tag_list.taglist_update_widget(t, widget) end)
    t:connect_signal("tagged", function() M_tag_list.taglist_update_widget(t, widget) end)
    t:connect_signal("untagged", function() M_tag_list.taglist_update_widget(t, widget) end)
  end
}

return M_tag_list
