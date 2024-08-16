local gfs    = require("gears.filesystem")

local M      = {}

-- M.terminal = "kitty"
M.terminal   = "alacritty"
M.mods       = {
  m = "Mod4",
  s = "Shift",
  c = "Control",
}

M.root_dir = gfs.get_configuration_dir()
M.wallpapers = gfs.get_configuration_dir() .. "/wallpapers/"
M.assets=gfs.get_configuration_dir() .. "/assets/"
--github个人贡献图组件
M.contributions = gfs.get_configuration_dir() .. "/assets/contributions.jpg"

--weather widget config
--使用和风天气:https://www.qweather.com/
M.weather_app_id = ''
M.weather_city_id = ''
M.weather_city_name=' 长沙天心'


return M
