-- 长牌场景
local GameScene = class("GameScene", require "app.ui.game.base.BaseGameScene")
require "app.help.ComNoti"
require "app.help.WidgetUtils"



function GameScene:initView()
    self.name = "GameScene"
    print("=====GameScene:initView")
    self.layout = cc.CSLoader:createNode("ui/game/gameBasenew.csb")
    self:addChild(self.layout)
    WidgetUtils.setScalepos(self.layout)
     --WidgetUtils.setScalepos(self.layout:getChildByName(""))
    self.UILayer = require("app.ui.game.base.GameUILayer").new(self)
    :addTo(self.layout:getChildByName("UInode"))
    :setPosition(cc.p(0, 0))


    self:initDataBySelf()

    self:initTable()
    self:refreshScene()
    self:setbgstype()
end

function GameScene:initDataBySelf()
    self.voicelist = { }

    self.isRunning = false
    -- 添加一个房间开始的等待动画
    self.actionList = { { act_type = ACTIONTYPEBYMYSELF.CREATE_CARD } }

    self.allResultData = nil
    self.chuPaiIndex = -1
    self.display_anpai = false

    -- self:setRestTileNum(0)

    self.lastAct = nil

    self.myDedugList = {}


    table.insert(self.myDedugList,"tableId:"..self:getTableID())
    table.insert(self.myDedugList,"round:"..self:getNowRound()+1)
    table.insert(self.myDedugList,"useId:"..LocalData_instance:getUid())
end

function GameScene:initTable()
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
        print("............i = ", i)
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
        state == poker_common_pb.EN_TABLE_STATE_WAIT_MAI_PAI or 
        state == poker_common_pb.EN_TABLE_STATE_WAIT_AN_PAI or
        state == poker_common_pb.EN_TABLE_STATE_WAIT_BAO_PAI or
        state == poker_common_pb.EN_TABLE_STATE_WAIT_PIAO
        then 

        self.display_anpai = self.table_info.display_anpai
        self:setRestTileNum(self.table_info.left_card_num)
        self.UILayer:refreshInfoNode()

        self:setJiangCard(self.table_info.jiang_card)
        self.UILayer:setJiangCard(self.table_info.jiang_card)


        if  self.table_info.joker_card then
            self:setJokerCard(self.table_info.joker_card)
            self.UILayer:setJokerCard(self.table_info.joker_card)
        end
        if state == poker_common_pb.EN_TABLE_STATE_WAIT_PIAO then
            local oldData = clone(self.table_info)
            for k,v in pairs(self.table_info.sdr_seats) do
                v.hand_cards = {}
                v.ding_zhang_card = nil
            end
            self.localdingzhuang_sdr = oldData
            self.localdata_sdr = clone(oldData)
            for i,v in ipairs(self.localdata_sdr) do
                v.ding_zhang_card = nil
            end
            self:setSeatsInfo(self.table_info.sdr_seats)
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

            if self:getTableConf().ttype == HPGAMETYPE.HFBH  then 
                print("...............self.table_info.need_show = ",self.table_info.need_show)
                print("...............self.table_info.fanpai_index = ",self.table_info.fanpai_index)
                print("...............self:getMyIndex() = ",self:getMyIndex())
                if (self.table_info.need_show or self.table_info.fanpai_index == self:getMyIndex()) and self.table_info.is_mopai then
                    _data.act_type = poker_common_pb.EN_SDR_ACTION_SHOW
                    ishidden_HB = true
                    self:addAction(_data)
                end
            end
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

                --百胡
               if self:getTableConf().ttype == HPGAMETYPE.HFBH then
                    --百胡的抓是没有牌的
                    if  v.act_type == poker_common_pb.EN_SDR_ACTION_ZHUA or 
                        v.act_type == poker_common_pb.EN_SDR_ACTION_TUO or 
                        v.act_type == poker_common_pb.EN_SDR_ACTION_DA then
                        ishidden_HB = true
                    end
                end
            end

            if ischuData then
                self:addAction( { act_type = ACTIONTYPEBYMYSELF.MYTURN_CHU, data = ischuData })
            else
                if self:getTableConf().ttype == HPGAMETYPE.HFBH and ishidden_HB == false then
                    print("--百胡里面，如果牌是扣着的，就不显示操作按钮")
                else 
                    self:addAction( { act_type = ACTIONTYPEBYMYSELF.MYTURN, data = actionchoice })
                end
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
    self:setSeatsInfo(dss_seats)
    for k, v in pairs(dss_seats) do
        self.tablelist[v.index + 1]:resetData()
        self.tablelist[v.index + 1]:refreshSeat(v)
    end
    self.UILayer:waitGameStart()
    self.isRunning = false
    self.actionList = { { act_type = ACTIONTYPEBYMYSELF.CREATE_CARD } }
    self.chuPaiIndex = -1
    self.display_anpai = false

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
    local infoStr = ""
    print("addDebugList")
    print(info)
    if  type(info) == "table" then 
        infoStr = self:printTable(info)
        print("infoStr")
    end
    table.insert(self.myDedugList,_str..":"..infoStr)
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
    printTable(data, "xp69")

    self:setDealerIndex(data.dealer)
    self:setXiaoJiaIndex(data.xiaojia_index)

    
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

function GameScene:setGameBegin(ischong)
    print(debug.traceback("", 2))
    for i, v in ipairs(self.tablelist) do
        print(".......................牌局游戏开始～",i)
        v:gameStartAction(ischong)
    end
end


-- 背景 根据设置选择及时更换
function GameScene:setbgstype()
    local typestylse = cc.UserDefault:getInstance():getIntegerForKey("bg_type", 3)
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
function GameScene:showpeiResult(data)
    LaypopManger_instance:PopBox("SingleResultView", data, self, 1)
    for i,v in ipairs(self:getSeatsInfo()) do
        v.is_piao = nil
        v.has_kou_pai = nil
        v.piao_score = 0
    end
    self:setOldDealerIndex(-1)
    self:setRestTileNum(0)
    self:setJiangCard(0)
    self.UILayer:setJiangCard(0)

    self:setJokerCard(0)
    self.UILayer:setJokerCard(0)

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
    printTable(data, "123")

    -- printInfo("[GameScene] NotifySeatOperationChoice")
    -- printTable(data)

    -- self.mytable:setIsMyTurn(true)
    local ischuData = nil
    for k, v in pairs(data.sdr_choices) do
        v.action_token = data.action_token
        if v.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI or 
            v.act_type == poker_common_pb.EN_SDR_ACTION_PRE_CHUPAI then
            ischuData = v
        end
    end

    if ischuData  then
        self:addAction( { act_type = ACTIONTYPEBYMYSELF.MYTURN_CHU, data = ischuData })
    else
        self:addAction( { act_type = ACTIONTYPEBYMYSELF.MYTURN, data = data.sdr_choices })
    end

end

function GameScene:ResponseDoAction(data)
    -- print("...................ResponseDoAction ")
    printTable(data,"123")

    if data["result"] == 0 then
        if data["action"] and data["action"]["act_type"] == poker_common_pb.EN_SDR_ACTION_DA then
                -- 删除所有 da 的
                local tmpActionList = clone(self.actionList)
                self.actionList = {}
                local remove = false
                for i, v in ipairs(tmpActionList) do
                    if v["act_type"] == ACTIONTYPEBYMYSELF.MYTURN and v["data"] then
                        for i2, v2 in ipairs(v["data"]) do
                            if v2["act_type"] == poker_common_pb.EN_SDR_ACTION_DA and (v2["seat_index"] == data["action"]["seat_index"]) then
                                remove = true
                            end
                        end
                    end

                    if not remove then
                        table.insert(self.actionList, clone(v))
                    end
                end
        end
    end    

    self:deleteAction("ResponseDoAction")
end

function GameScene:NotifyActionFlow(data)

    print(".......................GameScene:NotifyActionFlow ")
    printTable(data,"123")
    if not data.new_sdr_action_flow then
        return
    end

    if data["new_sdr_action_flow"]["action"]["act_type"] == poker_common_pb.EN_SDR_ACTION_ZHUA then  --下抓

        self:addXiaZhua(data["new_sdr_action_flow"]["action"]["seat_index"])        

        for i, v in ipairs(self:getSeatsInfo()) do
            self.tablelist[v.index+1]:refreshXiaZhua(v)
        end

        return
    end

    -- 如果 我还有 操作列表，没取消的话，
    if self.mytable.actionview:getIsShow() then
        self.mytable.actionview:hide()
        table.remove(self.actionList, 1)
        self.isRunning = false
    end

    local action = data.new_sdr_action_flow.action
    self:addAction(action)
end

-- 显示暗的牌
function GameScene:showAnCardAction(display_anpai)

    print(".............是否要显示暗的牌 ", display_anpai)

    if display_anpai and self.display_anpai == false then

        self.display_anpai = display_anpai

        for k, v in pairs(self.tablelist) do
            v:refreshShowTile()
            v:updataHuXiText()
        end
    end
end
function GameScene:getIsDisplayAnpai()

    return self.display_anpai
end



function GameScene:deleteAction(_str)

    print("----------------------------------deleteAction--- _str = ", _str)
     if self.lastAct and self.lastAct.seat_index  and self.lastAct.seat_index == self:getMyIndex() then
        self:addDebugList("delete",{from = _str})
    end

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

    if not self.isRunning then
        local info = self.actionList[1]
        if info then
            self:doAction(info, "addAction")
        end
    end
end


-- 操作动画相关
function GameScene:doAction(data, _str)


    self.lastAct = data

    print("............doAction")
    printTable(data,"xp69")

    -- if  data.col_info and data.col_info.token then
    --     if  self:getIsChongFuAdd(data.seat_index,data.col_info)  then
    --         self:deleteAction("重复添加")
    --         return
    --     end
    -- end
    
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

    self.isRunning = true

    if data.act_type < 100 and data.seat_index and  data.seat_index == self:getMyIndex() and data.act_type~=poker_common_pb.EN_SDR_ACTION_PIAO then
        print("data.act_type:"..data.act_type)
        self.mytable:setBanedCardsList(data.baned_cards or {} ) --设置我不能打的牌
    end

    if self:priorityAction(data) then

    elseif  data.act_type == ACTIONTYPEBYMYSELF.BIPAI then
        self:biPaiAction(data.data)
    elseif  data.act_type == ACTIONTYPEBYMYSELF.CREATE_CARD then
        -- 为了 延迟等待创建牌的动画结束 再播放操作动画而加的延迟
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create( function()
            -- print
            self:deleteAction("创建牌的动画结束")
        end )))
    elseif data.act_type == ACTIONTYPEBYMYSELF.NEXT_OPERATION then
        -- 轮到谁操作，的那个闹钟的显示与倒计时

        self:setRestTileNum(data.left_card_num)
        self.UILayer:refreshInfoNode()
        self.UILayer:setOpertip(data.operation_index)

        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create( function()
            self:deleteAction("轮到谁操作")
        end )))
    elseif data.act_type == ACTIONTYPEBYMYSELF.MYTURN then

        self.mytable:setIsMyTurn(true)
        self.mytable:showActionView(data.data)

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

        -- local cards = self:getHandTileByIdx(self:getMyIndex())
        -- if cards and #cards%2 == 1 then
        --     self:addDebugList("chu",{num = #cards,str = "手牌的数量不对"})
        --     self:uploadDebugList()
        -- end
    elseif data.act_type == ACTIONTYPEBYMYSELF.GAMEOVER then
        self:showpeiResult(data.data)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_CHUPAI then
        print(".........出牌动画，等待玩家操作，明牌")
        data.func = function()
            self:showAnCardAction(data.display_anpai)
        end
        if data.ischong then
        else
            self:deleteHandTile( { data.dest_card }, data.seat_index)
        end
        self.chuPaiIndex = data.seat_index
        self.tablelist[data.seat_index + 1]:chuPaiAction(data)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_PRE_CHUPAI then
        print(".........预出牌动画，等待玩家操作，明牌")
        data.func = function()
            self:showAnCardAction(data.display_anpai)
        end
        if data.ischong then
        else
            self:deleteHandTile( { data.dest_card }, data.seat_index)
        end
        self.chuPaiIndex = data.seat_index
        self.tablelist[data.seat_index + 1]:chuPaiAction(data)



    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_NAPAI then
        print(".........翻牌动画，等待玩家操作，翻的是 ", data.dest_card)

        data.func = function()
            self:showAnCardAction(data.display_anpai)
        end

        self:setRestTileNum(data.left_card_num)
        self.UILayer:refreshInfoNode()
        self.chuPaiIndex = data.seat_index
        self.tablelist[data.seat_index + 1]:fanPaiAction(data)

        -- local cards = self:getHandTileByIdx(self:getMyIndex())
        -- if cards and #cards%2 == 0 then
        --     self:addDebugList("翻牌",{num = #cards,str = "手牌的数量不对"})
        --     self:uploadDebugList()
        -- end

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
        self.tablelist[data.seat_index + 1]:chiPaiAction(data)

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


        self.tablelist[data.seat_index + 1]:waiPaiAction(data)
        -- self.mytable:setBanedCardsList(data.baned_cards or {}) --设置我不能打的牌

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

        self.tablelist[data.seat_index + 1]:pengPaiAction(data)

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

        self.tablelist[data.seat_index + 1]:weiPaiAction(data)

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

        self.tablelist[data.seat_index + 1]:paoPaiAction(data)

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
        self.tablelist[data.seat_index + 1]:tiPaiAction(data)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_KUA then --跨
        print(".........提牌动画")
        self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        elseif data.col_info.is_waichi == nil or data.col_info.is_waichi == false then
            self:deleteHandTile(data.col_info.cards,data.seat_index)
        end

        self.tablelist[data.seat_index + 1]:kuaPaiAction(data)

     elseif data.act_type == poker_common_pb.EN_SDR_ACTION_SHANG_SHOU then
        print(".........")
        self:addHandTile(data.seat_index, data.dest_card)
        self.tablelist[data.seat_index + 1]:shangShouAction(data)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_OUT_CARD then
        print(".........翻牌和出牌动画后，无玩家操作，把牌加到出牌位，明牌")
        printTable(data)

        if self:getTableConf().ttype == HPGAMETYPE.ESSH or self:getTableConf().ttype == HPGAMETYPE.XESDR or self:getTableConf().ttype == HPGAMETYPE.XFSH then
            if data.is_napai then 
                self:addDisardTile(data.seat_index, data.dest_card)
            else
                self:addPutoutTile(data.seat_index, data.dest_card)
            end
        else
            self:addPutoutTile(data.seat_index, data.dest_card)
        end
        
        self.chuPaiIndex = -1
        self.tablelist[data.seat_index + 1]:outCardAction(data)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_HUPAI then
        print(".........胡牌动画")
        self:addHandTile(data.seat_index, data.dest_card)
        self.tablelist[data.seat_index + 1]:huPaiAction(data)
    
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_XIAO_HU then
        print("....EN_SDR_ACTION_XIAO_HU.....胡牌动画")
        printTable(data,"xpjs")

        -- self.
        self.tablelist[data.seat_index + 1]:xiaoHuPaiAction(data)
         self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create( function()
            self:deleteAction("笑胡了")
        end )))

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_QI_HU then
        print(".........胡牌动画")
        self.tablelist[data.seat_index + 1]:qiHuPaiAction(data)
         self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create( function()
            self:deleteAction("弃胡了")
        end )))
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_BAO then
        print(".........报")
        self.tablelist[data.seat_index+1]:baoPaiAction(data)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function() 
            self:deleteAction("报牌结束")
        end)))

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_UPDATE then  --更新out_col
        print(".........更新out_col")
        self:addShowTile(data.seat_index, data.col_info)
        -- self.tablelist[data.seat_index+1]:refreshShowTile()
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function() 
            self:deleteAction("更新结束")
        end)))
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_QIANG_ZHUANG then

        local dealerIcon = self.tablelist[self:getDealerIndex()+1].icon
        local zhuang = dealerIcon:getChildByName("zhuang"):setColor(cc.c3b(0x99, 0x96, 0x96))
        local worldpos = dealerIcon:convertToWorldSpace(cc.p(zhuang:getPositionX(), zhuang:getPositionY()))

        self:setOldDealerIndex(self:getDealerIndex())
        self:setDealerIndex(data.seat_index)

        self.tablelist[data.seat_index+1]:showZhuangAction(function()
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function() 
                self:deleteAction("抢庄动画结束！")
            end)))
            for ii,vv in ipairs(self.tablelist) do
                vv:setIsShowHuaZhuang(false)
            end
        end,worldpos)
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

        self.tablelist[data.seat_index + 1]:zhaoPaiAction(data)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_DENG then --巴杠为登
        print(".........登牌动画")
        self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            if self:getTableConf().ttype == HPGAMETYPE.YSGSDR or 
                self:getTableConf().ttype == HPGAMETYPE.JSCH or 
                self:getTableConf().ttype == HPGAMETYPE.ESCH then 
            else
                local deleteList = data.col_info.cards
                self:deleteHandTile(deleteList,data.seat_index)
            end
        end
        self.tablelist[data.seat_index + 1]:dengPaiAction(data)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_KOU then --不打了，放弃了，把玩家所有手牌设置为灰色
        print(".........弃牌动画")
        self:getSeatInfoByIdx(data.seat_index).has_kou_pai = true
        self.tablelist[data.seat_index + 1]:yangAction(data)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_SHOW then 
        self.tablelist[data.seat_index + 1]:showPaiAction(data)
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_TOU then  --偷牌

        self:setRestTileNum(self:getRestTileNum() -1)
        self.UILayer:refreshInfoNode()

        self:addHandTile(data.seat_index, data.dest_card)
        self.tablelist[data.seat_index + 1]:touPaiAction(data)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_TUO then --拖牌
        print(".........拖牌")
        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            self:deleteHandTile({data.dest_card},data.seat_index)
        end
        self.tablelist[data.seat_index + 1]:tuoPaiAction(data)

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_LIANG_LONG then 
        print(".........亮拢动画")

        -- local _data = {}
        data.bao_info = {}
        table.insert(data.bao_info,{bao_type = 100}) --添加亮拢的报

        self:setLongCard(data.seat_index,data.dest_card)
        self.tablelist[data.seat_index+1]:updataHuXiText()
        self.tablelist[data.seat_index+1]:baoPaiAction(data)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function() 
            self:deleteAction("报牌结束")
        end)))
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_TIAN then 
        print(".........填，也就是杠 动画")    
        self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        end
        self.tablelist[data.seat_index + 1]:tianPaiAction(data)

 elseif data.act_type == poker_common_pb.EN_SDR_ACTION_MAI then --卖赖子
        print(".........卖癞子")
        -- self:deleteAction("卖癞子")

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