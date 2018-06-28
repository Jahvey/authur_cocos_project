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

	self.text = self.mainLayer:getChildByName("text")
	self.text:setString("")
end
function MessageView:initEvent()
	ComNoti_instance:addEventListener("3;1;5",self,self.releasecall)
end
function MessageView:onEndAni(  )
	Socketapi.sendggaomsg()
end
function MessageView:releasecall(data )
	self.text:setString(data.content)
end
return MessageView