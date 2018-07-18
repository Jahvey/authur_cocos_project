local TableFactory = { }

function TableFactory.create(tableClass, actionClass)
    local TableRight = class("TableRight", tableClass)
    local LongCard = require "app.ui.game_base_cdd.base.LongCard"

    function TableRight:refreshHandTile()

        if self.gamescene.name == "GameScene" then
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
            pokerCard:setPositionY(20)
            self.handcardnode:addChild(pokerCard)
            table.insert(self._pokers ,pokerCard)
        end
        -- if self.gamescene:getDealerIndex() == self:getTableIndex() then
        --     if #self._pokers > 0 then
        --         self._pokers[#self._pokers]:setDizhutip()
        --     end
        -- end
       
    end
    

    function TableRight:chuPaiAction(data,isan)
        self.showcardnode:removeAllChildren()
        self.showcardnode:setVisible(true)
        self.buchunode:setVisible(false)
        local totall = #data.cards
        data.type = data.cardtype
        local cardslocal = self.gamescene.Suanfuc:getrealcardsTab(data.cards,data)
        local cards = {}
        for i,v in ipairs(cardslocal) do

            local pokerCard = LongCard.new(v.value)
           if v.islai or pokerCard:getPokerValue() == LocalData_instance:getLaiZiValuer() then
                pokerCard:setisshowLai(true)
            else
                pokerCard:setisshowLai(false)
            end
            --pokerCard:setLocalZOrder(totall -i)
            pokerCard:setCardAnchorPoint(cc.p(1,0.5))
            pokerCard:setScale(CHU_CARD_SCALE)
            pokerCard:setPositionY(self.cardheight*CHU_CARD_SCALE/2)
            pokerCard:setPositionX((i-totall)*55*CHU_CARD_SCALE)
            self.showcardnode:addChild(pokerCard)
            table.insert(cards,pokerCard)
        end
        -- if self.gamescene:getDealerIndex() == self:getTableIndex() then
        --     if #cards > 0 then
        --         cards[#cards]:setDizhutip()
        --     end
        -- end

        if isan then
            local showpos = cc.p(-(self.cardwidth*totall-(totall-1)*55)/2*CHU_CARD_SCALE,self.cardheight*CHU_CARD_SCALE/2)
            showpos = self.showcardnode:convertToWorldSpace(showpos)
            self:playCardtypeAn(data,showpos)
            self.gamescene:deleteAction("完成打牌")
        else
            print("重连显示")
        end
    end

    return TableRight
end

return TableFactory