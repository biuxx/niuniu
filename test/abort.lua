--意外断开测试

local cjson = require('cjson')
local protocol = require('protocol')
local before = require('test.before')
local after = require('test.after')
local http = require('resty.http')

local proto = protocol()
local sock = before()

--
local httpc = http:new()
local ret, err = httpc:request_uri('http://api.weiyouba.cn/user/signin.json?name=a&pass=a')
local token = cjson.decode(ret.body).token

--
local evt = { id = 1, event = 'user.signin', payload = { token = token } }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
sock:send(req)

ngx.exit(500)
