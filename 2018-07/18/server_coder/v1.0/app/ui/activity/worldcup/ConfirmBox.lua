local ConfirmBox = class("ConfirmBox",require "app.module.basemodule.BasePopBox")

function ConfirmBox:initView(data,func)
	self.widget = cc.CSLoader:createNode("ui/worldcup/box/confirmBox.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	self.sureBtn = self.mainLayer:getChildByName("btn")
	WidgetUtils.addClickEvent(self.sureBtn, function( )
		func()
		LaypopManger_instance:backByName("WCConfirmBox")
	end)

	-- local tip = self.mainLayer:getChildByName("tip")
	-- tip:setString(str or "")
	local strnode = self.mainLayer:getChildByName("strnode")

	local tip1 = strnode:getChildByName("tip1")
	local num = strnode:getChildByName("num")
	local tip2 = strnode:getChildByName("tip2")
	local name = strnode:getChildByName("name")

	num:setString(self:formatPrice(data.point))
	name:setString(data.name or "")

	local labellist = {tip1,num,tip2,name}
	local posx = 0

	for i,v in ipairs(labellist) do
		v:setPositionX(posx)
		posx = posx + v:getContentSize().width
	end

	strnode:setPositionX(-posx/2)
end

function ConfirmBox:formatPrice(price)
	local str = price

	if price >= 10000 then
		if price%10000 == 0 then
			str = string.format("%d".."万",(price/10000))
		else
			str = string.format("%.2f".."万",(price/10000))
		end
	end

	return str
end

function ConfirmBox:onEnter()
end

function ConfirmBox:onExit()
end

return ConfirmBox