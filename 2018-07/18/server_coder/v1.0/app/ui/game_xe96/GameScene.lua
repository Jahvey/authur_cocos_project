-- 长牌场景
local GameScene = class("GameScene", require "app.ui.game_poker.GameScene")
-- 背景 根据设置选择及时更换
function GameScene:setbgstype()
    local typestylse = cc.UserDefault:getInstance():getIntegerForKey("bg_type_poker", 1)
    -- 界面变化
    self.UILayer:setbgstype(typestylse)
    -- 牌变化
    for k, v in pairs(self.tablelist) do
        v:setbgstype(typestylse)
    end
end

function GameScene:initTable()
    local tableBase = require(self.path .. ".GameTable")
    local gameAction = require(self.path .. ".ActionView")

    local bottomtable = require("app.ui.game_xe96.TableBottom").create(require("app.ui.game_poker.TableBottom").create(tableBase, gameAction),gameAction).new(self.layout:getChildByName("bottomnode"), self)
    local toptable = require("app.ui.game_xe96.TableTop").create(require("app.ui.game_poker.TableTop").create(tableBase)).new(self.layout:getChildByName("topnode"), self)
    local lefttable = require("app.ui.game_xe96.TableLeft").create(require("app.ui.game_poker.TableLeft").create(tableBase)).new(self.layout:getChildByName("leftnode"), self)
    local righttable = require("app.ui.game_xe96.TableRight").create(require("app.ui.game_poker.TableRight").create(tableBase)).new(self.layout:getChildByName("rightnode"), self)

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

--有些需要特殊重载,优先处理，并返回是否跳过后面的
function GameScene:priorityAction(data)
	if data.act_type == poker_common_pb.EN_SDR_ACTION_OUT_CARD then
        print(".........翻牌和出牌动画后，无玩家操作，把牌加到出牌位，明牌")
        printTable(data)

        if self:getTableConf().seat_num == 3 then
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
        return true
    end

	return self.super.priorityAction(self,data)
end

return GameScene