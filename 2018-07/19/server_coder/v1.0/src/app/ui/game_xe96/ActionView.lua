
local ActionView = class("ActionView", require "app.ui.game_poker.ActionView")

function ActionView:init()
	self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_WAI]= { sort = 2, img = "game/btn_wai.png" }
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_PAO]= { sort = 2, img = "game/btn_xiazhua.png" }
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_CHI] = { sort = 2, img = "game/btn_chi.png" }
end

return ActionView