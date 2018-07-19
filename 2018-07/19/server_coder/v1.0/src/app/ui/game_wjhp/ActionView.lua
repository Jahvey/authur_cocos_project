
local ActionView = class("ActionView", require "app.ui.game.ActionView")
function ActionView:init()
    --
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_ZHAO]= { sort = 2, img = "game/btn_zhao.png" }
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_PENG] = { sort = 2, img = "game/btn_dui.png" }
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_AN_GANG] = { sort = 2, img = "game/btn_zha.png" }
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_GANG] = { sort = 2, img = "game/btn_kaifan.png" }
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_GANG_2] = { sort = 2, img = "game/btn_tachuan.png" }
end
return ActionView