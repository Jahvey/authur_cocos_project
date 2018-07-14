local RecordScene = class("RecordScene", require "app.ui.game_base_cdd.base.BaseGameScene")
-- override
function RecordScene:ctor(data, pos, path)
    
    self.name = "RecordScene"
    self.path = path
    self:initData(data)
    -- if self.table_info.sdr_conf.lai_zi_num > 1 then
    --     print("-----------------------she")
    --     LocalData_instance:setLaiZiValuer(3) 
    -- end

    self:initView(data)
    self:initEvent()


    

    -- printTable(data.game_over,"xp68")



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
    print("record doudizhu")
    self.layout = cc.CSLoader:createNode("ui/ddz/gameBase.csb")
    self:addChild(self.layout)
    WidgetUtils.setScalepos(self.layout)
     --WidgetUtils.setScalepos(self.layout:getChildByName(""))
    self.UILayer = require("app.ui.game_base_cdd.base.GameUILayer").new(self)
    :addTo(self.layout:getChildByName("UInode"))
    :setPosition(cc.p(0, 0))

    self.Suanfuc = require(self.path .. ".Suanfucforddz").new(self)

    self.UILayer:hideNormalBtn()

    self:initTable()

    self:refreshScene()
    self:setbgstype()

    self:initRecordPlayer(data)

end

function RecordScene:initTable()
    local tableBase = require(self.path .. ".GameTable")
    local gameAction = require(self.path .. ".ActionView")
    local bottomtable = require("app.ui.game_base_cdd.base.TableBottom").create(tableBase, gameAction).new(self.layout:getChildByName("bottomnode"), self)
    local toptable = require("app.ui.game_base_cdd.base.TableTop").create(tableBase).new(self.layout:getChildByName("topnode"), self)
    local lefttable = require("app.ui.game_base_cdd.base.TableLeft").create(tableBase).new(self.layout:getChildByName("leftnode"), self)
    local righttable = require("app.ui.game_base_cdd.base.TableRight").create(tableBase).new(self.layout:getChildByName("rightnode"), self)

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

    --底牌设置
    if self.table_info.dipai_cards then
        if  self:getTableConf().ttype == HPGAMETYPE.MCDDZ then  --只有麻城斗地主是其它玩家能看到底牌
             self.mytable:updateDiZhuCards(true,self.table_info.dipai_cards)
        else
            if  self:getDealerIndex() == self:getMyIndex () then
                self.mytable:updateDiZhuCards(true,self.table_info.dipai_cards)
            end
        end
    else
        if  self:getTableConf().ttype == HPGAMETYPE.ESDDZ then --只有恩施斗地主是4张地主牌
            self.mytable:updateDiZhuCards(true,{0,0,0,0})
        else
            self.mytable:updateDiZhuCards(true,{0,0,0})
        end
    end

    if  self:getTableConf().ttype == HPGAMETYPE.MCDDZ then
        if self.table_info.laizi_card then
            LocalData_instance:setLaiZiValuer(self.table_info.laizi_card % 16 ) 
            self.mytable:updateLaiZiCards(true,self.table_info.laizi_card)
        else
            self.mytable:updateLaiZiCards(true,nil)
        end
    elseif self:getTableConf().ttype == HPGAMETYPE.ESDDZ then
        LocalData_instance:setLaiZiValuer(18) 
    end

    self:otherInitView()

end
function RecordScene:otherInitView()

end

function RecordScene:refreshScene()

    self.UILayer:initTopInfo(self:getTableID())

    for i, v in ipairs(self:getSeatsInfo()) do

        self.tablelist[v.index + 1]:refreshSeat(v)
        self.tablelist[v.index + 1]:gameStartAction(false)
        self.tablelist[v.index + 1]:refreshHandTile()
    end
end

-- 数据处理
function RecordScene:initData(data)
    -- print(".............RecordScene:initData")
    -- data.sdr_record.sdr_total_action_flows = {}
    -- data.sdr_record.game_over = {}

    printTable(data,"xp68")

    self.table_info = clone(data.sdr_record)
    self.localdata = data

    self:setInitRestTileNum()
    self:setNowRound(self.table_info.round)
    
    self:setDealerIndex(self.table_info.dealer)

    self:setXiaoJiaIndex(self.table_info.xiaojia_index)

    for k, v in pairs(self:getSeatsInfo()) do
        v.state = 99
    end

    self.beiginpos = 1
    self.chuPaiIndex = -1

    self._data = {}
    self._data.mingPai = false  --  明牌开关

    -- 经典斗地主开启明牌功能
    if (self.table_info.sdr_conf.ttype == HPGAMETYPE.JDDDZ) then
        self:setMingPai(true)
    end

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

function RecordScene:setInitRestTileNum()

    self:setRestTileNum(46)
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
    -- local typestylse = cc.UserDefault:getInstance():getIntegerForKey("bg_type", 3)

    -- -- 界面变化
    self.UILayer:setbgstype()
    -- -- 牌变化
    -- for k, v in pairs(self.tablelist) do
    --     v:setbgstype(typestylse)
    -- end
end


function RecordScene:deleteAction(_str)
    print("----------------------------------deleteAction--- _str = ", _str)
end

-- 操作动画相关
function RecordScene:action(data, hidenAnimation)
    data = data.action
    if self:priorityAction(data,hidenAnimation) then
    elseif  data.act_type == ACTIONTYPEBYMYSELF.CREATE_CARD then
        -- 为了 延迟等待创建牌的动画结束 再播放操作动画而加的延迟
        self:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create( function()
            -- print
            self:deleteAction("创建牌的动画结束")
        end )))
         --self:deleteAction("创建牌的动画结束")
    elseif data.act_type == ACTIONTYPEBYMYSELF.NEXT_OPERATION then
        -- 轮到谁操作，的那个闹钟的显示与倒计时

        -- self:setRestTileNum(data.left_card_num)
        --self.UILayer:refreshInfoNode()
        self.UILayer:setOpertip(data.operation_index)
        self.tablelist[data.operation_index + 1].showcardnode:removeAllChildren()
        self.tablelist[data.operation_index + 1].buchunode:setVisible(false)
        -- self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create( function()
        --     self:deleteAction("轮到谁操作")
        -- end )))
        self:deleteAction("轮到谁操作")
    elseif data.act_type == ACTIONTYPEBYMYSELF.MYTURN then
        print("轮到我 出牌 操作")
        self.mytable:setIsMyTurn(true)
        self.mytable:showActionView(data.data)
    elseif data.act_type == ACTIONTYPEBYMYSELF.MYTURN_CHU then
        self.mytable:setIsMyTurn(true)
        self.UILayer:setOpertip(data.data.seat_index)
        -- self.mytable:refreshHandTile()

        -- local cards = self:getHandTileByIdx(self:getMyIndex())
    elseif data.act_type == ACTIONTYPEBYMYSELF.GAMEOVER then
        self:showpeiResult(data.data)
        printTable(data.data,"sjp10")
        self.UILayer:setOpertip()
        -- self:deleteAction("小结算")
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then

        if  data.cards then
            self.tablelist[data.seat_index + 1]:chuPaiAction(data,true)
            self:deleteHandTile(data.cards,data.seat_index)
            self.tablelist[data.seat_index + 1]:refreshHandTile()
            self.tablelist[data.seat_index + 1]:refreshcardNum()
        end
  
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_PASS then
        print(".........过，不需要动画")
        self.tablelist[data.seat_index + 1]:pass(true)
        if data.is_single_over then
            --self.table_info.sdr_total_action_flows = {}
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create( function()
                self:deleteAction("过")
                for i,v in ipairs(self.tablelist) do
                    v.showcardnode:removeAllChildren()
                    v.buchunode:setVisible(false)
                end
            end )))
        else
            self:deleteAction("过")
        end
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_BU_QIANG then
        self.tablelist[data.seat_index + 1]:showbujiaodizhu(true)
        
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
                self:deleteAction("不抢")
        end)))
     elseif data.act_type == poker_common_pb.EN_SDR_ACTION_QIANG_DI_ZHU then
        print("抓地主地主")
        self.tablelist[data.seat_index + 1]:showjiaodizhu(true)
        
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
                self:deleteAction("抢地主地主")
            end)))

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_ZHUA_PAI then
        print("抓牌 ---- 翻底牌:"..data.seat_index)
        -- if  self:getDealerIndex() == self:getMyIndex () then
            self.mytable:updateDiZhuCards(true,data.col_info.cards)
            self:setDiZhuCards(data.col_info.cards)
        -- end
        -- 
        self.tablelist[data.seat_index + 1]:addDizhuCards(data.col_info.cards)
        self.tablelist[data.seat_index + 1]:refreshcardNum()

        self.mytable.actionview:hide()
        
        self:deleteAction("抓牌动画结束！")

    -- elseif data.act_type == poker_common_pb.EN_SDR_ACTION_DAO then
    --     print("倒")
    --     self:setDoublevalue(data.seat_index,1)
    --     self.tablelist[data.seat_index + 1]:shuangDoubletip(true)
    --     self:deleteAction("倒")
    -- elseif data.act_type == poker_common_pb.EN_SDR_ACTION_LA then
    --     print("拉")
    --     self:setDoublevalue(data.seat_index,1)
    --     self.tablelist[data.seat_index + 1]:shuangDoubletip(true)
    --     self:deleteAction("拉")
    -- elseif data.act_type == poker_common_pb.EN_SDR_ACTION_WO then
    --     self:setDoublevalue(data.seat_index,2)
    --     self.tablelist[data.seat_index + 1]:shuangDoubletip(true)
    --     print("窝")

    --     self:deleteAction("窝")
    -- elseif data.act_type == poker_common_pb.EN_SDR_ACTION_LEI then
    --     self:setDoublevalue(data.seat_index,2)
    --     self.tablelist[data.seat_index + 1]:shuangDoubletip(true)
    --     print("垒")

    --     self:deleteAction("垒")
       elseif data.act_type == poker_common_pb.EN_SDR_ACTION_BUY then --买牌
        print("倒")
        -- self:setDoublevalue(data.seat_index,1)
        self.tablelist[data.seat_index + 1]:buyOrSellPaiAction(true)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_SELL then --卖牌
        print("倒")
        self.tablelist[data.seat_index + 1]:buyOrSellPaiAction(false)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_NOTIFY_BUY then --广播买卖

        for i,v in ipairs(self.tablelist) do
            v:showBuyPaiAction(data.buy_results[i])
            if data.buy_results[i] and i ~= (data.dealer+1) then
                self:setDoublevalue(i-1,1)
                v:shuangDoubletip(false)
            end
        end
        -- local oldDealer = self:getDealerIndex()+1
        -- local dealerIcon = self.tablelist[oldDealer].icon
        -- local zhuang = dealerIcon:getChildByName("zhuang"):setVisible(false)--setColor(cc.c3b(0x99, 0x96, 0x96))
        -- local worldpos = dealerIcon:convertToWorldSpace(cc.p(zhuang:getPositionX(), zhuang:getPositionY()))
       
        self:setDealerIndex(data.dealer)
        -- self.tablelist[oldDealer]:refreshHandTile()

        self.tablelist[data.dealer+1]:showZhuangAction(function()
            self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
                self:deleteAction("抢庄动画结束！")
            end)))
        end)
        -- end,worldpos)

        -- self.tablelist[data.seat_index + 1]:buyOrSellPaiAction(data)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_JIA_BEI then
        self.tablelist[data.seat_index + 1]:shuangDoubletip(true)
        self:deleteAction("加倍")

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_BU_JIA_BEI then
        self.tablelist[data.seat_index + 1]:bujiaBei()
        self:deleteAction("不加倍")

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_BAO then

        self.tablelist[data.seat_index + 1]:showbaojing(#data.cards,true)
        self:deleteAction("报警")
        --免战
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_QIANG_MIAN_ZHAN then
        print("...免战")

        self:deleteAction("投降")
    --翻牌
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_FAN_DI_PAI then
        print("...翻牌")

        self:deleteAction("翻牌")
    else
        self:otherAction(data)
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

function RecordScene:handleAnKouData(data)

    local _list = {}
    if data.an_kou_info and  #data.an_kou_info ~= 0 then
        for i,v in ipairs(data.an_kou_info) do
           table.insert(_list,v.card)
        end
    end
    self:setAnKouInfo(data.seat_index,_list)
    self.tablelist[data.seat_index+1]:refreshHandTile()
   
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
    printTable(self.table_info.sdr_total_action_flows,"sjp10")
    local action = cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create( function()
        print("step:"..self.beiginpos)
        if self.table_info.sdr_total_action_flows[self.beiginpos] ~= nil then

            self:action(self.table_info.sdr_total_action_flows[self.beiginpos])
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
            LocalData_instance:setLaiZiValuer(-2)  
            --LaypopManger_instance:PopBox("SingleResultView", self.table_info.game_over, self, 2)
            LaypopManger_instance:PopBox("DDZSingleResultView", self.table_info.game_over, self,2)
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
    print(self.beiginpos)
    print(max)
    self.progress:setPercent(percent)    
end
return RecordScene