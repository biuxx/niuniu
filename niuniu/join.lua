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
  --返回房间里的信息
  

  return { }
end
