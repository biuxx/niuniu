return function(sess, req, data)
  sess.game = nil
  local sql = 'UPDATE user SET gameid = 0 WHERE id = %d'
  data.update(sql, sess.id)
end
