local users = require('users')

return function(args)
  local n = 0
  for k, v in pairs(users) do
    n = n + 1
  end
  return { n = n }
end
