return
{
  tcp =
  {
    timeout = 30000,
    max_retry = 5,
  },
  mysql =
  {
    timeout = 3000,
    keepalive = 6000,
    poolsize = 64,
    datasource =
    {
      host = '127.0.0.1',
      port = 3306,
      database = 'tau',
      user = 'tau',
      password = 'tau'
    }
  }
}
