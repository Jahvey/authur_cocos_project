local LoginScene = class("LoginScene",function()
    return cc.Scene:create()
end)


local update_url = "http://jrpkapi.arthur-tech.com/mjapi/index.php/Tools/updategame"


function LoginScene:ctor(isre)
    print("LoginScene")
    self.isre = isre
    --客服端app的版本
    CLIENT_VERSION = 0
    self.checkcnt = 1
    if device.platform == "android" then
         luaj = require("cocos.cocos2d.luaj")
        local function logincallback(version)
            CLIENT_VERSION = version
        end
        local className = NOWANDROIDPATH
        local methodName = "getversion"
        local args  =  {logincallback}
        local sig = "(I)V"
        luaj.callStaticMethod(className, methodName, args, sig)
    elseif device.platform == "ios" then
        luaoc.callStaticMethod("RootViewController","getVersion",{callback =function(version)
            CLIENT_VERSION = tonumber(version)
        end})
    end

    --客服端app的版本
    CLIENT_QUDAO = 0
    if device.platform == "android" then
         luaj = require("cocos.cocos2d.luaj")
        local function logincallback(qudao)
            CLIENT_QUDAO = tonumber(qudao)
        end
        local className = NOWANDROIDPATH
        local methodName = "getQudao"
        local args  =  {logincallback}
        local sig = "(I)V"
        luaj.callStaticMethod(className, methodName, args, sig)

    elseif device.platform == "ios" then
        luaoc.callStaticMethod("RootViewController","getQuDaoNumber",{callback =function(qudao)
            CLIENT_QUDAO = qudao
        end})
    end
    CLIENT_QUDAO = 11034
    print("渠道："..CLIENT_QUDAO)
    print("app:"..CLIENT_VERSION)

    self:initMusic()
    self:getScalePos()
    self:initview()
end
function LoginScene:initMusic()
    -- audio.stopAllSounds()
    -- if device.platform == "windows" or device.platform == "mac" then 
    --     return true
    -- end
    -- audio.playMusic('sound/bgm1.mp3', true)
    -- if cc.UserDefault:getInstance():getIntegerForKey("LocalData_music",-99) == -99 then
    --     cc.UserDefault:getInstance():setIntegerForKey("LocalData_music",50)
    -- end
    -- local effectvalue = cc.UserDefault:getInstance():getIntegerForKey("LocalData_effect")
    -- if effectvalue == 0 then
    --     effectvalue = 100
    -- elseif effectvalue == -1 then
    --     effectvalue = 0 
    -- end 
    -- local musicvalue = cc.UserDefault:getInstance():getIntegerForKey("LocalData_music") 
    -- if musicvalue == 0 then
    --     musicvalue = 70
    -- elseif musicvalue == -1 then
    --     musicvalue = 0 
    -- end
    -- audio.setSoundsVolume(effectvalue/100)
    -- audio.setMusicVolume(musicvalue/100)
    -- if effectvalue > 0 then
    --     cc.UserDefault:getInstance():setIntegerForKey("LocalData_effect",effectvalue)
    -- elseif effectvalue == 0 then
    --     cc.UserDefault:getInstance():setIntegerForKey("LocalData_effect",-1)
    -- end
    -- if musicvalue > 0 then
    --     cc.UserDefault:getInstance():setIntegerForKey("LocalData_music",musicvalue)
    -- elseif musicvalue == 0 then
    --     cc.UserDefault:getInstance():setIntegerForKey("LocalData_music",-1)
    -- end


end
function LoginScene:initview()
    local widget
    if device.platform == "ios" or device.platform == "mac" then
        -- if SHENHEBAO then
        --     widget= cc.CSLoader:createNode("ui/login/loginView1.csb")
        -- else
            widget= cc.CSLoader:createNode("ui/login/loginView.csb")
        --end
    else
        widget= cc.CSLoader:createNode("ui/login/loginView.csb")
    end
    self.widget = widget

    self.layout = widget:getChildByName("main")
    self:setBgScale(widget:getChildByName("bg"))
    self.version = self.layout:getChildByName("version")
    print("height:"..display.height)
    self.version:setPosition(cc.p(40,720-40))
    self.version:setString("version:"..CLIENT_VERSION.."."..CONFIG_REC_VERSION)
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

    local index = 0
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


        self:registerScriptHandler(function(state)
            print("--------------"..state)
           if state == "enter" then
                self:onEnter()
            elseif state == "exit" then
                 self:onExit()
            end
        end)
    else
        self:checkversion()
        --self:entenlogin()
                
    end
end
function LoginScene:getScalePos()
    local size = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local xscale =  size.width/1280
    local yscale = size.height/720
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
function LoginScene:entenlogin(ishttpno)

    package.loaded["app.ui.scene.ReloadModule"] = nil
    require "app.ui.scene.ReloadModule":reload()

    local LoginView  = require "app.ui.login.LoginView"
    local loginview = LoginView.new(self,ishttpno)
    self:addChild(loginview)

end

function LoginScene:onEnter()
    print("====LoginScene:onEnter====")
    self.checkcnt = 1
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
            self:downFile()
            
        else
            print("解压失败")
            local errCode = event:getDataString()
            self.updatatip:setString("解压失败" .. string.format(", code:%d", errCode))
            self:popbox("版本更新失败，请重试",function()
                self:downFile()
            end)
        end
    end
    local listener = cc.EventListenerCustom:create("downtool_unfile", handle2)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
   

    if device.platform == "android" or device.platform == "ios" then
        self:checkversion()
    end

end


function LoginScene:onExit()
    -- body
end


function LoginScene:checkversion()

    print("..............checkversion ")
    self.loadbg:setVisible(false)
    self.updatatip:setString("正在检查更新")
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("POST", update_url)
    xhr.isgood =true
    local function responsecallback()
         if xhr.isgood == false then
            return
        end
        self:stopAllActions()
        xhr.isgood =false
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            print("success")
            local response   = xhr.response
            local output = cjson.decode(response)
            print(response)
            printTable(output)
            if output and output.serverstatus == 1 then
                self.downlisttab = output.resource
                if output.ispending == 1 then
                    SHENHEBAO = true
                else 
                    SHENHEBAO = false
                end
                if SHENHEBAO or (device.platform ~= "android" and device.platform ~= "ios")  then
                    self:entenlogin()
                else
                    if output.updateversion and output.updateversion.isupdate == 1 then
                        self:popbox("需要更新到最新版本才能进行游戏",function( ... )
                            require "app.help.CommonUtils"
                            CommonUtils.openUrl(output.updateversion.url)
                        end)
                    else
                      self:downFile()
                    end
                end
            else
                 self:popboxFail("更新失败，是否直接进入游戏？",function()
                    self:checkversion()
                end)
            end
        else
            print(" PHP  网页 出错 了, 或者没有网络")
            self:popboxFail("网络请求失败,请重试!",function()
                self:checkversion()
            end)
        end
    end 
    local sendstr = "resource="..CONFIG_REC_VERSION.."&osversion="..device.platform
    sendstr = sendstr.."&channeltype="..CLIENT_QUDAO.."&version="..CLIENT_VERSION
    sendstr = sendstr.."&areatype="..cc.UserDefault:getInstance():getIntegerForKey("CITY_SELECT_SERVER",1)
    print("sendstr = ",sendstr)
    xhr:registerScriptHandler(responsecallback)
    xhr:send(sendstr)
    self:stopAllActions()
    self:runAction(cc.Sequence:create(cc.DelayTime:create(8),cc.CallFunc:create(function(  )
        if xhr.isgood then
            xhr.isgood = false
            self:popboxFail("更新失败，是否直接进入游戏？",function()
                 self:checkversion()
            end)
        end
    end)))

    return xhr


end
function LoginScene:successful()
    print("===========11======")
    self:entenlogin()
end

function LoginScene:downFile()
    -- body
    if self.downlisttab == nil or self.downlisttab[1] == nil then
        self:successful()
        return
    end
    CONFIG_REC_VERSION = self.downlisttab[1].version
    self.loadbg:setVisible(true)
    print(device.writablePath)
    self.isdownsucessful = false
    self.downfilesize = self.downlisttab[1].size
    Downtool:sharedDowntool():downLoad(self.downlisttab[1].url)
    self.progress:setPercent(0)
end


function LoginScene:popbox(str,fuc)

    local widget = cc.CSLoader:createNode("ui/popbox/PromptBoxOneView.csb")
    self:addChild(widget)
    widget:setPosition(cc.p(display.cx,display.cy))

    widget:getChildByName("layer"):setBackGroundColorOpacity(0/100*255)

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

function LoginScene:popboxFail(str,fuc)
    if SHENHEBAONEEDHTTP then
        self:popbox("网络连接失败，请重试",fuc)
        return 
    end
    local widget = cc.CSLoader:createNode("ui/popbox/promptBoxView.csb")
    self:addChild(widget)
    widget:setPosition(cc.p(display.cx,display.cy))
    widget:getChildByName("layer"):setBackGroundColorOpacity(0/100*255)

    local text = widget:getChildByName("main"):getChildByName("content")
    text:setString(str)
    local btn = widget:getChildByName("main"):getChildByName("sureBtn")
    local onbtn = function(sender,eventType)
        print("onbtn")
        if eventType == ccui.TouchEventType.ended then   --按钮 触摸完成处理
            widget:removeFromParent()
            self.uid = cc.UserDefault:getInstance():getIntegerForKey("default_uid",0)
            if self.uid == 0 then
                self:entenlogin()
            else
                self:entenlogin(true)
            end 
            return 
        end
    end
    btn:addTouchEventListener(onbtn)
    local btn = widget:getChildByName("main"):getChildByName("cancelBtn")
    local onbtn = function(sender,eventType)
        print("onbtn")
        if eventType == ccui.TouchEventType.ended then   --按钮 触摸完成处理
            widget:removeFromParent()
            self:checkversion()
            return 
        end
    end
    btn:addTouchEventListener(onbtn)
end
return LoginScene