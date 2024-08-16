local log = require("utils.log")
local utils = require("utils")
local rubato = require("utils.rubato")
local awful = require("awful")
local gears = require("gears")
local utils = require("utils")
local wibox = require("wibox")
local constants = require("constants")
local wave = require("widgets.dymicIsland.wave")

local log = require("utils.log")
local M = {}
local wave_widgets = nil
local wave_detail_widgets = nil

-- 顶部的主组件消失
local hide = function(dymic_island_widgets)
	local s = dymic_island_widgets.screen
	local screenWidth = s.geometry.width
	local sceenx = s.geometry.x

	local mouse_enter_animatin_time = rubato.timed({
		duration = 1 / 3, -- half a second
		intro = 1 / 6, -- one third of duration
		override_dt = true, -- better accuracy for testing
		easing = rubato.quadratic,
		pos = 260,
		subscribed = function(pos)
			if pos > 0 then
				dymic_island_widgets.dymic_island_host.width = utils.ui.dpiSize(pos)
				dymic_island_widgets.dymic_island_host.x = (screenWidth - utils.ui.dpiSize(pos)) / 2 + sceenx
			else
				dymic_island_widgets.dymic_island_host.visible = false
			end
		end,
	})

	mouse_enter_animatin_time.target = 0
end

local revert_widget = function(dymic_island_widgets)
	-- code
	local s = dymic_island_widgets.screen
	local screenWidth = s.geometry.width
	local sceenx = s.geometry.x
	--

	awful.spawn.easy_async_with_shell("sleep 1", function()
		-- 销毁 wibox

		log.write_log("enter destoryu")

		if wave_widgets ~= nil then
			log.write_log("set visible wave_widgets")
			wave_widgets.visible = false
		end

		if wave_detail_widgets ~= nil then
			log.write_log("set visible wave_detail_widgets")
			wave_detail_widgets.visible = false
		end

		local mouse_enter_animatin_time = rubato.timed({
			duration = 1 / 3, -- half a second
			intro = 1 / 6, -- one third of duration
			override_dt = true, -- better accuracy for testing
			easing = rubato.quadratic,
			pos = 0,
			subscribed = function(pos)
				if pos > 0 then
					dymic_island_widgets.dymic_island_host.visible = true
					dymic_island_widgets.dymic_island_host.width = utils.ui.dpiSize(pos)
					dymic_island_widgets.dymic_island_host.x = (screenWidth - utils.ui.dpiSize(pos)) / 2 + sceenx
				end
			end,
		})

		mouse_enter_animatin_time.target = 260
	end)
end

local show = function(dymic_island_widgets)
	-- 防止重复创建组件
	if wave_widgets ~= nil then
		wave_widgets.visible = true
	end

	local s = dymic_island_widgets.screen
	local screenWidth = s.geometry.width
	local sceenx = s.geometry.x

	local wave = wave.init()

	wave_widgets = wibox({
		widget = wibox.widget({
			wave,
			margins = utils.ui.dpiSize(5),
			widget = wibox.container.margin,
		}),
		screen = s,
		x = (screenWidth - utils.ui.dpiSize(260)) / 2 + sceenx,
		width = utils.ui.dpiSize(28),
		y = utils.ui.dpiSize(5),
		shape = gears.shape.circle,
		height = utils.ui.dpiSize(28),
		bg = "#ffffff39",
		ontop = false,
		visible = true,
		type = "utils",
	})
end

local create_cover_icon_widget = function()
	local app_icon_path = constants.assets .. "/wyy.png"
	if _G_cover_img ~= nil then
		app_icon_path = _G_cover_img
	end

	cover_icon_widget = wibox.widget({
		image = app_icon_path,
		widget = wibox.widget.imagebox,
		resize = true,
	})

	return cover_icon_widget
end

local show_detail = function(dymic_island_widgets)
	-- 防止重复创建组件
	if wave_detail_widgets ~= nil then
		wave_detail_widgets.visible = true
	end

	local s = dymic_island_widgets.screen
	local screenWidth = s.geometry.width
	local sceenx = s.geometry.x

	local icons_close = constants.assets .. "/stop.png"
	local notification_handle_icon = wibox.widget({
		wibox.widget({
			image = icons_close,
			widget = wibox.widget.imagebox,
			resize = true,
		}),
		margins = utils.ui.dpiSize(3),
		widget = wibox.container.margin,
	})

	local notification_text = wibox.widget({
		wibox.widget({
			markup = "playing",
			font = "JetBrains Mono Nerd Font Bold 8",
			widget = wibox.widget.textbox,
		}),
		valign = "center",
		halign = "center",
		widget = wibox.container.place,
	})

	local ret_widget = create_cover_icon_widget()

	local notification_app_icon = wibox.widget({
		ret_widget,
		right = utils.ui.dpiSize(8),
		top = utils.ui.dpiSize(1),
		bottom = utils.ui.dpiSize(1),
		widget = wibox.container.margin,
	})

	local notification_widgets_detail_content = wibox.widget({
		wibox.widget({
			notification_handle_icon,
			notification_text,
			notification_app_icon,
			expand = "inside",
			layout = wibox.layout.align.horizontal,
		}),
		margins = utils.ui.dpiSize(5),
		widget = wibox.container.margin,
	})

	wave_detail_widgets = wibox({
		widget = notification_widgets_detail_content,
		screen = s,
		x = (screenWidth - utils.ui.dpiSize(180)) / 2 + sceenx,
		width = utils.ui.dpiSize(215),
		y = utils.ui.dpiSize(5),
		shape = gears.shape.rounded_bar,
		height = utils.ui.dpiSize(28),
		bg = "#ffffff39",
		ontop = false,
		visible = true,
		type = "utils",
	})
end

M.listen = function(dymic_island_widgets)
	hide(dymic_island_widgets)

	show(dymic_island_widgets)

	show_detail(dymic_island_widgets)
end

M.listen_revert = function(dymic_island_widgets)
	log.write_log("enter revert")
	revert_widget(dymic_island_widgets)
end

return M
