-----------------
-- 本地配置
-- yc
-- 2016/11/8
-----------------
LocalConfig = {}
-- 房间配置
-- type 必须从小到达
-- 标题图片 
-- itemname 为图片 1 局数 2封顶 3 玩法
LocalConfig.ROOM = {
	{
		name = "泸州鬼麻将",
		imgtype = 1,
		config = {
			[1]	= {
					itemsname = "局数",
					imgtype = 1,
					items = {
						{
							optionname = "4局(房卡x2)",
							-- 是否多选
							ismultiple = false,
							type = 1,
							default = 1,
							index = 1,
							value = 4,
						},
						{
							optionname = "8局(房卡x3)",
							-- 是否多选
							ismultiple = false,
							type = 1,
							index = 2,
							value = 8,
						}
					}
				},

			[2] = {
					itemsname = "封顶",
					imgtype = 2,
					items = {
						{
							optionname = "40颗",
							-- 是否多选
							ismultiple = false,
							type = 1,
							default = 1,
							index = 3,
							value = 40,
						},
						{
							optionname = "80颗",
							-- 是否多选
							ismultiple = false,
							type = 1,
							index = 4,
							value = 80, 
						},
						{
							optionname = "不封顶",
							-- 是否多选
							ismultiple = false,
							type = 1,
							index = 5,
							value = -1, 
						},
					}
				},
			[3] = {
					itemsname = "玩法",
					imgtype = 3,
					items = {
						{
							optionname = "8鬼",
							-- 是否多选
							ismultiple = false,
							type = 1,
							default = 1,
							index = 6,
							value = 8,
							key = "gui",
						},
						{
							optionname = "12鬼",
							-- 是否多选
							ismultiple = false,
							type = 1,
							index = 7,
							value = 12,
							key = "gui",
						},
						{
							optionname = "2颗 (胡)",
							-- 是否多选
							ismultiple = false,
							type = 2,
							default = 1,
							index = 8,
							value = 1,
							key = "hu",
						},
						{
							optionname = "5颗 (胡)",
							-- 是否多选
							ismultiple = false,
							type = 2,
							index = 9,
							value = 2,
							key = "hu",
						},
						{
							optionname = "喜钱",
							-- 是否多选
							ismultiple = true,
							type = 3,
							default = 1,
							index = 10,
							value = 10,
							key = "xiqian",
						},
						-- {
						-- 	optionname = "换三张",
						-- 	-- 是否多选
						-- 	ismultiple = true,
						-- 	type = 3,
						-- 	index = 11,
						-- 	key = "huansanzhang",
						-- },
						-- {
						-- 	optionname = "报牌",
						-- 	-- 是否多选
						-- 	ismultiple = true,
						-- 	type = 3,
						-- 	index = 12,
						-- 	key = "baopai",
						-- },
						-- {
						-- 	optionname = "杀牌",
						-- 	-- 是否多选
						-- 	ismultiple = true,
						-- 	type = 3,
						-- 	index = 13,
						-- },
					}
				}
		},
	},
}

if SHENHEBAO then
	LocalConfig.ROOM[1].config[1].items[1].optionname = "4局"
	LocalConfig.ROOM[1].config[1].items[2].optionname = "8局"
end
-- level 最外层 
function LocalConfig.getRoomInfo(typ,index)
	if not type or not index then
		return 
	end
	local info = LocalConfig.ROOM[typ]
	if not info then
		print("没有找到该类型的配置")
		return
	end
	for i,v in ipairs(info.config) do
		for m,vv in pairs(v.items) do
			if vv.index == index then
				return vv
			end
		end	
	end
	return nil
end
-- items 下的类型
function LocalConfig.getRoomInfoByValue(typ,index,value,keyStr)
	if not typ or not index or not value then
		return 
	end
	local info = LocalConfig.ROOM[typ]
	if not info or not info.config or not info.config[index] then
		print("没有找到该类型的配置")
		return
	end
	for i,v in ipairs(info.config[index].items) do
		if keyStr and v.key == keyStr then
			if v.value == value then
				return v
			end
		elseif not keyStr then
			if v.value == value then
				return v
			end
		end	
	end	
	return nil
end
-- 快速发言文字
LocalConfig.QUICK_CHAT_LIST = {
    "快点快点！多整两盘哦！", 
    "催啥子催，我看叫哪张",   
    "你们太要不得了哦，只晓得按到我胡安", 
    "你们整得好哦！我要来我要来！", 
    "输家不开口，赢家不准走",  
    "我有事，先整一盘就走了，你们整开心哈",
    "不得再放了，点炮我都胡了", 
    "美女，你割撒子，我打给你哇 ",  
}
-- 快速发言语音
LocalConfig.QUICK_EFFECT_LIST = {
	"kuaidianduozheng2pan",
	"chuishaizchui2",
	"nimentaiyaobudele",
	"nimenzhengdehao",
	"shujiabukaikou", 
	"woyoushi", 
	"budezaifangle",
	"meinv nihushazi"    
}
-- -- 表情
-- LocalConfig.EMOJ_LIST = {
--     "E00E","E02B","E043","E04F","E051","E052","E053",
--     "E056","E057","E058","E059","E105","E106","E107",
--     "E108","E252","E401","E402","E403","E404","E405",
--     "E406","E407","E408","E409","E40A","E40B","E40C",
--     "E40D","E40E","E40F","E410","E411","E412","E413",
--     "E414","E415","E416","E417","E418","E41D","E41F",
--     "E420","E421","E428","E52B","E52D","E52E"	
-- }
return LocalConfig