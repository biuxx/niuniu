local cjson = require('cjson')
local rooms = require('saolei.rooms')
local errors = require('errors')
local throw = require('throw')

--退出房间
return function(sess, req, data)
  if not sess.game or sess.game.name ~= 'saolei' or not sess.game.roomid then
    sess.close()
    throw(errors.ILLEGAL)
  end
  local room = rooms[sess.game.roomid]
  room.users[sess.id] = nil
  sess.game.roomid = nil

  local rs = {}
  for id, room in pairs(rooms) do
    rs[#rs + 1] = { id = id, name = room.name, min = room.min / 100, max = room.max / 100 }
  end
  table.sort(rs, function(a, b) return a.id < b.id end)

  return { rooms = next(rs) and rs or cjson.empty_array }
end
