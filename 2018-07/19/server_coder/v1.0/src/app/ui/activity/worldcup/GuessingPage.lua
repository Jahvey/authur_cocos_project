local GuessingPage = class("GuessingPage",function ()
	return cc.Node:create()
end)

local RULE_TITLE = "激情世界杯，每日猜不停"
local RULE_CONTENT = "1. 活动时间：2018-06-14 12:00 ~ 2018-07-16 12:00\n2. 每个赛程可以选择一个比赛结果，使用大力神点数下注，下注成功后不可以退换，但可追加投注额，（1000点封顶）。\n3. 每场比赛开赛前30分钟下注截止。\n4. 每日12:00公布比赛结果，玩家可领取奖励。同时更新比赛赛程。\n"

local WEEK_MAP = {
	[1] = "周一",
	[2] = "周二",
	[3] = "周三",
	[4] = "周四",
	[5] = "周五",
	[6] = "周六",
	[0] = "周日",
}

function GuessingPage:ctor(mainview,item)
	self:initData(mainview,item)
	self:initView()
	self:initEvent()
end

function GuessingPage:initData(mainview,item)
	self.mainView = mainview
	self.item = item
end

function GuessingPage:initView()
	self.widget = cc.CSLoader:createNode(self.mainView:getResourcePath().."guessing/guessingnode.csb")
	self:addChild(self.widget)

	local rulebtn = self.widget:getChildByName("rulebtn")

	WidgetUtils.addClickEvent(rulebtn, function()
		LaypopManger_instance:PopBox("WCRuleBox",{title = RULE_TITLE,content = RULE_CONTENT})
	end)

	self.scrollView = self.widget:getChildByName("scrollview")

	self.titleItem = self.scrollView:getChildByName("titleitem"):setSwallowTouches(false)
	self.titleItem:retain()
	self.titleItem:removeFromParent()

	self.detailItem = self.scrollView:getChildByName("detailitem"):setSwallowTouches(false)
	self.detailItem:retain()
	self.detailItem:removeFromParent()

	self.resultItem = self.scrollView:getChildByName("resultitem"):setSwallowTouches(false)
	self.resultItem:retain()
	self.resultItem:removeFromParent()
end

function GuessingPage:initEvent()
	self:registerScriptHandler(function(state)
		if state == "enter" then
			self:onEnter()
		elseif state == "exit" then
			self:onExit()
		end
	end)
end

function GuessingPage:refreshScrollView(data)
	self.scrollView:removeAllChildren()
	self.scrollView.contentNode = ccui.Layout:create()
		:addTo(self.scrollView)

	self.scrollView.itemList = {}
	self.scrollView.innerHeight = 0

	for i,v in ipairs(data.list or {}) do
		local titleitem = self.titleItem:clone()
			:addTo(self.scrollView.contentNode)
			:setTag(i)
			:setPositionY(-self.scrollView.innerHeight)

		local date = titleitem:getChildByName("date")
		local weekday = titleitem:getChildByName("weekday")
		local tip = titleitem:getChildByName("tip")
		local redpoint = titleitem:getChildByName("redpoint")

		date:setString(string.sub(v.date,1,4).."-"..string.sub(v.date,5,6).."-"..string.sub(v.date,7,8))
		weekday:setString(WEEK_MAP[v.weekday] or "")
		tip:setString("[共"..v.num.."场比赛]")

		weekday:setPositionX(date:getPositionX()+date:getContentSize().width+3)
		tip:setPositionX(weekday:getPositionX()+weekday:getContentSize().width+3)

		self.scrollView.innerHeight = self.scrollView.innerHeight + titleitem:getContentSize().height
		titleitem.data = v
		titleitem.extending = false

		titleitem.setRedVisible = function (bool)
			redpoint:setVisible(bool)
		end
		titleitem.setRedVisible(v.red == 1)

		WidgetUtils.addClickEvent(titleitem,function ()
			self:clickTitle(titleitem)
		end)

		table.insert(self.scrollView.itemList,titleitem)
	end

	self.resetScrollView(self.scrollView,self.scrollView.contentNode,cc.size(self.scrollView:getContentSize().width,self.scrollView.innerHeight))
end

function GuessingPage:clickTitle(item)
	if item.data.detail then
		self:extendItem(item)
	else
		self:getDetail(item)
	end
end

function GuessingPage:extendItem(item,refresh)
	if not item.detailNode or refresh then
		if item.detailNode then
			item.detailNode:removeFromParent()
		end
		item.detailNode = ccui.Layout:create()
			:addTo(item)
			:setPosition(cc.p(0,0))
		item.detailNode.height = 0
		
		for i,v in ipairs(item.data.detail) do
			local detailitem = self:createDetailItem(v,item)
				:addTo(item.detailNode)
				:setPosition(cc.p(0,-item.detailNode.height))
			item.detailNode.height = item.detailNode.height + detailitem:getContentSize().height
		end
	end

	item.extending = refresh and item.extending or not item.extending

	if item.extending then
		item:getChildByName("title_u"):setVisible(false)
		item:getChildByName("title_s"):setVisible(true)
	else
		item:getChildByName("title_u"):setVisible(true)
		item:getChildByName("title_s"):setVisible(false)
	end

	self.scrollView.innerHeight = 0
	for i,v in ipairs(self.scrollView.itemList) do
		v:setPositionY(-self.scrollView.innerHeight)
		self.scrollView.innerHeight = self.scrollView.innerHeight + v:getContentSize().height
		if v.extending then
			self.scrollView.innerHeight = self.scrollView.innerHeight + v.detailNode.height
			v.detailNode:setVisible(true)
		else
			if v.detailNode then
				v.detailNode:setVisible(false)
			end
		end
	end

	self.resetScrollView(self.scrollView,self.scrollView.contentNode,cc.size(self.scrollView:getContentSize().width,self.scrollView.innerHeight))
end

function GuessingPage:createDetailItem(data,parentitem)
	local item
	local team1 = data.team1
	local team2 = data.team2
	local draw = data.draw

	if data.result == -1 then
		item = self.detailItem:clone()

		local statuslabel = item:getChildByName("status")
		local chipnumlabel = item:getChildByName("chipnum")
		local oddslabel = item:getChildByName("odds")
		local posx = statuslabel:getPositionX()

		local chipinnode = item:getChildByName("chipinnode")
		local chipbtn1 = chipinnode:getChildByName("chipbtn1")
		local chipbtn2 = chipinnode:getChildByName("chipbtn2")
		local chipbtn3 = chipinnode:getChildByName("chipbtn3"):setVisible(false)
		local chipnum1 = chipinnode:getChildByName("chipnum1")
		local chipnum2 = chipinnode:getChildByName("chipnum2")
		local chipnum3 = chipinnode:getChildByName("chipnum3"):setVisible(false)

		local chipinfo = {
			{btn = chipbtn1,num = chipnum1,info = team1,},
			{btn = chipbtn2,num = chipnum2,info = team2,},
			{btn = chipbtn3,num = chipnum3,info = draw,},
		}

		if data.bet ~= -1 then
			statuslabel:setString("已投注")
			statuslabel:setColor(cc.c3b(0x5f, 0x96, 0x00))
			posx = posx + statuslabel:getContentSize().width + 2

			chipnumlabel:setVisible(true)
			chipnumlabel:setString("["..data.bet_num.."]")
			chipnumlabel:setPositionX(posx)
			posx = posx + chipnumlabel:getContentSize().width + 2
		else
			statuslabel:setString("未投注")
			statuslabel:setColor(cc.c3b(0xff, 0x9f, 0x1e))
			posx = posx + statuslabel:getContentSize().width + 2
			chipnumlabel:setVisible(false)
		end

		oddslabel:setPositionX(posx)
		if data.endtime > 1530288000 then
			oddslabel:setString("实时赔率["..team1.name..team1.rate.." "..team2.name..team2.rate.."]")
		else
			oddslabel:setString("实时赔率["..team1.name..team1.rate.." 平"..draw.name..draw.rate.." "..team2.name..team2.rate.."]")
		end

		for _,v in ipairs(chipinfo) do
			v.num:setString("已投注:"..v.info.bet_people.."人")
			WidgetUtils.addClickEvent(v.btn,function ()
				LaypopManger_instance:PopBox("WCBetBox",self.mainView,data,v.info,function ()
					if not WidgetUtils:nodeIsExist(parentitem) then
						return
					end
					self:getDetail(parentitem)
				end)
			end)
			if data.endtime < os.time() then
				if data.bet  == v.info.id then
					self:setBtnStatus(v.btn,4)
				else
					self:setBtnStatus(v.btn,3)
				end
			else
				if data.bet ~= -1 then
					if v.info.id ~= data.bet then
						self:setBtnStatus(v.btn,3)
					else
						self:setBtnStatus(v.btn,2)
					end
				else
					self:setBtnStatus(v.btn,1)
				end
			end
		end
	else
		item = self.resultItem:clone()

		local myoddslabel = item:getChildByName("myodds")
		local oddslabel = item:getChildByName("odds")
		local result = item:getChildByName("result")
		local getbtn = item:getChildByName("getbtn")
		local posx = myoddslabel:getPositionX()

		getbtn:setEnabled(false)
		getbtn:getChildByName("text_get"):setVisible(false)
		getbtn:getChildByName("text_get_gray"):setVisible(true)
		getbtn:getChildByName("text_get_gray2"):setVisible(false)

		if data.bet ~= -1 then
			local betname = self.mainView:getCountryName(data.bet)
			if data.bet == 0 then
				betname = "平局"
			end
			myoddslabel:setString("我的投注["..betname..data.bet_num.."]")
			posx = posx + myoddslabel:getContentSize().width + 2

			if data.bet == data.result and data.is_get ~= 1 then
				getbtn:setEnabled(true)
				getbtn:getChildByName("text_get"):setVisible(true)
				getbtn:getChildByName("text_get_gray"):setVisible(false)
				getbtn:getChildByName("text_get_gray2"):setVisible(false)
				WidgetUtils.addClickEvent(getbtn,function ()
					self:getAward(data.gid,parentitem,self.mainView:convertToNodeSpace(getbtn:getParent():convertToWorldSpace(cc.p(getbtn:getPositionX(),getbtn:getPositionY()))))
				end)
			elseif data.is_get == 1 then
				getbtn:setEnabled(false)
				getbtn:getChildByName("text_get"):setVisible(false)
				getbtn:getChildByName("text_get_gray"):setVisible(false)
				getbtn:getChildByName("text_get_gray2"):setVisible(true)
			end
		else
			myoddslabel:setVisible(false)
		end

		oddslabel:setPositionX(posx)
		if data.endtime > 1530288000 then
			oddslabel:setString("最终赔率["..team1.name..team1.rate.." "..team2.name..team2.rate.."]")
		else
			oddslabel:setString("最终赔率["..team1.name..team1.rate.." 平"..draw.name..draw.rate.." "..team2.name..team2.rate.."]")
		end
		
		result:setString(team1.score..":"..team2.score)

	end

	local timelabel = item:getChildByName("time")

	if data.endtime > os.time() then
		timelabel:setString(os.date("%H"..":".."%M",data.endtime))
	else
		timelabel:setString("已结束")
	end

	local name1 = item:getChildByName("name1")
	local name2 = item:getChildByName("name2")
	local flag1 = item:getChildByName("flag1")
	local flag2 = item:getChildByName("flag2")

	name1:setString(team1.name)
	name2:setString(team2.name)
	flag1:loadTexture(self.mainView:getCountryFlag(team1.id))
	flag2:loadTexture(self.mainView:getCountryFlag(team2.id))

	return item
end

function GuessingPage:setBtnStatus(btn,state)
	local tc = btn:getChildByName("tc")
	local tc_g = btn:getChildByName("tc_g")
	local ta = btn:getChildByName("ta")
	local ta_g = btn:getChildByName("ta_g")
	for _,child in ipairs(btn:getChildren()) do
		child:setVisible(false)
	end
	if state == 1 then
		btn:setEnabled(true)
		tc:setVisible(true)
	elseif state == 2 then
		btn:setEnabled(true)
		ta:setVisible(true)
	elseif state == 3 then
		btn:setEnabled(false)
		tc_g:setVisible(true)
	else
		btn:setEnabled(false)
		ta_g:setVisible(true)
	end
end

function GuessingPage:checkRedpoint()
	local mainred = false
	for _,item in ipairs(self.scrollView.itemList) do
		local titlered = not item.data.detail and item.data.red == 1
		for _,v in ipairs (item.data.detail or {}) do
			titlered = titlered or (v.bet ~= -1 and v.bet == v.result and v.is_get == 0)
		end 
		mainred = mainred or titlered 

		item.setRedVisible(titlered)
	end

	self.item.setRedVisible(mainred)
end

function GuessingPage:getList()
	self.mainView:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.WCGUESSGETLIST,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self.mainView:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end

		self:refreshScrollView(msg)
	end)
end

function GuessingPage:getDetail(item)
	self.mainView:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.WCGUESSGETDETAIL,{uid = LocalData_instance.uid,date = item.data.date},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(item) then
			return
		end

		self.mainView:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end
		item.data.detail = msg.list or {}
		self:extendItem(item,true)
		self:checkRedpoint()
	end)
end

function GuessingPage:getAward(gid,parentitem,startpos)
	self.mainView:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.WCGUESSGETAWARD,{uid = LocalData_instance.uid,gid = gid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self.mainView:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end

		-- self.mainView:gainPoint(msg.num,startpos)
		self.mainView:setPoint(self.mainView:getPoint()+(msg.num or 0))
		LaypopManger_instance:PopBox("WCTipBox","恭喜你在本次竞猜中获得了"..msg.num.."大力神点数")
		self:getDetail(parentitem)
		
	end)
end

function GuessingPage:onEnter()
	self:getList()
end

function GuessingPage:onExit()
	if self.titleItem then
		self.titleItem:release()
	end
	if self.detailItem then
		self.detailItem:release()
	end
	if self.resultItem then
		self.resultItem:release()
	end
end

function GuessingPage.resetScrollView(scrollview,contentnode,newsize)
	local viewsize = scrollview:getContentSize()
	local innersize = scrollview:getInnerContainerSize()
	local lastinnerpos = scrollview:getInnerContainerPosition()
	scrollview:setInnerContainerSize(cc.size(newsize.width,newsize.height))
	local newheight = scrollview:getInnerContainerSize().height
	contentnode:setPosition(cc.p(0,math.max(newheight,viewsize.height)))
	scrollview:setInnerContainerPosition(cc.p(lastinnerpos.x,math.max(lastinnerpos.y-(newheight-innersize.height),viewsize.height-newheight)))
end

return GuessingPage