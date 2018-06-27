

local VoiceView = class("VoiceView", function()
    return cc.Node:create()
end)


function  VoiceView:ctor(btn)
    --当前音乐音效的值
    self.localeffice = 0
    self.localmusice = 0
    self.isneedsend  = false
    -- if device.platform == "android" or device.platform == "ios" then
    --       IMDispatchMsgNode:cpLogin("dsfasfadsfdsafadsdf")
    -- end
    self:initView()
    local onbtn = function(sender,eventType)
        if eventType == ccui.TouchEventType.began then   --按钮 触摸开始处理
            print("ccui.TouchEventType.began")
            if device.platform == "android" or device.platform == "ios" then
                IMDispatchMsgNode:stopRecord()
                self.voiceview:setVisible(true)
                self.localeffice = AudioUtils.getSoundsVolume()
                self.localmusice  = AudioUtils.getMusicVolume()
                if IMDispatchMsgNode:startRecord() then
                    AudioUtils.setSoundsVolume(0)
                    AudioUtils.setMusicVolume(0)
                    IMDispatchMsgNode:stopPlay()
                end
            else
                print('不支持当前平台')
            end
        end
    
        if eventType == ccui.TouchEventType.ended then   --按钮 触摸完成处理
            print("ccui.TouchEventType.ended")
            if device.platform == "android" or device.platform == "ios" then
                self.voiceview:setVisible(false)
                AudioUtils.setSoundsVolume(self.localeffice)
                AudioUtils.setMusicVolume(self.localmusice)
                IMDispatchMsgNode:stopRecord()
                self.isneedsend =true
            else
                print('不支持当前平台')
            end
        end
           
        if eventType == ccui.TouchEventType.canceled then   --按钮 触摸取消处理
           if device.platform == "android" or device.platform == "ios" then
                self.voiceview:setVisible(false)
                AudioUtils.setSoundsVolume(self.localeffice)
                AudioUtils.setMusicVolume(self.localmusice)
                IMDispatchMsgNode:stopRecord()
                self.isneedsend  =false
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
            self.voiceview:removeFromParent()
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
        print("yvsdk_onstop:"..evt:getDataString())
        local out = cjson.decode(evt:getDataString())
        if not self.isneedsend then
            return
        end
        if out  then
            if tonumber(out.time) < 1000 then
                print("时间太短了")
            else
                print("时间开始上传")
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


                if tonumber(output.time) then

                    local tableinfo = {}
                    tableinfo.type = 3
                    tableinfo.id = output
                    local jsonstr = json.encode(tableinfo)
                    Socketapi.sendchat(jsonstr)
                else
                    print("语音发送失败")
                end

            else
                print("上传失败:"..evt:getDataString())
                self.issend = false
            end
        else
            self.issend = false
            -- CommonUtils:prompt(LangUtils:getStr("social_chat_title8"))
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