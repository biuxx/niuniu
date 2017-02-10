local users = require('users')
local data = require('data')
return function(args)

  --读最新的一条sql
  local dt = data()
  local sql = 'SELECT id, notice FROM notice ORDER BY id DESC limit 1'
  local notice = dt.queryone(sql)
  dt.close()
  for k, v in pairs(users) do
    v.cast('cast.notice.update', { notice = notice.notice })
  end
  return {}
end
