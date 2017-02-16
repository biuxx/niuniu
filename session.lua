local errors = require('errors')
local throw = require('throw')

return function()
  local M =
  {
    users = require('users'),
    events = {}
  }

  M.close = function()
    if not M.id then
      M.closed = true
      return
    end
    if M.closed then
      return
    end
    if M.game then
      require(M.game.name .. '.destroy')(M)
    end

    M.users[M.id] = nil
    M.closed = true

    local data = require('data')()
    local sql = 'UPDATE user SET online = 0, gameid = 0 WHERE id = %d'
    data.update(sql, M.id)
    data.close(true)
  end

  M.cast = function(event, payload)
    M.events[#M.events + 1] = { event = event, id = 0, payload = payload }
  end


  --加入分组
  M.join = function(groupid)
    local engine = require('majiang.engine')
    engine.join(M, groupid)
  end

  --退出当前分组
  M.quit = function()
    local engine = require('majiang.engine')
    engine.quit(M)
  end

  --组内单播
  M.singlecast = function(id, evt)
    if not M.game.groupid then
      throw(errors.ILLEGAL)
    end
    local engine = require('majiang.engine')
    local members = engine.group(M.game.groupid).members
    if members[id] then
      engine.singlecast(id, evt)
    end
  end

  --组内广播
  --inclusive 是否包括本身
  M.groupcast = function(evt, inclusive)
    if not M.game.groupid then
      throw(errors.ILLEGAL)
    end
    local engine = require('majiang.engine')
    local members = engine.group(M.game.groupid).members
    for id, _ in pairs(members) do
      if inclusive or id ~= M.id then
        engine.singlecast(id, evt)
      end
    end
  end


  return M
end
