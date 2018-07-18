local TipBox = class("TipBox",require "app.module.basemodule.BasePopBox")

function TipBox:initView(str)
	self.widget = cc.CSLoader:createNode("ui/worldcup/box/comTipBox.csb")
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

	local tip = self.mainLayer:getChildByName("tip")
	tip:setString(str or "")
end

function TipBox:onEnter()
end

function TipBox:onExit()
end

return TipBox