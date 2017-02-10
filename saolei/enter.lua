local cjson = require('cjson')
local errors = require('errors')
local throw = require('throw')
local rooms = require('saolei.rooms')

--进入房间
return function(sess, req, data)
  local id = req.id
  if not sess.game or sess.game.name ~= 'saolei' or not rooms[id] then
    sess.close()
    throw(errors.ILLEGAL)
  end

  --(可能是客户端连点)的补丁
  if sess.game.roomid then
    local room = rooms[sess.game.roomid]
    room.users[sess.id] = nil
  end

  local room = rooms[id]

  local ds = {}
  for id, desk in pairs(room.desks) do
    ds[#ds + 1] = { id = id, name = desk.name, gold = room.gold / 100, usern = desk.usern }
  end
  table.sort(ds, function(a, b) return a.id < b.id end)

  room.users[sess.id] = sess
  sess.game.roomid = id

  return { desks = next(ds) and ds or cjson.empty_array }
end
