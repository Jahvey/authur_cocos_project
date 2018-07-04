local SmallLoadingView = class("SmallLoadingView",function() 
	return cc.Node:create()
end)

function SmallLoadingView:ctor()
	self:initView()
	self:initEvent()
end

function SmallLoadingView:initView()
	print("========================loading")

	self.widget = cc.CSLoader:createNode("ui/popbox/loadingView.csb")
	self:addChild(self.widget)

	local mainLayer = self.widget:getChildByName("main")

	mainLayer:getChildByName("tip"):setString("正在加载，请稍候")

	local circle = mainLayer:getChildByName("circle")

	local act = cc.RotateBy:create(0.1, 30)
	circle:runAction(cc.RepeatForever:create(act))
end

function SmallLoadingView:initEvent()
	self:show()
end

function SmallLoadingView:show()
	self:stopAllActions()
	self:setVisible(true)
	self:runAction(cc.Sequence:create(cc.DelayTime:create(10),cc.CallFunc:create(function()
		self:setVisible(false)
	end)))
end

return SmallLoadingView