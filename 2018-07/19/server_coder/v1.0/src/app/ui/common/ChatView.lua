-------------------------------------------------
--   TODO   聊天UI
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local ChatView = class("ChatView",PopboxBaseView)    
function ChatView:ctor(_gameScene)
    self.gameScene = _gameScene
    self:initData()
    self:initView()
    self:initEvent()
end

function ChatView:initData()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/image/plist/emoji.plist")
end

function ChatView:initView()
    self.widget = cc.CSLoader:createNode("ui/chat/chatView.csb")
    self:addChild(self.widget)

    self.layer = self.widget:getChildByName("layer")
    WidgetUtils.addClickEvent(self.layer, function( )
        LaypopManger_instance:back()     
    end)

    self.mainLayer = self.widget:getChildByName("main")
    self.textField = self.mainLayer:getChildByName("textFieldBg"):getChildByName("textField"):setString("")

    local touchlayer = ccui.Layout:create()
    touchlayer:setContentSize(cc.size(display.width*4, display.height*4))
    touchlayer:setPosition(cc.p(-display.width, -display.height))
    self:addChild(touchlayer, 10)
    touchlayer:setTouchEnabled(true)
    touchlayer:setVisible(false)

    WidgetUtils:addPressListener(touchlayer, function (event)
        self.textField:setDetachWithIME(true)
    end)

    local old_x,old_y = self.widget:getPosition()
    self.textField:addEventListener(function (target, event)
        if event == ccui.TextFiledEventType.attach_with_ime then-- 进入输入
             print("进入输入～～～～")
            if device.platform == "ios" then
                 self.widget:stopAllActions()
                 self.widget:runAction(cc.Sequence:create(cc.MoveTo:create(0.225,cc.p(old_x, old_y+400)),cc.CallFunc:create(function()
                     print("进入输入～～～～结束")
                    touchlayer:setVisible(true)
                 end)))
                 cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(true)
            end
        elseif event == ccui.TextFiledEventType.detach_with_ime then-- 离开输入
            print("...........离开输入")
            if device.platform == "ios" then
                self.widget:stopAllActions()
                self.widget:runAction(cc.Sequence:create(cc.MoveTo:create(0.175, cc.p(old_x, old_y)),cc.CallFunc:create(function()
                        print("...........离开输入 结束")
                        touchlayer:setVisible(false)
                 end)))
                cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
            end

        elseif event == ccui.TextFiledEventType.insert_text then --输入字符
        elseif event == ccui.TextFiledEventType.delete_backward then--删除字符
        end
    end)



    self.sendBtn = self.mainLayer:getChildByName("textFieldBg"):getChildByName("sendBtn")
    WidgetUtils.addClickEvent(self.sendBtn, function( )
        self:sendBtnCall()
    end)
    
    -- 常用语
    local message_off = self.mainLayer:getChildByName("message_off") 
    self.listView = self.mainLayer:getChildByName("listView")
    local item = self.listView:getChildByName("item")
    item:retain()
    self.listView:setItemModel(item)
    item:removeFromParent()
    item:release()
    self.listView:removeAllItems()
    self:createTextListView()

    -- 表情
    local face_off = self.mainLayer:getChildByName("face_off")
    self.scrollView = self.mainLayer:getChildByName("scrollView")
    self.scrollView:removeAllChildren()
    self:createEmojScrollView()

    self.listView:setScrollBarPositionFromCornerForVertical(cc.p(self.listView:getScrollBarPositionFromCornerForVertical().x-15,self.listView:getScrollBarPositionFromCornerForVertical().y))
    self.scrollView:setScrollBarPositionFromCornerForVertical(cc.p(self.scrollView:getScrollBarPositionFromCornerForVertical().x-15,self.scrollView:getScrollBarPositionFromCornerForVertical().y))



    WidgetUtils.addClickEvent(message_off, function(  )
        message_off:setVisible(false)
        self.listView:setVisible(true)

        face_off:setVisible(true)
        self.scrollView:setVisible(false)
    end)

    WidgetUtils.addClickEvent(face_off, function(  )

        message_off:setVisible(true)
        self.listView:setVisible(false)

        face_off:setVisible(false)
        self.scrollView:setVisible(true)
    end)
   
    message_off:setVisible(false)
    self.listView:setVisible(true)
    face_off:setVisible(true)
    self.scrollView:setVisible(false)
end

-- 创建文字面板
function ChatView:createTextListView()

    print("......创建文字面板",QUICK_CHAT_LIST)

    local _list = QUICK_CHAT_LIST

    local audio_type = cc.UserDefault:getInstance():getIntegerForKey("audio_type",1)
    if (self.gameScene:getTableConf().ttype == HPGAMETYPE.FJSDR or self.gameScene:getTableConf().ttype == HPGAMETYPE.LJSDR) and audio_type == 1 then
        _list = QUICK_CHAT_LIST_fjsdr
    elseif self.gameScene:getTableConf().ttype == HPGAMETYPE.SJHP or self.gameScene:getTableConf().ttype == HPGAMETYPE.WJHP then
        _list = QUICK_CHAT_LIST_sjhp
    end

    for i,v in ipairs(_list) do
        self.listView:pushBackDefaultItem()
        local item = self.listView:getItem(i-1)

        local text = item:getChildByName("text")
        text:ignoreContentAdaptWithSize(true)
        text:setTextAreaSize(cc.size(418,0))
        text:setString(v)
        text:ignoreContentAdaptWithSize(false) 
        item:setTouchEnabled(true)

        item:setContentSize(cc.size(item:getContentSize().width,72)) --一行
     
        text:setPositionY(item:getContentSize().height/2)
        WidgetUtils.addClickEvent(item, function( )
           Socketapi.sendChat(1,"",i,1)
           LaypopManger_instance:back()
        end)
    end
end
-- 创建表情面板
function ChatView:createEmojScrollView()
    local cnt = 30
    local posy = self.scrollView:getContentSize().height-60
    local posx = 60
    local every_row = 4
    -- 行间距
    local ver_spacing = 120
    -- 列间距
    local hor_spacing = 120
    local height = 60
    for i=1,cnt do
        local spr  = ccui.ImageView:create("game/chat/small_"..i..".png",ccui.TextureResType.localType)
        self.scrollView:addChild(spr)

        local row = math.ceil(i / every_row)
        local col = i - (row-1)*every_row

        local x = posx + (col-1)*hor_spacing
        local y = posy-(row-1)*ver_spacing
        spr:setScale(1.0)
        spr:setPosition(cc.p(x,y)) 
        spr:setTouchEnabled(true)
        WidgetUtils.addClickEvent(spr, function( )
            Socketapi.sendChat(1,"",i,2)
            LaypopManger_instance:back()
        end)
    end   
    local row = math.ceil(cnt / every_row)
    height = height + (row-1)*ver_spacing + 60
    self.scrollView:setInnerContainerSize(cc.size(self.scrollView:getContentSize().width,height))
    for i,v in ipairs(self.scrollView:getChildren()) do
        v:setPositionY(v:getPositionY()+height-self.scrollView:getContentSize().height)
    end
end
function ChatView:sendBtnCall()
    local str = self.textField:getString()
    if str ~= "" then
        Socketapi.sendChat(0,str)
        LaypopManger_instance:back()
    end
end
function ChatView:initEvent()

end
return ChatView