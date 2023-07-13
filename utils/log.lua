local M_log = {
  write_log = function(message)
    --如果不是string类型就转换成string类型
    --如果是table类型就转换成string类型

    if type(message) ~= "string" then
      message = tostring(message)
    end


    local file = io.open(os.getenv("HOME") .. "/.config/awesome/debug.log", "a")
    file:write(message .. "\n")
    file:close()
  end
}
