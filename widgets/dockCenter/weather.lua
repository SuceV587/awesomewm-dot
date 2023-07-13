local wibox           = require("wibox")
local naughty         = require("naughty")
local gears           = require("gears")
local utils           = require("utils")
local beautiful       = require("beautiful")
local awful           = require("awful")
local constants       = require("constants")

M_dock_center_weather = {
  timeout           = function(args)
    return args.timeout or (60 * 15)
  end,
  init              = function()
    --添加组件
    local args = {
      APPID = constants.weather_app_id,
      city_id = constants.weather_city_id,
      city_name = constants.weather_city_name,
      timeout = 60 * 15, -- 15 min
    }
    local widget = M_dock_center_weather:make_widget_wrap(args)
    M_dock_center_weather.loopWeather(args)
    return widget
  end,
  --curl -s 'https://api.qweather.com/v7/weather/now?location=1815577&key=5ca9c851a9d44819961749d9909e4f3d'
  fetchApi          = function(args)
    local callback = function()
      local APPID        = args.APPID        -- mandatory
      local city_id      = args.city_id or 0 -- placeholder
      local current_call = args.current_call or
          "curl  -L -X GET --compressed 'https://devapi.qweather.com/v7/weather/7d?location=%s&key=%s' "

      local cmd          = string.format(current_call, city_id, APPID)
      awful.spawn.easy_async(cmd,
        function(f)
          local weather_now, _, err = utils.json.decode(f, 1, nil)
          if not err and type(weather_now) == "table" and tonumber(weather_now["code"]) == 200 then
            M_dock_center_weather.update_widget(weather_now["daily"])
          end
        end)
    end

    return callback
  end,
  loopWeather       = function(args)
    utils.run.newtimer("weather-fetch", M_dock_center_weather.timeout(args), M_dock_center_weather.fetchApi(args), false,true)
  end,
  make_widget_wrap  = function(args)
    local widget_bg = wibox.widget {
      widget  = wibox.container.margin,
      margins = utils.ui.dpiSize(15)
    }
    --内容
    local content_widget = wibox.layout.fixed.vertical()
    --为content_widget添加间距
    content_widget.spacing = utils.ui.dpiSize(13)

    --上面部分是今天的天气.分别放在左边和右边
    local today_widget = wibox.layout.flex.horizontal()
    -- 下面部分是未来几天的天气
    future_widget = wibox.layout.flex.horizontal()
    future_widget.spacing = utils.ui.dpiSize(24)
    --轮询未来6天的天气
    -- M_dock_center_weather.loopFutureWeather(future_widget)

    --今天的气温和位置
    local today_left_widget = wibox.layout.fixed.vertical()
    today_left_widget.spacing = utils.ui.dpiSize(3)

    --上面是位置
    today_location_widget = wibox.widget {
      text   = args.city_name or "北京",
      font   = beautiful.jetBrains .. 9,
      widget = wibox.widget.textbox
    }

    today_left_widget:add(today_location_widget)
    --今天的天气图标
    local today_right_widget = wibox.layout.fixed.vertical()
    today_icon_widget        = wibox.widget {
      image         = beautiful.weather_icon,
      resize        = true,
      forced_width  = utils.ui.dpiSize(28),
      forced_height = utils.ui.dpiSize(28),
      widget        = wibox.widget.imagebox
    }
    today_left_widget:add(today_icon_widget)

    --今天的天气描述
    today_desc_widget         = wibox.widget {
      text   = '晴',
      font   = beautiful.jetBrains .. 15,
      widget = wibox.widget.textbox
    }
    --最高气温和最低气温
    today_temp_min_max_widget = wibox.widget {
      text   = '20° ~ 30°',
      font   = beautiful.jetBrains .. 12,
      widget = wibox.widget.textbox
    }
    --添加到右边
    today_right_widget:add(today_desc_widget)
    today_right_widget:add(today_temp_min_max_widget)

    --添加到今天的天气
    today_widget:add(today_left_widget)
    today_widget:add({ nil })
    today_widget:add(today_right_widget)
    content_widget:add(today_widget)
    content_widget:add(future_widget)

    widget_bg:set_widget(content_widget)

    return wibox.widget {
      wibox.widget {
        widget_bg,
        halign = 'center',
        valign = 'center',
        widget = wibox.container.place
      },
      bg     = '#15428099',
      widget = wibox.container.background,
      shape  = utils.ui.rounded_rect(utils.ui.dpiSize(20)),
    }
  end,
  loopFutureWeather = function(future_widget, data)
    local initData = {
      { fxDate = '2023-05-01', tempMax = '20', tempMin = '10', iconDay = '100', textDay = '晴' },
      { fxDate = '2023-05-02', tempMax = '30', tempMin = '12', iconDay = '100', textDay = '晴' },
      { fxDate = '2023-05-03', tempMax = '30', tempMin = '12', iconDay = '100', textDay = '晴' },
      { fxDate = '2023-05-03', tempMax = '30', tempMin = '12', iconDay = '100', textDay = '晴' },
      { fxDate = '2023-05-03', tempMax = '30', tempMin = '12', iconDay = '100', textDay = '晴' },
      { fxDate = '2023-05-03', tempMax = '30', tempMin = '12', iconDay = '100', textDay = '晴' },
    }
    data = data or initData

    --先把future_widget清空
    future_widget:reset()
    --循环initData,添加到future_widget
    for i, v in ipairs(data) do
      local future_item_widget   = wibox.layout.fixed.vertical()
      future_item_widget.spacing = utils.ui.dpiSize(3)

      --年月日格式为月-日
      v.fxDate                   = string.sub(v.fxDate, 6, 10)
      local future_item_date     = wibox.widget {
        text   = v.fxDate,
        font   = beautiful.jetBrains .. 9,
        widget = wibox.widget.textbox
      }
      --天气图标
      local icons                = constants.wallpapers .. '/icons/' .. v.iconDay .. ".svg"
      --设置天气图标大小为20x20
      local future_item_icon     = wibox.widget {
        image         = icons,
        resize        = true,
        forced_width  = utils.ui.dpiSize(20),
        forced_height = utils.ui.dpiSize(20),
        widget        = wibox.widget.imagebox
      }
      --最高气温和最低气温
      local future_item_temp     = wibox.widget {
        text   = v.tempMin .. '~' .. v.tempMax .. '°',
        font   = beautiful.jetBrains .. 9,
        widget = wibox.widget.textbox
      }
      future_item_widget:add(future_item_date)
      future_item_widget:add(future_item_icon)
      future_item_widget:add(future_item_temp)


      future_widget:add(future_item_widget)
    end
  end,
  update_widget     = function(datas)
    --取datas的第一天的数据
    local today_data = datas[1]
    --更新今天的天气
    today_desc_widget:set_text(today_data.textDay)
    today_temp_min_max_widget:set_text(today_data.tempMin .. '° ~ ' .. today_data.tempMax .. '°')
    today_icon_widget:set_image(constants.wallpapers .. '/icons/' .. today_data.iconDay .. '.svg')

    --取datas里面的后6天的数据
    --更新未来6天的天气
    local future_datas = {}
    for i = 2, 7 do
      future_datas[i - 1] = datas[i]
    end

    M_dock_center_weather.loopFutureWeather(future_widget, future_datas)
  end
}


return M_dock_center_weather
