local RankListView = class("RankListView",PopboxBaseView)

function RankListView:ctor()
	self:initView()
end

function RankListView:initView()
	self.widget = cc.CSLoader:createNode("ui/rankList/RankListView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	self.listView = self.mainLayer:getChildByName("listview")

	local rulebtn = self.mainLayer:getChildByName("rulebtn")
	local rulebg = rulebtn:getChildByName("rulebg")
	local touchlayer = rulebg:getChildByName("touch"):setVisible(false)

	WidgetUtils.addClickEvent(rulebtn,function ()
		if rulebg:isVisible() then
			rulebg:setVisible(false)
			touchlayer:setVisible(false)
		else
			rulebg:setVisible(true)
			touchlayer:setVisible(true)


			userdata={}
			userdata.cid=7
			userdata.pid=79
			userdata.json={
				["type"]="7.点击规则"

		    }
		    CommonUtils.sends(userdata)
		end




	end)

	local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)   
    listener:registerScriptHandler(function(touch, event)
    	rulebg:setVisible(false)
    	touchlayer:setVisible(false)
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = touchlayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchlayer)

	self.item = self.mainLayer:getChildByName("itembg")
	self.item:retain()
	self.listView:setItemModel(self.item)
	self.item:removeFromParent()
	self.item:release()

	self.listView:removeAllItems()

	local headicon = self.mainLayer:getChildByName("myRank"):getChildByName("headicon"):setScale(0.7)
	local nameLabel = self.mainLayer:getChildByName("myRank"):getChildByName("namelabel"):setString(LocalData_instance.nick)
	require("app.ui.common.HeadIcon").new(headicon,LocalData_instance.pic)

	self.myRankIndex = self.mainLayer:getChildByName("myRank"):getChildByName("left_info"):getChildByName("index")
	self.myRankNum = self.mainLayer:getChildByName("myRank"):getChildByName("right_info"):getChildByName("mynum")

	self:initTitle()

end


function RankListView:initTitle()

	local titlebg = self.mainLayer:getChildByName("titlebg")

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
			self:requestDailyRank()
		end
	end)

	right_off:setTouchEnabled(true)
	right_off:addTouchEventListener(function (widget, event)
		if event == ccui.TouchEventType.ended then
			if self.right_on:isVisible() then
				return
			end
			self:requestWeekRank()
		end
	end)

end


function RankListView:refreshListView(data)
	self.listView:removeAllItems()
	if data.list then
		for i,v in ipairs(data.list) do

			self.listView:pushBackDefaultItem()
			local item = self.listView:getItem(i-1)

			local headicon = item:getChildByName("headicon"):setScale(0.7)
			local nameLabel = item:getChildByName("namelabel"):setString(CommonUtils:base64(v.nickname,true))
			local desclabel = item:getChildByName("desclabel"):setString("玩牌局数："..v.num)
			local ranknum = item:getChildByName("ranknum"):setVisible(false)
			local rankimg = item:getChildByName("rankimg"):setVisible(false)

			require("app.ui.common.HeadIcon").new(headicon,v.img)
			
			if i <= 3 and i >= 1 then
				rankimg:setVisible(true)
				rankimg:loadTexture("res/cocostudio/ui/rankList/"..i..".png")
			else
				ranknum:setVisible(true)
				ranknum:setString(i)
			end
		end
		if data.myrank then
		else
			data.myrank = 0
		end

		self.myRankIndex:setString("第"..data.myrank.."名")
		self.myRankNum:setString("玩牌局数："..data.mysocre)
	end
end


function RankListView:requestDailyRank()
	print(".........请求每日排行榜")
	self:showSmallLoading()
	self.right_on:setVisible(false)
	self.left_on:setVisible(true)

	ComHttp.httpPOST(ComHttp.URL.DAILYRANK,{uid = LocalData_instance.uid,date = 0,page = 1},function(msg)
			if not WidgetUtils:nodeIsExist(self) then
				return
			end
			-- printTable(msg,"xp")

			self:refreshListView(msg)
			self:hideSmallLoading()
		end)
end

function RankListView:requestWeekRank()
	print(".........请求每周排行榜")
	self:showSmallLoading()
	self.right_on:setVisible(true)
	self.left_on:setVisible(false)


	userdata={}
	userdata.cid=7
	userdata.pid=80
	userdata.json={
		["type"]="7.点击本周排行"

    }
    CommonUtils.sends(userdata)
	ComHttp.httpPOST(ComHttp.URL.GETUSERRANK,{uid = LocalData_instance.uid},function(msg)
			if not WidgetUtils:nodeIsExist(self) then
				return
			end
			-- printTable(msg,"xp")
			self:refreshListView(msg)
			self:hideSmallLoading()
		end)
end



function RankListView:onEndAni()
	self:requestDailyRank()
end

return RankListView