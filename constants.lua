local gfs    = require("gears.filesystem")

local M      = {}

-- M.terminal = "kitty"
M.terminal   = "alacritty"
M.mods       = {
  m = "Mod4",
  s = "Shift",
  c = "Control",
}
M.wallpapers = gfs.get_configuration_dir() .. "/wallpapers/"


--github个人贡献图组件
M.contributions = gfs.get_configuration_dir() .. "/wallpapers/contributions.jpg"

--weather widget config
--使用和风天气:https://www.qweather.com/
M.weather_app_id = '5ca9c851a9d44819961749d9909e4f3d'
M.weather_city_id = '101250111'
M.weather_city_name=' 长沙天心'


return M
