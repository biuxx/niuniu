local quote = ngx.quote_sql_str
local errors = require('errors')
local throw = require('throw')

return function(sess, req, data)
  if sess.id or sess.users[sess.id] then
    sess.close()
    throw(errors.SIGNIN_ALREADY)
  end
  local token = req.token

  local sql = 'SELECT id, nick, avatar, gold, new, ban FROM user WHERE token = %s'
  local user = data.queryone(sql, quote(token))
  if not user then
    sess.close()
    throw(errors.TOKEN_ERROR)
  end
  if user.ban == 1 then
    sess.close()
    throw(errors.BANNED)
  end

  if sess.users[user.id] then
    sess.close()
    throw(errors.SIGNIN_ALREADY)
  end

  sql = 'SELECT id, name FROM game'
  local games = data.query(sql)

  sql = 'UPDATE user SET online = 1, ip = %s WHERE id = %d'
  data.update(sql, quote(ngx.var.remote_addr), user.id)



  sess.id = user.id
  sess.nick = user.nick
  sess.avatar = user.avatar
  sess.gold = user.gold
  sess.users[sess.id] = sess

  --公告
  sql = 'SELECT id, notice FROM notice ORDER BY id DESC limit 1'
  local notice = data.queryone(sql)
  print(1)

  local function fun_wechat()
    sess.cast('cast.notice.update', { notice = notice.notice })
  end
  ngx.timer.at(1, fun_wechat, {})

  user.gold = user.gold / 100

  return
  {
    user = user,
    games = games
  }
end
