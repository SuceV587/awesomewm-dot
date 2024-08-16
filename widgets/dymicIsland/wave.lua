local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local cairo = require("lgi").cairo
local utils = require("utils")

local M = {}

M.init = function()
  -- 创建波浪组件
  local wave_widget = wibox.widget {
    widget = wibox.widget.graph,
    width = utils.ui.dpiSize(25),
    step_width = 5,
    step_spacing = 1,
    color = "#ccabdb",
    background_color = "#00000000",
    min_value = -60,
    max_value = 50,
    value = 50,
    forced_height = 20,
    paddings = 5,
    border_width = 3,
    border_color = "#00000000",
    update_value = function(self)
      local random_value = math.random(-30, 50)     -- 生成 0 到 100 之间的随机值
      self:add_value(random_value)
    end,
    start_animation = function(self)
      self.animation = gears.timer {
        timeout = 0.1,
        autostart = true,
        callback = function()
          self:update_value()
        end
      }
    end,
    stop_animation = function(self)
      if self.animation then
        self.animation:stop()
        self.animation = nil
      end
    end
  }

  -- 启动波浪动画
  wave_widget:start_animation()
  return wave_widget
end

return M

