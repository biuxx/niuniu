local cjson = require('cjson')
local mysql = require('resty.mysql')
local config = require('config')
local errors = require('errors')
local throw = require('throw')

return function()
  local M = {}

  local function format(sql, ...)
    ngx.log(ngx.NOTICE, sql)
    local s = string.format(sql, ...)
    return s
  end

  local function query(my, sql)
    local ok, err = my:send_query(sql)
    if not ok then
      ngx.log(ngx.ERR, 'failed to send query: ', err)
      throw(errors.UNKNOWN)
    end
    local full, res, err = {}, nil, 'again'
    while err == 'again' do
      res, err = my:read_result()
      if not res then
        ngx.log(ngx.ERR, 'failed to read result: ', err)
        throw(errors.UNKNOWN)
      end
      full[#full + 1] = res
    end
    return #full == 1 and full[1] or full
  end

  local my, err = mysql:new()
  if not my then
    ngx.log(ngx.ERR, 'failed to new mysql: ', err)
    throw(errors.UNKNOWN)
  end
  my:set_timeout(config.mysql.timeout)
  local ok, err = my:connect(config.mysql.datasource)
  if not ok then
    ngx.log(ngx.ERR, 'failed to connect to mysql: ', err)
    throw(errors.UNKNOWN)
  end
  query(my, 'START TRANSACTION')

  M.close = function(commit)
    if commit then
      query(my, 'COMMIT')
    else
      query(my, 'ROLLBACK')
    end
    my:set_keepalive(config.mysql.keepalive, config.mysql.poolsize)
  end

  M.queryone = function(sql, ...)
    local s = format(sql, ...)
    return query(my, s)[1]
  end

  M.query = function(sql, ...)
    local s = format(sql, ...)
    return query(my, s)
  end

  M.update = function(sql, ...)
    local s = format(sql, ...)
    return query(my, s).affected_rows
  end

  M.insert = function(sql, ...)
    local s = format(sql, ...)
    return query(my, s).insert_id
  end

  M.updates = function(sql, ps, each)
    ngx.log(ngx.NOTICE, sql)
    ngx.log(ngx.NOTICE, cjson.encode(ps))
    query(my, "PREPARE data_updates FROM '" .. sql .. "'")
    for _, v in ipairs(ps) do
      local sets, us = {}, {}
      for i, vv in ipairs(v) do
        sets[#sets + 1] = 'SET @p' .. i .. ' = ' .. vv .. ';'
        us[#us + 1] = '@p' .. i
      end
      query(my, table.concat(sets, ''))
      local res = query(my, 'EXECUTE data_updates USING ' .. table.concat(us, ','))
      if each and res.affected_rows < 1 then
        ngx.log(ngx.ERR, 'affected_rows less than 1')
        throw(errors.UNKNOWN)
      end
    end
    query(my, 'DEALLOCATE PREPARE data_updates')
  end

  M.inserts = function(sql, ps)
    ngx.log(ngx.NOTICE, sql)
    ngx.log(ngx.NOTICE, cjson.encode(ps))
    local ids = {}
    query(my, "PREPARE data_inserts FROM '" .. sql .. "'")
    for _, v in ipairs(ps) do
      local sets, us = {}, {}
      for i, vv in ipairs(v) do
        sets[#sets + 1] = 'SET @p' .. i .. ' = ' .. vv .. ';'
        us[#us + 1] = '@p' .. i
      end
      query(my, table.concat(sets, ''))
      local res = query(my, 'EXECUTE data_inserts USING ' .. table.concat(us, ','))
      ids[#ids + 1] = res.insert_id
    end
    query(my, 'DEALLOCATE PREPARE data_inserts')
    return ids
  end

  return M
end
