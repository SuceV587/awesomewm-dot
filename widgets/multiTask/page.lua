local wibox              = require('wibox')
-- local mouse              = require('mouse')
local utils              = require('utils')
local naughty            = require('naughty')
local gears              = require("gears")
local beautiful          = require("beautiful")
local M                  = {}

-- 创建一个新的 layout，用于水平排列圆点
local create_dots_widget = function(num_dots)
  local dots_layout = wibox.widget {
    spacing = utils.ui.dpiSize(3),
    layout = wibox.layout.flex.horizontal
  }

  for i = 1, num_dots do
    -- 创建一个新的 circle widget，设置其大小和背景色
    local circle_widget = wibox.widget {
      wibox.widget {
        text   = " ",
        font   = beautiful.jetBrains .. '8',
        valign = 'center',
        align  = 'center',
        widget = wibox.widget.textbox
      },
      bg     = '#ffffff33',
      shape  = gears.shape.circle,
      widget = wibox.container.background
    }
    -- 将这个圆点添加到 dots_layout 中
    dots_layout:add(circle_widget)
  end
  -- 返回 dots_layout，这是一个包含所有圆点的水平 layout
  return dots_layout
end

M.init                   = function()
  -- 获取所有当前打开的客户端
  local clients = client.get()
  local page_size = 6

  -- 计算需要显示的圆点数量（clients 数组的长度除以6，然后取模）
  local num_dots = math.floor((#clients + page_size - 1) / page_size)

  local page_dot_widgets = wibox.widget {
    create_dots_widget(num_dots),
    halign = 'center',
    valign = 'center',
    widget = wibox.container.place
  }

  -- -- 创建一个包含所有圆点的 wibox
  local dots_wibox_width = num_dots * utils.ui.dpiSize(25)
  local dots_wibox = wibox({
    screen  = mouse.screen,
    visible = true,
    ontop   = true,
    type    = "menu",
    width   = dots_wibox_width,
    widget  = page_dot_widgets,
    x       = (mouse.screen.geometry.width - dots_wibox_width) / 2,
    y       = mouse.screen.geometry.height - utils.ui.dpiSize(100),
    bg      = "#ffffff30",
    shape   = gears.shape.rounded_bar,
    -- width = s.geometry.width,
    height  = utils.ui.dpiSize(22)
  })

  -- -- 将第一个圆点的背景色设置为白色
  -- page_dot_widgets.widget.children[1].fg = "#ffffff"

  -- -- 监听鼠标滚动事件，以便在切换页面时更改第一个圆点的背景色
  -- dots_wibox:connect_signal("button::press", function(_, _, _, button)
  --   naughty.notify({
  --     preset = naughty.config.presets.critical,
  --     title = "Oops, there were errors during startup!",
  --     text = button
  --   })
  --   if button == 4 then
  --     -- 向前滚动一页
  --     page_dot_widgets.widget.children[dots_wibox.current_dot].fg = "#ffffff33"
  --     dots_wibox.current_dot = dots_wibox.current_dot - 1
  --     if dots_wibox.current_dot < 1 then
  --       dots_wibox.current_dot = num_dots
  --     end
  --     page_dot_widgets.widget.children[dots_wibox.current_dot].fg = "#fff"
  --   elseif button == 5 then
  --     -- 向后滚动一页
  --     dots_wibox.widget.children[dots_wibox.current_dot].bg = "#ffffff33"
  --     dots_wibox.current_dot = (dots_wibox.current_dot % num_dots) + 1
  --     page_dot_widgets.widget.children[dots_wibox.current_dot].fg = "#fff"
  --   end
  -- end)
  -- -- 将当前圆点的索引绑定到 wibox 对象上
  -- dots_wibox.current_dot = 1
  return dots_wibox
end




return M
