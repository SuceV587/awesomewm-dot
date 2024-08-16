-- 创建顶部的组建状态栏
local beautiful = require("beautiful")
local awful = require("awful")
local utils = require("utils")
local wibox = require("wibox")
local gears = require("gears")
local my_widgets = require("widgets")
local net_speed_widget = require("widgets.net-speed-widget.net-speed")
local naughty = require("naughty")
local my_volume = my_widgets.volume()

-- 设置为中国时区格式,为了正确的显示日期和时间
os.setlocale("zh_CN.UTF-8")

M_top_widget = {
	init = function(screen)
		local top = awful.wibar({
			height = utils.ui.dpiSize(43),
			type = "dock",
			bg = "#00000000",
			position = "top",
			screen = screen,
			widget = M_top_widget.topWidgetList(),
		})

		-- 增加点击事件
		-- M_top_widget.right_widget:buttons(gears.table.join(
		-- -- 左键单击事件
		--   awful.button({}, 1, function()
		--     -- 执行 rofi 命令
		--     awful.spawn("rofi -show drun")
		--   end)
		-- ))

		return top
	end,
	-- 顶部widget的全部内容，由左右两部分组成
	topWidgetList = function()
		return wibox.widget({
			M_top_widget.right_widget(),
			nil,
			M_top_widget.left_widget(),
			right = utils.ui.dpiSize(20),
			layout = wibox.layout.align.horizontal,
			widget = wibox.container.margin,
		})
	end,
	-- 右边的组建，包括wifi,网速，声音和系统托盘等
	left_widget = function()
		return wibox.widget({
			wibox.widget({
				layout = wibox.layout.fixed.horizontal,
				spacing = utils.ui.dpiSize(8),
				net_speed_widget(),
				my_widgets.temp,
				my_volume,
				M_top_widget.tag_now(),
				M_top_widget.sysTray(),
			}),
			right = utils.ui.dpiSize(10),
			widget = wibox.container.margin,
		})
	end,
	right_widget = function()
		return wibox.widget({
			{
				wibox.widget({
					wibox.widget({
						format = "%H:%M %m月%d日  %A ",
						widget = wibox.widget.textclock,
						font = beautiful.font,
					}),
					fg = "#ffffff",
					widget = wibox.container.background,
				}),
				layout = wibox.layout.fixed.horizontal,
				spacing = 3,
			},
			left = utils.ui.dpiSize(10),
			widget = wibox.container.margin,
		})
	end,
	-- 系统托盘
	sysTray = function()
		local initSysTray = wibox.widget({
			horizontal = false,
			base_size = utils.ui.dpiSize(17),
			forced_height = utils.ui.dpiSize(17),
			-- this is a bug!!!
			-- opacity = 0.8,
			widget = wibox.widget.systray,
		})

		return wibox.widget({
			wibox.widget({
				wibox.widget({
					initSysTray,
					top = utils.ui.dpiSize(2),
					bottom = utils.ui.dpiSize(2),
					left = utils.ui.dpiSize(10),
					right = utils.ui.dpiSize(10),
					widget = wibox.container.margin,
				}),
				shape = gears.shape.rounded_bar,
				bg = "#ffffff",
				widget = wibox.container.background,
			}),
			align = "center",
			valign = "center",
			widget = wibox.container.place,
		})
	end,
	-- 监听systray的重绘制事件

	tag_now = function()
		local tagList = { " Dock", " Code", " Chat", " Vmware", " Other1", " Other2" }
		local tag_name_widget = wibox.widget({
			text = " Dock",
			widget = wibox.widget.textbox,
		})

		tag.connect_signal("property::selected", function(t)
			local index = tonumber(t.name)
			if index ~= nil and index >= 1 and index <= #tagList then
				tag_name_widget:set_markup(tagList[index])
			else
				tag_name_widget:set_markup(" Other" .. index)
			end
		end)

		return tag_name_widget
	end,
}

return M_top_widget
