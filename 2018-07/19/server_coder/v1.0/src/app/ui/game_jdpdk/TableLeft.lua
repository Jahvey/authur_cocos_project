local TableFactory = { }

function TableFactory.create(tableClass, actionClass)
    local TableLeft = class("TableLeft", tableClass)
    local LongCard = require "app.ui.game_base_cdd.base.LongCard"

    function TableLeft:refreshHandTile()

        if self.gamescene.name == "GameScene" then
            return
        end
        self._pokers  = {}
        self.handcardnode:removeAllChildren()
        self.handcardnode:setVisible(true)

        local handtile = clone(self.gamescene:getHandTileByIdx(self.tableidx))
        print("_----------牌")
        printTable(handtile,"sjp10")
        self.gamescene.Suanfuc:sort( handtile )
        printTable(handtile)
        local totall = #handtile
        for i,v in ipairs(handtile) do
            local pokerCard = LongCard.new(v)
            pokerCard:setScale(0.4)
            pokerCard:setCardAnchorPoint(cc.p(0,0))
            pokerCard:setPositionX((i-1)*50*0.4)
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
    

    function TableLeft:chuPaiAction(data,isan)
        self.showcardnode:removeAllChildren()
        self.showcardnode:stopAllActions()
        self.showcardnode:setScale(1)
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

            pokerCard:setCardAnchorPoint(cc.p(0,0.5))
            pokerCard:setPositionY(self.cardheight*CHU_CARD_SCALE/2)
            pokerCard:setScale(CHU_CARD_SCALE)
            pokerCard:setPositionX((i-1)*55*CHU_CARD_SCALE)
            self.showcardnode:addChild(pokerCard)
            table.insert(cards,pokerCard)
        end

        -- if self.gamescene:getDealerIndex() == self:getTableIndex() then
        --     if #cards > 0 then
        --         cards[#cards]:setDizhutip()
        --     end
        -- end
        if isan then
            local showpos = cc.p((self.cardwidth*totall-(totall-1)*55)/2*CHU_CARD_SCALE,self.cardheight*CHU_CARD_SCALE/2)
            showpos = self.showcardnode:convertToWorldSpace(showpos)
            self:playCardtypeAn(data,showpos)
            self.gamescene:deleteAction("完成打牌")
        else
            print("重连显示")
        end
    end

    return TableLeft
end

return TableFactory