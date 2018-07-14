local PrizeListView = class("PrizeListView1",PopboxBaseView)
function PrizeListView:ctor(data,headnode)
	self.headnode = headnode
	self.data = data
	self:initView()
end
function PrizeListView:initView(typ)
	self.widget = cc.CSLoader:createNode("newyear/PrizeListView1.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("close"), function( )
		LaypopManger_instance:back()
	end)

	self.mainLayer:getChildByName("pic0"):setVisible(false)
	self.mainLayer:getChildByName("pic1"):setVisible(false)
	self.mainLayer:getChildByName("pic"..self.data.itemtype):setVisible(true)

end

function PrizeListView:refreshView(data)
	local infonode = self.mainLayer:getChildByName("infonode")

	local headicon = infonode:getChildByName("headicon")
	local name = infonode:getChildByName("name")
	local id = infonode:getChildByName("id")

	local tip1 = infonode:getChildByName("tip1")
	local tip2 = infonode:getChildByName("tip2")
	
	tip1:setString("恭喜获得IPHONE8一台")
	tip2:setString("请在十日内联系客服领取奖励")
end

function PrizeListView:getInfo()
	
end

return PrizeListView