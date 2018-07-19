local TableFactory = { }

function TableFactory.create(tableClass, actionClass)
    local TableTop = class("TableTop", tableClass)
    local LongCard = require "app.ui.game_base_cdd.base.LongCard"
    function TableTop:init(...)
    end
    function TableTop:initLocalConf()
        self.localpos = 3
        self.cardAnchor = cc.p(0.5,0)  
        self.effectnode = self.gamescene.layout:getChildByName("effectnode"):getChildByName("top")
    end

    function TableTop:refreshHandTile()

        if self.gamescene.name == "GameScene" then
            return
        end
       
    end
    

    function TableTop:refreshPutoutTile()
    end
    function TableTop:chuPaiAction(data,isan)
        self.showcardnode:removeAllChildren()
        self.showcardnode:setVisible(true)
        self.buchunode:setVisible(false)
        local totall = #data.cards
        data.type = data.cardtype
        local cardslocal = self.gamescene.Suanfuc:getrealcardsTab(data.cards,data)
        for i,v in ipairs(cardslocal) do
            local pokerCard = LongCard.new(v.value)
            if v.islai or pokerCard:getPokerValue() == LocalData_instance:getLaiZiValuer() then
                pokerCard:setisshowLai(true)
            else
                pokerCard:setisshowLai(false)
            end
            pokerCard:setCardAnchorPoint(cc.p(0.5,0))
            pokerCard:setScale(CHU_CARD_SCALE)
            pokerCard:setPositionX((i-(totall + 1) / 2)*55*CHU_CARD_SCALE)
            self.showcardnode:addChild(pokerCard)
        end
        if isan then
            self:playCardtypeAn(data)
            self.gamescene:deleteAction("完成打牌")
        else
            print("重连显示")
        end
    end

    return TableTop
end

return TableFactory