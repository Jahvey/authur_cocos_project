local MatchView = class("MatchView",require "app.module.basemodule.BasePopBox")

function MatchView:initData()
end

function MatchView:initView()
	self.widget = cc.CSLoader:createNode("ui/match/matchview.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")

	WidgetUtils.setScalepos(self.mainLayer)
	local bg = self.mainLayer:getChildByName("bg")
	bg:setScale9Enabled(true)
	bg:setCapInsets(cc.rect(0,0,1280,720))
	bg:setContentSize(cc.size(display.width,display.height))
	
	self:initTopNode()
	self:initLeftNode()
	self:initRightNode()
end

function MatchView:initTopNode()
	self.topNode = self.mainLayer:getChildByName("topnode")

	local backbtn = self.topNode:getChildByName("backbtn")
	WidgetUtils.addClickEvent(backbtn,function ()
		LaypopManger_instance:back()
	end)

	local recordbtn = self.topNode:getChildByName("recordbtn")
	WidgetUtils.addClickEvent(recordbtn,function ()
		LaypopManger_instance:PopBox("MatchRecordlBox")
	end)
end

function MatchView:initLeftNode()
	self.leftNode = self.mainLayer:getChildByName("leftnode")
end

function MatchView:initRightNode()
	self.rightNode = self.mainLayer:getChildByName("rightnode")
	self.rightNode.listViews = {}

	self.listView = self.rightNode:getChildByName("listview")

	local itemmodel = self.listView:getChildByName("item")
	itemmodel:retain()
	self.listView:setItemModel(itemmodel)
	self.listView:removeAllItems()
	itemmodel:release()

	self.listPos = cc.p(self.listView:getPositionX(),self.listView:getPositionY())
	self.listView:retain()
	self.listView:removeFromParent()
end

function MatchView:refreshLeft(data)
	self.leftNode.itemList = {}

	for i=1,#data.list do
		local item = self.leftNode:getChildByName("item"..i):setVisible(true)
		item.data = data.list[i]
		item.idx = i

		item:getChildByName("img"):ignoreContentAdaptWithSize(true):loadTexture("ui/match/text_"..data.list[i].type..".png")
		item:getChildByName("select"):getChildByName("img_s"):ignoreContentAdaptWithSize(true):loadTexture("ui/match/text_"..data.list[i].type.."_s.png")

		table.insert(self.leftNode.itemList,item)
		WidgetUtils.addClickEvent(item,function ()
			self:clickTitle(item)
		end)

		if i == 1 then
			self:clickTitle(item)
		end
	end

end

function MatchView:refreshRight(idx,data)
	
	self.rightNode.listViews[idx].itemList = {}
	self.rightNode.listViews[idx]:removeAllItems()

	for i,v in ipairs(data.list or {}) do
		self.listView:pushBackDefaultItem()

		local item = self.listView:getItem(i-1)

		local name = item:getChildByName("name")
		local timetip1 = item:getChildByName("timetip1")
		local timetip2 = item:getChildByName("timetip2")
		local timetip3 = item:getChildByName("timetip3")
		local curnum = item:getChildByName("curnum")
		local totalnum = item:getChildByName("totalnum")
		local cardnum = item:getChildByName("cardnum")
		local signbtn = item:getChildByName("signbtn")
		local exitbtn = item:getChildByName("exitbtn")

		name:setString(v.name)

		cardnum:setString("x"..(v.cost_num or "0"))
		timetip1:setVisible(true)
		timetip2:setVisible(false)
		timetip3:setVisible(false)
		curnum:setString(v.apply_num)
		totalnum:setVisible(false)

		WidgetUtils.addClickEvent(item, function()
			LaypopManger_instance:PopBox("MatchDetailBox",v.id)
		end)

		WidgetUtils.addClickEvent(signbtn, function ()
			if not v.cost_num or v.cost_num <= 0 then
				Socketapi.requestQuickMatch(v.id)
			else
				LaypopManger_instance:PopBox("MatchConfirmBox",v.cost_num or 0,function ()
					Socketapi.requestQuickMatch(v.id)
				end)
			end
			
		end)

		table.insert(self.rightNode.listViews[idx].itemList, item)
	end
end


function MatchView:clickTitle(item)
	if item:getChildByName("select"):isVisible() then
		return
	end

	for _,v in ipairs(self.leftNode.itemList) do
		v:getChildByName("select"):setVisible(false)
	end

	item:getChildByName("select"):setVisible(true)

	self.rightNode.listViews[item.idx] = self.rightNode.listViews[item.idx] or clone(self.listView):addTo(self.rightNode):setPosition(self.listPos)

	for i,v in ipairs(self.rightNode.listViews) do
		v:setVisible(false)
	end

	self.rightNode.listViews[item.idx]:setVisible(true)

	self:getMatchList(item)
end

function MatchView:onEnter()
	self:getConf()
end

function MatchView:getConf()
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.MATCHGETMAINLIST,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end

		self:refreshLeft(msg)
	end)
end

function MatchView:getMatchList(item)
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.MATCHGETMATCHLIST,{uid = LocalData_instance.uid,type = item.data.type,city_id = GAME_CITY_SELECT},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end

		self:refreshRight(item.idx,msg)
	end)
end

return MatchView