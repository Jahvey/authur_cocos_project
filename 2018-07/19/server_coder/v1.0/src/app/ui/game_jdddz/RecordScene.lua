local RecordScene = class("RecordScene", require "app.ui.game_base_cdd.RecordScene")
function RecordScene:priorityAction(data,hidenAnimation)

    if data.act_type == poker_common_pb.EN_SDR_ACTION_BU_QIANG then
        self.tablelist[data.seat_index + 1]:showBuQiangDiZhu()
        
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
                for i,v in ipairs(self.tablelist) do
                    v:showdizhucleanup()
                end

                self:deleteAction("不抢")
        end)))

        return true
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_QIANG_DI_ZHU then
        self.tablelist[data.seat_index + 1]:showQiangDiZhu()
        
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
                for i,v in ipairs(self.tablelist) do
                    v:showdizhucleanup()
                end

                self:deleteAction("抢地主")
            end)))

        -- 地主icon
        self:setDealerIndex(data.seat_index)
        for i,v in ipairs(self.tablelist) do
            v:hideZhuang()
        end
        self.tablelist[data.seat_index + 1]:showZhuangAction(nil, nil, true)
        for i,v in ipairs(self.tablelist) do
            v:refreshHandTile(false)
        end

        return true
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_JIAO_DI_ZHU then
        -- is_baozi_zhuang：玩家被动成为庄家

        -- 叫地主
        self.tablelist[data.seat_index + 1]:showJiaoDiZhu()
        
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
                for i,v in ipairs(self.tablelist) do
                    v:showdizhucleanup()
                end

                self:deleteAction("叫地主")
            end)))

        -- 地主icon
        self:setDealerIndex(data.seat_index)
        for i,v in ipairs(self.tablelist) do
            v:hideZhuang()
        end
        self.tablelist[data.seat_index + 1]:showZhuangAction(nil, nil, true)
        for i,v in ipairs(self.tablelist) do
            v:refreshHandTile(false)
        end

        return true
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_BU_JIAO then
        self.tablelist[data.seat_index + 1]:showBuJiaoDiZhu()
        
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
                for i,v in ipairs(self.tablelist) do
                    v:showdizhucleanup()
                end

                self:deleteAction("不叫地主")
        end)))

        return true
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_JIA_BEI then
        self.tablelist[data.seat_index + 1]:showJiaBei(true)
        self:deleteAction("加倍")

        return true
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_BU_JIA_BEI then
        self.tablelist[data.seat_index + 1]:showBuJiaBei()
        self:deleteAction("不加倍")

        return true

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_MING_PAI then
        -- self:setHandTileByIdx(data["seat_index"], data["card"])
        self:setMingPaiByIdx(data["seat_index"], 1)

        self.tablelist[data.seat_index + 1]:refreshHandTile()
        self.tablelist[data.seat_index + 1]:showMingPai()
    end

    return false
end
return RecordScene