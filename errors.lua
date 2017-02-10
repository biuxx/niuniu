return
{
  UNKNOWN = 1,
  ILLEGAL = 2,
  BUSY = 3,
  TOKEN_ERROR = 4,
  SIGNIN_ALREADY = 5,
  BANNED = 6,

  --统一错误
  GOLD_LIMIT = 1001,
  NICK_EMPTY = 1002,
  NICK_EXISTS = 1003,
  AVATAR_EMPTY = 1004,

  --扫雷错误
  PACK_LIMIT = 2001,
  MINE_ERROR = 2002,
  MINE_OWNER = 2003,

  --麻将错误
  PLAYER_MONEY_NOT_ENOUGH = 3001, --门票不足
  PLAYER_OUT_DESK = 3002, --游戏未开始
  PLAYER_INVAILD_CODE = 3003, --房间码错误
  PLAYER_MSG_FREQUENTLY = 3004, --请求太频繁
  PLAYER_PAIJV_NOT_END = 3005, --有未结束的牌局
  PLAYER_DESK_FULL = 3006, --桌子满了
  PLAYER_ROOM_FULL = 3007, --房间满了
  DESK_OUT_OF_LIMIT = 3008, --房间局数达到上限


  [1] = '未知错误',
  [2] = '不合法的请求',
  [3] = '服务器繁忙',
  [4] = '无效的令牌',
  [5] = '重复登录',
  [6] = '已被封禁',

  [1001] = '金币不足',
  [1002] = '昵称不能为空',
  [1003] = '昵称已存在',
  [1004] = '头像不能为空',

  [2001] = '雷包总额不符',
  [2002] = '雷包不存在',
  [2003] = '不能踩自己的雷包',

  [3001] = '门票不足',
  [3002] = '游戏未开始',
  [3003] = '房间码错误',
  [3004] = '请求太频繁',
  [3005] = '有未结束的牌局',
  [3006] = '桌子满了',
  [3007] = '房间满了',
  [3008] = '房间局数达到上限',

}
