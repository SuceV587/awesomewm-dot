local wibox      = require('wibox')
local mainWidget = require('widgets.multiTask.mainWidget')
local page = require("widgets.multiTask.page")

local naughty    = require("naughty")
local M          = {}


local refreshWidget = function(screen)
  local widgets = mainWidget.init(1, screen)
  -- local page_layout_widges=mainWidget.conut_page(1,screen)

  page.init()

  fullScreenWidget:setup {
    widgets,
    halign = "center",
    valign = "center",
    widget = wibox.container.margin
  }


end

M.init = function(fullScreenWidget,  screen)
  --当接收到"toggle"信号时，如果组件当前可见，则隐藏组件，否则显示组件
  fullScreenWidget:connect_signal("toggle", function()
    --toggle fullScreenWidget show or hidden status
    fullScreenWidget.visible = not fullScreenWidget.visible

    --when show fullScreenWidget , start to init the widget content
    if fullScreenWidget.visible then
      refreshWidget( screen)
    end
  end)
end



return M
