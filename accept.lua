local cjson = require('cjson')
local data = require('data')
local config = require('config')
local protocol = require('protocol')
local events = require('events')
local errors = require('errors')
local session = require('session')
math.randomseed(os.time())

--消息队列线程
local function thread_queue(sock, sess, proto)
  return ngx.thread.spawn(function()
    while not sess.closed do
      if next(sess.events) then
        local evt = table.remove(sess.events, 1)
        local down = cjson.encode(evt)
        print('通知消息：', down)
        sock:send(proto.encode(down))
      else
        ngx.sleep(0.01)
      end
    end
  end)
end

--开始监听
return function()
  local sock = assert(ngx.req.socket(true))
  sock:settimeout(config.tcp.timeout)
  local sess, proto = session(), protocol()
  local queue = thread_queue(sock, sess, proto)

  --客户端取消连接回调
  local ok, err = ngx.on_abort(sess.close)
  if not ok then
    ngx.log(ngx.ERR, 'register on_abort error: ', err)
    return
  end

  local timeouts = 0
  while not sess.closed do
    local json, err = proto.decode(sock)
    if not json then
      if err == 'timeout' then
        timeouts = timeouts + 1
      end
      --超时或其他错误断开连接
      if timeouts >= config.tcp.max_retry or err ~= 'timeout' then
        ngx.log(ngx.WARN, 'receive error: ', err)
        break
      end
    else
      print('上行消息：', json)
      --解析上行消息
      local ok, req = pcall(function() return cjson.decode(json) end)
      if not ok then
        break
      end
      local evt = events[req.event]
      if not evt then
        ngx.log(ngx.ERR, 'request error')
        break
      end
      if not sess.id and req.event ~= 'user.signin' and req.event ~= 'ping' then
        ngx.log(ngx.ERR, 'illegal access')
        break
      end
      --是否有数据库支持
      local ok, payload, res
      if evt.transactional then
        local dt
        ok, payload = pcall(function()
          dt = data()
          return evt.handler(sess, req.payload, dt)
        end)
        if dt then
          if not ok then
            print(payload)
          end
          dt.close(ok)
        end
      else
        ok, payload = pcall(function()
          return evt.handler(sess, req.payload)
        end)
      end
      if not ok then
        ngx.log(ngx.ERR, 'payload: ', payload)
        local idx = string.find(payload, '{', 1, true)
        local code = idx and loadstring('return ' .. string.sub(payload, idx))().error or errors.UNKNOWN
        res = { error = { code = code, message = errors[code] } }
        ngx.log(ngx.ERR, '逻辑错误: ', code, ', ', errors[code])
      else
        res = { payload = payload }
      end
      --下行消息
      res.event = req.event
      res.id = req.id
      local down = cjson.encode(res)
      print('下行消息：', down)
      sock:send(proto.encode(down))
      timeouts = 0
      print(timeouts)
    end
  end
  ngx.log(ngx.WARN, 'connection closed by server')
  sess.close()
  pcall(function()
    ngx.thread.wait(queue)
    sock:close()
  end)
end
