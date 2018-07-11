local RecallActivity = class("RecallActivity",PopboxBaseView)
function RecallActivity:ctor(data)
	self:initView()
	self:initEvent(data)
end

function RecallActivity:initView()
	self.widget = cc.CSLoader:createNode("ui/recallactvity/recallactView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closebtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closebtn, function( )
		LaypopManger_instance:back()
	end)

	WidgetUtils.setScalepos(self.mainLayer)
	WidgetUtils.setBgScale(self.mainLayer:getChildByName("bg"))
	self.mainLayer:getChildByName("bg"):setPosition(cc.p(0,0))

	local btn1 = self.mainLayer:getChildByName("btn1"):setBright(false):setTouchEnabled(false)
	local btn2 = self.mainLayer:getChildByName("btn2")

	self.btn1 = btn1

	WidgetUtils.addClickEvent(btn1,function ()
		self:getAward()
	end)

	local board = btn2:getChildByName("board")
	WidgetUtils.addClickEvent(btn2,function ()
		if board:isVisible() then
			return
		end

		board:setVisible(true)
		-- CommonUtils.wechatShare2({
		-- 	title = "老玩家福利！",
		-- 	content = "惊喜！"..LocalData_instance:getNick().."正在召回你，快戳此链接下载并进入游戏，领取50房卡！",
		-- 	url = "/Share/recall?uid="..LocalData_instance.uid.."&channel="..CLIENT_QUDAO,
		-- 	flag = 0,
		-- 	icon = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),
		-- })
	end)

	local touchlayer = self.mainLayer:getChildByName("touchlayer")
	WidgetUtils.setBgScale(touchlayer)
	touchlayer:setPosition(cc.p(0,0))
	touchlayer:setSwallowTouches(false)
	WidgetUtils.addClickEvent(touchlayer,function ()
		board:setVisible(false)
	end,true)

	local sharebtn1 = board:getChildByName("sharebtn1")
	local sharebtn2 = board:getChildByName("sharebtn2")

	WidgetUtils.addClickEvent(sharebtn1,function ()
		CommonUtils.wechatShare2({
			title = "老玩家福利！",
			content = "惊喜！"..LocalData_instance:getNick().."正在召回你，快戳此链接下载并进入游戏，领取50房卡！",
			url = "/Share/recall?uid="..LocalData_instance.uid.."&channel="..CLIENT_QUDAO,
			flag = 0,
			icon = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),
		})
	end)

	WidgetUtils.addClickEvent(sharebtn2,function ()
		CommonUtils.wechatShare2({
			title = "【召回有礼】"..LocalData_instance:getNick().."正在召回你，快戳此链接下载并进入游戏，惊喜壕礼在等着你！",
			content = "",
			url = "/Share/recall?uid="..LocalData_instance.uid.."&channel="..CLIENT_QUDAO,
			flag = 1,
			icon = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),
		})
	end)

	self.scrollview = self.mainLayer:getChildByName("contentnode"):getChildByName("infonode"):getChildByName("scrollview")

	self.item = self.scrollview:getChildByName("item")
	self.item:retain()
	self.item:removeFromParent()

	self.hline = self.scrollview:getChildByName("hline")
	self.hline:retain()
	self.hline:removeFromParent()
end

function RecallActivity:refreshData(data)

	local num = self.mainLayer:getChildByName("contentnode"):getChildByName("num")
	num:setString("房卡奖励:"..(data.chip or 0).."张")

	if tonumber(data.chip) > 0 then
		self.btn1:setBright(true)
		self.btn1:setTouchEnabled(true)
	else
		self.btn1:setBright(false)
		self.btn1:setTouchEnabled(false)
	end

	local totalnum = #data.list
	local totalheight = 0
	totalheight = self.item:getContentSize().height*totalnum

	local viewsize = self.scrollview:getContentSize()

	if totalheight <= viewsize.height then
		self.scrollview:setInnerContainerSize(viewsize)
		self.scrollview:setTouchEnabled(false)
		self.scrollview:setSwallowTouches(false)
		self.item:setTouchEnabled(false)
		self.item:setSwallowTouches(false)
	else
		self.scrollview:setInnerContainerSize(cc.size(viewsize.width,totalheight))
	end

	height = math.max(totalheight,viewsize.height)

	-- self.hline:clone()
	-- 	:addTo(self.scrollview)
	-- 	:setPosition(cc.p(2,height-4))

	local count = 0
	while height > 0 do
		count = count + 1
		height = height - self.item:getContentSize().height

		if data.list[count] then
			local item = self.item:clone()
			item:addTo(self.scrollview)
				:setPosition(cc.p(0,height))

			local head = item:getChildByName("head"):setVisible(true):setScale(0.5)
			local name = item:getChildByName("name"):setVisible(true)
			local id = item:getChildByName("id"):setVisible(true)
			local day = item:getChildByName("day"):setVisible(true)

			require("app.ui.common.HeadIcon").new(head,data.list[count].img)
			name:setString(data.list[count].name)
			id:setString(data.list[count].uid)
			day:setString(data.list[count].day.."天")
		end

		self.hline:clone()
			:addTo(self.scrollview)
			:setPosition(cc.p(2,height))
	end
end

function RecallActivity:getList()
	if self:isLoadingVisible() then
		return
	end
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.RECALLGETLIST,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end
		self:hideSmallLoading()
		if msg.status == 0 then
			return
		end
		self:refreshData(msg)
	end,nil,self.loadingView)
end

function RecallActivity:getAward()
	if self:isLoadingVisible() then
		return
	end
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.RECALLGETAWARD,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end
		self:hideSmallLoading()
		-- self:refreshData(msg)
		self.btn1:setBright(false)
		self.btn1:setTouchEnabled(false)
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "领取成功！"})
		self:getList()
	end,nil,self.loadingView)
end
function RecallActivity:initEvent(data)
	self:registerScriptHandler(function(state)
		if state == "enter" then
			if data then
				self:refreshData(data)
			else
				self:getList()
			end
		elseif state == "exit" then
			if self.item then
				self.item:release()
				self.item = nil
			end
			if self.hline then
				self.hline:release()
				self.hline = nil
			end
		end
	end)
end	

function RecallActivity:isLoadingVisible()
	if self.loadingView and tolua.cast(self.loadingView,"cc.Node") then
		return self.loadingView:isVisible()
	end
	return false
end
return RecallActivity