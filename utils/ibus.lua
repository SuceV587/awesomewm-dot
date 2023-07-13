local awful = require("awful")

return function()
  local current = nil
  local ibus = "ibus engine"
  local engines = { "Bamboo", "BambooUs" }

  local _toggle = function(cur)
    local next = engines[1]
    if cur == engines[1] then
      next = engines[2]
    end

    awful.util.spawn(ibus .. " " .. next)

    current = next
  end

  local toggle = function()
    if current == nil then
      awful.spawn.easy_async_with_shell(ibus, function(cur)
        _toggle(cur)
      end)
    else
      _toggle(current)
    end
  end

  return { toggle = toggle }
end
