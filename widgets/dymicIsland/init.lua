local naughty            = require("naughty")
local wibox              = require("wibox")
local gears              = require("gears")
local utils              = require("utils")
local constants          = require("constants")
local shapes             = require("utils.shape")
local awful              = require('awful')
local taglist_widget     = require('widgets.taglist')
local client_status      = require('widgets.dymicIsland.client_status')

local dymic_island_sign  = require('widgets.dymicIsland.sign')

-- 创建一个图标框用于显示客户端图标
local client_icon_widget = wibox.widget({
  widget = wibox.widget.imagebox,
  resize = true,
})



local create_dymicIslnad = function(s)
  local screenWidth = s.geometry.width

  -- 当前运行的client
  local host_widget = wibox.widget {
    wibox.widget {
      wibox.widget {
        client_icon_widget,
        taglist_widget.init(),
        client_status.init(),
        expand = "inside",
        layout = wibox.layout.align.horizontal
      },
      right = utils.ui.dpiSize(6),
      left = utils.ui.dpiSize(10),
      top = utils.ui.dpiSize(4),
      bottom = utils.ui.dpiSize(4),
      widget = wibox.container.margin,
    },
    shape = utils.ui.rounded_rect(utils.ui.dpiSize(35)),
    widget = wibox.container.background
  }

  -- main widget
  local dymic_island_host = wibox({
    widget = host_widget,
    screen = s,
    x = (screenWidth - utils.ui.dpiSize(260)) / 2,
    width = utils.ui.dpiSize(260),
    -- x = utils.ui.dpiSize(10),
    -- width = screenWidth - utils.ui.dpiSize(20),
    y = utils.ui.dpiSize(5),
    shape = gears.shape.rounded_bar,
    height = utils.ui.dpiSize(35),
    bg = '#00000065',
    ontop = false,
    visible = true,
    type = 'utils',
  })

  local dymic_island_widgets = {
    client_icon_widget = client_icon_widget,
    running_status_widget = client_status.running_status_widget,
    float_status_widget = client_status.float_status_widget,
    ontop_status_widget = client_status.ontop_status_widget,
    dymic_island_host = dymic_island_host
  }

  -- -- 为dymic_island监听一些消息
  dymic_island_sign.listen(dymic_island_widgets)
end


return create_dymicIslnad
