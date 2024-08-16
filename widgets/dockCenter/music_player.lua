local wibox = require("wibox")
local utils = require("utils")
local beautiful = require("beautiful")
local constants = require("constants")
local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local log = require("utils.log")
local gears = require("gears")
local cairo = require("lgi").cairo
--音乐播放器组件

M_music_player = {
	init = function()
		local widget = M_music_player:make_widget_wrap()
		M_music_player:update_info()
		return widget
	end,
	make_widget_wrap = function()
		local widget_bg = wibox.widget({
			widget = wibox.container.margin,
			margins = utils.ui.dpiSize(20),
		})

		cover_wiget = wibox.widget({
			image = constants.assets .. "/cover.jpg",
			resize = true,
			widget = wibox.widget.imagebox,
		})

		local left_music_cover = wibox.widget({
			cover_wiget,
			margins = utils.ui.dpiSize(10),
			widget = wibox.container.margin,
		})

		--右边的内容
		local right_music_info = M_music_player:make_right_music_info()

		--内容
		local content_widget = wibox.widget({
			left_music_cover,
			right_music_info,
			nil,
			-- expand = "inside",
			-- fill_space     = true,
			spacing = utils.ui.dpiSize(25),
			layout = wibox.layout.fixed.horizontal,
		})

		widget_bg:set_widget(content_widget)

		local main_music_widget = wibox.widget({
			widget_bg,
			bg = "#00000099",
			widget = wibox.container.background,
			shape = utils.ui.rounded_rect(utils.ui.dpiSize(20)),
		})

		main_music_widget.type = "utils"

		return main_music_widget
	end,
	--右边的内容
	make_right_music_info = function()
		--由上中下三部分组成
		local right_music_info_widget = wibox.layout.fixed.vertical()
		right_music_info_widget.spacing = utils.ui.dpiSize(8)

		--上面的歌名
		music_name_widget = wibox.widget({
			text = "暂无播放曲目",
			ellipsize = "end",
			font = beautiful.jetBrains .. "14",
			align = "center",
			widget = wibox.widget.textbox,
			forced_height = utils.ui.dpiSize(22),
		})
		right_music_info_widget:add(music_name_widget)

		music_control_status_widget = wibox.widget({
			text = "",
			font = beautiful.jetBrains .. "28",
			align = "center",
			widget = wibox.widget.textbox,
		})

		--设置点击事件,播放和暂停
		music_control_status_widget:buttons(gears.table.join(awful.button({}, 1, nil, function()
			M_music_player:toggle_play()
		end)))

		back_control_widget = wibox.widget({
			text = "󰒫",
			font = beautiful.jetBrains .. "18",
			align = "right",
			widget = wibox.widget.textbox,
		})

		--上一首点击事件
		back_control_widget:buttons(gears.table.join(awful.button({}, 1, nil, function()
			M_music_player:previous()
		end)))

		next_control_widget = wibox.widget({
			text = "󰒬",
			align = "left",
			font = beautiful.jetBrains .. "18",
			widget = wibox.widget.textbox,
		})

		--下一首点击事件
		next_control_widget:buttons(gears.table.join(awful.button({}, 1, nil, function()
			M_music_player:next()
		end)))

		--中间由三个按钮部分组成，上一首，播放/暂停，下一首
		local music_control_widget = wibox.widget({
			layout = wibox.layout.flex.horizontal,
			back_control_widget,
			music_control_status_widget,
			next_control_widget,
			spacing = utils.ui.dpiSize(30),
		})

		right_music_info_widget:add(music_control_widget)

		local bottom_progress = M_music_player:make_bottom_music_progress()
		right_music_info_widget:add(bottom_progress)

		return right_music_info_widget
	end,
	--底部的播放进度条
	make_bottom_music_progress = function()
		--这里由水平的三部分组件组成，左边是当前播放时间，中间是进度条，右边是总时间
		--左边的当前播放时间
		current_time_widget = wibox.widget({
			text = "00:0",
			font = beautiful.jetBrains .. "10",
			align = "center",
			widget = wibox.widget.textbox,
		})

		--中间的进度条
		music_progressbar = wibox.widget({
			wibox.widget({

				max_value = 100,
				value = 0,
				forced_height = utils.ui.dpiSize(6),
				shape = gears.shape.rounded_bar,
				color = "#888888",
				background_color = "#dddddd",
				widget = wibox.widget.progressbar,
			}),
			margins = utils.ui.dpiSize(6),
			widget = wibox.container.margin,
		})

		--右边的总时间
		total_time_widget = wibox.widget({
			text = "00:0",
			font = beautiful.jetBrains .. "10",
			align = "center",
			widget = wibox.widget.textbox,
		})

		local bottom_progress_widget = wibox.widget({
			current_time_widget,
			music_progressbar,
			total_time_widget,
			layout = wibox.layout.align.horizontal,
		})

		return bottom_progress_widget
	end,
	-- 每隔1s去获取一下播放器的信息
	update_info = function()
		utils.run.newtimer("update_music_player", 1, function()
			awful.spawn.easy_async_with_shell("playerctl metadata", function(stdout)
				--如果stdout字符串里面包含"spotify"，那么就是spotify。包含netease-cloud-music就是网易云音乐
				local player = M_music_player.get_play_soft(stdout)
				if player == "other" then
					return
				end

				--设置歌曲名字和歌手
				M_music_player:set_music_title()

				--设置播放状态
				M_music_player.set_music_status(player)

				--设置播放进度
				M_music_player.set_music_progress(player)

				M_music_player.set_cover()
			end)
		end, false, true)
	end,
	--获取播放器软件是哪个spotify还是网易云音乐
	get_play_soft = function(stdout)
		--如果是QQ音乐,那么是不支持的。目前只支持网易云音乐和spotify

		local test = string.find(stdout, "netease")

		local player = "other"
		if string.find(stdout, "spotify") then
			-- spotify
			player = "spotify"
		elseif string.find(stdout, "netease") then
			-- 网易云音乐
			player = "netease-cloud-music"
		else
			-- 其他
			player = "other"
		end

		return player
	end,
	set_music_title = function()
		awful.spawn.easy_async_with_shell("playerctl metadata --format '{{ artist }} - {{ title }}' ", function(stdout)
			--如果是QQ音乐,那么是不支持的。目前只支持网易云音乐和spotify
			music_name_widget:set_text(stdout)
		end)
	end,
	set_music_status = function(player)
		awful.spawn.easy_async_with_shell("playerctl -p " .. player .. " status", function(stdout)
			status = stdout:gsub("%s+", "") -- 清除多余的空格

			if music_control_status_widget == nil then
				return
			end

			if status == "Playing" then
				music_control_status_widget:set_text("󰏦 ")
			else
				music_control_status_widget:set_text(" ")
			end
		end)
	end,
	set_music_progress = function(player)
		--获取当前播放时间
		awful.spawn.easy_async_with_shell("playerctl -p " .. player .. " position", function(stdout)
			local current_time = stdout:gsub("%s+", "") -- 清除多余的空格

			current_time_widget:set_text(M_music_player.format_time(current_time))

			--获取总时间
			awful.spawn.easy_async_with_shell("playerctl -p " .. player .. " metadata mpris:length", function(stdout)
				local total_time = stdout:gsub("%s+", "") -- 清除多余的空格
				total_time = tonumber(total_time)

				if total_time ~= nil then
					total_time_widget:set_text(M_music_player.format_time(total_time / 1000000))
					--设置进度条
					music_progressbar.widget:set_value(current_time / (total_time / 1000000) * 100)
				end
			end)
		end)
	end,
	set_cover = function()
		awful.spawn.easy_async_with_shell("playerctl metadata --format '{{mpris:artUrl}}' ", function(stdout)
			--格式化专辑封面格式
			local cover_img = string.gsub(stdout, "file://", "")
			cover_img = cover_img:gsub("%s+", "")

			if _G_cover_img == nil or _G_cover_img ~= cover_img then
				_G_cover_img = cover_img

				cover_wiget:set_image(_G_cover_img)
			end
		end)
	end,
	format_time = function(time)
		--获取time_string的类型
		local min = math.floor(time / 60)
		local sec = math.floor(time % 60)

		if sec < 10 then
			sec = "0" .. sec
		end
		return min .. ":" .. sec
	end,
	toggle_play = function()
		awful.spawn.easy_async_with_shell("playerctl play-pause", function(stdout)
			--如果stdout字符串里面包含"spotify"，那么就是spotify。包含netease-cloud-music就是网易云音乐
			local player = M_music_player.get_play_soft(stdout)
			if player == "other" then
				return
			end

			--设置播放状态
			M_music_player.set_music_status(player)
		end)
	end,
	--上一首
	previous = function()
		awful.spawn.easy_async_with_shell("playerctl previous", function(stdout)
			--如果stdout字符串里面包含"spotify"，那么就是spotify。包含netease-cloud-music就是网易云音乐
		end)
	end,
	--下一首
	next = function()
		awful.spawn.easy_async_with_shell("playerctl next", function(stdout)
			--如果stdout字符串里面包含"spotify"，那么就是spotify。包含netease-cloud-music就是网易云音乐
		end)
	end,

	create_and_save_rounded_image = function(path, output_path, size, radius)
		local rounded_image = M_music_player.create_rounded_image(path, size, radius)
		rounded_image:write_to_png(output_path)
	end,

	-- 裁剪图片为圆角
	create_rounded_image = function(path, size, radius)
		local image = cairo.ImageSurface.create(cairo.Format.ARGB32, size, size)
		local cr = cairo.Context(image)

		cr:set_source(gears.color("#00000000"))
		cr:paint()

		cr:arc(radius, radius, radius, math.pi, 3 * math.pi / 2)
		cr:arc(size - radius, radius, radius, 3 * math.pi / 2, 2 * math.pi)
		cr:arc(size - radius, size - radius, radius, 0, math.pi / 2)
		cr:arc(radius, size - radius, radius, math.pi / 2, math.pi)
		cr:close_path()
		cr:clip()

		local source = cairo.ImageSurface.create_from_png(path)
		cr:set_source_surface(source, 0, 0)
		cr:paint()

		log.write_log(image)

		return image
	end,
}

return M_music_player
