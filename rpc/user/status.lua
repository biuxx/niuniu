local users = require('users')

return function(args)
  local id = args.id

  local sess = users[id]

  return { online = sess and true or false, game = sess and (sess.game and sess.game.name or nil) or nil}
end
