local ShopTipBox = class("ShopTipBox",require "app.module.basemodule.BasePopBox")

function ShopTipBox:initView(str)
	self.widget = cc.CSLoader:createNode("ui/worldcup/box/shopTipBox.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	self.sureBtn = self.mainLayer:getChildByName("btn")
	WidgetUtils.addClickEvent(self.sureBtn, function( )
		LaypopManger_instance:back()
	end)

	local num = self.mainLayer:getChildByName("num")
	num:setString(str or "")
end

function ShopTipBox:onEnter()
end

function ShopTipBox:onExit()
end

return ShopTipBox