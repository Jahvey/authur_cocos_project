local LogoScene = class("LogoScene",function()
    return cc.Scene:create()
end)

function LogoScene:ctor()

    NOWANDROIDPATH = LOCALANDROIDPATH or "com/jiuyouqipai/arthur/wxapi/WXEntryActivity"
    print("logoscene")
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local addres = "https://www.baidu.com"
    xhr:open("GET", addres)
    xhr:send()

    math.randomseed(os.time())

    local layer = cc.LayerColor:create(cc.c4b(255,255,255,255),display.width, display.height)
    self:addChild(layer)
    local bg = cc.Sprite:create("logo.png")
            :addTo(self)
            :setPosition(cc.p(display.cx,display.cy))
    self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
    		
            glApp:enterScene("LoginScene")
    	end)))
end
return LogoScene
