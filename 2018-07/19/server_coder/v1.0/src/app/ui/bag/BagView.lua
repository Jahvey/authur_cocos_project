local BagView = class("BagView",require "app.module.basemodule.BasePopBox")

function BagView:initData()
	self.scrollViewList = {}
	self.data = {}
	self.selectItem = nil
end

function BagView:initView()
	self.widget = cc.CSLoader:createNode("ui/bag/bagview.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	self:initRightNode()
	self:initLeftNode()
end

function BagView:initLeftNode()
	self.leftNode = self.mainLayer:getChildByName("leftnode")

	self.pageList = {
		{node = self.leftNode:getChildByName("page_1"),typ = 1,},
		{node = self.leftNode:getChildByName("page_2"),typ = 2,},
	}

	self.scrollView = self.leftNode:getChildByName("scrollview")
	self.scrollViewPos = cc.p(self.scrollView:getPositionX(),self.scrollView:getPositionY())
	self.item = self.scrollView:getChildByName("item")

	self.item:retain()
	self.item:removeFromParent()

	self.scrollView:retain()
	self.scrollView:removeFromParent()

	for i,page in ipairs(self.pageList) do
		WidgetUtils.addClickEvent(page.node,function ()
			self:clickPage(page)
		end)

		if i == 1 then
			self:clickPage(page)
		end
	end
end

function BagView:initRightNode()
	self.rightNode = self.mainLayer:getChildByName("rightnode")

	self.rightNode.img = self.rightNode:getChildByName("img"):ignoreContentAdaptWithSize(true)
	self.rightNode.name = self.rightNode:getChildByName("name")
	self.rightNode.des = self.rightNode:getChildByName("des")
	self.rightNode.btn = self.rightNode:getChildByName("btn")
end

function BagView:refreshView()
	self:refreshLeftNode()
end

function BagView:refreshLeftNode()
	self:refreshPage(self.selectPage)
	self:refreshRightNode()
end

function BagView:clickPage(page)
	if not page.scrollView then
		page.scrollView = self.scrollView:clone()
			:addTo(self.leftNode)
			:setPosition(self.scrollViewPos)

		self:refreshPage(page)
	end

	for i,v in ipairs(self.pageList) do
		v.node:getChildByName("unselect"):setVisible(true)
		v.node:getChildByName("select"):setVisible(false)

		if v.scrollView then
			v.scrollView:setVisible(false)
		end
	end

	page.node:getChildByName("unselect"):setVisible(false)
	page.node:getChildByName("select"):setVisible(true)
	page.scrollView:setVisible(true)
	self.selectPage = page

	self:refreshRightNode()
end

function BagView:refreshPage(page)
	page.update = false

	local count = 0
	local contentnode = page.scrollView:getChildByName("node")

	page.scrollView.itemList = {}
	contentnode:removeAllChildren()

	for i,v in ipairs(self.data) do
		if v.functype == page.typ then
			count = count + 1

			local item = self.item:clone()
				:addTo(contentnode)
				:setPosition(cc.p((i-1)%4*self.item:getContentSize().width,-(math.ceil(count/4)-1)*self.item:getContentSize().height-20))
			item.data = v

			self:setItem(item)

			table.insert(page.scrollView.itemList,item)
		end
	end

	local totalheight = math.ceil(count/4)*self.item:getContentSize().height+20
	page.scrollView:setInnerContainerSize(cc.size(page.scrollView:getContentSize().width,totalheight))

	contentnode:setPosition(cc.p(0,page.scrollView:getInnerContainerSize().height))
end

function BagView:setItem(item)
	local img = item:getChildByName("img"):ignoreContentAdaptWithSize(true):setScale(1)
	local num = item:getChildByName("num")
	local lock = item:getChildByName("lock")
	local new = item:getChildByName("new")
	
	local using = item:getChildByName("using")

	-- 0:无状态 1:已使用 2:new
	if item.data.status == 0 then
		using:setVisible(false)
		new:setVisible(false)
	elseif item.data.status == 1 then
		using:setVisible(true)
		new:setVisible(false)
	elseif item.data.status == 2 then
		using:setVisible(false)
		new:setVisible(true)
	end

	if item.data.type == 201 then
		img:setScale(0.84)
	end

	-- name:setString(item.data.name)
	num:setString("/"..item.data.num)
	NetPicUtils.getPic(img, item.data.img)

	WidgetUtils.addClickEvent(item,function ()
		self:clickItem(item)
	end)

	function item:setSelect(bool)
		local board_g = self:getChildByName("board_g")
		local board_y = self:getChildByName("board_y")
		local border  = self:getChildByName("border")
		board_g:setVisible(not bool)
		board_y:setVisible(bool)
		border:setVisible(bool)
	end
end

function BagView:clickItem(item)
	if self.selectPage.selectItem then
		self.selectPage.selectItem:setSelect(false)
	end

	self.selectPage.selectItem = item
	self.selectPage.selectItem:setSelect(true)

	if self.selectPage.selectItem.data.status == 2 then
		self.selectPage.selectItem.data.status = 0
		self:setItem(self.selectPage.selectItem)
	end

	self:refreshRightNode()

	self:getItemData(item)
end

function BagView:refreshRightNode()
	if not self.selectPage.selectItem or not WidgetUtils:nodeIsExist(self.selectPage.selectItem) then
		self.rightNode.name:setString("")
		self.rightNode.img:setVisible(false)
		self.rightNode.btn:setVisible(false)
		self.rightNode.des:setString("")
		return
	end

	local data = self.selectPage.selectItem.data

	self.rightNode.name:setString(data.name)

	self.rightNode.img:setVisible(false)
	NetPicUtils.getPic(self.rightNode.img, data.img)

	self.rightNode.btn:setVisible(true)

	local text_open = self.rightNode.btn:getChildByName("text_open")
	local text_use = self.rightNode.btn:getChildByName("text_use")
	local text_use_gray = self.rightNode.btn:getChildByName("text_use_gray")
	local text_unuse = self.rightNode.btn:getChildByName("text_unuse")
	if data.functype == 1 then
		self.rightNode.btn:setEnabled(true)
		text_open:setVisible(true)
		text_use:setVisible(false)
		text_use_gray:setVisible(false)
		text_unuse:setVisible(false)
		WidgetUtils.addClickEvent(self.rightNode.btn,function ()
			local item = self.selectPage.selectItem
			if data.num > 1 then
				LaypopManger_instance:PopBox("BagOpenBox",data,function (num)
					self:useItem(item,num)
				end)
			else
				self:useItem(item,1)
			end
		end)
	else
		text_open:setVisible(false)
		if data.status == 1 then
			self.rightNode.btn:setEnabled(true)
			text_use:setVisible(false)
			text_use_gray:setVisible(false)
			text_unuse:setVisible(true)
			WidgetUtils.addClickEvent(self.rightNode.btn,function ()
				local item = self.selectPage.selectItem

				self:unuseItem(item)
			end)
		else
			self.rightNode.btn:setEnabled(true)
			text_use:setVisible(true)
			text_use_gray:setVisible(false)
			text_unuse:setVisible(false)
			WidgetUtils.addClickEvent(self.rightNode.btn,function ()
				local item = self.selectPage.selectItem

				self:useItem(item,1)
			end)
		end

		
	end

	self.rightNode.des:setString(self.selectPage.selectItem.data.content or "")
end

function BagView:getList()
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.BAGGETLIST,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self:hideSmallLoading()

		for i,v in ipairs(self.pageList) do
			if v.scrollView then
				v.scrollView.update = true
			end
		end

		self.data = msg.list
		self:refreshView()
	end)
end

function BagView:getItemData(item)
	if item.getDetail or item.requesting then
		return
	end

	item.requesting = true
	ComHttp.httpPOST(ComHttp.URL.BAGGETINFO,{uid = LocalData_instance.uid,itemid = item.data.itemid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(item) then
			return
		end

		item.getDetail = true
		item.requesting = false

		for k,v in pairs(msg) do
			item.data[k] = v
		end

		self:setItem(item)
		self:refreshRightNode()
	end)
end

local TIP = {
	[2] = "速度太快,请稍后再试！",
	[3] = "该物品不存在",
	[4] = "使用失败！",
	[5] = "已经装备了该物品！",
	[6] = "数量不足！",
}

function BagView:useItem(item,num)
	if item.requesting then
		return
	end

	item.requesting = true
	ComHttp.httpPOST(ComHttp.URL.BAGUSEITEM,{uid = LocalData_instance.uid,itemid = item.data.itemid,num = num},function(msg)
		printTable(msg)

		if not WidgetUtils:nodeIsExist(item) then
			return
		end
		item.requesting = false
		if msg.status == 1 then
			if item.data.functype == 2 then
				for i,v in ipairs(item:getParent():getParent():getParent().itemList) do
					if v.data.functype == 2 and v.data.type == item.data.type then
						v.data.status = 0
						self:setItem(v)
					end
				end
				item.data.status = 1

				local equips = LocalData_instance:get("items_info")
				if equips and equips ~= "" then
					equips = cjson.decode(equips)
				else
					equips = {}
				end

				for i=#equips,1,-1 do
					local data = ItemConf:getItemData(equips[i])

					if data and data.type == item.data.type then
						table.remove(equips,i)
					end
				end

				table.insert(equips,tonumber(msg.items_info))
				LocalData_instance:set({items_info = cjson.encode(equips)})

				if item.data.type == 201 then
					if cc.Director:getInstance():getRunningScene().HallView then
						cc.Director:getInstance():getRunningScene().HallView:refreshView()
					end
				end
			elseif item.data.functype == 1 then
				item.data.num = item.data.num - num
			end
			
			if item.data.num > 0 then
				self:setItem(item)
				self:refreshRightNode()
			else
				self:refreshView()
			end
		else
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = TIP[msg.status] or ""})
		end
	end)
end

local TIP2 = {
	[2] = "速度太快,请稍后再试！",
	[3] = "该物品不存在",
	[4] = "操作失败！",
	[5] = "未装备该物品！",
	[6] = "数量不足！",
}

function BagView:unuseItem(item)
	if item.requesting then
		return
	end

	item.requesting = true
	ComHttp.httpPOST(ComHttp.URL.BAGUNUSEITEM,{uid = LocalData_instance.uid,itemid = item.data.itemid},function(msg)
		printTable(msg)

		if not WidgetUtils:nodeIsExist(item) then
			return
		end
		item.requesting = false
		if msg.status == 1 then
			if item.data.functype == 2 then
				item.data.status = 0

				local equips = LocalData_instance:get("items_info")
				if equips and equips ~= "" then
					equips = cjson.decode(equips)
				else
					equips = {}
				end

				for i=#equips,1,-1 do
					local data = ItemConf:getItemData(equips[i])

					if data and data.type == item.data.type then
						table.remove(equips,i)
					end
				end

				LocalData_instance:set({items_info = cjson.encode(equips)})

				if item.data.type == 201 then
					if cc.Director:getInstance():getRunningScene().HallView then
						cc.Director:getInstance():getRunningScene().HallView:refreshView()
					end
				end
			end
			
			self:setItem(item)
			self:refreshRightNode()
			
		else
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = TIP2[msg.status] or ""})
		end
	end)
end

function BagView:onEnter()
	self:getList()
end

function BagView:onExit()
end

return BagView