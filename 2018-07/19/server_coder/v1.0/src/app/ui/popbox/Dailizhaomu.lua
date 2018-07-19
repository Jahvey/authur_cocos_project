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
		CommonUtils.copyTo("jrhp007")
	end)

	WidgetUtils.addClickEvent(mainLayer:getChildByName("btn_close"), function( )
		LaypopManger_instance:back()
	end)

end
function Dailizhaomu:initEvent()
end
return Dailizhaomu