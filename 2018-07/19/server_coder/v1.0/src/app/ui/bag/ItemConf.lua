local ITEM = {}

ITEM[100000] = {
	name = "世界杯冠军头像框",
	content = "2018年世界杯活动第一名排行奖励。",
	type = 201,-- 101福袋 102宝箱 201头像框 202装扮 203进场特效
	functype = 2,-- 1消耗品 2装饰品
	img = "headframe/100000.png",
}

ITEM[100001] = {
	name = "世界杯亚军头像框",
	content = "2018年世界杯活动第二名排行奖励。",
	type = 201,
	functype = 2,
	img = "headframe/100001.png",
}

ITEM[100002] = {
  name = "世界杯季军头像框",
  content = "2018年世界杯活动第三名排行奖励。",
  type = 201,
  functype = 2,
  img = "headframe/100002.png",
}

ITEM[100003] = {
  name = "世界杯活动头像框",
  content = "2018年世界杯活动第4-10名排行奖励。",
  type = 201,
  functype = 2,
  img = "headframe/100003.png",
}


ItemConf = class("ItemConf")

function ItemConf:getItemData(itemid)
	return ITEM[itemid]
end