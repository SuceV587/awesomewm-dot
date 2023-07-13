local wibox              = require("wibox")
local gears              = require("gears")
local awful              = require("awful")
local beautiful          = require("beautiful")
local utils              = require("utils")
local constants          = require("constants")
local my_widgets         = require("widgets")
local mods               = constants.mods
local my_volume          = my_widgets.volume()
local net_speed_widget   = require("widgets.net-speed-widget.net-speed")
local create_dymicIslnad = require("widgets.dymicIsland")
local create_mulit_taks  = require("widgets.multiTask")
local naughty            = require("naughty")

local top_widget         = require('widgets.topBar')
local bottom_widget      = require('widgets.bottomBar')
local dock_center        = require('widgets.dockCenter')


-- 创建一个文本框widget
-- local marginBg =

-- 最重要的部分，删除后可能进入不了屏幕
awful.screen.connect_for_each_screen(function(s)
  awful.tag(utils.misc.range(1, 6, 1), s, awful.layout.layouts[1])

  utils.ui.set_wallpaper(s)

  fullScreenWidget = create_mulit_taks(s)

  bottom_widget.init(s)
  -- Each screen has its own tag table.

  top_widget.init(s)

  dock_center.init(s)

  create_dymicIslnad(s)
end)
