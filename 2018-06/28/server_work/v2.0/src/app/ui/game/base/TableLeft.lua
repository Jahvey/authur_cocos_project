local TableFactory = { }

function TableFactory.create(tableClass, actionClass)
    local TableLeft = class("TableLeft", tableClass)
    local LongCard = require "app.ui.game.base.LongCard"
    function TableLeft:init(...)
       self.record_column_mac = 8
    end

    function TableLeft:initLocalConf()
        self.MsgLayerOffset = { posx = 50, posy = 50 }
        self.localpos = 4

        self.effectnode = self.gamescene.layout:getChildByName("effectnode"):getChildByName("left")
        -- 出牌节点
        self.moPaiPos = self.node:convertToWorldSpace(cc.p(self.nodebegin:getPosition()))

    end

    function TableLeft:refreshHandTile()

        if self.gamescene.name == "GameScene" then
            return
        end
        self:updataHuXiText()
        self.handCardNode:removeAllChildren()
        self.handCardNode:setVisible(true)

        local handtile = clone(self.gamescene:getHandTileByIdx(self.tableidx))
        handtile = ComHelpFuc.sortOtherHandTile(handtile)


       local scale = 0.84
        local width = 4+4
        local height = 0
        if #handtile > 11 then
            width = width + 11*38*scale
            height = (math.ceil((#handtile)/11))*42
        else
            width = width + #handtile*38*scale
            height = 42
        end
        self.handCardNode:setContentSize(cc.size(width,height))
        for i,v in ipairs(handtile) do
            local card = LongCard.new(CARDTYPE.ONTABLE,v)
            card:setScale(scale)
         
            card:setPosition(cc.p(4+((i-1)%11)*38*scale+38*scale/2,math.floor(((i-1)/11))*40+42*scale/2 + 4  ))
            self.handCardNode:addChild(card)

            if self.gamescene:getIsJiangCard(v) then
                card:showJiang()
            end

            if self.gamescene:getIsJokerCard(v) then
                card:showJoker()
            end
        end
    end
    function TableLeft:refreshShowTile()
        if self.gamescene.name == "GameScene" then
            self:updataHuXiText()
        end

        self.showCardNode:removeAllChildren()
        self.showCardNode:setVisible(true)
        self.showcardspr = { }
    
        print("TableLeft bai  zji  test")
        local showCardList = self:getShowCardList()
        self.nextShowPos = cc.p(15, 21)
        local index = 0
        for i, v in ipairs(showCardList) do
            if v.card_ti then
            for ii, vv in ipairs(v.card_ti) do
                print("create:"..vv.card)
                local card = LongCard.new(CARDTYPE.ONTABLE, vv.card)
                card:setLocalZOrder(100-ii)
                if #v.card_ti >= 6 then
                    card:setPosition(cc.p(self.nextShowPos.x,self.nextShowPos.y+(ii-1)*16))
                else
                    card:setPosition(cc.p(self.nextShowPos.x,self.nextShowPos.y+(ii-1)*36))
                end
                self.showCardNode:addChild(card)
                table.insert(self.showcardspr, card)
                if self.gamescene:getIsJiangCard(vv.card) then
                    card:showJiang()
                end
                if self.gamescene:getIsJokerCard(vv.card) then
                    card:showJoker()
                end
            end
            if self.gamescene:getTableConf().ttype == HPGAMETYPE.XCCH  then 
                if v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_MAI then
                    local maiNode = self:addQiShouMaiTips(v)
                    maiNode:setVisible(true)
                    maiNode:setPosition(self.nextShowPos)
                    maiNode:setLocalZOrder(100)
                    self.showCardNode:addChild(maiNode,99)

                end
            end
            index = index + 1
            self.nextShowPos = cc.p(self.nextShowPos.x+38,self.nextShowPos.y)
        end
        
        end
    end

    function TableLeft:getShowPos(token)
        local showCol = self.gamescene:getShowTileByIdx(self.tableidx)
        for i,v in ipairs(showCol) do
            if v.token == token then
                return cc.p(15+(i*38),21)
            end
        end
        return self.nextShowPos
    end


    function TableLeft:refreshPutoutTile()
        print(".........TableLeft:refreshPutoutTile 刷新摆牌")

        self.outCardNode:removeAllChildren()
        self.outCardNode:setVisible(true)
        local putouttile 
        if self.gamescene:getTableConf().ttype == HPGAMETYPE.ESSH or self.gamescene:getTableConf().ttype == HPGAMETYPE.XESDR or self.gamescene:getTableConf().ttype == HPGAMETYPE.XFSH then
            putouttile =  clone(self.gamescene:getDiscardTileByIdx(self.tableidx))
        else
            putouttile =  clone(self.gamescene:getPutoutTileByIdx(self.tableidx))
        end
        self.outcardspr = { }
 
        self.nextPutPos = cc.p(BASECARDWIDTH/2,0-BASECARDHEIGHT/2)
       -- putouttile = {17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17}
        for i,v in ipairs(putouttile) do
            local card = LongCard.new(CARDTYPE.ONTABLE, v)
            card:setPosition(self.nextPutPos)
            self.outCardNode:addChild(card)
            table.insert(self.outcardspr, card)
            if i%10 == 0 then
                self.nextPutPos = cc.p(BASECARDWIDTH/2, -BASECARDHEIGHT/2 - BASECARDHEIGHT*i/10)
            else
                self.nextPutPos = cc.p(cc.p(self.nextPutPos.x+38,self.nextPutPos.y))
            end
            print("...........TableLeft..self.nextPutPos i = ",i)
            print("...........TableLeft..self.nextPutPos x= "..self.nextPutPos.x.." y: "..self.nextPutPos.y)

            if self.gamescene:getIsJiangCard(v) then
                card:showJiang()
            end
            if self.gamescene:getIsJokerCard(v) then
                card:showJoker()
            end
        end

    end

    function TableLeft:refreshDiscardTile()
        if self.gamescene:getTableConf().ttype ~= HPGAMETYPE.ESSH and  self.gamescene:getTableConf().ttype ~= HPGAMETYPE.XESDR and self.gamescene:getTableConf().ttype ~= HPGAMETYPE.XFSH then
            self.qiCardNode:setVisible(false)
            return
        end
        self.qiCardNode:removeAllChildren()
        self.qicardspr = { }
        self.nextDiscardPos = cc.p(20+BASECARDWIDTH, BASECARDHEIGHT/2)
        local qiCardTile =  clone(self.gamescene:getPutoutTileByIdx(self.tableidx))
        if  qiCardTile and #qiCardTile > 0 then
            self.qiCardNode:setVisible(true)
        end

        for i,v in ipairs(qiCardTile) do
            local card = LongCard.new(CARDTYPE.ONTABLE, v)
            card:setPosition(self.nextDiscardPos)
            self.qiCardNode:addChild(card)
            table.insert(self.qicardspr, card)

          
            self.nextDiscardPos = cc.p(cc.p(self.nextDiscardPos.x+38,self.nextDiscardPos.y))
        end
    end


    return TableLeft
end

return TableFactory