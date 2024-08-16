local awful = require("awful")

awful.layout.layouts = {

	awful.layout.suit.spiral,
	--
	-- 主区域在右，平铺区域在左
	awful.layout.suit.tile,
	--
	-- 主区域在上，平铺区域在下
	-- awful.layout.suit.tile.bottom,

	awful.layout.suit.floating,
	-- 平铺在上面，主区域在下
	-- awful.layout.suit.tile.top,
	-- awful.layout.suit.fair,
	-- awful.layout.suit.fair.horizontal,
	-- 螺旋状的平铺
	-- awful.layout.suit.spiral,
	-- 主区域一个客户端，其他副区域重叠显示的
	-- awful.layout.suit.spiral.dwindle,
	-- 这种布局下，每个client打开都是maxium的状态，多个client之间不能平铺
	-- awful.layout.suit.max,
	-- 这种布局下，每个client打开都是fullscreen的状态，多个client之间不能平铺
	-- awful.layout.suit.max.fullscreen,
	-- 这种布局下，其中一个主客户端显示中间位置(ontop=true),其他客户端平铺在后面
	-- awful.layout.suit.magnifier,
}

-- 绑定鼠标功能
-- super+左键，可以移动client;
-- super+右键，可以调整窗口大小
client.connect_signal("request::default_mousebindings", function()
	awful.mouse.append_client_mousebindings({
		awful.button({}, 1, function(c)
			c:activate({ context = "mouse_click" })
		end),
		awful.button({ modkey }, 1, function(c)
			c:activate({ context = "mouse_click", action = "mouse_move" })
		end),
		awful.button({ modkey }, 3, function(c)
			c:activate({ context = "mouse_click", action = "mouse_resize" })
		end),
	})
end)

-- 鼠标放到哪个客户端，哪个客户端就自动获得焦点，变成activate状态
-- client.connect_signal("mouse::enter", function(c)
--   c:activate { context = "mouse_enter", raise = false }
-- end)
