local CityManager = class("CityManager")

local CONFIG = {}

--城市服务器选择  1 
-- cc.UserDefault:getInstance():setIntegerForKey("CITY_SELECT_SERVER",1)
-- cc.UserDefault:getInstance():setIntegerForKey("CITY_SELECT_CITY",1)

GAME_CITY_SELECT = cc.UserDefault:getInstance():getIntegerForKey("CITY_SELECT_SERVER",1)
GAME_LOCAL_CITY = cc.UserDefault:getInstance():getIntegerForKey("CITY_SELECT_CITY",1)
-- GAME_CITY_SELECT = 1
-- GAME_LOCAL_CITY = 1
--是否是测试服,true 为测试服, false 为正式服
local islocalnetwork = false
-- 恩施
CONFIG[1] = {
	GAME_USERDEFAULT = "",
	IPLOCAL = {port = 9016,ip = "112.124.120.19"}, 
	
	--陈超冲 54013 ，9542，112.124.120.19 
	--胡凯 9012  112.124.120.19,
	--超神 9052 112.124.120.19,

	-- IPLOCAL = {port = 9022,ip = "114.215.188.39"}, 
	--浩源 9022 114.215.188.39,
	--朱柯 33012 114.215.188.39,
	-- 端口
	PORTONLINE = 8002,
	--本地保存的IP
	IPLOCALDAFAULTLIST = {
		"47.97.126.190",
		"47.96.152.200",
		"121.196.215.61",
	},
	-- HTTP线上配置
	HTTP_ADDRESS_ONLINE = "http://jrhpapi.arthur-tech.com/mjapi/index.php",
	--防御相关
	HTTPLOCALDFAULIST =  {"jrhpapi.arthur-tech.com",},
	HTTPCDNLOCALDFAULIST = {"jrhpapi.arthur-tech.com",},
	-- 创建房间界面的游戏列表
	GAMESLIST = {60,61,62,63,64,66,67,65,74,75,77},--花牌列表
	GAMESLIST_POKER = {69,71,78,79,81},--扑克牌列表，斗地主
	GAMESLIST_MJ = {73,86},--麻将列表
	-- 用于选择城市场景的配置
	CITYCONF = { 
        list =
        {  
            {name = "恩施绍胡",open =1},
            {name = "利川上大人",open =1},
            {name = "恩施楚胡",open =1},
            {name = "巴东上大人",open =1},--63
            {name = "鹤峰百胡",open =1},--64
            {name = "建始楚胡",open =1},--66
            {name = "野三关上大人",open =1},--67
            {name = "来凤上大人",open =1},--65
            {name = "野三关踢脚",open =1},--69
            {name = "恩施斗地主",open =1},--71
            {name = "宣恩上大人",open =1},--74
            {name = "宣恩96",open =1},--75
            {name = "咸丰绍胡",open =1},--77
            {name = "巴东三星麻将",open =1},--73
            {name = "咸丰3A12",open =1},--78
            {name = "经典跑得快",open =1},--79
            {name = "经典斗地主",open =1},--81
            {name = "恩施麻将",open =1},--86
        },
    },
}

-- 张家界
CONFIG[2] = {
	GAME_USERDEFAULT = "zjj",
	IPLOCAL ={port = 9012,ip = "112.124.120.19"}, 
	
	-- 端口
	PORTONLINE = 9012,
	--本地保存的IP
	IPLOCALDAFAULTLIST = {"116.62.166.117",},
	-- HTTP线上配置
	HTTP_ADDRESS_ONLINE = "http://hnhpapi.arthur-tech.com/mjapi/index.php",
	--防御相关
	HTTPLOCALDFAULIST =  {"hnhpapi.arthur-tech.com",},
	HTTPCDNLOCALDFAULIST = {"hnhpapi.arthur-tech.com",},
	-- 创建房间界面的游戏列表
	GAMESLIST = {68},
	-- 用于选择城市场景的配置
	CITYCONF = { 
        list =
        {  
            {name = "桑植96",open =1},
        },
    },
}

-- 麻城
CONFIG[3] = {
	GAME_USERDEFAULT = "mc",
	IPLOCAL = {port = 9012,ip = "112.124.120.19"}, 
	
	-- 端口
	PORTONLINE = 9012,
	--本地保存的IP
	IPLOCALDAFAULTLIST = {"116.62.166.117",},
	-- HTTP线上配置
	HTTP_ADDRESS_ONLINE = "http://hnhpapi.arthur-tech.com/mjapi/index.php",
	--防御相关
	HTTPLOCALDFAULIST =  {"hnhpapi.arthur-tech.com",},
	HTTPCDNLOCALDFAULIST = {"hnhpapi.arthur-tech.com",},
	-- 创建房间界面的游戏列表
	GAMESLIST = {70},
	-- 用于选择城市场景的配置
	CITYCONF = { 
        list =
        {  
            {name = "麻城斗地主",open =1},
            
        },
    },
}

-- 孝感
CONFIG[4] = {
	GAME_USERDEFAULT = "xg",

	IPLOCAL = {port = 9542,ip = "112.124.120.19"}, --应城小字牌
	-- 端口
	PORTONLINE = 9012,
	--本地保存的IP
	IPLOCALDAFAULTLIST = {"116.62.166.117",},
	-- HTTP线上配置
	HTTP_ADDRESS_ONLINE = "http://hnhpapi.arthur-tech.com/mjapi/index.php",
	--防御相关
	HTTPLOCALDFAULIST =  {"hnhpapi.arthur-tech.com",},
	HTTPCDNLOCALDFAULIST = {"hnhpapi.arthur-tech.com",},
	-- 创建房间界面的游戏列表
	GAMESLIST = {76,85},
	GAMESLIST_POKER = {84},--扑克牌列表，斗地主
	-- 用于选择城市场景的配置
	CITYCONF = { 
        list =
        {  
            {name = "孝昌扯胡",open =1},--76
            {name = "应城斗地主",open =1},--84
            {name = "应城小字牌",open =1},--85
        },
    },
}

-- 襄阳
CONFIG[5] = {
	GAME_USERDEFAULT = "xy",
	IPLOCAL = {port = 9012,ip = "112.124.120.19"}, 
	
	-- 端口
	PORTONLINE = 9012,
	--本地保存的IP
	IPLOCALDAFAULTLIST = {"116.62.166.117",},
	-- HTTP线上配置
	HTTP_ADDRESS_ONLINE = "http://hnhpapi.arthur-tech.com/mjapi/index.php",
	--防御相关
	HTTPLOCALDFAULIST =  {"hnhpapi.arthur-tech.com",},
	HTTPCDNLOCALDFAULIST = {"hnhpapi.arthur-tech.com",},
	-- 创建房间界面的游戏列表
	GAMESLIST = {82},
	-- 用于选择城市场景的配置
	CITYCONF = { 
        list =
        {  
            {name = "宜城绞胡",open =1},--71
        },
    },
}
-- 咸宁
CONFIG[6] = {
	GAME_USERDEFAULT = "xn",
	IPLOCAL = {port = 39012,ip = "114.215.188.39"}, 
	
	-- 端口
	PORTONLINE = 9012,
	--本地保存的IP
	IPLOCALDAFAULTLIST = {"116.62.166.117",},
	-- HTTP线上配置
	HTTP_ADDRESS_ONLINE = "http://hnhpapi.arthur-tech.com/mjapi/index.php",
	--防御相关
	HTTPLOCALDFAULIST =  {"hnhpapi.arthur-tech.com",},
	HTTPCDNLOCALDFAULIST = {"hnhpapi.arthur-tech.com",},
	-- 创建房间界面的游戏列表
	GAMESLIST = {88},
	-- 用于选择城市场景的配置
	CITYCONF = { 
        list =
        {  
            {name = "通城个子牌",open =1},--71
        },
    },
}


CONFIG[7] = {
	GAME_USERDEFAULT = "yc",
	IPLOCAL = {port = 9016,ip = "112.124.120.19"}, 
	
	-- 端口
	PORTONLINE = 9012,
	--本地保存的IP
	IPLOCALDAFAULTLIST = {"116.62.166.117",},
	-- HTTP线上配置
	HTTP_ADDRESS_ONLINE = "http://hnhpapi.arthur-tech.com/mjapi/index.php",
	--防御相关
	HTTPLOCALDFAULIST =  {"hnhpapi.arthur-tech.com",},
	HTTPCDNLOCALDFAULIST = {"hnhpapi.arthur-tech.com",},
	-- 创建房间界面的游戏列表
	GAMESLIST = {91,101,102,103},
	-- 用于选择城市场景的配置
	CITYCONF = { 
        list =
        {  
            {name = "宜昌老精",open =1},--91
            {name = "三精花牌",open =1},--71
            {name = "五精花牌",open =1},--71
            {name = "当阳翻精",open =1},--91
        },
    },
}

--城市服务器选择  1恩施 2张家界,3麻城,4孝感 5襄阳 6咸宁,7宜昌
local usablecity = {1,7,6,4,5,3,2}
local unchangekey = {
	["CITY_SELECT_SERVER"]=1,
	["CITY_SELECT_CITY"]=1,
	["OPEN_CITY"]=1,
	["iospaydata"]=1,
	["iospayid"]=1,
	["iosorderid"]=1,
	["fangchengmi"]=1,
}

if getStringForKey == nil  then
	print("set luca ")
	if cc.UserDefault.getIntegerForKey ~= nil then
		print("set luca   not nil",type(cc.UserDefault.getIntegerForKey))
		print("set luca   not nil",type(cc.UserDefault:getInstance().getIntegerForKey))
	end
	getStringForKey =  cc.UserDefault.getStringForKey
	cc.UserDefault.getStringForKey = function(dd,key,data)
		if unchangekey[key] == nil then
			key = CONFIG[GAME_LOCAL_CITY].GAME_USERDEFAULT..key
		end
		return getStringForKey(cc.UserDefault:getInstance(),key,data)
	end

	setStringForKey =  cc.UserDefault.setStringForKey
	cc.UserDefault.setStringForKey = function(dd,key,data)

		if unchangekey[key] == nil then
			key = CONFIG[GAME_LOCAL_CITY].GAME_USERDEFAULT..key
		end
		setStringForKey(cc.UserDefault:getInstance(),key,data)
	end

	getIntegerForKey =  cc.UserDefault.getIntegerForKey
	cc.UserDefault.getIntegerForKey = function(dd,key,data)
		if unchangekey[key] == nil then
			key = CONFIG[GAME_LOCAL_CITY].GAME_USERDEFAULT..key
		end
		-- print("key:"..key)
		-- print(getIntegerForKey(cc.UserDefault:getInstance(),key,data or 0))
		return getIntegerForKey(cc.UserDefault:getInstance(),key,data or 0)
	end

	setIntegerForKey =  cc.UserDefault.setIntegerForKey
	cc.UserDefault.setIntegerForKey = function(dd,key,data)
		if unchangekey[key] == nil then
			key = CONFIG[GAME_LOCAL_CITY].GAME_USERDEFAULT..key
		end
		-- print("key:"..key)
		setIntegerForKey(cc.UserDefault:getInstance(),key,data)
	end
end

function CityManager:ctor()
	-- body
end

function CityManager.getInstance()
	if not CM_INSTANCE then
		CM_INSTANCE = CityManager.new()
	end 
	return CM_INSTANCE
end


function CityManager:getIPLOCAL()
	-- if not CONFIG[GAME_CITY_SELECT] then
	local conf = CONFIG[GAME_CITY_SELECT] or CONFIG[1]

	return islocalnetwork and (conf.IPLOCAL or {port = 9012,ip = "112.124.120.19"})
end

function CityManager:getPORTONLINE()
	local conf = CONFIG[GAME_CITY_SELECT] or CONFIG[1]

	return conf.PORTONLINE
end

function CityManager:getIPLOCALDAFAULTLIST()
	local conf = CONFIG[GAME_CITY_SELECT] or CONFIG[1]

	return conf.IPLOCALDAFAULTLIST
end

function CityManager:getHTTP_ADDRESS_ONLINE()
	local conf = CONFIG[GAME_CITY_SELECT] or CONFIG[1]

	return conf.HTTP_ADDRESS_ONLINE
end

function CityManager:getHTTPLOCALDFAULIST()
	local conf = CONFIG[GAME_CITY_SELECT]

	return conf.HTTPLOCALDFAULIST
end

function CityManager:getHTTPCDNLOCALDFAULIST()
	local conf = CONFIG[GAME_CITY_SELECT] or CONFIG[1]

	return conf.HTTPCDNLOCALDFAULIST
end

--扑克牌的游戏列表
function CityManager:getPOKERGAMESLIST()
	local conf = CONFIG[GAME_CITY_SELECT] or CONFIG[1]

	return conf.GAMESLIST_POKER or {}
end
--麻将的游戏列表
function CityManager:getMAJIANGGAMESLIST()
	local conf = CONFIG[GAME_CITY_SELECT] or CONFIG[1]

	return conf.GAMESLIST_MJ or {}
end

function CityManager:getGAMESLIST()
	local conf = CONFIG[GAME_CITY_SELECT] or CONFIG[1]

	return conf.GAMESLIST or {}
end

function CityManager:getCITYCONF(index)
	local conf = CONFIG[index]

	return (conf and conf.CITYCONF )or {}
end

function CityManager:getUsableCity()
	return usablecity
end

return CityManager.getInstance()