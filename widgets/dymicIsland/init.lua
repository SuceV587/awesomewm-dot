local naughty = require("naughty")
local wibox = require("wibox")
local gears = require("gears")
local utils = require("utils")
local constants = require("constants")
local shapes = require("utils.shape")
local awful = require("awful")
local taglist_widget = require("widgets.taglist")
local client_status = require("widgets.dymicIsland.client_status")

local dymic_island_sign = require("widgets.dymicIsland.update")
local notification_sign = require("widgets.dymicIsland.notification_sign")
local logs = require("utils.log")
local os = require("os")
-- 创建一个图标框用于显示客户端图标
local client_icon_widget = wibox.widget({
	widget = wibox.widget.imagebox,
	resize = true,
})

local M = {}

M.init = function(s)
	local screenWidth = s.geometry.width
	local sceenx = s.geometry.x
	-- 当前运行的client
	local host_widget = wibox.widget({
		wibox.widget({
			wibox.widget({
				client_icon_widget,
				taglist_widget.init(s),
				client_status.init(),
				expand = "inside",
				layout = wibox.layout.align.horizontal,
			}),
			right = utils.ui.dpiSize(6),
			left = utils.ui.dpiSize(6),
			top = utils.ui.dpiSize(3),
			bottom = utils.ui.dpiSize(3),
			widget = wibox.container.margin,
		}),
		shape = utils.ui.rounded_rect(utils.ui.dpiSize(35)),
		widget = wibox.container.background,
	})

	local dymic_island_host = wibox({
		widget = host_widget,
		screen = s,
		x = (screenWidth - utils.ui.dpiSize(260)) / 2 + sceenx,
		width = utils.ui.dpiSize(260),
		y = utils.ui.dpiSize(5),
		shape = gears.shape.rounded_bar,
		height = utils.ui.dpiSize(32),
		bg = "#ffffff39",
		ontop = false,
		visible = true,
		type = "utils",
	})

	local dymic_island_widgets = {
		client_icon_widget = client_icon_widget,
		running_status_widget = client_status.running_status_widget,
		float_status_widget = client_status.float_status_widget,
		ontop_status_widget = client_status.ontop_status_widget,
		dymic_island_host = dymic_island_host,
		screen = s,
	}

	-- -- 为dymic_island监听一些消息
	dymic_island_sign.listen(dymic_island_widgets)

	local index = s.index

	--首屏幕
	if index == 1 then
		local last_notice_time = 0
		naughty.connect_signal("added", function(n)
			--15s内的重复消息不进行提示
			local now_time = os.time()
			if now_time - last_notice_time > 5 then
				last_notice_time = now_time
				local app_icon = n.icon or nil
				notification_sign.listen(dymic_island_widgets, app_icon)
			end
		end)
	end
end

return M
