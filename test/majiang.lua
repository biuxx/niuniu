--扫雷测试

local cjson = require('cjson')
local protocol = require('protocol')
local before = require('test.before')
local after = require('test.after')
local http = require('resty.http')

local proto = protocol()
local sessall = {}

local function thread_queue(sock, sess, proto)
    return ngx.thread.spawn(function()
        while not sess.closed do
            local json, err = proto.decode(sock)
            if not json then
                --
                ngx.sleep(0.01)
            else
                print(sess.id .. '-下行消息：', json)
                local restable = cjson.decode(json)
                if restable.event == "majiang.create" then
                    sess.roomcode = restable.payload.code
                end

                --{"payload":{"user":{"nick":"玩家2","id":2,"new":1,"gold":9880.69,"avatar":1,"ban":0},"games":[{"name":"扫雷","id":1},{"name":"海南麻将","id":2}]},"id":1,"event":"user.signin"}
                if restable.event == "user.signin" then
                    sess.id = restable.payload.user.id
                end

                if restable.event == "majiang.start" then
                    sess.shou = restable.payload.tiles.shou
                    sess.dao = restable.payload.tiles.dao
                    sess.chu = restable.payload.tiles.chu
                    sess.hua = restable.payload.tiles.hua
                    sess.shou = restable.payload.tiles.shou
                end
                if restable.event == "majiang.playing" then
                    sess.chuable = true
                end

                if restable.event == "majiang.result" then
                    local evt = { id = 3, event = 'majiang.ready', payload = {} }
                    local json = cjson.encode(evt)
                    local req = proto.encode(json)
                    print('发送: ' .. json)
                    ngx.sleep(1)
                    sock:send(req)
                end

                --{"payload":{"player":{"gold":1003844,"id":62,"nick":"玩家ddd","idx":4,"score":0}},"id":0,"event":"majiang.join"}
                --{"payload":{"code":"67539","states":{"code":"67539","games":8,"rate":2,"room":1,"creator":2,"curgames":0}},"id":3,"event":"majiang.create"}
                if restable.event == "majiang.create" then
                    sess.idx = 1
                end
                --{"payload":{"states":{"rate":2,"code":"62143","games":8,"type":1,"room":1,"creator":2,"curgames":0},
                -- -- "code":"62143","players":[{"id":1,"nick":"玩家1","avatar":1,"gold":1003944,"idx":2,"score":0},
                -- -- {"phone":"1","id":2,"avatar":1,"saolei_gold":-5965,"ip":"59.110.43.8","pass":"92eb5ffee6ae2fec3ad71c777531578f","score":0,"code":"1","gold":988069,"name":"b","token":"0e9089d18d4f3ca2dae842157fef8a95","idx":1,"new":1,"qq":"1","nick":"玩家2","deduct":0,"online":1,"ban":0,"gameid":2,"signuptime":1481643831,"saolei_tax":0},{"id":61,"gold":1003844,"idx":3,"nick":"玩家ccc","avatar":1,"score":0}]},"id":3,"event":"majiang.join"}
                if restable.event == "majiang.join" and restable.payload.players then
                    local es = restable.payload.players
                    if es and #es > 0 then
                        for i = 1, #es do
                            if es[i].id == sess.id then
                                sess.idx = es[i].idx
                            end
                        end
                    end
                end



                --{"payload":{"tile":2,"playerid":1,"events":{},"left":85},"id":0,"event":"majiang.zhua"}
                if restable.event == "majiang.zhua" and restable.payload then
                    local es = restable.payload.events
                    print(restable.payload.playerid)
                    print(sess.id)
                    print(restable.payload.tile)
                    if restable.payload.playerid == sess.id and restable.payload.tile > 1 then
                        print('zzzzz')
                        if es and #es > 0 then
                            --todo
                            local evt = { id = 1, event = 'majiang.hu', payload = { group = es[1].events.hu } }
                            local json = cjson.encode(evt)
                            local req = proto.encode(json)
                            print('发送: ' .. req)
                            sock:send(req)
                            ngx.sleep(1)
                        else
                            local evt = { id = 1, event = 'majiang.chu', payload = { tile = restable.payload.tile } }
                            local json = cjson.encode(evt)
                            local req = proto.encode(json)
                            print('发送: ' .. req)
                            sock:send(req)
                            ngx.sleep(1)
                        end
                    end
                end

                if restable.event == "majiang.chu" and restable.payload and restable.payload.events then
                    local es = restable.payload.events
                    if es and #es > 0 then
                        for i = 1, #es do
                            if es[i].playerid == sess.id then
                                if es[i].events.hu then
                                    local evt = { id = 1, event = 'majiang.hu', payload = { group = es[i].events.hu
                                    } }
                                    local json = cjson.encode(evt)
                                    local req = proto.encode(json)
                                    sock:send(req)
                                    print('发送: ' .. req)
                                    ngx.sleep(1)
                                    break
                                end
                                if es[i].events.peng then
                                    local evt = {
                                        id = 1,
                                        event = 'majiang.peng',
                                        payload = {
                                            group = es[i].events.peng
                                        }
                                    }
                                    local json = cjson.encode(evt)
                                    local req = proto.encode(json)
                                    print('发送: ' .. req)
                                    sock:send(req)
                                    ngx.sleep(1)
                                    break
                                end
                                if es[i].events.gang then
                                    local evt = { id = 1, event = 'majiang.gang', payload = { group = es[i].events
                                    .gang[1] } }
                                    local json = cjson.encode(evt)
                                    local req = proto.encode(json)
                                    print('发送: ' .. req)
                                    sock:send(req)
                                    ngx.sleep(1)
                                    break
                                end
                                if es[i].events.chi then
                                    local evt = { id = 1, event = 'majiang.chi', payload = { group = es[i].events
                                    .chi[1] } }
                                    local json = cjson.encode(evt)
                                    local req = proto.encode(json)
                                    print('发送: ' .. req)
                                    sock:send(req)
                                    ngx.sleep(1)
                                    break
                                end
                            end
                            break
                        end
                    end
                end

                --{"payload":{"tile":22,"playerid":2,"events":[{"events":{"chi":[[20,21,22,22],[21,22,23,22]]},"playerid":1}]},"id":0,"event":"majiang.chu"}
                --如果chu里有event 对应的playerid 发送pass


                --{"payload":{"tiles":{"shou":[2,31,34,33,20,30,2,20,25,4,6,19,24],"dao":{},"chu":{}},"left":91,"master":2,
                -- -- "dice":[[1,1]]},"id":0,"event":"majiang.start"}
            end
        end
    end)
end

--不停的ping 不然等着的人会断..
local function thread_queue_ping(sock, sess, proto)
    return ngx.thread.spawn(function()
        while not sess.closed do
            local evt = { id = 1, event = 'ping', payload = {} }
            local json = cjson.encode(evt)
            local req = proto.encode(json)
            sock:send(req)
            ngx.sleep(3)
        end
    end)
end


--第一个人登录建房
local sock = before()
local httpc = http:new()
local ret, err = httpc:request_uri('http://api.weiyouba.cn/user/signin.json?name=b&pass=b')
local token = cjson.decode(ret.body).token

local sess1 = { id = 1, closed = false }
sessall[sess1.id] = sess1
thread_queue(sock, sess1, proto)
thread_queue_ping(sock, sess1, proto)
--
local evt = { id = 1, event = 'user.signin', payload = { token = token } }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
sock:send(req)

--local res, err = proto.decode(sock)
--print('接收: ' .. res)

--
local evt = { id = 2, event = 'majiang.open', payload = { id = 2 } }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
ngx.sleep(2)
sock:send(req)

--local res, err = proto.decode(sock)
--print('接收: ' .. res)

--
local evt = { id = 3, event = 'majiang.create', payload = { states = { room = 1, rate = 2 } } }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
ngx.sleep(2)
sock:send(req)

--local res, err = proto.decode(sock)
--print('接收: ' .. res)
-- {"payload":{"code":"54874","states":{"code":"54874","games":8,"rate":2,"room":1,"creator":2,"curgames":0}},"id":3,"event":"majiang.create"}
--local restable = cjson.decode(res)
--local roomcode = restable.payload.code


--第2个人登录加入
local sock2 = before()
local httpc2 = http:new()
local ret2, err2 = httpc2:request_uri('http://api.weiyouba.cn/user/signin.json?name=a&pass=a')
local token2 = cjson.decode(ret2.body).token

local sess2 = { id = 2, closed = false }
sessall[sess2.id] = sess2
thread_queue(sock2, sess2, proto)
thread_queue_ping(sock2, sess2, proto)
--
local evt2 = { id = 1, event = 'user.signin', payload = { token = token2 } }
local json2 = cjson.encode(evt2)
local req2 = proto.encode(json2)

print('发送: ' .. json2)
ngx.sleep(10)
local roomcode = sess1.roomcode
sock2:send(req2)

--local res, err = proto.decode(sock2)
--print('接收: ' .. res)

--
local evt = { id = 2, event = 'majiang.open', payload = { id = 2 } }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
ngx.sleep(2)
sock2:send(req)

--local res, err = proto.decode(sock2)
--print('接收: ' .. res)

--
local evt = { id = 3, event = 'majiang.join', payload = { code = roomcode } }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
ngx.sleep(2)
sock2:send(req)

--local res, err = proto.decode(sock)
--print('接收: ' .. res)

-----
-- 第3个人登录加入
local sock3 = before()
local httpc3 = http:new()
local ret2, err2 = httpc3:request_uri('http://api.weiyouba.cn/user/signin.json?name=c&pass=c')
local token2 = cjson.decode(ret2.body).token

local sess3 = { id = 3, closed = false }
sessall[sess3.id] = sess3
thread_queue(sock3, sess3, proto)
thread_queue_ping(sock3, sess3, proto)
--
local evt2 = { id = 1, event = 'user.signin', payload = { token = token2 } }
local json2 = cjson.encode(evt2)
local req2 = proto.encode(json2)

print('发送: ' .. json2)
ngx.sleep(2)
sock3:send(req2)

--local res, err = proto.decode(sock3)
--print('接收: ' .. res)

--
local evt = { id = 2, event = 'majiang.open', payload = { id = 2 } }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
ngx.sleep(2)
sock3:send(req)

--local res, err = proto.decode(sock3)
--print('接收: ' .. res)

--
local evt = { id = 3, event = 'majiang.join', payload = { code = roomcode } }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
ngx.sleep(2)
sock3:send(req)

--local res, err = proto.decode(sock)
--print('接收: ' .. res)

--四个人发送ready
local evt = { id = 3, event = 'majiang.ready', payload = {} }
local json = cjson.encode(evt)
local req = proto.encode(json)
print('发送: ' .. json)
ngx.sleep(1)
sock:send(req)

--第4个人登录加入
local sock4 = before()
local httpc4 = http:new()
local ret2, err2 = httpc4:request_uri('http://api.weiyouba.cn/user/signin.json?name=d&pass=d')
local token2 = cjson.decode(ret2.body).token

local sess4 = { id = 4, closed = false }
sessall[sess4.id] = sess4
thread_queue(sock4, sess4, proto)
thread_queue_ping(sock4, sess4, proto)
--
local evt2 = { id = 1, event = 'user.signin', payload = { token = token2 } }
local json2 = cjson.encode(evt2)
local req2 = proto.encode(json2)

print('发送: ' .. json2)
ngx.sleep(2)
sock4:send(req2)

--local res, err = proto.decode(sock4)
--print('接收: ' .. res)

--
local evt = { id = 2, event = 'majiang.open', payload = { id = 2 } }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
ngx.sleep(2)
sock4:send(req)

--local res, err = proto.decode(sock4)
--print('接收: ' .. res)

--
local evt = { id = 3, event = 'majiang.join', payload = { code = roomcode } }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
ngx.sleep(2)
sock4:send(req)


--四个人发送ready
local evt = { id = 3, event = 'majiang.ready', payload = {} }
local json = cjson.encode(evt)
local req = proto.encode(json)
print('发送: ' .. json)
ngx.sleep(1)
sock:send(req)

--取消ready
local evt = { id = 3, event = 'majiang.cancelready', payload = {} }
local json = cjson.encode(evt)
local req = proto.encode(json)
print('发送: ' .. json)
ngx.sleep(1)
sock:send(req)


local evt = { id = 3, event = 'majiang.ready', payload = {} }
local json = cjson.encode(evt)
local req = proto.encode(json)
ngx.sleep(1)
sock2:send(req)
ngx.sleep(1)
sock3:send(req)
ngx.sleep(1)
sock4:send(req)
ngx.sleep(1)
sock:send(req)

--四个人发送fold
local evt = { id = 3, event = 'majiang.fold', payload = { fold = 0 } }
local json = cjson.encode(evt)
local req = proto.encode(json)
print('发送: ' .. json)
ngx.sleep(3)
sock:send(req)
local evt = { id = 3, event = 'majiang.fold', payload = { fold = 1 } }
local json = cjson.encode(evt)
local req = proto.encode(json)
print('发送: ' .. json)
ngx.sleep(1)
sock2:send(req)
local evt = { id = 3, event = 'majiang.fold', payload = { fold = 2 } }
local json = cjson.encode(evt)
local req = proto.encode(json)
print('发送: ' .. json)
ngx.sleep(1)
sock3:send(req)
local evt = { id = 3, event = 'majiang.fold', payload = { fold = 5 } }
local json = cjson.encode(evt)
local req = proto.encode(json)
print('发送: ' .. json)
ngx.sleep(1)
sock4:send(req)
print('fold end')
ngx.sleep(2)

while not sess1.chuable do
    ngx.sleep(1)
end
--出牌
local evt = { id = 3, event = 'majiang.chu', payload = { tile = sess1.shou[1] } }
local json = cjson.encode(evt)
local req = proto.encode(json)
print('发送: ' .. json)
ngx.sleep(1)
sock:send(req)

--{"payload":{"tiles":{"shou":[2,31,34,33,20,30,2,20,25,4,6,19,24],"dao":{},"chu":{}},"left":91,"master":2,
-- -- "dice":[[1,1]]},"id":0,"event":"majiang.start"}

while true do
    ngx.sleep(1)
end

--local res, err = proto.decode(sock)
--print('接收: ' .. res)

--[[ 先不close
sess1.closed = true;
sess2.closed = true;
sess3.closed = true;
sess4.closed = true;
ngx.sleep(2)
]]

--[[close 退游戏
local evt = { id = 3, event = 'majiang.close', payload = {  } }
local json = cjson.encode(evt)
local req = proto.encode(json)

print('发送: ' .. json)
sock2:send(req)

local res, err = proto.decode(sock)
print('接收: ' .. res)
]]



--先不关sock 让线程一直执行
--after(sock)
--after(sock2)
--after(sock3)
--after(sock4)
