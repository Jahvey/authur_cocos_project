-------------------------------------------------
--   TODO   帮助UI
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local HelpView = class("HelpView",PopboxBaseView)
function HelpView:ctor(type)
	self.type = type
	self:initData()
	self:initView()
	self:initEvent()
end
function HelpView:initData()

end

function HelpView:initView()
	if self.type == 2 then
		self.widget = cc.CSLoader:createNode("ui/popbox/helpView1.csb")
	else
		self.widget = cc.CSLoader:createNode("ui/popbox/helpView.csb")
	end
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closeBtn"), function( )
		print("返回大厅")
		LaypopManger_instance:back()
	end)

end

function HelpView:initEvent()
end
return HelpView