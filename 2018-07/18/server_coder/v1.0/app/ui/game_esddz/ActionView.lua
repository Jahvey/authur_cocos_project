
local ActionView = class("ActionView", require "app.ui.game_base_cdd.ActionView")
function ActionView:init()
    --
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_BUY] = {type =1, sort = 10,img = "gameddz/ddz_btn_text_maipai.png"} -- 买牌
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_SELL]= {type =2,sort = 0,img = "gameddz/ddz_btn_text_bumai.png"}--卖牌
 
end
return ActionView