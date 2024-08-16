local awful = require("awful")
local beautiful = require("beautiful")
local utils = require("utils")
local cairo = require("lgi").cairo
local gears = require("gears")

local get_icon = function(default_icon)
	local s = gears.surface(default_icon)
	local img = cairo.ImageSurface.create(cairo.Format.ARGB32, s:get_width(), s:get_height())
	local cr = cairo.Context(img)
	cr:set_source_surface(s, 0, 0)
	cr:paint()
	return img._native
end

-- TODO: Add more rules
awful.rules.rules = {
	{
		id = "global",
		rule = {},
		properties = {
			focus = true,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			-- placement        = awful.placement.no_overlap + awful.placement.no_offscreen,
			placement = awful.placement.centered,
			shadow = true,
			floating = false,
			maximized = false,
			size_hints_honor = false,
		},
	},
	-- rofi的时候，其他awesomewm的快捷键禁用
	{
		id = "rofi",
		rule_any = {
			class = {
				"rofi",
				"Rofi",
			},
		},
		properties = {
			floating = true,
			keys = nil,
		},
	},
	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- 默认浮动和居中的程序
	{
		id = "dialogs",
		rule_any = {
			type = { "dialog" },
			class = {
				"qq",
				"QQ",
				"com.alibabainc.dingtalk",
				"netease-cloud-music",
				"wechat.exe",
				"Wine",
				"utools",
				"uTools",
				--蓝牙管理设备
				"blueman-manager",
				"Blueman-manager",
				"blueman-adapters",
				"Blueman-adapters",
				--虚拟机
				"VirtualBox Machine",
				"VirtualBox Manager",
				"VirtualBox",
				"VirtualBox",
				"bluemail",
				"BlueMail",
				"geary",
				"Geary",
				"bytedance-feishu",
				"Bytedance-feishu",
				"com.xunlei.download",
				"com.xunlei.download",
				"ulauncher",
				"Ulauncher",
				"AssUI",
				"assUI",
				"ksnip",
			},
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = {
			floating = true,
			shadow = false,
			maximized = false,
			maximized_horizontal = false,
			maximized_vertical = false,
		},
		callback = function(c)
			awful.placement.centered(c, nil)
		end,
	},
	-- FullHD Resolution for Specific Apps
	{
		id = "dialogs",
		rule_any = {
			class = {},
			instance = { "remmina" },
		},
		except_any = {
			name = {
				"Remmina Remote Desktop Client",
			},
		},
		properties = {
			floating = true,
			maximized = true,
		},
	},
	-- All Dialogs are floating and center
	{
		id = "titlebars",
		rule_any = { type = { "normal", "dialog" } },
		properties = { titlebars_enabled = true },
	},

	{
		id = "dingtalk",
		rule_any = {
			class = {
				"com.alibabainc.dingtalk",
			},
		},
		properties = {
			floating = true,
			shape = utils.ui.rounded_rect(10),
			border_width = utils.ui.dpiSize(2),
		},
	},
	-- 可以为某个软件单独设置屏幕和tags
	-- 把微信和邮件放到第三个tag
	{
		rule_any = {
			name = { "Blender" },
		},
		properties = {
			tag = screen[1].tags[3],
		},
	},

	-- 音乐定义初始大小
	{
		rule_any = {
			class = {
				"netease-cloud-music",
				"qq",
				"QQ",
			},
		},
		properties = {
			tag = screen[1].tags[3],
		},
		-- callback = function(c)
		--   c.width = utils.ui.dpiSize(1200)
		--   c.height = utils.ui.dpiSize(800)
		-- end
	},
}
