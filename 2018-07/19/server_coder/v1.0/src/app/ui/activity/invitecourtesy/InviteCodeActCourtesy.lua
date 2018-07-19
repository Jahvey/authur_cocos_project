local InviteCodeActCourtesy = class("InviteCodeActCourtesy",PopboxBaseView)

function InviteCodeActCourtesy:ctor(redpoint)
	self.redpoint = redpoint
	self.shareType = 0
	self:initView()
	self:initEvent()
end

function InviteCodeActCourtesy:initEvent()
	self:registerScriptHandler(function(state)
		if state == "enter" then
			self:onEnter()
		elseif state == "exit" then
			self:onExit()
		end
	end)
end

function InviteCodeActCourtesy:initView()
	self.widget = cc.CSLoader:createNode("ui/invitecourtesy/inviteCourtesy.csb")
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

function InviteCodeActCourtesy:initLeft()
	self.leftnode = self.mainLayer:getChildByName("leftnode")

	local touchlayer = self.leftnode:getChildByName("touchlayer"):setSwallowTouches(false)
	touchlayer:setContentSize(cc.size(display.width,display.height))

	local shareboard = self.leftnode:getChildByName("board")

	WidgetUtils.addClickEvent(touchlayer,function ()
		shareboard:setVisible(false)
	end,true)


end

function InviteCodeActCourtesy:initRight()
	self.rightnode = self.mainLayer:getChildByName("rightnode")

	local scrollview = self.rightnode:getChildByName("scrollview")

	self.setnode = scrollview:getChildByName("setnode")
	
	self.item = scrollview:getChildByName("item")
	self.item:retain()
	self.item:removeFromParent()

	scrollview:addEventListener(function(sender, eventType)
        local event = {}
        if eventType == 9 then
        	-- print(sender:getInnerContainer():getPositionY())
        	if sender:getInnerContainer():getPositionY() > -200 then
        		self:getListData(self.nextpage)
        	end
        end
    end)
end

function InviteCodeActCourtesy:refreshLeft(data)


	local btn1 = self.leftnode:getChildByName("btn1")
	local btn2 = self.leftnode:getChildByName("btn2")

	local erWm = self.leftnode:getChildByName("erweima")
	erWm:setVisible(false)

	NetPicUtils.getPic(erWm, data.qrcode)

	erWm:setContentSize(269,269)



	local erweima_0 = self.leftnode:getChildByName("erweima_0"):ignoreContentAdaptWithSize(true)
	erweima_0:setOpacity(0)
	erweima_0:setVisible(false)
	NetPicUtils.getPic(erweima_0, data.shareimg)
	erweima_0:setVisible(false)


	local shareboard = self.leftnode:getChildByName("board"):setVisible(false)


	WidgetUtils.addClickEvent(btn1, function( )
		print("分享地址")
		shareboard:setVisible(true)
		self.shareType = 0
		shareboard:setPosition(cc.p(-468,-130))
	end)

	WidgetUtils.addClickEvent(btn2, function( )
		print("分享图片")
		shareboard:setVisible(true)
		self.shareType = 1
		shareboard:setPosition(cc.p(-238,-130))
		-- CommonUtils.activity_shareScreen(data.shareimg)
	end)

	local sharebtn1 = shareboard:getChildByName("button1")
	local sharebtn2 = shareboard:getChildByName("button2")

	WidgetUtils.addClickEvent(sharebtn1,function ()
		print("好友",self.shareflag,self.shareType)
		self.shareflag = 0
		if self.shareType == 0 then 
			CommonUtils.wechatShare3(
			{
				title = "今日花牌",
				content = "【今日花牌】火热上线中！快在手机上约局，嗨起来！",
				url = data.url,
				flag = 0,
				icon = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),
			})
		else
			CommonUtils.activity_shareScreen(data.shareimg,self.shareflag)
		end
	end)



	WidgetUtils.addClickEvent(sharebtn2,function ()
		self.shareflag = 1
		print("朋友圈",self.shareflag,self.shareType)
		if self.shareType == 0 then 
			CommonUtils.wechatShare3(
			{
				title = "【今日花牌】火热上线中！快在手机上约局，嗨起来！",
				content = "",
				url = data.url,
				flag = 1,
				icon = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),
			})
		else
			CommonUtils.activity_shareScreen(data.shareimg,self.shareflag)
		end
		
	end)


end


function InviteCodeActCourtesy:loadImageCheLocal()
	-- body

	local path = string.gsub(device.writablePath, "[\\\\/]+$", "") .."/".."appdata/res/cocostudio/ui/invitecourtesy/localimage"


	-- local path = string.gsub(device.writablePath, "[\\\\/]+$", "") .. cc.FileUtils:getInstance():getWritablePath().."appdata/res/cocostudio/ui/invitecourtesy/localimage"
	-- print("NetPicUtils.getLocalPic "..path)
	local FileUtils = cc.FileUtils:getInstance()

	-- if not io.exists(path) then
	if not FileUtils:isDirectoryExist(path) then	
		-- require "lfs"	
		--目录不存在，创建此目录
		if FileUtils:createDirectory(path) then
			print("创建成功")
			return path
		else
			print("创建失败")	
		end
	end

	return path
end


function InviteCodeActCourtesy:uploadImage(picurl)
	-- body
	if string.find(picurl, "http") == nil then
		--print("not find")
		return 
	end
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", picurl)
	local function onDownloadImage()
	    print("xhr.readyState is:", xhr.readyState, "xhr.status is: ", xhr.status)
	    if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	   	  	local fileData = xhr.response
	        local picPath = self:loadImageCheLocal()
	        io.writefile(picPath,fileData)
		else
			print("failed")	
			
	    end
	end
	xhr:registerScriptHandler(onDownloadImage)
	xhr:send()
end

function InviteCodeActCourtesy:refreshRight(data)
	-- 已邀请好友
	local label2 = self.rightnode:getChildByName("label2")
	-- 已领房卡
	local label3 = self.rightnode:getChildByName("label3")
	-- 可领房卡
	local label4 = self.rightnode:getChildByName("label4")

	label2:setString(data.listnum)
	label3:setString(data.getnum)
	label4:setString(data.togetnum)

	-- dump(data)

	self.playConf = data.playnum

	-- print("kfkfkkffffff",self.playConf)

end

function InviteCodeActCourtesy:insertToList(list,page)
	local scrollview = self.rightnode:getChildByName("scrollview")

	local curnum = #list
	local lastnum = self.totalnum or 0
	self.totalnum = lastnum + curnum
	local now = scrollview:getInnerContainerPosition()
	printTable(now,"pbz")

	-- local topitem = self.setnode:getChildByName("topitem"):setPositionY(0)
	-- local topheight = topitem:getContentSize().height
	local itemheight = self.item:getContentSize().height
	totalheight = itemheight*self.totalnum

	local viewsize = scrollview:getContentSize()

	self.item:setTouchEnabled(false)
	self.item:setSwallowTouches(false)
	if totalheight <= viewsize.height then
		scrollview:setInnerContainerSize(viewsize)
		scrollview:setTouchEnabled(false)
		scrollview:setSwallowTouches(false)
	else
		scrollview:setTouchEnabled(true)
		scrollview:setSwallowTouches(true)
		scrollview:setInnerContainerSize(cc.size(viewsize.width,totalheight))
	end

	height = math.max(totalheight,viewsize.height)
	self.setnode:setPositionY(height)
	if page == 0 then
		scrollview:setInnerContainerPosition(cc.p(now.x,viewsize.height-height))
	else
		scrollview:setInnerContainerPosition(cc.p(now.x,math.max(now.y-curnum*itemheight,viewsize.height-height)))
	end

	-- for i=1,3 do
	-- 	self.setnode:getChildByName("vline_"..i):setContentSize(cc.size(2,height)):setPositionY(0)
	-- end
	
	local posy = -(lastnum*itemheight)
	for i,v in ipairs(list) do
		local item = self.item:clone()
		item:addTo(self.setnode)
			:setPosition(cc.p(0,posy))

		local head = item:getChildByName("head"):setScale(0.8)
		local name = item:getChildByName("name")
		local status = item:getChildByName("status")
		local num = item:getChildByName("num")
		local btn = item:getChildByName("btn")
		local btn2 = item:getChildByName("btn2")
		local tag = item:getChildByName("tag")

		name:setString(CommonUtils:base64(v.name,true))
		-- ID:setString(v.uid)
		num:setString("x"..v.reward)
		require("app.ui.common.HeadIcon").new(head,v.img)

		--"status": "状态1待领取邀请奖励，2玩家玩牌数不足，3待领取玩牌奖励，4已经领取完",
		if v.status == 1 then
			status:setString("邀请成功")
			btn:loadTextureNormal("ui/invitecourtesy/green_btn.png",ccui.TextureResType.localType)
			btn:loadTexturePressed("ui/invitecourtesy/green_btn.png",ccui.TextureResType.localType)
			btn:setContentSize(223,54)
			btn2:loadTexture("ui/invitecourtesy/green_btn_icon.png", ccui.TextureResType.localType)
			btn2:setContentSize(189,34)
		elseif v.status == 2 then
			status:setString("玩牌"..v.playnum.."/"..self.playConf.."局")
			btn:loadTextureNormal("ui/invitecourtesy/orage_btn.png",ccui.TextureResType.localType)
			btn:loadTexturePressed("ui/invitecourtesy/orage_btn.png",ccui.TextureResType.localType)
			btn:setContentSize(223,54)
			btn2:loadTexture("ui/invitecourtesy/has_dai_wan_cheng_btn.png", ccui.TextureResType.localType)
			btn2:setContentSize(96,33)
		elseif v.status == 3 then
			status:setString("玩牌"..v.playnum.."/"..self.playConf.."局")
			btn:loadTextureNormal("ui/invitecourtesy/green_btn.png",ccui.TextureResType.localType)
			btn:loadTexturePressed("ui/invitecourtesy/green_btn.png",ccui.TextureResType.localType)
			btn:setContentSize(223,54)
			btn2:loadTexture("ui/invitecourtesy/green_play_reward.png", ccui.TextureResType.localType)
			btn2:setContentSize(189,33)
		elseif v.status == 4 then
			status:setString("已领取")
			btn:loadTextureNormal("ui/invitecourtesy/grey_btn.png",ccui.TextureResType.localType)
			btn:loadTexturePressed("ui/invitecourtesy/grey_btn.png",ccui.TextureResType.localType)
			btn:setContentSize(223,54)
			btn2:loadTexture("ui/invitecourtesy/has_reward.png", ccui.TextureResType.localType)
			btn2:setContentSize(95,33)
		end

		WidgetUtils.addClickEvent(btn,function ()
			self:getAwardRight(v.id)
		end)
		posy = posy - itemheight
	end

end

function InviteCodeActCourtesy:onEnter()
	ComHttp.httpPOST(ComHttp.URL.COURTESYICONF,{uid = LocalData_instance.uid,unionid = cc.UserDefault:getInstance():getStringForKey("weixin_account","")},function(msg)
		-- dump(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end
		self:refreshLeft(msg)
		self:refreshRight(msg)
		self:getListData(1)
	end)
end

function InviteCodeActCourtesy:onExit()
	if self.item then
		self.item:release()
		self.item = nil
	end

	local redpoint = self.redpoint

	ComHttp.httpPOST(ComHttp.URL.ICAGETRED,{uid = LocalData_instance.uid},function(msg)
		printTable(msg,"pbz")
		if redpoint and WidgetUtils:nodeIsExist(redpoint) then
			if msg.status == 1 then
				redpoint:setVisible(true)
			else
				redpoint:setVisible(false)
			end
		end
	end)

	
end

function InviteCodeActCourtesy:getListData(page)
	if self.isrequest then
		return
	end
	if self.isover then
		return
	end
	self.isrequest = true
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.COURTESYILIST,{uid = LocalData_instance.uid,page = page or 0},function(msg)
		print("page======",page)

		-- dump(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end
		self:hideSmallLoading()
		self.isrequest = false
		self.nextpage = msg.page
		-- self:refreshRankNode(msg)
		self:insertToList(msg.list,page)
		
		if #msg.list < 5 then
			self.isover = true
		end

		-- if msg.page == 1 and #msg.list == 10 then
		-- 	self:getRankData(msg.page)
		-- end
	end)
end



function InviteCodeActCourtesy:getAwardRight(id)
	local tips = {
	[1] = "恭喜您领取奖励成功！祝您游戏愉快！",
	[2] = "不好意思，操作过于频繁，请稍后再试！",
	[3] = "领取失败,任务未完成！",
	[4] = "领取失败,网络不给力！",
}

	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.COURTESYIREWARD,{uid = LocalData_instance.uid,listid = id},function(msg)
		printTable(msg,"pbz")

		-- dump(msg)
		-- status:1领取成功，2活动未开启，3已经领取过了，4领取失败，5操作速度过快,6今日没有可用领取次数
		if msg.status == 1 then
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = tips[msg.status] or "恭喜您获得"..msg.num.."张房卡"})
		-- elseif msg.status == 6 then
		-- 	LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "对不起，已达到今日领取上限，请明天再来领取奖励！"})
		else
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = tips[msg.status] or "领取失败（ErrorCode:"..msg.status.."）"})
		end

		if not WidgetUtils:nodeIsExist(self) then
			return
		end
		self:hideSmallLoading()
		if msg.status == 1 then
			self:refreshView()
		end
	end)
end

function InviteCodeActCourtesy:refreshView()
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.COURTESYICONF,{uid = LocalData_instance.uid,unionid = cc.UserDefault:getInstance():getStringForKey("weixin_account","")},function(msg)
		printTable(msg,"pbz")
		if not WidgetUtils:nodeIsExist(self) then
			return
		end
		self:hideSmallLoading()
		self:refreshLeft(msg)
		self:refreshRight(msg)
		self.isover = false
		self.totalnum = 0
		self:getListData(1)
	end)
end

return InviteCodeActCourtesy