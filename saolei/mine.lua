local quote = ngx.quote_sql_str
local cjson = require('cjson')
local errors = require('errors')
local throw = require('throw')
local rooms = require('saolei.rooms')
local rate = { [5] = 2, [7] = 1.42, [10] = 1 } --雷点倍率

--踩雷
return function(sess, req, data)
  if not sess.game or sess.game.name ~= 'saolei' or not sess.game.deskid then
    sess.close()
    throw(errors.ILLEGAL)
  end
  local room = rooms[sess.game.roomid]
  if sess.gold < room.gold then
    throw(errors.GOLD_LIMIT)
  end
  local id = req.id

  local sql = 'SELECT userid, gold, minegold, n, minen, digit FROM pack WHERE id = %d AND roomid = %d AND deskid = %d AND minen < n'
  local pack = data.queryone(sql, id, sess.game.roomid, sess.game.deskid)
  if not pack then
    throw(errors.MINE_ERROR)
  end
  if pack.userid == sess.id then
    throw(errors.MINE_OWNER)
  end

  local sql = 'SELECT userid, nick, gold AS income FROM mine WHERE packid = %d'
  local mines = data.query(sql, id)
  local hits = {}
  for _, mine in ipairs(mines) do
    if math.fmod(mine.income, 10) == pack.digit then
      mine.loss = math.floor(pack.gold * rate[pack.n])
    else
      mine.loss = 0
    end
    hits[#hits + 1] = { miss = mine.loss == 0 and 1 or 0, nick = mine.nick, income = string.format('%.2f', mine.income / 100) }
  end
  for _, mine in ipairs(mines) do
    if mine.userid == sess.id then
      local ret = { miss = mine.loss == 0 and 1 or 0, income = string.format('%.2f', mine.income / 100), digit = pack.digit, loss = mine.loss == 0 and '0.00' or string.format('%.2f', -mine.loss / 100), sum = string.format('%.2f', (mine.income - mine.loss) / 100) }
      ret.hits = next(hits) and hits or cjson.empty_array
      return ret
    end
  end

  local gold, n = pack.gold - pack.minegold, pack.n - pack.minen
  local income, loss = 0, 0
  if n == 1 then
    income = gold
  else
    income = math.random(1, math.floor(gold * 2 / n))
  end
  if math.fmod(income, 10) == pack.digit then
    loss = math.floor(pack.gold * rate[pack.n])
  end

  --收益
  local mineincr, minetax, ownerincr, ownertax = 0, 0, 0, 0
  if loss == 0 then
    mineincr = math.floor(income * 0.975)
    minetax = income - mineincr
  else
    mineincr = income - loss
    ownerincr = math.floor(loss * 0.975)
    ownertax = loss - ownerincr
  end
  if ownerincr > 0 then
    sql = 'UPDATE user SET gold = gold + %d, saolei_gold = saolei_gold + %d, saolei_tax = saolei_tax + %d WHERE id = %d'
    data.update(sql, ownerincr, ownerincr, ownertax, pack.userid)
  end
  sql = 'UPDATE user SET gold = gold + %d, saolei_gold = saolei_gold + %d, saolei_tax = saolei_tax + %d WHERE id = %d AND gold = %d'
  local rown = data.update(sql, mineincr, mineincr, minetax, sess.id, sess.gold)
  if rown ~= 1 then
    throw(errors.BUSY)
  end

  sql = 'INSERT INTO mine(packid, userid, nick, gold) VALUES(%d, %d, %s, %d)'
  data.update(sql, id, sess.id, quote(sess.nick), income)

  sql = 'UPDATE pack SET minegold = minegold + %d, minen = minen + 1 WHERE id = %d AND minen = %d'
  rown = data.update(sql, income, id, pack.minen)
  if rown ~= 1 then
    throw(errors.BUSY)
  end

  --发包人金币变化
  local owner = sess.users[pack.userid]
  if owner and ownerincr > 0 then
    owner.gold = owner.gold + ownerincr
    owner.cast('cast.user.update', { gold = owner.gold / 100 })
  end

  --广播雷包变化
  local dones = {}
  for _, v in ipairs(mines) do
    dones[v.userid] = true
  end
  local desk = room.desks[sess.game.deskid]
  if n == 1 then
    local p = { id = id }
    for _, s in pairs(desk.users) do
      s.cast('cast.saolei.pack.remove', p)
    end
  else
    for _, s in pairs(desk.users) do
      local p = { id = id, minen = pack.minen + 1 }
      if s.id == sess.id then
        p.done = 1
      else
        p.done = dones[s.id] and 1 or 0
      end
      s.cast('cast.saolei.pack.update', p)
    end
  end

  sess.gold = sess.gold + mineincr
  sess.cast('cast.user.update', { gold = sess.gold / 100 })

  local ret = { miss = loss == 0 and 1 or 0, income = string.format('%.2f', income / 100), digit = pack.digit, loss = loss == 0 and '0.00' or string.format('%.2f', -loss / 100), sum = string.format('%.2f', (income - loss) / 100) }
  hits[#hits + 1] = { miss = loss == 0 and 1 or 0, nick = sess.nick, income = string.format('%.2f', income / 100) }
  ret.hits = next(hits) and hits or cjson.empty_array
  return ret
end
