cc.FileUtils:getInstance():addSearchPath("ui/")

local MainScene = class("MainScene", cc.load("mvc").ViewBase)

MainScene.RESOURCE_FILENAME = "MainScene.csb"

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
    self:testButtonFunc(uiRoot)

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
   nameLabelBMFont:setString("hello hhh")  
   nameLabelBMFont:setScale(5)

  
  
    local passwordLabelBMFont = uiRoot:getChildByName("Text_2")  
    passwordLabelBMFont:setString("world")  

  
  
    local confirmLabelBMFont = uiRoot:getChildByName("Text_3")  
    confirmLabelBMFont:setString("adonai")  
end  





return MainScene
