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


function GameTable:updataHuXiText()

    local fen_hand = self:getHandCandsFen()
    local fen_show = 0
    local _list = self.gamescene:getShowTileByIdx(self.tableidx)

    for k,v in pairs(_list) do
        --如果是暗，并且没有蹬或者招的牌
        if self:isShowShowTileFen(_list,v) then
            fen_show = fen_show + v.score
            if v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_PENG or
                v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_ZHAO then

                local card = v.cards[1]
                --上11，丘21，化31，七41，可81 是金牌，其他是素牌
                if card ~= 0x11 and card ~= 0x21 and card ~= 0x31 and card ~= 0x41 and card ~= 0x81 then
                    fen_show  = fen_show + 0.5
                end    
            end
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
     -- self.gamescene:getLongCard(self.tableidx)
    if self.tableidx == self.gamescene:getMyIndex() or self.gamescene.name == "RecordScene"  then
        local list = ComHelpFuc.sortMyHandTile(clone(self.gamescene:getHandTileByIdx(self.tableidx)))

        --算分规则
        --1,基础分，当牌的个数为3个的时候，为黑牌的时候基础分为1分
        --2,个数加一，则分数基础分＋4，
        --3,为红牌的时候，基础分＊2
        --4,为将牌时，基础分＊4
        --5,但是，当个数为6的时候，如果没有亮拢，则就只算是两个3张，分数＊0.5
        
        -- printTable(list,"xp65")

        for k,v in pairs(list) do
            local oldValue = 0

            local isHave = {false,false,false}
            for kk,vv in pairs(v.valueList) do
                isHave[vv.two_value] = true
            end

            if isHave[1] == true  and isHave[2] == true and isHave[3] == true then
                print(".........可以成句")
                local isThreeCards =  0
                local isFourCards =  0
                local minNum = 10
                for kk,vv in pairs(v.valueList) do
                    if  vv.num == 3 then
                        isThreeCards = vv.real_value
                    end
                    if  vv.num == 4 then
                        isFourCards = vv.real_value
                    end
                    if minNum > vv.num  then
                        minNum = vv.num
                    end
                end
                print(".........isThreeCards ＝ ",isThreeCards)
                print(".........isFourCards ＝ ",isFourCards)
                print(".........minNum ＝ ",minNum)
                print(".........v.one_value ＝ ",v.one_value)

                if  isFourCards == 0 and isThreeCards == 0 then
                    --有几句，句中可有金,有金的句，一句一金
                    if v.one_value == 1 or v.one_value == 2 or v.one_value == 3 or  v.one_value == 4 or  v.one_value == 8 then
                        fen_hand = fen_hand + minNum * 1
                    end 
                else
                    if isFourCards ~= 0 then
                        if isFourCards ~= 0x11 and isFourCards ~= 0x21 and isFourCards ~= 0x31 and isFourCards ~= 0x41 and isFourCards ~= 0x81 then
                            fen_hand = fen_hand + 1.5
                        else
                            fen_hand = fen_hand + 4
                        end
                    else
                        if isThreeCards ~= 0x11 and isThreeCards ~= 0x21 and isThreeCards ~= 0x31 and isThreeCards ~= 0x41 and isThreeCards ~= 0x81 then
                            fen_hand = fen_hand + 1
                        else
                            fen_hand = fen_hand + 3
                        end
                    end
                end
            else
                --只能成坎不能成句
                for kk,vv in pairs(v.valueList) do
                    if  oldValue ~= vv.real_value  then
                        if  vv.num == 3 then
                            if vv.real_value ~= 0x11 and vv.real_value ~= 0x21 and vv.real_value ~= 0x31 and vv.real_value ~= 0x41 and vv.real_value ~= 0x81 then
                                fen_hand = fen_hand + 1
                            else
                                fen_hand = fen_hand + 3
                            end    
                        end
                         if  vv.num == 4 then
                            if vv.real_value ~= 0x11 and vv.real_value ~= 0x21 and vv.real_value ~= 0x31 and vv.real_value ~= 0x41 and vv.real_value ~= 0x81 then
                                fen_hand = fen_hand + 1.5
                            else
                                fen_hand = fen_hand + 4
                            end    
                        end
                    end
                    oldValue = vv.real_value
                end  
            end
        end
    end
    return fen_hand
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

--设置出分动画  
function GameTable:setChuFen(fen,hidenAnimation)

    if  hidenAnimation  then
        local chufen = self.icon:getChildByName("chu"):setVisible(true)
        chufen:setTexture("game/icon_chu.png")
        chufen:getChildByName("piaoscore"):setVisible(true)
        chufen:getChildByName("redpoint"):setVisible(true)
        if fen < 10 then
            chufen:getChildByName("piaoscore"):setPositionX(27.50)
        else
            chufen:getChildByName("piaoscore"):setPositionX(21.50)
        end

        chufen:getChildByName("piaoscore"):setString(fen)
        return
    end

    if self.icon:getChildByName("chunode") == nil then
        local chunode = cc.CSLoader:createNode("animation/piao/piao.csb")
        self.icon:addChild(chunode)
        chunode:setName("chunode")
        chunode:setVisible(false)
        chunode:getChildByName("dingpiaozhong"):setVisible(false)

        local bao = chunode:getChildByName("piao")
        bao:getChildByName("Node_2_0"):getChildByName("Image_1"):loadTexture("game/icon_chu.png",ccui.TextureResType.localType)
        bao:getChildByName("Node_2"):getChildByName("Image_1"):loadTexture("game/icon_chu.png",ccui.TextureResType.localType)
    end

    local chunode = self.icon:getChildByName("chunode"):setVisible(true)

    local chufen = self.icon:getChildByName("chu")
    local piaoIcon = self.icon:getChildByName("piao")
    if piaoIcon:isVisible() then
        chufen:setPosition(cc.p(piaoIcon:getPositionX(),piaoIcon:getPositionY() - 50))
        chunode:setPosition(cc.p(piaoIcon:getPositionX(),piaoIcon:getPositionY() - 50))
    else
        chufen:setPosition(cc.p(piaoIcon:getPosition()))
        chunode:setPosition(cc.p(piaoIcon:getPosition()))
    end

    chunode:getChildByName("piao"):setVisible(true)
    AudioUtils.playVoice("action_chufen",self.gamescene:getSexByIndex(self:getTableIndex()))

    self.icon:getChildByName("chunode"):stopAllActions()
    if type ~= 0 then
        local action = cc.CSLoader:createTimeline("animation/piao/piao.csb")
        local function onFrameEvent(frame)
            if nil == frame then
                return
            end
            local str = frame:getEvent()
            if str == "end" then
                if type ~= -1 then

                    self.gamescene:deleteAction("比分动画结束！")

                    chunode:removeFromParent()
                    local chufen = self.icon:getChildByName("chu"):setVisible(true)
                    chufen:setTexture("game/icon_chu.png")
                    chufen:getChildByName("piaoscore"):setVisible(true)
                    chufen:getChildByName("redpoint"):setVisible(true)
                    if fen < 10 then
                        chufen:getChildByName("piaoscore"):setPositionX(27.50)
                    else
                        chufen:getChildByName("piaoscore"):setPositionX(21.50)
                    end

                    chufen:getChildByName("piaoscore"):setString(fen)
                end
            end
        end
        action:setFrameEventCallFunc(onFrameEvent)
        self.icon:getChildByName("chunode"):runAction(action)
        action:gotoFrameAndPlay(0, false)
    end
end


-- 刷新座位信息
function GameTable:refreshSeat(info, isStart)

    if not info then
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
        name:setString(info.user.nick)

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

                if info.piao_score < 10 then
                    piao:getChildByName("piaoscore"):setPositionX(27.50)
                else
                    piao:getChildByName("piaoscore"):setPositionX(21.50)
                end

                piao:getChildByName("piaoscore"):setString(info.piao_score)
            end
        end

        if info.chu_score and info.chu_score > 0 then
            local chufen = self.icon:getChildByName("chu"):setVisible(true)
            if piao:isVisible() then
                chufen:setPosition(cc.p(piao:getPositionX(),piao:getPositionY() - 50))
            else
                chufen:setPosition(cc.p(piao:getPosition()))
            end
            chufen:setTexture("game/icon_chu.png")
            chufen:getChildByName("piaoscore"):setVisible(true)
            chufen:getChildByName("redpoint"):setVisible(true)
            if info.chu_score < 10 then
                chufen:getChildByName("piaoscore"):setPositionX(27.50)
            else
                chufen:getChildByName("piaoscore"):setPositionX(21.50)
            end
            chufen:getChildByName("piaoscore"):setString(info.chu_score)
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

    if self.tableidx ~= self.gamescene:getMyIndex() then
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
function GameTable:playPaiVoice(pai)
    local _str = (math.floor(pai / 16))..(pai % 16)
    if pai == 0x43 or pai == 0x73 then
        AudioUtils.playVoice("pai_xcch_".._str, self.gamescene:getSexByIndex(self:getTableIndex()))
        return
    end
    AudioUtils.playVoice("pai_".._str, self.gamescene:getSexByIndex(self:getTableIndex()))
end
return GameTable