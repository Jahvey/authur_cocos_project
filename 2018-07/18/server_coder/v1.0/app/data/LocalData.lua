

-------------------------------------------------
--   TODO   数据管理。包含玩家信息和本地设置(严格按照set/get方法操作)
--   @author sjp
--   Create Date 2016.10.24
-------------------------------------------------

-- 快速发言文字
QUICK_CHAT_LIST = {
    "别吵啦，别吵啦，专心玩儿游戏吧", 
    "催什么，我在想打哪张",   
    "快点儿啊，等的我花儿都谢啦", 
    "美女，你缺哪张，我打给你",
    "土豪，我们做朋友吧", 
    "喂，你这么牛叉，你家人知道吗",  
    "我是菜鸟，大侠，手下留情啊",
    "怎么又断线了，网络也忒差啦",  
}


-- 表情
EMOJ_LIST = {
    "E00E","E02B","E043","E04F","E051","E052","E053",
    "E056","E057","E058","E059","E105","E106","E107",
    "E108","E252","E401","E402","E403","E404","E405",
    "E406","E407","E408","E409","E40A","E40B","E40C",
    "E40D","E40E","E40F","E410","E411","E412","E413",
    "E414","E415","E416","E417","E418","E41D","E41F",
    "E420","E421","E428","E52B","E52D","E52E"   
}

-- 快速发言文字
QUICK_CHAT_LIST_fjsdr = {
    "俩们快点撒，撒焖慢啰", 
    "催什嘛儿催，让我想哈哆",   
    "我今儿列个胡很有点大，俩们招呼点哦", 
    "好好打牌，莫日大瞎。",
    "搞不得哒，瞌睡来哒", 
    "输家不开口，赢家不许走",  
    "你哈招哒，我还进个花儿哦",
    "莫舍不得流量，开个4G噻，太慢哒",  
}

QUICK_CHAT_LIST_sjhp = {
    "俩们快点撒，撒焖慢啰", 
    "紧在性些嘛咧，快点噻",   
    "俩儿是不是睡着哒。", 
    "你在磨洋工啊，我等滴无交果哒",
    "你急嘛急，你早点着急，孙儿都多大哒", 
    "催什嘛儿催，让我想哈duo。",  
    "莫舍不得流量，开个4G噻，太慢哒",
    "你哈招哒，我还进个花儿哦。",  
    "俩们太铁哒，直巴铁匠都么得勒么铁。",  
    "俩们都太会打哒。",  
}   


local LocalData = class("LocalData",function()
    return {}
end)
function LocalData:getInstance()
	if not LocalData_instance then
	    LocalData_instance = self.new()
	end
	return LocalData_instance
end
function LocalData:ctor()
    self.openUDID = nil
    self.nick = nil
    self.uid = nil
    self.pic = nil
    self.chips = 0
    -- 性别 0 男 1 女 2 不识别
    self.gender = nil
    self.token = nil
    -- 客户端保存，用户下次校验
    self.wechatid = nil  
    -- 是否新用户
    self.is_created = nil
    -- ip
    self.login_ip = nil
    --音效 音乐  默认  1 为开启  0 为关闭
    --登录类型
    self.logintype = nil
    self.effect = nil
    self.music = nil
    self.use_heart_beat = nil 
    self.heart_beat_interval = nil
    -- 经度
    self.longitude = nil
    -- 纬度
    self.latitude = nil
    self.info = {}
    self.gameType = 60

    --gameIP的 请求ip
    self.list_ip = nil
    self.connect_ip = nil

    --登录返回是不是token错误
    self.isTokenError = false

end

function LocalData:reset()
    self.logintype = nil
    self.is_created = nil
    self.wechatid = nil
    self.token = nil
    self.gender = nil
    self.nick = nil
    self.uid = nil
    self.pic = nil
    self.gender = nil
    self.login_ip = nil
    self.info = {}
end
 -- 60，金堂考考
function LocalData:getGameType()
    -- self.gameType =  cc.UserDefault:getInstance():getIntegerForKey("select_gametype",60)
    return self.gameType
end
function LocalData:setGameType(_type)
    self.gameType = _type
    -- cc.UserDefault:getInstance():setIntegerForKey("select_gametype",_type)
end


function LocalData:getlogintype()
    return self.logintype
end

function LocalData:setlogintype(type)
    self.logintype  = type
end

function LocalData:set(info)
    for key,value in pairs(info) do
        self.info[key] = value
    end
    if info.uid then
        -- self.uid = info.uid
        self:setUid(info.uid)
    end
    if info.chips then
        self.chips = info.chips
    end 
    if info.nick then
        self.nick = info.nick
    end
    if info.pic_url then
        self.pic = info.pic_url
    end
    if info.last_login_ip then
        self.login_ip = CommonUtils.getIpStr(info.last_login_ip)
    end
    if info.gender then
        self.gender = info.gender
    end
end
function LocalData:get(key)
    if not key then
        return
    end
    return self.info[key]
end
function LocalData:getopenUDID()
    local oppenid = cc.UserDefault:getInstance():getStringForKey("LocalData_openUDID","")
    if oppenid == "" then
      CommonUtils.getOpenuuid(function(openuid)
                oppenid= openuid
                print("oppendid:"..openuid)
            end)
    end
    cc.UserDefault:getInstance():setStringForKey("LocalData_openUDID",oppenid)
    cc.UserDefault:getInstance():flush()
    return oppenid
end
function LocalData:setUid(uid)
	self.uid = uid
    cc.UserDefault:getInstance():setIntegerForKey("default_uid",uid)
    -- print("=============1===",uid)
end

function LocalData:getUid()
    if not self.uid or self.uid == 0 then
        self.uid = cc.UserDefault:getInstance():getIntegerForKey("default_uid")
    end 
	return self.uid
end
function LocalData:setChips(val)
    self.chips = val
end
function LocalData:getChips()
    return self.chips
end
-- account
function LocalData:setAccount(value)
    self.account = value
end
function LocalData:getAccount()
    return self.account
end
-- 昵称
function LocalData:setNick(nick)
    self.nick = nick
end
function LocalData:getNick()
    return self.nick
end
-- 性别
function LocalData:setSex(value)
    self.gender = value
end
function LocalData:getSex()
    return tonumber(self.gender)
end
-- 头像
function LocalData:setPic(value)
    self.pic = value
end
function LocalData:getPic()
    return self.pic
end
function LocalData:setLoginIp(value)
    self.login_ip = CommonUtils.getIpStr(value)
end
-- IP
function LocalData:getLoginIp()
   return self.login_ip 
end
-- token
function LocalData:setToken(value)
    self.token = value
end
function LocalData:getToken()
    return self.token
end
-- 是否新用户
function LocalData:setIsCreated(bol)
    self.is_created = bol
end
function LocalData:getIsCreated()
    return self.is_created
end
-- gameIP 的  请求ip
function LocalData:setlist_ip(ip)
    if ip == nil  then
        self.list_ip = nil
    else
        self.list_ip = CommonUtils.getIpStr(ip) 
    end
end
function LocalData:getlist_ip()
   return self.list_ip 
end

function LocalData:setconnect_ip(ip)
    if ip == nil  then
        self.connect_ip = nil
    else
        self.connect_ip = CommonUtils.getIpStr(ip) 
    end
end
function LocalData:getconnect_ip()
   return self.connect_ip 
end


-- self.wechatid
function LocalData:setWechatid(value)
    self.wechatid = value
    cc.UserDefault:getInstance():setStringForKey("WechatId",self.wechatid )
end
function LocalData:getWechatid()
    if not self.wechatid then
        self.wechatid = cc.UserDefault:getInstance():getStringForKey("WechatId")
    end
    if self.wechatid == "" then
        return nil
    end
    return self.wechatid
end
-- use_heart_beat
function LocalData:setUseHeartBeat(value)
    self.use_heart_beat = value
end
function LocalData:getUseHeartBeat()
    return self.use_heart_beat
end
-- heart_beat_interval
function LocalData:setHeartBeatinterval(value)
    self.heart_beat_interval = value
end
function LocalData:getHeartBeatinterval()
    return self.heart_beat_interval
end
function LocalData:setCreateRoomConfig(key,value)
    cc.UserDefault:getInstance():setStringForKey("CreateRoomV1.2"..key,value)
end

function LocalData:getCreateRoomConfig(key)
    return cc.UserDefault:getInstance():getStringForKey("CreateRoomV1.2"..key)
end

function LocalData:setSelfLocalVoiceHandle(value)
    self.send_self_local_voice_handle_data = value
end
function LocalData:getSelfLocalVoiceHandle()
    return self.send_self_local_voice_handle_data
end

function LocalData:getbaipai_stype()
    -- if true then
    --     return 2
    -- end
    return cc.UserDefault:getInstance():getIntegerForKey(self:getUid().."bg_type_new1", 1)
end

function LocalData:setbaipai_stype( stype )
    if stype~= 1 and stype~= 2 then
    else
        cc.UserDefault:getInstance():setIntegerForKey(self:getUid().."bg_type_newlocal", stype)
    end
end
function LocalData:setbaipai_stype_real()
    local stype = cc.UserDefault:getInstance():getIntegerForKey(self:getUid().."bg_type_newlocal", 1)
    cc.UserDefault:getInstance():setIntegerForKey(self:getUid().."bg_type_new1", stype)
end

--设置收费的游戏列表
function LocalData:setFeeList(list)
    self.feeList = list
end
function LocalData:getIsFeeByGameType(_type)
    if not self.feeList then
        return false
    end
    for k,v in pairs(self.feeList) do
       if v.gametype == _type  then
            if v.isFee == 1 then
                return true
            else
                return false
           end
       end
    end
    return false
end


function LocalData:setIsTokenError(_bool)
    self.isTokenError = _bool
end
function LocalData:getIsTokenError()
    return self.isTokenError
end

--玩牌中的癞子牌，斗地主的
function LocalData:setLaiZiValuer(_card)
    if _card == 0 then
        _card = -2
    end

    self.laiZi = _card or -2
end
function LocalData:getLaiZiValuer()
    return self.laiZi or -2
end


function LocalData:setVisualAngleUID(uid)
    self.visual_uid = uid
end

function LocalData:getVisualAngleUID()
    return self.visual_uid
end


function LocalData:getIsSale(_type)
    return self.visual_uid
end
--设置限时打折活动
function LocalData:setSaleData(_data)
    self.saleData = _data
end
function LocalData:getIsSale(_type)
    if not self.saleData then
        return nil
    end
    local _time = os.time()
    if  _time < self.saleData.starttime  or  _time > self.saleData.endtime  then
        return nil
    end

    local datetab  = os.date("*t")
    local _hour = datetab.hour or 0  
    local _min = datetab.min or 0  
    local allMin = _hour * 60 +  _min
    if  allMin < tonumber(self.saleData.startmin)  or  allMin > tonumber(self.saleData.endmin)  then
        return nil
    end

    local list = self.saleData.list
    if #list == 0 then
        return nil
    end
    for k,v in pairs(list) do
        if v.game_type == _type then
            local _data = {}
            for kk,vv in pairs(v.round_list) do
                _data[vv.round] = vv.discount / 100.0
            end
            return _data
        end 
    end
    return nil
end

LocalData:getInstance()