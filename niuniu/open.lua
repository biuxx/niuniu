local cjson = require('cjson')
local rooms = require('niuniu.rooms')

--房间列表
return function(sess, req, data)
  local id = req.id --

  local sql = 'UPDATE user SET gameid = %d WHERE id = %d'
  data.update(sql, id, sess.id)

  sess.game = { name = 'niuniu' }

  local rs = {}
  for id, room in ipairs(rooms) do
    rs[#rs + 1] = { id = id, name = room.name, usern= room.usern }
  end
  table.sort(rs, function(a, b) return a.id < b.id end)

  return { rooms = next(rs) and rs or cjson.empty_array }
end
