
local LoginScene = class("LoginScene",function()
    return cc.Scene:create()
end)


function LoginScene:ctor()
    print("LoginScene")
    --客服端app的版本
   	CLIENT_VERSION = 1
   	if device.platform == "android" then
   		 luaj = require("cocos.cocos2d.luaj")
        local function logincallback(version)
            CLIENT_VERSION = version
        end
        local className = "com/dazhongjuyou/moretop/wxapi/WXEntryActivity"
        local methodName = "getversion"
        local args  =  {logincallback}
        local sig = "(I)V"
        luaj.callStaticMethod(className, methodName, args, sig)
   	elseif device.platform == "ios" then
   		luaoc.callStaticMethod("RootViewController","getVersion",{callback =function(version)
			CLIENT_VERSION = tonumber(version)
		end})
   	end

   	--客服端app的渠道
   	CLIENT_QUDAO = 1
   	if device.platform == "android" then
   		 luaj = require("cocos.cocos2d.luaj")
        local function logincallback(qudao)
            CLIENT_QUDAO = tonumber(qudao)
        end
        local className = "com/dazhongjuyou/moretop/wxapi/WXEntryActivity"
        local methodName = "getQudao"
        local args  =  {logincallback}
        local sig = "(I)V"
        luaj.callStaticMethod(className, methodName, args, sig)

   	elseif device.platform == "ios" then
   		luaoc.callStaticMethod("RootViewController","getQuDaoNumber",{callback =function(qudao)
			CLIENT_QUDAO = qudao
		end})
   	end
   	print("渠道："..CLIENT_QUDAO)
   	print("app:"..CLIENT_VERSION)

    self:initMusic()
    self:getScalePos()
    self:initview()
end
function LoginScene:initMusic()
	audio.stopAllSounds()
	if device.platform == "windows" or device.platform == "mac" then 
		return true
	end
    audio.playMusic('sound/bgm1.mp3', true)
   	local effectvalue = cc.UserDefault:getInstance():getIntegerForKey("LocalData_effect")
    if effectvalue == 0 then
        effectvalue = 100
    elseif effectvalue == -1 then
        effectvalue = 0 
    end 
    local musicvalue = cc.UserDefault:getInstance():getIntegerForKey("LocalData_music") 
    if musicvalue == 0 then
        musicvalue = 100
    elseif musicvalue == -1 then
        musicvalue = 0 
    end
    audio.setSoundsVolume(effectvalue/100)
    audio.setMusicVolume(musicvalue/100)
    if effectvalue > 0 then
        cc.UserDefault:getInstance():setIntegerForKey("LocalData_effect",effectvalue)
    elseif effectvalue == 0 then
        cc.UserDefault:getInstance():setIntegerForKey("LocalData_effect",-1)
    end
    if musicvalue > 0 then
        cc.UserDefault:getInstance():setIntegerForKey("LocalData_music",musicvalue)
    elseif musicvalue == 0 then
        cc.UserDefault:getInstance():setIntegerForKey("LocalData_music",-1)
    end
end
function LoginScene:initview()

    local effectvalue = cc.UserDefault:getInstance():getIntegerForKey("LocalData_effect")
    if effectvalue == 0 then
        effectvalue = 100
    elseif effectvalue == -1 then
        effectvalue = 0 
    end 
    local musicvalue = cc.UserDefault:getInstance():getIntegerForKey("LocalData_music") 
    if musicvalue == 0 then
        musicvalue = 100
    elseif musicvalue == -1 then
        musicvalue = 0 
    end
    audio.setSoundsVolume(effectvalue/100)
    audio.setMusicVolume(musicvalue/100)
    
	local widget = cc.CSLoader:createNode("ui/login/loginView.csb")
	self.widget = widget
    --self.widget:setVisible(false)
	self.layout = widget:getChildByName("main")
	self:setBgScale(widget:getChildByName("bg"))
	self.version = self.layout:getChildByName("version")
	print("height:"..display.height)
	--self.version:setPosition(cc.p(40,720-40))
	self.version:setString("Version:"..CLIENT_VERSION.."."..CONFIG_REC_VERSION)
	local loginnode = self.layout:getChildByName("loginNode")
	loginnode:setVisible(false)
	local checkNode = self.layout:getChildByName("checkNode")
	checkNode:setVisible(true)

	self:setScalepos(self.layout)
	self:addChild(widget)
	self.updatatip =  self.layout:getChildByName("checkNode"):getChildByName("updateTip")
	self.loadbg =  self.layout:getChildByName("checkNode"):getChildByName("barbg")
	local loadprogress = self.layout:getChildByName("checkNode"):getChildByName("barbg"):getChildByName("loadingBar")
	loadprogress:setPercent(0)
	self.progress = loadprogress
	-- loadprogress = WidgetUtils:getChildByName(self.layout,{"checkNode","barbg","loadingBar"})

	local loadlable = self.layout:getChildByName("checkNode"):getChildByName("updateTip")
	local index = 0
	-- loadprogress:runAction(cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(0.03),cc.CallFunc:create(function()
	-- 	index = index + 1
	-- 	loadprogress:setPercent(index)
	-- 	loadlable:setString("更新中("..index..")")
	-- 	if index == 100 then
	-- 		self:entenlogin()
	-- 	end
	-- end)), 100))

	if device.platform == "android" or device.platform == "ios" then
		local function updata()
	        --print("updata")
	        local per = Downtool:sharedDowntool():getProssgress()
	        if per >= 0  and self.isdownsucessful == false then
	            self.progress:setPercent(per)
	            self.updatatip:setString("更新中".."("..per.."％)")
	        end

	    end
	    self:scheduleUpdateWithPriorityLua(updata,-1)
    end

        --self:entenlogin()
        -- if device.platform == "mac"  then
        --     self:entenlogin()
        -- else
    	    self:registerScriptHandler(function(state)
    	        print("--------------"..state)
    	       if state == "enter" then
    	            self:onEnter()
    	        elseif state == "exit" then
    	             self:onExit()
    	        end
    	    end)
        --end
        --self:entenlogin()
	--else
		--self:entenlogin()
	--end




end
function LoginScene:getScalePos()
	local size = cc.Director:getInstance():getOpenGLView():getFrameSize()
	local xscale =  size.width/1335
	local yscale = size.height/750
	local offxscale = 1
	local offyscale = 1
	if xscale > yscale then
	    offxscale =  1*xscale/yscale
	else
	    offyscale  = 1*yscale/xscale
	end
	self.offxscale = offxscale
	self.offyscale = offyscale
end
--界面适配
function LoginScene:setScalepos(node)
	local children = node:getChildren()
	if children then
		for i,v in ipairs(children) do
			local x = v:getPositionX()
			local y = v:getPositionY()
			v:setPositionX(x*self.offxscale)
			v:setPositionY(y*self.offyscale)
		end
	end
	--node:setPosition(display.cx,display.cy)
end
function LoginScene:setBgScale(bg)
	if self.offxscale >self.offyscale then
		bg:setScale(self.offxscale)
	else
		bg:setScale(self.offyscale)
	end
	bg:setPosition(display.cx,display.cy)
end
function LoginScene:entenlogin()
	print("123")
	local LoginView  = require "app.ui.login.LoginView"
	local loginview = LoginView.new(self)
	self:addChild(loginview)
end

function LoginScene:onEnter()
	local eventDispatcher = self:getEventDispatcher()
    local function handle1(event)
        print("handle1")
        if tonumber(event:getDataString()) == 1 then
            print("下载成功")
            self.isdownsucessful = true
            self.progress:setPercent(100)
            self.updatatip:setString("解压中...")
            Downtool:sharedDowntool():UncompressPackage()
        else
            print("下载失败")
            self.updatatip:setString("更新失败")
            self:popbox("版本更新失败，请重试",function()
                self:downFile()
            end)

        end
    end
    local listener = cc.EventListenerCustom:create("downtool_downfile", handle1)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)


    local function handle2(event)
         if tonumber(event:getDataString()) == 1 then
            print("解压成功")
            table.remove(self.downlisttab,1)
            self.version:setString("Version:"..CLIENT_VERSION.."."..CONFIG_REC_VERSION)
            --self:downFile()
            self:successful()
            
        else
            print("解压失败")
            self.updatatip:setString("解压失败")
            self:popbox("版本更新失败，请重试",function()
                self:downFile()
            end)
        end
    end
    local listener = cc.EventListenerCustom:create("downtool_unfile", handle2)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    self:checkversion()

end


function LoginScene:onExit()
	-- body
end


function LoginScene:checkversion()
    print("checkversion")
    self.loadbg:setVisible(false)
    self.updatatip:setString("正在检查更新")
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("POST", "http://47.96.180.57:8090/ZGameAccountDongXiang/version/getVersionInfo")
    local function responsecallback()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            print("success")
            local response   = xhr.response
            local output = cjson.decode(response)
           	print(response)
           	printTable(output)
           	if output.result == 1 then
	            self.downlisttab = output.content
                if output.ispending == 1 then
                    SHENHEBAO = true
                end
	            if output.data.content and output.data.content.resourceUrl then
                    if device.platform == "android" or device.platform == "ios" then 
                        self.downlisttab = output.data.content
                        self:downFile()
                    else
                        self:entenlogin()
                        print("entenlogin1")
                    end
                else
                    print("entenlogin2")
                     self:entenlogin()
	            end
            -- elseif output.result == 0 then
            --     self:entenlogin()
	        else
	        	print("请求出错了")
	        end
        else
            print(" PHP  网页 出错 了, 或者没有网络")
            self:popbox("网络请求失败",function()
                self:checkversion()
            end)
        end
    end
    local sendtab = {}
    if device.platform == "android" then
         sendtab.mtype = 1
    elseif device.platform == "ios" then
         sendtab.mtype = 2
    else
        sendtab.mtype = 3
    end
    sendtab.mtype =1 
    sendtab.clientver = CLIENT_VERSION
    sendtab.zyver = CONFIG_REC_VERSION
    sendtab.fromid = CLIENT_QUDAO
   local sendstr = json.encode(sendtab,1)
    print(sendstr)
    xhr:registerScriptHandler(responsecallback)
    --local  CryTo::Md5(sendstr.."zgameMd5")
    print(sendstr..CryTo:Md5(sendstr.."zgameMd5"))
    xhr:send(sendstr..CryTo:Md5(sendstr.."zgameMd5"))
    return xhr


end
function LoginScene:successful()

    self:entenlogin()
end

function LoginScene:downFile()
	-- body
    if self.downlisttab == nil or self.downlisttab.resourceUrl == nil then
        self:successful()
        return
    end
    CONFIG_REC_VERSION = self.downlisttab.vernum
    self.loadbg:setVisible(true)
    print(device.writablePath)
    self.isdownsucessful = false
    self.downfilesize = self.downlisttab.size
	Downtool:sharedDowntool():downLoad(self.downlisttab.resourceUrl)
    --Downtool:sharedDowntool():downLoad("http://zkj110.oss-cn-shanghai.aliyuncs.com/2.zip")
    self.progress:setPercent(0)
end


function LoginScene:popbox(str,fuc)

	local widget = cc.CSLoader:createNode("ui/popbox/updatePromptBoxView.csb")
	self:addChild(widget)
	widget:setPosition(cc.p(display.cx,display.cy))
    widget:getChildByName("layer"):setBackGroundColor(cc.c3b(0,0,0))
    widget:getChildByName("layer"):setBackGroundColorOpacity(math.floor((num or 60)/100*255))
    widget:getChildByName("layer"):setContentSize(cc.size(display.width*2,display.height*2))
    widget:getChildByName("layer"):setPosition(cc.p(-display.cx,-display.cy))

	local text = widget:getChildByName("main"):getChildByName("content")
	text:setString(str)
	local btn = widget:getChildByName("main"):getChildByName("sureBtn")
 	local onbtn = function(sender,eventType)
    	print("onbtn")
        if eventType == ccui.TouchEventType.ended then   --按钮 触摸完成处理
        	widget:removeFromParent()
           if fuc then
           		fuc()
           end
        end
    end
    
    btn:addTouchEventListener(onbtn)

end




return LoginScene