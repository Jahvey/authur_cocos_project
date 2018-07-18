
MAJIANGCARDTYPE = {
    RIGHT = 1,
    TOP = 2,
    LEFT = 3,
    BOTTOM = 4,
    MYSELF = 5,
    MYSELF_LEFT = 6,--自己碰杠的牌横向
    MYSELF_BIG = 7,--打出牌展示
}

--16近制 
--  1,2,3,4,5,6,7,8,9,//1-9 wan
-- 21,22,23,24,25,26,27,28,29,//1-9 tiao
-- 33,34,35,36,37,38,39,40,41,//1-9 tiao － 16

-- 41,42,43,44,45,46,47,48,49,//1-9 tong
-- 65,66,67,68,69,70,71,72,73,//1-9 tong － 16

--东 61  南 64  西 67 北 70 中 71发 76 白79 
local MaJiangCard = class("MaJiangCard",function()
    return cc.Node:create()
end)
-- value  -1 其他家打牌状态图
-- -2 胡牌状态图
function MaJiangCard:ctor(typemj,value)

    local picstr,valuestr  = self:getpicpath(typemj,value)
    local spr  =  cc.Sprite:create("gamemj/card/"..picstr)
    self:addChild(spr)


    -- print(".......value = ",value)
    --  print(".......picstr = ",picstr)
    --    print(".......valuestr = ",valuestr)


    if valuestr and valuestr ~= "" then
        local  valuespr = cc.Sprite:create("gamemj/card/"..valuestr)
        spr:addChild(valuespr,2)

        valuespr:setPosition(cc.p(spr:getContentSize().width/2,spr:getContentSize().height/2))
        self.valuespr  = valuespr
        local sprsize = spr:getContentSize()
        if typemj == MAJIANGCARDTYPE.TOP then
            valuespr:setPosition(cc.p(22,35))
        elseif typemj == MAJIANGCARDTYPE.BOTTOM then
            valuespr:setPosition(cc.p(28,50))
        elseif typemj == MAJIANGCARDTYPE.LEFT then
            valuespr:setPosition(cc.p(26,28))
        elseif typemj == MAJIANGCARDTYPE.RIGHT then
            valuespr:setPosition(cc.p(26,28))
        elseif typemj == MAJIANGCARDTYPE.MYSELF then
            valuespr:setPosition(cc.p(46,53))
        elseif typemj == MAJIANGCARDTYPE.MYSELF_LEFT then
            valuespr:setPosition(cc.p(44,44))
        elseif typemj == MAJIANGCARDTYPE.MYSELF_BIG then
            valuespr:setPosition(cc.p(42,72))
        end
    end
    self.typemj = typemj
    self.majiang = spr
    self.value  = value
    --当前牌的状态  主角使用  0为选中  1 选中
    self.type =  0
    self.show = nil
end

--获取图片
function MaJiangCard:getpicpath(typemj,value)


    local bg = ""
    local str = "pai/"
    if value > 0 then
        if typemj == MAJIANGCARDTYPE.TOP then
            bg = str.."show_small.png"
        elseif typemj == MAJIANGCARDTYPE.BOTTOM then
            bg = str.."front_show_big.png"
        elseif typemj == MAJIANGCARDTYPE.LEFT then
            bg = str.."left_show.png"
        elseif typemj == MAJIANGCARDTYPE.RIGHT then
            bg = str.."left_show.png"
        elseif typemj == MAJIANGCARDTYPE.MYSELF then
            bg = str.."front_inhand.png"
        elseif typemj == MAJIANGCARDTYPE.MYSELF_BIG then
            bg = str.."show_big.png"
        end
    elseif value == 0 or value == - 2 then
        if typemj == MAJIANGCARDTYPE.TOP then
            bg = str.."opposite_back.png"
        elseif typemj == MAJIANGCARDTYPE.BOTTOM then
            bg = str.."front_back.png"
        elseif typemj == MAJIANGCARDTYPE.LEFT then
            bg = str.."left_back.png"
        elseif typemj == MAJIANGCARDTYPE.RIGHT then
            bg = str.."right_back.png"
        elseif typemj == MAJIANGCARDTYPE.MYSELF then
            bg = str.."front_inhand.png"
        elseif  typemj == MAJIANGCARDTYPE.MYSELF_BIG then 
            bg = str.."opposite_back.png"
        end
    elseif  value == -1 then
        if typemj == MAJIANGCARDTYPE.TOP then
            bg = str.."opposite_inhand.png"
        elseif typemj == MAJIANGCARDTYPE.LEFT then
            bg = str.."left_inhand.png"
        elseif typemj == MAJIANGCARDTYPE.RIGHT then
            bg = str.."right_inhand.png"
        end
        return bg
    end



    local str = "" 
    if typemj == MAJIANGCARDTYPE.TOP  then
        str = "small/"
        if value == 0 or  value == -1 or value == -2 then 
            str = ""
        else
            if value < 0x10 then
                str = str.."wan_"..tostring(value%16).."_small.png"
            elseif value < 0x30 then
                str = str.."tiao_"..tostring(value%16).."_small.png"
            elseif value < 0x50 then
                str = str.."bing_"..tostring(value%16).."_small.png"
            elseif value <= 0x70 then
                str = str.."feng_"..tostring(value%16).."_small.png"
            elseif value == 0x71 then
                str = str.."zhong_small_gui.png"
            elseif value < 0x80 then
                str = str.."other_"..tostring(value%16).."_small.png"
            end

        end
       
    elseif typemj == MAJIANGCARDTYPE.BOTTOM then
        str = "medium/"
        if value == 0 or  value == -1 or value == -2 then 
            str = ""
        else 
            if value < 0x10 then
                str = str.."wan_"..tostring(value%16).."_medium.png"
            elseif value < 0x30 then
                str = str.."tiao_"..tostring(value%16).."_medium.png"
            elseif value < 0x50 then
                str = str.."bing_"..tostring(value%16).."_medium.png"
            elseif value <= 0x70 then
                str = str.."feng_"..tostring(value%16).."_medium.png"
            elseif value == 0x71 then
                str = str.."zhong_medium_gui.png"
            elseif value < 0x80 then
                str = str.."other_"..tostring(value%16).."_medium.png"
            end

        end
    elseif typemj == MAJIANGCARDTYPE.LEFT then
        str = "small_left/"
        if value == 0 or  value == -1 or value == -2 then 
            str = ""
        else 
            if value < 0x10 then
                str = str.."wan_"..tostring(value%16).."_small_left.png"
            elseif value < 0x30 then
                str = str.."tiao_"..tostring(value%16).."_small_left.png"
            elseif value < 0x50 then
                str = str.."bing_"..tostring(value%16).."_small_left.png"
            elseif value <= 0x70 then
                str = str.."feng_"..tostring(value%16).."_small_left.png"
            elseif value == 0x71 then
                str = str.."zhong_small_left_gui.png"
            elseif value < 0x80 then
                str = str.."other_"..tostring(value%16).."_small_left.png"
            end
        end
    elseif typemj == MAJIANGCARDTYPE.RIGHT then
        str = "small_right/"
        if value == 0 or  value == -1 or value == -2 then 
            str = ""
        else 
            if value < 0x10 then
                str = str.."wan_"..tostring(value%16).."_small_right.png"
            elseif value < 0x30 then
                str = str.."tiao_"..tostring(value%16).."_small_right.png"
            elseif value < 0x50 then
                str = str.."bing_"..tostring(value%16).."_small_right.png"
            elseif value <= 0x70 then
                str = str.."feng_"..tostring(value%16).."_small_right.png"
            elseif value == 0x71 then
                str = str.."zhong_small_right_gui.png"
            elseif value < 0x80 then
                str = str.."other_"..tostring(value%16).."_small_right.png"
            end
        end
    elseif typemj == MAJIANGCARDTYPE.MYSELF then
        str = "big/"
        if value == 0 or  value == -1 or value == -2 then 
            str = ""
        else 
            if value < 0x10 then
                str = str.."wan_"..tostring(value%16)..".png"
            elseif value < 0x30 then
                str = str.."tiao_"..tostring(value%16)..".png"
            elseif value < 0x50 then
                str = str.."bing_"..tostring(value%16)..".png"
            elseif value <= 0x70 then
                str = str.."feng_"..tostring(value%16)..".png"
            elseif value == 0x71 then
                str = str.."zhong_ui.png"
            elseif value < 0x80 then
                str = str.."other_"..tostring(value%16)..".png"
            end
        end

    elseif typemj == MAJIANGCARDTYPE.MYSELF_LEFT then
        str = "medium_left/"
        if value == 0 or  value == -1 or value == -2 then 
            str = ""
        else 
            if value < 0x10 then
                str = str.."wan_"..tostring(value%16).."_medium_left.png"
            elseif value < 0x30 then
                str = str.."tiao_"..tostring(value%16).."_medium_left.png"
            elseif value < 0x50 then
                str = str.."bing_"..tostring(value%16).."_medium_left.png"
            elseif value <= 0x70 then
                str = str.."feng_"..tostring(value%16).."_medium_left.png"
            elseif value == 0x71 then
                str = str.."zhong_small_left_gui.png"
            elseif value < 0x80 then
                str = str.."other_"..tostring(value%16)..".png"
            end

        end
     elseif typemj == MAJIANGCARDTYPE.MYSELF_BIG then

        str = "big/"
        if value == 0 or  value == -1 or value == -2 then 
            str = ""
        else 
            if value < 0x10 then
                str = str.."wan_"..tostring(value%16)..".png"
            elseif value < 0x30 then
                str = str.."tiao_"..tostring(value%16)..".png"
            elseif value < 0x50 then
                str = str.."bing_"..tostring(value%16)..".png"
            elseif value <= 0x70 then
                str = str.."feng_"..tostring(value%16)..".png"
            elseif value == 0x71 then
                str = str.."zhong_ui.png"
            elseif value < 0x80 then
                str = str.."other_"..tostring(value%16)..".png"
            end

        end
        
    end

  

    return bg,str


   
end

function MaJiangCard:getCardValue()
    -- body
    return self.value
end
function MaJiangCard:setAnchorPoint(p)
    self.majiang:setAnchorPoint(p)
end
function MaJiangCard:getAnchorPoint()
    return self.majiang:getAnchorPoint()
end
function MaJiangCard:getSizeforma()
    return self.majiang:getContentSize()
end

function MaJiangCard:getbg()
    return self.majiang
end

function MaJiangCard:setOriginPos(posx, posy)
    self.orignpos = { x = posx, y = posy }
end

function MaJiangCard:getOriginPos()
    if self.orignpos then
        return self.orignpos.x, self.orignpos.y
    end
    return false
end

function MaJiangCard:setCardOpacticy(value)
    self.majiang:setOpacity(value)
    self.valuespr:setOpacity(value)
end
---
--设置灰暗
function MaJiangCard:setGray()
    self.isgray = true
    self.majiang:setColor(cc.c3b( 0x99, 0x96, 0x96))
end
function MaJiangCard:getIsGray()
    if  self.isgray then
        return true
    end
    return false
end
function MaJiangCard:hideGray()
     self.majiang:setColor(cc.c3b(255, 255, 255))
     self.isgray = false
end

--设置碰杠的目标来源
function MaJiangCard:setPengZhiZhen(id)
    print("MaJiangCard:setPengZhiZhen",id)
   if self.pengZhiZhen then
        return 
    end
    self.pengZhiZhen = ccui.ImageView:create("gamemj/card/peng_arrow_"..id..".png")
    self.majiang:addChild(self.pengZhiZhen,1)
    self.pengZhiZhen:setPosition(cc.p(self.majiang:getContentSize().width/2-10,self.majiang:getContentSize().height/2+23))
    self.pengZhiZhen:setContentSize(self.majiang:getContentSize())
    self.pengZhiZhen:setVisible(true)
end

--设置吃牌
function MaJiangCard:hideYellow( )
    self.majiang:setColor(cc.c4b( 0xff, 0xff, 0xff,255))
end
function MaJiangCard:setYellow( show )

    if show == nil then
        show = true
    end
    -- FFFF00
    -- if show then
    --     self.majiang:setColor(cc.c4b( 0xff, 0xc6, 0x00,255/3))
    -- else
    --     self.majiang:setColor(cc.c4b( 0xff, 0xff, 0xff,255))
    -- end
    if self.yellow then
        self.yellow:setVisible(show)
        return 
    end
    self.yellow = ccui.ImageView:create("gamemj/card/card_yellow.png")
            :setScale9Enabled(true)
            :setCapInsets(cc.rect(14, 14, 1,1))
    self.majiang:addChild(self.yellow,1)
    self.yellow:setPosition(cc.p(self.majiang:getContentSize().width/2,self.majiang:getContentSize().height/2))
    self.yellow:setContentSize(self.majiang:getContentSize())

    self.yellow:setVisible(show)
end


--设置癞子
function MaJiangCard:showJoker()
    if  self.joker then
        return
    end
    print(".......显示癞子")

    local valuestr = "gamemj/card/laizi/"
    if self.typemj == MAJIANGCARDTYPE.TOP then
        valuestr = valuestr.."wang_show_small.png"
    elseif self.typemj == MAJIANGCARDTYPE.BOTTOM then
        valuestr = valuestr.."wang_front_show_big.png"
    elseif self.typemj == MAJIANGCARDTYPE.LEFT then
        valuestr = valuestr.."wang_left_show.png"
    elseif self.typemj == MAJIANGCARDTYPE.RIGHT then
        valuestr = valuestr.."wang_right_show.png"
    elseif self.typemj == MAJIANGCARDTYPE.MYSELF then
        valuestr = valuestr.."wang_front_inhand.png"
    elseif self.typemj == MAJIANGCARDTYPE.MYSELF_BIG then
        valuestr = valuestr.."wang_show_big.png"
    end
    print(".................  valuestr = ",valuestr)
    if  valuestr ~= "gamemj/card/laizi/" then
        self.joker = ccui.ImageView:create(valuestr)
        self.majiang:addChild(self.joker,4)
        if self.typemj == MAJIANGCARDTYPE.TOP then
            self.joker :setPosition(cc.p(19,30))
        elseif self.typemj == MAJIANGCARDTYPE.BOTTOM then
            self.joker :setPosition(cc.p(28,43))
        elseif self.typemj == MAJIANGCARDTYPE.LEFT then
            self.joker :setPosition(cc.p(26,20))
        elseif self.typemj == MAJIANGCARDTYPE.RIGHT then
            self.joker :setPosition(cc.p(25,21))
        elseif self.typemj == MAJIANGCARDTYPE.MYSELF then
            self.joker :setPosition(cc.p(43,62))
        end
    end

end

--设置痞子
function MaJiangCard:showPizi()
    if  self.pizi then
        return
    end
    print(".......显示癞子")

    local valuestr = "gamemj/card/pizi/"
    if self.typemj == MAJIANGCARDTYPE.TOP then
        valuestr = valuestr.."wang_show_small.png"
    elseif self.typemj == MAJIANGCARDTYPE.BOTTOM then
        valuestr = valuestr.."wang_front_show_big.png"
    elseif self.typemj == MAJIANGCARDTYPE.LEFT then
        valuestr = valuestr.."wang_left_show.png"
    elseif self.typemj == MAJIANGCARDTYPE.RIGHT then
        valuestr = valuestr.."wang_right_show.png"
    elseif self.typemj == MAJIANGCARDTYPE.MYSELF then
        valuestr = valuestr.."wang_front_inhand.png"
    elseif self.typemj == MAJIANGCARDTYPE.MYSELF_BIG then
        valuestr = valuestr.."wang_show_big.png"
    end
    print(".................  valuestr = ",valuestr)
    if  valuestr ~= "gamemj/card/pizi/" then
        self.pizi = ccui.ImageView:create(valuestr)
        self.majiang:addChild(self.pizi,4)
        if self.typemj == MAJIANGCARDTYPE.TOP then
            self.pizi :setPosition(cc.p(19,30))
        elseif self.typemj == MAJIANGCARDTYPE.BOTTOM then
            self.pizi :setPosition(cc.p(28,43))
        elseif self.typemj == MAJIANGCARDTYPE.LEFT then
            self.pizi :setPosition(cc.p(26,20))
        elseif self.typemj == MAJIANGCARDTYPE.RIGHT then
            self.pizi :setPosition(cc.p(25,21))
        elseif self.typemj == MAJIANGCARDTYPE.MYSELF then
            self.pizi :setPosition(cc.p(43,62))
        end
    end
end

function MaJiangCard:setCardNum(_num)
    if self.numTips then
        self.numTips:loadTexture("gamemj/card/num_".._num..".png",ccui.TextureResType.localType)
        return
    end

    local valuestr = "gamemj/card/num_".._num..".png"
    self.numTips = ccui.ImageView:create(valuestr)
    self.majiang:addChild(self.numTips,4)

    
    if self.typemj == MAJIANGCARDTYPE.TOP then
        self.numTips :setPosition(cc.p(35,22))
    elseif self.typemj == MAJIANGCARDTYPE.BOTTOM then
        self.numTips:setPosition(cc.p(50,30))
    elseif self.typemj == MAJIANGCARDTYPE.LEFT then
        self.numTips :setPosition(cc.p(12,17))
        self.numTips:setRotation(90)
    elseif self.typemj == MAJIANGCARDTYPE.RIGHT then
        self.numTips :setPosition(cc.p(41,38))
        self.numTips:setRotation(270)
    end

    -- if self.typemj == MAJIANGCARDTYPE.TOP then
    --     self.numTips :setPosition(cc.p(19,30))
    -- elseif self.typemj == MAJIANGCARDTYPE.BOTTOM then
    --     self.numTips :setPosition(cc.p(28,43))

    -- elseif self.typemj == MAJIANGCARDTYPE.MYSELF then
    --     self.numTips :setPosition(cc.p(43,62))
    -- end
end


--设置，牌桌出现过的牌的标示
function MaJiangCard:setIsShow()

    print("...setShow........self.value = ",self.value)
    
    if self.showTips ~= nil then
        self.showTips:setVisible(true)
        return 
    end
    print(".......显示癞子")

    local valuestr = "gamemj/card/show/"
    if self.typemj == MAJIANGCARDTYPE.TOP then
        valuestr = valuestr.."show_small_kuang.png"
    elseif self.typemj == MAJIANGCARDTYPE.BOTTOM then --
        valuestr = valuestr.."front_show.png"
    elseif self.typemj == MAJIANGCARDTYPE.LEFT then
        valuestr = valuestr.."left_show_kuang.png"
    elseif self.typemj == MAJIANGCARDTYPE.RIGHT then
        valuestr = valuestr.."left_show_kuang.png"
    elseif self.typemj == MAJIANGCARDTYPE.MYSELF then
        valuestr = valuestr.."front_inhand_kuang.png"
    end
    print(".................  valuestr = ",valuestr)
    if  valuestr ~= "gamemj/card/show/" then
        self.showTips = ccui.ImageView:create(valuestr)
        self.majiang:addChild(self.showTips,5)
        if self.typemj == MAJIANGCARDTYPE.TOP then
            self.showTips :setPosition(cc.p(21,31))
        elseif self.typemj == MAJIANGCARDTYPE.BOTTOM then --有
            self.showTips :setPosition(cc.p(28,43))
        elseif self.typemj == MAJIANGCARDTYPE.LEFT then
            self.showTips :setPosition(cc.p(27,28))
        elseif self.typemj == MAJIANGCARDTYPE.RIGHT then
            self.showTips :setPosition(cc.p(27,28))
        elseif self.typemj == MAJIANGCARDTYPE.MYSELF then
            self.showTips :setPosition(cc.p(45,66))
        end
    end
end
function MaJiangCard:hideShow()
    if self.showTips ~= nil then
        self.showTips:setVisible(false)
    end
end

--设置 下教的牌的标示，表示打出它之后，就能下教
function MaJiangCard:setJiaoTips()

    print("...setShow........self.value = ",self.value)
    
    if self.jiaoTips then
        self.jiaoTips:setVisible(true)
        return 
    end
    print("...setShow........self.value = 22 = ",self.value)
    self.jiaoTips = ccui.ImageView:create("gamemj/card/tips_jiao.png")
        :setPosition(cc.p(self.majiang:getContentSize().width/2,self.majiang:getContentSize().height+20))
    self.majiang:addChild(self.jiaoTips,99)
end
function MaJiangCard:hideJiaoTips()
    if self.jiaoTips ~= nil then
        self.jiaoTips:setVisible(false)
    end
end

function MaJiangCard:getIsJiao()
    if self.jiaoTips then
        return self.jiaoTips:isVisible()
    end
    return false
end






return MaJiangCard