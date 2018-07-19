local RecordScene = class("RecordScene", require "app.ui.game.base.BaseGameScene")

function RecordScene:ctor(data, pos, path)
    self.name = "RecordScene"
    self.path = path
    self.kuaijin_pos = pos
    self:initData(data)
    self:initView(data)
    self:initEvent()
    
    if pos then
        self.stopbtn:setVisible(false)
        self.playbtn:setVisible(true)
        if pos > 1 then
            self:kuaijin(pos)
        end
    else
        self:actiongo()
    end
end

-- override
function RecordScene:initView(data)
    self.layout = cc.CSLoader:createNode("ui/game/gameBasenew.csb")
        :addTo(self)

    self.UILayer = require("app.ui.game.base.GameUILayer").new(self)
    :addTo(self.layout:getChildByName("UInode"))
    :setPosition(cc.p(0, 0))

    WidgetUtils.setScalepos(self.layout)
    self.UILayer:hideNormalBtn()

    self:initTable()

    self:refreshScene()
    self:setbgstype()

    self:initRecordPlayer(data)

    
    self:setJiangCard(self.table_info.jiang_card)
    self.UILayer:setJiangCard(self.table_info.jiang_card)

    if  self.table_info.joker_card then
        self:setJokerCard(self.table_info.joker_card)
        self.UILayer:setJokerCard(self.table_info.joker_card)
    end

end

function RecordScene:initTable()
    local tableBase = require(self.path .. ".GameTable")
    local gameAction = require(self.path .. ".ActionView")
    local bottomtable = require("app.ui.game.base.TableBottom").create(tableBase, gameAction).new(self.layout:getChildByName("bottomnode"), self)
    local toptable = require("app.ui.game.base.TableTop").create(tableBase).new(self.layout:getChildByName("topnode"), self)
    local lefttable = require("app.ui.game.base.TableLeft").create(tableBase).new(self.layout:getChildByName("leftnode"), self)
    local righttable = require("app.ui.game.base.TableRight").create(tableBase).new(self.layout:getChildByName("rightnode"), self)

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
        v:showNode()
        v:setTableIndex(i - 1)
    end

    self.mytable = bottomtable

    self:otherInitView()

end
function RecordScene:otherInitView()

end

function RecordScene:refreshScene()
    self.UILayer:initTopInfo(self:getTableID())
    for i, v in ipairs(self:getSeatsInfo()) do
        if  v.index == self:getMyIndex() then
            self.mytable:setBanedCardsList(v.baned_cards or {}) --设置我不能打的牌
        end
        self.tablelist[v.index + 1]:refreshSeat(v)
    end

    for i, v in ipairs(self.tablelist) do
        if  self.kuaijin_pos and self.kuaijin_pos > 1 then
            v:gameStartAction(true)
        else
            v:gameStartAction(false)
        end
    end
end

-- 数据处理
function RecordScene:initData(data)
    print(".............RecordScene:initData")
    -- printTable(data.sdr_record)

    self.table_info = clone(data.sdr_record)
    self.localdata = data
    LocalData_instance:setGameType(self:getTableConf().ttype)
    self:setRestTileNum(self.table_info.left_card_num or 0)
    self:setNowRound(self.table_info.round)
    self:setDealerIndex(self.table_info.dealer)
    self:setXiaoJiaIndex(self.table_info.xiaojia_index)

    for k, v in pairs(self:getSeatsInfo()) do
        v.state = 99
    end

    self.beiginpos = 1
    self.chuPaiIndex = -1


    if LocalData_instance:getVisualAngleUID() == nil then
        --设置视角uid
        local _uid = nil
        for i, v in ipairs(self.table_info.sdr_seats) do
            if _uid == nil then
                _uid = v.user.uid
            end

            if v.user and v.user.uid == LocalData_instance:getUid() then
                _uid = v.user.uid
                break
            end
        end
        LocalData_instance:setVisualAngleUID(_uid)
    end
end

-- 获取自己的服务器位置索引
function RecordScene:getMyIndex()
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.user and v.user.uid == LocalData_instance:getVisualAngleUID() then
            return v.index
        end
    end
    return 0
end

function RecordScene:getIsDisplayAnpai()
    return true
end

function RecordScene:initRecordPlayer(data)
    local layout = cc.CSLoader:createNode("ui/game/recordnode.csb")
    layout:setLocalZOrder(1)
    self:addChild(layout)
    layout:setPosition(cc.p(display.cx, display.cy))
    self.playbtn = WidgetUtils.getNodeByWay(layout, { "playbtn" })
    WidgetUtils.addClickEvent(self.playbtn, function()
        self.stopbtn:setVisible(true)
        self.playbtn:setVisible(false)
        self:playrecord()
    end )
    self.playbtn:setVisible(false)
    self.stopbtn = WidgetUtils.getNodeByWay(layout, { "stopbtn" })
    WidgetUtils.addClickEvent(self.stopbtn, function()
        self.stopbtn:setVisible(false)
        self.playbtn:setVisible(true)
        self:stoprecord()
    end )

    self.quickbtn = WidgetUtils.getNodeByWay(layout, { "quickbtn" })
    WidgetUtils.addClickEvent(self.quickbtn, function()
        self:kuaijin()
    end )

    self.daotui = WidgetUtils.getNodeByWay(layout, { "rebtn" })
    WidgetUtils.addClickEvent(self.daotui, function()
        local scene = self.new(data,(self.beiginpos - 2), self.path)
        display.runScene(scene)
    end )

    self.closebtn = WidgetUtils.getNodeByWay(layout, { "closebtn" })
    WidgetUtils.addClickEvent(self.closebtn, function()
        self:exitplay()
    end )


    --进度条
    self.progress = layout:getChildByName("LoadingBar")
    self.progress:setPercent(0)
end

-- 背景 根据设置选择及时更换
function RecordScene:setbgstype()
    local typestylse = cc.UserDefault:getInstance():getIntegerForKey("bg_type", 3)

    -- 界面变化
    self.UILayer:setbgstype(typestylse)
    -- 牌变化
    for k, v in pairs(self.tablelist) do
        v:setbgstype(typestylse)
    end
end


function RecordScene:deleteAction(_str)
    print("----------------------------------deleteAction--- _str = ", _str)
end

-- 操作动画相关
function RecordScene:action(data, hidenAnimation)
    data = data.action

    if data.act_type < 100 and data.seat_index and  data.seat_index == self:getMyIndex() then
        self.mytable:setBanedCardsList(data.baned_cards or {} ) --设置我不能打的牌
    end
    print("............doAction")
    printTable(data,"xp7")


    if self:priorityAction(data,hidenAnimation) then
    elseif data.act_type == ACTIONTYPEBYMYSELF.CREATE_CARD then
        -- 为了 延迟等待创建牌的动画结束 再播放操作动画而加的延迟
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create( function()
            self:deleteAction("创建牌的动画结束")
        end )))
     elseif data.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then
        print(".........出牌动画，等待玩家操作，明牌")
        self:deleteHandTile( { data.dest_card }, data.seat_index)
        self.chuPaiIndex = data.seat_index
        self.tablelist[data.seat_index + 1]:chuPaiAction(data,hidenAnimation)
        self.lastistou = false

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_PRE_CHUPAI then
        print(".........预出牌动画，等待玩家操作，明牌")
        self:deleteHandTile( { data.dest_card }, data.seat_index)
        self.chuPaiIndex = data.seat_index
        self.tablelist[data.seat_index + 1]:chuPaiAction(data,hidenAnimation)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_NAPAI then
        print(".........翻牌动画，等待玩家操作，翻的是 ", data.dest_card)
        self:setRestTileNum(data.left_card_num)
        self.UILayer:refreshInfoNode()
        self.chuPaiIndex = data.seat_index
        self.tablelist[data.seat_index + 1]:fanPaiAction(data,hidenAnimation)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_CHI then --2+1的吃为抵
        print(".........吃牌动画")
        self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)

        --为true的时候，表示是用已经歪了的吃的，只需要更新内容
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        elseif data.col_info.is_waichi == nil or data.col_info.is_waichi == false then
            local list = ComHelpFuc.getDeleteDestList(data.col_info,data.dest_card)
            self:deleteHandTile(list,data.seat_index)
        end

        self.tablelist[data.seat_index + 1]:chiPaiAction(data,hidenAnimation)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_WAI then --1+1的吃为歪
        
        print(".........歪牌动画")
        self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)

        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            local list = ComHelpFuc.getDeleteDestList(data.col_info,data.dest_card)
            self:deleteHandTile(list,data.seat_index)
        end
        self.tablelist[data.seat_index + 1]:waiPaiAction(data,hidenAnimation)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_PENG then
        print(".........碰牌动画")
        self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            local list = ComHelpFuc.getDeleteDestList(data.col_info,data.dest_card)
            self:deleteHandTile(list,data.seat_index)
        end
        self.tablelist[data.seat_index + 1]:pengPaiAction(data,hidenAnimation)

     elseif data.act_type == poker_common_pb.EN_SDR_ACTION_WEI then  --自己翻出来的碰为昭
        print(".........偎牌动画")
        self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)
        local list = ComHelpFuc.getDeleteDestList(data.col_info,data.dest_card)
        if self:getTableConf().ttype == HPGAMETYPE.HFBH then
            if data.col_info.is_waichi == true then
                list = {}
            end
        end
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            self:deleteHandTile(list,data.seat_index)
        end


        self.tablelist[data.seat_index + 1]:weiPaiAction(data,hidenAnimation)

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
                deleteList = {card,card,card,card}
            end
            self:deleteHandTile(deleteList,data.seat_index)
        end


        self.tablelist[data.seat_index + 1]:paoPaiAction(data,hidenAnimation)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_TI then --暗杠也是抓
        print(".........提牌动画")
        self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            local deleteList = data.col_info.cards
            if data.col_info.is_waichi == true then
                local card = data.col_info.cards[1]
                deleteList = {card,card,card,card}
            end
            self:deleteHandTile(deleteList,data.seat_index)
        end


        self.tablelist[data.seat_index + 1]:tiPaiAction(data,hidenAnimation)

     elseif data.act_type == poker_common_pb.EN_SDR_ACTION_SHANG_SHOU then
        self:tableHideEffectnode()
        print(".........胡牌动画 暂时用的是 偷牌动画")
        self:addHandTile(data.seat_index, data.dest_card)
        self.tablelist[data.seat_index + 1]:shangShouAction(data,hidenAnimation)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_OUT_CARD then
        print(".........翻牌和出牌动画后，无玩家操作，把牌加到出牌位，明牌")
        printTable(data)

        if self:getTableConf().ttype == HPGAMETYPE.ESSH or self:getTableConf().ttype == HPGAMETYPE.XESDR or self:getTableConf().ttype == HPGAMETYPE.XFSH  then
            if data.is_napai then 
                self:addDisardTile(data.seat_index, data.dest_card)
            else
                self:addPutoutTile(data.seat_index, data.dest_card)
            end
        else
            self:addPutoutTile(data.seat_index, data.dest_card)
        end
        
        self.chuPaiIndex = -1
        self.tablelist[data.seat_index + 1]:outCardAction(data,hidenAnimation)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_HUPAI then
        print(".........胡牌动画")
        self:addHandTile(data.seat_index, data.dest_card)
        self.tablelist[data.seat_index + 1]:huPaiAction(data,self.lastistou)
        self:otherAction(data)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_XIAO_HU then
        print(".........笑牌动画")
        self.tablelist[data.seat_index + 1]:xiaoHuPaiAction(data,hidenAnimation)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_QI_HU then
        print(".........弃牌动画")
        self.tablelist[data.seat_index + 1]:qiHuPaiAction(data,hidenAnimation)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_BAO then
        print(".........报")
        self.tablelist[data.seat_index+1]:baoPaiAction(data,hidenAnimation)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_KUA then --跨
        print(".........提牌动画")
        self:tableHideEffectnode()
        self:addShowTile(data.seat_index, data.col_info,hidenAnimation)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        elseif data.col_info.is_waichi == nil or data.col_info.is_waichi == false then
            self:deleteHandTile(data.col_info.cards,data.seat_index)
        end

        self.tablelist[data.seat_index + 1]:kuaPaiAction(data,hidenAnimation)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_UPDATE then  --更新out_col
        print(".........更新out_col")
        self:addShowTile(data.seat_index, data.col_info)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function() 
            self:deleteAction("更新结束")
        end)))
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_QIANG_ZHUANG then
        local dealerIcon = self.tablelist[self:getDealerIndex()+1].icon
        local zhuang = dealerIcon:getChildByName("zhuang"):setColor(cc.c3b(0x99, 0x96, 0x96))
        local worldpos = dealerIcon:convertToWorldSpace(cc.p(zhuang:getPositionX(), zhuang:getPositionY()))

        self:setDealerIndex(data.seat_index)
        self.tablelist[data.seat_index+1]:showZhuangAction(function()
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function() 
                self:deleteAction("抢庄动画结束！")
            end)))
            for ii,vv in ipairs(self.tablelist) do
                vv:setIsShowHuaZhuang(false)
            end
        end,worldpos,hidenAnimation)
    elseif data.act_type == poker_common_pb.EN_DSS_ACTION_HUA_ZHUANG then
        self.tablelist[data.seat_index+1]:setIsShowHuaZhuang(true)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function() 
                self:deleteAction("滑庄结束！")
            end)))

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_ZHAO then --明杠为招
        print(".........招牌动画")
        self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)
       if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            local list = ComHelpFuc.getDeleteDestList(data.col_info,data.dest_card)
            if self:getTableConf().ttype == HPGAMETYPE.HFBH then
                if data.col_info.is_waichi == true then
                    list = {}
                end
            end
            self:deleteHandTile(list,data.seat_index)
        end
        self.tablelist[data.seat_index + 1]:zhaoPaiAction(data,hidenAnimation)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_DENG then --巴杠为登
        print(".........登牌动画")
        self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            local deleteList = data.col_info.cards
            self:deleteHandTile(deleteList,data.seat_index)
        end
        self.tablelist[data.seat_index + 1]:dengPaiAction(data,hidenAnimation)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_KOU then --不打了，放弃了，把玩家所有手牌设置为灰色
        print(".........弃牌动画")
        self:getSeatInfoByIdx(data.seat_index).has_kou_pai = true
        self.tablelist[data.seat_index + 1]:yangAction(data,hidenAnimation)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_TOU then  --偷牌

        self:setRestTileNum(self:getRestTileNum() -1)
        self.UILayer:refreshInfoNode()

        self:addHandTile(data.seat_index, data.dest_card)
        self.tablelist[data.seat_index + 1]:touPaiAction(data,hidenAnimation)
        
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_SHOW then 
        self.tablelist[data.seat_index + 1]:showPaiAction(data,hidenAnimation)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_TUO then --拖
        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            self:deleteHandTile({data.dest_card},data.seat_index)
        end
        self.tablelist[data.seat_index + 1]:tuoPaiAction(data,hidenAnimation)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_LIANG_LONG then 
        print(".........亮拢动画")
        data.bao_info = {}
        table.insert(data.bao_info,{bao_type = 100}) --添加亮拢的报
        self:setLongCard(data.seat_index,data.dest_card)
        self.tablelist[data.seat_index+1]:updataHuXiText()
        self.tablelist[data.seat_index+1]:baoPaiAction(data)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_TIAN then 
        self:tableHideEffectnode()
        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        end
        self.tablelist[data.seat_index + 1]:tianPaiAction(data)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_MAI then --卖赖子
        print(".........卖癞子")
        self:tableHideEffectnode()

        local delete_card = data.dest_card
        if data.col_info.original_cards and data.col_info.original_cards[1]  then
            delete_card = data.col_info.original_cards[1]
        end
        if data.is_fan_ting then --如果是翻出来的牌，马上就听的话，不需要删除手牌
        else
            self:deleteHandTile( {delete_card}, data.seat_index)
        end
        self:addShowTile(data.seat_index, data.col_info)
        self.tablelist[data.seat_index + 1]:tingPaiAction(data)

    end
    if data.act_type == poker_common_pb.EN_SDR_ACTION_TOU then
        self.lastistou = true
    end

    self:otherAllAction(data)
end

--有些需要特殊重载,优先处理，并返回是否跳过后面的
function RecordScene:priorityAction(data,hidenAnimation)
    return false
end
function RecordScene:otherAction(data)

end
function RecordScene:otherAllAction(data)
 
end


function RecordScene:tableHideEffectnode()
    if self.chuPaiIndex ~= -1 then
        -- print(".......翻出，或者打出的牌，被操作了，需要隐藏 self.chuPaiIndex＝ ",self.chuPaiIndex)
        self.tablelist[self.chuPaiIndex + 1]:hideEffectnode()
        self.chuPaiIndex = -1
    end
end

function RecordScene:getFanPanWorldPos()
    return self.UILayer:getFanPanWorldPos()
end


function RecordScene:actiongo()
    local action = cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create( function()
        if self.table_info.sdr_total_action_flows and self.table_info.sdr_total_action_flows[self.beiginpos] ~= nil then

            local data = self.table_info.sdr_total_action_flows[self.beiginpos]
            if data.action.act_type == poker_common_pb.EN_SDR_ACTION_PRE_CHUPAI then
                self.beiginpos = self.beiginpos + 1
                data = self.table_info.sdr_total_action_flows[self.beiginpos]
            end

            self:action(data)
            self.beiginpos = self.beiginpos + 1

            self:updataProgress()
        else
            print("结束")
            self:stopAllActions()
            self:endplay()
        end
    end ))
    self:runAction(cc.RepeatForever:create(action))
end

function RecordScene:endplay()

    for i, v in ipairs(self.tablelist) do
        -- v:refreshSeat()
        v:refreshHandTile()
    end

    if self.isendshow == nil then
        self.isendshow = true
        if self.table_info.game_over then
            LaypopManger_instance:PopBox("SingleResultView", self.table_info.game_over, self, 2)
        end
    end
end

function RecordScene:kuaijin(pos)
    print("快进")
    self:stopAllActions()
    local number = pos or 1
    for i = 1, number do
        if self.table_info.sdr_total_action_flows and self.table_info.sdr_total_action_flows[self.beiginpos] ~= nil then
            
            local data = self.table_info.sdr_total_action_flows[self.beiginpos]
            if data.action.act_type == poker_common_pb.EN_SDR_ACTION_PRE_CHUPAI then
                self.beiginpos = self.beiginpos + 1
                data = self.table_info.sdr_total_action_flows[self.beiginpos]
            end
            self:action(data, number > 1)
            self.beiginpos = self.beiginpos + 1

        else
            print("结束")
            LocalData_instance:setVisualAngleUID(nil)
            self:stopAllActions()
            self:endplay()
            break
        end
    end
    self:updataProgress()
    self.stopbtn:setVisible(false)
    self.playbtn:setVisible(true)
end

function RecordScene:stoprecord()
    self:stopAllActions()
end

function RecordScene:playrecord()
    self:actiongo()
end

function RecordScene:replay()
    local scene = self.new(self.localdata,nil, self.path)
    display.runScene(scene)
end

--切换视角继续
function RecordScene:switchingReplay()
    print("...........切换视角继续")
    local scene = self.new(self.localdata,self.beiginpos, self.path)
    display.runScene(scene)
end


function RecordScene:exitplay()
    LocalData_instance:setVisualAngleUID(nil)
    Notinode_instance:setVisible(true)
    cc.Director:getInstance():popScene()
end

function RecordScene:setZhizhen(actionflow)
    self.UILayer:setOpertip(actionflow.action.seatid, true)
end

function RecordScene:updataProgress( )
    local max = #self.table_info.sdr_total_action_flows
    local percent = (self.beiginpos / max * 100)
    self.progress:setPercent(percent)    
end




return RecordScene