CARDTYPE = {
    MYHAND = 1,
    -- 我自己的手牌
    ACTIONSHOW = 2,
    -- 特效展示，
    ONTABLE = 3-- 摆在桌面上的牌，以及小结算界面，和操作选项
}

local LongCard = class("LongCard", function()
    return cc.Node:create()
end )

-- -1 其他家打牌状态图
-- -2 胡牌状态图
function LongCard:ctor(typemj, value)
    --结算默认第一套图片
    self.gameType = LocalData_instance:getGameType()
    if self.gameType == HPGAMETYPE.BDSDR or
        self.gameType == HPGAMETYPE.HFBH or
        self.gameType == HPGAMETYPE.XESDR or
        self.gameType == HPGAMETYPE.YSGSDR then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/pai_bdsdr.plist", "plist/pai_bdsdr.png")
    elseif self.gameType == HPGAMETYPE.LFSDR  then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/pai_lfsdr.plist", "plist/pai_lfsdr.png")
    elseif self.gameType == HPGAMETYPE.XCCH  then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/pai_xcch.plist", "plist/pai_xcch.png")
    elseif self.gameType == HPGAMETYPE.YCSDR  then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/ycsdr_card.plist", "plist/ycsdr_card.png")
    else
        cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/pai.plist", "plist/pai.png")
    end

    self.cardType = typemj
    self.cardValue = value

    local picstr = self:getPicPath()
    self.picstr = picstr
    if picstr == "" then
        print("没有找到牌的纹理图片")
        return
    end

    local _picstr =  cc.SpriteFrameCache:getInstance():getSpriteFrameByName(picstr)
    if _picstr  then
    else
        local data = {cardValue = self.cardValue,_picstr = picstr}
        self.cardValue = 0
        picstr = self:getPicPath()
        if device.platform ~= "ios"  and  device.platform ~= "android" then 
        else
            ComNoti_instance:dispatchEvent("add_Debug_List_Card",data)
        end
    end

    local _picstr = cc.Sprite:createWithSpriteFrameName(picstr)
    if _picstr then
        self.paiSprite = _picstr
        self:addChild(self.paiSprite)
        if device.platform ~= "ios"  and  device.platform ~= "android" then
            if self.cardType == CARDTYPE.MYHAND or self.cardType == CARDTYPE.ACTIONSHOW then
                local size = self.paiSprite:getContentSize()
                local  ttfConfig = math.floor(self.cardValue / 16)..self.cardValue % 16
                local label2 = cc.Label:createWithSystemFont(ttfConfig, "", 24)
                label2:setPosition( cc.p(15, size.height-15))
                label2:setTextColor( cc.c4b(255, 0, 0, 255))
                label2:setAnchorPoint(cc.p(0.5, 0.5))
                label2:enableOutline(cc.c4b(255,255,255,255))
                self.paiSprite:addChild(label2)
            end
        end
    else
        print("没有找到牌的纹理图片 picstr =" .. picstr .. ".")
    end
end

-- 获取图片
function LongCard:getPicPath()
    local paiStr = self.cardValue
    if self.cardValue ~= 0 then
        paiStr =(math.floor(self.cardValue / 16))..(self.cardValue % 16)
    end
    
    local str = ""
    if self.cardValue ~= 0 then
        if self.cardType == CARDTYPE.MYHAND then
            str = "shou_" .. paiStr
        elseif self.cardType == CARDTYPE.ONTABLE then
            str = "zhuo_" .. paiStr
        elseif self.cardType == CARDTYPE.ACTIONSHOW then
            str = "tong_" .. paiStr
        end
    else
        local bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type", 3)
        if self.cardType == CARDTYPE.ONTABLE then
            if bg_type == 1 or bg_type == 3 then
                str = "zhuo_paibei_1"
            else
                str = "zhuo_paibei_2"
            end
        else
            print(".....长牌背 bg_type =",bg_type)
            --现在只有一套图，但是有两个牌背
            if bg_type == 1 or bg_type == 3 then
                str = "tong_paibei_1"
            else
                str = "tong_paibei_2"
            end
        end
    end
    if self.gameType == HPGAMETYPE.BDSDR or 
        self.gameType == HPGAMETYPE.HFBH or
        self.gameType == HPGAMETYPE.XESDR or
        self.gameType == HPGAMETYPE.YSGSDR then
        return "bdsdr_"..str .. ".png"
    elseif self.gameType == HPGAMETYPE.LFSDR then
        return "lfsdr_"..str .. ".png"
    elseif self.gameType == HPGAMETYPE.XCCH then
        return "xcch_"..str .. ".png"
    elseif self.gameType == HPGAMETYPE.YCSDR  then
        return "ycsdr_"..str .. ".png"
    end
    return str .. ".png"
end


function LongCard:getCardValue()
    -- body
    return self.cardValue
end

function LongCard:getbg()
    return self.paiSprite
end

function LongCard:setOriginPos(posx, posy)
    self.orignpos = { x = posx, y = posy }
end

function LongCard:getOriginPos()
    if self.orignpos then
        return self.orignpos.x, self.orignpos.y
    end
    return false
end

function LongCard:setCardOpacticy(value)
    self.paiSprite:setOpacity(value)
end

function LongCard:setGray()
    self.isgray = true
    self.paiSprite:setColor(cc.c3b(0x99, 0x96, 0x96))
    if self.jiang_bg then
        self.jiang_bg:setColor(cc.c3b(0x99, 255, 255))
    end
end

function LongCard:getIsGray()
    if  self.isgray then
        return true
    end
    return false
end
function LongCard:hideGray()
     self.paiSprite:setColor(cc.c3b(255, 255, 255))
     self.isgray = false
     if self.jiang_bg then
        self.jiang_bg:setColor(cc.c3b(255, 255, 255))
     end
end
function LongCard:showJiang()
    if self.jiang_bg then
        return
    end
    --
    local str = "game/jiang_"
    if self.gameType == HPGAMETYPE.HFBH  then
        str = str.."bh_"
    elseif self.gameType == HPGAMETYPE.LFSDR  then
        str = str.."lf_"
    else
        str = str.."ysg_"
    end

    if self.cardType == CARDTYPE.ONTABLE then
        str = str.."table.png"
    elseif self.cardType == CARDTYPE.MYHAND then
        str = str.."hand.png"
    elseif self.cardType == CARDTYPE.ACTIONSHOW then
        str = str.."action.png"
    end

    self.jiang_bg = ccui.ImageView:create(str)
    self:addChild(self.jiang_bg)
end

function LongCard:showJoker()
    if self.joker_bg then
        return
    end
    --
    local str = "game/laizi_"
    if self.cardType == CARDTYPE.ONTABLE then
        str = str.."table.png"
    elseif self.cardType == CARDTYPE.MYHAND then
        str = str.."hand.png"
    elseif self.cardType == CARDTYPE.ACTIONSHOW then
        str = str.."action.png"
    end

    self.joker_bg = ccui.ImageView:create(str)
    self:addChild(self.joker_bg)

    if self.cardType == CARDTYPE.MYHAND then
        self.joker_bg:setPosition(cc.p(90-78,111-89))
    end


end


function LongCard:setbgstype(bg_type)

 
end


return LongCard