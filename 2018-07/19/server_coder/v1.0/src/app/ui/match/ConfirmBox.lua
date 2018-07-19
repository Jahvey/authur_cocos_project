local ConfirmBox = class("ConfirmBox",require "app.module.basemodule.BasePopBox")

function ConfirmBox:initView(num,func)
	self.widget = cc.CSLoader:createNode("ui/match/box/confirmbox.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")

	local node = self.mainLayer:getChildByName("node")
	local width = 0
	local tip1 = node:getChildByName("tip1")
	tip1:setPositionX(width)
	width = width + tip1:getContentSize().width+1
	local num = node:getChildByName("num")
	num:setPositionX(width)
	width = width + num:getContentSize().width+1
	local tip2 = node:getChildByName("tip2")
	tip2:setPositionX(width)
	width = width + tip2:getContentSize().width

	node:setPositionX(-width/2)

	local cancelbtn = self.mainLayer:getChildByName("cancelbtn")
	WidgetUtils.addClickEvent(cancelbtn, function( )
		LaypopManger_instance:back()
	end)

	local surebtn = self.mainLayer:getChildByName("surebtn")
	WidgetUtils.addClickEvent(surebtn,function ()
		if func then
			func()
		end
		LaypopManger_instance:back()
	end)
end

function ConfirmBox:onEnter()
end

function ConfirmBox:onExit()
end

return ConfirmBox