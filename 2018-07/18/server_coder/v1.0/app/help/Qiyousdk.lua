Qiyousdk = {}

local ANDROIDPATH_QIYU = NOWANDROIDPATH
function Qiyousdk.showui()
	if device.platform == "android" then
		  	luaj = require("cocos.cocos2d.luaj")
            local function logincallback()
                print("====分享成功")
            end
            local className = ANDROIDPATH_QIYU
            local methodName = "showqiyu"
            local args  =  {outputFile,0}
            local sig = "(I)V"
            luaj.callStaticMethod(className, methodName, args, sig)
	elseif device.platform == "ios" then
		luaoc.callStaticMethod("RootViewController","showfanguiUi")
	end
end


function Qiyousdk.logout()
	
	if device.platform == "android" then
		luaj = require("cocos.cocos2d.luaj")
        local className = ANDROIDPATH_QIYU
        local methodName = "logoutforqiyu"
        local args  =  {}
        local sig = "()V"
        luaj.callStaticMethod(className, methodName, args, sig)
	elseif device.platform == "ios" then
		luaoc.callStaticMethod("RootViewController","logoutforqiyu")
	end
end


function Qiyousdk.getunReadcount()
	local countnum = 0
	local function callback(count)
		print("count:"..count)
        countnum = count
    end

	if device.platform == "android" then
         luaj = require("cocos.cocos2d.luaj")
        local className = ANDROIDPATH_QIYU
        local methodName = "getqiyouUnreadcount"
        local args  =  {callback}
        local sig = "(I)V"
        luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
        luaoc.callStaticMethod("RootViewController","getqiyouUnreadcount",{callback =callback})
    end
	return countnum
end



function Qiyousdk.setuserinfo()
	local infotable = {}
	infotable[1] = {}
	infotable[1].value = "今日花牌"
	infotable[1].key = "gamename"
	infotable[1].label = "游戏名称:"

	infotable[2] = {}
	infotable[2].value = LocalData_instance.uid
	infotable[2].key = "uid"
	infotable[2].label = "UID:"

	infotable[3] = {}
	infotable[3].value = GAME_LOCAL_CITY
	infotable[3].key = "diqu"
	infotable[3].label = "地区:"


	local jsonstr = cjson.encode(infotable)

	if device.platform == "android" then
		luaj = require("cocos.cocos2d.luaj")
        local className = ANDROIDPATH_QIYU
        local methodName = "setUserinfoqiyu"
        local args  =  {tostring(LocalData_instance.uid),jsonstr}
        local sig = "(Ljava/lang/String;Ljava/lang/String;)V"
        luaj.callStaticMethod(className, methodName, args, sig)
	elseif device.platform == "ios" then
		luaoc.callStaticMethod("RootViewController","setUserinfoforqiyu",{uid = LocalData_instance.uid,jsondata = jsonstr})
	end
end