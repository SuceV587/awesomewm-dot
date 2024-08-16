-- 接收到消息通知后,上面的dymic island动态变化
local log = require('utils.log')
local utils = require("utils")
local rubato = require('utils.rubato')
local awful = require('awful')
local gears = require("gears")
local utils = require("utils")
local wibox = require('wibox')
local constants = require("constants")


local M = {}
local notification_widgets = nil
local notification_widgets_detail_content = nil
local notification_icon_widget = nil

-- 顶部的主组件消失
local hide = function(dymic_island_widgets)
    local s = dymic_island_widgets.screen
    local screenWidth = s.geometry.width
    local sceenx = s.geometry.x
    --

    local mouse_enter_animatin_time = rubato.timed {
        duration = 1 / 3, -- half a second
        intro = 1 / 6, -- one third of duration
        override_dt = true, -- better accuracy for testing
        easing = rubato.quadratic,
        pos = 260,
        subscribed = function(pos)
            if pos > 0 then
                dymic_island_widgets.dymic_island_host.width = utils.ui.dpiSize(pos)
                dymic_island_widgets.dymic_island_host.x = (screenWidth - utils.ui.dpiSize(pos)) / 2 + sceenx
            else
                dymic_island_widgets.dymic_island_host.visible = false
            end
        end
    }

    mouse_enter_animatin_time.target = 0
end

local create_notification_icon_widget = function(app_icon)
    local app_icon_path = constants.assets .. '/linux.png'
    if app_icon ~= nil then
        app_icon_path = app_icon
    end

    --反正重复创建
    if notification_icon_widget ~= nil then
        notification_icon_widget:set_image(app_icon_path)
        return
    end

    notification_icon_widget = wibox.widget {
        image = app_icon_path,
        widget = wibox.widget.imagebox,
        resize = true
    }

    return notification_icon_widget
end

local show_notify_widget = function(dymic_island_widgets, app_icon)

    -- 防止重复创建组件
    if notification_widgets ~= nil then
        notification_widgets.visible = true
    end

    if notification_widgets_detail ~= nil then
        create_notification_icon_widget(app_icon)
        notification_widgets_detail.visible = true
        return
    end

    -- 防止重复创建组件
    local s = dymic_island_widgets.screen
    local screenWidth = s.geometry.width
    local sceenx = s.geometry.x
    local icons = constants.assets .. '/notification.png'

    notification_widgets = wibox({
        widget = wibox.widget {
            wibox.widget {
                image = icons,
                widget = wibox.widget.imagebox
            },
            margins = utils.ui.dpiSize(8),
            widget = wibox.container.margin
        },
        screen = s,
        x = (screenWidth - utils.ui.dpiSize(260)) / 2 + sceenx,
        width = utils.ui.dpiSize(28),
        y = utils.ui.dpiSize(5),
        shape = gears.shape.circle,
        height = utils.ui.dpiSize(28),
        bg = '#ffffff39',
        ontop = false,
        visible = true,
        type = 'utils'
    })

    local icons_close = constants.assets .. '/close_notice.png'
    local notification_handle_icon = wibox.widget {
        wibox.widget {
            image = icons_close,
            widget = wibox.widget.imagebox,
            resize = true
        },
        margins = utils.ui.dpiSize(3),
        widget = wibox.container.margin
    }

    local notification_text = wibox.widget {
        wibox.widget {
            markup = "  message from",
            font = "JetBrains Mono Nerd Font Bold 8",
            widget = wibox.widget.textbox
        },
        valign = 'center',
        halign = 'center',
        widget = wibox.container.place
    }

    local ret_widget = create_notification_icon_widget(app_icon)

    local notification_app_icon = wibox.widget {
        ret_widget,
        right = utils.ui.dpiSize(8),
        top = utils.ui.dpiSize(1),
        bottom = utils.ui.dpiSize(1),
        widget = wibox.container.margin
    }

    local notification_widgets_detail_content = wibox.widget {
        wibox.widget {
            notification_handle_icon,
            notification_text,
            notification_app_icon,
            expand = "inside",
            layout = wibox.layout.align.horizontal
        },
        margins = utils.ui.dpiSize(5),
        widget = wibox.container.margin
    }

    notification_widgets_detail = wibox({
        widget = notification_widgets_detail_content,
        screen = s,
        x = (screenWidth - utils.ui.dpiSize(180)) / 2 + sceenx,
        width = utils.ui.dpiSize(215),
        y = utils.ui.dpiSize(5),
        shape = gears.shape.rounded_bar,
        height = utils.ui.dpiSize(28),
        bg = '#ffffff39',
        ontop = false,
        visible = true,
        type = 'utils'
    })
end

local revert_widget = function(dymic_island_widgets)
    -- code
    local s = dymic_island_widgets.screen
    local screenWidth = s.geometry.width
    local sceenx = s.geometry.x
    --

    awful.spawn.easy_async_with_shell("sleep 3", function()
        -- 销毁 wibox
        notification_widgets_detail.visible = false
        notification_widgets.visible = false

        local mouse_enter_animatin_time = rubato.timed {
            duration = 1 / 3, -- half a second
            intro = 1 / 6, -- one third of duration
            override_dt = true, -- better accuracy for testing
            easing = rubato.quadratic,
            pos = 0,
            subscribed = function(pos)
                if pos > 0 then
                    dymic_island_widgets.dymic_island_host.visible = true
                    dymic_island_widgets.dymic_island_host.width = utils.ui.dpiSize(pos)
                    dymic_island_widgets.dymic_island_host.x = (screenWidth - utils.ui.dpiSize(pos)) / 2 + sceenx
                end
            end
        }

        mouse_enter_animatin_time.target = 260
    end)
end



M.listen = function(dymic_island_widgets, app_icon)
    hide(dymic_island_widgets)

    -- show notification widget
    show_notify_widget(dymic_island_widgets, app_icon)


    -- 10s后,又显示回原来的bar
    revert_widget(dymic_island_widgets)
end

return M
