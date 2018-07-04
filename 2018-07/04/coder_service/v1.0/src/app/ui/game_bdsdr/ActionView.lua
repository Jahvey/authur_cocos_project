
local ActionView = class("ActionView", require "app.ui.game.ActionView")
function ActionView:init()

  	self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_ZHAO]= { sort = 2, img = "game/btn_mao.png" }
  	self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_PENG]= { sort = 2, img = "game/btn_ding.png" }

end
return ActionView