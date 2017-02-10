return function()
  local sock = ngx.socket.tcp()
  sock:settimeout(60000)
  local ok, err = sock:connect('59.110.43.8', 8081)
  if not ok then
    return nil, err
  end
  return sock
end
