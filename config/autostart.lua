-- 启动自动运行的脚本

local awful = require("awful")
local filesystem = require("gears.filesystem")
local config_dir = filesystem.get_configuration_dir()
local utils = require("utils")


local function autostart_apps()
  --- Compositor
  utils.run.check_if_running("picom", nil, function()
    awful.spawn("picom  --config " .. config_dir .. "otherSysConf/picom.conf", false)
  end)

  --因为修改了分辨率，这里执行下restart命令
  -- awful.spawn.with_shell('xrandr --output HDMI-A-0 --scale 0.8x0.8')

  --keyBoard maps . It must sleep some well
  awful.spawn.with_shell('sleep 3;xmodmap /home/amao/mySpace/1dotfile/keyBoard/.Xmodmap')

  -- onedrive storage
  utils.run.run_once_grep('onedrivegui','sh -c "/usr/bin/onedrivegui"')

  --diodon is a paste manager.The keymap is mod+p
  utils.run.run_once_grep('diodon','/usr/bin/diodon &')

  awful.spawn('xset r rate 200 30')

end

autostart_apps()
