
local ActionView = class("ActionView", require "app.ui.game_base_cdd.ActionView")

function ActionView:init()
 	
	self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_GIVE_UP] = {type =2, sort = 10,img = "gameddz/ddz_btn_tou.png"} -- 买牌
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_NOT_GIVE_UP]= {type =1,sort = 0,img = "gameddz/ddz_btn_butou.png"}--卖牌

    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_LIANG_NIU] = {type =1, sort = 10,img = "gameddz/ddz_btn_liang.png"} -- 买牌
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_NOT_LIANG_NIU]= {type =2,sort = 0,img = "gameddz/ddz_btn_buliang.png"}--卖牌


end
--is_first_chu_pai
function ActionView:isfirstchupai(cards)
	-- body
end
return ActionView