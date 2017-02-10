--扫雷测试

local cjson = require('cjson')
local protocol = require('protocol')
local before = require('test.before')
local after = require('test.after')
local http = require('resty.http')

local proto = protocol()
local sock = before()

--
local httpc = http:new()
local ret, err = httpc:request_uri('http://api.weiyouba.cn/user/signin.json?name=b&pass=b')
local token = cjson.decode(ret.body).token

--
local evt = { id = 1, event = 'user.signin', payload = { token = token } }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
sock:send(req)

local res, err = proto.decode(sock)
print('接收: ' .. res)

--
local evt = { id = 2, event = 'saolei.open', payload = { id = 1 } }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
sock:send(req)

local res, err = proto.decode(sock)
print('接收: ' .. res)

--
local evt = { id = 3, event = 'saolei.enter', payload = { id = 1 } }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
sock:send(req)

local res, err = proto.decode(sock)
print('接收: ' .. res)

--
local evt = { id = 4, event = 'saolei.join', payload = { id = 1 } }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
sock:send(req)

local res, err = proto.decode(sock)
print('接收: ' .. res)

--
local packs = cjson.decode(res).payload.packs
local evt = { id = 5, event = 'saolei.mine', payload = { id = packs[#packs].id } }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
sock:send(req)

local res, err = proto.decode(sock)
print('接收: ' .. res)

--
local evt = { id = 6, event = 'saolei.quit' }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
sock:send(req)

local res, err = proto.decode(sock)
print('接收: ' .. res)

--
local evt = { id = 7, event = 'saolei.exit' }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
sock:send(req)

local res, err = proto.decode(sock)
print('接收: ' .. res)

ngx.sleep(2)

after(sock)
