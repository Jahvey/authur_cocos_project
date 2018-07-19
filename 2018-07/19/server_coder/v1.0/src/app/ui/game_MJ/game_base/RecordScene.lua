local RecordScene = class("RecordScene", require "app.ui.game_MJ.game_base.base.BaseGameScene")

function RecordScene:ctor(data, pos, path)
    self.name = "RecordScene"
    self.path = path
    self.kuaijin_pos = pos
    self:initData(data)
    self:initView(data)
    self:initEvent()
    self:initOutCardTips()
    
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
    self.layout = cc.CSLoader:createNode("ui/game_mj/gameBasenew.csb")
        :addTo(self)

    self.UILayer = require("app.ui.game_MJ.game_base.base.GameUILayer").new(self)
    :addTo(self.layout:getChildByName("UInode"))
    :setPosition(cc.p(0, 0))

    WidgetUtils.setScalepos(self.layout)
    self.UILayer:hideNormalBtn()

    self:initTable()

    self:refreshScene()
    self:setbgstype()

    self:initRecordPlayer(data)


    self:setRestTileNum(self.table_info.left_card_num)
    self.UILayer:refreshInfoNode()
    self.UILayer:setOpertip(self.table_info.dealer)


    print("......回放界面 self.table_info.left_card_num ＝ ",self.table_info.left_card_num)
    print("......回放界面 self.table_info.laizi_card ＝ ",self.table_info.laizi_card)
    print("......回放界面 self.table_info.pizi_card ＝ ",self.table_info.pizi_card)

    if self.table_info.laizi_card then
        self.UILayer:setJokerCard(self.table_info.laizi_card)
    end
    if self.table_info.pizi_card then
        self.UILayer:setPiZiCard(self.table_info.pizi_card)
    end
    -- left_card_num
end

--打出牌上面的 指针标示
function RecordScene:initOutCardTips()
    print("............出牌提示！！！")
    local csblayer = cc.CSLoader:createNode("cocostudio/ui/game_action/out_tips/tips.csb")
    local action = cc.CSLoader:createTimeline("cocostudio/ui/game_action/out_tips/tips.csb")
    local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        print("event :"..str)
        if str == "end" then
            if isnothide == nil then
                csblayer:removeFromParent()
            end
            if type >2 then
                self:setHutips(type)
            end
        end
    end
    action:setFrameEventCallFunc(onFrameEvent)

    csblayer:runAction(action)
    action:gotoFrameAndPlay(0, true)

    self.tips = csblayer
    self.tips:setLocalZOrder(1)
    self:addChild(self.tips)
    self.tips:setVisible(false)
    self.tipsMa = nil
end

function RecordScene:setOutCardTips(isShow,ma)
    self.tips:setVisible(isShow)
    if isShow and ma then
        local pos = cc.p(ma:getPositionX(),ma:getPositionY())
        local posend = ma:getParent():convertToWorldSpace(pos)
        local anp = ma:getAnchorPoint()
        local size = ma:getbg():getContentSize()
        local _x = posend.x+(0.5-anp.x)*size.width
        local _y = posend.y+(0.5-anp.y)*size.height
        -- self.gamescene:setOutCardTips(true,)
        self.tips:setPosition(cc.p(_x,_y))
        self.tipsMa = ma
    end
    if isShow == false then
        if  self.tipsMa ~= nil then
            self.tipsMa:removeFromParent()
            self.tipsMa = nil
        end
    end

end

function RecordScene:initTable()
    local tableBase = require(self.path .. ".GameTable")
    local gameAction = require(self.path .. ".ActionView")
    
    self.Suanfuc = require("app.ui.game_MJ.game_base.SuanfucForGame").new(self)

    local bottomtable = require("app.ui.game_MJ.game_base.base.TableBottom").create(tableBase, gameAction).new(self.layout:getChildByName("bottomnode"), self)
    local toptable = require("app.ui.game_MJ.game_base.base.TableTop").create(tableBase).new(self.layout:getChildByName("topnode"), self)
    local lefttable = require("app.ui.game_MJ.game_base.base.TableLeft").create(tableBase).new(self.layout:getChildByName("leftnode"), self)
    local righttable = require("app.ui.game_MJ.game_base.base.TableRight").create(tableBase).new(self.layout:getChildByName("rightnode"), self)

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
        v:refreshHandCards(true)
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
    self:setNowRound(self.table_info.round)
    self:setDealerIndex(self.table_info.dealer)
    self:setXiaoJiaIndex(self.table_info.xiaojia_index)
    
    -- table.insert(self.table_info.sdr_total_action_flows, {act_type = ACTIONTYPEBYMYSELF.CREATE_CARD } )

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
    local typestylse = cc.UserDefault:getInstance():getIntegerForKey("bg_type_majiang", 3)

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

function RecordScene:setRunningAction(_time)

end
-- 操作动画相关
function RecordScene:action(data, hidenAnimation)
    data = data.action

    if data.act_type < 100 and data.seat_index and  data.seat_index == self:getMyIndex() then
        self.mytable:setBanedCardsList(data.baned_cards or {} ) --设置我不能打的牌
    end
    print("............doAction data.act_type = ",data.act_type)
    -- printTable(data,"xp7")

    self.UILayer:setOpertip(data.seat_index)

    if self:priorityAction(data) then
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_TOU then  --就是拿牌操作
        -- print(".........拿牌动画")

        self:setRestTileNum(self:getRestTileNum() -1)
        self.UILayer:setOpertip(data.operation_index)
        self.UILayer:refreshInfoNode()
        self:addHandCard(data)
        self.tablelist[data.seat_index + 1]:moPaiAction(data)

   elseif data.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then
        -- print(".........EN_SDR_ACTION_CHUPAI 出牌")
        -- self:addOutCard(data)
        self:deleteHandCard(data)
        self.tablelist[data.seat_index + 1]:chuPaiAction(data)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_OUT_CARD then
        -- print(".........EN_SDR_ACTION_OUT_CARD 出牌")
        self:addOutCard(data)
        self.tablelist[data.seat_index + 1]:outCardAction(data) 

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_PENG then
        -- print(".........碰牌动画")
        self:addShowCard(data)
        self:deleteHandCard(data)

        self.tablelist[data.seat_index + 1]:pengPaiAction(data)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_CHI then --2+1的吃为抵
        -- print(".........吃牌动画")
        self:addShowCard(data)
        self:deleteHandCard(data)

        self.tablelist[data.seat_index + 1]:chiPaiAction(data)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_GANG then
        -- print(".........杠牌动画")
        self:addShowCard(data)
        self:deleteHandCard(data)

        self.tablelist[data.seat_index + 1]:gangPaiAction(data)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_AN_GANG then
        -- print(".........暗杠动画")
        self:addShowCard(data)
        self:deleteHandCard(data)

        self.tablelist[data.seat_index + 1]:anGangPaiAction(data)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_UPDATE then  --更新out_col
        -- print(".........更新out_col")
        self:addShowCard(data)
        self.tablelist[data.seat_index+1]:refreshHandCards()
        self:setRunningAction(0.3)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_BAO then
        -- print(".........报")
        self.tablelist[data.seat_index+1]:baoPaiAction(data)

        self:setRunningAction(0.3)
   

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_HUPAI then
        -- print(".........胡牌动画")
        
        local handcards = self:getHandCardsByIdx(data.seat_index)

        if  #handcards % 3 == 2 then
            data.iszimo = true
        end
        self:addHandCard(data)
        self.tablelist[data.seat_index + 1]:huPaiAction(data)
    end
    self:otherAllAction(data)
end

--有些需要特殊重载,优先处理，并返回是否跳过后面的
function RecordScene:priorityAction(data)
    return false
end
function RecordScene:otherAction(data)

end
function RecordScene:otherAllAction(data)
 
end


function RecordScene:tableHideEffectnode()
 
end


function RecordScene:actiongo()
    local action = cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create( function()
        if self.table_info.sdr_total_action_flows and self.table_info.sdr_total_action_flows[self.beiginpos] ~= nil then

            local _flows = self.table_info.sdr_total_action_flows[self.beiginpos]
            self:action(_flows)
            self.beiginpos = self.beiginpos + 1

            if _flows.action.act_type == poker_common_pb.EN_SDR_ACTION_OUT_CARD then
                if  self.table_info.sdr_total_action_flows[self.beiginpos] ~= nil  then
                    self:action(self.table_info.sdr_total_action_flows[self.beiginpos])
                    self.beiginpos = self.beiginpos + 1
                end
            end
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
        v:refreshHandCards()
    end
    
    if self.isendshow == nil then
        self.isendshow = true
        if self.table_info.game_over then
            LaypopManger_instance:PopBox("MJSingleResultView", self.table_info.game_over, self, 2)
        end
    end
end

function RecordScene:kuaijin(pos)
    print("快进")
    self:stopAllActions()
    local number = pos or 1
    for i = 1, number do
        if self.table_info.sdr_total_action_flows and self.table_info.sdr_total_action_flows[self.beiginpos] ~= nil then
            self:action(self.table_info.sdr_total_action_flows[self.beiginpos], number > 1)
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