local LogoScene = class("LogoScene",function()
    return cc.Scene:create()
end)


function LogoScene:ctor()
    print("logoscene")
    local layer = cc.LayerColor:create(cc.c4b(255,255,255,255),display.width, display.height)
    self:addChild(layer)
    -- local bg = cc.Sprite:create("logo.png")
    --         :addTo(self)
    --         :setPosition(cc.p(display.cx,display.cy))
    -- self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
    -- 		glApp:enterScene("LoginScene")
    -- 	end)))
    local Director = cc.Director:getInstance()
    local WinSize = Director:getWinSize()
    for i=1,4 do
       local spr = cc.Sprite:create("game/cardbig/card_"..i..".png")
       spr:setScale(0.25)
       layer:addChild(spr)
       spr:setPosition(cc.p((WinSize.width/2)+(i - 2 -0.5)*180,WinSize.height/2+200))
    end
    --self.scene.cuolayer:addChild(cuo)
    local cuo
     cuo = require "app.cuoeffect"({1,2,3,4,5}, 0.7,function(  )
            cuo:removeFromParent()
            local spr = cc.Sprite:create("game/cardbig/card_".."5"..".png")
            layer:addChild(spr)
            spr:setAnchorPoint(cc.p(0.5,0.5))
            spr:setRotation(90)
            spr:setPosition(WinSize.width/2,WinSize.height/2- 75)
            spr:setScale(0.7)
            spr:setOpacity(0)
            spr:runAction(cc.Sequence:create(cc.FadeIn:create(0.5),cc.DelayTime:create(1),cc.CallFunc:create(function( ... )
                self:removeAllChildren()
            end)))
        end)
        self:addChild(cuo)


     --    self:setVisible(true)
     -- local cuo = require "app.cuoeffect"("Card.plist","card0.png", "card1.png", 2,function( ... )
     --    end)
     -- self:addChild(cuo)
end

return LogoScene
