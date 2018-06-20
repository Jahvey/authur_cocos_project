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
    
    --通过名称获取控件  
    local nameLabelBMFont = uiRoot:getChildByName("Text_1")  
    --设置文本  
   nameLabelBMFont:setString("A")  
   nameLabelBMFont:setScale(5)

  
  
    local passwordLabelBMFont = uiRoot:getChildByName("Text_2")  
    passwordLabelBMFont:setString("B")  

  
  
    local confirmLabelBMFont = uiRoot:getChildByName("Text_3")  
    confirmLabelBMFont:setString("C")  



    self:addChild(uiRoot)



end



-- function MainScene:resetLabelByName(uiRoot)  
--     --通过名称获取控件  
--     local nameLabelBMFont = uiRoot:getChildByName("Text_1")  
--     --设置文本  
--    nameLabelBMFont:setString("A")  
--    self:addChild(nameLabelBMFont)
  
  
--     local passwordLabelBMFont = uiRoot:getChildByName("Text_2")  
--     passwordLabelBMFont:setString("B")  
--     self:addChild(passwordLabelBMFont)
  
  
--     local confirmLabelBMFont = uiRoot:getChildByName("Text_3")  
--     confirmLabelBMFont:setString("C")  

--      self:addChild(confirmLabelBMFont)
-- end  





return MainScene
