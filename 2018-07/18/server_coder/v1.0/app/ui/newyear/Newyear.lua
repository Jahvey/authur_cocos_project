ComHttp.URL["YEARCOMMON"] = "/Dogyear/getcommon"
ComHttp.URL["YEARCONFIG1"] = "/Dogyear/everydayplay_config" 
ComHttp.URL["YEARGET1"] = "/Dogyear/everydayplay_get"   
ComHttp.URL["YEARCONFIG2"] = "/Dogyear/allplay_config" 
ComHttp.URL["YEARGET2"] = "/Dogyear/allplay_get"  

ComHttp.URL["YEARCONFIG3"] = "/Dogyear/invite_config" 
ComHttp.URL["YEARGET3"] = "/Dogyear/invite_get" 

ComHttp.URL["YEARCONFIG4"] = "/Dogyear/share_config" 
ComHttp.URL["YEARGET4"] = "/Dogyear/share_get" 

ComHttp.URL["YEARCONFIG5"] = "/Dogyear/totalpay" 
ComHttp.URL["YEARGET5"] = "/Dogyear/totalpay_getprize" 

ComHttp.URL["YEARCONFIG6"] = "/Dogyear/exchangeallconfig" 
ComHttp.URL["YEARCONFIG61"] ="/Dogyear/servicelottery_buy"
ComHttp.URL["YEARCONFIG62"] ="/Dogyear/usetag_get"
ComHttp.URL["YEARCONFIG63"] ="/Dogyear/exchange_get"
ComHttp.URL["YEARCONFIG64"] ="/Dogyear/serverlottery_buy"
ComHttp.URL["YEARSHARE"] = "/Dogyear/everydayplay_sharelog"
ComHttp.URL["YEARCONFIG65"] ="/Dogyear/serverlottery_prizelist"
ComHttp.URL["YEARCONFIG66"] ="/Dogyear/serverlottery_getprize"


SHARE_TEXT = {
	"玩今日花牌 赢新春大礼",
	"新年玩花牌 天天赢手机",
	"玩花牌，免费领iPhone，就在今日花牌",
	"玩牌还能赢iPhone？没有错，这种好事就在今日花牌",
	"春节回馈新老用户，今日花牌送iphone了",
}


NEWYERRSHREA = {}
--分享好友
function NEWYERRSHREA.sharefriend( )
	if device.platform == "android" then
        luaj = require("cocos.cocos2d.luaj")
        local function logincallback(code)
            print("====分享成功")
        end
        local className = NOWANDROIDPATH
        local methodName = "share2weixin"
        print(cc.FileUtils:getInstance():fullPathForFilename("common/head.png"))

        -- local gameNameStr = GT_INSTANCE:getGameName() 
        local gameNameStr = "今日花牌"
        local args  =  {gameNameStr,SHARE_TEXT[os.time()%5+1],ComHttp.shareAddress.."/Share/dogyear_invite?uid="..LocalData_instance.uid,cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),0}
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
        luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
        -- local gameNameStr = GT_INSTANCE:getGameName() or ""
        local gameNameStr = "今日花牌"
        luaoc.callStaticMethod("RootViewController","weixinshare",{url = ComHttp.shareAddress.."/Share/dogyear_invite?uid="..LocalData_instance.uid,flag = 0,title = gameNameStr,disc = SHARE_TEXT[os.time()%5+1],pic = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png")})
    else
    	print("不支持")
    	local event = cc.EventCustom:new("weixinsharecallback")
	   	event:setDataString("0")
	   	cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)

    end
end



--分享朋友圈
function NEWYERRSHREA.sharePyquan( )
    local img = "year.jpg"
    local iconPath = cc.FileUtils:getInstance():fullPathForFilename(img)
    if device.platform == "android" then
        if string.find(iconPath, "appdata") then
        else
           local image = cc.Image:new()
            image:initWithImageFile(iconPath)
            iconPath = cc.FileUtils:getInstance():getWritablePath().."appdata/res/"..img
            print(iconPath)
            if cc.FileUtils:getInstance():isDirectoryExist(cc.FileUtils:getInstance():getWritablePath().."appdata/res") then
            else
                cc.FileUtils:getInstance():createDirectory(cc.FileUtils:getInstance():getWritablePath().."appdata/res")
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
    else
    	print("不支持")
    	local event = cc.EventCustom:new("weixinsharecallback")
	   	event:setDataString("0")
	   	cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
    end
end


