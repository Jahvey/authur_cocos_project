local GameTypeManager = class("GameTypeManager")

HPGAMETYPE  = {
	ESSH	= 60, --恩施绍胡
	LCSDR	= 61, --利川上大人
	ESCH	= 62, --恩施楚胡
	BDSDR 	= 63, --巴东上大人
	HFBH  	= 64, --鹤峰百胡
	LFSDR 	= 65, --来凤上大人
	JSCH  	= 66, --建始楚胡
	YSGSDR  = 67, --野三关上大人
	SZ96 	= 68, --桑植96
	YSGDDZ  = 69, --野三关斗地主
	MCDDZ  	= 70, --麻城斗地主
	ESDDZ  	= 71, --恩施斗地主
	--72 是四色牌的app中的罗源四色牌
	BDMJ	= 73, --巴东三星麻将
	XESDR 	= 74, --宣恩上大人
	XE96 	= 75,--宣恩96
	XCCH	= 76, --孝昌扯胡
	XFSH  	= 77,--咸丰绍胡
	XFPDK	= 78, --咸丰跑得快
	JDPDK 	= 79, -- 经典跑的快
	JDDDZ 	= 81,  -- 经典斗地主
	YCSDR 	= 82,  -- 宜城绞胡，
	--83 是四色牌的app中的连江四色牌	
	YCDDZ 	= 84,
	YCXZP 	= 85,	--应城小字牌
	ESMJ  	= 86,	--恩施麻将
	SJHP = 101,--三精
	WJHP = 102,--五精 
	--87 是河池牛鬼的app中河池牛鬼
	TCGZP  	= 88,	--通城个子牌
	--89 陇西麻将app中的陇西麻将89
	LJSDR  	= 91,	--宜昌老精上大人

	FJSDR  	= 103,	--当阳翻精上大人

	-- 服务器已用
	-- EN_Node_TeaBar = 80;  // 亲友圈
	-- EN_Node_List_Dispather = 90;
	-- EN_Node_PHP = 99;
	-- EN_Node_Unknown = 100;
}

--类型分类 
STYLETYPE =
{
	HuaPai 	= 1, --花牌
	Poker 	= 2, --扑克牌
	MaJiang = 3, --麻将
}

HPMATCHTYPE = {
	ESSH = 200,
}

MATCHMAP = {
	[HPMATCHTYPE.ESSH] = HPGAMETYPE.ESSH,
}

local GameConfig = {}
GameConfig[HPGAMETYPE.ESSH]	= { PATH = "game_sh",	 	GameName = "恩施绍胡",	style = STYLETYPE.HuaPai, 	isHelp = true, 	wechatName = "恩施绍胡代理详询：", 		wechat = "jrhp007"}
GameConfig[HPGAMETYPE.LCSDR]= { PATH = "game_sdr",	 	GameName = "利川上大人",	style = STYLETYPE.HuaPai, 	isHelp = true, 	wechatName = "利川上大人代理详询：", 	wechat = "jrhp007"}
GameConfig[HPGAMETYPE.ESCH]	= { PATH = "game_ch",	 	GameName = "恩施楚胡",	style = STYLETYPE.HuaPai, 				wechatName = "恩施楚胡代理详询：", 		wechat = "jrhp008"}
GameConfig[HPGAMETYPE.BDSDR]= { PATH = "game_bdsdr", 	GameName = "巴东上大人",	style = STYLETYPE.HuaPai, 	isHelp = true,			wechatName = "巴东上大人代理详询：", 	wechat = "jrhp008"}
GameConfig[HPGAMETYPE.HFBH]	= { PATH = "game_hfbh",	 	GameName = "鹤峰百胡",	style = STYLETYPE.HuaPai, 	isHelp = true,	wechatName = "鹤峰百胡代理详询：", 		wechat = "jrhp008"}
GameConfig[HPGAMETYPE.LFSDR]= { PATH = "game_lfsdr", 	GameName = "来凤上大人",	style = STYLETYPE.HuaPai, 				wechatName = "来凤上大人代理详询：", 	wechat = "jrhp008"}
GameConfig[HPGAMETYPE.JSCH] = { PATH = "game_jsch",		GameName = "建始楚胡",	style = STYLETYPE.HuaPai, 				wechatName = "建始楚胡代理详询：", 		wechat = "jrhp008"}
GameConfig[HPGAMETYPE.YSGSDR]= { PATH = "game_ysgsdr", 	GameName = "野三关上大人",style = STYLETYPE.HuaPai, 	isHelp = true,	wechatName = "野三关上大人代理详询：", 	wechat = "jrhp008"}
GameConfig[HPGAMETYPE.SZ96]= { PATH = "game_sz96", 		GameName = "桑植96",		style = STYLETYPE.Poker, 				wechatName = "桑植96代理详询：", 		wechat = "jrhp008"}
GameConfig[HPGAMETYPE.YSGDDZ]= { PATH = "game_ysgddz", 	GameName = "野三关踢脚",	style = STYLETYPE.Poker, 	isHelp = true,	wechatName = "野三关踢脚代理详询：", 	wechat = "jrhp008"}
GameConfig[HPGAMETYPE.MCDDZ]= { PATH = "game_mcddz", 	GameName = "麻城斗地主",	style = STYLETYPE.Poker, 				wechatName = "麻城斗地主代理详询：", 	wechat = "jrhp008"}
GameConfig[HPGAMETYPE.ESDDZ]= { PATH = "game_esddz", 	GameName = "恩施斗地主",	style = STYLETYPE.Poker, 	isHelp = true,	wechatName = "恩施斗地主代理详询：", 	wechat = "jrhp008"}
GameConfig[HPGAMETYPE.XCCH]= { PATH = "game_xcch", 		GameName = "孝昌扯胡",	style = STYLETYPE.HuaPai, 				wechatName = "孝昌扯胡代理详询：", 		wechat = "jrhp008"}
GameConfig[HPGAMETYPE.BDMJ]= { PATH = "game_MJ/mj_bdmj",GameName = "巴东麻将",	style = STYLETYPE.MaJiang, 	isHelp = true,	wechatName = "巴东麻将代理详询：", 		wechat = "jrhp008"}
GameConfig[HPGAMETYPE.XESDR]= { PATH = "game_xesdr", 	GameName = "宣恩上大人",	style = STYLETYPE.HuaPai, 		wechatName = "宣恩上大人代理详询：", wechat = "jrhp008"}
GameConfig[HPGAMETYPE.XE96]= { PATH = "game_xe96", 		GameName = "宣恩96",		style = STYLETYPE.Poker, 		wechatName = "宣恩96代理详询：", wechat = "jrhp008"}
GameConfig[HPGAMETYPE.XFSH]= { PATH = "game_xfsh", 		GameName = "咸丰绍胡",	style = STYLETYPE.HuaPai, 		wechatName = "咸丰绍胡代理详询：", wechat = "jrhp008"}
GameConfig[HPGAMETYPE.XFPDK]= { PATH = "game_xfpdk", 	GameName = "咸丰3A12",	style = STYLETYPE.Poker, 		wechatName = "咸丰3A12代理详询：", wechat = "jrhp008"}
GameConfig[HPGAMETYPE.JDPDK]= { PATH = "game_jdpdk", 	GameName = "经典跑得快",	style = STYLETYPE.Poker, 		wechatName = "经典跑得快代理详询：", wechat = "jrhp008"}
GameConfig[HPGAMETYPE.JDDDZ]= { PATH = "game_jdddz", 	GameName = "经典斗地主",	style = STYLETYPE.Poker, 		wechatName = "经典斗地主代理详询：", 	wechat = "jrhp007"}
GameConfig[HPGAMETYPE.YCSDR]= { PATH = "game_ycsdr", 	GameName = "宜城绞胡",	style = STYLETYPE.HuaPai, 		wechatName = "宜城上大人代理详询：", 	wechat = "jrhp008"}
GameConfig[HPGAMETYPE.YCDDZ]= { PATH = "game_ycddz", 	GameName = "应城斗地主",	style = STYLETYPE.Poker, 		wechatName = "应城斗地主代理详询：", 	wechat = "jrhp008"}
GameConfig[HPGAMETYPE.YCXZP]= { PATH = "game_ycxzp", 	GameName = "应城小字牌",	style = STYLETYPE.HuaPai, 		wechatName = "宜城上大人代理详询：", 	wechat = "jrhp008"}
GameConfig[HPGAMETYPE.ESMJ]= { PATH = "game_MJ/mj_esmj",GameName = "恩施麻将",	style = STYLETYPE.MaJiang, 	isHelp = true,	wechatName = "恩施麻将代理详询：", 		wechat = "jrhp008"}
GameConfig[HPGAMETYPE.TCGZP]= { PATH = "game_tcgzp",	GameName = "通城个子牌",	style = STYLETYPE.HuaPai, 	audioPath = "hp/tcgzp",twoAudio = true,wechatName = "通城个子牌详询：", 		wechat = "jrhp008", }
GameConfig[HPGAMETYPE.LJSDR]= { PATH = "game_ljsdr", 	GameName = "宜昌老精",	style = STYLETYPE.HuaPai, 	audioPath = "hp/fjsdr",twoAudio = true,wechatName = "宜昌老精上大人代理详询：", 	wechat = "jrhp008"}
GameConfig[HPGAMETYPE.FJSDR]= { PATH = "game_fjsdr", 	GameName = "当阳翻精",	style = STYLETYPE.HuaPai, 	audioPath = "hp/fjsdr",twoAudio = true,		wechatName = "当阳翻精上大人代理详询：", 	wechat = "jrhp008"}
GameConfig[HPGAMETYPE.SJHP]= { PATH = "game_sjhp", 	GameName = "三精花牌",	style = STYLETYPE.HuaPai, 	isHelp = false,	wechatName = "三精花牌代理详询：", 	wechat = "jrhp008"}
GameConfig[HPGAMETYPE.WJHP]= { PATH = "game_wjhp", 	GameName = "五精花牌",	style = STYLETYPE.HuaPai, 	isHelp = false,	wechatName = "三精花牌代理详询：", 	wechat = "jrhp008"}

-- 前端为了控制逻辑而自己加的操作类型,所有玩法共用，只能增不能减
ACTIONTYPEBYMYSELF =
{
    CREATE_CARD = 100, -- 刚开始游戏，创建牌的时候，会有一个牌的移动过程，要移动完了，再进行下面的动画
    NEXT_OPERATION = 101, -- 轮到下一个玩家操作，或者等待某个玩家操作，把闹钟移动到其对应位置
    MYTURN = 102, -- 我的操作回合，
    MYTURN_CHU = 103, -- 我的出牌环节，把闹钟和 手指都显示出来
    GAMEOVER = 104, -- 游戏结束
    BIPAI = 105, --比牌确定庄 
    XUANPAI = 106, --选牌确定癞子 
    DINGZHANG = 107
}

function GameTypeManager:ctor()
	-- body
end

function GameTypeManager.getInstance()
	if not GT_INSTANCE then
		GT_INSTANCE = GameTypeManager.new()
	end 
	return GT_INSTANCE
end

function GameTypeManager:getGameName(ttype)
	return (GameConfig[ttype] and GameConfig[ttype].GameName) or ""
end

function GameTypeManager:getGamePath(ttype)
	if MATCHMAP[ttype] then
		return GameConfig[MATCHMAP[ttype]] and GameConfig[MATCHMAP[ttype]].PATH
	end
	return GameConfig[ttype] and GameConfig[ttype].PATH
end

function GameTypeManager:getWechatName(ttype)
	return GameConfig[ttype] and GameConfig[ttype].wechatName
end

function GameTypeManager:getWechat(ttype)
	return GameConfig[ttype] and GameConfig[ttype].wechat
end

function GameTypeManager:getIsHelp(ttype)
	return GameConfig[ttype] and GameConfig[ttype].isHelp or false
end

function GameTypeManager:getIsAudioPath(ttype)
	return GameConfig[ttype] and GameConfig[ttype].audioPath or nil
end

function GameTypeManager:getIsTwoAudio(ttype)
	return GameConfig[ttype] and GameConfig[ttype].twoAudio or false
end




--是否在扑克牌的列表中,是为了用于区分创建房间的入口
function GameTypeManager:getIsInThePokerList(ttype)
	if #CM_INSTANCE:getPOKERGAMESLIST() ~= 0 and ttype then
		for i,v in ipairs(CM_INSTANCE:getPOKERGAMESLIST()) do
			if v == ttype then
				return true
			end
		end
	end
	return false
end

function GameTypeManager:getIsInTheMaJiangList(ttype)
	if #CM_INSTANCE:getMAJIANGGAMESLIST() ~= 0 and ttype then
		for i,v in ipairs(CM_INSTANCE:getMAJIANGGAMESLIST()) do
			if v == ttype then
				return true
			end
		end
	end
	return false
end

--是否是新的扑克布局，两种背景

function GameTypeManager:getGameStyle(ttype)
	return GameConfig[ttype] and GameConfig[ttype].style
end

-- fromType,
-- 1是牌桌的规则按钮，要按照换行来显示全部
-- 2是牌桌内邀请按钮点击，按照字符串的方式显示全部
-- 3是大结算界面，不需要显示人数和牌局数
-- 4是小结算界面，不需要显示人数和牌局数,以及支付方式

function GameTypeManager:getTableDes(tableConfig, fromType)

	local list = {}
	local str = ""
	if not tableConfig then
		if fromType == 1 then
			return list
		end
		return str
	end

	local str
	if  fromType ~= 3 and fromType ~= 4  then
		if tableConfig.seat_num then
			str = "三人"
			if tableConfig.seat_num == 4  then
				str = "四人"
				elseif tableConfig.seat_num == 2  then
				str = "两人"
			end  
			table.insert(list,str)
		end
		if tableConfig.round then
			table.insert(list,tableConfig.round.."局")
		end
	end

	if  fromType ~= 4 then
		if tableConfig.tbid then
			if tableConfig.tb_pay_type == 0 then
				table.insert(list,"亲友圈支付")
			elseif tableConfig.tb_pay_type == 1 then
				table.insert(list,"亲友圈均摊")
			end
		else
			if tableConfig.pay_type == 0 then
				table.insert(list,"标准房费")
			elseif tableConfig.pay_type == 1 then
				table.insert(list,"均摊房费")
			end
		end
	end

	if tableConfig.ttype ==  HPGAMETYPE.ESCH then
		if tableConfig.is_chi_re then
			table.insert(list,"吃热")
		end
		if tableConfig.is_du_gang_jiang_zhao then
			table.insert(list,"独杠降招")
		end

	elseif tableConfig.ttype ==  HPGAMETYPE.ESSH then
		if  tableConfig.qiang_type == 0 then
			table.insert(list,"上七八可")
		elseif tableConfig.qiang_type == 1  then
			table.insert(list,"见红枪")
		else
			table.insert(list,"夹夹枪")
		end

		if  tableConfig.is_ke_hu_bu_zhui then
			table.insert(list,"可胡不追")
		end


	elseif tableConfig.ttype ==  HPGAMETYPE.LCSDR then
		
		if tableConfig.seat_num == 2  and  tableConfig.special_score then
			if tableConfig.special_score ~= 0 then
				table.insert(list,tableConfig.special_score.."胡起胡")
			end
		end
		
		if tableConfig.has_piao then
			table.insert(list,"漂")
		end

	elseif tableConfig.ttype ==  HPGAMETYPE.LFSDR then
		if tableConfig.is_dao_jin then
			table.insert(list,"可倒进")
		else
			table.insert(list,"不可倒进")
		end

	elseif tableConfig.ttype ==  HPGAMETYPE.BDSDR then
		table.insert(list,"底分"..tableConfig.di_score.."分")
		table.insert(list,tableConfig.jing_hu_score.."胡")
		if tableConfig.is_dai_kan_mao then
			table.insert(list,"带坎带卯")
		end
		if tableConfig.is_fangpao_bao_pei then
			table.insert(list,"包铳")
		end

	elseif tableConfig.ttype ==  HPGAMETYPE.HFBH then
		if tableConfig.wu_ba_bu_peng then
			table.insert(list,"五八不碰")
		end
		if tableConfig.du_kan_bu_chai then
			table.insert(list,"独坎不拆")
		end
		if tableConfig.luo_di_sheng_hua == false then
			table.insert(list,"不可落地生花")
		end

		if tableConfig.pao_fen then
			if  tableConfig.pao_fen == 0 then
				table.insert(list,"放炮不加分")
			else
				table.insert(list,"放炮加"..tableConfig.pao_fen.."分")
			end
		end
	elseif tableConfig.ttype ==  HPGAMETYPE.JSCH then
		if tableConfig.count_way and tableConfig.count_way ~= 0 then
			table.insert(list,"紧小")
		else
			table.insert(list,"紧大")
		end

		if tableConfig.is_long_ke_gua_long then
			table.insert(list,"龙可挂龙")
		end

	elseif tableConfig.ttype ==  HPGAMETYPE.YSGSDR then
		table.insert(list,"底分"..tableConfig.di_score.."分")

	elseif tableConfig.ttype ==  HPGAMETYPE.SZ96 then
		-- table.insert(list,"底分"..tableConfig.di_score.."分")
		if tableConfig.has_piao then
			table.insert(list,"漂")
		end
	elseif tableConfig.ttype ==  HPGAMETYPE.YSGDDZ then
		table.insert(list,"底分"..tableConfig.di_score.."分")

		table.insert(list,"地主"..tableConfig.max_line.."分封")

	elseif tableConfig.ttype ==  HPGAMETYPE.MCDDZ then
		if tableConfig.count_way == 0 then
			table.insert(list,"算番:加法")
		else
			table.insert(list,"算番:乘法")
		end
	elseif tableConfig.ttype ==  HPGAMETYPE.XESDR then
		if tableConfig.qiang_type then
			if  tableConfig.qiang_type == 0 then
				table.insert(list,"上七八胡")
			elseif tableConfig.qiang_type == 1  then
				table.insert(list,"见红枪")
			elseif tableConfig.qiang_type == 2  then
				table.insert(list,"碰一绍二")
			end
		end
		if tableConfig.count_way then
			if tableConfig.count_way == 0 then
				table.insert(list,"算分:加法")
			elseif tableConfig.count_way == 1 then
				table.insert(list,"算分:乘法")
			end
		end

		if tableConfig.di_score then
			table.insert(list,"底分"..tableConfig.di_score.."分")
		end
	elseif tableConfig.ttype ==  HPGAMETYPE.XE96 then
		if tableConfig.qiang_type then
			if  tableConfig.qiang_type == 0 then
				table.insert(list,"1.4.7.J.红色")
			elseif tableConfig.qiang_type == 1  then
				table.insert(list,"1.4.7.J.红,黑色")
			elseif tableConfig.qiang_type == 2  then
				table.insert(list,"碰一绍二")
			end
		end

		if tableConfig.di_score then
			table.insert(list,"底分"..tableConfig.di_score.."分")
		end

		if tableConfig.count_way and tableConfig.count_way == 0 then
			table.insert(list,"加法")
		else
			table.insert(list,"乘法")
		end

	elseif tableConfig.ttype ==  HPGAMETYPE.XFSH then
		if tableConfig.qiang_type then
			if  tableConfig.qiang_type == 0 then
				table.insert(list,"上七八可")
			elseif tableConfig.qiang_type == 1  then
				table.insert(list,"见红枪")
			elseif tableConfig.qiang_type == 2  then
				table.insert(list,"夹夹枪")
			end
		end

		if tableConfig.di_score then
			table.insert(list,"底分"..tableConfig.di_score.."分")
		end
	elseif tableConfig.ttype ==  HPGAMETYPE.XCCH then 
		table.insert(list,"底分"..tableConfig.di_score.."分")

		if tableConfig.you_lai_bi_bai then
			table.insert(list,"有癞必搁")
		end
	elseif tableConfig.ttype ==  HPGAMETYPE.BDMJ then  --巴东麻将
		table.insert(list,"底分"..tableConfig.di_score.."分")
	elseif tableConfig.ttype ==  HPGAMETYPE.XFPDK then 
		if tableConfig.max_bomb and tableConfig.max_bomb > 0 then
			table.insert(list,tableConfig.max_bomb.."炸封顶")
		end
	elseif tableConfig.ttype ==  HPGAMETYPE.YCSDR then 
		if tableConfig.has_piao then
			table.insert(list,"漂")
		else
			table.insert(list,"不漂")
		end
		if tableConfig.game_play_type then
			if tableConfig.game_play_type == 0 then
				table.insert(list,"定张")
			elseif tableConfig.game_play_type == 1 then
				table.insert(list,"定张定恰定光")
			end
		end

	elseif tableConfig.ttype ==  HPGAMETYPE.JDPDK then 
		if tableConfig.is_last_winner_dealer then
			table.insert(list,"黑桃3先出")
		else
			table.insert(list,"赢牌先出")
		end

		if tableConfig.you_da_bi_chu then
			table.insert(list,"有大必出")
		end

		if tableConfig.able_two_lain_dui then
			table.insert(list,"可出2连对")
		end

		if tableConfig.bomb_3_a then
			table.insert(list,"3个A是炸弹")
		end
	elseif tableConfig.ttype == HPGAMETYPE.JDDDZ then
		table.insert(list,"地主"..tableConfig.max_line.."分封")

	elseif tableConfig.ttype == HPGAMETYPE.YCDDZ then
		table.insert(list,tableConfig.laizi_num.."癞子")
		if tableConfig.max_bomb and tableConfig.max_bomb == 0 then
			table.insert(list,"不封顶")
		elseif tableConfig.max_bomb then
			table.insert(list,tableConfig.max_bomb.."炸")
		end
		if tableConfig.deal_handcard_type == 1  then

			table.insert(list,"两次发完")
		else
			table.insert(list,"一张一发")
		end
		if tableConfig.di_score then
			table.insert(list,"底分"..tableConfig.di_score.."分")
		end
		printTable(tableConfig, "sjp3")
		if tableConfig.count_way and tableConfig.count_way == 0 then
			table.insert(list,"平番")
		elseif tableConfig.count_way and tableConfig.count_way == 1 then
			table.insert(list,"倍番")
		else
			print("coutnt_way nil")
		end
	elseif tableConfig.ttype == HPGAMETYPE.YCXZP then
		if tableConfig.di_score then
			table.insert(list,"底分"..tableConfig.di_score.."分")
		end

		if tableConfig.piao_score ~= nil then
			if tableConfig.piao_score == 0 then
				table.insert(list,"不漂")
			else
				table.insert(list,"漂分"..tableConfig.piao_score.."分")
			end
		end
	elseif tableConfig.ttype == HPGAMETYPE.ESMJ then

		if  tableConfig.game_play_type == 2 then
			table.insert(list,"一癞到底")
		elseif  tableConfig.game_play_type == 3 then
			table.insert(list,"多癞")
		end

		if tableConfig.game_play_type_2 and #tableConfig.game_play_type_2 > 0 then
			local _str = {"抬庄","杠上炮","禁止养痞","打癞禁胡","打痞禁胡"}
			
			printTable(tableConfig.game_play_type_2,"xp66")
			for k,v in pairs(tableConfig.game_play_type_2) do
				table.insert(list,_str[v+1])
			end
		end

		if tableConfig.di_score then
			local di_score = tableConfig.di_score/10.0
			table.insert(list,"底分"..di_score.."分")
		end
	elseif tableConfig.ttype == HPGAMETYPE.SJHP then
		if tableConfig.game_play_type_2 then
			for i,v in ipairs(tableConfig.game_play_type_2) do
				if v == poker_common_pb.ENM_SDR_PLAY_TYPE_XIAN_DUI then
					table.insert(list,"限对")
				elseif v == poker_common_pb.ENM_SDR_PLAY_TYPE_ZHUO_MIAN_SUAN_ZHU_JING then
					table.insert(list,"桌面精不算主精")
				elseif v == poker_common_pb.ENM_SDR_PLAY_TYPE_ZI_DAI_1_KAN_JING then
					table.insert(list,"自带一坎精")
				elseif v == poker_common_pb.ENM_SDR_PLAY_TYPE_ZI_DAI_2_HUA_JING then
					table.insert(list,"自带两花精")
				elseif v == poker_common_pb.ENM_SDR_PLAY_TYPE_ZHI_NENG_ZI_MO then
					table.insert(list,"只能自摸")
				end
			end
		end
		if tableConfig.count_way then
			if tableConfig.count_way == 1 then
				table.insert(list,"按胡计分")
				if tableConfig.special_score then
					if tableConfig.special_score == 1 then
						table.insert(list,"一胡一分")
					elseif tableConfig.special_score == 2 then
						table.insert(list,"逢一就包")
					elseif tableConfig.special_score == 3 then
						table.insert(list,"二舍三入")
					end
					
				end
			elseif tableConfig.count_way == 2 then
				table.insert(list,"按坡计分")
				if tableConfig.special_score then
					table.insert(list,"底分"..tableConfig.special_score.."分")
				end
			end
		end
		if tableConfig.is_fangpao_bao_pei then
			table.insert(list,"包铳")
		end
				
	elseif tableConfig.ttype == HPGAMETYPE.WJHP then
		if tableConfig.game_play_type_2 then
			for i,v in ipairs(tableConfig.game_play_type_2) do
				if v == poker_common_pb.ENM_SDR_PLAY_TYPE_XIAN_DUI then
					table.insert(list,"限对")
				elseif v == poker_common_pb.ENM_SDR_PLAY_TYPE_ZHUO_MIAN_SUAN_ZHU_JING then
					table.insert(list,"桌面精不算主精")
				elseif v == poker_common_pb.ENM_SDR_PLAY_TYPE_ZI_DAI_1_KAN_JING then
					table.insert(list,"自带一坎精")
				elseif v == poker_common_pb.ENM_SDR_PLAY_TYPE_ZI_DAI_2_HUA_JING then
					table.insert(list,"自带两花精")
				elseif v == poker_common_pb.ENM_SDR_PLAY_TYPE_ZHI_NENG_ZI_MO then
					table.insert(list,"只能自摸")
				end
			end
		end
		if tableConfig.count_way then
			if tableConfig.count_way == 1 then
				table.insert(list,"按胡计分")
				if tableConfig.special_score then
					if tableConfig.special_score == 1 then
						table.insert(list,"一胡一分")
					elseif tableConfig.special_score == 2 then
						table.insert(list,"逢一就包")
					elseif tableConfig.special_score == 3 then
						table.insert(list,"二舍三入")
					end
					
				end
			elseif tableConfig.count_way == 2 then
				table.insert(list,"按坡计分")
				if tableConfig.special_score then
					table.insert(list,"底分"..tableConfig.special_score.."分")
				end
			end
		end
		if tableConfig.is_fangpao_bao_pei then
			table.insert(list,"包铳")
		end
	elseif tableConfig.ttype == HPGAMETYPE.TCGZP then
		if tableConfig.is_dahua == true then
			table.insert(list,"打花")
		end
		if tableConfig.is_shiduihu == true then
			table.insert(list,"可十对胡")
		end
		if tableConfig.is_yipaoduoxiang == true then
			table.insert(list,"一炮多响")
		end

		if tableConfig.can_jian_pai == true then
			table.insert(list,"可捡")
		end

		if tableConfig.piao_score then
			if tableConfig.piao_score == 0 then
				table.insert(list,"不跑")
			else
				table.insert(list,"跑分:"..tableConfig.piao_score.."分")
			end
		end

		if tableConfig.di_score then
			table.insert(list,"底分:"..tableConfig.di_score.."分")
		end
		
		if tableConfig.hupai_score then
			table.insert(list,"起胡:"..tableConfig.hupai_score.."胡")
		end
		if tableConfig.suanhua_type then
			if tableConfig.suanhua_type == 0 then
				table.insert(list,"十花")
			elseif tableConfig.suanhua_type == 1 then
				table.insert(list,"遛花")
			end
		end
	elseif tableConfig.ttype ==  HPGAMETYPE.LJSDR then
		table.insert(list,"底分"..tableConfig.di_score.."分")
		if tableConfig.is_fangpao_bao_pei then
			table.insert(list,"包铳")
		end
		if tableConfig.is_dai_kan_mao then
			table.insert(list,"带坎带卯")
		end
		
		if tableConfig.zimo_score and tableConfig.zimo_score > 0 then
			table.insert(list,"自摸加倍")
		end
		
		if tableConfig.qiang_an_mao then
			table.insert(list,"扯暗卯")
		end
	elseif tableConfig.ttype ==  HPGAMETYPE.FJSDR then
		table.insert(list,"底分"..tableConfig.di_score.."分")
		if tableConfig.is_dai_kan_mao then
			table.insert(list,"带坎带卯")
		end
	end

	--封顶，提出来处理
	if tableConfig.max_multiple then
		if  tableConfig.max_multiple == 0 then
			table.insert(list,"不封顶")
		else
			if tableConfig.ttype == HPGAMETYPE.SZ96 then
				table.insert(list,tableConfig.max_multiple.."倍封")
			elseif tableConfig.ttype == HPGAMETYPE.ESDDZ then
				table.insert(list,tableConfig.max_multiple.."炸封")
			else
				table.insert(list,tableConfig.max_multiple.."番封")
			end
		end
	end

	local str = ""
	for k,v in pairs(list) do
		str = str..v.." "
	end
	
	if fromType == 1 then
		return list
	end
	return str
end

return GameTypeManager.getInstance()