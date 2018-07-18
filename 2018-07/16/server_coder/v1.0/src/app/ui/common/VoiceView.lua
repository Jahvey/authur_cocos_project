

local VoiceView = class("VoiceView", function()
    return cc.Node:create()
end)


function  VoiceView:ctor(btn)
    --当前音乐音效的值
    self.localeffice = 0
    self.localmusice = 0
    self.isneedsend  = false
    self:initView()
    local onbtn = function(sender,eventType)
        if eventType == ccui.TouchEventType.began then   --按钮 触摸开始处理


        userdata={}
        userdata.cid=11
        userdata.pid=105
        userdata.json={
            ["type"]="11.点击话筒-发送语音"

        }
        CommonUtils.sends(userdata)




            print("ccui.TouchEventType.began")
            if device.platform == "android" or device.platform == "ios" then
                self.voiceview:setVisible(true)


                if cc.FileUtils:getInstance():isFileExist(cc.FileUtils:getInstance():getWritablePath().."test.amr") then
                    cc.FileUtils:getInstance():removeFile(cc.FileUtils:getInstance():getWritablePath().."test.amr")
                end
                if IMDispatchMsgNode:startRecord() then
                else
                  CommonUtils:prompt("录音失败!", CommonUtils.TYPE_CENTER)
                end
            else
                print('不支持当前平台')
            end
        end
    
        if eventType == ccui.TouchEventType.ended then   --按钮 触摸完成处理
            print("ccui.TouchEventType.ended")
            if device.platform == "android" or device.platform == "ios" then
                self.voiceview:setVisible(false)
                self.isneedsend =true
                IMDispatchMsgNode:stopRecord()
            else
                print('不支持当前平台')
            end
        end
           
        if eventType == ccui.TouchEventType.canceled then   --按钮 触摸取消处理
           if device.platform == "android" or device.platform == "ios" then
                self.voiceview:setVisible(false)
                self.isneedsend  =false
                IMDispatchMsgNode:stopRecord()               
            else
                print('不支持当前平台')
            end
        end
        
        if eventType == ccui.TouchEventType.moved then    --按钮 触摸移动事件处理
        end
    end
    
    btn:addTouchEventListener(onbtn)

    self:registerScriptHandler(function(state)
        print("--------------"..state)
        if state == "cleanup" then
            if tolua.cast(self.voiceview,"cc.Node") then
                if self.voiceview:getParent() then
                    self.voiceview:removeFromParent()
                end
            end
        elseif state == "enter" then
            self:onEnter()
        elseif state == "exit" then
             self:onExit()
        end
    end)

    btn:addChild(self)

end
function VoiceView:onEnter()
    print("注册 VoiceView:onEnter")
    local eventDispatcher = self:getEventDispatcher()
    local listener = cc.EventListenerCustom:create("yvsdk_onstop" , function ( evt )
        local out = cjson.decode(evt:getDataString())
        if not self.isneedsend then
            return
        end
        if out  then
            if tonumber(out.time) < 1000 then
                print("时间太短了")
                 CommonUtils:prompt("您的语音太短了", CommonUtils.TYPE_CENTER)
            else
                print("时间开始上传")
                LocalData_instance:setSelfLocalVoiceHandle(out.path)
                IMDispatchMsgNode:upLoadFile(out.path)
            end
        end
    end)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)


     local listener = cc.EventListenerCustom:create("yvsdk_upload" , function ( evt )
        local output = cjson.decode(evt:getDataString())
        if output then
            if tonumber(output.result) == 0 then
                print("上传成功:"..evt:getDataString())
            else
                CommonUtils:prompt("语音发送失败")
                print("上传失败:"..evt:getDataString())
                self.issend = false
                CommonUtils:prompt("网络不给力，语音发送失败，请您重试", CommonUtils.TYPE_CENTER)
                 if device.platform == "android" or device.platform == "ios"  then
                    if LocalData_instance:getUid() then
                        IMDispatchMsgNode:cpLogin(GAME_LOCAL_CITY.."huapai"..LocalData_instance:getUid())
                    end
                end
            end
        else
            self.issend = false
        end
    end)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

end

function VoiceView:onExit()
end

function VoiceView:initView()
    ccb_voiceplay = ccb_voiceplay or {}  
    ccb["ccb_voiceplay"] = ccb_voiceplay 
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad("ccbi/gamevoice.ccbi", proxy, true, "")
    node.ccb = ccb_voiceplay.mAnimationManager
    node:setPosition(cc.p(display.cx,display.cy))
    self.voiceview = node
    self.voiceview:setVisible(false)
    Notinode_instance:addChild(self.voiceview)
end



return VoiceView