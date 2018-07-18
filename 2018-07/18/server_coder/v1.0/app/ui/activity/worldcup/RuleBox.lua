local RuleBox = class("RuleBox",require "app.module.basemodule.BasePopBox")

function RuleBox:initView(data)
	self.widget = cc.CSLoader:createNode("ui/worldcup/box/ruleBox.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	local title = self.mainLayer:getChildByName("title")
	title:setString(data.title or "")

	local text = self.mainLayer:getChildByName("text")
	text:setString(data.content or "")
end

function RuleBox:onEnter()
end

function RuleBox:onExit()
end

return RuleBox