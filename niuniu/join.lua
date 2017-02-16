local rooms = require('niuniu.rooms')
local errors = require('errors')
local throw = require('throw')
local cjson = require('cjson')

return function(sess, req, data)

  if not sess.game or sess.game.name ~= 'niuniu' or not sess.game.roomid then
    sess.close()
    throw(errors.ILLEGAL)
  end
  --roomid
  local room = rooms[sess.game.roomid]
  if not room then
    sess.close()
    throw(errors.ILLEGAL)
  end

  if room.usern and room.usern>=100 then
    throw(errors.PLAYER_ROOM_FULL)
  end
  --获取房间里的信息



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

  --需要返回的房间信息
  --房间内状态{状态码，倒计时，}
  --房间内人数
  --抢桩列表
  --筹码区的数量（自己的和其他玩家的，四组）
  return { }
end
