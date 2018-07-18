
local ActionView = class("ActionView", require "app.ui.game.ActionView")

function ActionView:init()
    --wai  和 chi  都叫吃
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_CHI]= { sort = 2, img = "game/btn_chi.png" }
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_WAI]= { sort = 2, img = "game/btn_chi.png" }

end


return ActionView