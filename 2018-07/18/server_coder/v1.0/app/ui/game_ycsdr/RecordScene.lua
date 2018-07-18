local RecordScene = class("RecordScene", require "app.ui.game.RecordScene")

function RecordScene:priorityAction(data)
	 if data.act_type == poker_common_pb.EN_SDR_ACTION_WEI then  --自己翻出来的碰为昭
 		self:tableHideEffectnode()
        self:addShowTile(data.seat_index, data.col_info)

        local list = ComHelpFuc.getDeleteDestList(data.col_info,data.dest_card)
        self:deleteHandTile(list,data.seat_index)

        self.tablelist[data.seat_index + 1]:weiPaiAction(data,hidenAnimation)
        return true
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_UPDATE then  --更新out_col
        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            self:deleteHandTile({data.dest_card},data.seat_index)
        end
        -- self.tablelist[data.seat_index+1]:refreshShowTile()
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function() 
            self:deleteAction("更新结束")
        end)))
        return true
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_ZHAO_2 then --4 杠1
        print(".........招牌动画")
        self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            local list = ComHelpFuc.getDeleteDestList(data.col_info,data.dest_card)
            -- if self:getTableConf().ttype == HPGAMETYPE.HFBH then
            --     if data.col_info.is_waichi == true then
            --         list = {}
            --     end
            -- end
            self:deleteHandTile(list,data.seat_index)
        end

        self.tablelist[data.seat_index + 1]:zhaoPaiAction2(data)
        return true
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_PIAO then  
        print("票")
        self:notifyPiao( data )
    end
    return false
end
function RecordScene:notifyPiao( data )

    print("GameScene:notifyPiao( data )")
    printTable(data,"xpp")

    local _score = data.piao_score or 0
    if _score > 0 then
        self:getSeatInfoByIdx(data.seat_index).is_piao = true
    else
        self:getSeatInfoByIdx(data.seat_index).is_piao = false
        _score = 0
    end
    self:getSeatInfoByIdx(data.seat_index).piao_score = _score
    self.tablelist[data.seat_index+1]:setPiao(_score)
    self:deleteAction("更新结束")
    --table.insert(self.actionList, 1,{ act_type = ACTIONTYPEBYMYSELF.DINGZHANG} ) 
end

return RecordScene