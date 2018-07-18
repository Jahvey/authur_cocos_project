local GameTable = class("GameTable", require("app.ui.game.GameTable"))

function GameTable:initView()
    self.nodenotbegin = self.node:getChildByName("nodenotbegin")
    -- 开始之前的位置，
    self.nodebegin = self.node:getChildByName("nodebegin")
    -- 开始牌局之后的位置

    -- 手牌节点
    self.handCardNode = self.node:getChildByName("handcardnode"):setVisible(false)
    
    -- 出牌节点
    self.outCardNode = self.node:getChildByName("chucardnode"):setVisible(false)
    -- dump(self.outCardNode:getRotation())
    -- 弃牌节点
    self.qiCardNode = self.node:getChildByName("qicardnode"):setVisible(false)
    
    -- 摆牌节点
    self.showCardNode = self.node:getChildByName("showcardnode"):setVisible(false)
    
    -- 头像节点
    self.icon = self.node:getChildByName("icon")

    -- 手牌数节点
    self.handnum = self.node:getChildByName("handnum"):setVisible(false)

    -- 弃牌数节点
    self.qicardnum = self.node:getChildByName("qicardnum"):setVisible(false)

    self.moPaiPos = cc.p(0, 0)


end

function GameTable:resetData()
    self.handcardspr = { }
    -- 二维数组
    self.outcardspr = { }
    self.showcardspr = { }
    self.qicardspr = { }

    self.isRunning = false

    self.nextOutPos = cc.p(self.outCardNode:getPosition())
    self.nextShowPos = cc.p(self.showCardNode:getPosition())
    self.nextDiscardPos = cc.p(20+BASECARDWIDTH, BASECARDHEIGHT/2)

    self.showCardNode:removeAllChildren()
    self.handCardNode:removeAllChildren()
    self.outCardNode:removeAllChildren()
    self.qiCardNode:removeAllChildren()
    self.handnum:setVisible(false)

    if self.effectnode then
        self.effectnode:removeAllChildren()
    end
    self.icon:setPosition(cc.p(self.nodenotbegin:getPositionX(), self.nodenotbegin:getPositionY()))


end

-- 刷新座位信息
function GameTable:refreshSeat(info, isStart)

    if not info then
        info = self.gamescene:getSeatInfoByIdx(self:getTableIndex())
    end

    self.icon:setVisible(true)


    -- local headbg = self.icon:getChildByName("headbg")
    if info.state == poker_common_pb.EN_SEAT_STATE_NO_PLAYER or info.user == nil or info.user == { } then
        for i, v in ipairs(self.icon:getChildren()) do
            v:setVisible(false)
        end
        -- headbg:setVisible(true)
        local bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type", 3)
        -- headbg:loadTexture("game/bg_headbg_" .. bg_type .. ".png", ccui.TextureResType.localType)
        -- self.icon:getChildByName("head_icon"):setVisible(true)

    else
        for i, v in ipairs(self.icon:getChildren()) do
            if self.addfaceeffectnode ~= v then
                v:setVisible(false)
            end
        end
        -- headbg:setVisible(true)

        local bg_type = cc.UserDefault:getInstance():getIntegerForKey("bg_type", 3)
        -- headbg:loadTexture("game/bg_headbg_" .. bg_type .. ".png", ccui.TextureResType.localType)

        local head = self.icon:getChildByName("headicon")

        local name = self.icon:getChildByName("name"):setVisible(false)
        local ready = self.icon:getChildByName("ok"):setVisible(false)
        local zhuang = self.icon:getChildByName("zhuang"):setVisible(false)
        zhuang:setColor(cc.c3b(255, 255, 255))
        local lixiantip = self.icon:getChildByName("lixian"):setVisible(false)
        local fangzhutip = self.icon:getChildByName("fangzhu"):setVisible(false)

        local huxitext = self.icon:getChildByName("huxitext"):setVisible(false)
        local fentext = self.icon:getChildByName("fentext"):setVisible(false)
        local piao = self.icon:getChildByName("piao"):setVisible(false)
        -- piao:getChildByName("piaoscore"):setVisible(false)
        -- piao:getChildByName("redpoint"):setVisible(false)
        local piaopos = cc.p(piao:getPositionX(),piao:getPositionY())
        local bao = self.icon:getChildByName("bao")
        -- self.icon:getChildByName("huazhuang"):setVisible(false)
        
        head:setVisible(true)
        name:setString(info.user.nick)

        -- local size = headbg:getContentSize()
        local headicon = require("app.ui.common.HeadIcon").new(head, info.user.role_picture_url,66).headicon
        head.headicon = headicon
        -- head:setPosition(cc.p(0, 2))

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

        elseif info.state == poker_common_pb.EN_SEAT_STATE_WIN then
            fentext:setVisible(true)
            huxitext:setVisible(true)
            if info.total_score == nil then
                info.total_score = 0
            end
            fentext:setString("分数: " .. info.total_score)
            self:updataHuXiText()

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

        if info.state == poker_common_pb.EN_SEAT_STATE_PLAYING or info.state == 99 then
            if info.piao_score and info.piao_score > 0 then
                piao:setVisible(true)
                if info.piao_score and info.piao_score > 0 then
                    piao:getChildByName("piaoscore"):setString(info.piao_score)
                end
            end

            if info.is_piao == true then
                piao:setVisible(true)
            end

            if info.has_kou_pai then
                piao:setVisible(true)
                piao:setTexture("game/icon_qi.png")
            end

            if info.is_after_xiao_hu_continue then
                piao:setVisible(true)
                piao:setTexture("game/icon_xiao.png")
            end
        end

        if info.has_qihu == true or info.is_wait_hu == true then
            bao:setVisible(true)
        end
        -- self:updataiconpos()
    end
end

function GameTable:getShowCardList()
    local showCol = clone(self.gamescene:getShowTileByIdx(self.tableidx))

    -- for i,v in ipairs(showCol) do
    --     -- if v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_WEI then
    --     --     showCol[i].cards = {v.dest_card,0,0}
    --     -- end
    --     for m=1,v.an_num or 0 do
    --         showCol[i].cards[m] = 0
    --     end
    -- end

    for i=#showCol,1,-1 do
        if showCol[i].cards then
            for m=1,showCol[i].an_num or 0 do
                showCol[i].cards[m] = 0
            end
        else
            table.remove(showCol,i)
        end
    end

    -- print("...........BaseTable:getShowCardList()")
    -- printTable(showCol)

    -- local function settiyong( data )
    --     local list = {}
    --     if data.cards then
    --         for i, v in ipairs(data.cards) do
    --             if data.card_ti == nil then
    --                 data.card_ti = {}
    --             end

    --             --不是我自己，没有显示，不是庄家
    --             if  self.tableidx ~= self.gamescene:getMyIndex() and 
    --                 self.gamescene:getIsDisplayAnpai() == false and
    --                 self.gamescene:getDealerIndex() ~= self.tableidx and
    --                 data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_TI then
    --                 v = 0
    --             end

    --             if #data.cards < 4 then
    --                 table.insert(data.card_ti, 1,{card = v})
    --             else
    --                 table.insert(data.card_ti, {card = v})
    --             end
    --         end
    --         -- if data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_WEI then
    --         --     data.card_ti[3].card = 0
    --         -- elseif data.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_TI then
    --         --     data.card_ti[4].card = 0
    --         -- end
    --     end
    -- end
    -- for i,v in ipairs(showCol) do
    --     settiyong( v )
    -- end

    return showCol
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
    -- print("........生成牌list节点")
    -- printTable(data,"xp7")

    local node = cc.Node:create()
    for i, v in ipairs(cardList) do
        local card = self.gamescene:createCardSprite(CARDTYPE.ACTIONSHOW, v)
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

-- 翻牌动画 从牌堆位到展示位
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

        m_pCardFront:runAction(cc.Sequence:create(pSpawnFront, act5, cc.CallFunc:create( function()
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

    local card = self.gamescene:createCardSprite(CARDTYPE.ACTIONSHOW, value)
    cardNode:addChild(card)
    card:setName("card")
    local path =  "game/mopaikuang_xj.png"
    local cardKuang = ccui.ImageView:create(path)
    cardNode:addChild(cardKuang, -1)

    if self.gamescene:getIsJiangCard(value) then
        card:showJiang()
    end

    cardNode:setVisible(false)
    cardNode:setRotation(90)
    cardNode:setPosition(spacepos)
    cardNode:setName("chupai")

    cardNode.beganpos = cc.p(0,0)
    if self.tableidx == self.gamescene:getMyIndex() then
        cardNode.beganpos = cc.p(0,self:getPosByShowRow().x)
    end
    cardNode.isCanTouched = true
    self:addMoveCardTips(cardNode)
    self:addTileEvent_1(cardNode)

    local card_bei = self.gamescene:createCardSprite(CARDTYPE.ACTIONSHOW, 0)
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
        self:playPaiVoice(value)
        self.gamescene:deleteAction("fanPaiAction")
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

    if self.gamescene:getTableConf().seat_num == 3 and self.gamescene.name == "GameScene" and self:getTableIndex() ~= self.gamescene:getMyIndex() then
        value = 0
    end

    local card = self.gamescene:createCardSprite(CARDTYPE.ACTIONSHOW, value)
    cardNode:addChild(card)
    card:setName("card")
    -- local path =  "game/2d_dapaikuang.png"
    -- local cardKuang = ccui.ImageView:create(path)
    -- cardNode:addChild(cardKuang, -1)

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

    local act1 = cc.ScaleTo:create(0.15, 1.2)
    local act2 = cc.DelayTime:create(0.15)
    local act3 = cc.ScaleTo:create(0.075, 1)

    cardNode:runAction(cc.Sequence:create(act1, act2, act3, cc.CallFunc:create( function()
        self:playPaiVoice(value)
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

-- 胡牌动画 出现在展示位
function GameTable:huPaiAction(data)

    local value = data.dest_card
    local card = self.gamescene:createCardSprite(CARDTYPE.ACTIONSHOW, value)
    self.effectnode:addChild(card)
    if self.gamescene:getIsJiangCard(value) then
        card:showJiang()
    end
    local _pos = cc.p(0,0)
    if self.tableidx == self.gamescene:getMyIndex() then
        _pos = cc.p(0,self:getPosByShowRow().x)
    end
    card:setPosition(_pos)

    self:showActionImg("action_hu")
    AudioUtils.playVoice("action_hu", self.gamescene:getSexByIndex(self:getTableIndex()))

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

--生成牌list节点
function GameTable:createCardsNode(data)
    
    local cardList = clone(data.col_info.cards)

    -- if data.col_info.an_num and data.col_info.an_num > 0 then
    --     for i
    -- end
    for i=1,data.col_info.an_num or 0 do
        cardList[i] = 0
    end
    --不是我自己，没有显示，不是庄家
    if  self.tableidx ~= self.gamescene:getMyIndex() and 
        self.gamescene:getIsDisplayAnpai() == false and
        self.gamescene:getDealerIndex() ~= self.tableidx and
        data.col_info.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_TI then
        for kk, vv in pairs(cardList) do
            cardList[kk] = 0
        end
    end
    -- print("........生成牌list节点")
    -- printTable(data,"xp7")

    local node = cc.Node:create()
    for i, v in ipairs(cardList) do
        local card = self.gamescene:createCardSprite(CARDTYPE.ACTIONSHOW, v)
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
    print("........GameTable:addTipAction name = ",_name)
    local node =  cc.Node:create()
    local bg = ccui.ImageView:create("game/bao_card_back.png")
    bg:setLocalZOrder(-1)
    node:addChild(bg)
    -- bao_info
    local _width = 0
    local list = {data.dest_card}
    for i,v in ipairs(list) do
        local pai = self.gamescene:createCardSprite(CARDTYPE.ONTABLE,v)
        pai:getbg():setAnchorPoint(cc.p(0,0.5))
        _width = _width + 5
        pai:setPositionX(_width)
        _width = _width + pai:getbg():getContentSize().width
        pai:setPositionY(29)
        pai:addTo(bg)

        -- if self.gamescene:getIsJiangCard(v) then
        --     pai:showJiang()
        -- end
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

-- 偷牌动画，从牌堆位到展示位 再到手牌位
function GameTable:touPaiAction(data, hidenAnimation)
    if hidenAnimation then
        self:refreshHandTile()
        return
    end

    local value = data.dest_card
    local function runAnimation(m_pCardFront, m_pCardBack, call)

        m_pCardBack:setScale(0.5)
        local act3 = cc.ScaleTo:create(0.15, 1.2)
        local act4 = cc.ScaleTo:create(0.05, 1.0)

        -- 动画序列（延时，显示，延时，隐藏）
        local pBackSeq = cc.Sequence:create(cc.Show:create(), cc.DelayTime:create(0.2), cc.Hide:create())
        -- 持续时间、半径初始值、半径增量、仰角初始值、仰角增量、离x轴的偏移角、离x轴的偏移角的增量
        local pBackCamera = cc.OrbitCamera:create(0.3, 1, 0, 0, -170, 0, 0)
        local pSpawnBack = cc.EaseSineInOut:create(cc.Spawn:create(pBackSeq, pBackCamera))
        m_pCardBack:runAction(cc.Sequence:create(act3, act4, pSpawnBack))

        -- 动画序列（延时，隐藏，延时，显示）
        local pFrontSeq = cc.Sequence:create(cc.DelayTime:create(0.2), cc.Hide:create(), cc.DelayTime:create(0.2), cc.Show:create())
        local pLandCamera = cc.OrbitCamera:create(0.3, 1, 0, -190, -170, 0, 0)
        local pSpawnFront = cc.EaseSineInOut:create(cc.Spawn:create(pFrontSeq, pLandCamera))

        local rotateTo = cc.RotateTo:create(0.225, 0)
        local endpos = cc.p(0,0)
        if self.tableidx == self.gamescene:getMyIndex() then
            endpos = cc.p(0,self:getPosByShowRow().x)
        end
        local act5 = cc.Spawn:create(cc.MoveTo:create(0.225, endpos), rotateTo)

        m_pCardFront:runAction(cc.Sequence:create(pSpawnFront, act5, cc.CallFunc:create( function()
            if call then
                call()
            end
        end )))

    end

    local worldpos = self.gamescene:getFanPanWorldPos()
    local spacepos = self.effectnode:convertToNodeSpace(worldpos)

    AudioUtils.playVoice("action_tou", self.gamescene:getSexByIndex(self:getTableIndex()))

    local card = self.gamescene:createCardSprite(CARDTYPE.ACTIONSHOW, value)
    card:setVisible(false)
    card:setRotation(90)
    card:setPosition(spacepos)
    self.effectnode:addChild(card)

    local card_bei = self.gamescene:createCardSprite(CARDTYPE.ACTIONSHOW, 0)
    card_bei:setRotation(90)
    card_bei:setPosition(spacepos)
    self.effectnode:addChild(card_bei)

    runAnimation(card, card_bei, function()

        local worldpos2 = self.effectnode:convertToNodeSpace(self.moPaiPos)

        local act1 = cc.ScaleTo:create(0.15, 1.2)
        local act2 = cc.DelayTime:create(0.15)
        local act3 = cc.ScaleTo:create(0.075, 1)
        local scaleTo = cc.ScaleTo:create(0.225, self.cardScale)
        local act4 = cc.Spawn:create(cc.MoveTo:create(0.225, worldpos2), scaleTo, cc.FadeOut:create(0.225))

        card.endFunc = function()
            card:setVisible(false)
            self:refreshHandTile()
        end

        card:runAction(cc.Sequence:create(act1, act2, act3, act4, cc.CallFunc:create( function()
            card.endFunc()
            card.endFunc = nil

        end ), cc.DelayTime:create(0.2), cc.CallFunc:create( function()
            card:stopAllActions()
            card:removeFromParent()
            -- self.effectnode:removeAllChildren()
            self.gamescene:deleteAction("touPaiAction")
        end )))

    end )
end

-- 歪牌动画 从展示位到摆牌位
function GameTable:waiPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    self:showActionImg("action_zhan")
    AudioUtils.playVoice("action_zhan", self.gamescene:getSexByIndex(self:getTableIndex()))

    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"waiPaiAction")
end

-- 跑牌动画 从展示位到摆牌位 --明杠
function GameTable:paoPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end

    if #data.col_info.cards > 4 then
        self:showActionImg("action_zhao")
        AudioUtils.playVoice("action_zhao", self.gamescene:getSexByIndex(self:getTableIndex()))
    else
        self:showActionImg("action_zou")
        AudioUtils.playVoice("action_zou", self.gamescene:getSexByIndex(self:getTableIndex()))
    end

    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"paoPaiAction")
end

-- 提牌动画 从展示位到摆牌位 --暗杠
function GameTable:tiPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end

    if #data.col_info.cards > 4 then
        self:showActionImg("action_zhao")
        AudioUtils.playVoice("action_zhao", self.gamescene:getSexByIndex(self:getTableIndex()))
    else
        self:showActionImg("action_zou")
        AudioUtils.playVoice("action_zou", self.gamescene:getSexByIndex(self:getTableIndex()))
    end

    --第四张要扣
    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"tiPaiAction")
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

-- -- 出牌动画，从展示位到出牌位
-- function GameTable:outCardAction(data, hidenAnimation)

--     if hidenAnimation then
--         self:refreshPutoutTile()
--         if self.gamescene:getTableConf().ttype == HPGAMETYPE.ESSH then
--             self:refreshDiscardTile()
--         end

--         return
--     end

--     local card = self.effectnode:getChildByName("chupai")
--     if card == nil then
--         print(".............出问题了！～！！！没有出牌")
--         return
--     end
--     card.isCanTouched = false
--     card:setPosition(card.beganpos)

--     if card:getChildByName("tips") then
--         card:getChildByName("tips"):setVisible(false)
--     end
--     local isNeedDelay = data.need_delay

--     local worldpos1 = self.qicardnum:convertToWorldSpace(cc.p(0,0))
--     local rotateTo = cc.RotateTo:create(0.2, self.qicardnum:getRotation())
--     -- -- TODO
--     -- local rotateTo = cc.RotateTo:create(0.2, 0)

--     local worldpos2 = self.effectnode:convertToNodeSpace(worldpos1)

    
--     local scaleTo = cc.ScaleTo:create(0.2, self.cardScale)
--     local act4 = cc.Spawn:create(cc.MoveTo:create(0.2, worldpos2), rotateTo, scaleTo, cc.FadeOut:create(0.2))

--     local _delay = 0.3
--     if isNeedDelay and self.gamescene.name == "GameScene" then
--         -- 在回放界面的时候，不需要延时
--         _delay = 1.2
--     end
--     card.endFunc = function()
--         card:setVisible(false)
--         self:refreshPutoutTile()
--         if self.gamescene:getTableConf().ttype == HPGAMETYPE.ESSH then
--             self:refreshDiscardTile()
--         end
--     end
--     card:runAction(cc.Sequence:create(cc.DelayTime:create(_delay), act4, cc.CallFunc:create( function()
--         if card.endFunc then
--             card.endFunc()
--         end
--         card.endFunc = nil

--     end ), cc.DelayTime:create(0.2), cc.CallFunc:create( function()
--         card:stopAllActions()
--         card:removeFromParent()
--         self.gamescene:deleteAction("outCardAction")
--     end )))
-- end

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

    local card = self.gamescene:createCardSprite(CARDTYPE.ACTIONSHOW, value)
    cardNode:addChild(card)
    local path =  "game/mopaikuang_xj.png"
    local cardKuang = ccui.ImageView:create(path)
    cardNode:addChild(cardKuang, -1)
    cardKuang:setVisible(false)

    cardNode:setVisible(false)
    cardNode:setRotation(90)
    cardNode:setPosition(spacepos)
    cardNode:setName("chupai")

    local card_bei = self.gamescene:createCardSprite(CARDTYPE.ACTIONSHOW, 0)
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

--设置票 状态   -1 等待 1-5 飘 0不飘
function GameTable:setPiao(type)
    self.icon:getChildByName("ok"):setVisible(false)

    if self.icon:getChildByName("piaonode") == nil then
        local piaonode = cc.CSLoader:createNode("animation/piao/piao.csb")
        self.icon:addChild(piaonode)
        piaonode:setName("piaonode")
        piaonode:setVisible(false)
        piaonode:getChildByName("dingpiaozhong"):setVisible(false)
        piaonode:setPositionX(55)
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
                   self.icon:getChildByName("piao"):setVisible(true)
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
            fen_show = fen_show + (v.score or 0)
        end
    end

    local all = fen_hand + fen_show
    self.icon:getChildByName("huxitext"):setString("点数:" .. all)
    if device.platform ~= "ios"  and  device.platform ~= "android" then
        if self.tableidx == self.gamescene:getMyIndex() then 
            self.icon:getChildByName("huxitext"):setString("点数:" .. fen_show.."+"..fen_hand)
        end
    end
end

function GameTable:getHandCandsFen()
    -- 获取手牌的点数
    local fen_hand = 0

    print("--获取手牌的点数")
    if self.tableidx == self.gamescene:getMyIndex() or self.gamescene.name == "RecordScene"  then
        local values = {0x17,0x18,0x19,0x1b,0x1c,0x1d,0x27,0x28,0x29,0x2b,0x2c,0x2d,0x3b,0x3c,0x3d,0x4b,0x4c,0x4d}
        local valuemap = {}
        for i,v in ipairs(values) do
            values[v] = true
        end
        local function getIsHunpai(value)
            if valuemap[value] then
                return true
            end
            return false
        end

        local list = clone(self.gamescene:getHandTileByIdx(self.tableidx))

        table.sort(list,function(a,b)
                return a<b
            end)

        local redlist = {}
        local blacklist = {}

        for i,v in ipairs(list) do
            if math.floor(v/16) == 1 or math.floor(v/16) == 2 then
                table.insert(redlist,v)
            else
                table.insert(blacklist,v)
            end
        end

        local function reformData(list)
            local output = {}
            for i,v in ipairs(list) do
                if not output[v%16] then
                    output[v%16] = 1
                else
                    output[v%16] = output[v%16] + 1
                end
            end
            return output
        end 

        local redstatistics = reformData(redlist)
        local blackstatistics = reformData(blacklist)

        local redhunmap = {
            [7] = true,
            [8] = true,
            [9] = true,
            [11] = true,
            [12] = true,
            [13] = true,
        }
        local blackhunmap = {
            [11] = true,
            [12] = true,
            [13] = true,
        }

        local function subKanScore(inputlist,map)
            for k,v in pairs(inputlist) do
                if v >= 3 then
                    if map[k] then
                        fen_hand = fen_hand + 6
                    else
                        fen_hand = fen_hand + 4
                    end
                    inputlist[k] = inputlist[k] - 3
                end
            end
            for k,v in pairs(inputlist) do
                if inputlist[k] == 0 then
                    inputlist[k] = nil
                end
            end
        end
        
        subKanScore(redstatistics,redhunmap)
        subKanScore(blackstatistics,blackhunmap)

        local function subSingleScore(inputlist,map)
            local num = 0
            for k,v in pairs(inputlist) do
                if map[k] then
                    num = num + (inputlist[k] or 0)
                end
            end
            fen_hand = fen_hand + num
        end

        subSingleScore(redstatistics,redhunmap)
        subSingleScore(blackstatistics,blackhunmap)

        -- local colummap = {
        --     [1] = {2,3},
        --     [4] = {5,6},
        --     [7] = {8,9},
        --     [11] = {12,13},
        -- }

        -- local function subYuanScore(inputlist,map)
        --     for k,v in pairs(inputlist) do
        --         if map[k] then
        --             if colummap[k] and inputlist[k] > 0 then
        --                 if inputlist[colummap[k][1]] and inputlist[colummap[k][1]] > 0 and inputlist[colummap[k][2]] and inputlist[colummap[k][2]] > 0 then
        --                     inputlist[k] = inputlist[k] - 1
        --                     inputlist[colummap[k][1]] = inputlist[colummap[k][1]] - 1
        --                     inputlist[colummap[k][2]] = inputlist[colummap[k][2]] - 1
        --                     fen_hand = fen_hand + 3
        --                 end
        --             end
        --         end
        --     end
        --     for k,v in pairs(inputlist) do
        --         if inputlist[k] == 0 then
        --             inputlist[k] = nil
        --         end
        --     end
        -- end

        -- subYuanScore(redstatistics,redhunmap)
        -- subYuanScore(blackstatistics,blackhunmap)

        -- colummap = {{7,8,9},{11,12,13}}
        -- local function sunKouScore(inputlist,map)
        --     for i,v in ipairs(colummap) do
        --         local num = 0
        --         for _,value in ipairs(v) do
        --             if not map[value] then
        --                 break
        --             end
        --             num = num + (inputlist[value] or 0)
        --         end
        --         fen_hand = fen_hand + num - num%2
        --     end
        -- end

        -- sunKouScore(redstatistics,redhunmap)
        -- sunKouScore(blackstatistics,blackhunmap)
    end

    return fen_hand
end

function GameTable:isShowShowTileFen(_list,col)
    --
    -- print("BaseTable:isShowShowTileFen")
    -- if  col.score == nil then
    --     return false
    -- end

    -- --不是我自己，没有显示，不是庄家，提的4张牌
    -- if  self.tableidx ~= self.gamescene:getMyIndex() and 
    --     self.gamescene:getIsDisplayAnpai() == false and
    --     self.gamescene:getDealerIndex() ~= self.tableidx and
    --     col.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_TI then
    --     return false
    -- end

    return true
end

 -- 手牌排序
function GameTable:sortHandTile(list)
    local handlist = {}

    -- table.sort(list,function (a,b)
    --     return (a%16 == b%16 and math.floor(a/16)<math.floor(b/16)) or a%16>b%16
    -- end)

    table.sort(list,function (a,b)
        return a%16<b%16
    end)

    local function getPairValue(value)
        local pairvalue = 0

        local colorvalue = math.floor(value/16)

        if colorvalue == 1 or colorvalue == 2 then
            pairvalue = 10
        else
            pairvalue = 20
        end

        local numvalue = value%16
        if numvalue > 10 then
            pairvalue = pairvalue + 4
        else
            pairvalue = pairvalue + math.ceil((numvalue%16)/3)
        end

        return pairvalue
    end

    local pairvaluetable = {14,24,13,23,12,22,11,21,}
    local index = 0

    for _,v in ipairs(pairvaluetable) do
        if not handlist[index] then
            handlist[index] = {}
        end
        local has_value = false
        for i=#list,1,-1 do
            if getPairValue(list[i]) == v then
                if not has_value then
                    index = index + 1
                    handlist[index] = {}
                    has_value = true
                end

                if #handlist[index] >= 5 then
                    index = index + 1
                    handlist[index] = {}
                end
                table.insert(handlist[index],1,list[i])
                table.remove(list,i)
            end
        end
    end

    -- for i=1,#list do
    --     for m=i+1,#list do
    --         if getPairValue(list[i]) == getPairValue(list[m]) then
    --             if math.floor(list[i]/16)>math.floor(list[m]/16) then
    --                 local temp = list[i]
    --                 list[i] = list[m]
    --                 list[m] = temp
    --             end
    --         else
    --             break
    --         end
    --     end
    -- end

    -- for i=1,#list do
    --     for m=i+1,#list do
    --         if getPairValue(list[i]) == getPairValue(list[m]) then
    --             if math.floor(list[i]/16)>math.floor(list[m]/16) then
    --                 local temp = list[i]
    --                 list[i] = list[m]
    --                 list[m] = temp
    --             end
    --         else
    --             break
    --         end
    --     end
    -- end

    -- table.sort(list,function (a,b)
    --     return (a%16 == b%16 and math.floor(a/16)<math.floor(b/16)) or a%16>b%16
    -- end)

    -- local redlist = {}
    -- local blacklist = {}

    -- for i,v in ipairs(list) do
    --     if math.floor(v/16) == 1 or math.floor(v/16) == 2 then
    --         table.insert(redlist,v)
    --     else
    --         table.insert(blacklist,v)
    --     end
    -- end

    

    -- local index = 0
    -- -- for k=1,2 do
    --     -- if k == 1 then
    --     --     list = redlist
    --     -- else
    --     --     list = blacklist
    --     -- end

    -- printTable(list)
    -- while #list > 0 do 
    --     local value = list[#list]
    --     table.remove(list,#list)
    --     local pairvalue = getPairValue(value)
    --     index = index + 1

    --     if not handlist[index] then
    --         handlist[index] = {}
    --     end

    --     table.insert(handlist[index],value)

    --     for i=#list,1,-1 do
    --         if getPairValue(list[i]) == getPairValue(value) then
    --             if #handlist[index] >=5 then
    --                 index = index + 1
    --                 handlist[index] = {}
    --             end
    --             table.insert(handlist[index],1,list[i])
    --             table.remove(list,i)
    --         end
    --     end
    -- end
    -- end

    return handlist
end

function GameTable:playPaiVoice(pai)
    AudioUtils.playVoice("shortcard_"..pai, self.gamescene:getSexByIndex(self:getTableIndex()))
end

function GameTable:setbgstype(bg_type)

end

return GameTable