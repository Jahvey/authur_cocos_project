local TableFactory = { }

function TableFactory.create(tableClass, actionClass)
    local TableTop = class("TableTop", tableClass)
    local LongCard = require "app.ui.game.base.LongCard"
    function TableTop:init()
        
    end

    function TableTop:initLocalConf()
        self.MsgLayerOffset = { posx = - 50, posy = 50 }
        self.localpos = 3
        self.effectnode = self.gamescene.layout:getChildByName("effectnode"):getChildByName("top")
        -- 出牌节点
        self.moPaiPos = self.node:convertToWorldSpace(cc.p(self.nodebegin:getPosition()))

        -- --如果是两人的，坐标需要调整
        -- if self.gamescene:getTableConf().seat_num == 2 then
        --     print("..........如果是两人的，坐标需要调整",self.showCardNode:getPosition())
        --     -- self.icon:getChildByName("zhuang"):setPosition(cc.p(50,-57))
        -- end

    end

    function TableTop:refreshHandTile()
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
            height = (math.ceil((#handtile-1)/11))*42
        else
            width = width + #handtile*38*scale
            height = 42
        end
        self.handCardNode:setContentSize(cc.size(width,height))
        self.handCardNode:setPositionX(-width/2)
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

    function TableTop:refreshShowTile()
        if self.gamescene.name == "GameScene" then
            self:updataHuXiText()
        end
        self.showCardNode:removeAllChildren()
        self.showCardNode:setVisible(true)
        self.showcardspr = { }

        print("TableTop:refreshShowTile bai  zji  test")
        local showCardList = self:getShowCardList()
        self.nextShowPos = cc.p(-19, 21)
        local index = 0

         for i, v in ipairs(showCardList) do
            if v.card_ti then
                
                printTable(v,"xp69")

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
                self.nextShowPos = cc.p(self.nextShowPos.x-38,self.nextShowPos.y)
            end
        end
    end

    function TableTop:getShowPos(token)
        local showCol = self.gamescene:getShowTileByIdx(self.tableidx)
        for i,v in ipairs(showCol) do
            if v.token == token then
                return cc.p(-19-(i*38),21)
            end
        end
        return self.nextShowPos
    end


    function TableTop:refreshPutoutTile()

        self.outCardNode:removeAllChildren()
        self.outCardNode:setVisible(true)
        local putouttile = clone(self.gamescene:getPutoutTileByIdx(self.tableidx))
        self.outcardspr = { }
  
        self.nextPutPos = cc.p(BASECARDWIDTH/2,0-BASECARDHEIGHT/2)
       --putouttile = {17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17}
        for i,v in ipairs(putouttile) do
            local card = LongCard.new(CARDTYPE.ONTABLE, v)
            card:setPosition(self.nextPutPos)
            self.outCardNode:addChild(card)
            table.insert(self.outcardspr, card)
            if i%10 == 0 then
                self.nextPutPos = cc.p(BASECARDWIDTH/2, 0-BASECARDHEIGHT/2 - BASECARDHEIGHT*i/10)
            else
                self.nextPutPos = cc.p(cc.p(self.nextPutPos.x+38,self.nextPutPos.y))
            end
            if self.gamescene:getIsJiangCard(v) then
                card:showJiang()
            end
            if self.gamescene:getIsJokerCard(v) then
                card:showJoker()
            end
        end
    end
    return TableTop
end

return TableFactory