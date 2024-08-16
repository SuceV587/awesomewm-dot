pcall(require, "luarocks.loader")

require("awful.autofocus")
local naughty = require("naughty")
local beautiful = require("beautiful")
local gears = require("gears")
local awful = require("awful")

beautiful.xresources.set_dpi(192)

if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end

beautiful.init(gears.filesystem.get_configuration_dir() .. "config/theme.lua")

require("config.wibar")
require("config.layout")
require("config.keys")
require("config.rules")
require("config.signals")
--启动开机脚本
require("config.naughty_center")
require("config.autostart")
