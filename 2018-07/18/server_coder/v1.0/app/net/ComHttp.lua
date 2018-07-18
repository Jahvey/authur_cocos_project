-------------------------------------------------
--   TODO   http请求
--   @author sjp
--   Create Date 2016.10.24
-------------------------------------------------


ComHttp = {}
ComHttp.HTTP_ADDRESS  = CM_INSTANCE:getHTTP_ADDRESS_ONLINE()
-- ComHttp.HTTP_ADDRESS = "http://dev.arthur-tech.com/phzapi/index.php"
ComHttp.shareAddress = ComHttp.HTTP_ADDRESS
ComHttp.loginadress = ""
--table转url
ComHttp.URL = {
    CHECKRESOURCE = "/Tools/updategame",
    LOGIN = "/Login/wechatlogin",
    CHECK_LOGIN = "/Login/wechatchecklogin",
    UPCOORDINATE = "/Userfunc/upcoordinate",
    GETOTHERCOORDINATE = "/Userfunc/getothercoordinate",
    REPORT_CRASH = "/Tools/reportcrash",
    REPORT_PUSHTOKEN = "/Tools/iostoken",
    REPORT_PUSHID = "/Tools/reportjpushid",
    GETONE_COORDINATE = "/Userfunc/getonecoordinate",
    CHECKINVITECODE = "/Market/checkinvitecode",
    MARKET_LIST = "/Market/getlist", 
    INVITECODE = "/Market/invitecode",  
	GETORDER = "/Market/getorder",
    PAOMADENG = "/Tools/marquee",
    IOSPAYHTTP = "/Pay/ios",
    GETNOTICELIST = "/Actcenter/actcenter_list",
    GETNOTICEINFO = "/Actcenter/actcenter_content",
    GETNOTICEREDPOINT =  "/Actcenter/actcenter_config",
    GETFREEAWARD = "/Activity/inviteandfree_getfree",
    BINDDAGENT = "/Invite/bindagent",
    GETINVITEACTSTATE = "/Activity/inviteandfree",
    GETINVITEAWARD = "/Activity/inviteandfree_getinvite",
    REPORTWECHATINVITE = "/Activity/inviteandfree_report",
    GETNOTICEUPDATENEW = "/Tools/noticeupdategamenew",
    MOSTUSERID = "/Userfunc/isactive",
    WECHATREPORT = "/Activity/wechatreport",
    GETACTCONFIG2 = "/Activity1/samewechatlogin_config",
    GETACTAWARD2 = "/Activity1/samewechatlogin_send",
    GETACTSTATE2 = "/Activity1/samewechatlogin_canget",
    SETREALNAME = "Activity1/setrealname",
    GETUSERRANK = "/Userfunc/rank",
    DAILYRANK = "/Activity2/dayrank",
    INCESSANCYSHARE = "/Activity1/incessancyshare_config",
    GETHALLAD = "/maininterface/ad",
    DEBUG_REPORT = "/Debugcode/reportlog",
    DINGDIANWANPAIGET = "/Activity1/timetogetbox_get",
    DINGDIANWANPAI = "/Activity1/timetogetbox_config",
    DINGDIANWANPAILIST = "/Activity1/timetogetbox_list",
    GETSHAREURL = "/Maininterface/sharedomain",
    GETAGENTINFO = "/Activity1/showagentinfo",

    -- 邀请送红包活动
    IFRPGETCONF = "/Activity1/inviteforredpacket_config",
    IFRPGETINVITE = "/Activity1/inviteforredpacket_getinvite",
    IFRPGETSHARE = "/Activity1/inviteforredpacket_getshare",
    IFRPEXCHANGE = "/Activity1/inviteforredpacket_exchange",
    -- 新手三日礼包
    NEWCOMMERGETCONF = "/Activity2/act_novicegiftpack_config",
    NEWCOMMERGETAWARD = "/Activity2/act_novicegiftpack_get",
    -- 邀请码活动
    ICAGETRED = "/Activity1/invitecode_red",
    ICAGETCONF = "/Activity1/invitecode_config",
    ICAGETAWARD1 = "/Activity1/invitecode_left",
    ICAGETLIST= "/Activity1/invitecode_list",
    ICAGETAWARD2 = "/Activity1/invitecode_right",
    --获取游戏的角标配置
    GETGAMETIPS = "/Maininterface/gametips",
    
    -- 召回活动
    RECALLGETLIST = "/Activity2/act_recall",
    RECALLGETAWARD = "/Activity2/act_recall_prize",

    --玩牌打折活动
    FANFKASALE = "Activity3/acttablediscount",
    --限时优惠
    TimeLimit = "/Activity3/timelimitshop",
	
	COURTESYICONF = "/Promote/act_invite_config",
    COURTESYILIST = "/Promote/act_invite_getlist",
    COURTESYIREWARD = "/Promote/act_invite_getreward",

    MAININTERFACE = "/Maininterface/init",

    
}
function ComHttp.tableTourl(tab)
    local poststr = ""
    if tab == nil or type(tab) ~= "table" then
        return poststr
    end
    local isfristadd = true
    for k,v in pairs(tab) do
        if isfristadd then
            isfristadd= false
            poststr = poststr..k.."="..v
        else
            poststr = poststr .."&"..k.."="..v
        end
    end
    return poststr
end

local API_CODE = "R5zPx2psuVQTq7BmTyR2ZFC0OZY0O64L"

local function getRandKey( )
    return os.time() .. math.random(100000, 999999999)
end


function ComHttp.encryptHttp(params)
    local tab
    local str = ""
    if params and params ~= "" then
        tab = string.split(params, "&")
    else
        tab = {}
    end
    -- printTable(tab)
    local randkey = getRandKey()
    local randPara = "randkey="..randkey..cc.UserDefault:getInstance():getIntegerForKey("default_uid",0)
    table.insert(tab, randPara)
    table.insert(tab, "apicode="..API_CODE)
    local function nameSort( a, b )
        return a < b
    end
    table.sort(tab, nameSort)
    for i,v in ipairs(tab) do
        if i > 1 then
            str = str .. "&"
        end
        str = str .. v
    end
    -- print(str)
    local para
    if params then
        para = params .. "&"
    else
        para = ""
    end
    para = para .. randPara .."&securitycode=".. CryTo:Md5(str)
    return para
end


--普通http
-- isencry是否加密
function ComHttp.httpPOST( address,table,callback,isencry)

    table["channeltype"] = CLIENT_QUDAO
    table["osversion"] = device.platform
    table["resversion"] = CONFIG_REC_VERSION
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    print(ComHttp.HTTP_ADDRESS..address)
    if address == "/Tools/updategame" then
         xhr:open("POST", "http://jrhpapi.arthur-tech.com/mjapi/index.php/Tools/updategame")
    else
        xhr:open("POST", ComHttp.HTTP_ADDRESS..address)
    end
    
    local function responsecallback()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            print("success")
            local response   = xhr.response
            local output = cjson.decode(response)
            if not output then
                output = {}
            end 
            -- printTable(output)
            if Notinode_instance and Notinode_instance.showLoading then
                Notinode_instance:showLoading(false)
            end
            if output.serverstatus == nil then
                print("解析php 失败")
            elseif output.serverstatus == 1 then
                if callback then
                    callback(output)
                end
            elseif output.serverstatus == 0 then
                print(output.serverinfo)
                if tonumber(output.servercode) ~= 100007 then
                    LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = output.serverinfo})
                end 
            else
                print("不存在的 serverstatus参数")
            end
        else
            print(" PHP  网页 出错 了, 或者没有网络")
            if Notinode_instance and Notinode_instance.showLoading then
                Notinode_instance:showLoading(false)
            end
            -- LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "网络连接错误"})
            --网络连接错误
            -- self:popbox(getStr("checkversion_title8"),function()
            --     self:checkversion()
            -- end)
            -- http error
        end
    end 
    local poststr = "result="..json.encode(table,1)
    
    --print("address:"..CommonUtils.HTTP_ADDRESS..address)
    -- print("address:"..CommonUtils.HTTP_ADDRESS..address)
    xhr:registerScriptHandler(responsecallback)
    print("sd:"..ComHttp.tableTourl(table))
    -- 默认加密
    if isencry == nil then
        isencry = true
    end
    -- 加密
    if isencry then
        xhr:send(ComHttp.encryptHttp(ComHttp.tableTourl(table)))
    else
        xhr:send(ComHttp.tableTourl(table)) 
    end 
    return xhr
end
-- 上报经纬度
function ComHttp.reportPos()
    --print("上单定位")
    Notinode_instance.reportnode:stopAllActions()
     Notinode_instance.reportnode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(function( ... )
        ComHttp.reportPos()
    end))))
    -- 获取经纬度
    CommonUtils.getLocaitioninfo()
    if LocalData_instance.uid then
        if LocalData_instance.longitude ~= "empty" then
            
            print("上传定位:"..LocalData_instance.longitude.."  "..LocalData_instance.latitude)
            ComHttp.httpPOST(ComHttp.URL.UPCOORDINATE,{uid= LocalData_instance.uid,lng = LocalData_instance.longitude,lat =LocalData_instance.latitude},function(msg) 
                
                 Notinode_instance.reportnode:stopAllActions()
            end)
        end
    end
end
-- 上报token
function ComHttp.reportToken()
    CommonUtils.getpushToken(function(token)
        print("上传的token:"..token)
         ComHttp.httpPOST(ComHttp.URL.REPORT_PUSHTOKEN,{uid= LocalData_instance.uid,token = token},function(msg) 
            print("上报成功")
        end)
    end)
    --同时也检测 ios 支付
    IOSPayCallback(true)
end
function ComHttp.reportpaomading()
    ComHttp.httpPOST(ComHttp.URL.PAOMADENG,{uid= LocalData_instance.uid},function()
    end)
end

-- 极光推送 registration_id 
function ComHttp.reportPushRegisId()
    CommonUtils.getpushToken(function(id)
        print("上传的id:"..id)
        if id and id ~= "" then
            ComHttp.httpPOST(ComHttp.URL.REPORT_PUSHID,{uid= LocalData_instance.uid,id = id},function(msg) 
                print("上报推送id成功")
            end)
        end 
    end)
end

--ios支付返回
function IOSPayCallback(islogin)
    Notinode_instance:showLoading(false)
    print("IOSPayCallback")
    local paydata = readPaylocalmsgData()
    if paydata == nil  or type(paydata) ~= "table" then
        print(" nil  or  not table")
        return 
    end
    for k,v in pairs(paydata) do
        local receiptstr = v.data
        local orderidstr = v.orderid
        local payid = v.payid --暂时没用上

        if receiptstr and receiptstr ~= "" then
            if islogin then
                Notinode_instance:showLoading(true,7)
            else
                Notinode_instance:showLoading(true,6)
            end

             ComHttp.httpPOST(ComHttp.URL.IOSPAYHTTP,{receipt = receiptstr,orderid = orderidstr,uid = LocalData_instance.uid},function(msg) 
                 if msg.serverstatus == 1 then
                    print("充值成功")
                else
                    print("充值失败")
                end
                paydata[k] = nil
                if paydata == {} or paydata == nil then
                    savePaylocalmsgData("")
                    print("没有数据了")
                    Notinode_instance:showLoading(false)
                else
                    savePaylocalmsgData(paydata)
                    print("还有数据")
                    -- printTable(paydata, "sjp")
                end
            end)
        end
    end
end

function ComHttp.getorder(info)

    Notinode_instance:showLoading(true,4)
    -- cc.UserDefault:getInstance():setStringForKey("iospaydata", "")
    -- cc.UserDefault:getInstance():setStringForKey("iospayid", "")
    -- cc.UserDefault:getInstance():setStringForKey("orderid", "")

    -- -- local output = cjson.decode(msg.package_json)
    -- -- printTable(output,"sjp3")
    -- luaoc.callStaticMethod("RootViewController","iosPay",{id = "",orderid = "output.orderid",callback = IOSPayCallback})
    
    ComHttp.httpPOST(ComHttp.URL.GETORDER,{uid= LocalData_instance.uid,paytype = info.paytype,mid = info.mid},function(msg) 
        print("请求订单号成功")
        if msg.serverstatus == 1 then
            if msg.url and SHENHEBAO == false then
                CommonUtils.openUrl(msg.url)
            else
                print("msg.package_json ===",msg.package_json)
                if device.platform == "ios" then

                    cc.UserDefault:getInstance():setStringForKey("iospaydata", "")
                    cc.UserDefault:getInstance():setStringForKey("iospayid", "")
                    cc.UserDefault:getInstance():setStringForKey("orderid", "")

                    -- local output = cjson.decode(msg.package_json)
                    -- printTable(output,"sjp3")
                    Notinode_instance:showLoading(true,5)
                    luaoc.callStaticMethod("RootViewController","iosPay",{id = info.productid,orderid = msg.orderid,callback = IOSPayCallback})
                elseif device.platform == "android" then
                    local str = cjson.encode(msg.package_json)
                    print("========str = ",str)
                    luaj = require("cocos.cocos2d.luaj")
                    local function callback(msg)
                        print("打开成功")
                    end
                    local className = NOWANDROIDPATH
                    local methodName = "paytype"
                    local args  =  {str,msg.orderid,callback}
                    local sig = "(Ljava/lang/String;Ljava/lang/String;I)V"
                    luaj.callStaticMethod(className, methodName, args, sig) 
                end 
            end
        end
    end)
end


function savePaylocalmsgData(tab)
    local name = CryTo:Md5("pay_localdata")
    local directory = string.gsub(device.writablePath, "[\\\\/]+$", "") .. device.directorySeparator.. "paylocal" .. device.directorySeparator
    if not cc.FileUtils:getInstance():isDirectoryExist(directory) then
        cc.FileUtils:getInstance():createDirectory(directory)
        -- require "lfs"   
        -- lfs.mkdir(directory) --目录不存在，创建此目录
    end

    local path = directory .. name
    local str = json.encode(tab)
    io.writefile(path, str)
end

function readPaylocalmsgData()
    local path = string.gsub(device.writablePath, "[\\\\/]+$", "") .. device.directorySeparator.. "paylocal" .. device.directorySeparator .. CryTo:Md5("pay_localdata")
    if not cc.FileUtils:getInstance():isFileExist(path) then
        return nil
    else
        local data = io.readfile(path)
        if data then
            local datajson = json.decode(data)
            if datajson == nil then
                os.remove(path)
            end
            return datajson
        else
            return nil
        end
    end
end

function globalPaycallios()
    print("globalPaycallios")
    local paydata = readPaylocalmsgData()
    if paydata == nil or paydata == "" then
        paydata = {}
    end

    local paydatastr = cc.UserDefault:getInstance():getStringForKey("iospaydata","")
    local payidstr = cc.UserDefault:getInstance():getStringForKey("iospayid","")
    local orderidstr = cc.UserDefault:getInstance():getStringForKey("iosorderid","")

    for i=1,1000 do
        local key = "key"..i
        if paydata[key]  == nil then
            paydata[key] = {orderid = orderidstr,data = paydatastr,payid = payidstr}
            break
        end
    end
    --for i=1,1000 then
    --end
    savePaylocalmsgData(paydata)

    -- printTable(paydata, "sjp")
    print("globalPaycallios end")
end



