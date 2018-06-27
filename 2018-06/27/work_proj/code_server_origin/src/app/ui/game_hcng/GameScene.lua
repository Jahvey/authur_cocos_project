
local GameScene = class("GameScene", require "app.ui.game_base_cdd.GameScene")
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
    self.Suanfuc.laizivalue = -1
    self.Suanfuc.isfivelai = false
    if self:getTableConf().laizi_num == 5 then
        self.Suanfuc.isfivelai = true
    end

end
function GameScene:priorityAction(data)

    if data.act_type == poker_common_pb.EN_SDR_ACTION_GIVE_UP then --买牌
       
        self:deleteAction("抓牌动画结束！")
        return true
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_NOT_GIVE_UP then --买牌
        self:deleteAction("抓牌动画结束！")
        return true
        
     elseif data.act_type == poker_common_pb.EN_SDR_ACTION_LIANG_NIU then --买牌
        self.tablelist[data.seat_index + 1]:showniu(data.col_info.niu_gui_index)
        self:deleteAction("抓牌动画结束！")
        return true
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
        if data.col_info.niu_gui_index then
            self.tablelist[data.seat_index + 1]:showniu(data.col_info.niu_gui_index)
        end

        self:deleteHandTile(data.cards,data.seat_index)
        self.tablelist[data.seat_index + 1]:refreshcardNum()
        if self:getMingPai() then
            self.tablelist[data.seat_index + 1]:refreshHandTile()
        end
        return true
    end

    return false
end


return GameScene