-- 长牌场景
local GameScene = class("GameScene", require "app.ui.game_base_cdd.GameScene")

function GameScene:priorityAction(data)

    if data.act_type == poker_common_pb.EN_SDR_ACTION_BUY then --买牌
        print("倒")
        self.tablelist[data.seat_index + 1]:showjiaodizhu(true)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
            for i,v in ipairs(self.tablelist) do
                v:showdizhucleanup()
            end

            self:setDiZhuCards(data.col_info.cards)

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
    end
    return false
end


return GameScene