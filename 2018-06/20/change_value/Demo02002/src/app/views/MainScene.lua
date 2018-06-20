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


    progressBarTools:runAction(cc.RepeatForever:create(to1))
    -- to1:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),
    --     cc.CallFunc:create( function()
    --         self.gamescene:deleteAction("LoadingBar_1")
    --     end )))

    self:addChild(uiRoot)



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
