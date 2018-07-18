local SignPage = class("SignPage",function ()
	return cc.Node:create()
end)

local RULE_TITLE = "激情世界杯，签到赢好礼"
local RULE_CONTENT = "1. 活动时间：2018-06-14 12:00 ~ 2018-07-16 12:00\n2. 玩家每日首次登录游戏，即可签到领取相应礼物。\n3. 点击“签到并分享”，参与微信朋友圈分享活动，即可领取双倍奖励。\n4. 断签不影响签到进程。\n"


function SignPage:ctor(mainview)
	self:initData(mainview)
	self:initView()
	self:initEvent()
end

function SignPage:initData(mainview)
	self.mainView = mainview

	self.itemList = {}
end

function SignPage:initView()
	self.widget = cc.CSLoader:createNode(self.mainView:getResourcePath().."sign/signnode.csb")
	self:addChild(self.widget)

	local rulebtn = self.widget:getChildByName("rulebtn")

	WidgetUtils.addClickEvent(rulebtn, function()
		LaypopManger_instance:PopBox("WCRuleBox",{title = RULE_TITLE,content = RULE_CONTENT})
	end)

	self.scrollView = self.widget:getChildByName("scrollview")
	self.signBtn = self.widget:getChildByName("signbtn")
	self.ruleBtn = self.widget:getChildByName("rulebtn")

	self.itemModel = self.scrollView:getChildByName("item")
	self.itemModel:retain()
	self.itemModel:removeFromParent()
end

function SignPage:initEvent()
	self:registerScriptHandler(function(state)
		if state == "enter" then
			self:onEnter()
		elseif state == "exit" then
			self:onExit()
		end
	end)

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	local listener = cc.EventListenerCustom:create("weixinsharecallback" , function ( evt )
		local output = evt:getDataString()
		if tonumber(output) and tonumber(output) == 0 then
			print("分享成功")
			self:getShareAward()
		else
			print("分享失败")
		end
	end)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function SignPage:refreshView(data)
	self.scrollView:removeAllChildren()

	local contentnode = ccui.Layout:create()
		:addTo(self.scrollView)
	for i,v in ipairs(data.list) do
		local x = (i-1)%6
		local y = math.floor((i-1)/6)
		local item = self.itemModel:clone()
			:addTo(contentnode)

		item:setPosition(cc.p(x*(item:getContentSize().width+8),-y*(item:getContentSize().height+8)))

			item.data = v	
			self:setItemStatus(item)

			table.insert(self.itemList,item)
	end

	local height = (self.itemModel:getContentSize().height+8)*(math.ceil(#data.list/6))
	contentnode:setPosition(cc.p(0,math.max(self.scrollView:getContentSize().height,height)))
	self.scrollView:setInnerContainerSize(cc.size(self.scrollView:getContentSize().width,height))

	self:setSignBtn()
end

function SignPage:setItemStatus(item)
	local bg_unsigned = item:getChildByName("bg_unsigned")
	local bg_signed = item:getChildByName("bg_signed")
	local num = item:getChildByName("num")
	local signed = item:getChildByName("signed") 
	local today = item:getChildByName("today")
	local icon = item:getChildByName("icon"):ignoreContentAdaptWithSize(true)

	if item.data.status == 0 then
		bg_unsigned:setVisible(true)
		bg_signed:setVisible(false)
		signed:setVisible(false)
		today:setVisible(true)
	elseif item.data.status == 1 then
		bg_unsigned:setVisible(false)
		bg_signed:setVisible(true)
		signed:setVisible(true)
		today:setVisible(false)
	elseif item.data.status == 2 then
		bg_unsigned:setVisible(false)
		bg_signed:setVisible(true)
		signed:setVisible(false)
		today:setVisible(false)
	else
		bg_unsigned:setVisible(true)
		bg_signed:setVisible(false)
		signed:setVisible(false)
		today:setVisible(false)
	end

	num:setString("/"..item.data.num)

	if item.data.num < 50 then
		icon:loadTexture(self.mainView:getResourcePath().."sign/football-1.png")
	elseif item.data.num < 200 then
		icon:loadTexture(self.mainView:getResourcePath().."sign/football-2.png")
	else
		icon:loadTexture(self.mainView:getResourcePath().."sign/football-3.png")
	end
end

function SignPage:setSignBtn()
	for i,v in ipairs(self.itemList) do
		if v.data.status == 0 then
			self.signBtn:setEnabled(true)
			WidgetUtils.addClickEvent(self.signBtn,function ()
				self:getSignAward(v)
			end)
			return
		end
	end
	WidgetUtils.addClickEvent(self.signBtn,function ()
		-- self:getSignAward(v)
		self.mainView:sharePic()
	end)
	-- self.signBtn:setEnabled(false)
end

function SignPage:autoSign()
	for i,v in ipairs(self.itemList) do
		if v.data.status == 0 then
			self:getSignAward(v)
			return
		end
	end
end

function SignPage:getSignAward(item)
	self.mainView:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.WCSIGNGETAWARD ,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self.mainView:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end

		-- self.mainView:setPoint(self.mainView:getPoint()+(msg.num or 0))
		self.mainView:gainPoint(msg.num,self.mainView:convertToNodeSpace(item:convertToWorldSpace(cc.p(item:getChildByName("icon"):getPositionX(),item:getChildByName("icon"):getPositionY()))))
		self.mainView:sharePic()
		if WidgetUtils:nodeIsExist(item) then
			item.data.status = 1
			self:setItemStatus(item)
			self:setSignBtn()
		end
	end)
end

function SignPage:getShareAward()
	ComHttp.httpPOST(ComHttp.URL.WCSIGNSHARE ,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if msg.status ~= 1 then
			return
		end

		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		-- self.mainView:setPoint(self.mainView:getPoint()+(msg.num or 0))
		self.mainView:gainPoint(msg.num,self.mainView:convertToNodeSpace(self.signBtn:getParent():convertToWorldSpace(cc.p(self.signBtn:getPositionX(),self.signBtn:getPositionY()))))
		-- self:autoSign()
	end)
end

function SignPage:getConf()
	self.mainView:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.WCSIGNGETCONF ,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self.mainView:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end

		self:refreshView(msg)
	end)
end

function SignPage:onEnter()
	self:getConf()
end

function SignPage:onExit()
	if self.itemModel then
		self.itemModel:release()
	end
end

return SignPage