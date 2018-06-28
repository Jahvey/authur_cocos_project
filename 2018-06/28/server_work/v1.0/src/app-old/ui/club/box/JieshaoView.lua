local JieshaoView = class("JieshaoView",PopboxBaseView)

function JieshaoView:ctor()
	
	self:initView()
	
end
function JieshaoView:initView()
	local widget = cc.CSLoader:createNode("ui/club/smallbox/CluedescView.csb")
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")

	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		
		LaypopManger_instance:back()
	end)

	

	--Socketapi.requestmsgclube(self.tid)
end

return JieshaoView