local cjson = require('cjson')
local protocol = require('protocol')

local proto = protocol()

local sock = ngx.socket.tcp()
sock:settimeout(3000)
local ok, err = sock:connect('59.110.43.8', 2020)

local req = { name = 'saolei.rooms' }
local json = cjson.encode(req)
local req = proto.encode(json)

print('发送: ' .. json)
sock:send(req)

local res, err = proto.decode(sock)
print('接收: ' .. res)

sock:close()
