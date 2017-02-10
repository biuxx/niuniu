local users = require('users')

return function(args)
  local id, gold = args.id, args.gold

  local sess = users[id]
  if sess then
    sess.gold = sess.gold + gold
    sess.cast('cast.user.update', { gold = sess.gold })
  end

  return {}
end
