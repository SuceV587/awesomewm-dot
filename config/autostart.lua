-- 启动自动运行的脚本

local awful = require("awful")
local filesystem = require("gears.filesystem")
local config_dir = filesystem.get_configuration_dir()
local utils = require("utils")

local function autostart_apps()
	-- 双屏下的设置
	awful.spawn(
		"xrandr  --dpi 192 --output eDP-1 --mode 1920x1200  --scale 1.5x1.5 --pos 0x0 --output HDMI-1 --primary --scale 0.9999x0.9999 --mode 3840x2160 --pos 2880x0"
	)

	--- Compositor
	utils.run.check_if_running("picom", nil, function()
		awful.spawn("picom  --config " .. config_dir .. "otherSysConf/picom.conf", false)
	end)

	--因为修改了分辨率，这里执行下restart命令
	-- awful.spawn.with_shell('xrandr --output HDMI-A-0 --scale 0.8x0.8')

	utils.run.run_once_grep("fcitx5", "fcitx5 &")

	--keyBoard maps . It must sleep some well
	awful.spawn.with_shell("sleep 3;xmodmap /home/amao/mySpace/2myOnedrive/keyBoard/.Xmodmap")

	-- onedrive storage
	-- utils.run.run_once_grep("onedrivegui", 'sh -c "/usr/bin/onedrivegui"')

	--diodon is a paste manager.The keymap is mod+p
	utils.run.run_once_grep("diodon", "/usr/bin/diodon &")

	utils.run.run_once_grep("fcitx5", "fcitx5 &")

	-- utils.run.run_once_grep("dida", "/usr/bin/dida &")

	awful.spawn("xset r rate 200 30")
end

autostart_apps()
