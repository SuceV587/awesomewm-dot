local beautiful = require("beautiful")
local gears = require("gears")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local M = {}

M.set_wallpaper = function(s)
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

M.rounded_rect = function(radius)
  radius = radius or beautiful.border_radius
  return function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, radius)
  end
end

M.colorize_text = function(text, color)
  return "<span foreground='" .. color .. "'>" .. text .. "</span>"
end

M.dpiSize = function (nums)
  return dpi(nums)
end

return M
