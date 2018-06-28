

-------------------------------------------------
--   TODO   数据管理。包含玩家信息和本地设置(严格按照set/get方法操作)
--   @author sjp
--   Create Date 2016.10.24
-------------------------------------------------
LocalData_instance = nil
local LocalData = class("LocalData",function()
    return {}
end)
function LocalData:getInstance()
	if not LocalData_instance then
        print("new LocalData_instance")
	    LocalData_instance = self.new()
	end
	return LocalData_instance
end
function LocalData:ctor()
    self["playerid"] = nil
    self["nickname"] = nil
    self["sex"] =  nil
    self["openid"] =  nil
    self["gamecoins"] =  nil
    self["serverinfo"] =   nil
    self["gamestatus"] =  nil
    self["headimgurl"] =  nil
    self["userid"] =  nil
    self["ip"] =  nil
end

function LocalData:reset()
    print("reset")
    self["playerid"] = nil
    self["nickname"] = nil
    self["sex"] =  nil
    self["openid"] =  nil
    self["gamecoins"] =  nil
    self["serverinfo"] =   nil
    self["gamestatus"] =  nil
    self["headimgurl"] =  nil
    self["userid"] =  nil
    self["ip"] =  nil
end

function LocalData:set(info)
    self["playerid"] = info.playerid
    self["nickname"] = info.nickname
    self["sex"] =  info.sex
    self["openid"] =  info.openid
    self["gamecoins"] =  info.gamecoins
    self["serverinfo"] =   info.serverinfo
    self["gamestatus"] =  info.gamestatus
    self["headimgurl"] =  info.headimgurl
    self["userid"] =  info.userid
    self["ip"] =  info.ip
end
function LocalData:get(key)
    if not key then
        return self
    end
    return self[key]
end

function LocalData:getChips()
    return self["gamecoins"]
end
function LocalData:getUid()
    return self["userid"]
end
function LocalData:getIp()
    return self["serverinfo"].severip
end

function LocalData:getPort()
    return self["serverinfo"].serverport
end

function LocalData:getPic()
    return self["headimgurl"]
end

LocalData:getInstance()