local GameTable = class("GameTable", require("app.ui.game.GameTable"))
local LongCard = require "app.ui.game.base.LongCard"
-- 拿牌动画,拿到之后，不展开
function GameTable:fanPaiAction(data, hidenAnimation)
    if hidenAnimation then
        return
    end

    local value = data.dest_card
    local func = data.func
    local function runAnimation(m_pCardFront, m_pCardBack, call)

        m_pCardBack:setScale(0.5)
        local act3 = cc.ScaleTo:create(0.2, 1.2)
        local act4 = cc.ScaleTo:create(0.05, 1.0)

        -- 动画序列（延时，显示，延时，隐藏）
        local pBackSeq = cc.Sequence:create(cc.Show:create(), cc.DelayTime:create(0.2), cc.Hide:create())
        -- 持续时间、半径初始值、半径增量、仰角初始值、仰角增量、离x轴的偏移角、离x轴的偏移角的增量
        local pBackCamera = cc.OrbitCamera:create(0.4, 1, 0, 0, -170, 0, 0)
        local pSpawnBack = cc.EaseSineInOut:create(cc.Spawn:create(pBackSeq, pBackCamera))
        m_pCardBack:runAction(cc.Sequence:create(act3, act4, pSpawnBack))

        -- 动画序列（延时，隐藏，延时，显示）
        local pFrontSeq = cc.Sequence:create(cc.DelayTime:create(0.25), cc.Hide:create(), cc.DelayTime:create(0.2), cc.Show:create())
        local pLandCamera = cc.OrbitCamera:create(0.4, 1, 0, -190, -170, 0, 0)
        local pSpawnFront = cc.EaseSineInOut:create(cc.Spawn:create(pFrontSeq, pLandCamera))

        local rotateTo = cc.RotateTo:create(0.3, 0)

        local endpos = cc.p(0,0)
        if self.tableidx == self.gamescene:getMyIndex() then
            endpos = cc.p(0,self:getPosByShowRow().x)
        end

        local act5 = cc.Spawn:create(cc.MoveTo:create(0.3, endpos), rotateTo)

        m_pCardFront:runAction(cc.Sequence:create(pSpawnFront, act5, cc.DelayTime:create(0.25),cc.CallFunc:create( function()
            if call then
                call()
            end
        end )))
    end

    local worldpos = self.gamescene:getFanPanWorldPos()
    local spacepos = self.effectnode:convertToNodeSpace(worldpos)


    -- 要求，自己翻的，是要加黄色背景框
    local cardNode = cc.Node:create()
    self.effectnode:addChild(cardNode)

    if self.tableidx == self.gamescene:getMyIndex() then
        local card = LongCard.new(CARDTYPE.ACTIONSHOW, value)
        cardNode:addChild(card)
        card:setName("card")
       
        if self.gamescene:getIsJiangCard(value) then
            card:showJiang()
        end
    else
       local card = LongCard.new(CARDTYPE.ACTIONSHOW, 0)
        cardNode:addChild(card)
        card:setName("card")
    end

    local path =  "game/mopaikuang.png"
    local cardKuang = ccui.ImageView:create(path)
    cardNode:addChild(cardKuang, -1)

    cardNode:setVisible(false)
    cardNode:setRotation(90)
    cardNode:setPosition(spacepos)
    cardNode:setName("chupai")

    cardNode.beganpos = cc.p(0,0)
    if self.tableidx == self.gamescene:getMyIndex() then
        cardNode.beganpos = cc.p(0,self:getPosByShowRow().x)
    end
    cardNode.isCanTouched = true
    self:addTileEvent_1(cardNode)
    self:addMoveCardTips(cardNode)

    local card_bei = LongCard.new(CARDTYPE.ACTIONSHOW, 0)
    card_bei:setRotation(90)
    card_bei:setPosition(spacepos)
    self.effectnode:addChild(card_bei)

    runAnimation(cardNode, card_bei, function()
        if func then
            func()
        end
        if cardNode:getChildByName("tips") then
            cardNode:getChildByName("tips"):setVisible(true)
        end

        if self.tableidx == self.gamescene:getMyIndex() then
            self:playPaiVoice(value)
        end

        self.gamescene:deleteAction("fanPaiAction")
    end )
end

-- 把之前拿的牌展开 从牌堆位到展示位
function GameTable:showPaiAction(data, hidenAnimation)
    if hidenAnimation then
        return
    end

    if self.tableidx == self.gamescene:getMyIndex() then
        self.gamescene:deleteAction("showPaiAction")
        return
    end

    local _card = self.effectnode:getChildByName("chupai")
    if _card then
        _card.isCanTouched = false
        _card:setPosition(_card.beganpos)

        _card:setVisible(false)
        _card:removeFromParent()
    else
        return
    end 

 


    local value = data.dest_card
    local func = data.func
    local function runAnimation(m_pCardFront, m_pCardBack, call)
        -- m_pCardBack:setScale(0.5)
        -- 动画序列（延时，显示，延时，隐藏）
        local pBackSeq = cc.Sequence:create(cc.Show:create(), cc.DelayTime:create(0.2), cc.Hide:create())
        -- 持续时间、半径初始值、半径增量、仰角初始值、仰角增量、离x轴的偏移角、离x轴的偏移角的增量
        local pBackCamera = cc.OrbitCamera:create(0.4, 1, 0, 0, -170, 0, 0)
        local pSpawnBack = cc.EaseSineInOut:create(cc.Spawn:create(pBackSeq, pBackCamera))
        m_pCardBack:runAction(pSpawnBack)

        -- 动画序列（延时，隐藏，延时，显示）
        local pFrontSeq = cc.Sequence:create(cc.Hide:create(), cc.DelayTime:create(0.2), cc.Show:create())
        local pLandCamera = cc.OrbitCamera:create(0.4, 1, 0, -190, -170, 0, 0)
        local pSpawnFront = cc.EaseSineInOut:create(cc.Spawn:create(pFrontSeq, pLandCamera))

        m_pCardFront:runAction(cc.Sequence:create(pSpawnFront, cc.CallFunc:create( function()
            if call then
                call()
            end
        end )))
    end

    -- 要求，自己翻的，是要加黄色背景框
    local cardNode = cc.Node:create()
    self.effectnode:addChild(cardNode)

    local card = LongCard.new(CARDTYPE.ACTIONSHOW, value)
    cardNode:addChild(card)
    card:setName("card")
   
    if self.gamescene:getIsJiangCard(value) then
        card:showJiang()
    end

    local path =  "game/mopaikuang.png"
    local cardKuang = ccui.ImageView:create(path)
    cardNode:addChild(cardKuang, -1)
    cardNode:setName("chupai")
    cardNode:setVisible(false)

    cardNode.beganpos = cc.p(0,0)
    if self.tableidx == self.gamescene:getMyIndex() then
        cardNode.beganpos = cc.p(0,self:getPosByShowRow().x)
    end
    cardNode.isCanTouched = true
    self:addTileEvent_1(cardNode)
    self:addMoveCardTips(cardNode)


    local card_bei = cc.Node:create()
    self.effectnode:addChild(card_bei)

    local cardKuang = ccui.ImageView:create(path)
    card_bei:addChild(cardKuang, -1)

    local card_be = LongCard.new(CARDTYPE.ACTIONSHOW, 0)
    card_bei:addChild(card_be)

    local _delay = 0.3
    if  data.need_delay and self.gamescene.name == "GameScene" then
        -- 在回放界面的时候，不需要延时
        _delay = 1.2
    end

    card_bei:runAction(cc.Sequence:create( cc.DelayTime:create(_delay), cc.CallFunc:create( function()
             runAnimation(cardNode, card_bei, function()
                if func then
                    func()
                end
                if self.tableidx == self.gamescene:getMyIndex() then
                else
                    self:playPaiVoice(value)
                end
                self.gamescene:deleteAction("showPaiAction")
            end )

        end )))
   
end

--wai  和 chi  都叫吃
-- 吃牌动画 从展示位到摆牌位
function GameTable:chiPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    
    self:showActionImg("action_chi")
    AudioUtils.playVoice("action_chi", self.gamescene:getSexByIndex(self:getTableIndex()))
    
    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"chiPaiAction")
end

-- 歪牌动画 从展示位到摆牌位
function GameTable:waiPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    self:showActionImg("action_chi")
    AudioUtils.playVoice("action_chi", self.gamescene:getSexByIndex(self:getTableIndex()))

    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"waiPaiAction")
end

-- 蹬牌动画，从展示位到摆牌位
function GameTable:dengPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end

    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)
    self:showActionImg("action_tiao")
    AudioUtils.playVoice("action_tiao", self.gamescene:getSexByIndex(self:getTableIndex()))
    self:nodeActionToShow(node,"dengPaiAction")
end


function GameTable:getShowCardList()
    local showCol = clone(self.gamescene:getShowTileByIdx(self.tableidx))

    -- print("...........BaseTable:getShowCardList()")
    -- printTable(showCol)

    local function settiyong( data )
        local list = {}
        if data.cards then
            for i, v in ipairs(data.cards) do
                if data.card_ti == nil then
                    data.card_ti = {}
                end

                --不是我自己，没有显示，不是庄家
                if  self.tableidx ~= self.gamescene:getMyIndex() and 
                    self.gamescene:getIsDisplayAnpai() == false and
                    self.gamescene:getDealerIndex() ~= self.tableidx and
                    data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_TI then
                    v = 0
                end

                --绍的牌全扣着
                if data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_WEI and 
                    self.tableidx ~= self.gamescene:getMyIndex() then
                    v = 0
                end

                if #data.cards < 4 then
                    table.insert(data.card_ti, 1,{card = v})
                else
                    table.insert(data.card_ti, {card = v})
                end
            end
        end
    end
    for i,v in ipairs(showCol) do
        settiyong( v )
    end
    return showCol
end

--是否显示摆牌的分数，有的暗，或者蹬是需要扣着牌的
function GameTable:isShowShowTileFen(_list,col)
    --
    print("BaseTable:isShowShowTileFen")
    if  col.score == nil then
        return false
    end

    --不是我自己，没有显示，不是庄家，提的4张牌
    if  self.tableidx ~= self.gamescene:getMyIndex() and 
        self.gamescene:getIsDisplayAnpai() == false and
        self.gamescene:getDealerIndex() ~= self.tableidx and
        col.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_TI then
        return false
    end

    --绍的牌全扣着
    if col.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_WEI and 
        self.tableidx ~= self.gamescene:getMyIndex() then
        return false
    end

    return true
end

--生成牌list节点
function GameTable:createCardsNode(data)

    local cardList = clone(data.col_info.cards)
    --不是我自己，没有显示，不是庄家
    if  self.tableidx ~= self.gamescene:getMyIndex() and 
        self.gamescene:getIsDisplayAnpai() == false and
        self.gamescene:getDealerIndex() ~= self.tableidx and
        data.col_info.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_TI then
        for kk, vv in pairs(cardList) do
            cardList[kk] = 0
        end
    end

    --绍的牌全扣着
    if data.col_info.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_WEI and 
        self.tableidx ~= self.gamescene:getMyIndex() then
        for kk, vv in pairs(cardList) do
            cardList[kk] = 0
        end
    end

    -- print("........生成牌list节点")
    -- printTable(data,"xp7")

    local node = cc.Node:create()
    for i, v in ipairs(cardList) do
        local card = LongCard.new(CARDTYPE.ACTIONSHOW, v)
        card:setPositionY((1 - i) * 30)
        node:addChild(card)

        if self.gamescene:getIsJiangCard(v) then
            card:showJiang()
        end
    end

    local _pos = cc.p(0,0)
    if self.tableidx == self.gamescene:getMyIndex() then
        _pos = cc.p(0,self:getPosByShowRow().x)
    end
    node:setPosition(_pos)
    node.token = data.token
    return node
end

function GameTable:playPaiVoice(pai)
    local _str = (math.floor(pai / 16))..(pai % 16)
    if pai == 0x43 or pai == 0x73 or pai == 0x81 or pai == 0x82 or pai == 0x83 then
        AudioUtils.playVoice("pai_bd_".._str, self.gamescene:getSexByIndex(self:getTableIndex()))
        return
    end
    AudioUtils.playVoice("pai_".._str, self.gamescene:getSexByIndex(self:getTableIndex()))
end


function GameTable:biPaiAction(pai,_fun)
    
    local value = pai
    local function runAnimation(m_pCardFront, m_pCardBack, call)
        m_pCardBack:setScale(0.5)
        local act3 = cc.ScaleTo:create(0.2, 1.2)
        local act4 = cc.ScaleTo:create(0.05, 1.0)

        -- 动画序列（延时，显示，延时，隐藏）
        local pBackSeq = cc.Sequence:create(cc.Show:create(), cc.DelayTime:create(0.2), cc.Hide:create())
        -- 持续时间、半径初始值、半径增量、仰角初始值、仰角增量、离x轴的偏移角、离x轴的偏移角的增量
        local pBackCamera = cc.OrbitCamera:create(0.4, 1, 0, 0, -170, 0, 0)
        local pSpawnBack = cc.EaseSineInOut:create(cc.Spawn:create(pBackSeq, pBackCamera))
        m_pCardBack:runAction(cc.Sequence:create(act3, act4, pSpawnBack))

        -- 动画序列（延时，隐藏，延时，显示）
        local pFrontSeq = cc.Sequence:create(cc.DelayTime:create(0.25), cc.Hide:create(), cc.DelayTime:create(0.2), cc.Show:create())
        local pLandCamera = cc.OrbitCamera:create(0.4, 1, 0, -190, -170, 0, 0)
        local pSpawnFront = cc.EaseSineInOut:create(cc.Spawn:create(pFrontSeq, pLandCamera))

        local rotateTo = cc.RotateTo:create(0.3, 0)

        local endpos = cc.p(0,0)
        if self.tableidx == self.gamescene:getMyIndex() then
            endpos = cc.p(0,self:getPosByShowRow().x)
        end

        local act5 = cc.Spawn:create(cc.MoveTo:create(0.3, endpos), rotateTo)

        m_pCardFront:runAction(cc.Sequence:create(pSpawnFront, act5, cc.CallFunc:create( function()
            if call then
                call()
            end
        end )))
    end

    local worldpos = self.gamescene:getFanPanWorldPos()
    local spacepos = self.effectnode:convertToNodeSpace(worldpos)

    -- 要求，自己翻的，是要加黄色背景框
    local cardNode  = cc.Node:create()
    self.effectnode:addChild(cardNode)

    local card = LongCard.new(CARDTYPE.ACTIONSHOW, value)
    cardNode:addChild(card)
    local path =  "game/mopaikuang.png"
    local cardKuang = ccui.ImageView:create(path)
    cardNode:addChild(cardKuang, -1)
    cardKuang:setVisible(false)

    cardNode:setVisible(false)
    cardNode:setRotation(90)
    cardNode:setPosition(spacepos)
    cardNode:setName("chupai")

    local card_bei = LongCard.new(CARDTYPE.ACTIONSHOW, 0)
    card_bei:setRotation(90)
    card_bei:setPosition(spacepos)
    self.effectnode:addChild(card_bei)

    runAnimation(cardNode, card_bei, function()
       
        local worldpos2 = self.effectnode:convertToNodeSpace(self.moPaiPos)
        local act1 = cc.ScaleTo:create(0.15, 1.2)
        local act2 = cc.DelayTime:create(0.15)
        local act3 = cc.ScaleTo:create(0.075, 1)
        local scaleTo = cc.ScaleTo:create(0.225, self.cardScale)
        local act4 = cc.Spawn:create(cc.MoveTo:create(0.225, worldpos2), scaleTo, cc.FadeOut:create(0.225))

        if self.gamescene:getDealerIndex() == self.tableidx then
            local act_3 = cc.ScaleTo:create(0, 3)
            local act_4 = cc.ScaleTo:create(0.2, 1.0)
            cardKuang:setVisible(true)
            cardKuang:runAction(cc.Sequence:create(act_3, act_4))
        end

        cardNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.3),act1, act2, act3, act4, cc.CallFunc:create( function()
             if self.gamescene:getDealerIndex() == self.tableidx then
                    if _fun then
                        _fun()
                    end
                end
                cardNode:setVisible(false)
                cardNode:stopAllActions()
                cardNode:removeFromParent()
            
        end ), cc.DelayTime:create(0.2), cc.CallFunc:create( function()
               
        end )))
    end)
end
local baoCof = 
{
    [1] = {img = "game/bao_sanzhang.png",audio = "bao_sanzhang",isBao = false}, --报三张
    [2] = {img = "game/bao_bigua.png",audio = "bao_bigua",isBao = false},--必挂三条口
    [3] = {img = "game/bao_kehubuzhui.png",audio = "bao_kehubuzhui",isBao = false},--可胡不追
    [4] = {img = "game/bao_baodukou.png",audio = "bao_baodukou",isBao = true},--报独口
    [5] = {img = "game/bao_liuwei.png",audio = "bao_liuwei",isBao = false},--报六位
    [6] = {img = "game/bao_houshao.png",audio = "bao_houshao",isBao = false},--后绍
    [7] = {img = "game/bao_haiyou.png",audio = "bao_haiyou",isBao = false},--还有
    [8] = {img = "game/bao_meile.png",audio = "bao_meile",isBao = false},--没了
    [9] = {img = "game/bao_daojin.png",audio = "bao_daojin",isBao = false},--倒进
    
    [10] = {img = "game/bao_guanxiaotou.png",audio = "bao_guanxiaotou",isBao = false},--关小偷
    [11] = {img = "game/bao_liugetuanyuan.png",audio = "bao_liugetuanyuan",isBao = false},--六个团圆
    [12] = {img = "game/bao_qishouwujiang.png",audio = "bao_qishouwujiang",isBao = false},--起手无将

    [100] = {img = "game/bao_lianglong.png",audio = "bao_lianglong",isBao = false},--亮拢
}
--报
function GameTable:baoPaiAction(data,hidenAnimation)
    if hidenAnimation  then
        for i,v in ipairs(data.bao_info) do
            if  baoCof[v.bao_type].isBao == true  then
                local bao = self.icon:getChildByName("bao"):setVisible(true)
                bao:setTexture("game/icon_bao.png")
            end
        end
        return
    end
    print("........BaseTable:addTipAction name = ",_name)
    local node =  cc.Node:create()
    local bg = ccui.ImageView:create("game/bao_card_back.png")
    bg:setLocalZOrder(-1)
    node:addChild(bg)
    -- bao_info
    local _width = 0
    local list = {data.dest_card}
    if  self.tableidx ~= self.gamescene:getMyIndex() and  data.bao_info and #data.bao_info ~= 0  then
        for i,v in ipairs(data.bao_info) do
            if v.bao_type == 6 then
                list = {}
            end
        end
    end
    for i,v in ipairs(list) do
        local pai = LongCard.new(CARDTYPE.ONTABLE,v)
        pai:getbg():setAnchorPoint(cc.p(0,0.5))
        _width = _width + 5
        pai:setPositionX(_width)
        _width = _width + pai:getbg():getContentSize().width
        pai:setPositionY(29)
        pai:addTo(bg)
    end
    if data.bao_info and #data.bao_info ~= 0 then
        for i,v in ipairs(data.bao_info) do
            local baoType = ccui.ImageView:create(baoCof[v.bao_type].img)
            if baoType then
                baoType:setAnchorPoint(cc.p(0, 0.5))
                baoType:setPosition(cc.p(_width,29))
                _width = _width + baoType:getContentSize().width
                bg:addChild(baoType)
            end
            if v.bao_type == 5 then
                local audioName = "liuwei_"..math.floor(data.dest_card / 16)..data.dest_card % 16
                AudioUtils.playVoice(audioName,self.gamescene:getSexByIndex(self:getTableIndex()))  
            else
                AudioUtils.playVoice(baoCof[v.bao_type].audio,self.gamescene:getSexByIndex(self:getTableIndex()))  
            end
            if  baoCof[v.bao_type].isBao == true  then
                self:setBao(1)
            end
        end
    end  

    _width = _width + 8
    bg:setScale9Enabled(true)
    bg:setCapInsets(cc.rect(15, 15, 17,17))
    bg:setContentSize(cc.size(_width,58))

    local _x,_y = self.icon:getPosition()
    if  self.localpos == 1 then
        bg:setAnchorPoint(cc.p(0,0.5))
        _x = _x - 32
        _y = _y + 138
    elseif  self.localpos == 2 then
        bg:setAnchorPoint(cc.p(1,0.5))
        _x = _x - 40
    elseif  self.localpos == 3 then
        bg:setAnchorPoint(cc.p(1,0.5))
        _x = _x - 40
    elseif self.localpos == 4 then
        bg:setAnchorPoint(cc.p(0,0.5))
        _x = _x + 40
    end

    local worldpos1 = self.node:convertToWorldSpace(cc.p(_x,_y))
    local spacepos = self.effectnode:convertToNodeSpace(worldpos1)
    node:setPosition(spacepos)
    self.effectnode:addChild(node)

    local act1 = cc.ScaleTo:create(0.15,1.2)
    local act2 = cc.DelayTime:create(0.15)
    local act3 = cc.ScaleTo:create(0.075,1)
    node:runAction(cc.Sequence:create(act1,act2,act3,cc.DelayTime:create(2),cc.CallFunc:create(function() 
        node:stopAllActions()
        node:removeFromParent()
    end)))
end

return GameTable