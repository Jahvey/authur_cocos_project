

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
    self.curscene = nil
end
function MyApp:run( )
	cc.FileUtils:getInstance():addSearchPath("res/")
    cc.FileUtils:getInstance():addSearchPath("res/cocostudio/")
	 --self:enterSceneByName("MajiangScene")
     self:createNotinode()
     self:enterSceneByName("LoginScene")
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

function MyApp:enterSceneByName(name,data)
    -- local scene = cc.Director:getInstance():getRunningScene()
    -- if scene.name and scene.name == name then
    --     return
    -- end
    print(".........进入 场景 ：",name)
    self.sceneName = name
    self:enterScene(name,data)
end

function MyApp:enterScene(sceneName, data, transitionType, time, more)
    STOPSOCEKT = false 
    local scenePackageName = "app.ui" .. ".scene." .. sceneName
    print("1")
    local sceneClass = require(scenePackageName)
    print("1.5")
    local scene = sceneClass.new(data)
    print("2")
    display.runScene(scene, transitionType, time, more)
    print("3")
    self.sceneName = sceneName
    self.curscene = scene
end
function MyApp:getCurScene()
    return self.curscene
end
return MyApp
