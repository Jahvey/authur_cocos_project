local TableFactory = { }

function TableFactory.create(tableClass, actionClass)
    local TableTop = class("TableTop", tableClass)
    local LongCard = require "app.ui.game_base_cdd.base.LongCard"
    function TableTop:init(...)
       self.record_column_mac = 8
    end

    function TableTop:initLocalConf()
        self.localpos = 3
        self.MsgLayerOffset = { posx = - 50, posy = 50 }
         self.cardAnchor = cc.p(1,0.5)  
         self.effectnode = self.gamescene.layout:getChildByName("effectnode"):getChildByName("top")
    end

    function TableTop:refreshHandTile()

        if self.gamescene.name == "GameScene" and not self.gamescene:getMingPai() then
            return
        end
        self._pokers = {}
        self.handcardnode:removeAllChildren()
        self.handcardnode:setVisible(true)

        local handtile = clone(self.gamescene:getHandTileByIdx(self.tableidx))

        self.gamescene.Suanfuc:sort( handtile )
        printTable(handtile)
        local totall = #handtile
        for i,v in ipairs(handtile) do
            local pokerCard = LongCard.new(v)
            pokerCard:setScale(0.4)
            pokerCard:setCardAnchorPoint(cc.p(1,0))
            pokerCard:setPositionX((totall-i)*-50*0.4)
            self.handcardnode:addChild(pokerCard)
            table.insert(self._pokers ,pokerCard)
        end
        if self.gamescene:getDealerIndex() == self:getTableIndex() then
            if self.gamescene:getTableConf().ttype ~= HPGAMETYPE.HCNG then
                if #self._pokers > 0 then
                    self._pokers[#self._pokers]:setDizhutip()
                end
            end
        end

    end
    

    function TableTop:refreshPutoutTile()
    end

    function TableTop:chuPaiAction(data,isan)
        self.showcardnode:removeAllChildren()
        self.showcardnode:stopAllActions()
        self.showcardnode:setScale(1)
        self.showcardnode:setVisible(true)
        local totall = #data.cards
        data.type = data.cardtype
        local cardslocal = self.gamescene.Suanfuc:getrealcardsTab(data.cards,data)
        local cards = {}
        local sc = 0.72
        for i,v in ipairs(cardslocal) do
            local pokerCard = LongCard.new(v.value)
            if v.islai then
                pokerCard:setisshowLai(true)
            else
                pokerCard:setisshowLai(false)
            end
            pokerCard:setCardAnchorPoint(cc.p(0,0.5))
            pokerCard:setPositionY(self.cardheight*sc/2-20)
            pokerCard:setScale(sc)
            pokerCard:setPositionX((i-1)*55*sc)
            self.showcardnode:addChild(pokerCard)
            table.insert(cards,pokerCard)
        end

        if self.gamescene:getDealerIndex() == self:getTableIndex() then
            if self.gamescene:getTableConf().ttype ~= HPGAMETYPE.HCNG then
                if #cards > 0 then
                    cards[#cards]:setDizhutip()
                end
            end
        end
        if isan then
            local showpos = cc.p((self.cardwidth*totall-(totall-1)*55)/2*sc,self.cardheight*sc/2)
            showpos = self.showcardnode:convertToWorldSpace(showpos)
            self:playCardtypeAn(data,showpos)
            self.gamescene:deleteAction("完成打牌")
        else
            print("重连显示")
        end
    end

    return TableTop
end

return TableFactory