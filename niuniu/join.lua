local rooms = require('niuniu.rooms')
local errors = require('errors')
local throw = require('throw')
local cjson = require('cjson')

--加入桌子
return function(sess, req, data)
  local id = req.id

  if not sess.game or sess.game.name ~= 'saolei' or not sess.game.roomid then
    sess.close()
    throw(errors.ILLEGAL)
  end
  local room = rooms[sess.game.roomid]
  local desk = room.desks[id]
  if not desk then
    sess.close()
    throw(errors.ILLEGAL)
  end

  if desk.usern and desk.usern>=100 then
    throw(errors.PLAYER_DESK_FULL)
  end

  local sql = 'SELECT id, userid, gold, n, digit, minen FROM pack WHERE roomid = %d AND deskid = %d AND minen < n'
  local packs = data.query(sql, sess.game.roomid, id)

  sql = 'SELECT gold FROM mine WHERE packid = %d AND userid = %d'
  for _, pack in ipairs(packs) do
    local mine = data.queryone(sql, pack.id, sess.id)
    pack.owner = pack.userid == sess.id and 1 or 0
    pack.done = mine and 1 or 0
    pack.gold = pack.gold / 100
    pack.userid = nil
  end

  --对房间用户广播人数变化
  room.users[sess.id] = nil
  --补丁 客户端会多次重复发这个而不quit
  if not desk.users[sess.id] then
    desk.usern = desk.usern + 1
  end
  desk.users[sess.id] = sess

  sess.game.deskid = id
  for _, s in pairs(room.users) do
    s.cast('cast.saolei.desk.update', { id = id, usern = desk.usern })
  end

  return { packs = next(packs) and packs or cjson.empty_array }
end
