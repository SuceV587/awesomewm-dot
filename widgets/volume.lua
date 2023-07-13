local wibox = require("wibox")
local beautiful = require("beautiful")
local utils = require("utils")

local ICONS = {
  normal = {
    high = "墳",
    low = "奄",
    medium = "",
    mute = "婢",
  },
}

local current_level = 50
local current_status = "on"

local get_icon = function(level, status)
  level = tonumber(level)
  if status == "off" then
    return ICONS.normal.mute
  end

  if level >= 75 then
    return ICONS.normal.high
  elseif level >= 40 then
    return ICONS.normal.medium
  elseif level >= 10 then
    return ICONS.normal.low
  end
end

local set_icon = function(percentage, icon, level, status)
  percentage.text = level .. "%"
end

return function()
  local icon = wibox.widget({
    markup = ' ' ,
    -- font = beautiful.font,
    -- font = "JetBrains Mono Nerd Font Bold 13",
    align = "center",
    valign = "center",
    forced_width = utils.ui.dpiSize(18),
    widget = wibox.widget.textbox,
  })

  local percentage_text = wibox.widget({
    id = "percent_text",
    align = "center",
    valign = "center",
    forced_width = utils.ui.dpiSize(36),
    font = beautiful.font,
    widget = wibox.widget.textbox,
  })

  local percentage = wibox.container.background(percentage_text)

  local widget = wibox.widget({
    icon,
    percentage,
    spacing = 5,
    layout = wibox.layout.fixed.horizontal,
  })

  widget:connect_signal("volume::update", function(_, level, status)
    if current_level ~= level or current_status ~= status then
      set_icon(percentage_text, icon, level, status)
    end

    current_level = level
    current_status = status
  end)

  utils.volume.get_level(function(level, status)
    set_icon(percentage_text, icon, level, status)
  end)

  return widget
end
