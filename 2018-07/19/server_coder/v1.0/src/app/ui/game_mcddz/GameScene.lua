-- 长牌场景
local GameScene = class("GameScene", require "app.ui.game_base_cdd.GameScene")

function GameScene:priorityAction(data)

	if data.act_type == poker_common_pb.EN_SDR_ACTION_ZHUA_PAI then --麻城是在抓拍里面确定庄家的
        print("抓牌 ---- 翻底牌:"..data.seat_index)
        printTable(data,"xp69")

       	self.mytable:updateDiZhuCards(true,data.col_info.cards) --麻城斗地主所有人都能看到地主牌
        
         --癞子牌设置
        if data.laizi_card then
            LocalData_instance:setLaiZiValuer(data.laizi_card % 16 ) 
            self.mytable:updateLaiZiCards(true,data.laizi_card)
        else
            self.mytable:updateLaiZiCards(true,nil)
        end

        for i,v in ipairs(self.tablelist) do
            v:showdizhucleanup(true)
        --     self.tablelist[i]:refreshHandTile()
        end

        self:setDiZhuCards(data.col_info.cards)
        -- 
        self.tablelist[data.seat_index + 1]:addDizhuCards(data.col_info.cards)
        self.tablelist[data.seat_index + 1]:refreshcardNum()

        self.mytable.actionview:hide()
        
        if data.is_baozi_zhuang then
            self.tablelist[data.seat_index+1]:showBaoZiDIZhu(true)
        end

        local oldDealer = self:getDealerIndex()+1
        local dealerIcon = self.tablelist[oldDealer].icon
        local zhuang = dealerIcon:getChildByName("zhuang"):setVisible(false)--setColor(cc.c3b(0x99, 0x96, 0x96))
        local worldpos = dealerIcon:convertToWorldSpace(cc.p(zhuang:getPositionX(),zhuang:getPositionY()))
       
        self:setDealerIndex(data.seat_index)
        self.mytable:refreshHandTile()

        self.tablelist[data.seat_index+1]:showZhuangAction(function()
            self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
                self:deleteAction("抢庄动画结束！")
            end)))
        end,worldpos)
        return true
    end
    return false
end


return GameScene