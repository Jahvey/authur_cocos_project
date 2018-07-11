

require "app.ui.CityManager"
require "app.ui.GameTypeManager"
require "app.help.WidgetUtils"
require "app.help.AudioUtils"
require "app.baseui.BaseView"
require "app.baseui.PopboxBaseView"
require "app.module.PopboxManager"
require "app.help.ComNoti"
require "app.help.CommonUtils"
require "app.net.SocketConnect"
require "app.help.NetPicUtils"

require "app.net.Socketapi"
require "app.net.ComHttp"
require "app.module.HttpManager"
require "app.ui.Notinode"
require "app.help.ComHelpFuc"
require "app.data.LocalData"
local TestMainOneScene = class("TestMainOneScene",function()
    return cc.Scene:create()
end)

function TestMainOneScene:ctor()


    local  size = cc.Director:getInstance():getWinSize()

    local widget = cc.CSLoader:createNode("myui/raward/Layer.csb")

    local main_layer = widget:getChildByName("main")

    local btn1=main_layer:getChildByName("btn_init")

    WidgetUtils.addClickEvent(btn1, function ( )
        -- body
     
         LaypopManger_instance:PopBox("mainHallNodeView")
    end)
    
    self:addChild(widget)


end



return TestMainOneScene
