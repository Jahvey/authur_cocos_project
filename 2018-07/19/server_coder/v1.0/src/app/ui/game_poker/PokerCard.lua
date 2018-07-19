CARDTYPE = {
    MYHAND = 1,  --我自己的手牌
    ACTIONSHOW = 2, --特效展示，
    ONTABLE = 3 --摆在桌面上的牌，以及小结算界面，和操作选项
}

local kCardStateGrabbed = 0 -- 获取到
local kCardStateUngrabbed  = 1-- 没有获取到

local PokerCard = class("PokerCard",function()
    return cc.Node:create()
end)
 -- 0x11~0x1d 方块
     -- 0x21~0x2d 红桃
     --0x31~0x3d 梅花
     --0x41~0x4d 黑桃
     -- 0x51 王

-- value  -1 其他家打牌状态图
-- -2 胡牌状态图
function PokerCard:ctor(typemj,value,isgray)
    self.touchState = kCardStateUngrabbed

    -- cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/pai_1.plist","plist/pai_1.png")
    -- cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/pai_2.plist","plist/pai_2.png")
    
    self.cardType = typemj
    self.cardValue  = value

    local picstr = self:getPicPath()
    -- print("...........PokerCard:ctor =",picstr)
    
    self.picstr = picstr
    if picstr == "" then
        print("没有找到牌的纹理图片")
        return
    end

    local _picstr  = cc.Sprite:create(picstr)
    if _picstr then
        self.paiSprite = _picstr
        self:addChild(self.paiSprite)
    else
        print("没有找到牌的纹理图片 picstr ="..picstr..".")
    end    
end

--获取图片
function PokerCard:getPicPath()
    local paiStr = self.cardValue
    -- if  self.cardValue ~= 0 then
    --     paiStr = (math.floor(self.cardValue/16))..(self.cardValue%16)
    -- end
    
    local str =""
    if self.cardType == CARDTYPE.MYHAND then
        str = "pokercard/card_b_"..self.cardValue..".png"
    elseif self.cardType == CARDTYPE.ONTABLE then
        str = "pokercard/card_s_"..self.cardValue..".png"
    elseif self.cardType == CARDTYPE.ACTIONSHOW then
        str = "pokercard/card_b_"..self.cardValue..".png"
    end
    -- local bg_type  =  cc.UserDefault:getInstance():getIntegerForKey("bg_type_poker",1)
    -- if bg_type == 3 then
    --     bg_type = 1
    -- elseif bg_type == 4 then
    --     bg_type = 2
    -- end

    return str
end

function PokerCard:setCardValue(value)
    self.cardValue = value
end
function PokerCard:getCardValue()
    -- body
    return  self.cardValue
end

function PokerCard:getbg()
    return self.paiSprite
end

function PokerCard:setOriginPos(posx,posy)
    self.orignpos = {x = posx,y = posy}
end

function PokerCard:getOriginPos()
    if self.orignpos then
        return self.orignpos.x,self.orignpos.y
    end
    return false
end

function PokerCard:setCardOpacticy(value)
    self.paiSprite:setOpacity(value)
end

function PokerCard:setGray()
    if self.graybg then
        return 
    end
    self.graybg = ccui.ImageView:create("common/null1.png")
            :setScale9Enabled(true)
            :setCapInsets(cc.rect(0, 0, 1,1))
    self.paiSprite:addChild(self.graybg)
    self.graybg:setPosition(cc.p(self.paiSprite:getContentSize().width/2,self.paiSprite:getContentSize().height/2))
    self.graybg:setContentSize(self.paiSprite:getContentSize())
    self.graybg:setVisible(true)
end

function PokerCard:hideGray()
    if not self.graybg then
        return
    end
    self.graybg:removeFromParent()
    self.graybg = nil
end

function PokerCard:getIsGray()
    if self.graybg and self.graybg:isVisible() then
        return true
    end
    return false
end
function PokerCard:setbgstype(bg_type)

    local picstr = self:getPicPath()
    self.picstr = picstr

    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(picstr)  
    if frame then
        self.paiSprite:setSpriteFrame(frame)
    else
        print("没有找到牌的纹理图片 picstr =",picstr)
    end 
end
function PokerCard:setAn( point )
    self.paiSprite:setAnchorPoint(point)
    self.paiSprite:setPosition(cc.p(0,0))
end

function PokerCard:showJiang()
end

return PokerCard