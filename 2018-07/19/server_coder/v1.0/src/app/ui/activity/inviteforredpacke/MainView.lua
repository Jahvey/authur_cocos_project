local MainView = class("MainView",PopboxBaseView)

function MainView:ctor()
	self:initView()
	self:initEvent()
end

function MainView:initEvent()

	self:registerScriptHandler(function(state)
		if state == "enter" then
			self:onEnter()
		elseif state == "exit" then
			self:onExit()
		end
	end)

	local eventDispatcher = self:getEventDispatcher()
	--微信分享回调
	local listener = cc.EventListenerCustom:create("weixinsharecallback" , function ( evt )
		local output = evt:getDataString()
		if tonumber(output) and tonumber(output) == 0 then
			print("分享成功")
			if self.data and self.data.todayshare == 0 then
				-- self.data.todayshare = 0
				if self.shareflag and self.shareflag == 1 then
					self:reportShare()
				end
			end
		else
			print("分享失败")
		end
	end)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function MainView:initView()
	self.widget = cc.CSLoader:createNode("ui/inviteforredpacke/mainView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	self.closeBtn:setPositionX(WidgetUtils.offxscale*self.closeBtn:getPositionX())
	self.closeBtn:setPositionY(WidgetUtils.offyscale*self.closeBtn:getPositionY())

	local bg = self.mainLayer:getChildByName("bg"):setTouchEnabled(true)
	bg:setContentSize(cc.size(display.width,display.height))
	self:initLeft()
	self:initRight()
end

function MainView:initLeft()
	self.leftnode = self.mainLayer:getChildByName("leftnode")

	local listview = self.leftnode:getChildByName("listview")
	local itemmodel = listview:getChildByName("item")

	itemmodel:retain()
	listview:setItemModel(itemmodel)
	itemmodel:removeFromParent()
	itemmodel:release()
end

function MainView:initRight()
	self.rightnode = self.mainLayer:getChildByName("rightnode")

	local listview = self.rightnode:getChildByName("recordlist")

	self.item = listview:getChildByName("item")
	self.item:retain()
	self.item:removeFromParent()

	self.line = listview:getChildByName("line")
	self.line:retain()
	self.line:removeFromParent()

	-- itemmodel:retain()
	-- listview:setItemModel(itemmodel)
	-- itemmodel:removeFromParent()
	-- itemmodel:release()

	local sharebtn = self.rightnode:getChildByName("sharebtn")

	local shareboard = self.rightnode:getChildByName("board")

	local btn1 = shareboard:getChildByName("button1")
	local btn2 = shareboard:getChildByName("button2")

	-- btn2:setVisible(false)
	-- shareboard:getChildByName("label2"):setVisible(false)
	
	-- btn1:setPositionX((btn1:getPositionX()+btn2:getPositionX())/2.0)
	-- shareboard:getChildByName("label1"):setPositionX(btn1:getPositionX())

	local sharetitle = "恩施花牌大酬宾，邀请好友送不停！"
	local sharecontent = "恩施绍胡、楚胡，利川、巴东、野三关、来凤上大人、鹤峰百胡、建始楚胡，应有尽有，赶紧看过来！"
	local sharecontent2 = "恩施绍胡、楚胡，利川、巴东、野三关、来凤上大人、鹤峰百胡、建始楚胡，应有尽有，赶紧看过来！"

	if GAME_CITY_SELECT == 2 then
		sharetitle = "桑植96大酬宾，邀请好友送不停！"
		sharecontent = "玩桑植96，就在今日花牌，快来点击下载，查收我的红包哟！"
		sharecontent2 = "玩桑植96，就在今日花牌，快来点击下载，查收我的红包哟！"
	end

	WidgetUtils.addClickEvent(btn1,function ()
		-- self:reportShare()
		self.shareflag = 0
		CommonUtils.wechatShare2(
			{
			title = sharetitle,
			content = sharecontent,
			url = "/Share/inviteforredpacket?uid="..LocalData_instance.uid,
			flag = 0,
			icon = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),
		})
	end)
	WidgetUtils.addClickEvent(btn2,function ()
		self.shareflag = 1
		CommonUtils.wechatShare2(
			{
			title = sharecontent2,
			content = "",
			url = "/Share/inviteforredpacket?uid="..LocalData_instance.uid,
			flag = 1,
			icon = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),
		})
	end)

	WidgetUtils.addClickEvent(sharebtn,function ()
		shareboard:setVisible(true)
	end)

	local touchlayer = self.rightnode:getChildByName("touchlayer"):setSwallowTouches(false)
	touchlayer:setContentSize(cc.size(display.width,display.height))

	WidgetUtils.addClickEvent(touchlayer,function ()
		shareboard:setVisible(false)
	end,true)

	self:changeBtnStatus(0,0)
end

function MainView:refreshView(data)
	self.data = data
	self:refreshLeft(data)
	self:refreshRight(data)
end

function MainView:refreshLeft(data)
	local list = clone(data.list)

	local listview = self.leftnode:getChildByName("listview")
	listview:removeAllItems()
	local count = 0
	while(#list>0 or count<5) do
		count = count + 1
		-- print(count)
		listview:pushBackDefaultItem()
		local item = listview:getItem(count-1)

		local mydata = list[1]
		table.remove(list,1)
		local name = item:getChildByName("name")
		if mydata then
			name:setString(CommonUtils:base64(mydata.name,true))

			local defaulthead = item:getChildByName("defaulthead")
			defaulthead:setVisible(false)

			local headicon = item:getChildByName("headicon"):setVisible(true)
			require("app.ui.common.HeadIcon").new(headicon,mydata.img)

			self:changeItemStatus(item,mydata)
		else
			name:setVisible(false)
		end
	end
end

function MainView:changeItemStatus(item,data)
	local packet = item:getChildByName("packet")
	local packet_gray = item:getChildByName("packet_gray")
	local tip = item:getChildByName("tip")
	local mark = item:getChildByName("mark")
	WidgetUtils.addClickEvent(item,function ()
			-- body
		end)
	if data.isget == 0 then
		--不能领取
		packet_gray:setVisible(true)
		packet:setVisible(false)
		tip:setVisible(true)
		mark:setVisible(false)
	elseif data.isget == 1 then
		--可以领取
		packet_gray:setVisible(false)
		packet:setVisible(true)
		tip:setVisible(false)
		mark:setVisible(false)
		WidgetUtils.addClickEvent(item,function ()
			self:getInviteAward(item,data)
		end)
	elseif data.isget == 2 then
		--已经领取过了
		packet_gray:setVisible(true)
		packet:setVisible(false)
		tip:setVisible(false)
		mark:setVisible(true)
	end
end

function MainView:formatTime(sec)
	local formatstr = ""
	local day = math.floor(sec / (24*60*60))
	if day > 0 then
		formatstr = formatstr..day.."天"
	end

	sec = sec % (24*60*60)
	local hour = math.floor(sec / (60*60))
	if hour > 0 then
		formatstr = formatstr..hour.."时"
	end

	sec = sec % (60*60)
	local min = math.floor(sec / (60))
	if min > 0 then
		formatstr = formatstr..min.."分"
	end

	return formatstr
end

function MainView:refreshRight(data)
	local timelabel = self.rightnode:getChildByName("timecount")
	timelabel:stopAllActions()
	timelabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function ()
		if os.time() >= data.endtime then
			timelabel:setString("活动已结束！")
		else
			timelabel:setString("活动倒计时:"..self:formatTime(data.endtime-os.time()))
		end
	end),cc.DelayTime:create(1))))
	
	self:changeBtnStatus()

	local listview = self.rightnode:getChildByName("recordlist")
	-- listview:removeAllItems()
	-- for i,v in ipairs(data.loglist) do
	-- 	listview:pushBackDefaultItem()
	-- 	local item = listview:getItem(count-1)

	-- 	local str = item:getChildByName("str")

	-- 	str:setString(v.str)
	-- end

	local totalnum = #data.loglist
	local totalheight = 0

	-- local topitem = self.innerscroll:getChildByName("topitem")
	totalheight = self.item:getContentSize().height*totalnum

	local viewsize = listview:getContentSize()

	if totalheight <= viewsize.height then
		listview:setInnerContainerSize(viewsize)
		listview:setTouchEnabled(false)
		listview:setSwallowTouches(false)
		self.item:setTouchEnabled(false)
		self.item:setSwallowTouches(false)
	else
		listview:setInnerContainerSize(cc.size(viewsize.width,totalheight))
	end

	height = math.max(totalheight,viewsize.height)

	local count = 0
	while height > 0 do
		count = count + 1
		

		if data.loglist[count] then
			local item = self.item:clone()
			item:addTo(listview)
				:setPosition(cc.p(0,height))
			local str = item:getChildByName("str")

			str:setString(data.loglist[count].str)
		end

		self.line:clone()
			:addTo(listview)
			:setPosition(cc.p(8,height-6))

		height = height - self.item:getContentSize().height
	end

end

function MainView:changeBtnStatus(money,proportion)
	if not money then
		money = tonumber(self.data.money)
		proportion = self.data.moneytochip
	end

	local num = self.rightnode:getChildByName("num")
	num:setString(money)

	local yuan = self.rightnode:getChildByName("yuan")
	yuan:setPositionX(num:getPositionX()+num:getContentSize().width/2+8)

	local btn1 = self.rightnode:getChildByName("btn1")

	local btn2 = self.rightnode:getChildByName("btn2")

	if money > 0 then
		btn1:setBright(true)
		btn1:setTouchEnabled(true)
		btn1:getChildByName("img1"):setVisible(true)
		btn1:getChildByName("img2"):setVisible(false)

		WidgetUtils.addClickEvent(btn1,function ()
			LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "请问是否兑换"..money*proportion.."张房卡？",sureCallFunc = function()
				self:exChange()
			end,cancelCallFunc = function()
			end})
		end)
	else
		btn1:setBright(false)
		btn1:setTouchEnabled(false)
		btn1:getChildByName("img1"):setVisible(false)
		btn1:getChildByName("img2"):setVisible(true)
	end

	if money >= 10 then
		btn2:setBright(true)
		btn2:setTouchEnabled(true)
		btn2:getChildByName("img1"):setVisible(true)
		btn2:getChildByName("img2"):setVisible(false)

		WidgetUtils.addClickEvent(btn2,function ()
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = self.data.getmoneystr})
		end)
	else
		btn2:setBright(false)
		btn2:setTouchEnabled(false)
		btn2:getChildByName("img1"):setVisible(false)
		btn2:getChildByName("img2"):setVisible(true)
	end
end

function MainView:onEnter()
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.IFRPGETCONF,{uid = LocalData_instance.uid},function(msg)
			printTable(msg)
			if not WidgetUtils:nodeIsExist(self) then
				return
			end

			self:hideSmallLoading()

			self:refreshView(msg)
		end)
end

function MainView:onExit()
	if self.item then
		self.item:release()
		self.item = nil
	end
	if self.line then
		self.line:release()
		self.line = nil
	end
end

function MainView:showAward(data)
	data.num = data.num or 0
	
	local node = cc.CSLoader:createNode("ui/activity/meiri/baoxiang/zhanshi.csb")
	self:addChild(node)
	-- node:getChildByName("node"):setVisible(false)

	local actionnode = node:getChildByName("zhanshi")

	local image = actionnode:getChildByName("Node_1"):getChildByName("Node_24_0"):getChildByName("images")
	image:ignoreContentAdaptWithSize(true)
	local text = node:getChildByName("node"):getChildByName("di"):getChildByName("text")
	-- text:setString(msg.content)

	if data.itemtype == 2 then
		image:loadTexture("cocostudio/ui/activity/meiri/hongbaohuodong/images/fangka_big.png", ccui.TextureResType.localType)
		text:setString("恭喜您获得"..data.num.."张房卡！")
	else
		image:loadTexture("cocostudio/ui/activity/meiri/hongbaohuodong/images/hongbao_big.png", ccui.TextureResType.localType)
		text:setString("恭喜您获得"..data.num.."元红包！")
	end

	
	local lightnode = node:getChildByName("light")

	local action1 = cc.CSLoader:createTimeline("ui/activity/meiri/hongbaohuodong/hongbaohuodong.csb")
	actionnode:runAction(action1)
	action1:gotoFrameAndPlay(0,false)

	local action2 = cc.CSLoader:createTimeline("ui/activity/meiri/hongbaohuodong/light.csb")
	lightnode:runAction(action2)
	action2:gotoFrameAndPlay(0,true)

	WidgetUtils.addClickEvent(node:getChildByName("node"):getChildByName("closeBtn"), function( )
		node:removeFromParent()
	end)
	WidgetUtils.addClickEvent(node:getChildByName("node"):getChildByName("btn"), function( )
		CommonUtils.shareScreen_2()
    	ISFENXIANGMEIRIACTIVIEY = true
	end)
end

function MainView:getInviteAward(item,data)
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.IFRPGETINVITE,{uid = LocalData_instance.uid,inviteid = data.inviteid},function(msg)
			printTable(msg)
			if msg.status == 1 then
				self:showAward({itemtype = 1,num = 2})
			else
				LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "领取失败！（".."errorCode:"..msg.status.."）"})
			end
			if not WidgetUtils:nodeIsExist(self) then
				return
			end
			self:hideSmallLoading()

			self:changeItemStatus(item,{isget = 2})
			if msg.status == 1 then
				self.data.money = self.data.money + 2
			end
			self:changeBtnStatus()
		end)
end

function MainView:exChange()
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.IFRPEXCHANGE,{uid = LocalData_instance.uid},function(msg)
			printTable(msg)
			if msg.status == 1 then
				self:showAward({itemtype = 2,num = msg.chip})
			else
				LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "领取失败！（".."errorCode:"..msg.status.."）"})
			end
			if not WidgetUtils:nodeIsExist(self) then
				return
			end
			self:hideSmallLoading()

			self.data.money = 0
			self:changeBtnStatus()
		end)
end

function MainView:reportShare()
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.IFRPGETSHARE,{uid = LocalData_instance.uid},function(msg)
			printTable(msg)
			if msg.status == 1 then
				self:showAward(msg)
				self.data.todayshare = 1
			else
				LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "领取失败！（".."errorCode:"..msg.status.."）"})
			end

			if not WidgetUtils:nodeIsExist(self) then
				return
			end
			self:hideSmallLoading()

			if msg.status == 1 then
				if msg.itemtype == 1 then
					self.data.money = self.data.money + msg.num
					self:changeBtnStatus()
				end
			end
		end)
end

return MainView