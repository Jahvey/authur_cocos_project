local ShareActivity = class("ShareActivity",PopboxBaseView)

function ShareActivity:ctor()
	self:initView()
	self:showSmallLoading()
end

function ShareActivity:initView()
	self.widget = cc.CSLoader:createNode("ui/activity/shareActView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
		:setPosition(cc.p(display.width/2-40,display.height/2-40))

	self.scrollview = self.mainLayer:getChildByName("scrollView")
		:setContentSize(cc.size(display.width,display.height))
		:setPosition(cc.p(-display.width/2,-display.height/2))

	self.node = self.scrollview:getChildByName("node")

	self.shareBtn = self.node:getChildByName("sharebtn")

	self.bg = self.mainLayer:getChildByName("bg"):setContentSize(cc.size(display.width,display.height))

	local hand = self.node:getChildByName("hand")

	hand:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.EaseSineIn:create(cc.MoveTo:create(1,cc.p(948,350))),cc.DelayTime:create(0.1),cc.CallFunc:create(function()
         hand:setPosition(cc.p(997,314))
     end))))

	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	WidgetUtils.addClickEvent(self.shareBtn, function( )
		hand:setVisible(false)
		self:shareEvent()
	end)

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local listener = cc.EventListenerCustom:create("weixinsharecallback" , function ( evt )
        local output = evt:getDataString()
        if tonumber(output) and tonumber(output) == 0 then
        	print("分享成功")
        	if (SHARESEED or 0) == (self.shareseed or -1) then
	        	ComHttp.httpPOST(ComHttp.URL.WECHATREPORT,{uid = LocalData_instance.uid,type = 2,reasontype = 1},function(msg)
				end)
	        end
        else
        	print("分享失败")
        end
    end)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function ShareActivity:shareEvent()
    CommonUtils.wechatShare({
			title = "11到17号,【喜来乐】麻将免费送iphone7/华为p10! 快来试试手气,大结算最高分第1就把大奖带回家！",
			content = "",
			url = "http://cddssactivityopzle.barretgames.com/mjapi/index.php/Share/wechatstatistics?type=2&channel="..CLIENT_QUDAO.."&uid="..LocalData_instance.uid.."&reasontype=1",
			flag = 1,
			icon = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),
		})
    SHARESEED = os.time()..math.random(10000,99999)
    self.shareseed = SHARESEED
end

function ShareActivity:onEndAni()
	self:requestActInfo()
end

function ShareActivity:refreshView(data)
	local contentnode = self.node:getChildByName("board"):getChildByName("content")
	local label1 = contentnode:getChildByName("label1")
	local label2 = contentnode:getChildByName("label2")
	local label3 = contentnode:getChildByName("label3")
	local label4 = contentnode:getChildByName("label4")

	local FONTSIZE = 24
	local COLOR = cc.c3b(0x9f,0x4c,0x1a)
	if data.list then
		for i,v in ipairs(data.list) do
			local time = ccui.Text:create(v.date,FONTNAME_DEF,FONTSIZE)
				:setColor(COLOR)
				:addTo(contentnode)
				:setPosition(cc.p(label1:getPositionX(),label1:getPositionY()-62*i+3))

			local head = ccui.ImageView:create("")
				:addTo(contentnode)
				:setPosition(cc.p(label2:getPositionX()-60,label2:getPositionY()-62*i+3))
				:setScale(0.6)

			require("app.ui.common.HeadIcon").new(head,v.img)

			local name = ccui.Text:create(v.name,FONTNAME_DEF,FONTSIZE)
				:setColor(COLOR)
				:addTo(contentnode)
				:setAnchorPoint(cc.p(0,0.5))
				:setPosition(cc.p(label2:getPositionX()-20,label2:getPositionY()-62*i+3))

			local uid = ccui.Text:create(v.uid,FONTNAME_DEF,FONTSIZE)
				:setColor(COLOR)
				:addTo(contentnode)
				:setPosition(cc.p(label3:getPositionX(),label3:getPositionY()-62*i+3))

			local score = ccui.Text:create(v.score,FONTNAME_DEF,FONTSIZE)
				:setColor(COLOR)
				:addTo(contentnode)
				:setPosition(cc.p(label4:getPositionX(),label4:getPositionY()-62*i+3))
		end
	end
end

function ShareActivity:requestActInfo()
	ComHttp.httpPOST(ComHttp.URL.SHAREACTIVITY1,{uid = LocalData_instance.uid},function(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end
		printTable(msg,"sjp3")
		self:refreshView(msg)
		self:hideSmallLoading()
	end)
end

return ShareActivity