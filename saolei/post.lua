local quote = ngx.quote_sql_str
local rooms = require('saolei.rooms')
local errors = require('errors')
local throw = require('throw')

--发雷包
return function(sess, req, data)
  if not sess.game or sess.game.name ~= 'saolei' or not sess.game.deskid then
    sess.close()
    throw(errors.ILLEGAL)
  end
  local gold, n, digit = math.floor(req.gold * 100), math.floor(req.n), math.floor(req.digit)
  if n ~= 5 and n ~= 7 and n ~= 10 then
    sess.close()
    throw(errors.ILLEGAL)
  end
  if sess.gold < gold then
    throw(errors.GOLD_LIMIT)
  end
  local room = rooms[sess.game.roomid]
  if gold < room.min or gold > room.max then
    throw(errors.PACK_LIMIT)
  end

  local sql = 'INSERT INTO pack(roomid, deskid, userid, nick, gold, n, digit) VALUES(%d, %d, %d, %s, %d, %d, %d)'
  local id = data.insert(sql, sess.game.roomid, sess.game.deskid, sess.id, quote(sess.nick), gold, n, digit)

  sql = 'UPDATE user SET gold = gold - %d, saolei_gold = saolei_gold - %d WHERE id = %d AND gold = %d'
  local rown = data.update(sql, gold, gold, sess.id, sess.gold)
  if rown ~= 1 then
    throw(errors.BUSY)
  end

  --只对本桌用户广播
  local desk = room.desks[sess.game.deskid]
  for _, s in pairs(desk.users) do
    local p = { id = id, gold = gold / 100, n = n, digit = digit, minen = 0, owner = s.id == sess.id and 1 or 0, done = 0 }
    s.cast('cast.saolei.pack.new', p)
  end

  sess.gold = sess.gold - gold
  sess.cast('cast.user.update', { gold = sess.gold / 100 })
end
