local file = {}

function file.read_all(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

function file.exists(file)
  local f = io.open(file, "rb")
    if f then f:close() end
      return f ~= nil
end

function file.read_lines(file_name)
  if not file.exists(file_name) then return {} end
  local lines = {}
  for line in io.lines(file_name) do 
    lines[#lines + 1] = line
  end
  return lines
end

return file
