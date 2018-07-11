local NoticeActView = class("NoticeActView",PopboxBaseView)

local JUMP_ENUM = {
	[2] = function () LaypopManger_instance:PopBox("Setrealname") end,
	[3] = function () LaypopManger_instance:PopBox("MeiriActivity") end,
}

function NoticeActView:ctor()
	self:initView()
end

function NoticeActView:initView()
	self.widget = cc.CSLoader:createNode("ui/notice/noticeActView.csb")
	self:addChild(self.widget)	

	self.mainLayer = self.widget:getChildByName("main")

	local closebtn = self.mainLayer:getChildByName("closeBtn")

	WidgetUtils.addClickEvent(closebtn,function ()
		LaypopManger_instance:back()
		CommonUtils.requsetRedPoint()
	end)

	self.mainLayer:getChildByName("bg"):setTouchEnabled(true)

	self.contentbg = self.mainLayer:getChildByName("contentbg")
	self.textbg = self.contentbg:getChildByName("textbg"):setVisible(false)
	self.scrollview = self.contentbg:getChildByName("scrollview")
	self.actimg =  self.contentbg:getChildByName("actimg"):ignoreContentAdaptWithSize(true):setTouchEnabled(true)
	self.noticeimg = self.scrollview:getChildByName("textimg"):ignoreContentAdaptWithSize(true)
	self.actimg:setVisible(false)
	self.noticeimg:setVisible(false)


	self:initData()
	self:initTitle()
	self:initListView()
	self:initDownEvent()
end

function NoticeActView:initData()
	self.curData = {}
	self.listData = {
		["1"] = {list = {}},
		["2"] = {list = {}},
		show = 1,
	}
end

function NoticeActView:initTitle()
	local titlebg = self.mainLayer:getChildByName("titlebg")

	self.leftpoint = titlebg:getChildByName("redpoint1")
	self.rightpoint = titlebg:getChildByName("redpoint2")

	self.left_on = titlebg:getChildByName("left_on")
	local left_off = titlebg:getChildByName("left_off")

	self.right_on = titlebg:getChildByName("right_on"):setVisible(false)
	local right_off = titlebg:getChildByName("right_off")

	left_off:setTouchEnabled(true)
	left_off:addTouchEventListener(function (widget, event)
		if event == ccui.TouchEventType.ended then
			if self.left_on:isVisible() then
				return
			end
			self:changeToAct()
			userdata={}
			userdata.cid=8
			userdata.pid=82
			userdata.json={
				["type"]="8.弹出精彩活动"

		    }
		    CommonUtils.sends(userdata)
		end
	end)

	right_off:setTouchEnabled(true)
	right_off:addTouchEventListener(function (widget, event)
		if event == ccui.TouchEventType.ended then
			if self.right_on:isVisible() then
				return
			end
			self:changeToNotice()
			userdata={}
			userdata.cid=8
			userdata.pid=83
			userdata.json={
				["type"]="8.点击游戏公告"

		    }
		    CommonUtils.sends(userdata)
		end
	end)
end

function NoticeActView:initListView()
	local listview = WidgetUtils.getNodeByWay(self.mainLayer,{"listviewbg","listview"})
	self.listView = listview
	listview:setScrollBarEnabled(false)

	local toparrow = WidgetUtils.getNodeByWay(self.mainLayer,{"listviewbg","arrowup"}):setVisible(false)
	local bottomarrow = WidgetUtils.getNodeByWay(self.mainLayer,{"listviewbg","arrowdown"}):setVisible(false)

	local item = listview:getChildByName("item")
	item:retain()
	listview:setItemModel(item)
	item:removeFromParent()
	item:release()

	listview:removeAllItems()
end

function NoticeActView:initDownEvent()
	self.noticeimg.downcallback = function ()
		self:hideSmallLoading()
		local height = self.noticeimg:getContentSize().height

		if height > self.scrollview:getContentSize().height then
			self.scrollview:setInnerContainerSize(cc.size(self.scrollview:getContentSize().width,height))
			self.noticeimg:setPositionY(height)
		else
			self.scrollview:setInnerContainerSize(cc.size(self.scrollview:getContentSize().width,self.scrollview:getContentSize().height))
			self.noticeimg:setPositionY(self.scrollview:getContentSize().height)
		end
	end

	self.actimg.downcallback = function ()
		self:hideSmallLoading()
	end
end

function NoticeActView:refreshListView(data)
	self.listitem = {}
	self.selectid = nil
	self.listView:removeAllItems()
	-- self.bottomarrow:setVisible(false)
	-- self.toparrow:setVisible(false)

	if not data then
		return
	end

	for i,v in ipairs(data) do

		self.listView:pushBackDefaultItem()
		local item = self.listView:getItem(i-1)
		item.id = v.id

		local title = item:getChildByName("titletext"):setString(v.name)
		local redpoint = item:getChildByName("redpoint")

		if v.redpoint == 1 then
			redpoint:setVisible(true)
		end

		item:setTouchEnabled(true)
		item:addTouchEventListener(function (widget, event)
			if event == ccui.TouchEventType.ended then
				self:clickListItem(v.id)
			end
		end)
		table.insert(self.listitem,item)
	end

	local innersize = self.listView:getInnerContainer():getContentSize()
	if #self.listView:getItems() <= 4 then
	else
		-- self.bottomarrow:setVisible(true)
	end	
	self.listView:jumpToTop()
end

function NoticeActView:clickListItem(id)
	if id and self.selectid and id == self.selectid then
		return
	end

	local clickfirstitem = false
	if not id then
		clickfirstitem = true
	end

	for i,v in ipairs(self.listitem) do
		if (i == 1 and clickfirstitem) or (id and id == v.id) then
			v:loadTexture("cocostudio/ui/common/createroom_2.png",ccui.TextureResType.localType)
			v:getChildByName("titletext"):setColor(cc.c3b(0xff,0xff,0xff))
			-- v:getChildByName("titletext"):enableOutline(cc.c3b(0xff,0xff,0xff),1)
			v:getChildByName("titletext"):enableShadow(cc.c3b(0xff,0xff,0xff),cc.size(1,-1))

			self.selectid = v.id
			self:getMsgInfo(v.id)
			v:getChildByName("redpoint"):setVisible(false)
			for m,n in ipairs(self.curData.list) do
				if n.id == v.id then
					n.redpoint = 0
					break
				end
			end
		else
			v:loadTexture("cocostudio/ui/common/createroom_3.png",ccui.TextureResType.localType)
			v:getChildByName("titletext"):setColor(cc.c3b(0x7e,0x44,0x15))
			-- v:getChildByName("titletext"):enableOutline(cc.c3b(0x7e,0x44,0x15),1)
			v:getChildByName("titletext"):enableShadow(cc.c3b(0x7e,0x44,0x15),cc.size(1,-1))
		end
	end

	local hasredpoint = false
	if self.listData["1"].list then
		for i,v in ipairs(self.listData["1"].list) do
			if v.redpoint == 1 then
				self.leftpoint:setVisible(true)
				hasredpoint = true
				break
			else
				self.leftpoint:setVisible(false)
			end
		end
	end

	if self.listData["2"].list then
		for i,v in ipairs(self.listData["2"].list) do
			if v.redpoint == 1 then
				self.rightpoint:setVisible(true)
				hasredpoint = true
				break
			else
				self.rightpoint:setVisible(false)
			end
		end
	end

	if hasredpoint then
		HASREDPOINT = true
	else
		HASREDPOINT = false
	end
end

function NoticeActView:changeToNotice()
	self.left_on:setVisible(false)
	self.right_on:setVisible(true)

	self:hideSmallLoading()
	-- self.textbg:setVisible(true)
	self.scrollview:setVisible(true)
	self.actimg:setVisible(false)

	self.curData = self.listData["2"]

	self:refreshListView(self.curData.list)

	self:clickListItem(self.curData.show)
end

function NoticeActView:changeToAct()
	self.left_on:setVisible(true)
	self.right_on:setVisible(false)
	self:hideSmallLoading()
	-- self.textbg:setVisible(false)
	self.scrollview:setVisible(false)
	self.actimg:setVisible(true)

	self.curData = self.listData["1"]

	self:refreshListView(self.curData.list)

	self:clickListItem(self.curData.show)

	if not self.curData.list then
		self.actimg:loadTexture("cocostudio/ui/notice/noact.png")
	end
end

function NoticeActView:getListInfo()
	self:showSmallLoading()

	ComHttp.httpPOST(ComHttp.URL.GETNOTICELIST,{uid = LocalData_instance.uid},function(msg)
			if not WidgetUtils:nodeIsExist(self) then
				return
			end
			printTable(msg,"xp")
			self.listData = msg
			
			if tonumber(msg.show) == 2 then
				self:changeToNotice()
			else
				self:changeToAct()
			end

		end)
end

function NoticeActView:getMsgInfo(id)
	self:showSmallLoading()
	self.noticeimg:loadTexture("cocostudio/ui/common/null.png")
	self.actimg:loadTexture("cocostudio/ui/common/null.png")

	ComHttp.httpPOST(ComHttp.URL.GETNOTICEINFO,{uid = LocalData_instance.uid,id = id},function(msg)
			if not WidgetUtils:nodeIsExist(self) then
				return
			end
			-- printTable(msg,"sjp3")

			if self.selectid ~= msg.jid then
				return
			end
			print("..............下载地址～～～msg.img ＝ ",msg.img)

			if self.scrollview:isVisible() then
				NetPicUtils.getPic(self.noticeimg,msg.img)
			elseif self.actimg:isVisible() then
				self.actimg.downcallback = function ()
					self:hideSmallLoading()
					self:addEventToActImg(msg)
				end
				NetPicUtils.getPic(self.actimg,msg.img)
			end
		end)
end

function NoticeActView:addEventToActImg(data)
	self.actimg:addTouchEventListener(function (widget, event)
		-- print("touch===========================")
		if data.jump == 1 then
			if event == ccui.TouchEventType.ended then
				if self.selectid == data.jid then
					if JUMP_ENUM[data.eid] then
						LaypopManger_instance:back()
						JUMP_ENUM[data.eid]()
						CommonUtils.requsetRedPoint()
					end
				end
			end
		end
	end)
end
function NoticeActView:onEndAni()
	self:getListInfo()
end

return NoticeActView