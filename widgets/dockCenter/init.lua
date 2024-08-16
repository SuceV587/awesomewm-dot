local naughty = require("naughty")
local wibox = require("wibox")
local gears = require("gears")
local utils = require("utils")
local beautiful = require("beautiful")
local awful = require("awful")
local weather = require("widgets.dockCenter.weather")
local calender = require("widgets.dockCenter.calender")
local usualClient = require("widgets.dockCenter.usual_client")
local github_contributions = require("widgets.dockCenter.github_contributions")
local clock_and_sys = require("widgets.dockCenter.clock_and_sys")
local music_player = require("widgets.dockCenter.music_player")

M_dock_center = {
	init = function(screen)
		--偏移的x左边，这是多屏显示器的时候，x需要平移另外一块显示器的大小
		local sceenx = screen.geometry.x

		local screenHeight = screen.geometry.height
		local screenWdith = screen.geometry.width
		local main_warp = wibox({
			screen = screen,
			width = screenWdith,
			x = sceenx,
			y = utils.ui.dpiSize(45),
			height = screenHeight - utils.ui.dpiSize(138),
			bg = "#00000000",
			ontop = false,
			visible = true,
			type = "desktop",
		})

		M_dock_center.listen_tag_change(main_warp)
		local mianWdight = M_dock_center.initMainWidget(screen)
		main_warp:setup({
			mianWdight,
			layout = wibox.container.margin,
			margins = utils.ui.dpiSize(30),
		})
	end,
	listen_tag_change = function(main_warp)
		tag.connect_signal("property::selected", function(t)
			local index = tonumber(t.name)
			if index == 1 then
				main_warp.visible = true
			else
				main_warp.visible = false
			end
		end)
	end,
	-- 添加网格布局
	initMainWidget = function(screen)
		local main_content = wibox.widget({
			valign = "top",
			halign = "left",
			widget = wibox.container.place,
		})
		--设置三行三列的网格布局
		local rows_grid = wibox.widget({
			forced_num_cols = 4,
			forced_num_rows = 5,
			orientation = "horizontal",
			homogeneous = true,
			expand = true,
			spacing = utils.ui.dpiSize(30),
			layout = wibox.layout.grid,
		})

		--放一个天气组件上去
		local weather_widget = weather.init()
		rows_grid:add(weather_widget)
		--
		-- --放一个日历组件上去
		local calender_widget = calender.init()
		rows_grid:add(calender_widget)
		--
		--
		-- --添加钟表和设备信息软件
		local clock = clock_and_sys.init()
		rows_grid:add_widget_at(clock, 1, 2, 1, 1)
		--
		--
		-- --把常用的软件组件放上去
		local usualClient_widget = usualClient.init()
		rows_grid:add_widget_at(usualClient_widget, 2, 2, 1, 1)
		--
		--
		local github_contributions_widget = github_contributions.init()
		rows_grid:add_widget_at(github_contributions_widget, 1, 3, 2, 1)

		local music_player_widget = music_player.init()
		rows_grid:add_widget_at(music_player_widget, 1, 4, 1, 1)

		main_content:set_widget(rows_grid)

		return main_content
	end,
}

return M_dock_center
