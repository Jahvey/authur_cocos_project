local RecordScene = class("RecordScene", require "app.ui.game_base_cdd.RecordScene")
function RecordScene:priorityAction(data,hidenAnimation)

   if data.act_type == poker_common_pb.EN_SDR_ACTION_BUY then --买牌
        print("买牌")
        self.tablelist[data.seat_index + 1]:showjiaodizhu(true)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
            -- self.Suanfuc.laizivalue = data.laizi_card%16
            -- LAIZIVALUE_LOCAL = data.laizi_card%16
            for i,v in ipairs(self.tablelist) do
                v:showdizhucleanup()
                --v:refreshHandTile()
            end

            --self:setDiZhuCards(data.col_info.cards)

            local oldDealer = self:getDealerIndex()+1
            local dealerIcon = self.tablelist[oldDealer].icon
            local zhuang = dealerIcon:getChildByName("zhuang"):setVisible(false)
            local worldpos = dealerIcon:convertToWorldSpace(cc.p(zhuang:getPositionX(), zhuang:getPositionY()))
           
            self:setDealerIndex(data.seat_index)
            self.tablelist[oldDealer]:refreshHandTile()

            self.tablelist[data.seat_index+1]:showZhuangAction(function()
                self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
                    self:deleteAction("抢庄动画结束！")
                end)))
            end,worldpos)


            end)))
        return true
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_SELL then --卖牌
        print("倒")
        self.tablelist[data.seat_index + 1]:showbujiaodizhu(false)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
                self:deleteAction("抢地主地主")
            end)))
        return true

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_NOTIFY_BUY then


        return true
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_JIA_BEI then
        self.tablelist[data.seat_index + 1]:showJiaBei()
        self:deleteAction("加倍")
        return true
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_BU_JIA_BEI then
        self.tablelist[data.seat_index + 1]:showBuJiaBei()
        self:deleteAction("不加倍")
        return true
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_ZHUA_PAI then
        self.Suanfuc.laizivalue = self.Suanfuc:getrealvalue(data.laizi_card%16)
        LAIZIVALUE_LOCAL = data.laizi_card%16
        self.tablelist[data.seat_index + 1]:addDizhuCards(data.col_info.cards)
        self.tablelist[data.seat_index + 1]:refreshcardNum()
        for i,v in ipairs(self.tablelist) do
            --v:showdizhucleanup()
            v:refreshHandTile()
        end

        -- print("抓牌 ---- 翻底牌:"..data.seat_index)
        self.mytable:updateDiZhuCards(true,data.col_info.cards)
        self:setDiZhuCards(data.col_info.cards)

        self:deleteAction("抓牌动画结束！")
        return true
    end
    return false
end
return RecordScene