local RecordScene = class("RecordScene", require "app.ui.game.RecordScene")

function RecordScene:priorityAction(data,hidenAnimation)

     if data.act_type == poker_common_pb.EN_SDR_ACTION_CHU then  --出
        self:getSeatInfoByIdx(data.seat_index).chu_score = data.dest_card
        self.tablelist[data.seat_index+1]:setChuFen(data.dest_card,hidenAnimation)
        return true
    end

    return false
end

return RecordScene