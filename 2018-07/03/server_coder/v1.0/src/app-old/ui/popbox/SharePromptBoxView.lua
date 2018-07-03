
local SharePromptBoxView = class("SharePromptBoxView",PopboxBaseView)
function SharePromptBoxView:ctor()
	self.shareType = nil
	self:initView()
end

function SharePromptBoxView:initView()
	self.widget = cc.CSLoader:createNode("ui/popbox/sharePromptBoxView.csb")
	self:addChild(self.widget)	

	self.mainLayer = self.widget:getChildByName("main")
	-- self.closeBtn = self.mainLayer:getChildByName("closebtn")

	self.layer = self.widget:getChildByName("layer")
	WidgetUtils.addClickEvent(self.layer, function( )
		LaypopManger_instance:back()
	end)

	self.invitebtn1 = self.mainLayer:getChildByName("button1")

	local text = "恩施花牌全面上线！绍胡、楚胡、利川巴东上大人、百胡等你来约！"

	self.shareType = 0
	WidgetUtils.addClickEvent(self.invitebtn1,function ()
		CommonUtils.wechatShare(
			{
			title = "今日扑克",
			content = text,
			url = ComHttp.HTTP_ADDRESS.."/Share/springinvite?type=2&channel="..CLIENT_QUDAO.."&uid="..LocalData_instance.uid,
			flag = 0,
			icon = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),
		})
		self.shareType = 1
	end)

	self.invitebtn2 = self.mainLayer:getChildByName("button2")


	WidgetUtils.addClickEvent(self.invitebtn2,function ()
			-- CommonUtils.wechatShare(
			-- {
			-- title = text,
			-- content = "",
			-- url = ComHttp.HTTP_ADDRESS.."/Share/springinvite?type=2&channel="..CLIENT_QUDAO.."&uid="..LocalData_instance.uid,
			-- flag = 1,
			-- icon = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),
			-- })
		CommonUtils.shareScreen_1()
		self.shareType = 2
	end)

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local listener = cc.EventListenerCustom:create("weixinsharecallback" , function ( evt )
        if evt then
          	local output = evt:getDataString()
	        if tonumber(output) and tonumber(output) == 0 then
	        	print("分享成功，",self.shareType)
	        	if self.shareType == 2 then
		        	ComHttp.httpPOST(ComHttp.URL.WECHATREPORT,{uid = LocalData_instance.uid,type = self.shareType,reasontype = 0},function(msg)
		        		print("获得房卡")
					end)
		        end
	        else
	        	print("分享失败")
	        end
        end
    end)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

return SharePromptBoxView