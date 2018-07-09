-------------------------------------------------
--   TODO   购买卡弹框UI
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local CardPromptBoxView = class("CardPromptBoxView",PopboxBaseView)
function CardPromptBoxView:ctor()
	self:initData()
	self:initView()
	self:initEvent()
end

function CardPromptBoxView:initData()

end

function CardPromptBoxView:initView()
	self.widget = cc.CSLoader:createNode("ui/popbox/cardPromptBoxView.csb")
	self:addChild(self.widget)	

	self.mainLayer = self.widget:getChildByName("main")
	-- self.tip1 = self.mainLayer:getChildByName("tip1")
	-- self.tip2 = self.mainLayer:getChildByName("tip1")
	-- self.tip3 = self.mainLayer:getChildByName("tip1")
	-- self.tip1:setString("房卡购买请联系")
	-- self.tip2:setString("代理加盟请联系")
	-- self.tip3:setString("投诉建议与举报")

	-- self.value1 = self.mainLayer:getChildByName("value1")
	-- self.value2 = self.mainLayer:getChildByName("value2")
	-- self.value3 = self.mainLayer:getChildByName("value3")

	-- self.value1:setString("")
	-- self.value2:setString("")
	-- self.value3:setString("")

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closeBtn"), function( )
		LaypopManger_instance:back()
	end)
end

function CardPromptBoxView:setValue()
	self.value1:setString("微信号：ttddp666")
	self.value2:setString("微信号：ttddp666")
	self.value3:setString("微信号：ttddp666")
end
function CardPromptBoxView:initEvent()
	--self:setValue()
end

return CardPromptBoxView