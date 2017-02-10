local bit = require('bit')
local lshift = bit.lshift
local rshift = bit.rshift
local bor = bit.bor
local band = bit.band

--将字符串中从i起的4个字节转为int值
local function int(s, i)
  i = i or 1
  local b1 = lshift(s:byte(i), 24)
  local b2 = lshift(s:byte(i + 1), 16)
  local b3 = lshift(s:byte(i + 2), 8)
  local b4 = s:byte(i + 3)
  return bor(b1, b2, b3, b4)
end

--将int值转为4个字节
local function str(i)
  local b1 = band(rshift(i, 24), 0xff)
  local b2 = band(rshift(i, 16), 0xff)
  local b3 = band(rshift(i, 8), 0xff)
  local b4 = band(i, 0xff)
  return string.char(b1, b2, b3, b4)
end

return function()
  local M =
  {
    bytes = '',
    readn = 0,
    len = -1,
  }
  --长度头+JSON的消息解析
  M.decode = function(sock)
    --数据头未读满
    if M.readn < 4 then
      local head, err, part = sock:receive(4 - M.readn)
      if part then
        M.bytes = M.bytes .. part
        M.readn = M.readn + part:len()
      end
      if not head then
        return nil, err
      else
        M.bytes = M.bytes .. head
        M.readn = M.readn + head:len()
        M.len = int(M.bytes)
      end
    end
    if M.readn >= 4 then
      if M.len <= 0 or M.len > 8192 then
        return nil, 'illegal'
      end
      local body, err, part = sock:receive(M.len - M.readn + 4)
      if part then
        M.bytes = M.bytes .. part
        M.readn = M.readn + part:len()
      end
      if not body then
        return nil, err
      else
        M.bytes = M.bytes .. body
        M.readn = M.readn + body:len()
        local bs = M.bytes
        M.bytes = ''
        M.readn = 0
        M.len = -1
        return bs:sub(5)
      end
    end
  end

  --长度头+JSON的消息生成
  M.encode = function(json)
    return str(json:len()) .. json
  end

  return M
end
