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
    if self.gameType == HPGAMETYPE.BDSDR or self.gameType == HPGAMETYPE.LJSDR or
        self.gameType == HPGAMETYPE.HFBH or self.gameType == HPGAMETYPE.XESDR or
        self.gameType == HPGAMETYPE.FJSDR or self.gameType == HPGAMETYPE.YSGSDR then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/pai_bdsdr.plist", "plist/pai_bdsdr.png")
    elseif self.gameType == HPGAMETYPE.LFSDR  then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/pai_lfsdr.plist", "plist/pai_lfsdr.png")
    elseif self.gameType == HPGAMETYPE.XCCH  then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/pai_xcch.plist", "plist/pai_xcch.png")
    elseif self.gameType == HPGAMETYPE.YCXZP  then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/pai_ycxzp.plist", "plist/pai_ycxzp.png")
    elseif self.gameType == HPGAMETYPE.YCSDR  then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/ycsdr_card.plist", "plist/ycsdr_card.png")
    elseif self.gameType == HPGAMETYPE.TCGZP  then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/tcgzp_card.plist", "plist/tcgzp_card.png")
    elseif self.gameType == HPGAMETYPE.SJHP or self.gameType == HPGAMETYPE.WJHP  then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/sjhp_card.plist", "plist/sjhp_card.png")
    else
        cc.SpriteFrameCache:getInstance():addSpriteFrames("plist/pai.plist", "plist/pai.png")
    end
    self.localvalue = value
    self.cardType = typemj
    
    -- print("value1:"..value)
    if value > 0xff then
        value = value%(16*16)
        self.isjing = true
    end
    self.cardValue = value
    -- print("value2:"..value)
   

    local picstr = self:getPicPath()
    self.picstr = picstr
    if picstr == "" then
        print("没有找到牌的纹理图片")
        return
    end
    -- print("......picstr = ",picstr)
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
        self.gameType == HPGAMETYPE.LJSDR or
        self.gameType == HPGAMETYPE.FJSDR or
        self.gameType == HPGAMETYPE.HFBH or
        self.gameType == HPGAMETYPE.XESDR or
        self.gameType == HPGAMETYPE.YSGSDR then
        return "bdsdr_"..str .. ".png"
    elseif self.gameType == HPGAMETYPE.LFSDR then
        return "lfsdr_"..str .. ".png"
    elseif self.gameType == HPGAMETYPE.XCCH then
        return "xcch_"..str .. ".png"
    elseif self.gameType == HPGAMETYPE.YCXZP then
        return "ycxzp_"..str .. ".png"
    elseif self.gameType == HPGAMETYPE.YCSDR  then
        return "ycsdr_"..str .. ".png"
    elseif self.gameType == HPGAMETYPE.TCGZP  then
        return "tcgzp_"..str .. ".png"
    elseif self.gameType == HPGAMETYPE.SJHP or self.gameType == HPGAMETYPE.WJHP then
        if self.isjing then
            return "sjhp_"..str .. "_hua.png"
        else
            return "sjhp_"..str .. ".png"
        end
    end
    return str .. ".png"
end


function LongCard:getCardValue()
    -- body
    if self.isjing then
        return self.localvalue
    else
        return self.cardValue
    end
    --return self.cardValue
end

function LongCard:getrealCardValue()
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
    if  self.paiSprite == nil  then
        return
    end
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

    if self.gameType == HPGAMETYPE.FJSDR  then
        self:showJiang_1()
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
function LongCard:showJiang_1()
    print("...........显示将牌")
    local str = "game/icon_huojing.png"
    self.jiang_bg = ccui.ImageView:create(str)
    self:addChild(self.jiang_bg)

    local size =  self.paiSprite:getContentSize()  
    local _size = self.jiang_bg:getContentSize() 
    self.jiang_bg:setPosition(cc.p((size.width-_size.width)/2.0-1,(size.height-_size.height)/2.0-2))
    if self.cardType == CARDTYPE.ONTABLE then
        self.jiang_bg:setScale(0.5)
        self.jiang_bg:setPosition(cc.p(size.width-_size.width/2.0-10,size.height-_size.height/2.0-10))
    end
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
function LongCard:setJian()
    if self.jian_tips then
        return
    end

    if self.cardType ~= CARDTYPE.MYHAND then
        return 
    end

    self.jian_tips = ccui.ImageView:create("game/icon_jian.png")
    self:addChild(self.jian_tips)
    local __size = self.jian_tips:getContentSize()
    self.jian_tips:setPosition(cc.p((90 - __size.width)/2.0-2,(111 - __size.height)/2.0-2))
end
function LongCard:getIsJian()
    if  self.jian_tips then
        return true
    end
    return false
end


--设置 下教的牌的标示，表示打出它之后，就能下教
function LongCard:setJiaoTips()
    if self.jiaoTips then
        self.jiaoTips:setVisible(true)
        return 
    end
    self.jiaoTips = ccui.ImageView:create("game/icon_ting.png")
    self:addChild(self.jiaoTips)
    local __size = self.jiaoTips:getContentSize()
    self.jiaoTips:setPosition(cc.p((90 - __size.width)/2.0-2,(111 - __size.height)/2.0-2))
end
function LongCard:hideJiaoTips()
    if self.jiaoTips ~= nil then
        self.jiaoTips:setVisible(false)
    end
end

function LongCard:getIsJiao()
    if self.jiaoTips then
        return self.jiaoTips:isVisible()
    end
    return false
end

function LongCard:setCardanpos(pos)
    self.paiSprite:setAnchorPoint(pos)
    self.paiSprite:setPosition(cc.p(0.5,0.5))
end

function LongCard:setbgstype(bg_type)

 
end


return LongCard