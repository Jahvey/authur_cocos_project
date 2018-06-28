local InviteCodeActBox = class("InviteCodeActBox",PopboxBaseView)

function InviteCodeActBox:ctor(redpoint)
	self.redpoint = redpoint
	self:initView()
	self:initEvent()
end

function InviteCodeActBox:initEvent()
	self:registerScriptHandler(function(state)
		if state == "enter" then
			self:onEnter()
		elseif state == "exit" then
			self:onExit()
		end
	end)
end

function InviteCodeActBox:initView()
	self.widget = cc.CSLoader:createNode("ui/invitecodeact/inviteCodeBox.csb")
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

function InviteCodeActBox:initLeft()
	self.leftnode = self.mainLayer:getChildByName("leftnode")

	local placeholder = self.leftnode:getChildByName("placeholder")
	local textfield = self.leftnode:getChildByName("textfield")

	local btn1 = self.leftnode:getChildByName("btn1")

	local btn2 = self.leftnode:getChildByName("btn2")

	local shareboard = self.leftnode:getChildByName("board")

	local sharebtn1 = shareboard:getChildByName("button1")
	local sharebtn2 = shareboard:getChildByName("button2")

	-- btn2:setVisible(false)
	-- shareboard:getChildByName("label2"):setVisible(false)
	
	-- btn1:setPositionX((btn1:getPositionX()+btn2:getPositionX())/2.0)
	-- shareboard:getChildByName("label1"):setPositionX(btn1:getPositionX())

	WidgetUtils.addClickEvent(sharebtn1,function ()
		-- self:reportShare()
		self.shareflag = 0
		CommonUtils.wechatShare2(
			{
			title = "今日扑克 — 恩施老乡都在玩！",
			content = "输入我的邀请码"..LocalData_instance.uid.."领房卡啦！您还不知道？赶紧点击此链接下载一起玩！",
			url = "/Share/invitecode?uid="..LocalData_instance.uid,
			flag = 0,
			icon = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),
		})
	end)
	WidgetUtils.addClickEvent(sharebtn2,function ()
		self.shareflag = 1
		CommonUtils.wechatShare2(
			{
			title = "输入我的邀请码"..LocalData_instance.uid.."领房卡啦！您还不知道？赶紧点击此链接下载一起玩！",
			content = "",
			url = "/Share/invitecode?uid="..LocalData_instance.uid,
			flag = 1,
			icon = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),
		})
	end)

	local touchlayer = self.leftnode:getChildByName("touchlayer"):setSwallowTouches(false)
	touchlayer:setContentSize(cc.size(display.width,display.height))

	WidgetUtils.addClickEvent(touchlayer,function ()
		shareboard:setVisible(false)
	end,true)

	WidgetUtils.addClickEvent(btn2,function ()
		shareboard:setVisible(true)
	end)
end

function InviteCodeActBox:initRight()
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

function InviteCodeActBox:refreshLeft(data)
	local scrollview = self.leftnode:getChildByName("scrollview")
	local rule = scrollview:getChildByName("rule")

	rule:ignoreContentAdaptWithSize(true)
	rule:setTextAreaSize(cc.size(scrollview:getContentSize().width-23,0))
	rule:setString(data.rule)
	-- rule:setString("1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n")
	rule:ignoreContentAdaptWithSize(false)

	local height = rule:getContentSize().height + 8
	print("=============height")
	print(height)
	local viewsize = scrollview:getContentSize()
	scrollview:setInnerContainerSize(cc.size(viewsize.width,math.max(viewsize.height,height)))

	rule:setPositionY(scrollview:getInnerContainerSize().height-4)

	local placeholder = self.leftnode:getChildByName("placeholder")
	local textfield = self.leftnode:getChildByName("textfield")

	local btn1 = self.leftnode:getChildByName("btn1")

	local checkfunc = function (str)
		if tonumber(str) then
			return true
		end
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "请输入正确的邀请码！"})
		return false
	end

	local touchlayer = ccui.Layout:create()
	touchlayer:setContentSize(cc.size(display.width*4, display.height*4))
	touchlayer:setPosition(cc.p(-display.width, -display.height))
	self:addChild(touchlayer, 10)
	touchlayer:setTouchEnabled(true)
	touchlayer:setVisible(false)
	self.touchlayer = touchlayer
	
	self:initTextField(textfield,placeholder,checkfunc)

	WidgetUtils.addClickEvent(btn1,function ()
		if checkfunc(textfield:getString()) then
			self:getAwardLeft(textfield:getString())
		end
	end)

	local btn2 = self.leftnode:getChildByName("btn2")

	--状态：1未绑定邀请，2已经填写邀请未领奖，3已经填写邀请已经领奖
	if data.status == 1 then
		textfield:setTouchEnabled(true)
		placeholder:setVisible(true)
		btn1:setTouchEnabled(true)
		btn1:setBright(true)
	elseif data.status == 2 then
		textfield:setString(data.invite_uid)
		textfield:setTouchEnabled(false)
		textfield:setVisible(false)
		placeholder:setVisible(true)
		placeholder:setString("已被好友"..data.invite_uid.."邀请成功")
		btn1:setTouchEnabled(true)
		btn1:setBright(true)
	elseif data.status == 3 then
		textfield:setString(data.invite_uid)
		textfield:setTouchEnabled(false)
		textfield:setVisible(false)
		placeholder:setVisible(true)
		placeholder:setString("已被好友"..data.invite_uid.."邀请成功")
		btn1:setTouchEnabled(false)
		btn1:setBright(false)
	end

end

function InviteCodeActBox:refreshRight(data)
	-- 我的邀请码
	local label1 = self.rightnode:getChildByName("label1")
	-- 已邀请好友
	local label2 = self.rightnode:getChildByName("label2")
	-- 已领房卡
	local label3 = self.rightnode:getChildByName("label3")
	-- 可领房卡
	local label4 = self.rightnode:getChildByName("label4")

	label1:setString(LocalData_instance.uid or "")
	label2:setString(data.had_invite)
	label3:setString(data.had_prize)
	label4:setString(data.remain_prize)

end

function InviteCodeActBox:insertToList(list,page)
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
		num:setString("x"..v.num)
		require("app.ui.common.HeadIcon").new(head,v.img)

		--"status": "状态1待领取邀请奖励，2玩家玩牌数不足，3待领取玩牌奖励，4已经领取完",
		if v.status == 1 then
			status:setString("邀请成功")
			btn:setVisible(true)
			btn2:setVisible(false)
		elseif v.status == 2 then
			status:setString("待玩牌3局")
			btn:setVisible(false)
			btn2:setVisible(true)
		elseif v.status == 3 then
			status:setString("玩牌3局")
			btn:setVisible(true)
			btn2:setVisible(false)
		elseif v.status == 4 then
			status:setString("玩牌3局")
			tag:setVisible(true)
			btn:setVisible(true)
			btn2:setVisible(false)
			btn:setTouchEnabled(false)
			btn:setBright(false)
		end

		WidgetUtils.addClickEvent(btn,function ()
			self:getAwardRight(v.id)
		end)

		posy = posy - itemheight
	end

end

function InviteCodeActBox:onEnter()
	ComHttp.httpPOST(ComHttp.URL.ICAGETCONF,{uid = LocalData_instance.uid,unionid = cc.UserDefault:getInstance():getStringForKey("weixin_account","")},function(msg)
		printTable(msg,"pbz")
		if not WidgetUtils:nodeIsExist(self) then
			return
		end
		self:refreshLeft(msg)
		self:refreshRight(msg)
		self:getListData(0)
	end)
end

function InviteCodeActBox:onExit()
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

function InviteCodeActBox:initTextField(textfield,placeholder,checkfunc)
	textfield.checkfunc = checkfunc
	local old_x,old_y = self.widget:getPosition()
	local function insertFunc()
		if textfield:getString() == "" then
			placeholder:setVisible(true)
		else
			placeholder:setVisible(false)
		end
	end

	textfield.insertFunc = insertFunc

	textfield:addEventListener(function (target, event)
		if event == ccui.TextFiledEventType.attach_with_ime then-- 进入输入
			-- if device.platform == "ios" then
			-- 	self.widget:stopAllActions()
			-- 	local offy = 200
			-- 	-- if index == 1 or index == 2 then
			-- 	-- 	offy = 100
			-- 	-- end
			-- 	self.widget:runAction(cc.Sequence:create(cc.MoveTo:create(0.225,cc.p(old_x, old_y+200)),cc.CallFunc:create(function()
			-- 		self.touchlayer:setVisible(true)
			-- 	end)))
			-- 	cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(true)
			-- end
		elseif event == ccui.TextFiledEventType.detach_with_ime then-- 离开输入
			-- checkfunc(target:getString())
			-- if device.platform == "ios" then
			-- 	self.widget:stopAllActions()
			-- 	self.widget:runAction(cc.Sequence:create(cc.MoveTo:create(0.175, cc.p(old_x, old_y)),cc.CallFunc:create(function()
			-- 		self.touchlayer:setVisible(false)
			-- 	end)))
			-- 	cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
			-- end
		elseif event == ccui.TextFiledEventType.insert_text then --输入字符
			insertFunc()
		elseif event == ccui.TextFiledEventType.delete_backward then--删除字符
			insertFunc()
		end
	end)
end

function InviteCodeActBox:getListData(page)
	if self.isrequest then
		return
	end
	if self.isover then
		return
	end
	self.isrequest = true
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.ICAGETLIST,{uid = LocalData_instance.uid,page = page or 0},function(msg)
		print("page======",page)
		printTable(msg,"pbz")
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

function InviteCodeActBox:getAwardLeft(code)
	local tips = {
	[1] = "恭喜您领取奖励成功！祝您游戏愉快！",
	[2] = "不好意思，活动还未开启，活动开启后再来参与哦！",
	[3] = "不好意思，您经领取过此奖励了，祝您游戏愉快。",
	[4] = "不好意思，领取奖励失败，请稍后再试！",
	[5] = "不好意思，操作过于频繁，请稍后再试！",
	[6] = "不好意思，只有新用户才能输入邀请码。您是老用户了，赶快去邀请新用户输入您的邀请码领取奖励吧！",
	[7] = "不好意思，在您之前下载游戏的好友才能邀请您。请输入在您之前注册游戏的玩家的邀请码！",
	[8] = "对不起，您输入的邀请码不存在，请输入正确的邀请码！",
}

	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.ICAGETAWARD1,{uid = LocalData_instance.uid,code = code},function(msg)
		printTable(msg,"pbz")
		-- status:1领取成功，2活动未开启，3已经领取过了，4领取失败，5操作速度过快,6注册时间早于活动时间，7注册时间早于邀请人注册时间
		if msg.status == 1 then
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = tips[msg.status] or "恭喜您获得"..msg.num.."张房卡"})
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

function InviteCodeActBox:getAwardRight(id)
	local tips = {
	[1] = "恭喜您领取奖励成功！祝您游戏愉快！",
	[2] = "不好意思，活动还未开启，活动开启后再来参与哦！",
	[3] = "不好意思，您经领取过此奖励了，祝您游戏愉快。",
	[4] = "不好意思，领取奖励失败，请稍后再试！",
	[5] = "不好意思，操作过于频繁，请稍后再试！",
	[6] = "对不起，您已达到今日领取上限，请明天再来领取奖励！",
}

	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.ICAGETAWARD2,{uid = LocalData_instance.uid,id = id},function(msg)
		printTable(msg,"pbz")
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

function InviteCodeActBox:refreshView()
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.ICAGETCONF,{uid = LocalData_instance.uid,unionid = cc.UserDefault:getInstance():getStringForKey("weixin_account","")},function(msg)
		printTable(msg,"pbz")
		if not WidgetUtils:nodeIsExist(self) then
			return
		end
		self:hideSmallLoading()
		self:refreshLeft(msg)
		self:refreshRight(msg)
		self.isover = false
		self.totalnum = 0
		self:getListData(0)
	end)
end

return InviteCodeActBox