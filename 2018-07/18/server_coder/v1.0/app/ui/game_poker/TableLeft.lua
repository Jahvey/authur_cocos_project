local TableFactory = { }

function TableFactory.create(tableClass, actionClass)
    local TableLeft = class("TableLeft", tableClass)
    function TableLeft:init(...)
       self.record_column_mac = 8
    end

    function TableLeft:initLocalConf()
        self.MsgLayerOffset = { posx = 50, posy = 50 }
        self.localpos = 4

        self.effectnode = self.gamescene.layout:getChildByName("effectnode"):getChildByName("left")
        -- 出牌节点
        self.moPaiPos = self.node:convertToWorldSpace(cc.p(self.nodebegin:getPosition()))

        if self.gamescene.name == "RecordScene" then
            self.nodebegin:setPositionY(self.nodebegin:getPositionY()+52)
            self.outCardNode:setPosition(cc.p(29,24.5))
        end
    end

    function TableLeft:refreshHandTile()

        if self.gamescene.name == "GameScene" then
            local info = self.gamescene:getSeatInfoByIdx(self:getTableIndex())

            if info.state == poker_common_pb.EN_SEAT_STATE_NO_PLAYER or info.user == nil or info.user == { } then
                self.handnum:setVisible(false)
                return
            else
                if info.state == poker_common_pb.EN_SEAT_STATE_PLAYING then
                    self.handnum:setVisible(true)
                    local text = self.handnum:getChildByName("text")
                    local handtile = clone(self.gamescene:getHandTileByIdx(self:getTableIndex()))
                    text:setString(#handtile)
                else
                    self.handnum:setVisible(false)
                end
            end
            return
        end

        -- 回放界面
        self:updataHuXiText()
        self.handCardNode:removeAllChildren()
        self.handCardNode:setVisible(true)

        local sortdata = ComHelpFuc.sortPokerHandTile(clone(self.gamescene:getHandTileByIdx(self.tableidx)))

        local handtile = {}
        for i,v in ipairs(sortdata) do
            for m,n in ipairs(v) do
                table.insert(handtile,n)
            end
        end

        local scale = 0.5
        local imgwidth = 377
        local width = 126
        local totalwidth = 0
        local height = 0
        local interval = width*scale

        totalwidth = width*scale*#handtile

        if totalwidth > imgwidth then
            interval = (imgwidth-width*scale)/(#handtile-1)
        end
        -- self.handCardNode:setContentSize(cc.size(width,height))
        for i,v in ipairs(handtile) do
            local card = self.gamescene:createCardSprite(CARDTYPE.MYHAND,v)
            card:setScale(scale)
         
            card:setPosition(cc.p(width/2*scale+(i-1)*interval+2,94/2-1))
            self.handCardNode:addChild(card)
        end
    end
    function TableLeft:refreshShowTile()
        if self.gamescene.name == "GameScene" then
            self:updataHuXiText()
        end

        self.showCardNode:removeAllChildren()
        self.showCardNode:setVisible(true)

        print(".........TableBottom:refreshShowTile 刷新摆牌")

        self.showcardspr = { }
        print("bai  zji  test")
        local showCardList = self:getShowCardList()
        self.nextShowPos = cc.p(19, 21)
        
        printTable(showCardList,"xpp")

        local showlist = {{}}

        local cardsize = cc.size(42,52)
        local step = 21
        local colstep = 15

        local function getColWidth(cards)
            return cardsize.width*#cards-((#cards-1)*step)
        end

        for i,v in ipairs(showCardList) do
            local node = cc.Node:create()
                :addTo(self.showCardNode)

            for m,n in ipairs(v.cards) do
                local card = self.gamescene:createCardSprite(CARDTYPE.ONTABLE, n)
                card:addTo(node)
                card:setPosition(cc.p(cardsize.width/2+step*(m-1),-cardsize.height/2))
            end

            local isinsert = false
            local index = 0
            local posx = 0
            while (not isinsert) do
                index = index + 1
                if not showlist[index] then
                    showlist[index] = {}
                end
                local num = 0
                posx = 0
                for _,cols in ipairs(showlist[index]) do
                    num = num + #cols
                    posx = posx + getColWidth(cols) + colstep
                end
                num = num + #v.cards
                if num <= 9 then
                    table.insert(showlist[index],v.cards)
                    isinsert = true
                end
            end

            node:setPosition(cc.p(posx,-(index-1)*cardsize.height))

        end
        printTable(showlist,"xpp")
    end

    function TableLeft:getShowPos(token)
        local showlist = {{}}

        local cardsize = cc.size(42,52)
        local step = 21
        local colstep = 15

        local function getColWidth(cards)
            return cardsize.width*#cards-((#cards-1)*step)
        end

        local showCardList = self:getShowCardList()
        for i,v in ipairs(showCardList) do
            local isinsert = false
            local index = 0
            local posx = 0
            while (not isinsert) do
                index = index + 1
                if not showlist[index] then
                    showlist[index] = {}
                end
                local num = 0
                posx = 0
                for _,cols in ipairs(showlist[index]) do
                    num = num + #cols
                    posx = posx + getColWidth(cols) + colstep
                end
                num = num + #v.cards
                if num <= 9 then
                    table.insert(showlist[index],v.cards)
                    isinsert = true
                end
            end
            if i == #showCardList then
                print("====================位置")
                return cc.p(posx,-(index-1)*cardsize.height)
            end
        end
        return self.nextShowPos
    end


    function TableLeft:refreshPutoutTile()
        print(".........TableLeft:refreshPutoutTile 刷新摆牌")

        local width = 42
        local height = 52

        -- if self.gamescene:getTableConf().seat_num == 3 then
        --     -- self.outCardNode:setVisible(false)
        --     -- local putouttile =  clone(self.gamescene:getTotalOutTileByIdx(self.tableidx))
        --     -- if #putouttile > 0 then
        --     --     self.qicardnum:setVisible(true)
        --     --     self.qicardnum:getChildByName("text"):setString(#putouttile)
        --     -- else
        --     --     self.qicardnum:setVisible(false)
        --     -- end
        --     -- return
        --     width = 26

        -- end

        self.outCardNode:removeAllChildren()
        self.outCardNode:setVisible(true)
        local putouttile 
        if self.gamescene:getTableConf().ttype == HPGAMETYPE.XE96 then
            putouttile =  clone(self.gamescene:getDiscardTileByIdx(self.tableidx))
        elseif self.gamescene:getTableConf().seat_num == 3 then
            putouttile =  clone(self.gamescene:getTotalOutTileByIdx(self.tableidx))
        else
            putouttile =  clone(self.gamescene:getPutoutTileByIdx(self.tableidx))
        end
        self.outcardspr = { }
 
        self.nextPutPos = cc.p(width/2,0-height/2)
       -- putouttile = {17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17}
        local maxcolumnum = 10
        for i,v in ipairs(putouttile) do
            local value = v
            if self.gamescene:getTableConf().seat_num == 3 and self.gamescene:getTableConf().ttype ~= HPGAMETYPE.XE96 then
                width = 26
                maxcolumnum = 16
                if not v.is_napai and self.gamescene.name == "GameScene" then
                    value = 0
                else
                    value = v.value
                end
            end
            local card = self.gamescene:createCardSprite(CARDTYPE.ONTABLE, value)

            card:setPosition(self.nextPutPos)
            self.outCardNode:addChild(card)
            table.insert(self.outcardspr, card)
            if i%maxcolumnum == 0 then
                self.nextPutPos = cc.p(width/2, -height/2 - height*i/maxcolumnum)
            else
                self.nextPutPos = cc.p(cc.p(self.nextPutPos.x+width,self.nextPutPos.y))
            end
            print("...........TableLeft..self.nextPutPos i = ",i)
            print("...........TableLeft..self.nextPutPos x= "..self.nextPutPos.x.." y: "..self.nextPutPos.y)

            if self.gamescene:getIsJiangCard(v) then
                card:showJiang()
            end
        end

    end

    function TableLeft:refreshDiscardTile()
        if self.gamescene:getTableConf().ttype ~= HPGAMETYPE.XE96 then
            self.qiCardNode:setVisible(false)
            return
        end
        self.qiCardNode:setVisible(true)
        self.qiCardNode:getChildByName("sprnode"):removeAllChildren()
        self.qicardspr = { }

        local width = 42
        local height = 52

        self.nextDiscardPos = cc.p(width/2,0)
        local qiCardTile =  clone(self.gamescene:getPutoutTileByIdx(self.tableidx))
        if qiCardTile and #qiCardTile > 0 then
            self.qiCardNode:setVisible(true)
        end

        for i,v in ipairs(qiCardTile) do
            local card = self.gamescene:createCardSprite(CARDTYPE.ONTABLE, v)
            card:setPosition(self.nextDiscardPos)
            self.qiCardNode:getChildByName("sprnode"):addChild(card)
            table.insert(self.qicardspr, card)

          
            self.nextDiscardPos = cc.p(cc.p(self.nextDiscardPos.x+25,self.nextDiscardPos.y))
        end
    end


    return TableLeft
end

return TableFactory