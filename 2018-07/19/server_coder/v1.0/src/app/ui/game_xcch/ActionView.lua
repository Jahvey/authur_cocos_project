
local ActionView = class("ActionView", require "app.ui.game.ActionView")

function ActionView:init()
    --
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_ZHAO]= { sort = 2, img = "game/btn_gang.png" }
end
return ActionView