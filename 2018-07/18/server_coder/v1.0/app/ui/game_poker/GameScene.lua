local GameScene = class("GameScene", require "app.ui.game.GameScene")

local PokerCard = require "app.ui.game_poker.PokerCard"
function GameScene:createCardSprite(typemj,value,isgray)
	return PokerCard.new(typemj, value, isgray)
end

function GameScene:initView()
    self.name = "GameScene"
    print("=====GameScene:initView")
    self.layout = cc.CSLoader:createNode("ui/gamexj/gameBase.csb")
    self:addChild(self.layout)
    WidgetUtils.setScalepos(self.layout)
     --WidgetUtils.setScalepos(self.layout:getChildByName(""))
    self.UILayer = require("app.ui.game_poker.GameUILayer").new(self)
    :addTo(self.layout:getChildByName("UInode"))
    :setPosition(cc.p(0, 0))


    self:initDataBySelf()

    self:initTable()
    self:refreshScene()
    self:setbgstype()
end

function GameScene:initTable()
    local tableBase = require(self.path .. ".GameTable")
    local gameAction = require(self.path .. ".ActionView")

    local bottomtable = require("app.ui.game_poker.TableBottom").create(tableBase, gameAction).new(self.layout:getChildByName("bottomnode"), self)
    local toptable = require("app.ui.game_poker.TableTop").create(tableBase).new(self.layout:getChildByName("topnode"), self)
    local lefttable = require("app.ui.game_poker.TableLeft").create(tableBase).new(self.layout:getChildByName("leftnode"), self)
    local righttable = require("app.ui.game_poker.TableRight").create(tableBase).new(self.layout:getChildByName("rightnode"), self)

    -- 初始化策略
    local maps = {
        [2] =
        {
            [0] = { bottomtable, toptable },
            [1] = { toptable, bottomtable },
        },
        [3] =
        {
            [0] = { bottomtable, righttable, lefttable },
            [1] = { lefttable, bottomtable, righttable },
            [2] = { righttable, lefttable, bottomtable },
        },
        [4] =
        {
            [0] = { bottomtable, righttable, toptable, lefttable },
            [1] = { lefttable, bottomtable, righttable, toptable },
            [2] = { toptable, lefttable, bottomtable, righttable },
            [3] = { righttable, toptable, lefttable, bottomtable },
        },
    }

    self.tablelist = maps[self:getTableConf().seat_num][self:getMyIndex()]

    for i, v in ipairs(self.tablelist) do
        print("............i = ", i)
        v:showNode()
        v:setTableIndex(i - 1)
    end

    self.mytable = bottomtable

    self:otherInitView()

end

function GameScene:refreshScene()

    self.UILayer:initTopInfo(self:getTableID())

    for i, v in ipairs(self:getSeatsInfo()) do
        if  v.index == self:getMyIndex() then
            self.mytable:setBanedCardsList(v.baned_cards or {}) --设置我不能打的牌
        end
        self.tablelist[v.index + 1]:refreshSeat(v)
    end
    local state = self:getTableState()
    self.isRunning = false
    print("..............self:getTableState() = ",state)
    print("..............self.isRunning  = ",self.isRunning)
    printTable(self.table_info, "xppp")

    if state == poker_common_pb.EN_TABLE_STATE_WAIT_DISSOLVE then
        state = self:getDissolveInfo().dissolve_info.pre_state

        print(".........断线后，有解散房间的请求.........poker_common_pb.EN_TABLE_STATE_WAIT_DISSOLVE ")
        printTable(self:getDissolveInfo())

        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create( function()
            self.dissolveView = LaypopManger_instance:PopBox("DissolveView", self:getSeatsInfo(), self:getDissolveInfo())
        end )))
    end

    if state == poker_common_pb.EN_TABLE_STATE_PLAYING or   --玩牌阶段
        state == poker_common_pb.EN_TABLE_STATE_WAIT_PLAYER_BAOPAI or
        state == poker_common_pb.EN_TABLE_STATE_WAIT_QIANG_ZHUANG or
        state == poker_common_pb.EN_TABLE_STATE_WAIT_AN_PAI then 

        self.display_anpai = self.table_info.display_anpai
        self:setRestTileNum(self.table_info.left_card_num)
        self.UILayer:refreshInfoNode()

        self:setJiangCard(self.table_info.jiang_card)
        self.UILayer:setJiangCard(self.table_info.jiang_card)

        for i,v in ipairs(self:getSeatsInfo()) do
            for m,n in ipairs(self:getPutoutTileByIdx(v.index)) do
                self:addTotalOutTile(v.index, {value = n})
            end

            for m,n in ipairs(self:getDiscardTileByIdx(v.index)) do
                self:addTotalOutTile(v.index, {value = n,is_napai = true})
            end

            if self:getTableConf().seat_num == 4 then
                for m,n in ipairs(self:getDiscardTileByIdx(v.index)) do
                    self:addPutoutTile(v.index, n)
                end
            end
        end

        self:setGameBegin(true)

        if self.table_info.operation_index then 
            local data = { }
            data.operation_index = self.table_info.operation_index
            data.left_card_num = self.table_info.left_card_num
            data.act_type = ACTIONTYPEBYMYSELF.NEXT_OPERATION
            self:addAction(data)
        end

        local ishidden_HB = false
        if self.table_info.operation_index and self.table_info.dest_card and self.table_info.dest_card ~= 0 then
            local data = { }
            data.dest_card = self.table_info.dest_card
            data.seat_index = self.table_info.operation_index
            data.left_card_num = self.table_info.left_card_num
           
            if self.table_info.is_mopai then
                data.act_type = poker_common_pb.EN_SDR_ACTION_NAPAI
            else
                ishidden_HB = true
                data.act_type = poker_common_pb.EN_SDR_ACTION_CHUPAI
            end
            data.ischong = true

            local _data = clone(data)

            self:addAction(data)

        end

        local ischuData = nil
        -- 重连处理
        local actionchoice, action_token = self:getActionChoiceByIdx(self:getMyIndex())
        if actionchoice then
            self.mytable:setIsMyTurn(true)
            print(".......actionchoice = ", self:getMyIndex())
            printTable(actionchoice)

            for k, v in pairs(actionchoice) do
                v.action_token = action_token
                if v.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI or  
                    v.act_type == poker_common_pb.EN_SDR_ACTION_PRE_CHUPAI then
                    ischuData = v
                end

            end

            if ischuData then
                self:addAction( { act_type = ACTIONTYPEBYMYSELF.MYTURN_CHU, data = ischuData })
            else
                -- if self:getTableConf().ttype == HPGAMETYPE.HFBH and ishidden_HB == false then
                --     print("--百胡里面，如果牌是扣着的，就不显示操作按钮")
                -- else 
                    self:addAction( { act_type = ACTIONTYPEBYMYSELF.MYTURN, data = actionchoice })
                -- end
            end
        end

        local latestaction = self:getLastestAction()
        print(".......latestaction = ", self:getMyIndex())
        printTable(latestaction)
        printTable(ischuData)

        if latestaction then
            if latestaction.action.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI and latestaction.action.seat_index ~= self:getMyIndex() then
                self.UILayer:setOpertip(latestaction.action.seat_index)
            elseif latestaction.action.act_type ~= poker_common_pb.EN_SDR_ACTION_CHUPAI then
                
            end
        end
        if not self.isRunning then
            local info = self.actionList[1]
            if info then
                self:doAction(info, "重连")
            end
        end
    end

    if state == poker_common_pb.EN_TABLE_STATE_WAIT_PIAO   then
        self:SelectPiao()
    end
end

-- 给手牌添加一张牌
function GameScene:addHandTile(idx, value)

    if self.name == "GameScene" then
        self:addDebugList("a_H",{value})
    end

    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            if v.hand_cards and type(v.hand_cards) == "table" then
                if self.name == "GameScene" and idx ~= self:getMyIndex() then
                    table.insert(v.hand_cards, 0)
                else
                    table.insert(v.hand_cards, value)
                end
                
                return
            end
            break
        end
    end
end

function GameScene:deleteHandTile(valuelist, seat_index)

    -- if self.name == "GameScene" and seat_index ~= self:getMyIndex() then
    --     return
    -- end

    print("删除手牌,deleteHandTile")
    printTable(valuelist,"xp")


    if self.name == "GameScene" then
        self:addDebugList("d_H",valuelist)
    end

    for i, v in ipairs(self.table_info.sdr_seats) do
        -- printTable(v,"xp")

        if v.index == seat_index then

            -- print("................我的手牌！！！数量 ",#v.hand_cards)
            for ii, vv in ipairs(valuelist) do
                for iii, vvv in ipairs(v.hand_cards) do
                    if self.name == "GameScene" and seat_index ~= self:getMyIndex() then
                        if vvv == 0 then
                            table.remove(v.hand_cards, iii)
                            break
                        elseif vvv == vv then
                            table.remove(v.hand_cards, iii)
                            break
                        end
                    else
                        if vvv == vv then
                            table.remove(v.hand_cards, iii)
                            break
                        end
                    end
                end
            end
            -- print(".....删除后....我的手牌！！！数量 ",#v.hand_cards)
            return
        end
    end
end

function GameScene:NotifyGameStart(data)
    print(".......................牌局游戏开始～")
    printTable(data, "xp")

    self:setNowRound(data.round)
   
    --比牌，
    if  data.round == 1 and self:getTableConf().ttype ~= HPGAMETYPE.XE96  then
        self:setDealerIndex(-1)
        self:setOldDealerIndex(-1)
        
        self:setRestTileNum(96)
        local oldData = clone(data)
        for k,v in pairs(data.sdr_seats) do
            v.hand_cards = {}
        end

        self:setSeatsInfo(data.sdr_seats)
        self:setGameBegin()
        self.isRunning = false
        table.insert(self.actionList, 1,{ act_type = ACTIONTYPEBYMYSELF.BIPAI,data = oldData} ) 
    else
        self:setDealerIndex(data.dealer)
        self:setOldDealerIndex(-1)
        self:setRestTileNum(data.left_card_num)
        self:setNowRound(data.round)

        self:setJiangCard(data.jiang_card)
        self.UILayer:setJiangCard(self.table_info.jiang_card)
        for i, v in ipairs(data.sdr_seats) do
            if  v.index == self:getMyIndex() then
                self.mytable:setBanedCardsList(v.baned_cards or {}) --设置我不能打的牌
            end
        end
        self:setSeatsInfo(data.sdr_seats)
        self:setGameBegin()
    end
end 


function GameScene:biPaiAction(data)

    print(".........biPaiAction")
    printTable(data,"xp")

    local function biPaiEnd()    
        self:setRestTileNum(data.left_card_num)
        self:setNowRound(data.round)

        self:setJiangCard(data.jiang_card)
        self.UILayer:setJiangCard(self.table_info.jiang_card)
        for i, v in ipairs(data.sdr_seats) do
            if  v.index == self:getMyIndex() then
                self.mytable:setBanedCardsList(v.baned_cards or {}) --设置我不能打的牌
            end
        end
        self:setSeatsInfo(data.sdr_seats)
        self:setGameBegin()

        self:deleteAction("比庄动画结束！")
    end

    self:setDealerIndex(data.dealer)
    
    for k,v in ipairs(data.sdr_seats) do
        local value = v.hand_cards[1]
        self.tablelist[v.index + 1]:biPaiAction(value,biPaiEnd)
    end
    

end

--漂相关
function GameScene:SelectPiao(data)
    data = {can_pass = true,
                    min_score = 0, }
    self.UILayer:gameStartAciton()
     if not self:getSeatInfoByIdx(self:getMyIndex()).is_piao then
        if not data then
            local piao_score = self:getSeatInfoByIdx(self:getMyIndex()).piao_score
            if not piao_score then
                piao_score = 0
            end
            data = {can_pass = (piao_score == 0),
                    min_score = piao_score, }
        end
        local selectnode = cc.Node:create()
        selectnode:setPosition(display.cx,display.cy)
        local btn1 = ccui.Button:create("game/btn_piao.png", "game/btn_piao.png", "game/btn_piao.png", ccui.TextureResType.localType)
        
        selectnode:addChild(btn1)
        self:addChild(selectnode)
        btn1:setPositionX(0)
        WidgetUtils.addClickEvent(btn1,function ()
            self:clickPiaoBtn(selectnode,btn1,data.min_score)
        end)

        if data.can_pass then
            local btn2 = ccui.Button:create("game/btn_guo.png", "game/btn_guo.png", "game/btn_guo.png", ccui.TextureResType.localType)
            selectnode:addChild(btn2)
            btn1:setPositionX(-100)
            btn2:setPositionX(100)
            
            WidgetUtils.addClickEvent(btn2,function ()
                self:requestPiao(0)
                selectnode:removeFromParent()
            end)
        end
    end

    for i,v in ipairs(self:getSeatsInfo()) do
        if not v.is_piao then
            self.tablelist[v.index+1]:setPiao(-1)
        else
            self.tablelist[v.index+1]:setPiao(v.piao_score)
        end
    end
end

function GameScene:responseSelectPiao( data )
    -- if data.result == 0 then
    --     data.seat_index = self:getMyIndex()
    --     self:notifyPiao(data)
    -- end
end

function GameScene:notifyPiao( data )
    self:getSeatInfoByIdx(data.seat_index).is_piao = data.is_piao
    self:getSeatInfoByIdx(data.seat_index).piao_score = data.piao_score
    self.tablelist[data.seat_index+1]:setPiao((not data.is_piao and -1) or data.piao_score)
end

-- 生成飘的2级页面
function GameScene:clickPiaoBtn(selectnode,btn,min_score)
    
    if btn.layer and tolua.cast(btn.layer,"cc.Node") then
        btn.layer:removeFromParent()
        btn.layer = nil
        return
    end

    btn.layer = cc.Node:create()
        :addTo(selectnode)

    local bg = ccui.ImageView:create("game/action_bg.png")
        :setScale9Enabled(true)
        :setCapInsets(cc.rect(30, 30, 44, 44))
        :setAnchorPoint(cc.p(0.5, 0))
        bg:setLocalZOrder(-1)
        bg:setContentSize(cc.size(56 + 44 + 92 *(5 - 1), 76 + 76))
        btn.layer:addChild(bg)

    local jiantou = ccui.ImageView:create("game/action_arrow.png")
        jiantou:setAnchorPoint(cc.p(0.5, 1))
        jiantou:setPositionX(bg:getContentSize().width / 2.0)
        bg:addChild(jiantou)

    -- 生成选择项
    for i=1,5 do
        -- local node = self:createSelectNode(v)
        local node = cc.Node:create()

        local btn = ccui.Button:create("game/piaobtn/piao_yellow_"..i..".png", "game/piaobtn/piao_yellow_"..i..".png", "game/piaobtn/piao_gray_"..i..".png", ccui.TextureResType.localType)
        btn:setAnchorPoint(cc.p(0.5, 0.5))
        btn:setScale9Enabled(true)
        -- btn:setContentSize(cc.size(50, 76 +(5 - 1) * 32))
        btn:setPositionX(0)
        btn:setPositionY(0)

        if min_score > i then
            btn:setBright(false)
            btn:setTouchEnabled(false)
        end

        WidgetUtils.addClickEvent(btn, function()
            -- self:sendAction(_tab)
            self:requestPiao(i)
            if tolua.cast(selectnode,"cc.Node") then
                selectnode:removeFromParent()
            end
        end )
        node:addChild(btn)

        node:setPositionX(28 + 22 +(i - 1) * 92)
        node:setPositionY(bg:getContentSize().height / 2.0)
        bg:addChild(node)
    end

    local _x, _y = btn:getPosition()
    btn.layer:setPosition(cc.p(_x, _y + 80))
end

--有些需要特殊重载,优先处理，并返回是否跳过后面的
function GameScene:priorityAction(data)
    if data.act_type == poker_common_pb.EN_SDR_ACTION_OUT_CARD then
        print(".........翻牌和出牌动画后，无玩家操作，把牌加到出牌位，明牌")
        printTable(data)

        if self:getTableConf().seat_num == 3 then
            if data.is_napai then 
                self:addDisardTile(data.seat_index, data.dest_card)
                self:addTotalOutTile(data.seat_index, {value = data.dest_card,is_napai = true})
            else
                self:addPutoutTile(data.seat_index, data.dest_card)
                self:addTotalOutTile(data.seat_index, {value = data.dest_card})
            end
        else
            self:addPutoutTile(data.seat_index, data.dest_card)
        end
        
        self.chuPaiIndex = -1
        self.tablelist[data.seat_index + 1]:outCardAction(data)
        return true
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_PAO then --明杠为抓
        print(".........跑牌动画")
        self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            local deleteList = data.col_info.cards
            if data.col_info.is_waichi == true then
                local card = data.col_info.cards[1]
                deleteList = {data.col_info.cards[1],data.col_info.cards[2],data.col_info.cards[3],data.col_info.cards[4]}
            end
            self:deleteHandTile(deleteList,data.seat_index)
        end

        self.tablelist[data.seat_index + 1]:paoPaiAction(data)
        return true
    end

    return false
end

function GameScene:addTotalOutTile(idx, value)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            if not v.total_out_cards then
                v.total_out_cards = { }
            end
            table.insert(v.total_out_cards, value)
            return value
        end
    end
end

function GameScene:getTotalOutTileByIdx(idx)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            print(".........GameScene:getTotalOutTileByIdx")
            printTable(v.total_out_cards)

            return v.total_out_cards or { }
        end
    end
    return {}
end

function GameScene:requestPiao(piao_score)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_select_piao
    request.is_piao = true
    if piao_score == 0 then
        request.is_piao = false
    end
    request.piao_score = piao_score
    SocketConnect_instance:send("cs_request_select_piao", msg)
end

return GameScene