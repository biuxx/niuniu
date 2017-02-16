local M =
{
  sessions = {}, -- 玩家信息
  desks = {}, -- 桌子信息
  cache = {}, -- 朋友场意外退出时记录房间id,用于再登陆时强连
  quit = {}, -- 练习场比赛状态下退出
}