local gears            = require('gears')
local awful            = require('awful')
local wibox            = require('wibox')
local utils            = require("utils")
local constants = require("constants")
-- 下载图片
M_github_contributions = {
  init = function()
    local imageWidet = wibox.widget {
      resize        = true,
      forced_width  = utils.ui.dpiSize(435),
      forced_height = utils.ui.dpiSize(350),
      shape         = utils.ui.rounded_rect(utils.ui.dpiSize(5)),
      widget        = wibox.widget.imagebox
    }
    local github_contributions_widget = wibox.widget {

          wibox.widget {

            wibox.widget {
              imageWidet,
              widget  = wibox.container.margin,
              margins = utils.ui.dpiSize(15),
              valign  = 'center',
              halign  = 'center',
            },
            halign = 'center',
            valign = 'center',
            widget = wibox.container.place
          },

          -- bg     = '#00000f',
          bg     = '#ffffff',
          shape  = utils.ui.rounded_rect(utils.ui.dpiSize(20)),
          widget = wibox.container.background
        },

        M_github_contributions.upDateImage(imageWidet)
    return github_contributions_widget
  end,
  upDateImage = function(imageWidet)
    -- local image_file = os.getenv('HOME') ..'/Pictures/background.svg'                                                                          -- 本地存储图片的路劲和文件名
    local image_file = constants.contributions
    local url = ""

    --这里如果图片不存在就下载图片
    if not gears.filesystem.file_readable(image_file) then
      awful.spawn.with_shell('curl -L -o "' .. image_file .. '" "' .. url .. '"',
        function() -- 运行 curl 命令下载图片
          imageWidet:set_image(image_file)
        end)
    else
      imageWidet:set_image(image_file)
    end
  end
}
return M_github_contributions
