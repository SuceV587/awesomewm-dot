local awful = require("awful")
local naughty = require("naughty")

return function()
  local widget = nil
  local noti_obj = nil

  local cmd_set = "amixer -D pulse sset Master"
  local cmd_get = "amixer -D pulse sget Master"
  local cmd_inc = cmd_set .. " 5%+"
  local cmd_dec = cmd_set .. " 5%-"
  local cmd_toggle = cmd_set .. " toggle"

  local get_level = function(cb)
    awful.spawn.easy_async(cmd_get, function(out)
      local level, status = string.match(out, "%[(%d+)%%%] %[(%a+)%]")
      cb(level, status)
    end)
  end

  local action = function(cmd)
    awful.spawn.easy_async(cmd, function()
      get_level(function(level, status)
        local percentage = level .. "%"
        local text = status == "on" and "Volume: " .. percentage or "[Muted] " .. percentage

        if widget then
          widget:emit_signal("volume::update", level, status)
        end

        noti_obj = naughty.notify({
          replaces_id = noti_obj ~= nil and noti_obj.id or nil,
          text = text,
        })
      end)
    end)
  end

  return {
    get_level = get_level,
    increase = function()
      action(cmd_inc)
    end,
    decrease = function()
      action(cmd_dec)
    end,
    toggle = function()
      action(cmd_toggle)
    end,
    set_widget = function(w)
      widget = w
    end,
  }
end
