
require "app.ui.newyear.Newyear"
  -- 1花牌 2 
 local ishavefive = true                   
local NewyearView = class("NewyearView",function()
	return cc.Node:create() 
end)
function NewyearView:ctor()
	self:initView()
	self:getdata( )
	self.canshowan = true
	self.listreward = {}

	 local function update()
        self:onUpdate()
    end
    self:scheduleUpdateWithPriorityLua(update, 0)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local listener = cc.EventListenerCustom:create("weixinsharecallback" , function ( evt )
		local output = evt:getDataString()
		if tonumber(output) and tonumber(output) == 0 then
			print("分享成功111")
			if self.issharepy then
				ComHttp.httpPOST(ComHttp.URL.YEARSHARE,{uid = LocalData_instance.uid},function(msg)
					if not WidgetUtils:nodeIsExist(self) then
						return
					end
					self:getdata(1)
				end)
			end
		else
			print("分享失败")
		end
	end)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

	--self:showSmallLoading()
end
function NewyearView:initView()
	local widget = cc.CSLoader:createNode("newyear/huodong.csb")
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")
	WidgetUtils.setBgScale(widget:getChildByName("bg"))
	WidgetUtils.setScalepos(self.mainLayer)
	self.mainLayer:setPosition(cc.p(display.cx,display.cy))
	print("ddddd")

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("return"), function( )
		self:removeFromParent()
	end)

	for i=1,6 do
		self.mainLayer:getChildByName("bg"):getChildByName("node"..i):setVisible(false)
	end
	self.mainLayer:getChildByName("bg"):setVisible(true)
	local function sele( sender, eventType )
		if eventType == ccui.CheckBoxEventType.selected then
            for i=1,6 do
            	local check = self.mainLayer:getChildByName("btnlist"):getChildByName("check"..i)
            	if check then
	            	check:setTouchEnabled(true)
	            	check:setSelected(false)
	            	check:getChildByName("1"):setVisible(true)
	            	check:getChildByName("2"):setVisible(false)
	            	self.mainLayer:getChildByName("bg"):getChildByName("node"..i):setVisible(false)
	            end
            end
            sender:setSelected(true)
            sender:setTouchEnabled(false)
            sender:getChildByName("1"):setVisible(false)
            sender:getChildByName("2"):setVisible(true)
            self.mainLayer:getChildByName("bg"):getChildByName("node"..sender:getTag()):setVisible(true)
            self:showSmallLoading()
            self:getdata(sender:getTag())
        end
	end
	for i=1,6 do
		local check = self.mainLayer:getChildByName("btnlist"):getChildByName("check"..i)
		check:setTag(i)
		check:addEventListener(sele)
	end
	sele( self.mainLayer:getChildByName("btnlist"):getChildByName("check1"), ccui.CheckBoxEventType.selected )
	--有些没有活动5
	if ishavefive == false then
		self.mainLayer:getChildByName("btnlist"):getChildByName("check5"):removeFromParent()
	else
		local cell5 = self.mainLayer:getChildByName("bg"):getChildByName("node5"):getChildByName("cell")
		cell5:setVisible(false)
		self.listview5 = self.mainLayer:getChildByName("bg"):getChildByName("node5"):getChildByName("listview")
		self.listview5:setItemModel(cell5)
	end
	local cell1 = self.mainLayer:getChildByName("bg"):getChildByName("node1"):getChildByName("cell")
	cell1:setVisible(false)
	self.listview1 = self.mainLayer:getChildByName("bg"):getChildByName("node1"):getChildByName("listview")
	self.listview1:setItemModel(cell1)

	local cell3 = self.mainLayer:getChildByName("bg"):getChildByName("node3"):getChildByName("cell")
	cell3:setVisible(false)
	self.listview3 = self.mainLayer:getChildByName("bg"):getChildByName("node3"):getChildByName("listview")
	self.listview3:setItemModel(cell3)


	local cell4 = self.mainLayer:getChildByName("bg"):getChildByName("node4"):getChildByName("cell")
	cell4:setVisible(false)
	self.listview4 = self.mainLayer:getChildByName("bg"):getChildByName("node4"):getChildByName("listview")
	self.listview4:setItemModel(cell4)

	
	self.mainLayer:getChildByName("goldbg"):getChildByName("num"):setVisible(false)
	self.mainLayer:getChildByName("hong"):getChildByName("num"):setVisible(false)
	local node = self.mainLayer:getChildByName("bg"):getChildByName("node2")
	for i,v in ipairs(node:getChildren()) do
		v:setVisible(false)
	end

	for i=1,4 do
		local bg = self.mainLayer:getChildByName("bg"):getChildByName("node6"):getChildByName("scrollview"):getChildByName("layer"):getChildByName("bg"..i)
		if bg then
			bg:setVisible(false)
		end

		local bg = self.mainLayer:getChildByName("bg"):getChildByName("node6"):getChildByName("scrollview"):getChildByName("layer"):getChildByName("card"..i)
		if bg then
			bg:setVisible(false)
		end

		local bg = self.mainLayer:getChildByName("bg"):getChildByName("node6"):getChildByName("scrollview"):getChildByName("layer"):getChildByName("hong"..i)
		if bg then
			bg:setVisible(false)
		end
	end

	self.toptime = self.mainLayer:getChildByName("top"):getChildByName("time")
	self.toptime:setVisible(false)
end

function NewyearView:showSmallLoading()
	if not self.loadingView or not tolua.cast(self.loadingView,"cc.Node") then
		self.loadingView = require "app.ui.popbox.SmallLoadingView".new()
		self.loadingView:setPosition(cc.p(display.cx,display.cy))
		self:addChild(self.loadingView,1)
	else
		self.loadingView:show()
	end
end

function NewyearView:hideSmallLoading()
	if self.loadingView and tolua.cast(self.loadingView,"cc.Node") then
		self.loadingView:setVisible(false)
	end
end


function NewyearView:onUpdate()
	if self.canshowan then
		if #self.listreward > 0 then
			self.canshowan = false
			self:showreward(self.listreward[1])
			table.remove(self.listreward,1)
		end
	end
end

function NewyearView:showreward(data)

	local widget = cc.CSLoader:createNode("newyear/gongxihuode/gongxihuode.csb")
	widget:setPosition(cc.p(display.cx,display.cy))
	self:addChild(widget,2)
	local btn = widget:getChildByName("final"):getChildByName("btn"):getChildByName("btn")
	if data.type == 1 then
		local num = widget:getChildByName("final"):getChildByName("num")
		local icon = widget:getChildByName("final"):getChildByName("baoxiang")
		num:setString(data.num.."个金币")
		icon:ignoreContentAdaptWithSize(true)
		widget:getChildByName("final"):getChildByName("info"):setString("金币限时兑换，活动结束将无效，赶快去兑换吧！")
		if data.num > 20 then
			icon:loadTexture("cocostudio/newyear/coin_4.png", ccui.TextureResType.localType)
		elseif data.num > 6 then
			icon:loadTexture("cocostudio/newyear/coin_3.png", ccui.TextureResType.localType)
		elseif data.num > 1 then
			icon:loadTexture("cocostudio/newyear/coin_2.png", ccui.TextureResType.localType)
		else
			icon:loadTexture("cocostudio/newyear/coin_1.png", ccui.TextureResType.localType)
		end
	elseif data.type == 2 then
		local num = widget:getChildByName("final"):getChildByName("num")
		local icon = widget:getChildByName("final"):getChildByName("baoxiang")
		num:setString("")
		icon:loadTexture("cocostudio/newyear/gong"..data.num..".png", ccui.TextureResType.localType)
		icon:ignoreContentAdaptWithSize(true)
	elseif data.type == 3 then
		local num = widget:getChildByName("final"):getChildByName("num")
		local icon = widget:getChildByName("final"):getChildByName("baoxiang")
		num:setString(data.num.."张")
		icon:loadTexture("cocostudio/newyear/icon_fangka.png", ccui.TextureResType.localType)
		icon:ignoreContentAdaptWithSize(true)
	elseif data.type == 4 then
		local num = widget:getChildByName("final"):getChildByName("num")
		local icon = widget:getChildByName("final"):getChildByName("baoxiang")
		num:setString(data.num.."元")
		icon:loadTexture("cocostudio/newyear/icon_hongbao_big.png", ccui.TextureResType.localType)
		icon:setScale(0.7)
		icon:ignoreContentAdaptWithSize(true)
		widget:getChildByName("final"):getChildByName("info"):setString("活动结束后10日内咨询客服领取")
		if data.tipstr then
			widget:getChildByName("final"):getChildByName("info"):setString(data.tipstr)
		end
	end
	WidgetUtils.addClickEvent(btn, function( )
		self.canshowan = true
		widget:removeFromParent()
	end)

	local action = cc.CSLoader:createTimeline("newyear/gongxihuode/gongxihuode.csb")

    widget:runAction(action)
    action:gotoFrameAndPlay(0,false)

    local action = cc.CSLoader:createTimeline("newyear/gongxihuode/xuanzhuanguang.csd.csb")

    widget:getChildByName("FileNode_1"):runAction(action)
    action:gotoFrameAndPlay(0,true)



end

function NewyearView:getdata(num)
	ComHttp.httpPOST(ComHttp.URL.YEARCOMMON,{uid= LocalData_instance.uid},function(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end
		printTable(msg,"xp") 
       	self:updatamain(msg)
    end)

	if num == 1 then
		 ComHttp.httpPOST(ComHttp.URL.YEARCONFIG1,{uid= LocalData_instance.uid},function(msg)
		 	if not WidgetUtils:nodeIsExist(self) then
				return
			end
		 	printTable(msg,"xp")
		 	self:hideSmallLoading()
	       self:updataone(msg)
	    end)
	elseif  num == 2  then
		ComHttp.httpPOST(ComHttp.URL.YEARCONFIG2,{uid= LocalData_instance.uid},function(msg) 
			if not WidgetUtils:nodeIsExist(self) then
				return
			end
			printTable(msg,"xp")
			self:hideSmallLoading()
	       self:updatatwo(msg)
	    end)
	elseif  num == 3  then
		ComHttp.httpPOST(ComHttp.URL.YEARCONFIG3,{uid= LocalData_instance.uid},function(msg) 
			if not WidgetUtils:nodeIsExist(self) then
				return
			end
			printTable(msg,"xp")
			self:hideSmallLoading()
	       self:updatathree(msg)
	    end)
	elseif  num == 4  then
		ComHttp.httpPOST(ComHttp.URL.YEARCONFIG4,{uid= LocalData_instance.uid},function(msg) 
			if not WidgetUtils:nodeIsExist(self) then
				return
			end
			printTable(msg,"xp")
			self:hideSmallLoading()
	       self:updatafour(msg)
	    end)
	elseif  num == 5  then
		ComHttp.httpPOST(ComHttp.URL.YEARCONFIG5,{uid= LocalData_instance.uid},function(msg) 
			if not WidgetUtils:nodeIsExist(self) then
				return
			end
			printTable(msg,"xp")
			self:hideSmallLoading()
	       self:updatafive(msg)
	    end)
	elseif  num == 6  then
		ComHttp.httpPOST(ComHttp.URL.YEARCONFIG6,{uid= LocalData_instance.uid},function(msg)
			if not WidgetUtils:nodeIsExist(self) then
				return
			end 
			printTable(msg,"xp")
			self:hideSmallLoading()
	       	self:updatasix(msg)
	    end)
	end
	

   

end
function NewyearView:updatamain(msg)
	local gold = self.mainLayer:getChildByName("goldbg"):getChildByName("num")
	gold:setString(msg.gold)
	gold:setVisible(true)

	local rmb = self.mainLayer:getChildByName("hong"):getChildByName("num")
	rmb:setString(msg.money)
	rmb:setVisible(true)

	local function updatatime( )
		local losttime = msg.endtime - os.time()
		self.toptime:setVisible(true)
		if losttime <= 0 then
			self.toptime:setString("00日00时00分")
		else
			local str = ""
			local day = math.floor(losttime/(3600*24))
			if day < 10 then
				str = str.."0"..day.."日"
			else
				str = str..day.."日"
			end
			losttime = losttime%(3600*24)
			local hour = math.floor(losttime/3600)
			if hour < 10 then
				str = str.."0"..hour.."时"
			else
				str = str..hour.."时"
			end
			losttime = losttime%3600
			local min = math.ceil(losttime/60)
			if min < 10 then
				str = str.."0"..min.."分"
			else
				str = str..min.."分"
			end
			self.toptime:setString(str)
		end
	end
	
	updatatime()
	self.mainLayer:stopAllActions()
	self.mainLayer:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( ... )
		updatatime()
	end))))
end
function NewyearView:updataone( msg )
	 self.listview1:removeAllItems()
	 for i,v in ipairs(msg.list) do
	 	self.listview1:pushBackDefaultItem()
        local item = self.listview1:getItem(i-1)
        item:setVisible(true)
        if v.type == 1 then
        	item:getChildByName("info"):setString("春节每日登陆奖励")
        elseif v.type == 2 then
        	item:getChildByName("info"):setString("春节每日完成局数奖励")
        elseif v.type == 3 then
        	item:getChildByName("info"):setString("春节每日分享奖励")
        end
        item:getChildByName("value"):setString(v.gold)
        --v.isget  = 2
        if v.isget == 0 then
        	local btn = item:getChildByName("btn")
        		btn:setVisible(true)
        		btn:getChildByName("share"):setVisible(false)
        		btn:getChildByName("get"):setVisible(true)
        		btn:getChildByName("text"):setVisible(false)
        		item:getChildByName("ling"):setVisible(false)

        		WidgetUtils.addClickEvent(btn, function( )
					print("领取")
					self:showSmallLoading()
					ComHttp.httpPOST(ComHttp.URL.YEARGET1,{uid= LocalData_instance.uid,type = v.type,id = v.id},function(msg) 
						printTable(msg,"xp")
						self:getdata(1)
				       	if msg.status == 1 then
				       		table.insert(self.listreward,{type =1,num = msg.num})
				       		if msg.gettag and msg.gettag ~= 0 then
				       			table.insert(self.listreward,{type =2,num = msg.gettag})
				       		end
				       	else
				       		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = msg.str})
				       	end
				    end)

				end)


        elseif v.isget == 1 then
	        	item:getChildByName("btn"):setVisible(false)
	        	item:getChildByName("ling"):setVisible(true)
        elseif v.isget == 2 then
        	if v.type == 1  then
        		item:getChildByName("btn"):setVisible(false)
        		item:getChildByName("ling"):setVisible(false)
        	elseif v.type == 2  then
        		local btn = item:getChildByName("btn")
        		btn:setVisible(true)
        		btn:setEnabled(false)
        		btn:getChildByName("share"):setVisible(false)
        		btn:getChildByName("get"):setVisible(false)
        		btn:getChildByName("text"):setString(v.num.."/"..v.target)
        		item:getChildByName("ling"):setVisible(false)
        	elseif v.type == 3  then
        		local btn = item:getChildByName("btn")
        		btn:setVisible(true)
        		--btn:setEnabled(false)
        		btn:getChildByName("share"):setVisible(true)
        		btn:getChildByName("get"):setVisible(false)
        		btn:getChildByName("text"):setVisible(false)
        		item:getChildByName("ling"):setVisible(false)
        		WidgetUtils.addClickEvent(btn, function( )
					print("分享")
					self.issharepy = true
					NEWYERRSHREA.sharePyquan( )
				end)
        	end
        end
	 end
end

function NewyearView:updatatwo( msg )
	local node = self.mainLayer:getChildByName("bg"):getChildByName("node2")
	for i,v in ipairs(node:getChildren()) do
		v:setVisible(true)
	end
	local jindu = {15,45,70,100}
	local load = self.mainLayer:getChildByName("bg"):getChildByName("node2"):getChildByName("loadbg"):getChildByName("load")
	load:setPercent(0)
	local iscanling
	local btn =  self.mainLayer:getChildByName("bg"):getChildByName("node2"):getChildByName("getbtn")
	for i,v in ipairs(msg.list) do
		local node =  self.mainLayer:getChildByName("bg"):getChildByName("node2"):getChildByName("reward"..i)
		node:getChildByName("tipbg"):getChildByName("Text_3"):setString(v.target.."局")
		node:getChildByName("gold"):getChildByName("num"):setString(v.gold)
		if v.isget == 1 or v.isget == 0 then
			load:setPercent(jindu[i])
			node:getChildByName("1"):setVisible(false)
			node:getChildByName("2"):setVisible(true)
			if v.isget == 1 then
				node:getChildByName("gold"):setVisible(false)
				node:getChildByName("ling"):setVisible(true)
			else
				iscanling = true
				node:getChildByName("gold"):setVisible(true)
				node:getChildByName("ling"):setVisible(false)
			end
		else
			node:getChildByName("gold"):setVisible(true)
			node:getChildByName("ling"):setVisible(false)
			node:getChildByName("1"):setVisible(true)
			node:getChildByName("2"):setVisible(false)
		end
	end
	if iscanling then
		btn:setEnabled(true)
	else
		btn:setEnabled(false)
	end

	WidgetUtils.addClickEvent(btn, function( )
		print("领取")
		for i,v in ipairs(msg.list) do
			if v.isget == 0 then
				self:showSmallLoading()
				ComHttp.httpPOST(ComHttp.URL.YEARGET2,{uid= LocalData_instance.uid,id = v.id},function(msg) 
					printTable(msg,"xp")
					self:getdata(2)
			       	if msg.status == 1 then
			       		table.insert(self.listreward,{type =1,num = msg.num})
			       		if msg.gettag and msg.gettag ~= 0 then
			       			table.insert(self.listreward,{type =2,num = msg.gettag})
			       		end
			       	else
			       		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = msg.str})
			       	end
			    end)
			    break
			end
		end
		

	end)


end
function NewyearView:updatathree( msg )
	local per = {10,35,65,100}

	local sharebtn = self.mainLayer:getChildByName("bg"):getChildByName("node3"):getChildByName("btn")
	WidgetUtils.addClickEvent(sharebtn, function( )
			self.issharepy = false
			NEWYERRSHREA.sharefriend( )
		end)
	self.listview4:removeAllItems()
	if #msg.list == 0 then
		self.mainLayer:getChildByName("bg"):getChildByName("node3"):getChildByName("text"):setVisible(true)
	else
		self.mainLayer:getChildByName("bg"):getChildByName("node3"):getChildByName("text"):setVisible(false)
	end
	for i,v in ipairs(msg.list) do
	 	self.listview3:pushBackDefaultItem()
        local item = self.listview3:getItem(i-1)
        item:setVisible(true)
        local canget = false
        local load =item:getChildByName("loadbg"):getChildByName("load")
        load:setPercent(0)
        for i1,v1 in ipairs(v.playlist) do
        	local node = item:getChildByName(i1)
        	node:getChildByName("title"):setString(v1.target.."局")
        	if v1.isget == 0 then
        		node:getChildByName("ling"):setVisible(false)
        		node:getChildByName("gold"):setVisible(true)
        		load:setPercent(per[i1])
        		canget = true
        	elseif v1.isget == 1 then
        		node:getChildByName("ling"):setVisible(true)
        		node:getChildByName("gold"):setVisible(false)
        		load:setPercent(per[i1])
        	elseif v1.isget == 2 then
        		node:getChildByName("ling"):setVisible(false)
        		node:getChildByName("gold"):setVisible(true)
        		node:getChildByName("goldicon"):loadTexture("cocostudio/newyear/coin_"..i1.."_gray.png", ccui.TextureResType.localType)
        	end
        	node:getChildByName("gold"):setString(v1.gold)
        end
        item:getChildByName("id"):setString("ID:"..v.uid)
        require("app.ui.common.HeadIcon").new(item:getChildByName("iconbg"):getChildByName("icon"), v.img,86)
        local btn = item:getChildByName("btn")
        if canget then
        	btn:getChildByName("1"):setVisible(false)
        	btn:getChildByName("2"):setVisible(true)
        	WidgetUtils.addClickEvent(btn, function( )
				for i1,v1 in ipairs(v.playlist) do
					if v1.isget == 0 then
						self:showSmallLoading()
						ComHttp.httpPOST(ComHttp.URL.YEARGET3,{actuid = v.uid,uid= LocalData_instance.uid,id = v1.id},function(msg) 
							printTable(msg,"xp")
							self:getdata(3)
					       	if msg.status == 1 then
					       		table.insert(self.listreward,{type =1,num = msg.num})
					       		if msg.gettag and msg.gettag ~= 0 then
					       			table.insert(self.listreward,{type =2,num = msg.gettag})
					       		end
					       	else
					       		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = msg.str})
					       	end
					    end)
					    break
					end
				end

			end)
        	

        else
        	btn:setEnabled(false)
        	btn:getChildByName("1"):setVisible(true)
        	btn:getChildByName("2"):setVisible(false)
        end

    end
end

function NewyearView:updatafour( msg )

	local sharebtn = self.mainLayer:getChildByName("bg"):getChildByName("node4"):getChildByName("btn")
	WidgetUtils.addClickEvent(sharebtn, function( )
			self.issharepy = false
			NEWYERRSHREA.sharefriend( )
		end)

	if #msg.list == 0 then
		self.mainLayer:getChildByName("bg"):getChildByName("node4"):getChildByName("text"):setVisible(true)
	else
		self.mainLayer:getChildByName("bg"):getChildByName("node4"):getChildByName("text"):setVisible(false)
	end


	self.listview4:removeAllItems()
	 for i,v in ipairs(msg.list) do
	 	self.listview4:pushBackDefaultItem()
        local item = self.listview4:getItem(i-1)
        item:setVisible(true)
        item:getChildByName("info"):setString("春节活动期间邀请"..v.target.."个玩家")
        item:getChildByName("value"):setString(v.gold)
        --v.isget  = 2
        local btn = item:getChildByName("btn")
        if v.isget == 0 then
        	
        		btn:setVisible(true)
        		btn:getChildByName("get"):setVisible(true)
        		btn:getChildByName("text"):setVisible(false)
        		item:getChildByName("ling"):setVisible(false)

        		WidgetUtils.addClickEvent(btn, function( )
					print("领取")
					self:showSmallLoading()
					ComHttp.httpPOST(ComHttp.URL.YEARGET4,{uid= LocalData_instance.uid,type = v.type,id = v.id},function(msg) 
						printTable(msg,"xp")
						self:getdata(1)
				       	if msg.status == 1 then
				       		table.insert(self.listreward,{type =1,num = msg.num})
				       		if msg.gettag and msg.gettag ~= 0 then
				       			table.insert(self.listreward,{type =4,num = msg.gettag})
				       		end
				       	else
				       		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = msg.str})
				       	end
				    end)

				end)


        elseif v.isget == 1 then
	        	item:getChildByName("btn"):setVisible(false)
	        	btn:getChildByName("get"):setVisible(false)
	        	item:getChildByName("ling"):setVisible(true)
	        	btn:getChildByName("text"):setVisible(false)
        elseif v.isget == 2 then
        	-- local btn = item:getChildByName("btn")
    		btn:setVisible(true)
    		btn:setEnabled(false)
    		btn:getChildByName("text"):setString(v.num.."/"..v.target)
    		item:getChildByName("ling"):setVisible(false)
    		btn:getChildByName("get"):setVisible(false)
        end
	 end
end


function NewyearView:updatafive( msg )

	self.listview5:removeAllItems()
	 for i,v in ipairs(msg.list) do
	 	self.listview5:pushBackDefaultItem()
        local item = self.listview5:getItem(i-1)
        item:setVisible(true)
        item:getChildByName("info"):setString("活动期间累积充值"..v.target.."元")
        item:getChildByName("value"):setString(v.gold)
        --v.isget  = 2
        if v.isget == 1 then
        	local btn = item:getChildByName("btn")
        		btn:setVisible(true)
        		btn:getChildByName("get"):setVisible(true)
        		btn:getChildByName("text"):setVisible(false)
        		item:getChildByName("ling"):setVisible(false)

        		WidgetUtils.addClickEvent(btn, function( )
					print("领取")
					self:showSmallLoading()
					ComHttp.httpPOST(ComHttp.URL.YEARGET5,{uid= LocalData_instance.uid,id = v.id},function(msg) 
						printTable(msg,"xp")
						self:getdata(5)
				       	if msg.status == 1 then
				       		table.insert(self.listreward,{type =1,num = msg.num})
				       		if msg.gettag and msg.gettag ~= 0 then
				       			table.insert(self.listreward,{type =2,num = msg.gettag})
				       		end
				       	else
				       		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = msg.str})
				       	end
				    end)

				end)


        elseif v.isget == 2 then
	        	item:getChildByName("btn"):setVisible(false)
	        	item:getChildByName("ling"):setVisible(true)
        elseif v.isget == 0 then
        	local btn = item:getChildByName("btn")
    		btn:setVisible(true)
    		btn:setEnabled(false)
    		btn:getChildByName("get"):setVisible(false)
    		btn:getChildByName("text"):setString(v.pay.."/"..v.target)
    		item:getChildByName("ling"):setVisible(false)
        end
	 end


end
function NewyearView:updatasix( msg )

	local node =  self.mainLayer:getChildByName("bg"):getChildByName("node6")
	for i,v in ipairs(node:getChildByName("scrollview"):getChildByName("layer"):getChildren()) do
		if v:getName() ~= "bg1" and v:getName() ~= "bg2" then
			v:removeFromParent()
		end
	end
	-- if msg.exchange_list then

	-- 	if  msg.exchange_list.chip then
	-- 		for i,v in ipairs(msg.exchange_list.chip) do
	-- 			local hong = node:getChildByName("scrollview"):getChildByName("layer"):getChildByName("card"..i)
	-- 			hong:setVisible(true)
	-- 			hong:getChildByName("text1"):setString(v.name)
	-- 			if v.type == 1 then
	-- 				hong:getChildByName("text2"):setString("个人库存"..v.showdepot.."份")
	-- 			else
	-- 				hong:getChildByName("text2"):setString("库存"..v.showdepot.."份")
	-- 			end
	-- 			local btn = hong:getChildByName("btn")
	-- 			if v.isexchange == 1 then
	-- 				btn:setEnabled(true)
	-- 				btn:getChildByName("node1"):setVisible(true)
	-- 				btn:getChildByName("node2"):setVisible(false)
	-- 				btn:getChildByName("node1"):getChildByName("num"):setString(v.price)
	-- 				WidgetUtils.addClickEvent(btn, function( )
	-- 					print("领取")
	-- 					self:showSmallLoading()
	-- 					ComHttp.httpPOST(ComHttp.URL.YEARCONFIG63,{uid= LocalData_instance.uid,id = v.id},function(msg) 
	-- 						printTable(msg,"xp")
	-- 						self:getdata(6)
	-- 				       	if msg.status == 1 then
	-- 				       		table.insert(self.listreward,{type =3,num = msg.num})
					  
	-- 				       		if msg.gettag and msg.gettag ~= 0 then
	-- 				       			table.insert(self.listreward,{type =2,num = msg.gettag})
	-- 				       		end
	-- 				       	else
	-- 				       		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = msg.str})
	-- 				       	end
	-- 				    end)

	-- 				end)
	-- 			else
	-- 				btn:setEnabled(false)
	-- 				btn:getChildByName("node1"):setVisible(false)
	-- 				btn:getChildByName("node2"):setVisible(true)
	-- 			end
	-- 		end
	-- 	end

	-- 	if  msg.exchange_list.money then
	-- 		for i,v in ipairs(msg.exchange_list.money) do
	-- 			local hong = node:getChildByName("scrollview"):getChildByName("layer"):getChildByName("hong"..i)
	-- 			hong:setVisible(true)
	-- 			hong:getChildByName("text1"):setString(v.name)
	-- 			hong:getChildByName("text2"):setString("还可以兑换"..v.showdepot.."次")
	-- 			local btn = hong:getChildByName("btn")
	-- 			if v.isexchange == 1 then
	-- 				btn:setEnabled(true)
	-- 				btn:getChildByName("node1"):setVisible(true)
	-- 				btn:getChildByName("node2"):setVisible(false)
	-- 				btn:getChildByName("node1"):getChildByName("num"):setString(v.price)
	-- 				WidgetUtils.addClickEvent(btn, function( )
	-- 					print("领取")
	-- 					self:showSmallLoading()
	-- 					ComHttp.httpPOST(ComHttp.URL.YEARCONFIG63,{uid= LocalData_instance.uid,id = v.id},function(msg) 
	-- 						printTable(msg,"xp")
	-- 						self:getdata(6)
	-- 				       	if msg.status == 1 then
	-- 				       		table.insert(self.listreward,{type =4,num = msg.num})
					       	
	-- 				       		if msg.gettag and msg.gettag ~= 0 then
	-- 				       			table.insert(self.listreward,{type =2,num = msg.gettag})
	-- 				       		end
	-- 				       	else
	-- 				       		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = msg.str})
	-- 				       	end
	-- 				    end)

	-- 				end)
	-- 			else
	-- 				btn:setEnabled(false)
	-- 				btn:getChildByName("node1"):setVisible(false)
	-- 				btn:getChildByName("node2"):setVisible(true)
	-- 			end
	-- 		end
	-- 	end

	-- end
	if msg.usetag_list then
		local hong = node:getChildByName("scrollview"):getChildByName("layer"):getChildByName("bg2")
		local btn = hong:getChildByName("btn")
		hong:setVisible(true)
		if msg.usetag_list.isexchange == 1 then
			btn:setEnabled(true)
			btn:getChildByName("1"):setVisible(false)
			btn:getChildByName("2"):setVisible(true)
		else
			btn:setEnabled(false)
			btn:getChildByName("1"):setVisible(true)
			btn:getChildByName("2"):setVisible(false)
		end

		for i=1,4 do
			if msg.usetag_list["tag"..i] > 0 then
				hong:getChildByName(i.."_1"):setVisible(false)
				hong:getChildByName(i.."_2"):setVisible(true)
			else
				hong:getChildByName(i.."_1"):setVisible(true)
				hong:getChildByName(i.."_2"):setVisible(false)
			end
			hong:getChildByName(i):setString("已有"..msg.usetag_list["tag"..i].."张")
		end

		WidgetUtils.addClickEvent(btn, function( )
			print("领取")
			self:showSmallLoading()
			ComHttp.httpPOST(ComHttp.URL.YEARCONFIG62,{uid= LocalData_instance.uid},function(msg) 
				printTable(msg,"xp")
				self:getdata(6)
		       	if msg.status == 1 then
		       		table.insert(self.listreward,{type =4,num = msg.num})
		       		if msg.gettag and msg.gettag ~= 0 then
		       			table.insert(self.listreward,{type =2,num = msg.gettag})
		       		end
		       	else
		       		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = msg.str})
		       	end
		    end)

		end)

		WidgetUtils.addClickEvent(hong:getChildByName("info"), function( )
			hong:getChildByName("touch"):setVisible(true)
			WidgetUtils.addClickEvent(hong:getChildByName("touch"), function( )
				hong:getChildByName("touch"):setVisible(false)
			end)
		end)
	end
	if msg.servicelottery_list then
		local hong = node:getChildByName("scrollview"):getChildByName("layer"):getChildByName("bg1")
		local btn = hong:getChildByName("btn")
		hong:setVisible(true)
		if msg.servicelottery_list.isbuy == 0 then
			btn:setEnabled(true)
			btn:getChildByName("node2"):setVisible(false)
			btn:getChildByName("node1"):setVisible(true)
			btn:getChildByName("node3"):setVisible(false)
			btn:getChildByName("node1"):getChildByName("num"):setString(msg.servicelottery_list.price)
			WidgetUtils.addClickEvent(btn, function( )
				print("领取")
				LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "金币不足"})
			end)
		elseif msg.servicelottery_list.isbuy == 1 then
			btn:setEnabled(true)
			btn:getChildByName("node2"):setVisible(false)
			btn:getChildByName("node1"):setVisible(true)
			btn:getChildByName("node3"):setVisible(false)
			btn:getChildByName("node1"):getChildByName("num"):setString(msg.servicelottery_list.price)
			WidgetUtils.addClickEvent(btn, function( )
				print("领取")
				LaypopManger_instance:PopBox("NewyearaddView",msg.servicelottery_list,self)

			end)

		elseif msg.servicelottery_list.isbuy == 2 then
			btn:setVisible(false)
			-- btn:getChildByName("node2"):setVisible(false)
			-- btn:getChildByName("node1"):setVisible(false)
			-- btn:getChildByName("node3"):setVisible(true)
			hong:getChildByName("open"):setVisible(false)
			-- hong:getChildByName("close"):setString(msg.servicelottery_list.str)

			hong:getChildByName("close"):setString(msg.servicelottery_list.str)
			-- WidgetUtils.addClickEvent(btn, function( )
			-- 	print("查看")
			-- 	LaypopManger_instance:PopBox("PrizeListView1",msg.servicelottery_list,self)
			-- end)
		end
		
		hong:getChildByName("git0"):setVisible(false)
		hong:getChildByName("git1"):setVisible(false)
		hong:getChildByName("git"..msg.servicelottery_list.itemtype):setVisible(true)
		hong:getChildByName("name"):setString(msg.servicelottery_list.title)
		if msg.servicelottery_list.count then
			hong:getChildByName("open"):getChildByName("name_0_0"):setString("已有"..msg.servicelottery_list.count.."人次参加")
			if msg.servicelottery_list.mytime and msg.servicelottery_list.mytime > 0 then
				hong:getChildByName("open"):getChildByName("name_0_0"):setString("已有"..msg.servicelottery_list.count.."人次参加\n".."我已参加了"..msg.servicelottery_list.mytime.."次")
			end
		end
		if msg.servicelottery_list.time then
			local function updatatime( )
				local losttime = msg.servicelottery_list.time - os.time()
				local daytitle = hong:getChildByName("open"):getChildByName("day")
				local hourtitle = hong:getChildByName("open"):getChildByName("hour")
				local mintitle = hong:getChildByName("open"):getChildByName("min")
				if losttime <= 0 then
					daytitle:setString("0")
					hourtitle:setString("0")
					mintitle:setString("0")
				else
					local day = math.floor(losttime/(3600*24))
					if day < 10 then
						daytitle:setString("0"..day)
					else
						daytitle:setString(day)
					end
					losttime = losttime%(3600*24)
					local hour = math.floor(losttime/3600)
					if hour < 10 then
						hourtitle:setString("0"..hour)
					else
						hourtitle:setString(hour)
					end
					losttime = losttime%3600
					local min = math.ceil(losttime/60)
					if min < 10 then
						mintitle:setString("0"..min)
					else
						mintitle:setString(min)
					end
				end
			end
			
			updatatime()
			hong:stopAllActions()
			hong:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( ... )
				updatatime()
			end))))

		end
	end

	local baseposx = 582
	local extrawidth = 0
	if msg.serverlottery_list then
		for i,v in ipairs(msg.serverlottery_list) do
			local hong
			if v.itemtype == 0 then
				hong = cc.CSLoader:createNode("newyear/cardnode.csb")
			else
				hong = cc.CSLoader:createNode("newyear/hongbaonode.csb")
			end

			hong:addTo(node:getChildByName("scrollview"):getChildByName("layer"))

			extrawidth = extrawidth + 297

			hong:setPosition(cc.p(baseposx+extrawidth,281))	

			local btn = hong:getChildByName("bg"):getChildByName("btn")
			hong:setVisible(true)
			if v.isbuy == 0 then
				btn:setEnabled(true)
				btn:getChildByName("node2"):setVisible(false)
				btn:getChildByName("node1"):setVisible(true)
				btn:getChildByName("node3"):setVisible(false)
				btn:getChildByName("node4"):setVisible(false)
				btn:getChildByName("node1"):getChildByName("num"):setString(v.price)
				WidgetUtils.addClickEvent(btn, function( )
					print("领取")
					LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "金币不足"})
				end)
			elseif v.isbuy == 1 then
				btn:setEnabled(true)
				btn:getChildByName("node2"):setVisible(false)
				btn:getChildByName("node1"):setVisible(true)
				btn:getChildByName("node3"):setVisible(false)
				btn:getChildByName("node4"):setVisible(false)
				btn:getChildByName("node1"):getChildByName("num"):setString(v.price)
				WidgetUtils.addClickEvent(btn, function( )
					print("领取")
					LaypopManger_instance:PopBox("NewyearaddView",v,self,true)
				end)

			elseif v.isbuy == 2 then
				-- btn:setVisible(false)
				btn:getChildByName("node2"):setVisible(false)
				btn:getChildByName("node1"):setVisible(false)
				btn:getChildByName("node3"):setVisible(false)
				btn:getChildByName("node4"):setVisible(false)
				hong:getChildByName("bg"):getChildByName("open"):setVisible(false)
				-- hong:getChildByName("bg"):getChildByName("close"):setString(v.str)

				if v.isprize == 1 then
					hong:getChildByName("bg"):getChildByName("close"):setString("恭喜您，您已中奖！")
					if v.isget == 0 then
						btn:getChildByName("node4"):setVisible(true)
						WidgetUtils.addClickEvent(btn, function( )
							ComHttp.httpPOST(ComHttp.URL.YEARCONFIG66,{uid= LocalData_instance.uid,pid = v.id},function(msg) 
								printTable(msg,"xp")
								self:getdata(6)
						       	if msg.status == 1 then
						       		if v.itemtype == 0 then
						       			table.insert(self.listreward,{type =3,num = v.itemnum})
						       		else
						       			table.insert(self.listreward,{type =4,num = v.itemnum,tipstr = "领取方式详情见获奖名单。"})
						       		end
						       	else
						       		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = msg.str or "领取失败！"})
						       	end
						    end)
						end)
					else
						btn:getChildByName("node3"):setVisible(true)
						WidgetUtils.addClickEvent(btn, function( )
							print("查看")
							LaypopManger_instance:PopBox("PrizeListView2",v,self)
						end)
					end
					
				else
					hong:getChildByName("bg"):getChildByName("close"):setString("很遗憾，您未中奖。")
					btn:getChildByName("node3"):setVisible(true)
					WidgetUtils.addClickEvent(btn, function( )
						print("查看")
						LaypopManger_instance:PopBox("PrizeListView2",v,self)
					end)
				end

				
			end
			
			-- hong:getChildByName("bg"):getChildByName("git0"):setVisible(false)
			-- hong:getChildByName("bg"):getChildByName("git1"):setVisible(false)
			-- hong:getChildByName("bg"):getChildByName("git"..v.itemtype):setVisible(true)
			hong:getChildByName("bg"):getChildByName("name"):setString(v.title)
			hong:getChildByName("bg"):getChildByName("tip"):setString(v.content)
			if v.count then
				hong:getChildByName("bg"):getChildByName("open"):getChildByName("name_0_0"):setString("已有"..v.count.."人次参加")
				if v.mytime and v.mytime > 0 then
					hong:getChildByName("bg"):getChildByName("open"):getChildByName("name_0_0"):setString("已有"..v.count.."人次参加\n".."我已参加了"..v.mytime.."次")
				end
			end
			if v.time then
				local function updatatime( )
					local losttime = v.time - os.time()
					local daytitle = hong:getChildByName("bg"):getChildByName("open"):getChildByName("day")
					local hourtitle = hong:getChildByName("bg"):getChildByName("open"):getChildByName("hour")
					local mintitle = hong:getChildByName("bg"):getChildByName("open"):getChildByName("min")
					if losttime <= 0 then
						daytitle:setString("0")
						hourtitle:setString("0")
						mintitle:setString("0")
					else
						local day = math.floor(losttime/(3600*24))
						if day < 10 then
							daytitle:setString("0"..day)
						else
							daytitle:setString(day)
						end
						losttime = losttime%(3600*24)
						local hour = math.floor(losttime/3600)
						if hour < 10 then
							hourtitle:setString("0"..hour)
						else
							hourtitle:setString(hour)
						end
						losttime = losttime%3600
						local min = math.ceil(losttime/60)
						if min < 10 then
							mintitle:setString("0"..min)
						else
							mintitle:setString(min)
						end
					end
				end
				
				updatatime()
				hong:stopAllActions()
				hong:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( ... )
					updatatime()
				end))))
			end
		end
	end
	if msg.exchange_list then
		if  msg.exchange_list.chip then
			for i,v in ipairs(msg.exchange_list.chip) do
				local hong = cc.CSLoader:createNode("newyear/card_smallnode.csb")
				hong:addTo(node:getChildByName("scrollview"):getChildByName("layer"))
				hong:setPositionY(422.5)

				if i%2 == 1 then
					extrawidth = extrawidth + 227
				else
					hong:setPositionY(139.5)
				end

				hong:setPositionX(baseposx+extrawidth)

				hong:setVisible(true)
				hong:getChildByName("bg"):getChildByName("text1"):setString(v.name)
				if v.type == 1 then
					hong:getChildByName("bg"):getChildByName("text2"):setString("个人库存"..v.showdepot.."份")
				else
					hong:getChildByName("bg"):getChildByName("text2"):setString("库存"..v.showdepot.."份")
				end
				local btn = hong:getChildByName("bg"):getChildByName("btn")
				if v.isexchange == 1 then
					btn:setEnabled(true)
					btn:getChildByName("node1"):setVisible(true)
					btn:getChildByName("node2"):setVisible(false)
					btn:getChildByName("node1"):getChildByName("num"):setString(v.price)
					WidgetUtils.addClickEvent(btn, function( )
						print("领取")
						self:showSmallLoading()
						ComHttp.httpPOST(ComHttp.URL.YEARCONFIG63,{uid= LocalData_instance.uid,id = v.id},function(msg) 
							printTable(msg,"xp")
							self:getdata(6)
					       	if msg.status == 1 then
					       		table.insert(self.listreward,{type =3,num = msg.num})
					  
					       		if msg.gettag and msg.gettag ~= 0 then
					       			table.insert(self.listreward,{type =2,num = msg.gettag})
					       		end
					       	else
					       		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = msg.str})
					       	end
					    end)

					end)
				else
					btn:setEnabled(false)
					btn:getChildByName("node1"):setVisible(false)
					btn:getChildByName("node2"):setVisible(true)
				end
			end
		end
	end

	node:getChildByName("scrollview"):setInnerContainerSize(cc.size(baseposx+extrawidth,node:getChildByName("scrollview"):getContentSize().height))
	node:getChildByName("scrollview"):getChildByName("layer"):setPositionX(0)
end

return NewyearView