
local ActionView = class("ActionView", require "app.ui.game_base_cdd.ActionView")

function ActionView:init()
 	
	self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_QIANG_DI_ZHU] = {type =1,sort = 10,img = "gameddz/ddz_btn_text_qiangdizhu.png"} --抢地主
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_BU_QIANG] = {type =2,sort = 0,img = "gameddz/ddz_btn_text_buqiang.png"} --不抢

    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_JIA_BEI] = {type =1,sort = 10,img = "gameddz/btn_jiabei.png"} --加倍
    self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_BU_JIA_BEI]= {type =2,sort = 0,img = "gameddz/btn_bujiabei.png"} --不加倍
 
end

return ActionView