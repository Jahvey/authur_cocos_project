local Card = class("Card",function()
    return cc.Node:create()
end)

function Card:ctor(value,issmall)
    self.issmall = issmall
    self.value = value
    self.localvalue = 0
    if self.issmall then
         self.valuespr = cc.Sprite:create("game/cards/card0.png")
    else
        self.valuespr = cc.Sprite:create("game/cards1/card0.png")
    end
    if value ~= 0 then
        if self.issmall then
            self.valuespr:setTexture("game/cards/card"..value..".png")
        else
            self.valuespr:setTexture("game/cards1/card"..value..".png")
        end
    end
    --self.valuespr:setAnchorPoint(cc.p(0,0))
    self:addChild(self.valuespr)

end
function Card:setCardAnchorPoint(point)
    self.valuespr:setAnchorPoint(point)
    self.valuespr:setPosition(cc.p(0,0))
end

function Card:getValue()

    return self.value
end
function Card:setlocalvalue(value)
    self.localvalue = value

end

function Card:getlocalvalue()
    return self.localvalue

end


function Card:showlocalvlue( )
    self:setValue(self.localvalue)
end
function Card:setValue( value )


    if self.issmall then
        self.valuespr:setTexture("game/cards/card"..value..".png")
        print("game/cards/card"..value..".png")
    else
         self.valuespr:setTexture("game/cards1/card"..value..".png")
         print("game/cards1/card"..value..".png")
    end
    self.value =value
end


function Card:setGray()
   self.valuespr:setColor(cc.c3b(191, 191, 191))
end


return Card