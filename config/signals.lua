local awful        = require("awful")
local beautiful    = require("beautiful")
local gears        = require("gears")
local utils        = require("utils")
local shapes       = require("utils.shape")
local ruled        = require("ruled")
local naughty      = require("naughty")
local cairo        = require("lgi").cairo
local dosktop_util = require("widgets.dockCenter.utils.desktop")

-- 在启动时设置壁纸
screen.connect_signal("property::geometry", utils.ui.set_wallpaper)

-- Hide border when there is only one client
screen.connect_signal("arrange", function(s)
  -- local only_one = #s.tiled_clients == 1
  for _, c in pairs(s.clients) do
    if c.floating or c.maximized then
      c.border_width = 0
    end
  end
end)

-- 为所有客户端设置圆角
client.connect_signal("manage", function(c)
  awful.spawn.easy_async_with_shell("sleep 0.1", function()
      --如果没有icon图标,则从系统目录中去取
    if c and c.valid  then
      local default_icon = dosktop_util.lookup_icon({ icon = c.class:lower() })
      if default_icon == nil then
        return
      end
      local s = gears.surface(default_icon)
      local img = cairo.ImageSurface.create(cairo.Format.ARGB32, s:get_width(), s:get_height())
      local cr = cairo.Context(img)
      cr:set_source_surface(s, 0, 0)
      cr:paint()
      c.icon = img._native
    end
  end)


  -- 如果处于第二个tag则设置为平铺
  local current_tag = c:tags()[1]
  if current_tag.name == "2" then
    c.floating = false
  end


  -- if awful.tag.selected(2) ==  then
  --   c.floating = false


  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end

  -- 把新打开的client移动到次要区域，不要占据主区域
  if not awesome.startup then
    c:to_secondary_section()
  end
end)


--发射信号???
client.connect_signal("property::fullscreen", function(c)

end)

--当一个客户端获得焦点时，将其边框颜色设置为美化主题中定义的焦点边框颜色。
client.connect_signal("focus", function(c)
  if c.floating or c.maximized then
    return
  end
  c.border_width = utils.ui.dpiSize(2)
  c.border_color = '#5654a2'
end)

--当一个客户端失去焦点时，将其边框颜色设置为美化主题中定义的非焦点边框颜色。
client.connect_signal("unfocus", function(c)
  c.border_width = 0
end)


-- 把历史消息存入到一个文件中
-- @todo 需要定期清理一下历史消息
naughty.connect_signal("added", function(n)
  local file = io.open(os.getenv("HOME") .. "/.config/awesome/naughty_history", "a")
  file:write(n.title .. ": " .. n.message .. "\n")
  file:close()
end)


-- All notifications will match this rule.
ruled.notification.connect_signal('request::rules', function()
  ruled.notification.append_rule {
    rule       = {},
    properties = {
      screen = awful.screen.preferred,
      implicit_timeout = 6,
    }
  }
end)
