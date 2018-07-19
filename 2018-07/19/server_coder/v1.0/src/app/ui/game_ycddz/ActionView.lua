
local ActionView = class("ActionView", require "app.ui.game_base_cdd.ActionView")

function ActionView:init()
 	
	  self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_BUY] = {type =1, sort = 10,img = "gameddz/ddz_btn_text_maipai.png"} -- 买牌
    	self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_SELL]= {type =2,sort = 0,img = "gameddz/ddz_btn_text_bumai.png"}--卖牌
 --不抢

    -- self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_JIA_BEI] = {type =1,sort = 10,img = "gameddz/btn_jiabei.png"} --加倍
    -- self.ACTIONCONF[poker_common_pb.EN_SDR_ACTION_BU_JIA_BEI]= {type =2,sort = 0,img = "gameddz/btn_bujiabei.png"} --不加倍
 
end

function ActionView:showAction(choices)
	self.btnNode:removeAllChildren()
    self.tipstable = nil

	local isjiabeiaction = false
	for i,v in ipairs(choices) do
		if v.act_type == poker_common_pb.EN_SDR_ACTION_JIA_BEI or v.act_type == poker_common_pb.EN_SDR_ACTION_BU_JIA_BEI then
			isjiabeiaction = true
		end
	end
	if isjiabeiaction then
		print("jiabeixuan")
		for i,v in ipairs(choices) do
			print(i,v)
			local btn = ccui.Button:create("game/action_ma"..i..".png")
			 btn:setPositionX((i-(2 + 1) / 2)*200)
			 self.btnNode:addChild(btn)
		 	WidgetUtils.addClickEvent(btn, function()
	            Socketapi.request_do_actionforddz(v.seat_index, v.act_type,v.action_token)
	            self:setVisible(false)
	            self.gamescene.mytable:setIsMyTurn(false)
			end)
		end
	else
		self.super.showAction(self,choices)
	end
	self:setVisible(true)
end

return ActionView