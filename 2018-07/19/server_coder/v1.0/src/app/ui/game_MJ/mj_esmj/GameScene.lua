-- 长牌场景
local GameScene = class("GameScene", require "app.ui.game_MJ.game_base.GameScene")


function GameScene:priorityAction(data)

	if data.act_type == poker_common_pb.EN_SDR_ACTION_GANG_2 then
        print(".........癞子杠，痞子杠 牌动画")
        self:addShowCard(data)
        self:deleteHandCard(data)

        self.tablelist[data.seat_index + 1]:gang2PaiAction(data)
		
		return true
	end
    return false
end



return GameScene