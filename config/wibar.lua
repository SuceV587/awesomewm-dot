local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local utils = require("utils")
local constants = require("constants")
local my_widgets = require("widgets")
local mods = constants.mods
local my_volume = my_widgets.volume()
local net_speed_widget = require("widgets.net-speed-widget.net-speed")
local create_mulit_taks = require("widgets.multiTask")
local naughty = require("naughty")

local top_widget = require("widgets.topBar")
local bottom_widget = require("widgets.bottomBar")
local dock_center = require("widgets.dockCenter")
local logs = require("utils.log")

local dymic_island = require("widgets.dymicIsland.init")

-- 最重要的部分，删除后可能进入不了屏幕
awful.screen.connect_for_each_screen(function(s)
	--为多屏幕做的兼容
	local index = s.index

	--首屏幕
	if index == 1 then
		dock_center.init(s)
		awful.tag(utils.misc.range(1, 6, 1), s, awful.layout.layouts[2])
	else
		awful.tag({ 7, 8, 9, 10 }, s, awful.layout.layouts[2])
	end

	utils.ui.set_wallpaper(s)

	-- fullScreenWidget = create_mulit_taks(s)

	top_widget.init(s)
	bottom_widget.init(s)

	dymic_island.init(s)
end)
