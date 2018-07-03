-------------------------------------------------
--   TODO   工具函数
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
CommonUtils = {}

-- ***无限调度***
-- @node    [node]      节点
-- @delay   [number]    延迟
-- @callfun [function]  回调函数
-- @count   [number]    运行次数
function CommonUtils.schedule(node, delay, callfun, count)
    local lastTime = 0
    local act      = nil 
    local lasttime = os.time()
    local onSchedule = function(object)
        if (count) then 
            -- print ("count", count)
            if (count>0) then 
                count = count - 1 
            else
                node:stopAction(act)
                return
            end 
        end 

        local curtime = os.time()
        callfun(curtime-lasttime)
        lasttime = curtime
    end
    act = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(delay),cc.CallFunc:create(onSchedule)))
    node:runAction(act)
    return act
end

-- 秒转化成小时：分：秒
function CommonUtils.secondChangeToTime(time)
    local second= time%60
    time = math.floor(time / 60)

    local minute= time%60
    time = math.floor(time / 60)

    local hour= time%24
    local day = math.floor(time / 24)

    return second,minute,hour,day
end
-- 点号动画
function CommonUtils.tipAction(label,str)
    label:setString(str)
    label:stopAllActions()
    local count = 0
    local callfunc = function() 
        count = count + 1
        if (count % 4) == 0 then
            label:setString(str)
        elseif (count % 4) == 2 then
            label:setString(str.."..")
        elseif (count % 4) == 1 then
            label:setString(str..".")
        elseif (count % 4) == 3 then
            label:setString(str.."...")
        end 
    end
    CommonUtils.schedule(label, 0.2, callfunc)
end
-- 得到ip
-- ::ffff:171.212.115.7  ipv6 的格式
function CommonUtils.getIpStr(str)
    if not str then
        return ""
    end
    local a,b = string.find(str,"f:")
    local ip = str
    if b then
        ip = string.sub(str,b+1)
    end
    return ip
end
-- 得到距离字符串
function CommonUtils.getDistanceStr(distance)
    if not distance then
        return "未知"
    end
    print(distance)
    if distance == "empty" then
        return "未知"
    end
    distance = tonumber(distance)
    if distance then
        if distance > 1000 then
            if distance % 1000 == 0 then 
                return "相距"..string.format("%d".."km",(distance/1000))
            else
                return "相距"..string.format("%.2f".."km",(distance/1000))
            end 
        else
            if math.floor(distance)< distance then
                return "相距"..string.format("%.2f".."m",distance)
            else
                return "相距"..string.format("%d".."m",distance)
            end 
        end
    end
end
function CommonUtils.shareScreen()
    local function afterCaptured(succeed, outputFile)
        if device.platform == "android" then
            luaj = require("cocos.cocos2d.luaj")
            local function logincallback(code)
                print("====分享成功")
            end
            local className = "com/dazhongjuyou/moretop/wxapi/WXEntryActivity"
            local methodName = "sharepic"
            local args  =  {outputFile,0}
            local sig = "(Ljava/lang/String;I)V"
            luaj.callStaticMethod(className, methodName, args, sig)
        elseif device.platform == "ios" then
            luaoc.callStaticMethod("RootViewController","weixinsharepic",{path = outputFile})
        end
    end
    cc.utils:captureScreen(afterCaptured, "jietu_1.png")
end


-- 分享游戏
function CommonUtils.sharegame(flag)
    if flag == 1 then
        ISPYQUAN =true
    else
        ISPYQUAN =false
    end
    if device.platform == "android" then
        luaj = require("cocos.cocos2d.luaj")
        local function logincallback(code)
            print("====分享成功")
        end
        local className = "com/dazhongjuyou/moretop/wxapi/WXEntryActivity"
        local methodName = "share2weixin"
        print(cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"))
        local args  =  {"聚闲有游戏    招募代理，合作共赢","大众聚友棋牌是一款扑克类棋牌。","http://fir.im/8txm",cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),flag or 0}
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
        luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
        luaoc.callStaticMethod("RootViewController","weixinshare",{url = "http://fir.im/8txm",flag = flag or 0,title = "聚闲有游戏    招募代理，合作共赢",disc = "大众聚友棋牌是一款扑克类棋牌。",pic = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png")})
    end
end

-- 分享游戏
function CommonUtils.sharegameforpy()
    local flag = 1
    if flag == 1 then
        ISPYQUAN =true
    else
        ISPYQUAN =false
    end
    local outputFile = cc.FileUtils:getInstance():fullPathForFilename("common/share.png")
    if device.platform == "android" then
            luaj = require("cocos.cocos2d.luaj")
            local function logincallback(code)
                print("====分享成功")
            end
            local className = "com/dazhongjuyou/moretop/wxapi/WXEntryActivity"
            local methodName = "sharepic"
            local args  =  {outputFile,1}
            local sig = "(Ljava/lang/String;I)V"
            luaj.callStaticMethod(className, methodName, args, sig)
        elseif device.platform == "ios" then
            luaoc.callStaticMethod("RootViewController","weixinsharepic",{path = outputFile,flag = 1})
        end
end



-- 分享排座
function CommonUtils.sharedesk(tableid,info,name)
    ISPYQUAN =false
    if device.platform == "android" then
        luaj = require("cocos.cocos2d.luaj")
        local function logincallback(code)
            print("====分享成功")
        end
        local className = "com/dazhongjuyou/moretop/wxapi/WXEntryActivity"
        local methodName = "share2weixin"
        print(cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"))
        local str1 = name.."规则:"..info.."速度加入【聚闲有游戏】。"
        local str2 = "http://fir.im/8txm"
        local args  =  {name.." 房号【"..tableid.."】   招募代理，合作共赢",str1,str2,cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),0}
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
        luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
        local tableinfo  = {url = "http://fir.im/8txm",flag = 0,title = name.." 房号【"..tableid.."】   招募代理，合作共赢",disc = "规则:"..info.."速度加入【聚闲有游戏】。",pic = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png")}
        luaoc.callStaticMethod("RootViewController","weixinshare",tableinfo)
    end
end

function CommonUtils:prompt(text, typ)
    if not typ then
        typ = CommonUtils.TYPE_CENTER
    end
    local x = display.cx
    local y
    if typ == CommonUtils.TYPE_CENTER then
        y = display.cy
    elseif typ == CommonUtils.TYPE_MOVE then
        y = display.cy
    else
        y = 390
    end


    if typ ~= CommonUtils.TYPE_MOVE and cc.Director:getInstance():getRunningScene():getChildByName("prompttip") then
       cc.Director:getInstance():getRunningScene():getChildByName("prompttip"):removeFromParent() 
    end


    local scene = cc.Director:getInstance():getRunningScene()
    local bg = ccui.ImageView:create("banner/board_fuzi.png")
    bg:setPosition(x, y)
    bg:setName("prompttip")
    scene:addChild(bg,2)


    local s = bg:getContentSize()
    local label = cc.Label:createWithSystemFont(text or "", "", 24, cc.size(600, 180), cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    label:setColor(cc.c3b(0xce, 0xcc, 0xcc))
    bg:addChild(label,2)
    label:setPosition(s.width/2, s.height/2)
    label:setAnchorPoint(cc.p(0.5, 0.5))


    local fadeIn = cc.FadeIn:create(0.3)
    local delaytime = cc.DelayTime:create(0.8);
    local move = cc.MoveBy:create(0.6,cc.p(0,100))
    local fadeOut = cc.FadeOut:create(0.3)
    local fun = cc.CallFunc:create(function ()
        bg:removeFromParent()
    end)
    local seq
    if typ == CommonUtils.TYPE_MOVE then
        fadeOut = cc.FadeOut:create(0.5)
        seq = cc.Sequence:create(move,fadeOut, fun, nil);
    else    
        seq = cc.Sequence:create(fadeIn, delaytime, fadeOut, fun, nil);
    end    
    bg:runAction(seq)
end

--位子信息
function CommonUtils.getLocaitioninfo()
    if device.platform == "android" then
        luaj = require("cocos.cocos2d.luaj")
        local function callback(str)
            local tab = string.split(str, "&")
            if tab[1] and tonumber(tab[1]) == 1 then
                -- CommonUtils:prompt(tab[2]..":"..tab[3])
                LocalData_instance.longitude = tab[2]
                LocalData_instance.latitude  = tab[3]
                print("===Longitude=="..tab[2].."===Latitude=="..tab[3])
            else
                print("没有pos ===")
                LocalData_instance.longitude = "empty"
                LocalData_instance.latitude = "empty"
            end
        end
        local className = "com/dazhongjuyou/moretop/wxapi/WXEntryActivity"
        local methodName = "getLocationData"
        local sig = "(I)V"
        luaj.callStaticMethod(className, methodName, {callback}, sig)
    elseif device.platform == "ios" then
        local function callback(isget, longitude,latitude)
            if isget then
                print("get location  data")
                print(longitude)
                print(latitude)
                LocalData_instance.longitude = longitude
                LocalData_instance.latitude = latitude
            else
                print("no get location  data")
                LocalData_instance.longitude = "empty"
                LocalData_instance.latitude = "empty"
            end
        end
        luaoc.callStaticMethod("RootViewController","getDistance",{callback = callback})
    else
        LocalData_instance.longitude = "empty"
        LocalData_instance.latitude = "empty"
    end 
end


function CommonUtils.getDianliangLevel(fuc)
    if device.platform == "android" then
            luaj = require("cocos.cocos2d.luaj")
            local function getdian(value)
                fuc(value)
            end
            local className = "com/dazhongjuyou/moretop/wxapi/WXEntryActivity"
            local methodName = "getDian"
            local args  =  {getdian}
            local sig = "(I)V"
            luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
        local function callback(value)
            fuc(value*100)
        end
        luaoc.callStaticMethod("RootViewController","getBatteryQuantity",{callback = callback})
    end
end

function CommonUtils.copyfang(tableid)
    if device.platform == "android" then
            luaj = require("cocos.cocos2d.luaj")
            
            local className = "com/dazhongjuyou/moretop/wxapi/WXEntryActivity"
            local methodName = "copyClipboard"
            local args  =  {tostring(tableid)}
            local sig = "(Ljava/lang/String;)V"
            luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
       
        luaoc.callStaticMethod("RootViewController","copyClipboard",{copy = tostring(tableid)})
    end
end
function CommonUtils.getpushToken(fuc)

    if device.platform == "android" then
            luaj = require("cocos.cocos2d.luaj")
            local function callback(regId)
                print("regId.."..regId)
                fuc(regId)
            end
            local className = "com/dazhongjuyou/moretop/wxapi/WXEntryActivity"
            local methodName = "getPushRegId"
            local args  =  {callback}
            local sig = "(I)V"
            luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
        local function callback(value)
            print("token:"..value)
            local localtoken = string.gsub(value, "<", "")
            localtoken = string.gsub(localtoken, ">", "")
            localtoken = string.gsub(localtoken, " ", "")
            fuc(localtoken)
        end
        luaoc.callStaticMethod("RootViewController","getToken",{callback = callback})
    end

end

-- 打开网页
function CommonUtils.openUrl(url)
    if device.platform == "android" then
            luaj = require("cocos.cocos2d.luaj")
            local function callback(msg)
                print("打开成功")
            end
            local className = "com/dazhongjuyou/moretop/wxapi/WXEntryActivity"
            local methodName = "openUrl"
            local args  =  {url,callback}
            local sig = "(Ljava/lang/String;I)V"
            luaj.callStaticMethod(className, methodName, args, sig) 
    elseif device.platform == "ios" then    
        luaoc.callStaticMethod("RootViewController","openUrl",{contenturl = url})
    end
end


-- 是否安装了微信
function CommonUtils.isInstallweichat(fuc)
    if device.platform == "ios" then
        local function callback(isinstall)
            fuc(isinstall)
        end
        luaoc.callStaticMethod("RootViewController","weixinInstance",{callback = callback})
    else
        return true
    end
end


-- 是否安装了微信
function CommonUtils.getOpenuuid(fuc)
    if device.platform == "ios" then
        luaoc.callStaticMethod("RootViewController","getUUID",{callback =function(openuuid)
            fuc(openuuid)
        end})
    elseif device.platform == "android" then
        math.randomseed(os.time())
        local id = os.time()..math.random(100000,9999999)
        fuc(id)
    end
end


-- 
function CommonUtils.zhengdong()
     if device.platform == "android" then
            luaj = require("cocos.cocos2d.luaj")
            local className = "com/dazhongjuyou/moretop/wxapi/WXEntryActivity"
            local methodName = "zDong"
            local args  =  {}
            local sig = "()V"
            luaj.callStaticMethod(className, methodName, args, sig) 
    elseif device.platform == "ios" then
         luaoc.callStaticMethod("RootViewController","zDong")
    end  
       
end

function CommonUtils.getcopy( fuc )
    local callback =  function(qudao)
            if tonumber(qudao) and string.len(tostring(qudao)) == 6 then
                fuc(tostring(qudao))
            end
        end
    if device.platform == "android" then
         luaj = require("cocos.cocos2d.luaj")
    
        local className = "com/dazhongjuyou/moretop/wxapi/WXEntryActivity"
        local methodName = "getcopy"
        local args  =  {callback}
        local sig = "(I)V"
        luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
        luaoc.callStaticMethod("RootViewController","getcopy",{callback =callback})
    else
        callback("101258")
    end
end


function CommonUtils.exitgame()

    if device.platform == "android" then
        luaj = require("cocos.cocos2d.luaj")
        local className = "com/dazhongjuyou/moretop/wxapi/WXEntryActivity"
        local methodName = "exitgame"
        local args  =  {}
        local sig = "()V"
        luaj.callStaticMethod(className, methodName, args, sig) 
    end
end
