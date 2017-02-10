local cjson = require('cjson')
local rooms = require('saolei.rooms')
local errors = require('errors')
local throw = require('throw')

--退出桌子
return function(sess, req)
  if not sess.game or sess.game.name ~= 'saolei' or not sess.game.deskid then
    sess.close()
    throw(errors.ILLEGAL)
  end
  local room = rooms[sess.game.roomid]
  local desk = room.desks[sess.game.deskid]
  desk.users[sess.id] = nil
  desk.usern = desk.usern - 1
  for _, s in pairs(room.users) do
    s.cast('cast.saolei.desk.update', { id = sess.game.deskid, usern = desk.usern})
  end
  room.users[sess.id] = sess
  sess.game.deskid = nil

  local ds = {}
  for id, desk in ipairs(room.desks) do
    ds[#ds + 1] = { id = id, name = desk.name, gold = room.gold / 100, usern = desk.usern }
  end
  table.sort(ds, function(a, b) return a.id < b.id end)

  return { desks = next(ds) and ds or cjson.empty_array }
end
