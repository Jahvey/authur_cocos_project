

require "app.ui.CityManager"
require "app.ui.GameTypeManager"
require "app.help.WidgetUtils"
require "app.help.AudioUtils"
require "app.baseui.BaseView"
require "app.baseui.PopboxBaseView"
-- require "app.baseui.LaypopManger"
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
local TestMainDemo = class("TestMainDemo",function()
    return cc.Scene:create()
end)

function TestMainDemo:ctor()


    local  size = cc.Director:getInstance():getWinSize()
    --第一种方式
    -- local layer = cc.LayerColor:create(cc.c4b(255,255,255,0),size.width, size.height)
    -- self:addChild(layer)
    -- local bg = cc.Sprite:create("Spirit/bg.jpg")
    --         :addTo(self)
    --         :setPosition(cc.p(display.cx,display.cy))
    local widget = cc.CSLoader:createNode("myui/test/Layer.csb")
 
 --第二种方式
    -- widget:setPosition(0,0)


    local btn1 = widget:getChildByName("Button_show")
    WidgetUtils.addClickEvent(btn1, function( )
         print("设置22")
         --LaypopManger_instance:PopBox("myshowView1")
        LaypopManger_instance:PopBox("myshowNodeView1")
    end)

    



    self:addChild(widget)






end





return TestMainDemo
