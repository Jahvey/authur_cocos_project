local RecordScene = class("RecordScene", require "app.ui.game.RecordScene")

function RecordScene:RecordScene(data)
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
    end
    return false
end


return RecordScene