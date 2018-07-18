local TableFactory = { }

function TableFactory.create(tableClass, actionClass)
    local TableLeft = class("TableLeft", tableClass)
    local MaJiangCard = require "app.ui.game_MJ.game_base.base.MaJiangCard"
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

    
    function TableLeft:refreshHandCards()
        self:updataHuXiText()
        self.handCardNode:removeAllChildren()
        self.handCardNode:setVisible(true)
        self.handcardspr = {}
        self.showcardspr = {}
        self.showJokerGangspr = {}

        print("..........TableTop:refreshHandCards()")
        local offy = 0
        local showCol = clone(self.gamescene:getShowCardsByIdx(self.tableidx))
        if  showCol and #showCol > 0 then
            for k,v in pairs(showCol) do
                if v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_GANG_2 then
                    local isHave = false
                    for kk,vv in pairs(self.showJokerGangspr) do
                        if vv:getCardValue() == v.dest_card then
                            vv.num = vv.num + 1
                            vv:setCardNum(vv.num)
                            isHave = true
                        end
                    end
                    if isHave == false then
                        local ma = MaJiangCard.new(MAJIANGCARDTYPE.LEFT,v.dest_card)
                        ma.num = 1
                        self.handCardNode:addChild(ma)
                        ma:setScale(0.75)
                        ma:setAnchorPoint(cc.p(0.5,1))
                        table.insert(self.showJokerGangspr,ma)
                        ma:setCardNum(1)
                        if self.gamescene:getIsJokerCard(v.dest_card) then
                            ma:showJoker()
                        end
                        if self.gamescene:getIsPiziCard(v.dest_card) then
                            ma:showPizi()
                        end
                        ma:setOriginPos(50,-80-#self.showJokerGangspr*35*0.75)
                        ma:setPosition(cc.p(50,-80-#self.showJokerGangspr*35*0.75))
                    end
                else
                    if  v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_CHI  then
                        for _k,_v in pairs(v.cards) do
                            if _v == v.dest_card  then
                                table.remove(v.cards,_k)
                            end
                        end
                        table.insert(v.cards,2,v.dest_card)
                    end
                    for kk,vv in pairs(v.cards) do
                        if  v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_AN_GANG and kk == 4 then
                            vv = 0
                        end
                        local ma = MaJiangCard.new(MAJIANGCARDTYPE.LEFT,vv)
                        self.handCardNode:addChild(ma)
                        table.insert(self.showcardspr,ma)
                        ma:setAnchorPoint(cc.p(0.5,1))
                        ma:setOriginPos(0, offy)
                        ma:setPosition(cc.p(0,offy))

                        if self.gamescene:getIsJokerCard(vv) then
                            ma:showJoker()
                        end
                        if self.gamescene:getIsPiziCard(vv) then
                            ma:showPizi()
                        end
                        -- if  v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_CHI  then
                        --     if  vv == v.dest_card  then
                        --         ma:setYellow()
                        --     end
                        -- end
                        if  v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_GANG or v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_AN_GANG then
                            if  kk == 4  then
                                ma:setPosition(cc.p(0,offy+35*2+11))
                            end
                        end
                        if  kk ~= 4  then
                            offy = offy - 35
                        end
                    end
                    offy = offy - 15
                end

                if k == #showCol then
                    if self.gamescene.name == "GameScene" then
                        offy = offy + 10
                    else
                        offy = offy - 5
                    end
                end
            end
        end 

        local handcards = clone(self.gamescene:getHandCardsByIdx(self.tableidx))
        table.sort(handcards)
        if handcards and #handcards > 0 then
            for i,v in ipairs(handcards) do
                if self.gamescene.name == "GameScene" then
                    v = -1
                end
                if  self.isChiPeng and i == #handcards then
                    self:showMoPai(v)
                else
                    local ma = MaJiangCard.new(MAJIANGCARDTYPE.LEFT,v)
                    self.handCardNode:addChild(ma)
                    table.insert(self.handcardspr,ma)
                    
                    ma:setAnchorPoint(cc.p(0.5,1))
                    ma:setOriginPos(0, offy)
                    ma:setPosition(cc.p(0,offy))

                    if self.gamescene.name == "GameScene" then
                        offy = offy - 25
                    else
                        offy = offy - 35
                    end
                end
            end
        end
    end
     --添加新摸的牌
    function TableLeft:showMoPai(value)

        print("...........TableBottom:addputout .......value = ",value)

        local showCol = self.gamescene:getShowCardsByIdx(self.tableidx)
        local offy = -38
        if  showCol and #showCol > 0 then
            for k,v in pairs(showCol) do
                if v.col_type ~= poker_common_pb.EN_SDR_COL_TYPE_YI_GANG_2 then
                    for kk,vv in pairs(v.cards) do
                        if  kk ~= 4  then
                            offy = offy - 35
                        end
                    end
                    offy = offy - 15
                end
                if k == #showCol then
                    if self.gamescene.name == "GameScene" then
                        offy = offy + 10
                    else
                        offy = offy - 5
                    end
                end
            end
        end
       
        local handcards = self.gamescene:getHandCardsByIdx(self.tableidx)
        if  handcards and #handcards > 0 then
            if self.gamescene.name == "GameScene" then
                offy = offy - (#handcards-1) * 25
            else
                offy = offy - (#handcards-1) * 35
            end
        end
        if self.gamescene.name == "GameScene" then
            value = -1
            offy = offy + 10
        end
        local ma = MaJiangCard.new(MAJIANGCARDTYPE.LEFT,value)
        self.handCardNode:addChild(ma)
        table.insert(self.handcardspr,ma)
        
        ma:setAnchorPoint(cc.p(0.5,1))
        ma:setOriginPos(0, offy)
        ma:setPosition(cc.p(0,offy))

        return ma
    end

    function TableLeft:refreshOutCards()
        self:updataHuXiText()
        self.outCardNode:removeAllChildren()
        self.outCardNode:setVisible(true)
        local putouttile = clone(self.gamescene:getPutoutTileByIdx(self.tableidx))
        self.outcardspr = { }
  
        self.nextPutPos = cc.p(BASECARDWIDTH/2,0-BASECARDHEIGHT/2)
        for i,v in ipairs(putouttile) do
            local ma = self:addputout(v)
            table.insert(self.outcardspr,ma)
        end
    end

    --添加一张打出去的牌
    function TableLeft:addputout(value)
        local totall = #self.outcardspr + 1

        local ma = MaJiangCard.new(MAJIANGCARDTYPE.LEFT,value)
        ma:setLocalZOrder(totall)
        ma:setAnchorPoint(cc.p(0,1))
        self.outCardNode:addChild(ma)
        if self.gamescene:getIsJokerCard(value) then
            ma:showJoker()
        end
        if self.gamescene:getIsPiziCard(value) then
            ma:showPizi()
        end

        local _num = 8
        if self.gamescene:getTableConf().seat_num == 2 then 
            _num = 14
        elseif self.gamescene:getTableConf().seat_num == 3 then 
            _num = 10
        end
        -- local _x = (_num/2.0 -(totall-1)%_num)*41 
        -- local _y = 0-math.floor((totall-1)/_num)*50

        local _x = math.floor((totall-1)/_num)*54
        local _y = (_num/2.0-(totall-1)%_num)*34

        ma:setPosition(cc.p(_x,_y))
        ma:setTag(totall)
        return ma
    end

    return TableLeft
end

return TableFactory