local M = {}

-- http://lua-users.org/wiki/CopyTable
M.deepcopy = function(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == "table" then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[M.deepcopy(orig_key)] = M.deepcopy(orig_value)
    end
    setmetatable(copy, M.deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

M.range = function(from, to, step)
  local t = {}
  step = step or 1

  for i = from, to, step do
    t[#t + 1] = i
  end

  return t
end

M.tbl_override = function(t1, t2)
  local merged = M.deepcopy(t1)

  for k, v in pairs(t2) do
    if type(v) == "table" then
      merged[k] = M.tbl_override(merged[k], v)
    else
      merged[k] = v
    end
  end

  return merged
end

M.dump = function(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then
        k = '"' .. k .. '"'
      end
      s = s .. "[" .. k .. "] = " .. M.dump(v) .. ","
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

M.bind = function(f, args)
  return function()
    if args then
      return f(table.unpack(args))
    end
    return f()
  end
end

return M
