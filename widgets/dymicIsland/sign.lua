local utils   = require("utils")
local naughty = require("naughty")
local rubato  = require('utils.rubato')
local awful   = require('awful')
local gears   = require("gears")
local wibox   = require("wibox")

local M       = {}

-- 鼠标进入 wibox 时调用的函数
local mouseEvent = function(dymic_island_widgets)
  local sceenWidth = awful.screen.focused().geometry.width
  local orginWidth = dymic_island_widgets.dymic_island_host.width
  local mouse_enter_animatin_time = nil

  dymic_island_widgets.dymic_island_host:connect_signal("button::press", function()
    if mouse_enter_animatin_time ~= nil and mouse_enter_animatin_time.running then
      return
    end

    dymic_island_widgets.dymic_island_host:setup({
      text = "233",
      widget = wibox.widget.textbox
    })

    mouse_enter_animatin_time = rubato.timed {
      duration = 1,       --half a second
      intro = 1 / 6,      --one third of duration
      override_dt = true, --better accuracy for testing
      subscribed = function(pos)
        if pos ~= nil and pos > 1 then
          dymic_island_widgets.dymic_island_host.width = pos
          dymic_island_widgets.dymic_island_host.x = (sceenWidth - pos) / 2
        end
      end
    }
    mouse_enter_animatin_time.target = sceenWidth - utils.ui.dpiSize(40)
  end)

  -- 鼠标离开 wibox 时调用的函数
  dymic_island_widgets.dymic_island_host:connect_signal("mouse::leave", function()
    dymic_island_widgets.dymic_island_host.width = orginWidth
    dymic_island_widgets.dymic_island_host.x = (sceenWidth - orginWidth) / 2
  end)
end


-- 监听当前正在运行的客户端的状态
local updateFouceClient = function(dymic_island_widgets)
  client.connect_signal("focus", function(focused_client)

    if focused_client == nil or focused_client.name == nil then
      return
    end

    if focused_client then
      dymic_island_widgets.client_icon_widget:set_image(focused_client.icon)
      dymic_island_widgets.running_status_widget:set_visible(true)
    else
      dymic_island_widgets.client_icon_widget:set_image(nil)
      dymic_island_widgets.running_status_widget:set_visible(false)
    end

    -- local running = 'begin'
    -- local sceenWidth = awful.screen.focused().geometry.width
    -- dymic_island_widgets.dymic_island_host.width = utils.ui.dpiSize(42) -- client_icon_widget:set_image(focused_client.icon)
    -- dymic_island_widgets.dymic_island_host.x = (sceenWidth - utils.ui.dpiSize(42)) / 2
    -- running = 'animation'
    --
    -- local timeds = rubato.timed {
    --   duration = 1,       --half a second
    --   intro = 1 / 6,      --one third of duration
    --   override_dt = true, --better accuracy for testing
    --   subscribed = function(pos)
    --     if running ~= 'animation' then
    --       return
    --     end
    --
    --     if pos ~= nil and pos > 1 then
    --       dymic_island_widgets.dymic_island_host.width = utils.ui.dpiSize(pos) -- client_icon_widget:set_image(focused_client.icon)
    --       dymic_island_widgets.dymic_island_host.x = (sceenWidth - utils.ui.dpiSize(pos)) / 2
    --     end
    --   end
    -- }
    -- timeds.target = 330
  end)
end

local refresh_status = function(dymic_island_widgets)
  local client_info_timer = gears.timer({ timeout = 0.5 })
  client_info_timer:connect_signal("timeout", function(status)
    local focused_client = client.focus

    if focused_client == nil then
      return
    end

    if focused_client.floating ~= nil and focused_client.floating then
      dymic_island_widgets.float_status_widget.bg = '#2e8b57'
    else
      dymic_island_widgets.float_status_widget.bg = '#cccccc80'
    end


    if focused_client.ontop ~= nil and focused_client.ontop then
      dymic_island_widgets.ontop_status_widget.bg = '#2e8b57'
    else
      dymic_island_widgets.ontop_status_widget.bg = '#cccccc80'
    end


    if focused_client.maximized ~= nil and focused_client.maximized then
      dymic_island_widgets.running_status_widget.bg = '#2e8b57'
    else
      dymic_island_widgets.running_status_widget.bg = '#cccccc80'
    end
  end)

  client_info_timer:start()
end

M.listen = function(main_widget)
  updateFouceClient(main_widget)
  refresh_status(main_widget)
  mouseEvent(main_widget)
end

return M
