--常用软件有哪些
local dosktop_util       = require("widgets.dockCenter.utils.desktop")
local naughty            = require("naughty")

local usal_client_config = {
  'QQ',
  'DingTalk',
  'Microsoft Edge', --'microsift'
  'Visual Studio Code',
  'Alacritty',
  'qqmusic',
  'Bluetooth Manager',
  'org.gnome.Nautilus',
  'Google Chrome',
  'Oracle VM VirtualBox',
  'Spotify',
  'NxShell',
  'Files'
}

local M                  = {
  get_usual_client = function(arg)
    local config = arg or {}
    local usual_client = {}
    local all_menu_dirs = { '/usr/share/applications/' }
    for i, dir in ipairs(config.menu_dirs or all_menu_dirs) do
      local entries = dosktop_util.parse_desktop_files({ dir = dir })
      for j, program in ipairs(entries) do
        --如果programe在usal_client_config中,则插入到usual_client中
        for k, v in ipairs(usal_client_config) do
          if program.Name == v then
            program.show = true
            table.insert(usual_client, program)
          end
        end
      end
    end
    return usual_client
  end
}


return M
