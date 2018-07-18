local DemonMode = class("DemonMode")

function DemonMode:ctor(gamescene)
	local tip = ccui.ImageView:create("game/tip.png")
		:addTo(gamescene)
		:setPosition(cc.p(display.cx,display.cy))

	tip:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.FadeOut:create(1),cc.CallFunc:create(function ()
		tip:removeFromParent()
	end)))

	self:overRideFunc(gamescene)
end

function DemonMode:overRideFunc(gamescene)
	gamescene.UILayer.topbg:setVisible(false)
	local newtop = cc.CSLoader:createNode("ui/game/topnode_demonmode.csb")
		:addTo(gamescene.UILayer.topbg:getParent())
		:setPosition(cc.p(gamescene.UILayer.topbg:getPositionX(),gamescene.UILayer.topbg:getPositionY()))
	gamescene.UILayer.topbg = newtop
	gamescene.UILayer:initTopInfo(0)
	gamescene.UILayer.topbg.loadTexture = function ()
	end
	gamescene.getTableCreaterID = function ()
		return -1
	end

	for i, v in ipairs(gamescene.tablelist) do
        v:refreshSeat()
    end

    WidgetUtils.addClickEvent(gamescene.UILayer.invitebtn, function()
        -- CommonUtils:prompt("暂未开放，敬请期待", CommonUtils.TYPE_CENTER)
        CommonUtils.sharedesk("试玩场", GT_INSTANCE:getTableDes(gamescene:getTableConf(), 2),gamescene:getTableConf().ttype)
    end)

	local setbgstype_p = gamescene.UILayer.setbgstype
	function gamescene.UILayer:setbgstype(bg_type)
	 	setbgstype_p(gamescene.UILayer,bg_type)
	 	print("=============DemonMode")
	end 

	function gamescene:getTableConf()
		self.table_info.sdr_conf.pay_type = -1
	    return self.table_info.sdr_conf
	end

	local NotifyLogoutTable_p = gamescene.NotifyLogoutTable
	function gamescene:NotifyLogoutTable(data)
		print("=========logout")
		printTable(data,"xp")
		if data.seat_index == self:getMyIndex() then
			glApp:enterSceneByName("MainScene")
			return
		end
		NotifyLogoutTable_p(gamescene,data)
		
	end

	ComNoti_instance:addEventListener("cs_notify_logout_table", gamescene, gamescene.NotifyLogoutTable)
end

return DemonMode