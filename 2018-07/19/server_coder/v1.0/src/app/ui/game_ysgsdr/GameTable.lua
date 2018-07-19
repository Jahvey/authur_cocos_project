local GameTable = class("GameTable", require("app.ui.game.GameTable"))
local LongCard = require "app.ui.game.base.LongCard"
-- 蹬牌动画，从展示位到摆牌位
function GameTable:dengPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end

    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)
    self:showActionImg("action_ta")
    AudioUtils.playVoice("action_ta", self.gamescene:getSexByIndex(self:getTableIndex()))
    self:nodeActionToShow(node,"dengPaiAction")
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

function GameTable:playPaiVoice(pai)
    local _str = (math.floor(pai / 16))..(pai % 16)
    if pai == 0x43 or pai == 0x73 or pai == 0x81 or pai == 0x82 or pai == 0x83 then
        AudioUtils.playVoice("pai_bd_".._str, self.gamescene:getSexByIndex(self:getTableIndex()))
        return
    end
    AudioUtils.playVoice("pai_".._str, self.gamescene:getSexByIndex(self:getTableIndex()))
end

function GameTable:getShowCardList()
    local showCol = clone(self.gamescene:getShowTileByIdx(self.tableidx))

    print("...........BaseTable:getShowCardList()")
    printTable(showCol)

    local function settiyong( data )
        local list = {}
        if data.cards then
            local out_card_num = data.out_card_num or 1
            out_card_num = out_card_num -1
            local taIndex = #data.cards - out_card_num 

            for i, v in ipairs(data.cards) do
                if data.card_ti == nil then
                    data.card_ti = {}
                end

                --绍的牌全扣着
                if data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_ZHAO and 
                    out_card_num > 0 and
                    i > taIndex  then
                    v = 0
                end
                -- if #data.cards < 4 then
                --     table.insert(data.card_ti, 1,{card = v})
                -- else
                    table.insert(data.card_ti, {card = v})
                -- end
            end
        end
    end
    for i,v in ipairs(showCol) do
        settiyong( v )
    end
    return showCol
end

--生成牌list节点
function GameTable:createCardsNode(data)

    print("生成牌list节点")
    printTable(data)

    local cardList = clone(data.col_info.cards)

    local out_card_num = data.col_info.out_card_num  or 1
    out_card_num = out_card_num -1

    local node = cc.Node:create()
    for i, v in ipairs(cardList) do
         if data.col_info.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_ZHAO and 
            out_card_num > 0  then
            v = 0
        end
        out_card_num = out_card_num - 1

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

function GameTable:getHandCandsFen()
    -- 获取手牌的点数
    local fen_hand = 0

    print("--获取手牌的点数")
     -- self.gamescene:getLongCard(self.tableidx)
    if self.tableidx == self.gamescene:getMyIndex() or self.gamescene.name == "RecordScene"  then
        local list = ComHelpFuc.sortMyHandTile(clone(self.gamescene:getHandTileByIdx(self.tableidx)))

        --算分规则
        --1,基础分，当牌的个数为3个的时候，为黑牌的时候基础分为4分
        --2,个数加一，则分数基础分＋4，
        --3,为红牌的时候，基础分＊2
        --4,为将牌时，基础分＊4
        --5,但是，当个数为6的时候，如果没有亮拢，则就只算是两个3张，分数＊0.5

        for k,v in pairs(list) do
            local oldValue = 0
              for kk,vv in pairs(v.valueList) do
                if  oldValue ~= vv.real_value and vv.num > 2 then
                    local _fen = 4 --规则1
                    _fen = (vv.num-2)*4  --规则2
                    if vv.two_value == 1 then  --规则3，第二位为1的是红牌
                        _fen = _fen * 2
                    end
                    if self.gamescene:getIsJiangCard(vv.real_value) then --规则4
                        _fen = _fen * 4
                    end

                    if vv.num == 6 and vv.real_value ~= self.gamescene:getLongCard(self.tableidx) then --规则5,分数刚好为之前的一半
                        _fen = _fen * 0.5
                    end
                    fen_hand = fen_hand + _fen
                end
                oldValue = vv.real_value
            end  
        end
    end
    return fen_hand
end

return GameTable