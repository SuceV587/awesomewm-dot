local awful   = require("awful")
local naughty = require("naughty")

M_keys        = {
  open_edeg = function()
    local edeg_commond = '/usr/bin/microsoft-edge-stable %U'
    local edeg_clss = { 'Microsoft-edge', 'microsoft-edge' }

    return M_keys.open_once(edeg_clss, edeg_commond)
  end,
  open_alacritty = function()
    local exec_command = 'alacritty'
    local client_class = { "Alacritty", "Alacritty" }

    return M_keys.open_once(client_class, exec_command)
  end,
  --如果已经打开了就不重复打开
  open_once = function(client_class, exec_command)
    local matcher = function(c)
      for _, class_value in pairs(client_class) do
        if awful.rules.match(c, { class = class_value }) then
          return true
        end
      end

      return false
    end
    local isOpened = false
    local clients = client.get(mouse.screen)
    for _, c in ipairs(clients) do
      if matcher(c) then
        isOpened = true
        c:emit_signal('request::activate', 'key.unminimize', { raise = true })
      end
    end

    if not isOpened then
      awful.spawn(exec_command)
    end
  end,
  --把所有tag1的窗口都隐藏了,显示桌面
  show_desktop = function()
    -- 切换到第一个 tag 并显示所有窗口
    local tag = awful.screen.focused().tags[1]
    if tag then
      awful.tag.viewonly(tag)
      for _, c in ipairs(tag:clients()) do
        c.minimized = true
      end
    end
  end
}

return M_keys
