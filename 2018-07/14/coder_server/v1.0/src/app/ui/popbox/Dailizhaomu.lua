-------------------------------------------------
--   TODO   代理招募
--   @author xp
--   Create Date 2018.6.25
-------------------------------------------------
local Dailizhaomu = class("Dailizhaomu",PopboxBaseView)
function Dailizhaomu:ctor()
	self:initData()
	self:initView()
	self:initEvent()
end
function Dailizhaomu:initData()

end
function Dailizhaomu:initView()
	self.widget = cc.CSLoader:createNode("ui/dailizhaomu/dailizhaomu.csb")
	self:addChild(self.widget)

	local mainLayer = self.widget:getChildByName("main")

	WidgetUtils.addClickEvent(mainLayer:getChildByName("btn_copy"), function( )
		userdata={}
		userdata.cid=10
		userdata.pid=92
		userdata.json={
			["type"]="10.复制微信客服号"

	    }
	    CommonUtils.sends(userdata)

		CommonUtils.copyTo("jrpk007")
	end)

	WidgetUtils.addClickEvent(mainLayer:getChildByName("btn_close"), function( )
		LaypopManger_instance:back()
	end)

end
function Dailizhaomu:initEvent()
end
return Dailizhaomu