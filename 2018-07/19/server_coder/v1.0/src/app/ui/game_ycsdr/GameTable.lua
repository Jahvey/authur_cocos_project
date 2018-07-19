local GameTable = class("GameTable", require("app.ui.game.GameTable"))
local LongCard = require "app.ui.game.base.LongCard"
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
        if self.localpos == 1 then
            cardNode.beganpos = cc.p(0,self:getPosByShowRow().x)
        end
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
    AudioUtils.playVoice("action_jiao", self.gamescene:getSexByIndex(self:getTableIndex()))
    
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
    AudioUtils.playVoice("action_jiao", self.gamescene:getSexByIndex(self:getTableIndex()))

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
        if self.localpos == 1 then
            _pos = cc.p(0,self:getPosByShowRow().x)
        end
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
function GameTable:dingPaiAction(pai,_fun)
    AudioUtils.playVoice("action_dingzhang", self.gamescene:getSexByIndex(self:getTableIndex()))
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
        local dingnode = self.icon:getChildByName("dingzhang")
        local worldpos = self.icon:convertToWorldSpace(cc.p(dingnode:getPositionX(),dingnode:getPositionY()))
        local worldpos2 = self.effectnode:convertToNodeSpace(worldpos)
        local act1 = cc.ScaleTo:create(0.15, 1.2)
        local act2 = cc.DelayTime:create(0.15)
        local act3 = cc.ScaleTo:create(0.075, 1)
        local scaleTo = cc.ScaleTo:create(0.225, self.cardScale)
        local act4 = cc.Spawn:create(cc.MoveTo:create(0.225, worldpos2), scaleTo, cc.FadeOut:create(0.225))

        -- if self.gamescene:getDealerIndex() == self.tableidx then
        --     local act_3 = cc.ScaleTo:create(0, 3)
        --     local act_4 = cc.ScaleTo:create(0.2, 1.0)
        --     cardKuang:setVisible(true)
        --     cardKuang:runAction(cc.Sequence:create(act_3, act_4))
        -- end

        cardNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.3),act1, act2, act3, act4, cc.CallFunc:create( function()
             self:setdingzhang()
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
function GameTable:getPosByShowRow( )
    -- body
    return cc.p(0,0)
end
function GameTable:biPaiAction(pai,_fun,iszhuang)
    
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
        print("localpos:"..self.localpos)
        print(self.tableidx,self.gamescene:getMyIndex())
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
        local info = self.gamescene:getSeatInfoByIdx(self:getTableIndex())
        if iszhuang then
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
    [14] = {img = "game/tip_chonghu.png",audio = "bao_qishouwujiang",isBao = true},--聪胡
    [100] = {img = "game/bao_lianglong.png",audio = "bao_lianglong",isBao = false},--亮拢
}
--报
function GameTable:baoPaiAction(data)
    self:setBao()
end

--设置报，头像右下的报
function GameTable:setBao()
    
    local info  = self.gamescene:getSeatInfoByIdx(self:getTableIndex())
    info.has_bao_cong_hu = true
    local baonode = cc.CSLoader:createNode("animation/piao/piao.csb")
    self.icon:addChild(baonode)
    baonode:setName("baonode")
    baonode:getChildByName("dingpiaozhong"):setVisible(false)

    local bao = baonode:getChildByName("piao")
    bao:getChildByName("Node_2_0"):getChildByName("Image_1"):loadTexture("game/tip_chonghu.png",ccui.TextureResType.localType)
    bao:getChildByName("Node_2"):getChildByName("Image_1"):loadTexture("game/tip_chonghu.png",ccui.TextureResType.localType)

    baonode:setPosition(cc.p(self.icon:getChildByName("bao"):getPosition()))

    local baonode = self.icon:getChildByName("baonode"):setVisible(true)
    baonode:stopAllActions()

    local action = cc.CSLoader:createTimeline("animation/piao/piao.csb")
    local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "end" then
            self.icon:getChildByName("bao"):setVisible(true)
            baonode:removeFromParent()
        end
    end
    action:setFrameEventCallFunc(onFrameEvent)

    baonode:runAction(action)
    action:gotoFrameAndPlay(0, false)

    AudioUtils.playVoice("action_chonghu",self.gamescene:getSexByIndex(self:getTableIndex()))
    
end



--设置票 状态   -1 等待 1-5 飘 0不飘
function GameTable:setPiao(type)
    print("trypoe:"..type)
    self.icon:getChildByName("ok"):setVisible(false)

    if self.icon:getChildByName("piaonode") == nil then
        local piaonode = cc.CSLoader:createNode("animation/piao/piao.csb")
        self.icon:addChild(piaonode)
        piaonode:setName("piaonode")
        piaonode:setVisible(false)
        piaonode:getChildByName("dingpiaozhong"):setVisible(false)
    end

    local piaonode = self.icon:getChildByName("piaonode"):setVisible(true)
    if type == -1 then
        piaonode:getChildByName("dingpiaozhong"):setVisible(true)
        piaonode:getChildByName("piao"):setVisible(false)
    elseif type >=1 and type <= 5 then
        piaonode:setPosition(cc.p(self.icon:getChildByName("piao"):getPosition()))
        piaonode:getChildByName("dingpiaozhong"):setVisible(false)
        piaonode:getChildByName("piao"):setVisible(true)
        AudioUtils.playVoice("action_piao",self.gamescene:getSexByIndex(self:getTableIndex()))
    else
        piaonode:setVisible(false)
        AudioUtils.playVoice("action_nopiao",self.gamescene:getSexByIndex(self:getTableIndex()))
    end

    self.icon:getChildByName("piaonode"):stopAllActions()
    if type ~= 0 then
        local action = cc.CSLoader:createTimeline("animation/piao/piao.csb")
        local function onFrameEvent(frame)
            if nil == frame then
                return
            end
            local str = frame:getEvent()
            if str == "end" then
                if type ~= -1 then
                    piaonode:removeFromParent()
                    local piao = self.icon:getChildByName("piao"):setVisible(true)
                    piao:setTexture("cocostudio/ui/game/icon_piao.png")
                    piao:getChildByName("piaoscore"):setVisible(true)
                    piao:getChildByName("redpoint"):setVisible(true)
                    self.icon:getChildByName("piao"):getChildByName("piaoscore"):setString(type)
                end
            end
        end
        action:setFrameEventCallFunc(onFrameEvent)
        self.icon:getChildByName("piaonode"):runAction(action)
        if type == -1 then
            action:gotoFrameAndPlay(0, true)
        else
            action:gotoFrameAndPlay(0, false)
        end
    end
    print("setpiaoend")
end


-- 刷新座位信息
function GameTable:refreshSeat(info, isStart)
    if not info then
        print("self:getTableIndex():"..self:getTableIndex())
        print(self:getTableIndex())
        printTable(self.gamescene:getSeatsInfo(),"xp111")
        info = self.gamescene:getSeatInfoByIdx(self:getTableIndex())
    end

    self.icon:setVisible(true)


    local headbg = self.icon:getChildByName("headbg")
    if info.state == poker_common_pb.EN_SEAT_STATE_NO_PLAYER or info.user == nil or info.user == { } then
        for i, v in ipairs(self.icon:getChildren()) do
            v:setVisible(false)
        end
        headbg:setVisible(true)
       
        local bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type", 3)
        if   GT_INSTANCE:getGameStyle(self.gamescene:getTableConf().ttype) == STYLETYPE.Poker  then
            bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type_poker", 1)
        end
        headbg:loadTexture("game/bg_headbg_" .. bg_type .. ".png", ccui.TextureResType.localType)
        self.icon:getChildByName("head_icon"):setVisible(true)

    else
        for i, v in ipairs(self.icon:getChildren()) do
            if self.addfaceeffectnode ~= v then
                v:setVisible(false)
            end
        end
        headbg:setVisible(true)
        
        local bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type", 3)
        if  GT_INSTANCE:getGameStyle(self.gamescene:getTableConf().ttype) == STYLETYPE.Poker then
            bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type_poker", 1)
        end
        headbg:loadTexture("game/bg_headbg_" .. bg_type .. ".png", ccui.TextureResType.localType)

        local head = self.icon:getChildByName("headicon")

        local name = self.icon:getChildByName("name"):setVisible(false)
        local ready = self.icon:getChildByName("ok"):setVisible(false)
        local zhuang = self.icon:getChildByName("zhuang"):setVisible(false)
        zhuang:setColor(cc.c3b(255, 255, 255))
        local lixiantip = self.icon:getChildByName("lixian"):setVisible(false)
        local fangzhutip = self.icon:getChildByName("fangzhu"):setVisible(false)

        local huxitext = self.icon:getChildByName("huxitext"):setVisible(false)
        local fentext = self.icon:getChildByName("fentext"):setVisible(false)
        local xiazhuatext = self.icon:getChildByName("xiazhuatext"):setVisible(false)
        local piao = self.icon:getChildByName("piao"):setVisible(false)
        piao:getChildByName("piaoscore"):setVisible(false)
        piao:getChildByName("redpoint"):setVisible(false)
        local piaopos = cc.p(piao:getPositionX(),piao:getPositionY())
        local bao = self.icon:getChildByName("bao")
        bao:setTexture("game/tip_chonghu.png")
        self.icon:getChildByName("huazhuang"):setVisible(false)
        
        head:setVisible(true)
        name:setString(ComHelpFuc.getCharacterCountInUTF8String(info.user.nick,9))

        -- local size = headbg:getContentSize()
        local headicon = require("app.ui.common.HeadIcon").new(head, info.user.role_picture_url,66).headicon
        head.headicon = headicon
        head:setPosition(cc.p(0, 2))

        if info.state == poker_common_pb.EN_SEAT_STATE_WAIT_FOR_NEXT_ONE_GAME then
            name:setVisible(true)

        elseif info.state == poker_common_pb.EN_SEAT_STATE_READY_FOR_NEXT_ONE_GAME then
            ready:setVisible(true)
            name:setVisible(true)
        elseif info.state == poker_common_pb.EN_SEAT_STATE_PLAYING then
            if self.gamescene:getDealerIndex() == self:getTableIndex() then
                if isStart then
                    self:showZhuangAction()
                else
                    zhuang:setVisible(true)
                end
            end

            if self.gamescene:getOldDealerIndex() == self:getTableIndex() then
                zhuang:setVisible(true)
                zhuang:setColor(cc.c3b(0x99, 0x96, 0x96))
            end

            fentext:setVisible(true)
            huxitext:setVisible(true)
            if info.total_score == nil then
                info.total_score = 0
            end
            fentext:setString("分数: " .. info.total_score)
            self:updataHuXiText()

            if self.gamescene:getTableConf().ttype == HPGAMETYPE.HFBH then
                xiazhuatext:setVisible(true)
                xiazhuatext:setString(string.format("下抓:%d", info.disable_4_times))
            end

        elseif info.state == poker_common_pb.EN_SEAT_STATE_WIN then
            fentext:setVisible(true)
            huxitext:setVisible(true)
            if info.total_score == nil then
                info.total_score = 0
            end
            fentext:setString("分数: " .. info.total_score)
            self:updataHuXiText()

            if self.gamescene:getTableConf().ttype == HPGAMETYPE.HFBH then
                xiazhuatext:setVisible(true)
                xiazhuatext:setString(string.format("下抓:%d", info.disable_4_times))
            end

        elseif info.state == 99 then
            if self.gamescene:getDealerIndex() == self:getTableIndex() then
                if isStart then
                    self:showZhuangAction()
                else
                    zhuang:setVisible(true)
                end
            end
            if self.gamescene:getOldDealerIndex() == self:getTableIndex() then
                zhuang:setVisible(true)
                zhuang:setColor(cc.c3b(0x99, 0x96, 0x96))
            end
            name:setVisible(true)
            huxitext:setVisible(true)
        else
            print("不存在的玩家状态")
        end

        if info.user.is_offline then
            lixiantip:setVisible(true)
        end

        if self.gamescene:getTableCreaterID() == info.user.uid then
            fangzhutip:setVisible(true)
        end

        if self.gamescene:getSeatInfoByIdx(self.tableidx).state ~= 99 then
            WidgetUtils.addClickEvent(headicon, function()
                self:clickHeadIcon(info.user)
            end )
        end
        if info.index == self.gamescene:getMyIndex() then
            self.gamescene.UILayer:refreshReadyCancel(info)
        end
        
        if info.piao_score and info.piao_score > 0 then
            piao:setVisible(true)
            if info.piao_score and info.piao_score > 0 then
                piao:getChildByName("piaoscore"):setVisible(true)
                piao:getChildByName("redpoint"):setVisible(true)
                piao:getChildByName("piaoscore"):setString(info.piao_score)
            end
        end
        if info.has_bao_cong_hu == true then
            bao:setVisible(true)
        end
        self:setdingzhang()

        -- if info.has_kou_pai then
        --     piao:setVisible(true)
        --     piao:setTexture("game/icon_qi.png")
        -- end

        -- if info.is_after_xiao_hu_continue then
        --     piao:setVisible(true)
        --     piao:setTexture("game/icon_xiao.png")
        -- end

        -- if info.has_qihu == true or info.is_wait_hu == true then
        --     bao:setVisible(true)
        -- end
        -- self:updataiconpos()
    end
end
function GameTable:setdingzhang()
    local info = self.gamescene:getSeatInfoByIdx(self:getTableIndex())
     if info.ding_zhang_card then
        local dingzhuang = self.icon:getChildByName("dingzhang")
        dingzhuang:removeAllChildren()
        local bg = cc.Sprite:create("game/dingbg.png")
        dingzhuang:addChild(bg)
        local card = LongCard.new(CARDTYPE.ONTABLE, info.ding_zhang_card)
        dingzhuang:addChild(card)
        dingzhuang:setVisible(true)
    end
end
--招牌动画类似于吃，从展示位到摆牌位
function GameTable:zhaoPaiAction(data,hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end

    self:showActionImg("action_xu")
    AudioUtils.playVoice("action_chua",self.gamescene:getSexByIndex(self:getTableIndex()))

    local node =  self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"zhaoPaiAction")
end
--招牌动画类似于吃，从展示位到摆牌位
function GameTable:zhaoPaiAction2(data,hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end

    self:showActionImg("action_gong")
    AudioUtils.playVoice("action_gong",self.gamescene:getSexByIndex(self:getTableIndex()))

    local node =  self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"zhaoPaiAction2")
end

-- 吃牌动画 从展示位到摆牌位
function GameTable:chiPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    
    self:showActionImg("btn_jiao")
    AudioUtils.playVoice("action_jiao", self.gamescene:getSexByIndex(self:getTableIndex()))
    
    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"chiPaiAction")
end


function GameTable:updataHuXiText()

    local fen_hand = 0
    if  self.gamescene:getTableConf().ttype == HPGAMETYPE.ESCH or 
        self.gamescene:getTableConf().ttype == HPGAMETYPE.HFBH or
        self.gamescene:getTableConf().ttype == HPGAMETYPE.JSCH then
    else
        fen_hand = self:getHandCandsFen()
    end
    local fen_show = 0
    local _list = self.gamescene:getShowTileByIdx(self.tableidx)

    for k,v in pairs(_list) do
        --如果是暗，并且没有蹬或者招的牌
        if self:isShowShowTileFen(_list,v) then
            fen_show = fen_show + v.score
        end
    end

    local all = fen_hand + fen_show
    self.icon:getChildByName("huxitext"):setString("点数:" .. fen_show)
    if device.platform ~= "ios"  and  device.platform ~= "android" then
        if self.tableidx == self.gamescene:getMyIndex() then 
            self.icon:getChildByName("huxitext"):setString("点数:" .. fen_show)
        end
    end
end




return GameTable