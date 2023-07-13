local gears   = require("gears")
local cairo   = require("lgi").cairo
local naughty = require("naughty")
local utils   = {}


utils.makeThumbnailBak = function(c, i)
  local geo = c:geometry()
  gears.surface(c.content):write_to_png("/tmp/awesomewm-client-screenshot-" .. i .. ".png", { scale = 0.5, quality = 10 })
  local thumbnail = "/tmp/awesomewm-client-screenshot-" .. i .. ".png"
  return thumbnail
end


utils.makeThumbnail = function(c)
  local content = gears.surface(c.content)
  local cr = cairo.Context(content)
  local x, y, w, h = cr:clip_extents()
  local img = cairo.ImageSurface.create(
    cairo.Format.ARGB32,
    w - x,
    h - y
  )
  cr = cairo.Context(img)
  cr:set_source_surface(content, 0, 0)
  cr.operator = cairo.Operator.SOURCE
  cr:paint()

  return gears.surface.load(img)
end

utils.makeIconThumbnail = function(c)
  return '/home/amao/Downloads/bg.jpg'
end


return utils
