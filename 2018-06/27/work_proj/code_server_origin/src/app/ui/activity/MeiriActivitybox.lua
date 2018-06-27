local MeiriActivitybox = class("MeiriActivitybox",PopboxBaseView)
require "mime"
function MeiriActivitybox:ctor()
	self:initView()
	self:initEvent()
	
end

function MeiriActivitybox:initView()
	self.widget = cc.CSLoader:createNode("ui/activity/meiri/Fenbox.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("surebtn"), function( )
		CommonUtils.shareScreen_3("cocostudio/ui/activity/meiri/shareActivity.jpg")
		ISFENXIANGMEIRIACTIVIEY = true
    	LaypopManger_instance:back()
	end)

end
function MeiriActivitybox:initEvent()
	local eventDispatcher = self:getEventDispatcher()
	--微信分享回调
	local listener = cc.EventListenerCustom:create("weixinsharecallback" , function ( evt )
	    local output = evt:getDataString()
	    if tonumber(output) and tonumber(output) == 0 then
	    	print("分享成功")
	    	ISFENXIANGMEIRIACTIVIEY = true
	    	LaypopManger_instance:back()

	    else
	    	print("分享失败")
	    end
	end)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end


return MeiriActivitybox