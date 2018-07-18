local RecordScene = class("RecordScene", require "app.ui.game_base_cdd.RecordScene")
function RecordScene:priorityAction(data,hidenAnimation)

    if data.act_type == poker_common_pb.EN_SDR_ACTION_BUY then --买牌
        if  hidenAnimation ~= nil  then
            self.tablelist[data.seat_index + 1]:showjiaodizhu(true)
            for i,v in ipairs(self.tablelist) do
                v:showdizhucleanup()
            end
            local oldDealer = self:getDealerIndex()+1
            local dealerIcon = self.tablelist[oldDealer].icon
            local zhuang = dealerIcon:getChildByName("zhuang"):setVisible(false)
            self:setDealerIndex(data.seat_index)
            self.tablelist[oldDealer]:refreshHandTile()

            self.tablelist[data.seat_index+1]:showZhuangAction(function()
            end,worldpos,hidenAnimation)
        else
            self.tablelist[data.seat_index + 1]:showjiaodizhu(true)
            self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
                for i,v in ipairs(self.tablelist) do
                    v:showdizhucleanup()
                end
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
        end
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
    end
    return false
end
return RecordScene