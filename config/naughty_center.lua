local naughty                  = require("naughty")
local awful                    = require('awful')
local dymic_island_notify_sign = require('widgets.dymicIsland.notification_sign')
local log                      = require('utils.log')


-- 把历史消息存入到一个文件中
naughty.connect_signal("added", function(n)
  local file = io.open(os.getenv("HOME") .. "/.config/awesome/naughty_history", "a")
  local app_name = n.app_name or "Unknown" -- 获取应用程序名称，如果不存在则使用 "Unknown"
  local app_icon = n.app_icon or "Unknown" -- 获取应用程序名称，如果不存在则使用 "Unknown"
  file:write(app_icon .. ":" .. n.title .. ": " .. n.message .. "\n")
  file:close()
end)
