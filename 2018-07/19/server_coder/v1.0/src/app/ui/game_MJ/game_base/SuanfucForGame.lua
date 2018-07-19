local SuanfucForGame = class("SuanfucForGame")

-- enum ENPokerType
-- {
-- 	EN_POKER_TYPE_UNKONWN			= 0; // 未知
-- 	EN_POKER_TYPE_SINGLE_CARD		= 1; // 单牌
-- 	EN_POKER_TYPE_PAIR				= 2; // 对子
-- 	EN_POKER_TYPE_TRIPLE			= 3; // 三不带
-- 	EN_POKER_TYPE_TRIPLE_WITH_ONE	= 4; // 三带一
-- 	EN_POKER_TYPE_TRIPLE_WITH_TWO	= 5; // 三带二
-- 	EN_POKER_TYPE_STRAIGHT			= 6; // 顺子
-- 	EN_POKER_TYPE_STRAIGHT_2		= 7; // 双顺
-- 	EN_POKER_TYPE_STRAIGHT_3		= 8; // 三顺
-- 	EN_POKER_TYPE_QUADRUPLE_WITH_TWO	= 9; // 四带二
-- 	EN_POKER_TYPE_SOFT_BOMB			= 20; // 软炸弹
-- 	EN_POKER_TYPE_SOFT_BOMB_OF_JOKER	= 21; // 软王炸
-- 	EN_POKER_TYPE_BOMB				= 22; // (硬)炸弹
-- 	EN_POKER_TYPE_BOMB_OF_JOKER		= 23; // (硬)王炸
-- }
--J:11, Q:12, K:13, A:14, 2:15, 小王:16, 大王:17, 癞子:18
function SuanfucForGame:ctor(_scene)
	self.gamescene = _scene
end

--获取删除牌列表
function SuanfucForGame:getDeleteList(data)

	if data.dele_hand_cards  then
		return data.dele_hand_cards
	end

	--恩施的癞子杠和痞子杠
	if data.act_type == poker_common_pb.EN_SDR_ACTION_GANG_2 then
		return {data.dest_card}
	end

	if data.col_info == nil then
		return {data.dest_card} or {-1}
	end

	local list = data.col_info.cards
	if data.col_info.original_cards then --如果有癞子，需要删除真实牌
		list = data.col_info.original_cards
	end

	if data.dest_card == nil then
		return list
	end
	local dest_card = data.dest_card

	local _list = clone(list)
	for i,v in ipairs(_list) do
		if v == dest_card  then
			table.remove(_list,i)
			dest_card = -1
			break
		end
	end
	return _list
	
end
--获取玩家坐的物理位置，根据服务器的理论位置，
--比如，玩家a坐在1号位的话，需要根据我的位子和玩牌人数，来决定他到底是坐在我的左边，还是右边，还是对面
function SuanfucForGame:getSeatPosByIndex(index)
 local maps = {
        [2] =
        {
            [0] = { 1, 3 },
            [1] = { 3, 1 },
        },
        [3] =
        {
            [0] = { 1, 2, 4 },
            [1] = { 4, 1, 2 },
            [2] = { 2, 4, 1 },
        },
        [4] =
        {
            [0] = { 1, 2, 3, 4 },
            [1] = { 4, 1, 2, 3 },
            [2] = { 3, 4, 1, 2 },
            [3] = { 2, 3, 4, 1 },
        },
    }

    maps = maps[self.gamescene:getTableConf().seat_num]
    maps = maps[self.gamescene:getMyIndex()]
   return maps[index+1]
end

--恩施麻将的特殊需求
function SuanfucForGame:getIsQingYiSe(index)
	--必须是有三组,癞子杠痞子杠不算
	--必须是同一花色
	print("......判断清一色")
	local show = clone(self.gamescene:getShowCardsByIdx(index))
	local num = 0
	local oldCard = 0
	for k,v in pairs(show) do
		if v.col_type ~= poker_common_pb.EN_SDR_COL_TYPE_YI_GANG_2 then
			num = num + 1
			print(".......v.dest_card = ",v.dest_card)
			print("......判断清一色 ".. math.abs(v.dest_card - oldCard))
			if  math.abs(v.dest_card - oldCard) > 10 then
				return false
			end
			oldCard = v.dest_card
		end
	end
	if num ~= 3 then
		return  false
	end
	return true
end

function SuanfucForGame:getIsJiangYiSe(index)
	-- （碰杠暗杠）  有两组，并且都是258的话
	--必须是有两组
	--必须是碰杠暗杠
	--必须是258
	local show = clone(self.gamescene:getShowCardsByIdx(index))
	local num = 0
	for k,v in pairs(show) do
		if v.col_type ~= poker_common_pb.EN_SDR_COL_TYPE_YI_GANG_2 then
			num = num + 1
			if v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_PENG or 
				v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_GANG or 
				v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_AN_GANG then  
				if v.dest_card == 0x2 or v.dest_card == 0x5 or v.dest_card == 0x8 or
					v.dest_card == 0x22 or v.dest_card == 0x25 or v.dest_card == 0x28 or
					v.dest_card == 0x42 or v.dest_card == 0x45 or v.dest_card == 0x48 then
					print(".......满足条件")
				else
					return false
				end
			else
				return false
			end
		end
	end
	if num ~= 2 then
		return  false
	end
	return true
end

function SuanfucForGame:getIsYangPi(_index)
	-- repeated int32 game_play_type_2 = 41;    // 多选玩法类型 0->抬杠 1->杠上炮 2->禁止养痞 3->打癞禁胡 4->打痞禁胡
	--有禁止养痞的选项
	--只有我自己有两个杠
	--其他人不能有杠
	if self.gamescene:getIsHavePlay(2) == false then
		return false
	end

	local  seatsInfo = self.gamescene:getSeatsInfo()
	for k,v in pairs(seatsInfo) do
		local gang_num = 0
		if v.out_col and #v.out_col >1 then
			for kk,vv in pairs(v.out_col) do
				if vv.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_GANG_2 or
					vv.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_GANG or
					vv.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_AN_GANG then
					gang_num = gang_num + 1
				end
			end
		end
		if v.index == _index and gang_num ~= 2 then
			return false
		end
		if v.index ~= _index and gang_num ~= 0 then
			return false
		end
	end
	return true
end

function SuanfucForGame:getIsTaiZhuang(_index,card)
	-- repeated int32 game_play_type_2 = 41;    // 多选玩法类型 0->抬杠 1->杠上炮 2->禁止养痞 3->打癞禁胡 4->打痞禁胡
	--有抬杠的选项
	--都没有摆出去的牌(癞子杠痞子杠除外)，没有打出去的牌
	--打出去的牌，我自己要没有
	--其他人打出去牌要是唯一，并且几个玩家的都要相同
	if self.gamescene:getIsHavePlay(0) == false then
		return false
	end
	local  seatsInfo = self.gamescene:getSeatsInfo()
	for k,v in pairs(seatsInfo) do
		if v.out_col and #v.out_col >0 then
			for kk,vv in pairs(v.out_col) do
				if vv.col_type ~= poker_common_pb.EN_SDR_COL_TYPE_YI_GANG_2 then
					return false
				end
			end
		end
	end

	for k,v in pairs(seatsInfo) do
		if v.index == _index then --我自己要没有牌
			if  v.out_cards and #v.out_cards >0 then
				return false
			end
		else
			if v.out_cards and #v.out_cards == 1 then --其他人必须有出牌，并且只有一张，
				for kk,vv in pairs(v.out_cards) do  --这一张还必须相同
					if vv ~= card  then
						return false
					end
				end
			else
				return false
			end
		end
	end
	return true

end
-- self.gamescene:getIsHavePlay(0)
return SuanfucForGame