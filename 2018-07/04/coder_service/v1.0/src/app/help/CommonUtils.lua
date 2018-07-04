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

--将时间转换为时:分:秒 00:00:00
function CommonUtils.getDateString(time)
    if (tonumber(time) <= 0) then 
        return "00:00:00"
    else
        return string.format("%02d:%02d:%02d",math.floor(time/(60*60)),math.floor((time/60)%60),time%60)
    end
end

--将时间转换为分:秒 00:00
function CommonUtils.getTimeString(time)
    if (tonumber(time) <= 0 ) then 
        return "00：00"
    else
        return string.format("%02d:%02d",math.floor((time/60)%60),time%60)
    end
end

--将时间转换为分00
function CommonUtils.getTimeMinuteString(time)
    if (tonumber(time) <= 0) then 
        return "00"
    else
        return string.format("%02d",math.floor((time/60)%60))
    end
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
--截图分享
function CommonUtils.shareScreen()
    local function afterCaptured(succeed, outputFile)
        if device.platform == "android" then
            luaj = require("cocos.cocos2d.luaj")
            local function logincallback(code)
                print("====分享成功")
            end
            local className = NOWANDROIDPATH
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

--截图图分享，分享到朋友圈
function CommonUtils.shareScreen_2()
    local function afterCaptured(succeed, outputFile)
        if device.platform == "android" then
            luaj = require("cocos.cocos2d.luaj")
            local function logincallback(code)
                print("====分享成功")
            end
            local className = NOWANDROIDPATH
            local methodName = "sharepic"
            local args  =  {outputFile,1}
            local sig = "(Ljava/lang/String;I)V"
            luaj.callStaticMethod(className, methodName, args, sig)
        elseif device.platform == "ios" then
            luaoc.callStaticMethod("RootViewController","weixinsharepic",{flag = 1,path = outputFile})
        end
    end
    cc.utils:captureScreen(afterCaptured, "jietu_1.png")
end
function CommonUtils.movePictocache(pathpic)
    local iconPath = cc.FileUtils:getInstance():fullPathForFilename(pathpic)
    if string.find(iconPath, cc.FileUtils:getInstance():getWritablePath()) then
    else
        local image = cc.Image:new()
        image:initWithImageFile(iconPath)
        local picsavepath = cc.FileUtils:getInstance():getWritablePath().."appdata/res/"..pathpic
        local ts = string.reverse(picsavepath)
        local pos = string.find(ts,"/")
        pos = string.len(ts) - pos
        local directorypath = string.sub(picsavepath,1,pos)
        print(directorypath)
         if cc.FileUtils:getInstance():isDirectoryExist(directorypath) then
        else
            cc.FileUtils:getInstance():createDirectory(directorypath)
        end
        if image:saveToFile(picsavepath, true) then
            print("end yes")
            iconPath = picsavepath
        else
            print("end no")

        end
    end
    return iconPath
end

--固定图分享，朋友圈分享
function CommonUtils.shareScreen_1()
    local img = "common/shareImage_"
    if GAME_CITY_SELECT then
        img = img..GAME_CITY_SELECT..".jpg"
        if not cc.FileUtils:getInstance():isFileExist(img) then
            img = "common/shareImage.jpg"
        end
    end
    local iconPath = cc.FileUtils:getInstance():fullPathForFilename(img)
    local iconPath = CommonUtils.movePictocache(img)
    if device.platform == "android" then
        if string.find(iconPath, "appdata") then
        else
           local image = cc.Image:new()
            image:initWithImageFile(iconPath)
            iconPath = cc.FileUtils:getInstance():getWritablePath().."appdata/res/"..img
            print(iconPath)
            if cc.FileUtils:getInstance():isDirectoryExist(cc.FileUtils:getInstance():getWritablePath().."appdata/res/common") then
            else
                cc.FileUtils:getInstance():createDirectory(cc.FileUtils:getInstance():getWritablePath().."appdata/res/common")
            end

            if image:saveToFile(iconPath, true) then
                print("end yes")
            else
                print("end no")
            end
        end

        luaj = require("cocos.cocos2d.luaj")
        local function logincallback(code)
            print("====分享成功")
        end
        local className = NOWANDROIDPATH
        local methodName = "sharepic"
        local args  =  {iconPath,1}
        local sig = "(Ljava/lang/String;I)V"
        luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
        luaoc.callStaticMethod("RootViewController","weixinsharepic",{flag = 1,path = iconPath})
    end
end

function CommonUtils.shareScreen_3(str)
    local iconPath = cc.FileUtils:getInstance():fullPathForFilename(str)
    local iconPath = CommonUtils.movePictocache(str)
    if device.platform == "android" then
        luaj = require("cocos.cocos2d.luaj")
        local function logincallback(code)
            print("====分享成功")
        end
        local className = NOWANDROIDPATH
        local methodName = "sharepic"
        local args  =  {iconPath,1}
        local sig = "(Ljava/lang/String;I)V"
        luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
        luaoc.callStaticMethod("RootViewController","weixinsharepic",{flag = 1,path = iconPath})
    end
end

-- 分享游戏
function CommonUtils.sharegame()
    -- if device.platform == "android" then
    --     luaj = require("cocos.cocos2d.luaj")
    --     local function logincallback(code)
    --         print("====分享成功")
    --     end
    --     local className = NOWANDROIDPATH
    --     local methodName = "share2weixin"
    --     print(cc.FileUtils:getInstance():fullPathForFilename("common/head.png"))

    --     -- local gameNameStr = GT_INSTANCE:getGameName() 
    --     local ameNameStr = "川南字牌"
    --     local args  =  {gameNameStr,"最地道泸州、泸县、古蔺、叙永、合江大贰都有，等你来约！",ComHttp.HTTP_ADDRESS.."/Share/wechat?channel="..CLIENT_QUDAO.."&type=0",cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),0}
    --     local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
    --     luaj.callStaticMethod(className, methodName, args, sig)
    -- elseif device.platform == "ios" then
    --     -- local gameNameStr = GT_INSTANCE:getGameName() or ""
    --     local gameNameStr = "川南字牌"
    --     luaoc.callStaticMethod("RootViewController","weixinshare",{url = ComHttp.HTTP_ADDRESS.."/Share/wechat?channel="..CLIENT_QUDAO.."type=0",flag = 0,title = gameNameStr,disc = "最地道泸州、泸县、古蔺、叙永、合江大贰都有，等你来约！",pic = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png")})
    -- end
end
-- 分享牌桌
function CommonUtils.sharedesk(tableid,info,gameType)
    if not gameType then
        gameType = LocalData_instance:getGameType()
    end
    local gameNameStr = GT_INSTANCE:getGameName(gameType).."【"..tableid.."】"
    print(gameNameStr)

    print(info)
    if device.platform == "android" then
        luaj = require("cocos.cocos2d.luaj")
        local function logincallback(code)
            print("====分享成功")
        end
        local className = NOWANDROIDPATH
        local methodName = "share2weixin"
        print(cc.FileUtils:getInstance():fullPathForFilename("common/head.png"))
        local str1 = "规则:"..info
        local str2 = ComHttp.HTTP_ADDRESS.."/Promoteshare/wechat?uid="..LocalData_instance.uid.."&channel="..CLIENT_QUDAO.."&tableid="..tableid.."&fromgame=1"
        local args  =  {gameNameStr,str1,str2,cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),0}
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
        luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
        local str1 = "规则:"..info
        luaoc.callStaticMethod("RootViewController","weixinshare",{url = ComHttp.HTTP_ADDRESS.."/Promoteshare/wechat?uid="..LocalData_instance.uid.."&channel="..CLIENT_QUDAO.."&tableid="..tableid.."&fromgame=1",flag = 0,title = gameNameStr,disc = str1,pic = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png")})
    end
    -- print(GT_INSTANCE:getGameName(gameType).."【"..tableid.."】")
    -- print(info)
end

function CommonUtils.wechatShare(_data,callback)

    local function _wechatShare(data)
        if device.platform == "android" then
        luaj = require("cocos.cocos2d.luaj")
        local function logincallback(code)
            print("====分享成功")
        end
        local className = NOWANDROIDPATH
        local methodName = "share2weixin"
        print(cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"))
        local args  =  {data.title,data.content,data.url,data.icon,data.flag}
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
        luaj.callStaticMethod(className, methodName, args, sig)
        elseif device.platform == "ios" then
            luaoc.callStaticMethod("RootViewController","weixinshare",{url = data.url,flag = data.flag,title = data.title,disc = data.content,pic = data.icon})
        end
    end 

    if _data.flag == 1 then
        CommonUtils.shareScreen_1()
        -- local isgood = true
        -- ComHttp.httpPOST(ComHttp.URL.GETSHAREURL,{uid= LocalData_instance.uid},function(msg) 
        --     if isgood == true then
        --         Notinode_instance:stopAllActions()
        --         isgood = false
        --         print("......_data.url = ",_data.url)
        --         if msg.domain and msg.domain ~= "" then
        --             _data.url = msg.domain.."/mjapi/index.php/Share/springinvite?type=2&channel="..CLIENT_QUDAO.."&uid="..LocalData_instance.uid
                
        --         end
        --         print("......_data.url = ",_data.url)
        --         _wechatShare(_data)
        --         print("........获取分享地址")
        --         printTable(msg,"xp")
        --     end
        -- end)    

        -- Notinode_instance:runAction(cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(function(  )
        --     if isgood then
        --         isgood = false
        --         _wechatShare(_data)
        --     end
        -- end)))
    else
        _wechatShare(_data)
    end

end

function CommonUtils.wechatShare2(data,callback)
    if data.flag == 1 then 
        CommonUtils.shareScreen_1()
        return
    end

    local url = ComHttp.shareAddress..data.url
    if device.platform == "android" then
        luaj = require("cocos.cocos2d.luaj")
        local function logincallback(code)
            print("====分享成功")
        end
        local className = NOWANDROIDPATH
        local methodName = "share2weixin"
        print(cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"))
        local args  =  {data.title,data.content,url,data.icon,data.flag}
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
        luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
        luaoc.callStaticMethod("RootViewController","weixinshare",{url = url,flag = data.flag,title = data.title,disc = data.content,pic = data.icon})
    end
end

function CommonUtils.wechatShare3(data,callback)
    local url = ComHttp.shareAddress..data.url
    if device.platform == "android" then
        luaj = require("cocos.cocos2d.luaj")
        local function logincallback(code)
            print("====分享成功")
        end
        local className = NOWANDROIDPATH
        local methodName = "share2weixin"
        print(cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"))
        local args  =  {data.title,data.content,url,data.icon,data.flag}
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
        luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
        luaoc.callStaticMethod("RootViewController","weixinshare",{url = url,flag = data.flag,title = data.title,disc = data.content,pic = data.icon})
    end
end


--位置信息
function CommonUtils.getLocaitioninfo()
    LocalData_instance.longitude = "empty"
    LocalData_instance.latitude = "empty"
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
        local className = NOWANDROIDPATH
        local methodName = "getLocationData"
        local sig = "(I)V"
        luaj.callStaticMethod(className, methodName, {callback}, sig)
    elseif device.platform == "ios" then
        local function callback(isget, latitude,longitude)
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
        LocalData_instance.longitude = 0.1
        LocalData_instance.latitude = 0.1
    end 
end

function CommonUtils.shareclub(tbid,name,info)

    local title =  "茶馆招募令 点此加入"
    local info = "我的茶馆【"..name.."】ID".."【"..tbid.."】".."介绍:"..info
     local str2 = ComHttp.HTTP_ADDRESS.."/Promoteshare/wechat?uid="..LocalData_instance.uid.."&channel="..CLIENT_QUDAO.."&fromgame=4&tbid="..tbid
    if device.platform == "android" then
        luaj = require("cocos.cocos2d.luaj")
        local function logincallback(code)
            print("====分享成功")
        end
        local className = NOWANDROIDPATH
        local methodName = "share2weixin"
        local args  =  {title,info,str2,cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),0}
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
        luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
        local tableinfo  = {url = str2,flag = 0,title = title,disc =info,pic = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png")}
        luaoc.callStaticMethod("RootViewController","weixinshare",tableinfo)
    end
    print("title:"..title)
    print("info:"..info)
    print("str2:"..str2)
end
function CommonUtils.sharerecord(recordid)

    local title =  "回放码【"..recordid.."】"
    local info = "我分享了一个【今日扑克】牌局记录，大家帮我看看。"
     local str2 = ComHttp.HTTP_ADDRESS.."/Promoteshare/wechat?uid="..LocalData_instance.uid.."&channel="..CLIENT_QUDAO.."&fromgame=6"
    if device.platform == "android" then
        luaj = require("cocos.cocos2d.luaj")
        local function logincallback(code)
            print("====分享成功")
        end
        local className = NOWANDROIDPATH
        local methodName = "share2weixin"
        local args  =  {title,info,str2,cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),0}
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
        luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
        local tableinfo  = {url = str2,flag = 0,title = title,disc =info,pic = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png")}
        luaoc.callStaticMethod("RootViewController","weixinshare",tableinfo)
    end
    print("title:"..title)
    print("info:"..info)
    print("str2:"..str2)
end
function CommonUtils.getDianliangLevel(fuc)
    if device.platform == "android" then
            luaj = require("cocos.cocos2d.luaj")
            local function getdian(value)
                fuc(value)
            end
            local className = NOWANDROIDPATH
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


function CommonUtils.getpushToken(fuc)

    if device.platform == "android" then
            luaj = require("cocos.cocos2d.luaj")
            local function callback(regId)
                print("regId.."..regId)
                fuc(regId)
            end
            local className = NOWANDROIDPATH
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
            local className = NOWANDROIDPATH
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
        local id = os.time()..math.random(100000,9999999)
        fuc(id)
    end
end

function CommonUtils.exitgame()
    if device.platform == "android" then
        luaj = require("cocos.cocos2d.luaj")
        local className = NOWANDROIDPATH
        local methodName = "exitgame"
        local args  =  {}
        local sig = "()V"
        luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
        luaoc.callStaticMethod("RootViewController","closed")
    end
end
--支付



function CommonUtils.pay()
    if device.platform == "ios" then

    elseif device.platform == "android" then
        luaj = require("cocos.cocos2d.luaj")
            local function callback(msg)
                print("打开成功")
            end
            local className = NOWANDROIDPATH
            local methodName = "pay"
            local args  =  {url,callback}
            local sig = "(Ljava/lang/String;I)V"
            luaj.callStaticMethod(className, methodName, args, sig) 
    end
end
function CommonUtils:base64(str,isdecrypt)
    require "mime"   
    
    if isdecrypt then
        --Base64解码  
        local unBase64Str = mime.unb64(str)  
        print(unBase64Str) 
        return unBase64Str
    end

    --Base64编码
    local base64Str = mime.b64(str)  
    print("==========="..base64Str)  
  
    return base64Str
end


-- 震动
function CommonUtils.zhengdong()
     if device.platform == "android" then
            luaj = require("cocos.cocos2d.luaj")
            local className = NOWANDROIDPATH
            local methodName = "zDong"
            local args  =  {}
            local sig = "()V"
            luaj.callStaticMethod(className, methodName, args, sig) 
    elseif device.platform == "ios" then
         luaoc.callStaticMethod("RootViewController","zDong")
    end     
end
-- 复制
function CommonUtils.copyTo(str)
     if device.platform == "android" then
            luaj = require("cocos.cocos2d.luaj")
            local function callback(msg)
                print("复制成功")
                CommonUtils:prompt("复制成功",CommonUtils.TYPE_CENTER)
                print("复制结束")
            end
            local className = NOWANDROIDPATH
            local methodName = "copyClipboard"
            local args  =  {str,callback}
            local sig = "(Ljava/lang/String;I)V"
            luaj.callStaticMethod(className, methodName, args, sig) 
    elseif device.platform == "ios" then
        luaoc.callStaticMethod("RootViewController","copyClipboard",{copy=str,callback =function(code)
              CommonUtils:prompt("复制成功",CommonUtils.TYPE_CENTER)
        end})
    end     
end
function CommonUtils.isBackground()
    if device.platform == "android" then
        local function callback(value)
            if value == "1" then
                print("处于后台")
            else
                print("不处于后台") 
            end
        end
        luaj = require("cocos.cocos2d.luaj")
        local className = NOWANDROIDPATH
        local methodName = "isApplicationBroughtToBackground"
        local args  =  {}
        local sig = "()V"
        luaj.callStaticMethod(className, methodName, args, sig)
    end
end
CommonUtils.TYPE_CENTER = 1
CommonUtils.TYPE_DOWN = 2
CommonUtils.TYPE_MOVE = 3
function CommonUtils:prompt(text, typ)
    -- print("===================1==================")
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

    -- print("===================2==================")
    local bgNode = cc.Director:getInstance():getRunningScene():getChildByName("prompttip") 
    if typ ~= CommonUtils.TYPE_MOVE and  tolua.cast(bgNode,"cc.Node")then
    -- print("===================6==================")
       bgNode:setName("")
       bgNode:stopAllActions()
       bgNode:removeFromParent() 
    end


    local scene = cc.Director:getInstance():getRunningScene()
    local bg = ccui.ImageView:create("common/board_fuzi.png")
    bg:setPosition(x, y)
    bg:setName("prompttip")
    scene:addChild(bg,2)

    -- print("===================3==================")
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
        -- print("===================4==================")
        if tolua.cast(bg,"cc.Node") then
            bg:setName("")
            bg:stopAllActions()
            bg:removeFromParent()
        end 
    end)
    local seq
    if typ == CommonUtils.TYPE_MOVE then
        fadeOut = cc.FadeOut:create(0.5)
        seq = cc.Sequence:create(move,fadeOut, fun, nil);
    else    
        seq = cc.Sequence:create(fadeIn, delaytime, fadeOut, fun, nil);
    end    
    -- print("===================5==================")
    bg:runAction(seq)
end

function CommonUtils.requsetRedPoint()
    ComHttp.httpPOST(ComHttp.URL.GETNOTICEREDPOINT,{uid = LocalData_instance.uid},function(msg)
        -- printTable(msg,"sjp3")
        if msg.redpoint == 1 then
            HASREDPOINT = true
        else
            HASREDPOINT = false
        end
    end)
end

--固定图分享，朋友圈分享
function CommonUtils.activity_shareScreen(pathpic,shareType)
    local iconPath = CommonUtils.activity_movePictocache(pathpic)
    if device.platform == "android" then
        luaj = require("cocos.cocos2d.luaj")
        local function logincallback(code)
            print("====分享成功")
        end
        local className = NOWANDROIDPATH
        local methodName = "sharepic"
        local args  =  {iconPath,shareType}
        local sig = "(Ljava/lang/String;I)V"
        luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
        luaoc.callStaticMethod("RootViewController","weixinsharepic",{flag = shareType,path = iconPath})
    end
end


function CommonUtils.activity_movePictocache(pathpic)

    local picsavepath = string.gsub(device.writablePath, "[\\\\/]+$", "") .. device.directorySeparator.."download_pic".. device.directorySeparator .. CryTo:Md5(pathpic)
    local ts = string.reverse(picsavepath)
    local pos = string.find(ts,"/")
    pos = string.len(ts) - pos
    local directorypath = string.sub(picsavepath,1,pos)
    print(directorypath)
    iconPath = picsavepath
    return iconPath
       
end

function CommonUtils.downapp()
    CommonUtils.openUrl("http://jrhpapi.arthur-tech.com/downloadpage/index.php/details/index?type=jrhp")
end


function CommonUtils.fangchengmi()
    
end
