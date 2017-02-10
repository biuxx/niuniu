local cjson = require('cjson')
local rooms = require('saolei.rooms')

return function(args)
  local rs = {}
  for roomid, room in pairs(rooms) do
    local r = { id = roomid, name = room.name }
    local rus = {}
    for userid, sess in pairs(room.users) do
      rus[#rus + 1] = userid
    end
    r.users = next(rus) and rus or cjson.empty_array

    local ds = {}
    for deskid, desk in pairs(room.desks) do
      local d = { id = deskid, name = desk.name }
      local dus = {}
      for userid, sess in pairs(desk.users) do
        dus[#dus + 1] = userid
      end
      d.users = next(dus) and dus or cjson.empty_array
      ds[#ds + 1] = d
    end
    r.desks = next(ds) and ds or cjson.empty_array

    rs[#rs + 1] = r
  end
  return { rooms = rs }
end
