-- 长牌场景
local GameScene = class("GameScene", require "app.ui.game_MJ.game_base.base.BaseGameScene")
require "app.help.ComNoti"
require "app.help.WidgetUtils"


function GameScene:initView()
    self.isRunning = true
    self.name = "GameScene"
    print("=====GameScene:initView")
    self.layout = cc.CSLoader:createNode("ui/game_mj/gameBasenew.csb")
    self:addChild(self.layout)
    WidgetUtils.setScalepos(self.layout)
    self.UILayer = require("app.ui.game_MJ.game_base.base.GameUILayer").new(self)
    :addTo(self.layout:getChildByName("UInode"))
    :setPosition(cc.p(0, 0))

    self:initDataBySelf()

    self:initTable()
    self:refreshScene()
    self:initOutCardTips()
    self:setbgstype()
end

function GameScene:initDataBySelf()
    self.voicelist = { }

    self.allResultData = nil
    
    self.lastAct = nil

    --记录bug
    self.myDedugList = {}
    table.insert(self.myDedugList,"tableId:"..self:getTableID())
    table.insert(self.myDedugList,"round:"..self:getNowRound()+1)
    table.insert(self.myDedugList,"useId:"..LocalData_instance:getUid())
end


function GameScene:initTable()
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
    end

    self.mytable = bottomtable

    self:otherInitView()

end
function GameScene:otherInitView()

end

--打出牌上面的 指针标示
function GameScene:initOutCardTips()
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

function GameScene:setOutCardTips(isShow,ma)
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
        if  WidgetUtils:nodeIsExist(self.tipsMa) then
            -- self.tipsMa:setName("")
            self.tipsMa:removeFromParent()
            self.tipsMa = nil
        end
    end
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
    print("..............self:getTableState() = ",state)
    printTable(self.table_info, "xp69")

    if state == poker_common_pb.EN_TABLE_STATE_WAIT_DISSOLVE then
        state = self:getDissolveInfo().dissolve_info.pre_state

        print(".........断线后，有解散房间的请求.........poker_common_pb.EN_TABLE_STATE_WAIT_DISSOLVE ")
        printTable(self:getDissolveInfo())

        self.UILayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create( function()
            self.dissolveView = LaypopManger_instance:PopBox("DissolveView", self:getSeatsInfo(), self:getDissolveInfo())
        end )))
    end

    if state == poker_common_pb.EN_TABLE_STATE_PLAYING  then 

         -- 添加一个房间开始的等待动画
        self.actionList = { { act_type = ACTIONTYPEBYMYSELF.CREATE_CARD } }

        if  self.table_info.laizi_card then
            self.UILayer:setJokerCard(self.table_info.laizi_card)
        end

        if  self.table_info.pizi_card then
            self.UILayer:setPiZiCard(self.table_info.pizi_card)
        end

        self:setGameBegin(true)

        if self.table_info.operation_index then 

            if  self.table_info.dest_card and self.table_info.dest_card ~= 0 then
            else
                self.table_info.left_card_num = self.table_info.left_card_num +1
            end

            local _data = { }
            _data.operation_index = self.table_info.operation_index
            _data.left_card_num = self.table_info.left_card_num
            _data.act_type = ACTIONTYPEBYMYSELF.NEXT_OPERATION
            self:addAction(_data)

            --表示打出来了，
            if  self.table_info.dest_card and self.table_info.dest_card ~= 0 then
                local _data = { }
                _data.dest_card = self.table_info.dest_card
                _data.seat_index = self.table_info.operation_index
                _data.left_card_num = self.table_info.left_card_num
                _data.act_type = poker_common_pb.EN_SDR_ACTION_CHUPAI
                _data.ischong = true
                self:addAction(_data)
            else
                local seatInfo = self:getSeatsInfo()
                for i, v in ipairs(seatInfo) do
                    if v.index == self.table_info.operation_index then
                        
                        if self.table_info.operation_index == self:getMyIndex() then
                            if not self.table_info.is_mopai then
                                table.sort(v.hand_cards)
                            end
                            print("..........断线重连，轮到我出牌！！！",self.table_info.is_mopai)
                        end
                            
                        local card = v.hand_cards[#v.hand_cards]
                        local _data = { }
                        _data.dest_card = card
                        _data.seat_index = v.index
                        _data.act_type = poker_common_pb.EN_SDR_ACTION_TOU
                        self:addAction(_data)
                        table.remove(v.hand_cards,#v.hand_cards)
                    end
                end
                self:setSeatsInfo(seatInfo)
            end
        end

        self:setRestTileNum(self.table_info.left_card_num)
        self.UILayer:refreshInfoNode()

        local ischuData = nil
        -- 重连处理
        local actionchoice, action_token = self:getActionChoiceByIdx(self:getMyIndex())
        if actionchoice then
            self.mytable:setIsMyTurn(true)
            print(".......actionchoice = ", self:getMyIndex())
            -- printTable(actionchoice)

            for k, v in pairs(actionchoice) do
                v.action_token = action_token
                if v.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then
                    ischuData = v

                    printTable(v,"xp70")
                end
            end

            if ischuData and #actionchoice == 1 then
                self:addAction( { act_type = ACTIONTYPEBYMYSELF.MYTURN_CHU, data = ischuData })
            else
                self:addAction( { act_type = ACTIONTYPEBYMYSELF.MYTURN, data = actionchoice })
            end
        end

        local latestaction = self:getLastestAction()
        print(".......latestaction = ", self:getMyIndex())
        printTable(latestaction)
        printTable(ischuData)

        if latestaction then
            if latestaction.action.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI and latestaction.action.seat_index ~= self:getMyIndex() then
                self.UILayer:setOpertip(latestaction.action.seat_index)
            end
        end

        self.isRunning = false
    end

    if state == poker_common_pb.EN_TABLE_STATE_WAIT_PIAO   then
        self:SelectPiao()
    end

end

-- 每帧调用
function GameScene:onUpdate()
    self:playVoice()
    self.UILayer:setNetState()

    self:UpdateAction()
end
function GameScene:waitGameStart()
    -- 等待下一局
    local dss_seats = self:getSeatsInfo()
    for k, v in pairs(dss_seats) do
        if v.state ~= poker_common_pb.EN_SEAT_STATE_READY_FOR_NEXT_ONE_GAME then
            v.state = poker_common_pb.EN_SEAT_STATE_WAIT_FOR_NEXT_ONE_GAME
        end
        v.hand_cards = {}
        v.out_cards = {}
        v.out_col = {}
    end
    self:setSeatsInfo(dss_seats)
    for k, v in pairs(dss_seats) do
        self.tablelist[v.index + 1]:resetData()
        self.tablelist[v.index + 1]:refreshSeat(v)
    end
    self.UILayer:waitGameStart()
    self.actionList = { { act_type = ACTIONTYPEBYMYSELF.CREATE_CARD } }
    self:setOutCardTips(false)

    --在结算界面可能会使用，所以在这里设置
    self:setOldDealerIndex(-1)
    --用于判断抬庄
    self.outCard = 0
    self.outCardIndex = -1
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
    ComNoti_instance:addEventListener("cs_notify_game_start", self, self.NotifyGameStart)
    ComNoti_instance:addEventListener("cs_notify_game_over", self, self.GameOver)
    ComNoti_instance:addEventListener("cs_response_dissolve_table", self, self.ResponseDissolveTable)
    ComNoti_instance:addEventListener("cs_notify_dissolve_table", self, self.NotifyDissolveTable)
    ComNoti_instance:addEventListener("cs_notify_dissolve_table_operation", self, self.NotifyDissolveTableOperation)

    ComNoti_instance:addEventListener("cs_notify_fpf_finish", self, self.showAllResult)

    ComNoti_instance:addEventListener("cs_notify_start_piao",self,self.SelectPiao)  
    ComNoti_instance:addEventListener("cs_response_select_piao",self,self.responseSelectPiao)
    ComNoti_instance:addEventListener("cs_notify_select_piao",self,self.notifyPiao)

    self:addOtherEventListener()

    -- 接收消息
    ComNoti_instance:addEventListener("cs_response_chat", self, self.ResponseChat)
    ComNoti_instance:addEventListener("cs_notify_chat", self, self.NotifyChat)

    ComNoti_instance:addEventListener("add_Debug_List_Card", self, self.addDebugList_Card)

    



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
    self.UILayer:gameStartAciton()
    if  self:getSeatInfoByIdx(self:getMyIndex()).is_piao == nil then
        local selectnode = cc.Node:create()
        selectnode:setPosition(display.cx,display.cy)
        local btn1 = ccui.Button:create("game/btn_piao.png", "game/btn_piao.png", "game/btn_piao.png", ccui.TextureResType.localType)
        btn1:setPositionX(-100)
        selectnode:addChild(btn1)

        WidgetUtils.addClickEvent(btn1,function ()
            Socketapi.request_selectpiao(true)
            selectnode:removeFromParent()
        end)

        local btn2 = ccui.Button:create("game/btn_guo.png", "game/btn_guo.png", "game/btn_guo.png", ccui.TextureResType.localType)
        selectnode:addChild(btn2)
        btn2:setPositionX(100)
        self:addChild(selectnode)
        WidgetUtils.addClickEvent(btn2,function ()
            Socketapi.request_selectpiao(false)
            selectnode:removeFromParent()
        end)
    end

    for i,v in ipairs(self:getSeatsInfo()) do
        if v.is_piao == nil then
            self.tablelist[v.index+1]:setPiao(0)
        else
            self.tablelist[v.index+1]:setPiao(v.is_piao)
        end
    end

end
function GameScene:notifyPiao( data )
    self:getSeatInfoByIdx(data.seat_index).is_piao = data.is_piao
    self.tablelist[data.seat_index+1]:setPiao(data.is_piao)
end
function GameScene:responseSelectPiao( data )
    if data.result == 0 then
        data.seat_index = self:getMyIndex()
        self:notifyPiao(data)
    end
end


--bugList 上传
function GameScene:printTable(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, isArray, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        str = string.gsub(str, "[%c\\\"]", {["\t"] = "\\t",["\r"] = "\\r",["\n"] = "\\n",["\""] = "\\\"",["\\"] = "\\\\",})
        return '"' .. str .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "   [" .. val .. "]"
        elseif type(val) == "string" then
            return "   [" .. quoteStr(val) .. "]"
        else
            return "   [" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    local isArray = function(arr)
        local count = 0 
        for k, v in pairs(arr) do
            count = count + 1 
        end 
        for i = 1, count do
            if arr[i] == nil then
                return false
            end 
        end 
        return true, count
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local addstr = ""
        for i =1 ,level do
            addstr = addstr.."  "
        end
        local tokens = {}
        tokens[#tokens + 1] = string.sub(addstr,0,-6).."{"
        local ret, count = isArray(obj)
        if ret then
            for i = 1, count do
                tokens[#tokens + 1] = addstr.. wrapVal(obj[i], level) .. ","
            end
        else
            for k, v in pairs(obj) do
                tokens[#tokens + 1] = addstr.. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
            end
        end
        tokens[#tokens + 1] = addstr.. "}"
        return table.concat(tokens, " ")
    end
   return dumpObj(obj, 0)
end

function GameScene:addDebugList(_str,info)
    -- local infoStr = ""
    -- print("addDebugList")
    -- print(info)
    -- if  type(info) == "table" then 
    --     infoStr = self:printTable(info)
    --     print("infoStr")
    -- end
    -- table.insert(self.myDedugList,_str..":"..infoStr)
end

function GameScene:addDebugList_Card(data)
    local infoStr = ""
    if  type(data) == "table" then 
        infoStr = self:printTable(data)
    end
    table.insert(self.myDedugList,"牌不对 :"..infoStr)

    
    if  self.lastAct.act_type == ACTIONTYPEBYMYSELF.BIPAI then
        self.biCardError = true
        return
    end

    local tableSeat = self:getSeatsInfo()
    if  type(tableSeat) == "table" then 
        infoStr = self:printTable(tableSeat)
    end
    table.insert(self.myDedugList,"GameTable :"..infoStr)

    self:uploadDebugList()

end

function GameScene:uploadDebugList()
    
    if device.platform ~= "ios"  and device.platform ~= "android" then
        return
    end

    if  cc.UserDefault:getInstance():getIntegerForKey("DebugList_TableID",0) == self:getTableID()  and
        cc.UserDefault:getInstance():getIntegerForKey("DebugList_round",-1) == self:getNowRound()
        then
        return
    end
    cc.UserDefault:getInstance():setIntegerForKey("DebugList_TableID", self:getTableID())
    cc.UserDefault:getInstance():setIntegerForKey("DebugList_round", self:getNowRound())

    print("................uploadDebugList ")
    local dedugString = ""

    if self.myDedugList then 
        for i=1,#self.myDedugList do
            dedugString = dedugString..self.myDedugList[i].."\n"
        end
    end

    dedugString = dedugString.."\n上报操作类型"

    ComHttp.httpPOST(ComHttp.URL.DEBUG_REPORT,{type = GT_INSTANCE:getGameName(self:getTableConf().ttype),log = dedugString,uid = LocalData_instance.uid },function()
       print("上报操作类型成功")
       self.myDedugList = {}
       SocketConnect_instance.socket:close()
    end)
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
    printTable(data, "123")
    self:setSeatInfo(data.sdr_seat)

    -- 检测ip 是否相同
    self.UILayer:openDistanceView()
    self.tablelist[data.sdr_seat.index + 1]:refreshSeat()
end

function GameScene:ResponseReadyforGame(data)
    print(".........function GameScene:ResponseReadyforGame(data)")
    -- printTable(data, "xp7")
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
    if data.result == 0 then
    elseif data.result == poker_common_pb.EN_MESSAGE_INVALID_SEAT_INDEX then
        print("不是房主不能解散房间")
        LaypopManger_instance:PopBox("PromptBoxView", 1, { tipstr = "不是房主不能解散房间" })
    else
        LaypopManger_instance:PopBox("PromptBoxView", 1, { tipstr = "你不可解散房间" })
    end
end

function GameScene:NotifyDissolveTable(data)
    glApp:enterSceneByName("MainScene")
end

function GameScene:NotifyDissolveTableOperation(data)
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
            if v.user then
                if data.connection_state == 0 then
                    v.user.is_offline = false
                else
                    v.user.is_offline = true
                end
            end
        end
    end
    self.tablelist[data.seat_index + 1]:refreshSeat()
end

function GameScene:NotifyGameStart(data)
    print(".......................牌局游戏开始～")
    printTable(data, "xp66")

    self:setDealerIndex(data.dealer)
    self:setXiaoJiaIndex(data.xiaojia_index)

    -- 添加一个房间开始的等待动画
    self.actionList = { { act_type = ACTIONTYPEBYMYSELF.CREATE_CARD } }
    
    for i, v in ipairs(data.sdr_seats) do
        if  v.index == self:getMyIndex() then
            self.mytable:setBanedCardsList(v.baned_cards or {}) --设置我不能打的牌
        end

        --如果是庄家，删除最后一张手牌，设置成摸牌操作
        if  v.index == data.dealer then
            local card = v.hand_cards[#v.hand_cards] --其实，这里肯定是第14张

            local _data = { }
            _data.dest_card = card
            _data.seat_index = v.index
            _data.act_type = poker_common_pb.EN_SDR_ACTION_TOU
            table.insert(self.actionList,_data)
            table.remove(v.hand_cards,#v.hand_cards)

            data.left_card_num = data.left_card_num +1
        end
    end

    if  data.laizi_card then
        if self:getTableConf().ttype == HPGAMETYPE.BDMJ or self:getTableConf().ttype == HPGAMETYPE.ESMJ then

            local oldData = clone(data)
            for k,v in pairs(data.sdr_seats) do
                v.hand_cards = {}
            end
            table.insert(self.actionList, 1,{ act_type = ACTIONTYPEBYMYSELF.XUANPAI,data = oldData} ) 
        end
    end
  

    self:setRestTileNum(data.left_card_num)
    self:setNowRound(data.round)


    self:setSeatsInfo(data.sdr_seats)
    self:setGameBegin()

    self.isRunning = false
end 

function GameScene:setGameBegin(ischong)
    for i, v in ipairs(self.tablelist) do
        print(".......................牌局游戏开始～")
        v:gameStartAction(ischong)
    end
end


-- 背景 根据设置选择及时更换
function GameScene:setbgstype()
    local typestylse = cc.UserDefault:getInstance():getIntegerForKey("bg_type_majiang", 1)
    -- 界面变化
    self.UILayer:setbgstype(typestylse)
    -- 牌变化
    for k, v in pairs(self.tablelist) do
        v:setbgstype(typestylse)
    end
end


-- 游戏结束
function GameScene:GameOver(data)
    print("游戏结束")
    -- 如果 我还有 操作列表，没取消的话，
    if self.mytable.actionview:getIsShow() then
        print(".......................GameScene:NotifyActionFlow .....  如果 我还有 操作列表，没取消的话，")
        self.mytable.actionview:hide()
        table.remove(self.actionList, 1)
        self.isRunning = false
    end
    self:addAction( { act_type = ACTIONTYPEBYMYSELF.GAMEOVER, data = data })

end

-- 显示单局结算
function GameScene:showSingleResult(data)
    self.isRunning = true
    print("显示单局结算 显示单局结算 ")
    data.sdr_result.cards = nil

    for k,v in pairs(data.sdr_result.players) do
        if v.col_info_lsit  then
            v.col_info_lsit  = nil
        end
    end

    printTable(data,"xp70")

    LaypopManger_instance:PopBox("MJSingleResultView", data, self, 1)
    for i,v in ipairs(self:getSeatsInfo()) do
        v.is_piao = nil
        v.has_kou_pai = nil
        v.piao_score = 0
    end
   
    self:setRestTileNum(0)
  

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
    printTable(data, "xp11")

    local ischuData = nil
    for k, v in pairs(data.sdr_choices) do
        v.action_token = data.action_token
        if v.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then
            ischuData = v
        end
    end

    if ischuData  and #data.sdr_choices == 1 then
        print("...........我能出牌")
        self:addAction( { act_type = ACTIONTYPEBYMYSELF.MYTURN_CHU, data = ischuData })
    else
        print("...........我不能出牌")
        self:addAction( { act_type = ACTIONTYPEBYMYSELF.MYTURN, data = data.sdr_choices })
    end
end

function GameScene:ResponseDoAction(data)
    -- print("...................ResponseDoAction ")
    printTable(data,"xp70")

    self:setRunningAction()
end

function GameScene:NotifyActionFlow(data)

    print(".......................GameScene:NotifyActionFlow ")
    printTable(data,"xp11")

    if not data.new_sdr_action_flow then
        return
    end
    local action = data.new_sdr_action_flow.action

    if action.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI and 
        action.seat_index == self:getMyIndex() and not action.ismyself then

        print("..............2return action.ismyself = ",action.ismyself)
        return
    end

    -- 如果 我还有 操作列表，没取消的话，
    if self.mytable.actionview:getIsShow() then
        print("如果 我还有 操作列表，没取消的话，")
        self.mytable.actionview:hide()
        table.remove(self.actionList, 1)
        self.isRunning = false
    end

   
    self:addAction(action)
end

-- 显示暗的牌
function GameScene:showAnCardAction(display_anpai)
    print(".............是否要显示暗的牌 ", display_anpai)
end
function GameScene:getIsDisplayAnpai()

end



function GameScene:UpdateAction()
    if self.isRunning == false then
        -- if self.lastAct and self.lastAct.seat_index  and self.lastAct.seat_index == self:getMyIndex() then
        --     self:addDebugList("delete",{from = _str})
        --  end

        local info = self.actionList[1]
        if info then
            self.isRunning = true
            self:doAction(info, "addAction")
            table.remove(self.actionList, 1)
        end
    end
end
--设置
function GameScene:setRunningAction(_time)
    if _time  then
        self:stopAllActions()
        self:runAction(cc.Sequence:create(cc.DelayTime:create(_time), cc.CallFunc:create( function()
            self.isRunning = false
        end)))
    else
        self.isRunning = false
    end
end


function GameScene:addAction(action)
    table.insert(self.actionList, action)
end


-- 操作动画相关
function GameScene:doAction(data, _str)


    self.lastAct = data

    print("............doAction")
    printTable(data,"xp11")

    if data.seat_index  and data.seat_index == self:getMyIndex() then
        local _act_type = data.act_type or 0
        local _dest_card = data.dest_card or 0
        local _col_info = data.col_info or nil
        local _cards = nil
        if  _col_info  then
            _cards = _col_info.original_cards or _col_info.cards or nil
        end
        self:addDebugList("do_A",{act = _act_type,dest = _dest_card,cards = _cards,from = _str})
    end

    if self:priorityAction(data) then
    elseif  data.act_type == ACTIONTYPEBYMYSELF.XUANPAI then
        self:xuanPaiAction(data.data)
    elseif  data.act_type == ACTIONTYPEBYMYSELF.BIPAI then
        self:biPaiAction(data.data)
    elseif  data.act_type == ACTIONTYPEBYMYSELF.CREATE_CARD then
        -- 为了 延迟等待创建牌的动画结束 再播放操作动画而加的延迟
        for k,v in pairs(self.tablelist) do
            v:refreshHandCards(true)
        end
        self:setRunningAction(0.3)

    elseif data.act_type == ACTIONTYPEBYMYSELF.NEXT_OPERATION then
        -- 轮到谁操作，的那个闹钟的显示与倒计时

        self:setRestTileNum(data.left_card_num)
        self.UILayer:refreshInfoNode()
        self.UILayer:setOpertip(data.operation_index)

        self:setRunningAction(0.1)

    elseif data.act_type == ACTIONTYPEBYMYSELF.MYTURN then
        self.mytable:setIsMyTurn(true)
        print("...........轮到我操作")

        local ishaveChu = false
        

        local _data = data.data
        for k,v in pairs(_data) do
            if v.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then
                ishaveChu = true
                print("...........我可以出牌")
                self.mytable:setIsMyTurn(true)
                self.mytable:showShouZhi(true, v)
                table.remove(_data,k)
            end
        end
        if ishaveChu == false  then
            print("...........我不可以出牌")
            self.mytable:setIsMyTurn(false)
            self.mytable:showShouZhi(false)
        end

        self.mytable:showActionView(_data)

        local _list = {}
        local _dest_card = 0
        for k,v in pairs(data.data) do
            local _act_type = v.act_type or 0
            local _cards = v.original_cards or v.cards or nil
            local _li = {}
            _li.act_type = _act_type
            _li.cards = _cards
            table.insert(_list,_li)
        end
        self:addDebugList("show",{dest = _dest_card,acts = _list})

    elseif data.act_type == ACTIONTYPEBYMYSELF.MYTURN_CHU then
        self.mytable:setIsMyTurn(true)
        self.mytable:showShouZhi(true, data.data)
        self.UILayer:setOpertip(data.data.seat_index)

    elseif data.act_type == ACTIONTYPEBYMYSELF.GAMEOVER then
        self:showSingleResult(data.data)

    -----------玩家的操作
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_TOU then  --就是拿牌操作
        print(".........拿牌动画")
        self:setRestTileNum(self:getRestTileNum() -1)
        self.UILayer:refreshInfoNode()
        self:addHandCard(data)
        self.tablelist[data.seat_index + 1]:moPaiAction(data)

   elseif data.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then
        print(".........EN_SDR_ACTION_CHUPAI 出牌")
        -- self:addOutCard(data)
        if data.ischong then
        else
            self:deleteHandCard(data)
        end
        self.tablelist[data.seat_index + 1]:chuPaiAction(data)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_OUT_CARD then
        print(".........EN_SDR_ACTION_OUT_CARD 出牌")
        self:addOutCard(data)
        self.tablelist[data.seat_index + 1]:outCardAction(data) 
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_PENG then
        print(".........碰牌动画")
        self:addShowCard(data)
        self:deleteHandCard(data)

        self.tablelist[data.seat_index + 1]:pengPaiAction(data)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_CHI then --2+1的吃为抵
        print(".........吃牌动画")
        self:addShowCard(data)
        self:deleteHandCard(data)

        self.tablelist[data.seat_index + 1]:chiPaiAction(data)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_GANG then
        print(".........杠牌动画")
        self:addShowCard(data)
        self:deleteHandCard(data)

        self.tablelist[data.seat_index + 1]:gangPaiAction(data)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_AN_GANG then
        print(".........暗杠动画")
        self:addShowCard(data)
        self:deleteHandCard(data)

        self.tablelist[data.seat_index + 1]:anGangPaiAction(data)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_UPDATE then  --更新out_col
        print(".........更新out_col")
        self:addShowCard(data)
        self.tablelist[data.seat_index+1]:refreshHandCards()
        self:setRunningAction(0.3)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_BAO then
        print(".........报")
        self.tablelist[data.seat_index+1]:baoPaiAction(data)

        self:setRunningAction(0.3)
   

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_HUPAI then
        print(".........胡牌动画")

        local handcards = self:getHandCardsByIdx(data.seat_index)
        if  #handcards % 3 == 2 then
            data.iszimo = true
        end
     
        print("........#handcards = ",#handcards)

        self:addHandCard(data)
        self.tablelist[data.seat_index + 1]:huPaiAction(data)
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

    
end
function GameScene:otherAllAction(data)
 
end

function GameScene:tableHideEffectnode()
   
end



function GameScene:xuanPaiAction(data)

    print(".........xuanPaiAction")
    printTable(data,"xp70")

    local acticon = cc.CSLoader:createNode("ui/game_action/laizi_majiang/laizi_majiang.csb")
    acticon:setPosition(cc.p(display.cx, display.cy))
    self:addChild(acticon,9)

    AudioUtils.playVoice("xuanlaizi", 1)
    local action = cc.CSLoader:createTimeline("ui/game_action/laizi_majiang/laizi_majiang.csb")
    local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "end" then

            self:setSeatsInfo(data.sdr_seats)

            if  data.pizi_card then
                self.UILayer:setPiZiCard(data.pizi_card)
            end

            self.UILayer:setJokerCard(data.laizi_card)
            acticon:removeFromParent()
            self:setRunningAction(0.3)
            AudioUtils.playVoice("mj_"..data.laizi_card,1)
        end
    end
    
    local randomList = {1,2,3,4,5,6,7,8,9,33,34,35,36,37,38,39,40,41,65,66,67,68,69,70,71,72,73}
    local function deleteRandom( _num )
        for k,v in pairs(randomList) do
            if v == _num  then
                table.remove(randomList,k)
                return
            end
        end
    end
    local _next = data.laizi_card-1 --) == 0  and  9 ) or ((data.laizi_card-1) == 0  and  9 ) ((data.laizi_card-1) == 0  and  9 )   or data.laizi_card-1
    _next = (_next == 0 and 9) or (_next == 32 and 41) or (_next == 64 and 73) or _next

    deleteRandom(_next)
    local _list = {_next}

    for i=1,7 do
        local num = math.random(1, #randomList)
        local _num = randomList[num]
        deleteRandom(_num)
        table.insert(_list,1,_num)
    end

    local Majiangcard = require "app.ui.game_MJ.game_base.base.MaJiangCard"
    for i=1,8 do
        local putoutingma = Majiangcard.new(MAJIANGCARDTYPE.BOTTOM,_list[i])
        --癞子牌
        if putoutingma then 
            local picstr,str = putoutingma:getpicpath(MAJIANGCARDTYPE.BOTTOM,_list[i])
            if str == nil then
            else
                local _img = acticon:getChildByName("Node_1"):getChildByName("laizi"):getChildByName("pai_mian_0"..i)
                _img:loadTexture("gamemj/card/"..str,ccui.TextureResType.localType)
            end
        end
    end
    action:setFrameEventCallFunc(onFrameEvent)
    action:gotoFrameAndPlay(0, false)
    acticon:runAction(action)
end

function GameScene:seekAndSignTile(value)
    for i,v in ipairs(self.tablelist) do
        v:seekAndSignTile(value)
    end
end

function GameScene:resignTile()
    for i,v in ipairs(self.tablelist) do
        v:resignTile()
    end
end


return GameScene