
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

	local textList = 
	{
		[1]="恩施花牌全面上线！绍胡、楚胡、利川巴东上大人、百胡等你来约！",
		[2]="桑植96火热组局中，等你来玩牌！",
		[3]="麻城斗地主正在火热组局，快来约起来！",
		[4]="孝昌扯胡，应城斗地主，应城小字牌等你约起来！",
		[5]="宜城绞胡火热约局中，快叫上牌友一起来玩吧！",
		[6]="通城个子牌等你来玩，戳戳戳链接，一起约起来！",
		[7]="宜昌花牌火热上线！宜昌三精、五精、老精等更多玩法，等你体验！",
	}

	local _test = "今日花牌，地道家乡玩法应有尽有，你身边的花牌专家！"
	-- 1恩施 2张家界,3麻城,4孝感 5襄阳 6咸宁,7宜昌

	self.shareType = 0
	WidgetUtils.addClickEvent(self.invitebtn1,function ()
		CommonUtils.wechatShare(
			{
			title = "今日花牌",
			content = textList[GAME_CITY_SELECT] or _test,
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