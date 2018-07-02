
local ShareView = class("ShareView",PopboxBaseView)
function ShareView:ctor()
	self:initView()
end
function ShareView:initData()

end

function ShareView:initView()
	self.widget = cc.CSLoader:createNode("ui/popbox/sharebox.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closebtn"), function( )
		print("返回大厅")
		LaypopManger_instance:back()
	end)

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("fbtn"), function( )
		print("好友")
		CommonUtils.sharegame(0)
	end)
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("pybtn"), function( )
		print("好友")
		CommonUtils.sharegameforpy()
		SHARECALLBACK_FUCN_FOR_ANDROID(0)
	end)
end


return ShareView