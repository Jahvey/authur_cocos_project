-------------------------------------------------
--   TODO   消息UI
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local MessageView = class("MessageView",PopboxBaseView)
function MessageView:ctor()
	self:initData()
	self:initView()
	self:initEvent()
end
function MessageView:initData()

end
function MessageView:initView()
	self.widget = cc.CSLoader:createNode("ui/popbox/messageView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closeBtn"), function( )
		print("返回大厅")
		LaypopManger_instance:back()
	end)

	self.scrollView = self.mainLayer:getChildByName("scrollView")
	self.content = self.scrollView:getChildByName("content")

	self.scrollView:setInnerContainerSize(cc.size(self.scrollView:getContentSize().width,self.content:getContentSize().height+50))
	self.content:setPositionY((self.scrollView:getInnerContainerSize().height)/2+90)
end
function MessageView:initEvent()
end
return MessageView