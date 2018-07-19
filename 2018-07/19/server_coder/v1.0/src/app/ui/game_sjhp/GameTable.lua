local GameTable = class("GameTable", require("app.ui.game.GameTable"))
local LongCard = require "app.ui.game.base.LongCard"
function GameTable:kaifanAction(data)

    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end

    self:showActionImg("action_kaifan")
    AudioUtils.playVoice("hp/sjhp/action_kai",self.gamescene:getSexByIndex(self:getTableIndex()))

    local node =  self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"kaifanAction")
end
function GameTable:pengPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    self:showActionImg("action_dui")
    AudioUtils.playVoice("hp/sjhp/action_dui",self.gamescene:getSexByIndex(self:getTableIndex()))

    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"pengPaiAction")
end

function GameTable:zhaPaiAction( data )
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end

    self:showActionImg("action_zha")
   AudioUtils.playVoice("hp/sjhp/action_zha",self.gamescene:getSexByIndex(self:getTableIndex()))

    -- local node =  self:createCardsNode(data)
    -- self.effectnode:addChild(node)

    -- self:nodeActionToShow(node,"tachuanAction")
end
function GameTable:tachuanAction(data)

    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end

    self:showActionImg("action_tachuan")
    AudioUtils.playVoice("hp/sjhp/action_ta",self.gamescene:getSexByIndex(self:getTableIndex()))

    local node =  self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"tachuanAction")
    
end

--招牌动画类似于吃，从展示位到摆牌位
function GameTable:zhaoPaiAction(data,hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end

    self:showActionImg("action_zhao")
    AudioUtils.playVoice("hp/sjhp/action_zhao",self.gamescene:getSexByIndex(self:getTableIndex()))

    local node =  self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"zhaoPaiAction")
end


function GameTable:updataHuXiText()

    local fen_show = 0
    local _list = self.gamescene:getShowTileByIdx(self.tableidx)

    for k,v in pairs(_list) do
        --如果是暗，并且没有蹬或者招的牌
        if self:isShowShowTileFen(_list,v) then
            fen_show = fen_show + v.score
        end
    end

    local all = fen_show
   self.icon:getChildByName("huxitext"):setString("胡数:" .. all)
end


function GameTable:huPaiAction(data)

    local value = data.dest_card
    local card = LongCard.new(CARDTYPE.ACTIONSHOW, value)
    self.effectnode:addChild(card)
    if self.gamescene:getIsJiangCard(value) then
        card:showJiang()
    end
     if self.gamescene:getIsJokerCard(value) then
        card:showJoker()
     end
    local _pos = cc.p(0,0)
    if self.tableidx == self.gamescene:getMyIndex() then
        _pos = cc.p(0,self:getPosByShowRow().x)
    end
    card:setPosition(_pos)

    self:showActionImg("action_hu")
    AudioUtils.playVoice("hp/sjhp/action_hu",self.gamescene:getSexByIndex(self:getTableIndex()))

    local act1 = cc.ScaleTo:create(0.15, 1.2)
    local act2 = cc.DelayTime:create(0.15)
    local act3 = cc.ScaleTo:create(0.075, 1)

    card:runAction(cc.Sequence:create(act1, act2, act3, cc.CallFunc:create( function()
        card:setVisible(false)
    end ), cc.DelayTime:create(0.2), cc.CallFunc:create( function()

        card:stopAllActions()
        card:removeFromParent()
        self.gamescene:deleteAction("huPaiAction")
    end )))
end


-- 出牌动画 出现在展示位
function GameTable:chuPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        return
    end
    local value = data.dest_card
    local func = data.func

    local cardNode = cc.Node:create()
    self.effectnode:addChild(cardNode)

    local card = LongCard.new(CARDTYPE.ACTIONSHOW, value)
    cardNode:addChild(card)
    card:setName("card")
    local path =  "game/2d_dapaikuang.png"
    local diKuang = ccui.ImageView:create(path)
    cardNode:addChild(diKuang)

    local _size = diKuang:getContentSize()
    local tips = ccui.ImageView:create("game/icon_da.png")
    local __size = tips:getContentSize()
    tips:setPosition(cc.p((90 - __size.width)/2.0-2,(310 - __size.height)/2.0-2))
    cardNode:addChild(tips)

    cardNode:setName("chupai")
    cardNode.isCanTouched = true
    cardNode.beganpos = cc.p(0,0)
    self:addTileEvent_1(cardNode)
    self:addMoveCardTips(cardNode)

    local _pos = cc.p(0,0)
    cardNode:setPosition(_pos)
    if self.gamescene:getIsJiangCard(value) then
        card:showJiang()
    end
     if self.gamescene:getIsJokerCard(value) then
        card:showJoker()
     end

    local act1 = cc.ScaleTo:create(0.15, 1.2)
    local act2 = cc.DelayTime:create(0.15)
    local act3 = cc.ScaleTo:create(0.075, 1)

    cardNode:runAction(cc.Sequence:create(act1, act2, act3, cc.CallFunc:create( function()

        local voicestr = (math.floor(value%(16*16)/16))..(value%(16*16)%16).."_"..(math.random(1,2))
        AudioUtils.playVoice("hp/sjhp/"..voicestr,self.gamescene:getSexByIndex(self:getTableIndex()))
        if func then
            func()
        end
        if cardNode:getChildByName("tips") then
            cardNode:getChildByName("tips"):setVisible(true)
        end
    end ), cc.DelayTime:create(0.2), cc.CallFunc:create( function()
        self.gamescene:deleteAction("chuPaiAction")
    end )))
end

function GameTable:huPaiAction(data,iszimo)

    local value = data.dest_card
    local card = LongCard.new(CARDTYPE.ACTIONSHOW, value)
    self.effectnode:addChild(card)
    if self.gamescene:getIsJiangCard(value) then
        card:showJiang()
    end
     if self.gamescene:getIsJokerCard(value) then
        card:showJoker()
     end
    local _pos = cc.p(0,0)
    if self.tableidx == self.gamescene:getMyIndex() then
        _pos = cc.p(0,self:getPosByShowRow().x)
    end
    card:setPosition(_pos)
    if iszimo then
        self:showActionImg("action_zimo")
        AudioUtils.playVoice("hp/sjhp/action_zimo",self.gamescene:getSexByIndex(self:getTableIndex()))
    else
        self:showActionImg("action_hu")
        AudioUtils.playVoice("hp/sjhp/action_hu",self.gamescene:getSexByIndex(self:getTableIndex()))
    end

    local act1 = cc.ScaleTo:create(0.15, 1.2)
    local act2 = cc.DelayTime:create(0.15)
    local act3 = cc.ScaleTo:create(0.075, 1)

    card:runAction(cc.Sequence:create(act1, act2, act3, cc.CallFunc:create( function()
        card:setVisible(false)
    end ), cc.DelayTime:create(0.2), cc.CallFunc:create( function()

        card:stopAllActions()
        card:removeFromParent()
        self.gamescene:deleteAction("huPaiAction")
    end )))
end




return GameTable