--多任务视图
local wibox             = require("wibox")
local naughty           = require("naughty")
local awful             = require("awful")
local utils             = require('utils')
local signModule        = require('widgets.multiTask.signals')

local fullScreenWidget  = nil

local create_mulit_taks = function(s)
  if fullScreenWidget == nil then
    --创建一个awesomewm的全屏组件，背景颜色为000
    fullScreenWidget = wibox({
      visible = false,
      ontop = true,
      type = "splash",
      screen = s,
      bg = "#00000066",
      width = s.geometry.width,
      height = s.geometry.height,
    })

    signModule.init(fullScreenWidget,s)
  end

  return fullScreenWidget
end

return create_mulit_taks
