-- Grab environment

local io         = io
local table      = table
local ipairs     = ipairs
local pairs      = pairs
local naughty    = require("naughty")
local awful      = require("awful")
-- module("dock.utils")

terminal         = 'alacritty'

icon_theme       = 'WhiteSur'

all_icon_sizes   = {
  '512x512',
  '128x128',
  '64x64',
  '96x96',
  '72x72',
  '48x48',
  '36x36',
}
all_icon_types   = {
  '',
  'apps',
}
all_icon_paths   = { '/usr/share/icons/' }

icon_sizes       = {}

local mime_types = {}

--判断文件是否存在
function file_exists(filename)
  local file = io.open(filename, 'r')
  local result = (file ~= nil)
  if result then
    file:close()
  end
  return result
end

--找寻对应的icon图标地址
function lookup_icon(arg)
  local ret = arg.icon:sub(1, 1) == '/'
  if arg.icon:sub(1, 1) == '/' and (arg.icon:find('.+%.png') or arg.icon:find('.+%.xpm') or arg.icon:find('.+%.svg')) then
    -- icons with absolute path and supported (AFAICT) formats
    return arg.icon
  else
    local icon_path = {}
    local icon_theme_paths = {}
    -- 如果设置了Icon主题,则优先使用
    if icon_theme then
      for i, path in ipairs(all_icon_paths) do
        table.insert(icon_theme_paths, path .. icon_theme .. '/')
      end
      -- TODO also look in parent icon themes, as in freedesktop.org specification
    end
    table.insert(icon_theme_paths, '/usr/share/icons/awesome-icons/') -- fallback theme cf spec
    --加入默认的icon目录,hicolor
    table.insert(icon_theme_paths, '/usr/share/icons/hicolor/') -- fallback theme cf spec

    local isizes = icon_sizes
    for i, sz in ipairs(all_icon_sizes) do
      table.insert(isizes, sz)
    end

    for i, icon_theme_directory in ipairs(icon_theme_paths) do
      for j, size in ipairs(arg.icon_sizes or isizes) do
        for k, icon_type in ipairs(all_icon_types) do
          table.insert(icon_path, icon_theme_directory .. size .. '/' .. icon_type .. '/')
        end
      end
    end

    for i, directory in ipairs(icon_path) do
      if (arg.icon:find('.+%.png') or arg.icon:find('.+%.svg') or arg.icon:find('.+%.xpm')) and file_exists(directory .. arg.icon) then
        return directory .. arg.icon
      elseif file_exists(directory .. arg.icon .. '.png') then
        return directory .. arg.icon .. '.png'
      elseif file_exists(directory .. arg.icon .. '.xpm') then
        return directory .. arg.icon .. '.xpm'
      elseif file_exists(directory .. arg.icon .. '.svg') then
        return directory .. arg.icon .. '.svg'
      end
    end
  end
end

function lookup_file_icon(arg)
  load_mime_types()

  local extension = arg.filename:match('%a+$')
  local mime = mime_types[extension] or ''
  local mime_family = mime:match('^%a+') or ''

  -- possible icons in a typical gnome theme (i.e. Tango icons)
  local possible_filenames = {
    mime,
    'gnome-mime-' .. mime,
    mime_family,
    'gnome-mime-' .. mime_family,
    extension
  }

  for i, filename in ipairs(possible_filenames) do
    local icon = lookup_icon({ icon = filename, icon_sizes = (arg.icon_sizes or all_icon_sizes) })
    if icon then
      return icon
    end
  end

  -- If we don't find ad icon, then pretend is a plain text file
  return lookup_icon({ icon = 'txt', icon_sizes = arg.icon_sizes or all_icon_sizes })
end

--- Load system MIME types
-- @return A table with file extension <--> MIME type mapping
function load_mime_types()
  if #mime_types == 0 then
    for line in io.lines('/etc/mime.types') do
      if not line:find('^#') then
        local parsed = {}
        for w in line:gmatch('[^%s]+') do
          table.insert(parsed, w)
        end
        if #parsed > 1 then
          for i = 2, #parsed do
            mime_types[parsed[i]] = parsed[1]:gsub('/', '-')
          end
        end
      end
    end
  end
end

--- Parse a .desktop file
-- @param file The .desktop file
-- @param requested_icon_sizes A list of icon sizes (optional). If this list is given, it will be used as a priority list for icon sizes when looking up for icons. If you want large icons, for example, you can put '128x128' as the first item in the list.
-- @return A table with file entries.
function parse_desktop_file(arg)
  local program = { show = true, file = arg.file }
  for line in io.lines(arg.file) do
    for key, value in line:gmatch("(%w+)=(.+)") do
      --如果已经存在,则不覆盖
      if program[key] == nil then
        program[key] = value
      end
    end
  end

  -- Don't show the program if NoDisplay is true
  -- Only show the program if there is not OnlyShowIn attribute
  -- or if it's equal to 'awesome'
  if program.NoDisplay == "true" or program.OnlyShowIn ~= nil and program.OnlyShowIn ~= "awesome" then
    program.show = false
  end

  -- Look up for a icon.
  if program.Icon then
    program.icon_path = lookup_icon({ icon = program.Icon, icon_sizes = (arg.icon_sizes or all_icon_sizes) })
    if program.icon_path ~= nil and not file_exists(program.icon_path) then
      program.icon_path = nil
    end
  end

  -- Split categories into a table.
  -- if program.Categories then
  --   program.categories = {}
  --   for category in program.Categories:gfind('[^;]+') do
  --     table.insert(program.categories, category)
  --   end
  -- end

  if program.Exec then
    local cmdline = program.Exec:gsub('%%c', program.Name)
    cmdline = cmdline:gsub('%%[fmuFMU]', '')
    cmdline = cmdline:gsub('%%k', program.file)
    if program.icon_path then
      cmdline = cmdline:gsub('%%i', '--icon ' .. program.icon_path)
    else
      cmdline = cmdline:gsub('%%i', '')
    end
    if program.Terminal == "true" then
      cmdline = terminal .. ' -e ' .. cmdline
    end
    program.cmdline = cmdline
  end

  return program
end

--- Parse a directory with .desktop files
-- @param dir The directory.
-- @param icons_size, The icons sizes, optional.
-- @return A table with all .desktop entries.
function parse_desktop_files(arg)
  local programs = {}
  local files = io.popen('find ' .. arg.dir .. ' -maxdepth 1 -name "*.desktop"'):lines()
  for file in files do
    arg.file = file
    table.insert(programs, parse_desktop_file(arg))
  end
  return programs
end

--- Parse a directory files and subdirs
-- @param dir The directory.
-- @param icons_size, The icons sizes, optional.
-- @return A table with all .desktop entries.
function parse_dirs_and_files(arg)
  local files = {}
  local paths = io.popen('find ' .. arg.dir .. ' -maxdepth 1 -type d'):lines()
  for path in paths do
    if path:match("[^/]+$") then
      local file = {}
      file.filename = path:match("[^/]+$")
      file.path = path
      file.show = true
      file.icon = lookup_icon({ icon = "folder", icon_sizes = (arg.icon_sizes or all_icon_sizes) })
      table.insert(files, file)
    end
  end
  local paths = io.popen('find ' .. arg.dir .. ' -maxdepth 1 -type f'):lines()
  for path in paths do
    if not path:find("\\.desktop$") then
      local file = {}
      file.filename = path:match("[^/]+$")
      file.path = path
      file.show = true
      file.icon = lookup_file_icon({ filename = file.filename, icon_sizes = (arg.icon_sizes or all_icon_sizes) })
      table.insert(files, file)
    end
  end
  return files
end

local M = {
  parse_desktop_files = parse_desktop_files,
  lookup_icon = lookup_icon
}

return M
