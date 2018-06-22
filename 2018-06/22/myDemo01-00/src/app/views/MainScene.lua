cc.FileUtils:getInstance():addSearchPath("res/ui/")

local MainScene = class("MainScene", cc.load("mvc").ViewBase)

MainScene.RESOURCE_FILENAME = "Layer2.csb"




function MainScene:onCreate()
    printf("resource node = %s", tostring(self:getResourceNode()))
    
    --[[ you can create scene with following comment code instead of using csb file.
    -- add background image
    display.newSprite("HelloWorld.png")
        :move(display.center)
        :addTo(self)

    -- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)
    ]]



   -- local  uiNode = display.newSprite("background.png",display.cx,display.cy)

 
    --self:testListView1()






    local  base_layer = cc.CSLoader:createNode("Layer2.csb")
    local listView = base_layer:getChildByTag(9) --获取listView的值
    local  button_add = base_layer:getChildByTag(15)-- get the button for add item to listView
    local  textField_input = base_layer:getChildByTag(11) --得到文本输入框中的相应的值

    --button_exit:setString("text")

    --listView_text:setVisible(false)


   --  listView:setBounceEnabled(true)                             -- 滑动惯性

   --  listView:setBackGroundImageScale9Enabled(true)              -- 设置9宫

   -- -- listView:setPosition(cc.p(display.cx,display.cy)) 

   --  listView:setItemsMargin(20)                                 -- item间距
   --  listView:setScrollBarEnabled(true)                         -- 设置滚动条隐藏
    


    local List = {}

    for i=1,7 do
        local str = "adonai:..."..i
        table.insert(List,str)
    end


     local function updataListView( listView)


       --listView:removeAllItems()

       listView:removeAllChildren()
       for k,v in pairs(List) do
            local text = ccui.Text:create()
            text:setFontSize(22)
            --text:setColor(cc.c3b(255,0,0)):setScale(2)
            text:setColor(cc.c3b(255,0,0))
            text:setString(v)
            --text:setPosition(cc.p(display.cx,display.cy))
           -- layout:addChild(text)
          --  local height=listView:getContentSize().height/2  -text:getFontSize()*(i)
          -- text:setPosition(cc.p(0,0))

          -- text:setPosition(cc.p(listView:getContentSize().width / 2,listView:getContentSize().height / 2))
           listView:addChild(text)   --弄清楚相应的层级关系，计算出text相对的父容器是listview，而不是layer
       end
    end

    

    updataListView(listView)

    -- -- 创建10个item
    -- for i = 1,5 do
    --     -- 这里创建的是ImageView 实际项目中可能会使用Label和Button
    --     -- local image = ccui.ImageView:create("HelloWorld.png")
    --     local text = ccui.Text:create()
    --     text:setFontSize(22)
    --     --text:setColor(cc.c3b(255,0,0)):setScale(2)
    --     text:setColor(cc.c3b(255,0,0))
    --     text:setString("adonai:..."..i)
    --     --text:setPosition(cc.p(display.cx,display.cy))
    --    -- layout:addChild(text)
    --   --  local height=listView:getContentSize().height/2  -text:getFontSize()*(i)
    --   -- text:setPosition(cc.p(0,0))
    --   -- text:setPosition(cc.p(listView:getContentSize().width / 2,listView:getContentSize().height / 2))
    --    listView:addChild(text)   --弄清楚相应的层级关系，计算出text相对的父容器是listview，而不是layer

    -- end

   



    self:addClickEvent(button_add, function ()
        -- body

        table.insert(List,textField_input:getString())
        updataListView(listView)

        -- local  input_text = ccui.Text:create()
        
        -- input_text:setFontSize(22)
        -- input_text:setColor(cc.c3b(255,0,0))
        -- input_text:setString()
        -- listView:addChild(input_text)

    end)





    self:addChild(base_layer)
end








    ---按钮点击事件注册
function MainScene:addClickEvent(btn, func)

    local iscantouch = true
    --是否可以执行
    local onbtn = function(sender,eventType)
        if eventType == ccui.TouchEventType.began then   --按钮 触摸开始处理
        
        end
        if eventType == ccui.TouchEventType.ended then   --按钮 触摸完成处理
            print("触摸完成～～～～")

            if func then
               func()
            end
        end
           
        if eventType == ccui.TouchEventType.canceled then   --按钮 触摸取消处理
        end
        
        if eventType == ccui.TouchEventType.moved then    --按钮 触摸移动事件处理
        end
    end
    
    --btn:addClickEventListener(onbtn)
    btn:addTouchEventListener(onbtn)
end


function MainScene:testListViewStr1(  )
    -- body


       -- ListView
    local listView = ccui.ListView:create()
    -- listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)  -- 设置方向为水平方向  
    listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)     -- 设置方向为垂直方向  
    listView:setBounceEnabled(true)                             -- 滑动惯性
    -- listView:setBackGroundImage("white_bg.png")              -- 背景图片
    listView:setBackGroundImageScale9Enabled(true)              -- 设置背景图片酒店图
    listView:setContentSize(600,300)  
    listView:setPosition(cc.p(display.cx,display.cy)) 
    listView:setAnchorPoint(cc.p(0.5,0.5))
    listView:setItemsMargin(10)                                 -- item间距
    listView:setScrollBarEnabled(false)                         -- 设置滚动条隐藏
    self:addChild(listView)

    -- 创建10个item
    for i = 1,10 do
        local layout = ccui.Layout:create()
        layout:setContentSize(300,300)
        layout:setAnchorPoint(cc.p(0.5,0.5))
        listView:addChild(layout)

        -- 这里创建的是ImageView 实际项目中可能会使用Label和Button
        -- local image = ccui.ImageView:create("HelloWorld.png")
        local text = ccui.Text:create()
        text:setFontSize(22)
        text:setColor(cc.c3b(255,0,0)):setScale(2)
        text:setString("adonai"..i)
        text:setPosition(cc.p(listView:getContentSize().width / 2,listView:getContentSize().height / 2))
        layout:addChild(text)
    end
end



function MainScene:testListView1(  )
    -- body

       --加载csb文件的方式
 local uiRoot2=cc.CSLoader:createNode("Layer2.csb")
   
     -- ListView
    local listView = ccui.ListView:create()

    listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)     -- 设置方向为垂直方向  
    listView:setBounceEnabled(true)                             -- 滑动惯性
    -- listView:setBackGroundImage("white_bg.png")              -- 背景图片
    listView:setBackGroundImageScale9Enabled(true)              -- 设置9宫格背景填充
    listView:setContentSize(600,300)  
    listView:setPosition(cc.p(display.cx,display.cy))
  
    listView:setAnchorPoint(cc.p(0.5,0.5))
    listView:setItemsMargin(0)                                 -- item间距
    --listView:setScrollBarEnabled(false)                         -- 设置滚动条隐藏
    self:addChild(listView)

    -- 创建10个item
    for i = 1,10 do
        local layout = ccui.Layout:create()
        layout:setContentSize(400,300)
        layout:setAnchorPoint(cc.p(0.5,0.5))
        listView:addChild(layout)

        -- 这里创建的是ImageView 实际项目中可能会使用Label和Button
        local image = ccui.ImageView:create("HelloWorld.png")
        image:setPosition(cc.p(listView:getContentSize().width /2,listView:getContentSize().height/2))
        layout:addChild(image)
    end

self:addChild(uiRoot2)

end


function MainScene:testLayer()
    -- body
       --加载csb文件的方式
  local uiRoot=cc.CSLoader:createNode("Layer.csb")
    
    self:resetLabelByName(uiRoot)


--progressBar
    local  to1 = cc.ProgressTo:create(2,100)
    local  progressBarTools = uiRoot:getChildByName("LoadingBar_1")
   -- progressBarTools.setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    --progressBarTools.setPosition(cc.p(size.width/4*2, size.height/2))


    progressBarTools:runAction(to1)
    -- to1:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),
    --     cc.CallFunc:create( function()
    --         self.gamescene:deleteAction("LoadingBar_1")
    --     end )))


    --button test
    --self:testButtonFunc(uiRoot)

    self:addChild(uiRoot)
end



function MainScene:testButtonFunc(uiRoot)

    -- body
--buttom listening
        local  btn = uiRoot:getChildByName("Button_1")
        btn:setTitleText("按钮")
        btn:setTitleFontSize(30)
        btn:setTitleColor(cc.c3b(255, 0, 0))
        --按钮的回调函数
        btn:addTouchEventListener(function ( sender,eventType )
            -- body
--[[
--这种方式调用
            if(0==eventType) then
                print("pressed finish()")
            elseif (1==eventType) then
                --todo
                print("move finish()")
            elseif (2==eventType) then
                --todo
                print("up")
            elseif (3==eventType) then
                --todo
                print("cancel() finish()")
            end

        --禁用按钮的特效
        btn:setEnabled(false)

]]

--或者是如下的调用方式
       if(ccui.TouchEventType.began==eventType) then
                print("pressed finish()")
            elseif (ccui.TouchEventType.moved==eventType) then
                --todo
                print("move finish()")
            elseif (ccui.TouchEventType.ended==eventType) then
                --todo
                print("up")
            elseif (ccui.TouchEventType.canceled==eventType) then
                --todo
                print("cancel() finish()")
            end


        end)

end


function MainScene:resetLabelByName(uiRoot)  
    --通过名称获取控件  
    local nameLabelBMFont = uiRoot:getChildByName("Text_1")  
    --设置文本  
   nameLabelBMFont:setString("hello 中国")  
   nameLabelBMFont:setScale(5)

  
  
    local passwordLabelBMFont = uiRoot:getChildByName("Text_2")  
    passwordLabelBMFont:setString("world")  

  
  
    local confirmLabelBMFont = uiRoot:getChildByName("Text_3")  
    confirmLabelBMFont:setString("adonai")  
end  





return MainScene
