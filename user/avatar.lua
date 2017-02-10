local errors = require('errors')
local throw = require('throw')

return function(sess, req, data)
  local avatar = req.avatar
  if not avatar then
    throw(errors.AVATAR_EMPTY)
  end

  local sql = 'UPDATE user SET avatar = %d WHERE id = %d'
  data.update(sql, avatar, sess.id)

  sess.cast('cast.user.upate', { avatar = avatar })
end
