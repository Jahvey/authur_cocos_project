local PrizeListView = class("PrizeListView2",PopboxBaseView)
function PrizeListView:ctor(data,headnode)
	self.headnode = headnode
	self.data = data
	self:initView()

	self:registerScriptHandler(function(state)
		if state == "enter" then
			self:getListData(0)
		elseif state == "exit" then
			if self.item then
				self.item:release()
			end
		end
	end)
end
function PrizeListView:initView()
	self.widget = cc.CSLoader:createNode("newyear/PrizeListView2.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("close"), function( )
		LaypopManger_instance:back()
	end)

	-- self.mainLayer:getChildByName("pic0"):setVisible(false)
	-- self.mainLayer:getChildByName("pic1"):setVisible(false)
	-- self.mainLayer:getChildByName("pic"..self.data.itemtype):setVisible(true)

	self.tip1 = self.mainLayer:getChildByName("tip1"):setString("恭喜以下玩家获得"..self.data.title)
	self.tip2 = self.mainLayer:getChildByName("tip2")

	local scrollview = self.mainLayer:getChildByName("scrollview")

	self.setnode = scrollview:getChildByName("contentnode")

	scrollview:addEventListener(function(sender, eventType)
        local event = {}
        if eventType == 9 then
        	-- print(sender:getInnerContainer():getPositionY())
        	if sender:getInnerContainer():getPositionY() > -200 then
        		self:getListData(self.nextpage)
        	end
        end
    end)

	self.item = scrollview:getChildByName("item")
	self.item:retain()
	self.item:removeFromParent()
	
end

-- function PrizeListView:refreshView(data)
-- 	local infonode = self.mainLayer:getChildByName("infonode")

-- 	local headicon = infonode:getChildByName("headicon")
-- 	local name = infonode:getChildByName("name")
-- 	local id = infonode:getChildByName("id")

-- 	local tip1 = infonode:getChildByName("tip1")
-- 	local tip2 = infonode:getChildByName("tip2")
	
-- 	tip1:setString("恭喜获得IPHONE8一台")
-- 	tip2:setString("请在十日内联系客服领取奖励")
-- end

function PrizeListView:insertToList(list,page)
	local scrollview = self.mainLayer:getChildByName("scrollview")

	local curnum = #list
	local lastnum = self.totalnum or 0
	self.totalnum = lastnum + curnum
	local now = scrollview:getInnerContainerPosition()
	printTable(now,"pbz")

	-- local topitem = self.setnode:getChildByName("topitem"):setPositionY(0)
	-- local topheight = topitem:getContentSize().height
	local itemheight = self.item:getContentSize().height
	totalheight = itemheight*math.ceil(self.totalnum/3)

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
		local heightdiff = 0
		heightdiff = totalheight - math.ceil(lastnum/3)*itemheight
		scrollview:jumpToTop()
		scrollview:setInnerContainerPosition(cc.p(now.x,math.max(now.y-heightdiff,viewsize.height-height)))
		printTable(scrollview:getInnerContainerPosition(),"pbz")
	end

	-- for i=1,3 do
	-- 	self.setnode:getChildByName("vline_"..i):setContentSize(cc.size(2,height)):setPositionY(0)
	-- end
	
	local posy = -(math.floor(lastnum/3)*itemheight)
	for i,v in ipairs(list) do
		local index = lastnum + i
		local item = self.item:clone()
		item:addTo(self.setnode)
			:setPosition(cc.p(0+((index-1)%3*self.item:getContentSize().width),posy))

		local head = item:getChildByName("infonode"):getChildByName("headicon")
		local name = item:getChildByName("infonode"):getChildByName("name")
		local id = item:getChildByName("infonode"):getChildByName("id")

		name:setString(CommonUtils:base64(v.name,true))
		id:setString("ID:"..v.uid)
		-- ID:setString(v.uid)
		-- num:setString("x"..v.num)
		require("app.ui.common.HeadIcon").new(head,v.pic)

		if index%3 == 0 then
			posy = posy - itemheight
		end
	end

end

function PrizeListView:getListData(page)
	if self.isrequest then
		return
	end
	if self.isover then
		return
	end
	self.isrequest = true
	self:showSmallLoading()
	print("===========request")
	ComHttp.httpPOST(ComHttp.URL.YEARCONFIG65,{uid = LocalData_instance.uid,page = page or 0,pid = self.data.id},function(msg)
		print("page======",page)
		printTable(msg,"pbz")
		if not WidgetUtils:nodeIsExist(self) then
			return
		end
		if #msg.list < 20 then
			self.isover = true
		end

		self:hideSmallLoading()
		self.isrequest = false
		self.nextpage = msg.page
		self:insertToList(msg.list,page)
		
		self.tip2:setString(msg.str)
	end)
end

return PrizeListView