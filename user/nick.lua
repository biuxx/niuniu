local quote = ngx.quote_sql_str
local errors = require('errors')
local throw = require('throw')

return function(sess, req, data)
  local nick = req.nick
  if not nick or nick == '' then
    throw(errors.NICK_EMPTY)
  end

  local sql = 'SELECT id FROM user WHERE nick = %s'
  local user = data.queryone(sql, quote(nick))
  if user then
    throw(errors.NICK_EXISTS)
  end

  sql = 'UPDATE user SET nick = %s, new = 0 WHERE id = %d'
  data.update(sql, quote(nick), sess.id)

  sess.cast('cast.user.upate', { nick = nick })
end
