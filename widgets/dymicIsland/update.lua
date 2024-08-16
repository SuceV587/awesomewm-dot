local utils = require("utils")
local naughty = require("naughty")
local rubato = require("utils.rubato")
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local log = require("utils.log")
local music_sign = require("widgets.dymicIsland.music_sign")

local M = {}
local is_music_bar = false

-- 受到notification消息
local main_bar_listen_notification = function()
	local sceenWidth = awful.screen.focused().geometry.width
	local orginWidth = dymic_island_widgets.dymic_island_host.width
	local mouse_enter_animatin_time = nil

	dymic_island_widgets.dymic_island_host:connect_signal("button::press", function()
		if mouse_enter_animatin_time ~= nil and mouse_enter_animatin_time.running then
			return
		end

		local s = dymic_island_widgets.screen
		local screenWidth = s.geometry.width
		local sceenx = s.geometry.x

		mouse_enter_animatin_time = rubato.timed({
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
			end,
		})

		mouse_enter_animatin_time.target = 0
	end)
end

-- 监听当前正在运行的客户端的状态
local updateFouceClient = function(dymic_island_widgets)
	client.connect_signal("focus", function(focused_client)
		if focused_client == nil or focused_client.name == nil then
			return
		end

		local s = dymic_island_widgets.screen

		-- -- 如果是网易云音乐,换一个音乐播放组件
		-- if focused_client.class == "netease-cloud-music" then
		-- 	is_music_bar = true
		-- 	music_sign.listen(dymic_island_widgets)
		-- 	return
		-- end
		--
		-- if is_music_bar then
		-- 	is_music_bar = false
		-- 	music_sign.listen_revert(dymic_island_widgets)
		-- end

		if focused_client then
			dymic_island_widgets.client_icon_widget:set_image(focused_client.icon)
			dymic_island_widgets.running_status_widget:set_visible(true)
		else
			dymic_island_widgets.client_icon_widget:set_image(nil)
			dymic_island_widgets.running_status_widget:set_visible(false)
		end
	end)
end

local refresh_status = function(dymic_island_widgets)
	local client_info_timer = gears.timer({
		timeout = 0.5,
	})
	client_info_timer:connect_signal("timeout", function(status)
		local focused_client = client.focus

		if focused_client == nil then
			return
		end

		if focused_client.floating ~= nil and focused_client.floating then
			dymic_island_widgets.float_status_widget.bg = "#2e8b57"
		else
			dymic_island_widgets.float_status_widget.bg = "#cccccc80"
		end

		if focused_client.ontop ~= nil and focused_client.ontop then
			dymic_island_widgets.ontop_status_widget.bg = "#2e8b57"
		else
			dymic_island_widgets.ontop_status_widget.bg = "#cccccc80"
		end

		if focused_client.maximized ~= nil and focused_client.maximized then
			dymic_island_widgets.running_status_widget.bg = "#2e8b57"
		else
			dymic_island_widgets.running_status_widget.bg = "#cccccc80"
		end
	end)

	client_info_timer:start()
end

M.listen = function(main_widget)
	updateFouceClient(main_widget)
	refresh_status(main_widget)
end

M.main_bar_listen_notification = main_bar_listen_notification

return M
