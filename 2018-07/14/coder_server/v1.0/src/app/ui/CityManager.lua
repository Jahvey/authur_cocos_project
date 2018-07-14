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
local islocalnetwork = true
-- 恩施
CONFIG[1] = {
	GAME_USERDEFAULT = "hc",
	--IPLOCAL = {port = 34102,ip = "114.215.188.39"},
	IPLOCAL = {port = 9016,ip = "112.124.120.19"}, 
	

	--陈超冲 54013 ，9542，112.124.120.19 
	--胡凯 9012  112.124.120.19,
	--超神 9052 112.124.120.19,

	-- IPLOCAL = {port = 9022,ip = "114.215.188.39"}, 
	--浩源 9022 114.215.188.39,
	--朱柯 29062 114.215.188.39,
	-- 端口
	PORTONLINE = 9012,
	--本地保存的IP
	IPLOCALDAFAULTLIST = {
		"39.108.246.109",
	},
	-- HTTP线上配置
	HTTP_ADDRESS_ONLINE = "http://jrpkapi.arthur-tech.com/mjapi/index.php",
	--防御相关
	HTTPLOCALDFAULIST =  {"jrpkapi.arthur-tech.com",},
	HTTPCDNLOCALDFAULIST = {"jrpkapi.arthur-tech.com",},
	-- 创建房间界面的游戏列表
	GAMESLIST = {87},--花牌列表
	-- 用于选择城市场景的配置
	CITYCONF = { 
        list =
        {  
            {name = "河池牛鬼",open =1},
        },
    },
}



--城市服务器选择  1 恩施 2 张家界,麻城,孝感
local usablecity = {1}

local unchangekey = {
	["CITY_SELECT_SERVER"]=1,
	["CITY_SELECT_CITY"]=1,
	["OPEN_CITY"]=1,
	["iospaydata"]=1,
	["iospayid"]=1,
	["iosorderid"]=1,
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