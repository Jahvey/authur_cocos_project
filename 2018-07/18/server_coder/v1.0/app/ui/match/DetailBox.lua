local DetailBox = class("DetailBox",require "app.module.basemodule.BasePopBox")

function DetailBox:initData(id)
	self.id = id
end

function DetailBox:initView()
	self.widget = cc.CSLoader:createNode("ui/match/detail/detailbox.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	self.detailNode = self.mainLayer:getChildByName("detailnode")
	self.awardNode = self.mainLayer:getChildByName("awardnode")
	self.ruleNode = self.mainLayer:getChildByName("rulenode")

	self.nodeList = {
		self.detailNode,
		self.awardNode,
		self.ruleNode,
	}

	self:initTitleNode()
	self:initAwardNode()

	self.signBtn = self.mainLayer:getChildByName("btn")

	-- WidgetUtils.addClickEvent(btn,function ()
	-- 	Socketapi.requestQuickMatch(self.id)
	-- end)
end

function DetailBox:initAwardNode()
	self.listView = self.awardNode:getChildByName("listview")

	local itemmodel = self.listView:getChildByName("item")
	itemmodel:retain()
	self.listView:setItemModel(itemmodel)
	self.listView:removeAllItems()
	itemmodel:release()
end

function DetailBox:initTitleNode()
	self.titleNode = self.mainLayer:getChildByName("titlenode")

	local left = self.titleNode:getChildByName("left")
	local mid = self.titleNode:getChildByName("mid")
	local right = self.titleNode:getChildByName("right")

	local titlelist = {left,mid,right}
	for i,item in ipairs(titlelist) do
		WidgetUtils.addClickEvent(item,function ()
			if item:getChildByName("select"):isVisible() then
				return
			end 
			for _,v in ipairs(titlelist) do
				v:getChildByName("select"):setVisible(false)
			end
			item:getChildByName("select"):setVisible(true)

			for _,v in ipairs(self.nodeList) do
				v:setVisible(false)
			end
			if self.nodeList[i] then
				self.nodeList[i]:setVisible(true)
			end

			if i == 2 then
				self:getAwardList()
			end
		end)
	end
end

function DetailBox:refreshDetailNode(data)
	local matchname = self.mainLayer:getChildByName("matchname")

	local namelabel = self.detailNode:getChildByName("namelabel")
	local periodlabel = self.detailNode:getChildByName("periodlabel")
	local timelabel = self.detailNode:getChildByName("timelabel")
	local playlabel = self.detailNode:getChildByName("playlabel")
	local costlabel = self.detailNode:getChildByName("costlabel")

	matchname:setString(data.name)
	namelabel:setString(data.name)
	playlabel:setString(GT_INSTANCE:getGameName(MATCHMAP[data.game_type] or data.game_type))
	periodlabel:setString("每天")
	timelabel:setString("满3人开赛")
	costlabel:setString("房卡x"..(data.cost_num or 0))

	WidgetUtils.addClickEvent(self.signBtn,function ()
		if data.cost_num > 0 then
			LaypopManger_instance:PopBox("MatchConfirmBox",data.cost_num or 0,function ()
				Socketapi.requestQuickMatch(self.id)
			end)
		else
			Socketapi.requestQuickMatch(self.id)
		end
	end)
end

function DetailBox:refreshAwardNode(data)
	self.listView:removeAllItems()

	for i,v in ipairs(data.list or {}) do
		self.listView:pushBackDefaultItem()

		local item = self.listView:getItem(i-1)

		local rank = item:getChildByName("rank")
		local award = item:getChildByName("award")

		if v.min_ord == v.max_ord then
			rank:setString("第"..v.min_ord.."名")
		else
			rank:setString("第"..v.max_ord.."-"..v.min_ord.."名")
		end
		
		local cardnum = 0

		for _,n in ipairs(v.list or {}) do
			if n.item_type == 1 then
				cardnum = n.num
				break
			end
		end
		award:setString("x"..cardnum)
	end
end

function DetailBox:refreshRuleNode(data)
	local label = self.ruleNode:getChildByName("label")

	label:setString(data.rule)
end

function DetailBox:onEnter()
	self:getConf()
end

function DetailBox:getConf(id)
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.MATCHGETDETAIL,{uid = LocalData_instance.uid,id = self.id},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end

		self.data = msg.list
		self:refreshDetailNode(msg.list)
		self:refreshRuleNode(msg.list)
	end)
end

function DetailBox:getAwardList()
	if self.awardNode.isinit then
		return
	end

	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.MATCHGETAWARDLIST,{uid = LocalData_instance.uid,id = self.id},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end
		self.awardNode.isinit = true
		self:refreshAwardNode(msg)
	end)
end

return DetailBox