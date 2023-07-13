local wibox     = require("wibox")
local utils     = require("utils")
local gears     = require("gears")
local beautiful = require("beautiful")
local awful     = require("awful")
local naughty   = require("naughty")

local constants = require("constants")


M_clocl_sys = {
  init = function()
    --这个组件分为两部分，左面是一个时钟，右面是一个音乐播放器
    local main_widget = wibox.widget {
      fill_space = true,
      spacing = utils.ui.dpiSize(20),
      layout = wibox.layout.fixed.horizontal
    }


    local left_widget = M_clocl_sys.init_clock_widget()
    main_widget:add(left_widget)

    --右边部分为task组件
    local right_widget = M_clocl_sys.init_system_info_widget()
    main_widget:add(right_widget)

    return main_widget
  end,
  init_clock_widget = function()
    -- 左边部分为钟表
    local clock_widget = wibox.widget {
      bg     = "#00000090",
      shape  = utils.ui.rounded_rect(utils.ui.dpiSize(20)),
      widget = wibox.container.background
    }

    local clock = M_clocl_sys.make_clock()
    clock_widget:setup {
      clock,
      layout = wibox.container.margin,
      margins = utils.ui.dpiSize(2)
    }
    return clock_widget
  end,
  make_clock = function()
    local imagebox = wibox.widget {
      resize = true,
      widget = wibox.widget.imagebox
    }
    -- 更新钟表

    utils.run.newtimer("update_clock", 1, function()
        local img = M_clocl_sys.make_clock_canvas()
        imagebox:set_image(img)
      end,
      false, true)

    return imagebox
  end,
  make_clock_canvas = function()
    local cairo = require("lgi").cairo

    -- 创建一个Canvas对象
    -- 200x200的画布
    local surface = cairo.ImageSurface.create(cairo.Format.ARGB32, utils.ui.dpiSize(200), utils.ui.dpiSize(200))
    local cr = cairo.Context(surface)

    -- 设置圆形钟表的参数
    local cx, cy, radius = utils.ui.dpiSize(100), utils.ui.dpiSize(100), utils.ui.dpiSize(90)
    local hour_hand_length, minute_hand_length, second_hand_length = utils.ui.dpiSize(50), utils.ui.dpiSize(70),
        utils.ui.dpiSize(80)

    -- 绘制表盘
    cr:set_source_rgb(1, 1, 1)
    cr:arc(cx, cy, radius, 0, math.pi * 2)
    cr:fill()

    -- 绘制刻度
    cr:set_line_cap(cairo.LineCap.ROUND)
    cr:set_source_rgb(0, 0, 0)
    for i = 1, 12 do
      local angle = math.pi / 6 * i
      local x1, y1 = cx + (radius - utils.ui.dpiSize(10)) * math.sin(angle),
          cy - (radius - utils.ui.dpiSize(15)) * math.cos(angle)
      local x2, y2 = cx + radius * math.sin(angle), cy - radius * math.cos(angle)
      cr:move_to(x1, y1)
      cr:line_to(x2, y2)
      cr:set_line_width(utils.ui.dpiSize(5))
      cr:stroke()

      -- 绘制数字
      -- 绘制数字
      local text_angle = math.pi / 6 * i
      local text_extents = cr:text_extents(tostring(i))
      local x = cx + (radius - utils.ui.dpiSize(30)) * math.sin(text_angle) - text_extents.width / 2 -
          text_extents.x_bearing
      local y = cy - (radius - utils.ui.dpiSize(30)) * math.cos(text_angle) - text_extents.height / 2 -
          text_extents.y_bearing
      cr:set_font_size(utils.ui.dpiSize(15))
      cr:move_to(x, y)
      cr:show_text(tostring(i))
    end

    for i = 0, 59 do
      local angle = math.pi / 30 * i
      local x1, y1 = cx + (radius - 5) * math.sin(angle), cy - (radius - 5) * math.cos(angle)
      local x2, y2 = cx + (radius - 10) * math.sin(angle), cy - (radius - 10) * math.cos(angle)
      cr:move_to(x1, y1)
      cr:line_to(x2, y2)
      cr:set_line_width(2)
      cr:stroke()
    end

    -- 绘制时针
    local hour = os.date("%I")
    local minute = os.date("%M")
    local second = os.date("%S")

    local angle_hour = math.pi / 6 * hour + math.pi / 360 * minute
    local angle_minute = math.pi / 30 * minute
    local angle_second = math.pi / 30 * second

    cr:move_to(cx, cy)
    cr:line_to(cx + hour_hand_length * math.sin(angle_hour), cy - hour_hand_length * math.cos(angle_hour))
    cr:set_line_width(utils.ui.dpiSize(7))
    cr:stroke()

    -- 绘制分针
    cr:move_to(cx, cy)
    cr:line_to(cx + minute_hand_length * math.sin(angle_minute), cy - minute_hand_length * math.cos(angle_minute))
    cr:set_line_width(utils.ui.dpiSize(5))
    cr:stroke()

    -- 绘制秒针
    cr:set_source_rgb(255, 128 / 255, 0) -- 将秒针颜色设置1黄色
    cr:move_to(cx, cy)
    cr:line_to(cx + second_hand_length * math.sin(angle_second), cy - second_hand_length * math.cos(angle_second))
    cr:set_line_width(utils.ui.dpiSize(1))
    cr:stroke()

    -- 将Canvas对象渲染为一个图像
    local img = surface:create_similar(cairo.Content.COLOR_ALPHA, utils.ui.dpiSize(200), utils.ui.dpiSize(200))
    local cr2 = cairo.Context(img)
    cr2:set_source_surface(surface)
    cr2:paint()

    return img
  end,
  init_system_info_widget = function()
    local syste_info_widget = wibox.widget {
      spacing = utils.ui.dpiSize(20),
      layout = wibox.layout.fixed.vertical
    }

    --上面组件由左右两部分组成
    --左边是一个cpu使用组件
    local top_widget = wibox.widget {
      spacing = utils.ui.dpiSize(2),
      forced_height = utils.ui.dpiSize(72),
      layout = wibox.layout.flex.horizontal
    }

    local top_widget_cpu = M_clocl_sys.init_cpu_widget()
    top_widget:add(top_widget_cpu)

    local top_widget_memory = M_clocl_sys.init_memory_widget()
    top_widget:add(top_widget_memory)


    syste_info_widget:add(top_widget)

    --下面是一个组件显示硬盘剩余
    local bottom_widget = M_clocl_sys.init_disk_widget()
    syste_info_widget:add(bottom_widget)

    local main_wrap = wibox.widget {
      wibox.widget {
        syste_info_widget,
        margins = utils.ui.dpiSize(6),
        widget = wibox.container.margin,
      },
      bg     = "#ffffff",
      fg     = "#999999",
      shape  = utils.ui.rounded_rect(utils.ui.dpiSize(20)),
      widget = wibox.container.background,
    }
    return main_wrap
  end,
  init_cpu_widget = function()
    --cpu组件由上下两部分组成,上面是一个圆环,下面是一个数字
    local cpu_arc = wibox.widget {
      wibox.widget {
        text   = "CPU",
        font   = beautiful.pingFang .. '9',
        widget = wibox.widget.textbox,
        align  = "center",
        valign = "center",
      },
      max_value = 100,
      value = 50,
      thickness = utils.ui.dpiSize(15),
      start_angle = math.pi * 1.5,
      rounded_edge = true,
      bg = '#dddddd',
      paddings = 0,
      colors = { '#38C364' },
      widget = wibox.container.arcchart
    }

    local update_interval = 3
    local cpu_idle_script = [[sh -c "vmstat 1 2 | tail -1 | awk '{printf \"%d\", $15}'"]]

    -- Periodically get cpu info
    awful.widget.watch(cpu_idle_script, update_interval, function(widget, stdout)
      -- local cpu_idle = stdout:match('+(.*)%.%d...(.*)%(')
      local cpu_idle = stdout
      cpu_idle = string.gsub(cpu_idle, '^%s*(.-)%s*$', '%1')
      local value = 100 - tonumber(cpu_idle)
      cpu_arc.value = value
    end)
    return cpu_arc
  end,
  init_memory_widget = function()
    --meory组件由上下两部分组成,上面是一个圆环,下面是一个数字
    local memory_arc = wibox.widget {
      wibox.widget {
        text   = "RAM",
        font   = beautiful.pingFang .. '8',
        widget = wibox.widget.textbox,
        align  = "center",
        valign = "center",
      },
      max_value = 100,
      value = 50,
      thickness = utils.ui.dpiSize(15),
      start_angle = math.pi * 1.5,
      rounded_edge = true,
      bg = '#dddddd',
      colors = { '#38C364' },
      widget = wibox.container.arcchart
    }

    local update_interval = 3
    local memory_idle_script = [[sh -c
     "LANG=c free -m | grep 'Mem:' | awk '{printf \"%d@@%d@\", $7, $2}'"
    ]]
    -- Periodically get cpu info
    awful.widget.watch(memory_idle_script, update_interval, function(widget, stdout)

      local available = stdout:match('(.*)@@')
      local total = tonumber(stdout:match('@@(.*)@'))
      local used = tonumber(total) - tonumber(available)
      -- local cpu_idle = stdout:match('+(.*)%.%d...(.*)%(')
      memory_arc.value = math.floor(used / total * 100)
    end)
    return memory_arc
  end,
  init_disk_widget = function()
    --disk组件由上下两部分组成,上面是一个progressbar,下面是一个数字
    local disk_widget = wibox.widget {
      spacing = utils.ui.dpiSize(10),
      layout = wibox.layout.fixed.vertical
    }
    --上面是一个progressbar
    local disk_progressbar = wibox.widget {
      max_value = 100,
      value = 90,
      forced_height = utils.ui.dpiSize(12),
      forced_width = utils.ui.dpiSize(200),
      shape = utils.ui.rounded_rect(utils.ui.dpiSize(12)),
      bar_shape = utils.ui.rounded_rect(utils.ui.dpiSize(12)),
      color = '#38C364',
      background_color = '#dddddd',
      widget = wibox.widget.progressbar
    }

    disk_widget:add(disk_progressbar)

    --下面是文字+数字
    local disk_text = wibox.widget {
      text   = "硬盘剩余",
      font   = beautiful.pingFang .. '9',
      align  = "center",
      valign = "center",
      widget = wibox.widget.textbox
    }
    disk_widget:add(disk_text)

    local update_interval = 10
    local disk_idle_script = [[sh -c "df -h | grep '/dev/nvme0n1p5'"]]

    -- Periodically get disk info
    awful.widget.watch(disk_idle_script, update_interval, function(widget, stdout)
      local disk_info = stdout
      local taotal, used, available, percent = string.match(disk_info, "%S+%s+(%S+)%s+%s+(%S+)%s+(%S+)%s+(%S+)%s+%S+")
      local used_text = "Disk Used:" .. used .. ", Available:" .. available
      disk_text.text = used_text
      local value = string.sub(percent, 1, -2)
      disk_progressbar.value = tonumber(value)
    end)



    return wibox.widget {
      disk_widget,
      -- top = utils.ui.dpiSize(20),
      left = utils.ui.dpiSize(30),
      right = utils.ui.dpiSize(30),
      widget = wibox.container.margin,
    }
  end
}


return M_clocl_sys
