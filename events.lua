return
{
  ['ping'] = { handler = require('ping'), transactional = false },
  --大厅
  ['user.signin'] = { handler = require('user.signin'), transactional = true },
  ['user.nick'] = { handler = require('user.nick'), transactional = true },
  ['user.avatar'] = { handler = require('user.avatar'), transactional = true },
  --扫雷
  ['saolei.open'] = { handler = require('saolei.open'), transactional = true },
  ['saolei.enter'] = { handler = require('saolei.enter'), transactional = false },
  ['saolei.join'] = { handler = require('saolei.join'), transactional = true },
  ['saolei.post'] = { handler = require('saolei.post'), transactional = true },
  ['saolei.mine'] = { handler = require('saolei.mine'), transactional = true },
  ['saolei.quit'] = { handler = require('saolei.quit'), transactional = false },
  ['saolei.exit'] = { handler = require('saolei.exit'), transactional = false },
  ['saolei.close'] = { handler = require('saolei.close'), transactional = true },
  --麻将
  ['majiang.open'] = { handler = require('majiang.open'), transactional = true },
  ['majiang.close'] = { handler = require('majiang.close'), transactional = true },

  ['majiang.load'] = { handler = require('majiang.handler.load'), transactional = true },
  ['majiang.pass'] = { handler = require('majiang.handler.pass'), transactional = false },
  ['majiang.chu'] = { handler = require('majiang.handler.chu'), transactional = false },
  ['majiang.chi'] = { handler = require('majiang.handler.chi'), transactional = false },
  ['majiang.peng'] = { handler = require('majiang.handler.peng'), transactional = false },
  ['majiang.gang'] = { handler = require('majiang.handler.gang'), transactional = false },
  ['majiang.hu'] = { handler = require('majiang.handler.hu'), transactional = false },
  ['majiang.fold'] = { handler = require('majiang.handler.fold'), transactional = true },
  ['majiang.create'] = { handler = require('majiang.handler.create'), transactional = true },
  ['majiang.join'] = { handler = require('majiang.handler.join'), transactional = true },
  ['majiang.ready'] = { handler = require('majiang.handler.ready'), transactional = true },
  ['majiang.back'] = { handler = require('majiang.handler.back'), transactional = true },
  ['majiang.quit'] = { handler = require('majiang.handler.quit'), transactional = true },
  ['majiang.dismiss'] = { handler = require('majiang.handler.dismiss'), transactional = false },
  ['majiang.agree'] = { handler = require('majiang.handler.agree'), transactional = false },
  ['majiang.apply'] = { handler = require('majiang.handler.apply'), transactional = false },
  ['majiang.newgift'] = { handler = require('majiang.handler.newgift'), transactional = true },
  ['majiang.syncinfo'] = { handler = require('majiang.handler.syncinfo'), transactional = true },
  ['majiang.check'] = { handler = require('majiang.handler.check'), transactional = true },
  ['majiang.auto'] = { handler = require('majiang.handler.auto'), transactional = true },
  ['majiang.match'] = { handler = require('majiang.handler.match'), transactional = true },

  --取消准备
  ['majiang.cancelready'] = { handler = require('majiang.handler.cancelready'), transactional = true },
}
