local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gears = require("gears")
local naughty = require("naughty")
local constants = require("constants")
local utils = require("utils")

local theme = {}

theme.transparent = "#0000004a"
-- theme.font = "JetBrains Mono Nerd Font Bold 11"

theme.pingFang = "PingFang SC Regular "
theme.font = "PingFang SC Regular 12,JetBrains Mono Nerd Font Bold 12"
theme.iconfont = "Roboto Medium"
theme.jetBrains = "JetBrains Mono Nerd Font Bold "

theme.black = "#16161D"
theme.red = "#E46876"
theme.yellow = "#F2D98C"
theme.orange = "#FFA066"
theme.green = "#A8C98F"
theme.white = "#D3D3D3"
theme.puple = "#A066D3"
theme.light_yellow = "#eddbb5"
theme.light_green = "#5bd2a6"
theme.ligth_blue = "#a8cfff"

theme.arcchart_color = "#5bd2a6"
theme.arcchart_bg = "#5bd2a6"
-- bg
theme.bg_normal = theme.transparent
-- theme.bg_focus = theme.green
theme.bg_focus = "#ffffff99"
theme.bg_urgent = theme.red

-- fg
theme.fg_normal = theme.white
-- theme.fg_focus = theme.yellow

theme.fg_focus = "#000"
theme.fg_urgent = theme.white

-- spacing

-- theme.spacing = dpi(8)
-- theme.spacing_md = dpi(12)
-- theme.spacing_lg = dpi(16)
-- theme.spacing_xl = dpi(20)

theme.spacing = dpi(5)
theme.spacing_md = dpi(8)
theme.spacing_lg = dpi(10)
theme.spacing_xl = dpi(14)

-- border
theme.useless_gap = dpi(5)
theme.border_width = dpi(1)
theme.border_radius = dpi(13)

-- theme.border_focus = theme.puple
theme.border_focus = "#3D59AB"
-- theme.border_normal = '#ffffff'

-- 定义新的阴影效果
theme.focused_shadow = {
	offset = 20,
	blur_radius = 100,
	color = "#000000",
	opacity = 0.8,
	shape = function(cr, w, h)
		gears.shape.rounded_rect(cr, w, h, 5)
	end,
}

-- taglist
theme.taglist_bg = theme.bg_normal
theme.taglist_bg_focus = theme.green
theme.taglist_bg_urgent = theme.red
theme.taglist_fg_focus = theme.bg_normal
theme.taglist_fg_occupied = theme.green

--tasklist
theme.tasklist_bg_focus = "#ffffff"

-- wallpaper
theme.wallpaper = gears.surface.load_uncached(constants.wallpapers .. "bg.jpg")

-- bar
theme.bar_height = dpi(60)

-- system tray
theme.systray_icon_spacing = theme.spacing
theme.systray_max_rows = 30
theme.bg_systray = "#ffffff"

-- theme.notification_height = dpi(68)
-- theme.notification_width = dpi(350)

-- ********************************* --
--
--              Naughty
--
-- ********************************* --

local nc = naughty.config
nc.defaults.margin = theme.spacing_lg
nc.defaults.shape = utils.ui.rounded_rect(utils.ui.dpiSize(20))
nc.defaults.timeout = 5

nc.padding = theme.spacing_xl
nc.defaults.bg = "#00000088"
nc.defaults.fg = "#f0f0f0"
nc.defaults.width = utils.ui.dpiSize(380)

nc.defaults.border_width = 2
nc.defaults.font = "PingFang SC Regular 10"
nc.defaults.icon_size = utils.ui.dpiSize(35)
nc.defaults.margin = utils.ui.dpiSize(15)
-- nc.presets.critical.bg = theme.red
-- nc.presets.critical.fg = theme.bg_normal
-- nc.presets.low.bg = theme.bg_normal
-- nc.presets.normal.bg = theme.green
-- nc.presets.normal.fg = theme.bg_normal

theme.notification_max_height = utils.ui.dpiSize(80)
-- theme.notification_max_height = utils.ui.dpiSize(50)

-- ********************************* --
--
--              Widgets
--
-- ********************************* --

-- battery
theme.battery_happy = theme.fg_normal
theme.battery_tired = theme.yellow
theme.battery_sad = theme.red
theme.battery_charging = theme.green

-- calendar
theme.calendar_fg_header = theme.fg_normal
theme.calendar_fg_focus = theme.bg_normal
theme.calendar_fg_weekday = theme.green
theme.calendar_fg = theme.fg_normal
theme.calendar_bg = theme.bg_normal
theme.calendar_bg_focus = theme.green

--keymaops hotkeys_bg,awful widget about popup hotkeys
theme.hotkeys_bg = "#000000"
theme.hotkeys_font = "JetBrains Mono Nerd Font Bold 12"
theme.hotkeys_border_color = "#333333"
theme.hotkeys_border_width = dpi(2)

local gfs = require("gears.filesystem")
theme.cpu_icon = constants.wallpapers .. "/icons/cpu.png"

return theme
