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


-- 吃牌动画 从展示位到摆牌位
function GameTable:chiPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    
    self:showActionImg("action_chi")
    self:playActionVoice("chi")
    
    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"chiPaiAction")
end

--捡牌动画，从上家的展示位到我的手牌位
function GameTable:JianShangShouAction(data,shangNode,hidenAnimation)
    if hidenAnimation then
        self:refreshHandTile()
        return
    end
    local card = shangNode:getChildByName("chupai")
    if card == nil  then
        print(".............出问题了！～！！！上家没有翻出来的牌")
        return
    end

    self:showActionImg("action_jian")
    self:playActionVoice("jian")

    card.isCanTouched = false
    card:setPosition(card.beganpos)
    if card:getChildByName("tips") then
        card:getChildByName("tips"):setVisible(false)
    end
    self:nodeActionToHand(card,"shangShouAction")


    -- card.endFunc = function()
    --     card:setVisible(false)
    --     self:refreshHandTile()
    -- end

    -- local worldpos2 = shangNode:convertToNodeSpace(self.moPaiPos)
    -- local act1 = cc.ScaleTo:create(0.12, 1.2)
    -- local act2 = cc.DelayTime:create(0.12)
    -- local act3 = cc.ScaleTo:create(0.06, 1)
    -- local scaleTo = cc.ScaleTo:create(0.18, self.cardScale)
    -- local act4 = cc.Spawn:create(cc.MoveTo:create(0.18, worldpos2), scaleTo, cc.FadeOut:create(0.18))

    -- local _endFunc = cc.CallFunc:create( function()
    --     card:setVisible(false)
    --     self:refreshHandTile()
    -- end)
    -- local _delay = cc.DelayTime:create(0.16)
    -- local _lastFun = cc.CallFunc:create( function()
    --     card:stopAllActions()
    --     card:removeFromParent()
    --     self.gamescene:deleteAction(_str)
    -- end )
    -- card:runAction(cc.Sequence:create(act1, act2, act3, act4, _endFunc, _delay, _lastFun))
end

--滑牌动画
function GameTable:huaPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    
    self:showActionImg("action_hua")
    self:playActionVoice("hua")

    if data.col_info.an_num == 5 then
        if data.seat_index ~= self.gamescene:getMyIndex() then
            data.col_info.cards ={0,0,0,0}
        end
        local node = self:createCardsNode(data)
        self.effectnode:addChild(node)
        self:nodeActionToHand(node,"huaPaiAction")
    else
        local node = self:createCardsNode(data)
        self.effectnode:addChild(node)
        self:nodeActionToShow(node,"huaPaiAction")
    end
end

--招牌动画类似于吃，从展示位到摆牌位
function GameTable:guanPaiAction(data,hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    self:showActionImg("action_guan")
    self:playActionVoice("guan")
    self.gamescene:deleteAction("guanPaiAction")
    -- if data.seat_index ~= self.gamescene:getMyIndex() then
    --     data.col_info.cards ={0,0,0,0}
    -- end
    -- local node =  self:createCardsNode(data)
    -- self.effectnode:addChild(node)

    -- self:nodeActionToHand(node,"zhaoPaiAction")
end


-- 动画统一 从展示位到摆牌位
function GameTable:nodeActionToShow(node,_str)
    node.endFunc = function()
        node:setVisible(false)
        self:refreshShowTile()
    end
    local showpos = self:getShowPos(node.token)

    
    local worldpos1 = self.showCardNode:convertToWorldSpace(showpos)
    local worldpos2 = self.effectnode:convertToNodeSpace(worldpos1)
    local act1 = cc.ScaleTo:create(0.12, 1.2)
    local act2 = cc.DelayTime:create(0.12)
    local act3 = cc.ScaleTo:create(0.06, 1)
    local rotateTo = cc.RotateTo:create(0.2, self.showCardNode:getRotation())
    local scaleTo = cc.ScaleTo:create(0.18, self.cardScale)
    local act4 = cc.Spawn:create(cc.MoveTo:create(0.18, worldpos2), rotateTo, scaleTo, cc.FadeOut:create(0.18))
    local _endFunc = cc.CallFunc:create( function()
        node.endFunc()
        node.endFunc = nil
    end)
    local _delay = cc.DelayTime:create(0.16)
    local _lastFun = cc.CallFunc:create( function()
        node:stopAllActions()
        node:removeFromParent()
        self.gamescene:deleteAction(_str)
    end )
    -- node:runAction(cc.Sequence:create(act1, act2, act3, act4, _endFunc, _delay,_lastFun))
    node:runAction(cc.Sequence:create(act4, _endFunc,_lastFun))
end

-- 动画统一 从展示位到手牌位
function GameTable:nodeActionToHand(node,_str)
    node.endFunc = function()
        node:setVisible(false)
        self:refreshHandTile()
    end

    local worldpos2 = self.effectnode:convertToNodeSpace(self.moPaiPos)
    local act1 = cc.ScaleTo:create(0.12, 1.2)
    local act2 = cc.DelayTime:create(0.12)
    local act3 = cc.ScaleTo:create(0.06, 1)
    local scaleTo = cc.ScaleTo:create(0.18, self.cardScale)
    local act4 = cc.Spawn:create(cc.MoveTo:create(0.18, worldpos2), scaleTo, cc.FadeOut:create(0.18))

    local _endFunc = cc.CallFunc:create( function()
        node:setVisible(false)
        self:refreshHandTile()
    end)
    local _delay = cc.DelayTime:create(0.16)
    local _lastFun = cc.CallFunc:create( function()
        node:stopAllActions()
        node:removeFromParent()
        self.gamescene:deleteAction(_str)
    end )
    -- node:runAction(cc.Sequence:create(act1, act2, act3, act4, _endFunc, _delay, _lastFun))
    node:runAction(cc.Sequence:create(act4, _endFunc, _lastFun))
end



-- self.gamescene:deleteAction(_str)

function GameTable:getShowCardList()
    local _showCol = clone(self.gamescene:getShowTileByIdx(self.tableidx))
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
                table.insert(data.card_ti, {card = v})
            end
        end
    end
    local showCol = {}
    for k,v in pairs(_showCol) do
        if (v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_HUA and v.an_num == 5) or
            v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_AN_GANG then
        else
            settiyong( v )
            table.insert(showCol,v)
        end
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


function GameTable:updataHuXiText()

    local fen_hand = self:getHandCandsFen()
    local fen_show = 0
    local _list = self.gamescene:getShowTileByIdx(self.tableidx)

    for k,v in pairs(_list) do
        --如果是暗，并且没有蹬或者招的牌
        if self:isShowShowTileFen(_list,v) then
            fen_show = fen_show + v.score
        end
    end

    local all = fen_hand + fen_show
    self.icon:getChildByName("huxitext"):setString("个子:" .. all)
    -- if device.platform ~= "ios"  and  device.platform ~= "android" then
    --     if self.tableidx == self.gamescene:getMyIndex() then 
    --         self.icon:getChildByName("huxitext"):setString("个子:" .. fen_show.."+"..fen_hand)
    --     end
    -- end
end


function GameTable:getHandCandsFen()
    -- 获取手牌的点数
    local fen_hand = 0
    return fen_hand
end
--设置跑 状态   -1 等待 1-5 飘 0不飘
function GameTable:setPiao(type)
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
        piaonode:getChildByName("dingpiaozhong"):getChildByName("dingpiaozhong_1"):setTexture("game/icon_daipao.png")

        piaonode:getChildByName("piao"):setVisible(false)
    elseif type >=1 and type <= 5 then
        piaonode:setPosition(cc.p(self.icon:getChildByName("piao"):getPosition()))
        piaonode:getChildByName("dingpiaozhong"):setVisible(false)
        piaonode:getChildByName("piao"):setVisible(true)

        local bao = piaonode:getChildByName("piao")
        bao:getChildByName("Node_2_0"):getChildByName("Image_1"):loadTexture("game/icon_pao.png" ,ccui.TextureResType.localType)
        bao:getChildByName("Node_2"):getChildByName("Image_1"):loadTexture("game/icon_pao.png" ,ccui.TextureResType.localType)

        self:playActionVoice("pao")
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
                    piao:setTexture("game/icon_pao.png")
                    piao:getChildByName("piaoscore"):setVisible(true)
                    piao:getChildByName("redpoint"):setVisible(true)
                    if type < 10 then
                        piao:getChildByName("piaoscore"):setPositionX(27.50)
                    else
                        piao:getChildByName("piaoscore"):setPositionX(21.50)
                    end
                    piao:getChildByName("piaoscore"):setString(type)
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
end

-- 偷牌动画，从牌堆位到展示位 再到手牌位 --因为摸的牌都要上手，不能给别人看，所以要重载
function GameTable:touPaiAction(data, hidenAnimation)
    if hidenAnimation then
        self:refreshHandTile()
        return
    end

    local value = data.dest_card
    local function runAnimation(m_pCardFront, m_pCardBack, call)

        m_pCardBack:setScale(0.5)
        local act3 = cc.ScaleTo:create(0.12, 1.2)
        local act4 = cc.ScaleTo:create(0.04, 1.0)

        -- 动画序列（延时，显示，延时，隐藏）
        local pBackSeq = cc.Sequence:create(cc.Show:create(), cc.DelayTime:create(0.16), cc.Hide:create())
        -- 持续时间、半径初始值、半径增量、仰角初始值、仰角增量、离x轴的偏移角、离x轴的偏移角的增量
        local pBackCamera = cc.OrbitCamera:create(0.24, 1, 0, 0, -170, 0, 0)
        local pSpawnBack = cc.EaseSineInOut:create(cc.Spawn:create(pBackSeq, pBackCamera))
        m_pCardBack:runAction(cc.Sequence:create(act3, act4, pSpawnBack))

        -- 动画序列（延时，隐藏，延时，显示）
        local pFrontSeq = cc.Sequence:create(cc.DelayTime:create(0.16), cc.Hide:create(), cc.DelayTime:create(0.16), cc.Show:create())
        local pLandCamera = cc.OrbitCamera:create(0.24, 1, 0, -190, -170, 0, 0)
        local pSpawnFront = cc.EaseSineInOut:create(cc.Spawn:create(pFrontSeq, pLandCamera))

        local rotateTo = cc.RotateTo:create(0.18, 0)
        local endpos = cc.p(0,0)
        if self.tableidx == self.gamescene:getMyIndex() then
            endpos = cc.p(0,self:getPosByShowRow().x)
        end
        local act5 = cc.Spawn:create(cc.MoveTo:create(0.18, endpos), rotateTo)

        local midFunc = cc.CallFunc:create( function()
            if  data.iszhua == false then
                -- self:playPaiVoice(value)
            end
        end)

        m_pCardFront:runAction(cc.Sequence:create(pSpawnFront,midFunc, act5, cc.CallFunc:create( function()
            if call then
                call()
            end
        end )))
    end

    local worldpos = self.gamescene:getFanPanWorldPos()
    local spacepos = self.effectnode:convertToNodeSpace(worldpos)
    if  data.iszhua == true then
        self:playActionVoice("zhua")
    end

    if self.gamescene.name == "GameScene" and self.tableidx ~= self.gamescene:getMyIndex() then
        value = 0
    end

    local card = LongCard.new(CARDTYPE.ACTIONSHOW, value)
    card:setVisible(false)
    card:setRotation(90)
    card:setPosition(spacepos)
    self.effectnode:addChild(card)

    local card_bei = LongCard.new(CARDTYPE.ACTIONSHOW, 0)
    card_bei:setRotation(90)
    card_bei:setPosition(spacepos)
    self.effectnode:addChild(card_bei)

    runAnimation(card, card_bei, function()

        local worldpos2 = self.effectnode:convertToNodeSpace(self.moPaiPos)

        local act1 = cc.ScaleTo:create(0.12, 1.2)
        local act2 = cc.DelayTime:create(0.12)
        local act3 = cc.ScaleTo:create(0.06, 1)
        local scaleTo = cc.ScaleTo:create(0.18, self.cardScale)
        local act4 = cc.Spawn:create(cc.MoveTo:create(0.18, worldpos2), scaleTo, cc.FadeOut:create(0.18))

        card.endFunc = function()
            card:setVisible(false)
            self:refreshHandTile()
        end
        card:runAction(cc.Sequence:create(act4, cc.CallFunc:create( function()
        -- card:runAction(cc.Sequence:create(act1, act2, act3, act4, cc.CallFunc:create( function()
            card.endFunc()
            card.endFunc = nil
            card:stopAllActions()
            card:removeFromParent()
            self.gamescene:deleteAction("touPaiAction")
        end )))
    end )
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

    local act1 = cc.ScaleTo:create(0.12, 1.2)
    local act2 = cc.DelayTime:create(0.12)
    local act3 = cc.ScaleTo:create(0.06, 1)

    -- cardNode:runAction(cc.Sequence:create(act1, act2, act3, cc.CallFunc:create( function()
    cardNode:runAction(cc.Sequence:create(cc.CallFunc:create( function()
        self:playPaiVoice(value)
        if func then
            func()
        end
        if cardNode:getChildByName("tips") then
            cardNode:getChildByName("tips"):setVisible(true)
        end
        self.gamescene:deleteAction("chuPaiAction")
    end )))
end

-- 刷新座位信息
function GameTable:refreshSeat(info, isStart)

    if not info then
        info = self.gamescene:getSeatInfoByIdx(self:getTableIndex())
    end

    self.icon:setVisible(true)

    if self.localpos == 3 then
        self.icon:getChildByName("huxitext"):setPosition(cc.p(45,30))
        self.icon:getChildByName("fentext"):setPosition(cc.p(45,0))
        self.icon:getChildByName("xiazhuatext"):setPosition(cc.p(45,-30))
    end

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
            
            xiazhuatext:setVisible(true)
            local need_zhua_times = info.need_zhua_times or 0
            xiazhuatext:setString("抓牌:"..need_zhua_times)

        elseif info.state == poker_common_pb.EN_SEAT_STATE_WIN then
            fentext:setVisible(true)
            huxitext:setVisible(true)
            if info.total_score == nil then
                info.total_score = 0
            end
            fentext:setString("分数: " .. info.total_score)
            self:updataHuXiText()
            xiazhuatext:setVisible(true)
            local need_zhua_times = info.need_zhua_times or 0
            xiazhuatext:setString("抓牌:"..info.need_zhua_times)

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
            xiazhuatext:setVisible(true)
            xiazhuatext:setString("抓牌:0")
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
            piao:setTexture("game/icon_pao.png")
            piao:setVisible(true)
            if info.piao_score and info.piao_score > 0 then
                piao:getChildByName("piaoscore"):setVisible(true)
                piao:getChildByName("redpoint"):setVisible(true)
                piao:getChildByName("piaoscore"):setString(info.piao_score)
            end
        end
    end
end
function GameTable:refreshXiaZhua(info)

    print("..........refreshXiaZhua 更新下抓！")
    printTable(info,"xp8")

    local xiazhuatext = self.icon:getChildByName("xiazhuatext"):setVisible(false)
    local zhua_times = 0 
    if  info.need_zhua_times then
        zhua_times = info.need_zhua_times
    end     
    xiazhuatext:setVisible(true)
    xiazhuatext:setString("抓牌:"..zhua_times)
end

function GameTable:playPaiVoice(pai)

    local _str = (math.floor(pai / 16))..(pai % 16)
    if math.floor(pai / 16) == 8 then
        _str = "7"..(pai % 16)
    end
    local _path = self:getVoicePath()
    _path = _path.."pai_gzp_".._str

    AudioUtils.playVoice(_path, self.gamescene:getSexByIndex(self:getTableIndex()))
end

function GameTable:playActionVoice(action)
    local _path = self:getVoicePath()
    AudioUtils.playVoice(_path.."action_"..action, self.gamescene:getSexByIndex(self:getTableIndex()))
end

function GameTable:sortMyHandTile(list)
    
    -- list = { 0x3d, 0x3d, 0x3f, 0x73, 0x83,
    --     0x6e, 0x6e, 0x6f, 0x6f, 0x6f, 0x6f, 
    --     0x73, 0x75, 0x76, 0x78, 0x83, 0x85,
    --     0x81, 0x83, 0x85, 0x87, 0x87}
    -- list = {29,30, 31,31,45,61,61,110,111,115,118,119,120,120,121,122,122,131,135}
    -- list = {45,119,135}
    -- 0x5f, 0x78, 0x89, 0x6d, 0x6d, 0x6d, 0x6f, 0x71, 0x72,0x75,0x75}

     table.sort(list,function(_a,_b)
        return _a < _b
    end)
    print(".............我自己的手牌 排序,#list = ",#list)
    printTable(list,"xp8")
    --

    local alterList = 
    {   --0x71=113,0x73=115,0x77=119,0x7a=122,0x78=120,0x79=121,
        --0x81=129,0x83=131,0x85=133,0x87=135,0x89=137
        [0x71] =  {value = 0x2e,is = {0x2d,0x2f}, num = 0}, --猫乙己
        [0x73] =  {value = 0x3e,is = {0x3d,0x3f},num = 0},--化三千
        [0x77] =  {value = 0x4d,is = {0x4f},num = 0},--七十土
        [0x79] =  {value = 0x5e,is = {0x5f},num = 0},--八九子

        [0x7a] =  {value = 0x4e,is = {0x4f},num = 0},--七十土
        [0x78] =  {value = 0x5d,is = {0x5f},num = 0},--八九子

        [0x81] =  {value = 0x2e,is = {0x2d,0x2f},must = 0x71,num = 0}, --猫乙己
        [0x83] =  {value = 0x3e,is = {0x3d,0x3f},must = 0x73,num = 0},--化三千
        [0x87] =  {value = 0x4d,is = {0x4f},must = 0x77,num = 0},--七十土
        [0x89] =  {value = 0x5e,is = {0x5f},must = 0x79,num = 0},--八九子

        [0x85] =  {value = 0x75,must = 0x75,num = 0},--75

    }

    local restoreList = 
    {
        [0x2e] = {0x71,0x81}, --猫乙己
        [0x3e] = {0x73,0x83},--化三千
        [0x4d] = {0x77,0x87},
        [0x4e] = {0x7a},
        [0x5d] = {0x78},
        [0x5e] = {0x79,0x89},
        [0x71] = {0x81},--71
        [0x73] = {0x83},--73
        [0x75] = {0x85},--75
        [0x77] = {0x87},--77
        [0x79] = {0x89},--79
    }

    local function getIsHave(_val)
        for k,v in pairs(list) do
            if v == _val  then
                return true
            end
        end
        return false
    end

    local function getIsAlter(_val)
        if alterList[_val] == nil then
            return _val
        end
        local _alter = alterList[_val]
        if _val == 0x85 then
            _alter.num = _alter.num  + 1
            return 0x75
        else
            for k,v in pairs(_alter.is) do
                if getIsHave(v) == true then
                    _alter.num = _alter.num  + 1
                    return _alter.value
                end
            end
            if _alter.must ~= nil then
                _alter.num = _alter.num  + 1
                return _alter.must
            end
        end
        return _val
    end
    
    local cloneList =  {}
    for k,v in pairs(list) do
        table.insert(cloneList,getIsAlter(v))
    end

    print(".............我自己的手牌 排序,#list = ",#cloneList)
    -- printTable(cloneList,"xp8")
    -- printTable(alterList,"xp8")
   

    --结构体整理，统计每张牌的个数，
    local realList = {}
    for i,v in ipairs(cloneList) do
        local ishave = false
        for kk,vv in pairs(realList) do
            if vv.real_value == v then
                vv.num = vv.num + 1
                ishave = true
            end
        end
        if not ishave then
            local _data = {}
            _data.real_value = v
            _data.one_value = math.floor(v/16)
            _data.two_value = v%16
            _data.num = 1
            table.insert(realList,_data)
        end
    end
    -- print("...........我自己的手牌 排序 .......1")
    -- printTable(realList,"xp8")

    
    --分列
    local function splitcolumn(columnData)
        -- print(".............拆分前")
        -- printTable(columnData,"xp8")
        local _one_value = columnData.one_value
        local list = {}
        local _data = {}
        _data.valueList = {}
        _data.one_value = _one_value
        _data.num = 0
        _data.two_value = columnData.two_value
        table.insert(list,_data)
        
        -- 
        table.sort(columnData.valueList,function(_a,_b)
            return _a.two_value < _b.two_value
        end)

        -- print(".............排序后")
        -- printTable(columnData,"xp8")

        for k,v in pairs(columnData.valueList) do
            --找出是否满足合并的列，比如，同为6，2个33和2个42，可以合并，
            local insert = false
            for ii,vv in ipairs(list) do
                if vv.num + v.num <= 6 and not insert  then
                    vv.num = vv.num + v.num
                    table.insert(vv.valueList,v)
                    insert = true
                end
            end
            --如果不满足，就另起一列
            if  not insert then
                local _data = {}
                _data.valueList = {v}
                _data.one_value = _one_value
                _data.num = v.num
                table.insert(list,_data)
            end
        end

        return list
    end

    -- 统计每种牌的个数,
    local function tongJiCnt(tab)   
        local ret = {}
        local add = 30
        for i,v in ipairs(tab) do
            local cnt = v.one_value 
            if not ret[cnt] then
                ret[cnt] = {}
                ret[cnt].valueList = {}
                table.insert(ret[cnt].valueList,v)
                ret[cnt].one_value = v.one_value
                ret[cnt].two_value = v.two_value
                ret[cnt].num = v.num
            else    
                if ret[cnt].one_value == v.one_value then
                    ret[cnt].num = ret[cnt].num + v.num
                    table.insert(ret[cnt].valueList,v)
                else
                    cnt = cnt + v.num
                    ret[cnt] = {}
                    ret[cnt].valueList = {}
                    table.insert(ret[cnt].valueList,v)
                    ret[cnt].one_value = v.one_value
                    ret[cnt].num = v.num    
                end
            end

            if  ret[cnt].num > 6 then
                --整理list
                for ii,vv in ipairs(splitcolumn(ret[cnt])) do
                    table.sort(vv.valueList,function(_a,_b)
                        return _a.two_value < _b.two_value
                    end)
                    if ii == 1 then
                        ret[cnt] = vv
                    else
                        ret[add] = vv
                        add = add +1
                    end
                end
            else
                table.sort(ret[cnt].valueList,function(_a,_b)
                    return _a.two_value < _b.two_value
                end)
            end
        end

        return ret
    end 
    realList = tongJiCnt(realList)

    -- print("...........我自己的手牌 统计列 .......1")
    -- printTable(realList,"xp8")

    --整理，
    local function zhengliCnt(tab)
        local _ret = {}
        for k,v in pairs(tab) do
            table.insert(_ret,v)
        end
        local function sortfunc_(_a,_b)
            return _a.one_value < _b.one_value
        end
        table.sort(_ret,sortfunc_)

        -- 如果单列之后一个的话，删除列，把内容放到最后去
        local column_count = #_ret
        if column_count > 8 then
            column_count = 8
        end

        local _last = {}
        _last.valueList = {}
        _last.one_value = 9
        _last.num = 0

        for i=column_count,1,-1 do
            if _ret[i].num == 1 then
                _last.num = _last.num +1
                table.insert(_last.valueList,_ret[i].valueList[1])
                table.remove(_ret,i)
            end
        end
        local function sortfunc_(_a,_b)
            return _a.one_value < _b.one_value
        end
        table.sort(_last.valueList,sortfunc_)
        if  _last.num > 0 then
            table.insert(_ret,_last)
        end
        return _ret
    end 

    realList = zhengliCnt(realList)
    -- print("..................整合后的结构")
    -- printTable(realList,"xp8")

    --把排列好的队列，展开
    local _num = 0
    local _list = {} --最后的返回
    for k,v in pairs(realList) do
        local columnList = {}
        columnList.valueList = {}
        columnList.one_value = v.one_value
        columnList.num = v.num
        _num = _num + v.num
        for kk,vv in pairs(v.valueList) do
            if restoreList[vv.real_value] == nil then
                for i=1,vv.num do
                    table.insert(columnList.valueList,1,vv)
                end
            else
                for _k,_v in pairs(restoreList[vv.real_value]) do
                    if alterList[_v].num > 0 then
                        local _vv = clone(vv)
                        _vv.num = alterList[_v].num
                        _vv.real_value = _v
                        _vv.one_value = math.floor(_v/16)
                        _vv.two_value = _v%16

                        vv.num =  vv.num - _vv.num

                        for i=1,_vv.num do
                            table.insert(columnList.valueList,1,_vv)
                        end
                    end
                end
                if vv.num > 0 then
                    for i=1,vv.num do
                        table.insert(columnList.valueList,1,vv)
                    end
                end
            end
        end
        table.insert(_list,1,columnList)
    end


    print("...........我自己的手牌 展开 .......数量 = ",_num)
    printTable(_list,"xp8")


    local function sortfunc_(_a,_b)
        return _a.one_value < _b.one_value
    end
    table.sort(_list,sortfunc_)

    return _list
end



return GameTable