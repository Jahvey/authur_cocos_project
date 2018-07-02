-------------------------------------------------
--   TODO   用户协议UI
--   @author yc
--   Create Date 2016.10.28
-------------------------------------------------
local UserAgreementView = class("UserAgreementView",PopboxBaseView)
function UserAgreementView:ctor()
	self:initData()
	self:initView()
	self:initEvent()
end
function UserAgreementView:initData()

end

function UserAgreementView:initView()
	self.widget = cc.CSLoader:createNode("ui/popbox/userAgreementView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closeBtn"), function( )
		print("返回大厅")
		LaypopManger_instance:back()
	end)

	self.scrollView = self.mainLayer:getChildByName("scrollView")
	self.content = self.scrollView:getChildByName("content")
	
	-- self.content:setTextAreaSize(cc.size(self.scrollView:getContentSize().width-20,0))
	-- self.scrollView:setInnerContainerSize(cc.size(self.scrollView:getContentSize().width,self.content:getContentSize().height))
	-- self.content:setPositionY(self.content:getContentSize().height-10)

	self.scrollView:setInnerContainerSize(cc.size(self.scrollView:getContentSize().width,self.content:getContentSize().height+50))
	self.content:setPositionY(self.scrollView:getInnerContainerSize().height-20)
	-- self.title:setPositionY(self.scrollView:getInnerContainerSize().height-20)
end

function UserAgreementView:showContent(str)
	self.content:setAnchorPoint(cc.p(0,1))
	self.content:ignoreContentAdaptWithSize(true)
	self.content:setTextAreaSize(cc.size(self.scrollView:getContentSize().width-20,0))
	self.content:setString(str)
	self.content:ignoreContentAdaptWithSize(false)
	self.scrollView:setInnerContainerSize(cc.size(self.scrollView:getContentSize().width,self.content:getContentSize().height))
	self.content:setPositionY(self.content:getContentSize().height-10)
end
function UserAgreementView:initEvent()
end
return UserAgreementView