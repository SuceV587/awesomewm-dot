local wibox = require("wibox")
local beautiful = require("beautiful")
local utils = require("utils")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")

local cpu_temp_widget = wibox.widget({
	font = beautiful.font,
	widget = wibox.widget.textbox,
})

local temp = wibox.widget({
	wibox.widget({
		text = "  ",
		widget = wibox.widget.textbox,
		font = beautiful.jetBrains .. "13",
	}),
	cpu_temp_widget,
	layout = wibox.layout.fixed.horizontal,
})

local temp_script = "sensors | grep 'Tctl:' | awk '{print $2}'"

-- 更新温度信息的函数
local update_temp = function()
	awful.spawn.easy_async_with_shell(temp_script, function(stdout)
		stdout = string.gsub(stdout, "+", "")
		stdout = string.gsub(stdout, "\n", "")
		cpu_temp_widget:set_text(stdout)
	end)
end

-- 每隔 10 秒更新一次温度信息
gears.timer({
	timeout = 2,
	callback = update_temp,
	autostart = true,
})

update_temp()
return temp
