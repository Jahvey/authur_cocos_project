local GameTable = class("GameTable", require("app.ui.game_poker.GameTable"))

-- 歪牌动画 从展示位到摆牌位
function GameTable:waiPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    self:showActionImg("action_wai")
    AudioUtils.playVoice("action_wai", self.gamescene:getSexByIndex(self:getTableIndex()))

    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"waiPaiAction")
end

function GameTable:paoPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    self:showActionImg("action_zhua")
    if #data.col_info.cards > 4 then
        AudioUtils.playVoice("action_kaizhao", self.gamescene:getSexByIndex(self:getTableIndex()))
    else
        AudioUtils.playVoice("action_ti", self.gamescene:getSexByIndex(self:getTableIndex()))
    end
    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"paoPaiAction")
end

function GameTable:tiPaiAction(data, hidenAnimation)
    self:refreshHandTile()
    if hidenAnimation then
        self:refreshShowTile()
        return
    end
    self:showActionImg("action_zhua")
    if #data.col_info.cards > 4 then
        AudioUtils.playVoice("action_kaizhao", self.gamescene:getSexByIndex(self:getTableIndex()))
    else
        AudioUtils.playVoice("action_ti", self.gamescene:getSexByIndex(self:getTableIndex()))
    end

    --第四张要扣
    local node = self:createCardsNode(data)
    self.effectnode:addChild(node)

    self:nodeActionToShow(node,"tiPaiAction")
end

function GameTable:getHandCandsFen()
    -- 获取手牌的点数
    local fen_hand = 0

    print("--获取手牌的点数")
    if self.tableidx == self.gamescene:getMyIndex() or self.gamescene.name == "RecordScene"  then
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

        local function getIsFenPai(value)
            -- if math.floor(value/16) == 1 or math.floor(value/16) == 2 then
                if value < 10 then
                    return true
                end
            -- end
            return false
        end

        local function subKanScore(inputlist,isred)
            for k,v in pairs(inputlist) do
                if v >= 3 then
                    if isred and getIsFenPai(k) then
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
        
        subKanScore(redstatistics,true)
        subKanScore(blackstatistics)

        local function subSingleScore(inputlist)
            local num = 0
            for k,v in pairs(inputlist) do
                if getIsFenPai(k) then
                    num = num + (inputlist[k] or 0)
                end
            end
            fen_hand = fen_hand + num
        end

        subSingleScore(redstatistics)
        -- subSingleScore(blackstatistics,blackhunmap)

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
    self.qiCardNode:getChildByName("sprnode"):removeAllChildren()
    self.handnum:setVisible(false)

    if self.effectnode then
        self.effectnode:removeAllChildren()
    end
    self.icon:setPosition(cc.p(self.nodenotbegin:getPositionX(), self.nodenotbegin:getPositionY()))


end

function GameTable:gameStartAction(ischong)
    print(".....................BaseTable..牌局游戏开始～")
    self.icon:setPosition(cc.p(self.nodebegin:getPositionX(), self.nodebegin:getPositionY()))

    if  ischong  then
        self:refreshSeat()
    else
        self:refreshSeat(nil, true)
    end
  
    self:refreshHandTile(true)

    self:refreshPutoutTile()
    self:refreshDiscardTile()

    self:refreshShowTile()
    -- 摆牌

    if self.tableidx == self.gamescene:getMyIndex() then
        self.gamescene.UILayer:gameStartAciton()
    end
    self.qiCardNode:setVisible(true)

end

-- 出牌动画，从展示位到出牌位
function GameTable:outCardAction(data, hidenAnimation)

    if hidenAnimation then
        self:refreshPutoutTile()
        if self.gamescene:getTableConf().ttype == HPGAMETYPE.ESSH or self.gamescene:getTableConf().ttype == HPGAMETYPE.XESDR or self.gamescene:getTableConf().ttype == HPGAMETYPE.XFSH then
            self:refreshDiscardTile()
        end

        return
    end

    local card = self.effectnode:getChildByName("chupai")
    if card == nil then
        print(".............出问题了！～！！！没有出牌")
        return
    end
    card.isCanTouched = false
    card:setPosition(card.beganpos)

    if card:getChildByName("tips") then
        card:getChildByName("tips"):setVisible(false)
    end
    local isNeedDelay = data.need_delay

    local worldpos1 = self.outCardNode:convertToWorldSpace(self.nextPutPos)
    local rotateTo = cc.RotateTo:create(0.2, self.outCardNode:getRotation())
    -- -- TODO
    -- local rotateTo = cc.RotateTo:create(0.2, 0)

    if data.is_napai then 
        worldpos1 = self.outCardNode:convertToWorldSpace(self.nextPutPos)
        rotateTo = cc.RotateTo:create(0.2, self.outCardNode:getRotation())
    else
        worldpos1 = self.qiCardNode:convertToWorldSpace(self.nextDiscardPos)
        rotateTo = cc.RotateTo:create(0.2, self.qiCardNode:getRotation())
    end

    local worldpos2 = self.effectnode:convertToNodeSpace(worldpos1)

    
    local scaleTo = cc.ScaleTo:create(0.2, self.cardScale)
    local act4 = cc.Spawn:create(cc.MoveTo:create(0.2, worldpos2), rotateTo, scaleTo, cc.FadeOut:create(0.2))

    local _delay = 0.3
    if isNeedDelay and self.gamescene.name == "GameScene" then
        -- 在回放界面的时候，不需要延时
        _delay = 1.2
    end
    card.endFunc = function()
        card:setVisible(false)
        self:refreshPutoutTile()
        self:refreshDiscardTile()
    end
    card:runAction(cc.Sequence:create(cc.DelayTime:create(_delay), act4, cc.CallFunc:create( function()
        if card.endFunc then
            card.endFunc()
        end
        card.endFunc = nil

    end ), cc.DelayTime:create(0.2), cc.CallFunc:create( function()
        card:stopAllActions()
        card:removeFromParent()
        self.gamescene:deleteAction("outCardAction")
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

    local pairvaluetable = {11,12,13,14,21,22,23,24,}
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

                -- if #handlist[index] >= 5 then
                --     index = index + 1
                --     handlist[index] = {}
                -- end
                table.insert(handlist[index],1,list[i])
                table.remove(list,i)
            end
        end
    end

    return handlist
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
            if self.tableidx ~= self.gamescene:getMyIndex() and 
                self.gamescene:getIsDisplayAnpai() == false and
                self.gamescene:getDealerIndex() ~= self.tableidx and
                showCol[i].col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_TI then
                for m=1,#showCol[i].cards do
                    showCol[i].cards[m] = 0
                end
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

function GameTable:playPaiVoice(pai)
    local filename = ""
    if math.floor(pai/16) == 1 or math.floor(pai/16) == 2 then
        filename = filename.."red_"
    else
        filename = filename.."black_"
    end
    filename = filename..pai%16
    AudioUtils.playVoice(filename, self.gamescene:getSexByIndex(self:getTableIndex()))
end

return GameTable