local GameTable = class("GameTable", require("app.ui.game.GameTable"))
local LongCard = require "app.ui.game.base.LongCard"


function GameTable:getHandCandsFen()
    -- 获取手牌的点数
    local fen_hand = 0

    print("--获取手牌的点数")
     -- self.gamescene:getLongCard(self.tableidx)
    if self.tableidx == self.gamescene:getMyIndex() or self.gamescene.name == "RecordScene"  then
        local list = ComHelpFuc.sortMyHandTile(clone(self.gamescene:getHandTileByIdx(self.tableidx)))

        --算分规则
        --1,基础分，当牌的个数为3个的时候，为黑牌的时候基础分为1分
        --2,当牌的个数为4个分为6，5个点时候分为12
        --3,为红牌的时候，基础分＊2
        --4,为将牌时，基础分＊2
        for k,v in pairs(list) do
            local oldValue = 0
              for kk,vv in pairs(v.valueList) do
                if  oldValue ~= vv.real_value and vv.num > 2 then
                    local _fen = 3 --规则1
                    if  vv.num == 4 then
                        _fen = 6
                    end
                    if  vv.num == 5 then
                        _fen = 13
                    end
                    
                    _fen = _fen + (vv.num-2)*5  --规则2
                    if vv.two_value == 1 then  --规则3，第二位为1的是红牌
                        _fen = _fen * 2
                    end
                    if self.gamescene:getIsJiangCard(vv.real_value) then --规则4
                        _fen = _fen * 2
                    end
                    fen_hand = fen_hand + _fen
                end
                oldValue = vv.real_value
            end  
        end
    end
    return fen_hand
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


-- 卖牌动画，从展示位到摆牌位
function GameTable:tingPaiAction(data, hidenAnimation)

    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    
    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:showActionImg("action_mai")
    AudioUtils.playVoice("action_mai", self.gamescene:getSexByIndex(self:getTableIndex()))

    self:nodeActionToShow(node,"maiPaiAction")
end

-- 填牌动画，从展示位到摆牌位
function GameTable:tianPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end

    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)
    self:showActionImg("action_tian")
    AudioUtils.playVoice("action_tian", self.gamescene:getSexByIndex(self:getTableIndex()))
    self:nodeActionToShow(node,"dengPaiAction")
end

--招牌动画类似于吃，从展示位到摆牌位
function GameTable:zhaoPaiAction(data,hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end

    self:showActionImg("action_gang")
    AudioUtils.playVoice("action_gang",self.gamescene:getSexByIndex(self:getTableIndex()))

    local node =  self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"zhaoPaiAction")
end


function GameTable:playPaiVoice(pai)
    local _str = (math.floor(pai / 16))..(pai % 16)
    if pai == 0x43 or pai == 0x73 then
        AudioUtils.playVoice("pai_xcch_".._str, self.gamescene:getSexByIndex(self:getTableIndex()))
        return
    end
    AudioUtils.playVoice("pai_".._str, self.gamescene:getSexByIndex(self:getTableIndex()))
end
return GameTable