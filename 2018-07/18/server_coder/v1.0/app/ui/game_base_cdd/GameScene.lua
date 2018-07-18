-- 长牌场景
local GameScene = class("GameScene", require "app.ui.game_base_cdd.base.BaseGameScene")
require "app.help.ComNoti"
require "app.help.WidgetUtils"



function GameScene:initView()
    self.name = "GameScene"
    print("=====GameScene:initView")
    self.layout = cc.CSLoader:createNode("ui/ddz/gameBase.csb")
    self:addChild(self.layout)
    WidgetUtils.setScalepos(self.layout)
     --WidgetUtils.setScalepos(self.layout:getChildByName(""))
    self.UILayer = require("app.ui.game_base_cdd.base.GameUILayer").new(self)
    :addTo(self.layout:getChildByName("UInode"))
    :setPosition(cc.p(0, 0))

    self.Suanfuc = require(self.path .. ".Suanfucforddz").new(self)


    self:initDataBySelf()

    self:initTable()
    self:refreshScene()
    self:setbgstype()
end

function GameScene:initDataBySelf()
    self.voicelist = { }
    self.isRunning = false
    -- 添加一个房间开始的等待动画
    self.actionList = { }

    self.allResultData = nil
    self.chuPaiIndex = -1

    self:setRestTileNum(0)

    self.lastAct = nil

    self.myDedugList = {}


end

function GameScene:initTable()
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

    self:otherInitView()

end
function GameScene:otherInitView()

end

function GameScene:refreshScene()

    self.UILayer:initTopInfo(self:getTableID())

    
    local state = self:getTableState()

    if state == poker_common_pb.EN_TABLE_STATE_WAIT_DISSOLVE then
        state = self:getDissolveInfo().dissolve_info.pre_state

        print(".........断线后，有解散房间的请求.........poker_common_pb.EN_TABLE_STATE_WAIT_DISSOLVE ")
        printTable(self:getDissolveInfo())

        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create( function()
            self.dissolveView = LaypopManger_instance:PopBox("DissolveView", self:getSeatsInfo(), self:getDissolveInfo())
        end )))
    end

    if state == poker_common_pb.EN_TABLE_STATE_PLAYING or   --玩牌阶段
        state == poker_common_pb.EN_TABLE_STATE_WAIT_QIANG_DI_ZHU or
        state == poker_common_pb.EN_TABLE_STATE_WAIT_DOUBLE or
        state == poker_common_pb.EN_TABLE_STATE_WAIT_MING_PAI or 
        state == poker_common_pb.EN_TABLE_STATE_WAIT_MING_PAI_2  then 

        -- if  state ~= poker_common_pb.EN_TABLE_STATE_WAIT_QIANG_DI_ZHU then
        --底牌设置
            if self.table_info.dipai_cards then
                
                print("断线重连的时候，地主牌")
                printTable(self.table_info.dipai_cards,"xp69")

                if  self:getTableConf().ttype == HPGAMETYPE.MCDDZ or self:getTableConf().ttype == HPGAMETYPE.YCDDZ  then  --只有麻城斗地主是其它玩家能看到底牌
                     self.mytable:updateDiZhuCards(true,self.table_info.dipai_cards)
                else
                    if  self:getDealerIndex() == self:getMyIndex () then
                        self.mytable:updateDiZhuCards(true,self.table_info.dipai_cards)
                    else
                       if  self:getTableConf().ttype == HPGAMETYPE.ESDDZ or self:getTableConf().ttype == HPGAMETYPE.YCDDZ then --只有恩施斗地主是4张地主牌
                            self.mytable:updateDiZhuCards(true,{0,0,0,0})
                        else
                            self.mytable:updateDiZhuCards(true,{0,0,0})
                        end
                    end
                end
            else
                if  self:getTableConf().ttype == HPGAMETYPE.ESDDZ or self:getTableConf().ttype == HPGAMETYPE.YCDDZ then --只有恩施斗地主是4张地主牌
                    self.mytable:updateDiZhuCards(true,{0,0,0,0})
                else
                    self.mytable:updateDiZhuCards(true,{0,0,0})
                end
            end
        -- end

        if self:getTableConf().ttype == HPGAMETYPE.YCDDZ then
            if self.table_info.laizi_card then
                if self.table_info.laizi_card == 0 then
                    self.Suanfuc.laizivalue = - 1
                    LAIZIVALUE_LOCAL = - 1
                else
                    LAIZIVALUE_LOCAL = self.table_info.laizi_card%16
                    self.Suanfuc.laizivalue = self.Suanfuc:getrealvalue(self.table_info.laizi_card%16)
                end
            end
        end
        --癞子牌设置
        if  self:getTableConf().ttype == HPGAMETYPE.MCDDZ then 
            if self.table_info.laizi_card then
                LocalData_instance:setLaiZiValuer(self.table_info.laizi_card % 16 ) 
                -- LocalData_instance:setLaiZiValuer(10) 
                self.mytable:updateLaiZiCards(true,self.table_info.laizi_card)
            else
                LocalData_instance:setLaiZiValuer(-2)  
                self.mytable:updateLaiZiCards(true,nil)
            end
        elseif  self:getTableConf().ttype == HPGAMETYPE.ESDDZ then
            LocalData_instance:setLaiZiValuer(18) 
        end



        self:setGameBegin(false)
        
        if self.table_info.operation_index ~= -1 then 
            local data = { }
            data.operation_index = self.table_info.operation_index
            data.left_card_num = self.table_info.left_card_num
            data.act_type = ACTIONTYPEBYMYSELF.NEXT_OPERATION
            self:addAction(data)
        end

     

        local ischuData = nil
        -- 重连处理
        local actionchoice, action_token = self:getActionChoiceByIdx(self:getMyIndex())
        if actionchoice then
            self.mytable:setIsMyTurn(true)
             for k, v in pairs(actionchoice) do
                v.action_token = action_token
            end
           self:addAction( { act_type = ACTIONTYPEBYMYSELF.MYTURN, data = actionchoice })
        end

        if not self.isRunning then
            local info = self.actionList[1]
            if info then
                self:doAction(info, "重连")
            end
        end

        if self.table_info.sdr_total_action_flows and #self.table_info.sdr_total_action_flows > 0 then

            for i,v in ipairs(self.table_info.sdr_total_action_flows) do
                local action = self.table_info.sdr_total_action_flows[#self.table_info.sdr_total_action_flows-i+1].action
                if i < 3 then
                    if action.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then
                        self.tablelist[action.seat_index + 1]:chuPaiAction(action,false)
                    elseif action.act_type == poker_common_pb.EN_SDR_ACTION_PASS then
                         self.tablelist[action.seat_index + 1].buchunode:setVisible(true)
                    end
                end
            end
        end
    end

    if  state == poker_common_pb.EN_TABLE_STATE_WAIT_QIANG_DI_ZHU  then
        print("抢地主阶段")
        printTable(self.table_info.dss_total_action_flows,"sjp10")
        if self.table_info.dss_total_action_flows and #self.table_info.dss_total_action_flows > 0 then
            for i,v in ipairs(self.table_info.dss_total_action_flows) do
                print(v.act_type)
                print(poker_common_pb.EN_DSS_ACTION_QIANG_DI_ZHU)
                print(poker_common_pb.EN_DSS_ACTION_BU_QIANG)
                if v.action.act_type == poker_common_pb.EN_DSS_ACTION_QIANG_DI_ZHU then
                    self.tablelist[v.action.seat_index + 1]:showjiaodizhu(false)
                    print("不抢")
                elseif v.action.act_type == poker_common_pb.EN_DSS_ACTION_BU_QIANG then
                    self.tablelist[v.action.seat_index + 1]:showbujiaodizhu(false)
                    print("抢")
                end

                if  self:getTableConf().ttype == HPGAMETYPE.ESDDZ then 
                    if v.action.act_type == poker_common_pb.EN_SDR_ACTION_BUY then
                        self.tablelist[v.action.seat_index + 1]:showjiaodizhu(false)
                        print("不抢")
                    elseif v.action.act_type == poker_common_pb.EN_SDR_ACTION_SELL then
                        self.tablelist[v.action.seat_index + 1]:showbujiaodizhu(false)
                        print("抢")
                    end
                end

            end
        end
    end

    for i, v in ipairs(self:getSeatsInfo()) do

        self.tablelist[v.index + 1]:refreshSeat(v)
    end

end

-- 每帧调用
function GameScene:onUpdate()
    -- self:playVoice()
    self:playVoice()
    self.UILayer:setNetState()
end
function GameScene:waitGameStart()
    -- 等待下一局
    local dss_seats = self:getSeatsInfo()
    for k, v in pairs(dss_seats) do
        if v.state ~= poker_common_pb.EN_SEAT_STATE_READY_FOR_NEXT_ONE_GAME then
            v.state = poker_common_pb.EN_SEAT_STATE_WAIT_FOR_NEXT_ONE_GAME
        end
    end
    self:setDealerIndex(-1)
    self:setSeatsInfo(dss_seats)
    for k, v in pairs(dss_seats) do
        self.tablelist[v.index + 1]:resetData()
        self.tablelist[v.index + 1]:refreshSeat(v)
    end
    if self:getTableConf().ttype == HPGAMETYPE.ESDDZ or self:getTableConf().ttype == HPGAMETYPE.YCDDZ then
         self.mytable:updateDiZhuCards(true,{0,0,0,0})
    else
         self.mytable:updateDiZhuCards(true,{0,0,0})
    end

   
    if self:getTableConf().ttype == HPGAMETYPE.MCDDZ then
        self.mytable:updateLaiZiCards(true)
    end
    self:setDiZhuCards(nil)
   
    self.UILayer:waitGameStart()
    self.isRunning = false
    self.actionList = { { act_type = ACTIONTYPEBYMYSELF.CREATE_CARD } }
    self.chuPaiIndex = -1
end

-- 注册网络协议
function GameScene:registerNetEventListener()
    ComNoti_instance:addEventListener("cs_notify_logout_table", self, self.NotifyLogoutTable)
    ComNoti_instance:addEventListener("cs_response_logout_table", self, self.ResponseLogoutTable)
    ComNoti_instance:addEventListener("cs_notify_player_connection_state", self, self.NotifyPlayerConnectionState)
    ComNoti_instance:addEventListener("cs_notify_sit_down", self, self.NotifySitDown)
    ComNoti_instance:addEventListener("cs_notify_seat_info", self, self.NotifySeatInfo)
    ComNoti_instance:addEventListener("cs_notify_next_operation", self, self.NotifyNextOperation)
    ComNoti_instance:addEventListener("cs_notify_seat_operation_choice", self, self.NotifySeatOperationChoice)
    ComNoti_instance:addEventListener("cs_response_ready_for_game", self, self.ResponseReadyforGame)
    ComNoti_instance:addEventListener("cs_notify_ready_for_game", self, self.NotifyReadyforGame)
    ComNoti_instance:addEventListener("cs_response_sdr_do_action", self, self.ResponseDoAction)
    ComNoti_instance:addEventListener("cs_notify_action_flow", self, self.NotifyActionFlow)
    ComNoti_instance:addEventListener("cs_notify_player_deal_mj", self, self.NotifyPlayerDealMj)
    ComNoti_instance:addEventListener("cs_notify_game_start", self, self.NotifyGameStart)
    ComNoti_instance:addEventListener("cs_notify_game_over", self, self.GameOver)
    ComNoti_instance:addEventListener("cs_response_dissolve_table", self, self.ResponseDissolveTable)
    ComNoti_instance:addEventListener("cs_notify_dissolve_table", self, self.NotifyDissolveTable)
    ComNoti_instance:addEventListener("cs_notify_dissolve_table_operation", self, self.NotifyDissolveTableOperation)

    ComNoti_instance:addEventListener("cs_notify_fpf_finish", self, self.showAllResult)

    ComNoti_instance:addEventListener("cs_notify_start_piao",self,self.SelectPiao)  
    ComNoti_instance:addEventListener("cs_response_select_piao",self,self.responseSelectPiao)
    ComNoti_instance:addEventListener("cs_notify_select_piao",self,self.notifyPiao)

    ComNoti_instance:addEventListener("cs_notify_ming_pai", self, self._notifyMingPai)

    self:addOtherEventListener()

    -- 接收消息
    ComNoti_instance:addEventListener("cs_response_chat", self, self.ResponseChat)
    ComNoti_instance:addEventListener("cs_notify_chat", self, self.NotifyChat)

    local listener = cc.EventListenerCustom:create("yvsdk_upload", function(evt)
        local output = json.decode(evt:getDataString(), 1)
        local CurVoiceUrl = LocalData_instance:getSelfLocalVoiceHandle()
        output.local_voice_handle_data = CurVoiceUrl
        if output then
            -- CommonUtils:prompt(output.result)
            -- print(output)
            if tonumber(output.result) == 0 then
                if tonumber(output.time) < 11000 then
                    Socketapi.sendChat(2, json.encode(output))
                else
                    CommonUtils:prompt("您的语音太长了", CommonUtils.TYPE_CENTER)
                    print("语音发送失败")
                end
            else
                print(output.url)
            end
        else
            print("语音发送失败")
        end

    end )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)

    local listener = cc.EventListenerCustom:create("yvsdk_finshed", handler(self, self.onFinshPlayVoice))
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)

    self:registerScriptHandler( function(state)
        print("--------------" .. state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end )

end
function GameScene:addOtherEventListener()

end

-----漂相关
function GameScene:SelectPiao(data)
end
function GameScene:notifyPiao( data )
end
function GameScene:responseSelectPiao( data )
end

-- 明牌
function GameScene:_notifyMingPai(data)
    printTable(data, "xp")
    self:setHandTileByIdx(data["seat_index"], data["card"])
    self:setMingPaiByIdx(data["seat_index"], 1)

    self.tablelist[data.seat_index + 1]:refreshHandTile()
    self.tablelist[data.seat_index + 1]:showMingPai()
end

--bugList 上传
function GameScene:printTable(obj)
   
end


function GameScene:NotifyLogoutTable(data)
    self:setSeatInfo( { index = data.seat_index, state = poker_common_pb.EN_SEAT_STATE_WAIT_FOR_NEXT_ONE_GAME })
    self.tablelist[data.seat_index + 1]:refreshSeat()
end

function GameScene:ResponseLogoutTable(data)
    if data.result == 0 then
        local table_id = self:getTableID()
            glApp:enterSceneByName("MainScene")
        if self.isdelegate then
        else
            if table_id and(tonumber(self:getTableCreaterID()) == LocalData_instance:getUid()) then
               glApp:getCurScene():havecreateTable(table_id,self:getTableConf().ttype)
            end
        end
    else
        LaypopManger_instance:PopBox("PromptBoxView", 1, { tipstr = "退出房间失败" })
    end
end


function GameScene:NotifySeatInfo(data)
    print("Notiseat_info")
    self:setSeatsInfo(data.seats)
    for i, v in ipairs(self.tablelist) do
        v:refreshSeat()
    end
end

function GameScene:NotifySitDown(data)
    print("NotifySitDown")
    printTable(data, "pbz")
    self:setSeatInfo(data.sdr_seat)

    local _list = {}

    -- 检测ip 是否相同
    self.UILayer:openDistanceView()
    self.tablelist[data.sdr_seat.index + 1]:refreshSeat()
end

function GameScene:ResponseReadyforGame(data)
    print(".........function GameScene:ResponseReadyforGame(data)")
    printTable(data, "xp7")
    if data.result == 0 then
        local seatinfo = self:getSeatInfoByIdx(self:getMyIndex())
        if data.state == true then
            seatinfo.state = poker_common_pb.EN_SEAT_STATE_READY_FOR_NEXT_ONE_GAME
            self:setSeatInfo(seatinfo)
        else
            seatinfo.state = poker_common_pb.EN_SEAT_STATE_WAIT_FOR_NEXT_ONE_GAME
            self:setSeatInfo(seatinfo)
        end
        self.tablelist[self:getMyIndex() + 1]:refreshSeat()
    else
        print("准备失败")
    end
end

function GameScene:NotifyReadyforGame(data)
    print(".........function GameScene:NotifyReadyforGame(data)")
    -- printTable(data, "xp7")
    local seatinfo = self:getSeatInfoByIdx(data.seat_index)
    if data.state == true then
        seatinfo.state = poker_common_pb.EN_SEAT_STATE_READY_FOR_NEXT_ONE_GAME
    else
        seatinfo.state = poker_common_pb.EN_SEAT_STATE_WAIT_FOR_NEXT_ONE_GAME
    end
    self.tablelist[data.seat_index + 1]:refreshSeat()
end

function GameScene:ResponseDissolveTable(data)
    print("GameScene:ResponseDissolveTable 自己解散房间的返回")
    printTable(data, "xp")

    if data.result == 0 then
    elseif data.result == poker_common_pb.EN_MESSAGE_INVALID_SEAT_INDEX then
        print("不是房主不能解散房间")
        LaypopManger_instance:PopBox("PromptBoxView", 1, { tipstr = "不是房主不能解散房间" })
    else
        LaypopManger_instance:PopBox("PromptBoxView", 1, { tipstr = "你不可解散房间" })
    end
end

function GameScene:NotifyDissolveTable(data)

    print("GameScene:NotifyDissolveTable NotifyDissolveTable")
    printTable(data, "xp")

    glApp:enterSceneByName("MainScene")
end

function GameScene:NotifyDissolveTableOperation(data)
    print("GameScene:NotifyDissolveTableOperation 收到解散房间的广播")
    printTable(data, "xp")
    if data then
        if tolua.cast(self.dissolveView, "cc.Node") == nil and data.dissolve_info ~= nil then
            LaypopManger_instance:backByName("SetView")
            self.dissolveView = LaypopManger_instance:PopBox("DissolveView", self:getSeatsInfo(), data)
        elseif tolua.cast(self.dissolveView, "cc.Node") then
            self.dissolveView:releaseRoom(data)
        end
    end
end
-- 显示总结算
function GameScene:showAllResult(data)

    print("游戏结束，总结算")
    printTable(data)
    -- glApp:enterSceneByName("MainScene")
    if data.is_dissolve_finish then

        if tolua.cast(self.dissolveView, "cc.Node") then
            LaypopManger_instance:backByName("DissolveView")
        end
        -- self:stopAllActions()
        -- 申请解散 直接弹出结算
        self.allResultData = data
        glApp:enterSceneByName("AllResultScene", self)
        -- LaypopManger_instance:PopBox("AllResultView",self)	
    else
        self.allResultData = data
    end

end
-- 发送消息回复
function GameScene:ResponseChat(data)
    data.ctype = data.json_msg_id
    data.uid = LocalData_instance:getUid()
    -- 文字
    if data.ctype == 0 then
        data.message = data.json_msg.message
        self.mytable:addMsgBubble(data)
        -- self:addMsgBubble(index,data)
        -- 表情
    elseif data.ctype == 1 then
        data.message = ""
        data.BigFaceChannel = data.json_msg.page
        data.BigFaceID = data.json_msg.id
        data.message = data.json_msg.msg
        data.uid = LocalData_instance:getUid()
        self.mytable:addMsgBubble(data)
    elseif data.ctype == 2 then
        data.message = data.json_msg.message
        data.pos = self:getMyIndex()
        table.insert(self.voicelist, data)
    end
end

-- 消息通知
function GameScene:NotifyChat(data)
    local idx = self:getIndexByUID(data.uid)
    if idx then
        print("index 位置= ", idx)
        data.pos = idx
        if data.ctype == 2 then
            table.insert(self.voicelist, data)
        else
            self.tablelist[idx + 1]:addMsgBubble(data)
        end
    else
        print("没有找到位子")
    end
end

function GameScene:playVoice()
    if device.platform == "android" or device.platform == "ios" then
    else
        return
    end

    if IMDispatchMsgNode:isPlaying() then
        return
    end

    if #self.voicelist > 0 then
        local data = self.voicelist[1]
        print("..............GameScene:playVoice ")
        printTable(data)
        local output = json.decode(data.message, 1)
        local isnotmove = false
        for i, v in ipairs(self:getSeatsInfo()) do
            if v.user and v.user.uid == data.uid then
                isnotmove = true
            end
        end
        if isnotmove then
            if device.platform == "android" or device.platform == "ios" then
                IMDispatchMsgNode:playFromUrl(output.url)
                self.tablelist[data.pos + 1]:addMsgBubble(data)
                table.remove(self.voicelist, 1)
            end
        else
            table.remove(self.voicelist, 1)
        end
    end
end

function GameScene:onFinshPlayVoice()

end

function GameScene:NotifyPlayerConnectionState(data)
    for i, v in ipairs(self:getSeatsInfo()) do
        if data.seat_index == v.index then
            if data.connection_state == 0 then
                v.user.is_offline = false
            else
                v.user.is_offline = true
            end
        end
    end
    self.tablelist[data.seat_index + 1]:refreshSeat()
end

function GameScene:NotifyGameStart(data)
    print(".......................牌局游戏开始～ data.dealer = ",data.dealer)
    printTable(data, "xp67")

    self.table_info.sdr_total_action_flows = {}
    self:setDealerIndex(data.dealer)
    self:setXiaoJiaIndex(data.xiaojia_index)

    self:setRestTileNum(data.left_card_num)
    self:setNowRound(data.round)
    self:setSeatsInfo(data.sdr_seats)
    self:setGameBegin(true)

    printTable(self.table_info, "xp67")


    if data.dipai_cards then
        if self:getTableConf().ttype == HPGAMETYPE.MCDDZ then  --只有麻城斗地主是其它玩家能看到底牌
             self.mytable:updateDiZhuCards(true,data.dipai_cards)
        else
            if self:getDealerIndex() == self:getMyIndex () then
                self.mytable:updateDiZhuCards(true,data.dipai_cards)
            end
        end
    else
        if self:getTableConf().ttype == HPGAMETYPE.ESDDZ or self:getTableConf().ttype == HPGAMETYPE.ESDDZ then --只有恩施斗地主是4张地主牌
             self.mytable:updateDiZhuCards(true,{0,0,0,0})
        else
             self.mytable:updateDiZhuCards(true,{0,0,0})
        end
    end

  
    if  self:getTableConf().ttype == HPGAMETYPE.MCDDZ then
        LocalData_instance:setLaiZiValuer(-2)  
        self.mytable:updateLaiZiCards(true,nil)
    elseif self:getTableConf().ttype == HPGAMETYPE.ESDDZ then
        LocalData_instance:setLaiZiValuer(18) 
    end
    

    for ii,vv in ipairs(self.tablelist) do
        vv.showcardnode:removeAllChildren()
        vv.buchunode:setVisible(false)
    end
    self:addAction( { act_type = ACTIONTYPEBYMYSELF.CREATE_CARD, data = data })
end 

function GameScene:setGameBegin(isbegin)
    print(".......................牌局游戏开始～,isbegin = ",isbegin)
    for i, v in ipairs(self.tablelist) do
        
        v:gameStartAction(isbegin)
    end
end


-- 背景 根据设置选择及时更换
function GameScene:setbgstype()
    local typestylse  = cc.UserDefault:getInstance():getIntegerForKey("bg_type_poker", 1)
    self.UILayer:setbgstype(typestylse)

    for k, v in pairs(self.tablelist) do
        v:setbgstype(typestylse)
    end
end


-- 游戏结束
function GameScene:GameOver(data)
    print("游戏结束")
    -- 如果 我还有 操作列表，没取消的话，
    -- if self.mytable.actionview:getIsShow() then
    --     print(".......................GameScene:NotifyActionFlow .....  如果 我还有 操作列表，没取消的话，")
    --     self.mytable.actionview:hide()
    --     table.remove(self.actionList, 1)
    --     self.isRunning = false
    -- end
    self:addAction( { act_type = ACTIONTYPEBYMYSELF.GAMEOVER, data = data })

end

-- 显示单局结算
function GameScene:showpeiResult(data)

    local ischunindex = 0
    
    for i,v in ipairs(data.sdr_result.players) do
        if v.win_info and v.win_info.styles then
            for i1,v1 in ipairs(v.win_info.styles) do
                if v1 == poker_common_pb.EN_SDR_STYLE_TYPE_Chun_Tian then
                    ischunindex = 1
                elseif v1 == poker_common_pb.EN_SDR_STYLE_TYPE_Fan_Chun_Tian then
                    ischunindex = 2
                end
            end
        end
    end
    for i,v in ipairs(self.tablelist) do
        v:gameOver()
    end

    printTable(data,"xp66")

    if ischunindex ~= 0 then
        self:runAction(cc.Sequence:create(cc.DelayTime:create(4),cc.CallFunc:create(function( ... )
            self:deleteAction("小结算")
            LaypopManger_instance:PopBox("DDZSingleResultView", data, self, 1)
        end)))
        self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function( ... )
            local DdzcsbAnmation = require "app.ui.game_base_cdd.DdzcsbAnmation"
            local node
            if ischunindex == 1 then
                node = DdzcsbAnmation.chuntianfordizhi()
            else
                node = DdzcsbAnmation.chuntianfornongming()
            end
            node:setPosition(cc.p(display.cx,display.cy))
            self:addChild(node)
        end)))
    else
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( ... )
            self:deleteAction("小结算")
            LaypopManger_instance:PopBox("DDZSingleResultView", data, self, 1)
        end)))
    end
end


-- 事件轮到谁操作
function GameScene:NotifyNextOperation(data)
    print("Next_Operation")
    -- printTable(data,"xp")

    data.act_type = ACTIONTYPEBYMYSELF.NEXT_OPERATION
    self:addAction(data)
end

function GameScene:NotifySeatOperationChoice(data)
    print(".......................GameScene:NotifySeatOperationChoice ")
    printTable(data, "xp")

    self.mytable:setIsMyTurn(true)
    -- local ischuData = nil
    for k, v in pairs(data.sdr_choices) do
        v.action_token = data.action_token
    end

    -- if ischuData then
    --     self:addAction( { act_type = ACTIONTYPEBYMYSELF.MYTURN_CHU, data = ischuData })
    -- else
    --     self:addAction( { act_type = ACTIONTYPEBYMYSELF.MYTURN, data = data.sdr_choices })
    -- end

    self:addAction( { act_type = ACTIONTYPEBYMYSELF.MYTURN, data = data.sdr_choices })

end

function GameScene:ResponseDoAction(data)
    print("...................ResponseDoAction ")
    printTable(data,"xp68")
    self:deleteAction("ResponseDoAction")
    if data.result ~= 0 then
        -- SocketConnect_instance.socket:close()
        LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "牌型错误，服务器拒绝",sureCallFunc = function() 
           
        end})   
    end
end

function GameScene:NotifyActionFlow(data)

    -- print(".......................GameScene:NotifyActionFlow")
    -- printTable(data,"xp")
    if not data.new_sdr_action_flow then
        return
    end

    -- -- 如果 我还有 操作列表，没取消的话，
    local action = data.new_sdr_action_flow.action
    action.display_anpai = data.display_anpai

    if self.mytable.actionview:getIsShow() and action.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then
        self.mytable.actionview:hide()
        table.remove(self.actionList, 1)
        self.isRunning = false
    end
    -- print(".......................GameScene:NotifyActionFlow action.act_type ＝ ",action.act_type)

    if (action.act_type == poker_common_pb.EN_SDR_ACTION_BUY or 
        action.act_type == poker_common_pb.EN_SDR_ACTION_SELL) and
        self:getTableConf().ttype == HPGAMETYPE.YSGDDZ then
       self:doAction(action, "BUY or SELL")
       self.isRunning = false
    elseif (action.act_type == poker_common_pb.EN_SDR_ACTION_JIA_BEI or 
        action.act_type == poker_common_pb.EN_SDR_ACTION_BU_JIA_BEI) and 
        self:getTableConf().ttype == HPGAMETYPE.JDDDZ then
        self:doAction(action, "JiaBei or BuJIaBei")
        self.isRunning = false
    else
        self:addAction(action)
    end

    
end




function GameScene:deleteAction(_str)
    print("----------------------------------deleteAction--- _str = ", _str)

    table.remove(self.actionList, 1)
    self.isRunning = false

    local info = self.actionList[1]
    if info then
        self:doAction(info, "deleteAction")
    end
end

function GameScene:addAction(action)
    print("........................GameScene:addAction，self.isRunning = ",self.isRunning)

    table.insert(self.actionList, action)
    printTable(self.actionList)
    
    if not self.isRunning then
        local info = self.actionList[1]
        if info then
            self:doAction(info, "addAction")
        end
    end
end


-- 操作动画相关
function GameScene:doAction(data, _str)
    
    print("GameScene:doAction .................... data.act_type = ",data.act_type)

    printTable(data,"xp66")
    
    self.lastAct = data
    self.isRunning = true

    if self:priorityAction(data) then
    elseif  data.act_type == ACTIONTYPEBYMYSELF.CREATE_CARD then
        -- 为了 延迟等待创建牌的动画结束 再播放操作动画而加的延迟
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1.8), cc.CallFunc:create( function()
            self:deleteAction("创建牌的动画结束")
        end )))
    elseif data.act_type == ACTIONTYPEBYMYSELF.NEXT_OPERATION then
        -- 轮到谁操作，的那个闹钟的显示与倒计时

        self.UILayer:setOpertip(data.operation_index)
        self.tablelist[data.operation_index + 1].showcardnode:removeAllChildren()
        self.tablelist[data.operation_index + 1].buchunode:setVisible(false)

        self:deleteAction("轮到谁操作")
    elseif data.act_type == ACTIONTYPEBYMYSELF.MYTURN then
        print("轮到我 出牌 操作")
        self.mytable:showActionView(data.data)
    elseif data.act_type == ACTIONTYPEBYMYSELF.MYTURN_CHU then
        self.UILayer:setOpertip(data.data.seat_index)

    elseif data.act_type == ACTIONTYPEBYMYSELF.GAMEOVER then
        self:showpeiResult(data.data)
        self.UILayer:setOpertip()
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then

        data.isya = false
        if self.table_info.sdr_total_action_flows and #self.table_info.sdr_total_action_flows > 0 then
            local totall = #self.table_info.sdr_total_action_flows
            for i,v in ipairs(self.table_info.sdr_total_action_flows) do
                local action = self.table_info.sdr_total_action_flows[totall-i+1].action
                if action.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then
                    if action.cardtype == data.cardtype  then
                        data.isya = true
                    end
                    break
                end
            end
        end

        if self.table_info.sdr_total_action_flows == nil then
            self.table_info.sdr_total_action_flows = {}
        end

        table.insert(self.table_info.sdr_total_action_flows,{action = data})
        self.tablelist[data.seat_index + 1]:chuPaiAction(data,true)

        self:deleteHandTile(data.cards,data.seat_index)
        self.tablelist[data.seat_index + 1]:refreshcardNum()
        if self:getMingPai() then
            self.tablelist[data.seat_index + 1]:refreshHandTile()
        end
  
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_PASS then
        print(".........过，不需要动画")
        self.tablelist[data.seat_index + 1]:pass(true)
        if data.is_single_over then
            self.table_info.sdr_total_action_flows = {}
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create( function()
                for i,v in ipairs(self.tablelist) do
                    v.showcardnode:removeAllChildren()
                    v.buchunode:setVisible(false)
                end
                self:deleteAction("过")
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
        if  self:getDealerIndex() == self:getMyIndex () then
            self.mytable:updateDiZhuCards(true,data.col_info.cards)
        end
        self:setDiZhuCards(data.col_info.cards)
        -- 
        self.tablelist[data.seat_index + 1]:addDizhuCards(data.col_info.cards)
        self.tablelist[data.seat_index + 1]:refreshcardNum()
        if self:getMingPai() then
            self.tablelist[data.seat_index + 1]:refreshHandTile()
        end

        self.mytable.actionview:hide()
        
        self:deleteAction("抓牌动画结束！")

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_BUY then --买牌
        print("倒")
        self.tablelist[data.seat_index + 1]:buyOrSellPaiAction(true)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_SELL then --卖牌
        print("倒")
        self.tablelist[data.seat_index + 1]:buyOrSellPaiAction(false)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_NOTIFY_BUY then --广播买卖 --野三关是在广播买卖里面确定庄家的

        printTable(data,"xp66")

        for i,v in ipairs(self.tablelist) do
            print(".........i = ",i)
            v:showBuyPaiAction(data.buy_results[i])
            if data.buy_results[i] and i ~= (data.dealer+1) then
                self:setDoublevalue(i-1,1)
                v:shuangDoubletip(false)
            end
        end

        local oldDealer = self:getDealerIndex()+1
        local dealerIcon = self.tablelist[oldDealer].icon
        local zhuang = dealerIcon:getChildByName("zhuang"):setVisible(false)--setColor(cc.c3b(0x99, 0x96, 0x96))
        local worldpos = dealerIcon:convertToWorldSpace(cc.p(zhuang:getPositionX(), zhuang:getPositionY()))
       
        self:setDealerIndex(data.dealer)
        self.tablelist[oldDealer]:refreshHandTile()

        if data.dealer ~= -1 then
            self.tablelist[data.dealer+1]:showZhuangAction(function()
                self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
                    self:deleteAction("抢庄动画结束！")
                end)))
            end,worldpos)
        end
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
function GameScene:priorityAction(data)
    return false
end

function GameScene:otherAction(data)
     self:deleteAction("不存在的操作为处理")
     print("-------------为处理操作")
    
end
function GameScene:otherAllAction(data)
 
end

function GameScene:tableHideEffectnode()
    if self.chuPaiIndex ~= -1 then
        print(".......翻出，或者打出的牌，被操作了，需要隐藏 self.chuPaiIndex＝ ", self.chuPaiIndex)
        self.tablelist[self.chuPaiIndex + 1]:hideEffectnode()
        self.chuPaiIndex = -1
    end
end


function GameScene:getFanPanWorldPos()
    return self.UILayer:getFanPanWorldPos()
end


return GameScene