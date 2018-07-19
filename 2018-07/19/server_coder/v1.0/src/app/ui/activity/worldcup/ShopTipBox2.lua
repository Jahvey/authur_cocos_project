local ShopTipBox = class("ShopTipBox2",require "app.module.basemodule.BasePopBox")

function ShopTipBox:initView(name)
	self.widget = cc.CSLoader:createNode("ui/worldcup/box/shopTipBox2.csb")
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

	local namelabel = self.mainLayer:getChildByName("name")
	namelabel:setString(name or "")

	local num = self.mainLayer:getChildByName("num")
	num:setString("jrhp007")
end

function ShopTipBox:onEnter()
end

function ShopTipBox:onExit()
end

return ShopTipBox