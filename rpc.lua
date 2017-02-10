local cjson = require('cjson')
local protocol = require('protocol')

return function()
  local sock = assert(ngx.req.socket(true))
  sock:settimeout(6000)
  local proto = protocol()
  local json, err = proto.decode(sock)
  if json then
    local req = cjson.decode(json)
    local handler = require('rpc.' .. req.name)
    local res = handler(req.args)
    sock:send(proto.encode(cjson.encode(res)))
  end
  pcall(function() sock:close() end)
end
