local WheelView = class("WheelView",require "app.module.basemodule.BasePopBox")

function WheelView:initData()
	self.chance = 0
	self.packetnum = 0
	self.isturnning = false
end

function WheelView:initView()
	self.widget = cc.CSLoader:createNode("ui/wheelsurf/wheel.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	self:initWheelNode()
	self:initInfoNode()
end

function WheelView:initWheelNode()
	self.wheelnode = self.mainLayer:getChildByName("wheelnode")

	local lottorybtn = self.wheelnode:getChildByName("lottorybtn")

	local selectednode = self.wheelnode:getChildByName("selectednode")

	self.lighttable = {}
	for i=1,12 do
		local light = selectednode:getChildByName("light"..i)

		table.insert(self.lighttable,light)
	end

	self.finger = self.wheelnode:getChildByName("finger")

	WidgetUtils.addClickEvent(lottorybtn,function ()
		if self.isturnning then
			-- self:stopWheelAnimation(math.random(1,8))
		else
			-- self:startWheelAnimation()
			self:getPrize()
		end
	end)

	self.animationnode = self.wheelnode:getChildByName("animationnode")
end

function WheelView:startWheelAnimation()
	-- self.finger:runAction(cc.RotateBy(360,1))
	if self.isturnning then
		return
	end
	self.animationnode:removeAllChildren()
	self.isturnning = true
	local function getLightIndex(idx)
		local idxtable = {}
		table.insert(idxtable,idx)
		table.insert(idxtable,(idx-1) > 0 and idx-1 or idx-1 + 12 )
		table.insert(idxtable,(idx-2) > 0 and idx-2 or idx-2 + 12 )

		return idxtable
	end
	local function update()
		if not self.isturnning then
			return
		end

		local angle = self.finger:getRotation()%360
		local index = math.ceil(angle/30)

		local idxtable = getLightIndex(index)

		for i,v in ipairs(self.lighttable) do
			v:setVisible(false)
		end

		for i,v in ipairs(idxtable) do
			if self.lighttable[v] then
				self.lighttable[v]:setVisible(true)
				self.lighttable[v]:setOpacity(255)
				if i == 2 then
					self.lighttable[v]:setOpacity(255*0.8)
				end
				if i == 3 then
					self.lighttable[v]:setOpacity(255*0.3)
				end
			end
		end
	end

	if self.schedulerScript then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerScript)
		self.schedulerScrip = nil
	end

	self.schedulerScript = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0.02, false)

	-- local action = cc.Sequence:create(cc.)
	local startangle = self.finger:getRotation()
	startangle = startangle%360
	self.finger:setRotation(startangle)
	self.finger.startangle = startangle
	self.finger:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(0.3,360),cc.CallFunc:create(function ()
		self.finger:setRotation(startangle)
	end))))
end

function WheelView:getAngleByIndex(idx)
	return (idx-1)*30+15
end

function WheelView:stopWheelAnimation(data)
	local idx = data.ord

	print("idx=================",idx)
	self.finger:stopAllActions()

	local nowangle = self.finger:getRotation()
	nowangle = nowangle%360
	self.finger:setRotation(nowangle)

	local endangle = self:getAngleByIndex(idx) + 720

	local downangle = nowangle

	self.finger:runAction(cc.Sequence:create(
		-- cc.RotateTo:create((downangle - nowangle)/(360/0.3) ,downangle),
		cc.RotateTo:create((endangle - downangle)/(360/0.3),endangle),
		cc.CallFunc:create(function ()
			for i,v in ipairs(self.lighttable) do
				v:setVisible(false)
			end
			
			local node =  cc.CSLoader:createNode("ui/wheelsurf/dalunpan/dalunpan.csb")
				:addTo(self.animationnode)
				:setRotation((idx-1)*30)
			local action = cc.CSLoader:createTimeline("ui/wheelsurf/dalunpan/dalunpan.csb")
			local function onFrameEvent(frame)
		    	print("action111")
		        if nil == frame then
		            return
		        end
		        local str = frame:getEvent()
		        if str == "end" then
		   --          node:removeFromParent()
		   --          if self.lighttable[idx] then
					-- 	self.lighttable[idx]:setVisible(true)
					-- end
					self.isturnning = false

					self:showreward(data)
		        end
		    end
		    action:setFrameEventCallFunc(onFrameEvent)

		    node:runAction(action)
		    action:gotoFrameAndPlay(0,false)
		end),
		cc.CallFunc:create(function ()
			if self.schedulerScript then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerScript)
				self.schedulerScrip = nil
			end
		end)))
end

function WheelView:initInfoNode()
	self.infonode = self.mainLayer:getChildByName("infonode")

	self.infobtn = self.infonode:getChildByName("infobtn")
end

function WheelView:errorStop()
	self.isturnning = false
	self.finger:stopAllActions()
	for i,v in ipairs(self.lighttable) do
		v:setVisible(false)
	end
	if self.schedulerScript then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerScript)
		self.schedulerScrip = nil
	end
	LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "出错啦，请重试"})
	self:getConf()
end

function WheelView:refreshView(data)
	local function refreshTaskdata(idx,taskdata)
		local tasknode = self.infonode:getChildByName("task"..idx)
		local tasktitle = tasknode:getChildByName("tasktitle")
		local target = tasknode:getChildByName("target")
		local loading = tasknode:getChildByName("loadingbar")
		local btn = tasknode:getChildByName("btn")
		local graybtn = tasknode:getChildByName("btn2")

		--tasktitle:setString(taskdata.name)
		--target:setString(math.min(taskdata.current,taskdata.target).."/"..taskdata.target)
		--loading:setPercent(math.min(taskdata.current,taskdata.target)/taskdata.target*100)

		if taskdata.status == 1 then
			btn:setVisible(true)
			graybtn:setVisible(false)
			btn:getChildByName("text1"):setVisible(false)
			btn:getChildByName("text2"):setVisible(true)
			WidgetUtils.addClickEvent(btn,function ()
				self:getChance(idx)
			end)
		elseif taskdata.status == 0 then
			btn:setVisible(true)
			graybtn:setVisible(false)
			btn:getChildByName("text1"):setVisible(true)
			btn:getChildByName("text2"):setVisible(false)
			WidgetUtils.addClickEvent(btn,function ()
				if idx == 1 then
					LaypopManger_instance:backByName("WheelSurfView")
					cc.UserDefault:getInstance():setIntegerForKey("game_class_select",10)
					LaypopManger_instance:PopBox("CreateRoomView")
				elseif idx == 2 then
					self.isshareimg = true
					CommonUtils.shareScreen_3("cocostudio/ui/wheelsurf/shareimg.jpg")
				elseif idx == 3 then
					LaypopManger_instance:backByName("WheelSurfView")
					LaypopManger_instance:PopBox("ShopView")
				end
			end)
		elseif taskdata.status == 2 then
			btn:setVisible(false)
			graybtn:setVisible(true)
		end
	end

	refreshTaskdata(1,data.play_config)
	refreshTaskdata(2,data.share_config)
	-- refreshTaskdata(3,data.pay_config)

	self.chance = data.chance
	self:refreshChance()
	-- local tipboard = self.wheelnode:getChildByName("board")
	-- local tiplabel = tipboard:getChildByName("tip")

	-- if data.redpacket and data.redpacket > 0 then
	-- 	tiplabel:setString("您已获得"..data.redpacket.."元红包")
	-- 	tipboard:setVisible(true)
	-- else
	-- 	tipboard:setVisible(false)
	-- end
	self.packetnum = data.redpacket
	WidgetUtils.addClickEvent(self.infobtn,function ()
		if self.needupdate then
			self:showSmallLoading()
			ComHttp.httpPOST(ComHttp.URL.WHEELGETCONF,{uid = LocalData_instance.uid},function(msg)
				printTable(msg)
				if not WidgetUtils:nodeIsExist(self) then
					return
				end

				self:hideSmallLoading()

				if msg.status ~= 1 then
					return
				end

				self:refreshView(msg)

				LaypopManger_instance:PopBox("WheelInfoBox",self.packetnum or 0,function (num)
					if not WidgetUtils:nodeIsExist(self) then
						return
					end
					self.packetnum = num
					-- self:getConf()
					self.needupdate = false
				end)
			end)
		else
			LaypopManger_instance:PopBox("WheelInfoBox",self.packetnum or 0,function (num)
				if not WidgetUtils:nodeIsExist(self) then
					return
				end
				self.packetnum = num
				-- self:getConf()
			end)
		end
	end)
end

function WheelView:refreshChance()
	local chancelabel = self.wheelnode:getChildByName("chance")
	chancelabel:setString("剩"..self.chance.."次")
end

function WheelView:onEnter()
	local eventDispatcher = self:getEventDispatcher()
	--微信分享回调
	local listener = cc.EventListenerCustom:create("weixinsharecallback" , function ( evt )
		local output = evt:getDataString()
		if tonumber(output) and tonumber(output) == 0 then
			-- print("分享成功")
			if self.isshareimg then
				ComHttp.httpPOST(ComHttp.URL.WHEELGETCHANCE,{uid = LocalData_instance.uid,type = 2},function(msg)
					printTable(msg)
					if not WidgetUtils:nodeIsExist(self) then
						return
					end

					if msg.status == 1 then
						LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "恭喜您获得"..msg.num.."次抽奖机会"})
						if not self.isturnning then
							self:getConf()
						end
					end
				end)
			end
		else
			print("分享失败")
		end
	end)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

	self:getConf()
end

function WheelView:onExit()
	-- if self.selectlight then
	-- 	self.selectlight:release()
	-- end

	if self.schedulerScript then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerScript)
	end
end

function WheelView:getConf()
	if self.isturnning then
		return
	end
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.WHEELGETCONF,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end

		self:refreshView(msg)
	end)
end

function WheelView:getPrize()
	if self.chance <= 0 then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "抽奖次数不足！"})
		return
	end

	if self.isturnning then
		return
	end

	self.chance = self.chance - 1
	self:refreshChance()

	local action = cc.Sequence:create(cc.DelayTime:create(15),cc.CallFunc:create(function ()
		self:errorStop()
	end))
	self:runAction(action)
	self:startWheelAnimation()
	ComHttp.httpPOST(ComHttp.URL.WHEELGETPRIZE,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		if msg.status == 1 then
			self.chance = msg.chance
			self:refreshChance()
			self:stopAction(action)
			self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function ()
				self:stopWheelAnimation(msg)
			end)))
		end

	end)
end

function WheelView:getChance(idx)
	local maps = {3,2,1}
	ComHttp.httpPOST(ComHttp.URL.WHEELGETCHANCE,{uid = LocalData_instance.uid,type = maps[idx]},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		if msg.status == 1 then
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "恭喜您获得"..msg.num.."次抽奖机会"})
			self.chance = self.chance + msg.num
			if not self.isturnning then
				self:getConf()
			end
		end
	end)
end

function WheelView:showreward(data)

	local widget = cc.CSLoader:createNode("cocostudio/ui/wheelsurf/gongxihuode/gongxihuode.csb")
	widget:setPosition(cc.p((display.cx-640)/2,0))
	self:addChild(widget,2)
	local btn = widget:getChildByName("final"):getChildByName("btn"):getChildByName("btn")
	-- if data.type == 1 then
	-- 	local num = widget:getChildByName("final"):getChildByName("num")
	-- 	local icon = widget:getChildByName("final"):getChildByName("baoxiang")
	-- 	num:setString(data.num.."个金币")
	-- 	icon:ignoreContentAdaptWithSize(true)
	-- 	widget:getChildByName("final"):getChildByName("info"):setString("金币限时兑换，活动结束将无效，赶快去兑换吧！")
	-- 	if data.num > 20 then
	-- 		icon:loadTexture("cocostudio/newyear/coin_4.png", ccui.TextureResType.localType)
	-- 	elseif data.num > 6 then
	-- 		icon:loadTexture("cocostudio/newyear/coin_3.png", ccui.TextureResType.localType)
	-- 	elseif data.num > 1 then
	-- 		icon:loadTexture("cocostudio/newyear/coin_2.png", ccui.TextureResType.localType)
	-- 	else
	-- 		icon:loadTexture("cocostudio/newyear/coin_1.png", ccui.TextureResType.localType)
	-- 	end
	-- elseif data.type == 2 then
	-- 	local num = widget:getChildByName("final"):getChildByName("num")
	-- 	local icon = widget:getChildByName("final"):getChildByName("baoxiang")
	-- 	num:setString("")
	-- 	icon:loadTexture("cocostudio/newyear/gong"..data.num..".png", ccui.TextureResType.localType)
	-- 	icon:ignoreContentAdaptWithSize(true)
	-- elseif data.type == 3 then
	-- 	local num = widget:getChildByName("final"):getChildByName("num")
	-- 	local icon = widget:getChildByName("final"):getChildByName("baoxiang")
	-- 	num:setString(data.num.."张")
	-- 	icon:loadTexture("cocostudio/newyear/icon_fangka.png", ccui.TextureResType.localType)
	-- 	icon:ignoreContentAdaptWithSize(true)
	-- elseif data.type == 4 then
	-- 	local num = widget:getChildByName("final"):getChildByName("num")
	-- 	local icon = widget:getChildByName("final"):getChildByName("baoxiang")
	-- 	num:setString(data.num.."元")
	-- 	icon:loadTexture("cocostudio/newyear/icon_hongbao_big.png", ccui.TextureResType.localType)
	-- 	icon:setScale(0.7)
	-- 	icon:ignoreContentAdaptWithSize(true)
	-- 	widget:getChildByName("final"):getChildByName("info"):setString("活动结束后10日内咨询客服领取")
	-- 	if data.tipstr then
	-- 		widget:getChildByName("final"):getChildByName("info"):setString(data.tipstr)
	-- 	end
	-- end

	if data.itemtype == 2 then
		local num = widget:getChildByName("final"):getChildByName("num")
		local icon = widget:getChildByName("final"):getChildByName("baoxiang")
		num:setString(data.name)
		icon:loadTexture("cocostudio/ui/wheelsurf/gongxihuode/icon_fangka.png", ccui.TextureResType.localType)
		icon:ignoreContentAdaptWithSize(true)
	elseif data.itemtype == 1 then
		local num = widget:getChildByName("final"):getChildByName("num")
		local icon = widget:getChildByName("final"):getChildByName("baoxiang")
		num:setString(data.name)
		icon:loadTexture("cocostudio/ui/wheelsurf/gongxihuode/icon_hongbao.png", ccui.TextureResType.localType)
		-- icon:setScale(0.7)
		icon:ignoreContentAdaptWithSize(true)
		-- if data.tipstr then
		-- 	widget:getChildByName("final"):getChildByName("info"):setString(data.tipstr)
		-- end
		self.needupdate = true
	end

	WidgetUtils.addClickEvent(btn, function( )
		widget:removeFromParent()
	end)

	local action = cc.CSLoader:createTimeline("cocostudio/ui/wheelsurf/gongxihuode/gongxihuode.csb")

    widget:runAction(action)
    action:gotoFrameAndPlay(0,false)

    local action = cc.CSLoader:createTimeline("cocostudio/ui/wheelsurf/gongxihuode/xuanzhuanguang.csd.csb")

    widget:getChildByName("FileNode_1"):runAction(action)
    action:gotoFrameAndPlay(0,true)
end

-- function WheelView:openview(msg)
-- 	local node = cc.CSLoader:createNode("ui/wheelsurf/award/zhanshi.csb")
-- 	self:addChild(node)
-- 	-- node:getChildByName("node"):setVisible(false)

-- 	local actionnode = node:getChildByName("zhanshi")

-- 	local image = actionnode:getChildByName("Node_1"):getChildByName("Node_24_0"):getChildByName("images")
-- 	image:ignoreContentAdaptWithSize(true)
-- 	if msg.itemtype == 2 then
-- 		image:loadTexture("ui/wheelsurf/award/images/fangka_big.png", ccui.TextureResType.localType)
-- 	else
-- 		image:loadTexture("ui/wheelsurf/award/images/hongbao_big.png", ccui.TextureResType.localType)
-- 	end

-- 	local text = node:getChildByName("node"):getChildByName("di"):getChildByName("text")
-- 	text:setString(msg.name)

-- 	local lightnode = node:getChildByName("light")

-- 	local action1 = cc.CSLoader:createTimeline("ui/wheelsurf/award/hongbaohuodong.csb")
-- 	actionnode:runAction(action1)
-- 	action1:gotoFrameAndPlay(0,false)

-- 	local action2 = cc.CSLoader:createTimeline("ui/wheelsurf/award/light.csb")
-- 	lightnode:runAction(action2)
-- 	action2:gotoFrameAndPlay(0,true)


-- 	WidgetUtils.addClickEvent(node:getChildByName("node"):getChildByName("closeBtn"), function( )
-- 		node:removeFromParent()
-- 	end)
-- 	WidgetUtils.addClickEvent(node:getChildByName("node"):getChildByName("btn"), function( )
-- 		CommonUtils.shareScreen_2()
--     	-- ISFENXIANGMEIRIACTIVIEY = true
-- 	end)
-- end

return WheelView