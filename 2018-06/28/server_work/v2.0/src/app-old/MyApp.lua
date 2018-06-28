

function LINK_FUCN_FOR_ANDROID(msg)
    --安卓获取到link转移到这里
    print("安卓link:"..msg)
    local event = cc.EventCustom:new("weixinurl")
   event:setDataString(msg)
   cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

local MyApp = class("MyApp",function()
    return {}
end)

function MyApp:ctor( )
    self.sceneName = ""
    -- 全局app
    glApp = self
    self.curscene = nil
end
function MyApp:run( )
    cc.FileUtils:getInstance():addSearchPath("res/")
    cc.FileUtils:getInstance():addSearchPath("res/cocostudio/")
     --self:enterScene("MajiangScene")
     self:createNotinode()
     self:enterScene("LogoScene")
end
function MyApp:createNotinode()
    local node = cc.Node:create()
    cc.Director:getInstance():setNotificationNode(node)


    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local listener = cc.EventListenerCustom:create("weixinurl" , function ( evt )
       print("MYAPP ")
       LINK_URL_DATA  = evt:getDataString()
    end)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)

end

function MyApp:enterSceneByName( name,data)
    -- local scene = cc.Director:getInstance():getRunningScene()
    -- if scene.name and scene.name == name then
    --     return
    -- end
    release_print(".........进入 场景 ：",name)
    self.sceneName = name
    self:enterScene(name,data)
end
-- require ("app.ui.scene.BaseScene")
function MyApp:enterScene(sceneName, data, transitionType, time, more)
    -- if sceneName == "MajiangScene" then
    --     sceneName = "testScene"
    -- end
    print("join scene:"..sceneName)
    local scenePackageName = "app.ui" .. ".scene." .. sceneName
    local sceneClass = require(scenePackageName)
    local scene = sceneClass.new(data)
    scene:init()
    display.runScene(scene, transitionType, time, more)
    scene.sceneName = sceneName
    self.sceneName = sceneName
    self.curscene = scene
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end
function MyApp:getCurScene()
    return self.curscene
end

function MyApp:pushScene(sceneName,data)
    local scenePackageName = "app.ui" .. ".scene." .. sceneName
    local sceneClass = require(scenePackageName)
    local scene = sceneClass.new(data)

    cc.Director:getInstance():pushScene(scene)
end
return MyApp
