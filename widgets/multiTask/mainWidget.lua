local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local utils = require("utils")
local taskUtils = require('widgets.multiTask.utils')
local gears = require("gears")

local M = {}

function is_client_in_focused_tag(c)
  -- 获取当前聚焦的 Tag
  local focused_tag = awful.screen.focused().selected_tag

  -- 获取 client 所在的 Tag
  local client_tags = c:tags()

  -- 判断 client 是否在当前聚焦的 Tag 上
  for _, tag in pairs(client_tags) do
    if focused_tag == tag then
      return true
    end
  end

  return false
end

local create_client_widget = function(c, i)
  -- 创建标题和图标小部件
  local title = c.name
  if title == nil or #title == 1 then
    title = c.class
  end

  local title_widget = wibox.widget {

    wibox.widget {
      markup = title,
      font = "sans bloder 12",
      forced_height = utils.ui.dpiSize(30),
      forced_width = utils.ui.dpiSize(250),
      widget = wibox.widget.textbox
    },
    left = utils.ui.dpiSize(15),
    bottom = utils.ui.dpiSize(15),
    widget = wibox.container.margin
  }


  local icon_widget = nil
  if c.icon == nil then
    icon_widget = wibox.widget {
      wibox.widget {
        markup = " ﮧ ",
        font = "JetBrains Mono Nerd Font Bold 11",
        widget = wibox.widget.textbox,
      },
      forced_height = utils.ui.dpiSize(30),
      forced_width  = utils.ui.dpiSize(30),
      bottom        = utils.ui.dpiSize(15),
      widget        = wibox.container.margin
    }
  else
    icon_widget = wibox.widget {
      awful.widget.clienticon(c),
      forced_height = utils.ui.dpiSize(30),
      forced_width  = utils.ui.dpiSize(30),
      bottom        = utils.ui.dpiSize(5),
      widget        = wibox.container.margin
    }
  end

  local top_layout = wibox.widget {
    icon_widget,
    title_widget,
    layout = wibox.layout.fixed.horizontal
  }


  local is_focuesd_tag = is_client_in_focused_tag(c)

  -- 将缩略图添加到竖直布局中
  local thumbnail = nil
  if is_focuesd_tag then
    thumbnail = taskUtils.makeThumbnail(c)
  else
    thumbnail = taskUtils.makeIconThumbnail(c)
  end

  local bottom_layout = wibox.widget {
    image      = thumbnail,
    widget     = wibox.widget.imagebox,
    clip_shape = utils.ui.rounded_rect(6),
  }

  -- 将标题和缩略图布局添加到主布局中

  local client_thumb_layout = wibox.widget {
    wibox.widget {
      wibox.widget {
        top_layout,
        bottom_layout,
        layout = wibox.layout.align.vertical
      },
      margins       = utils.ui.dpiSize(20),
      forced_height = utils.ui.dpiSize(320),
      forced_width  = utils.ui.dpiSize(500),
      widget        = wibox.container.margin
    },
    shape  = utils.ui.rounded_rect(6),
    widget = wibox.container.background,
  }
  return client_thumb_layout
end


M.init = function(page, screen)
  -- 每页显示的窗口数量
  local page_size = 6
  -- 计算起始和结束的索引
  page = page or 1
  local start_index = (page - 1) * page_size + 1
  local end_index = start_index + page_size - 1

  -- 分两列显示，每列三个
  local rows_grid = wibox.widget {
    forced_num_cols = 3,
    forced_num_rows = 2,
    homogeneous     = true,
    expand          = true,
    spacing         = utils.ui.dpiSize(20),
    layout          = wibox.layout.grid
  }

  --每一次只显示6个
  for index, c in ipairs(client.get()) do -- avoid showing non-normal clients (e.g. dock or desktop)
    if c.type == "normal" then
      if index >= start_index and index <= end_index then
        local client_widget = create_client_widget(c, index)
        rows_grid:add(client_widget)
      end

      index = index + 1
    end
  end

  --让他们水平和垂直居中
  local main_content = wibox.widget {
    rows_grid,
    halign = 'center',
    valign = 'center',
    widget = wibox.container.place
  }

  return main_content
end

-- -- 根据屏幕尺寸，计算放置窗体大小等.
-- local computeSize = function ()

return M
