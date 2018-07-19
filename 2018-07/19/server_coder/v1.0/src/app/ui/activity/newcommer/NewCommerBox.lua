local NewCommerBox = class("NewCommerBox",PopboxBaseView)

function NewCommerBox:ctor(redpoint)
	self.redpoint = redpoint
	self:initView()
	self:initEvent()
end

function NewCommerBox:initEvent()
	self:registerScriptHandler(function(state)
		if state == "enter" then
			self:onEnter()
		elseif state == "exit" then
			self:onExit()
		end
	end)
end

function NewCommerBox:initView()
	self.widget = cc.CSLoader:createNode("ui/newcommeract/newcommerbox.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	self.closeBtn:setPositionX(WidgetUtils.offxscale*self.closeBtn:getPositionX())
	self.closeBtn:setPositionY(WidgetUtils.offyscale*self.closeBtn:getPositionY())

	local bg = self.mainLayer:getChildByName("bg"):setTouchEnabled(true)
	bg:setContentSize(cc.size(display.width,display.height))
end

function NewCommerBox:refreshView(data)
	-- data.day = 3
	self.data = data
	local contentnode = self.mainLayer:getChildByName("contentnode")

	for i,v in ipairs(data.list) do
		local day = contentnode:getChildByName("day"..i)
		local grayboard = day:getChildByName("grayboard")
		local awardnum = day:getChildByName("awardnum")
		local text1 = day:getChildByName("text1")
		local text2 = day:getChildByName("text2")
		local text3 = day:getChildByName("text3")

		local btn1 = day:getChildByName("btn1")
		local btn2 = day:getChildByName("btn2")
		local btn3 = day:getChildByName("btn3")

		awardnum:setString("/"..v.itemnum)
		text2:setString(v.finish_num.."/"..v.num)
		text2:setPositionX(text1:getPositionX()+3)
		text3:setPositionX(text2:getPositionX()+text2:getContentSize().width+3)

		if v.canget == 2 then
			-- 可领取
			btn2:setVisible(true)
			btn1:setVisible(false)
			btn3:setVisible(false)

			WidgetUtils.addClickEvent(btn2,function ()
				self:getAward(i)
			end)
		elseif v.canget == 1 then 
			-- 已领取
			btn3:setVisible(true)
			btn1:setVisible(false)
			btn2:setVisible(false)

		else
			btn1:setVisible(true)
			if data.day ~= i then
				btn1:setTouchEnabled(false)
				btn1:setBright(false)
			end
			btn2:setVisible(false)
			btn3:setVisible(false)
			WidgetUtils.addClickEvent(btn1,function ()
				LaypopManger_instance:backByName("NewCommerAct")
				-- cc.UserDefault:getInstance():setIntegerForKey("game_class_select",10)
				LaypopManger_instance:PopBox("CreateRoomView",10)
			end)
		end

		if data.day ~= i then
			grayboard:setVisible(true)
		else
			grayboard:setVisible(false)
		end

		if data.day < i then
			local btn4 = day:getChildByName("btn4")
			if WidgetUtils:nodeIsExist(btn4) then
				btn4:setVisible(true)
				btn1:setVisible(false)
				btn2:setVisible(false)
				btn3:setVisible(false)
			end
		end
	end
end

function NewCommerBox:getAward(day)
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.NEWCOMMERGETAWARD,{uid = LocalData_instance.uid,day = day},function(msg)
		printTable(msg)
		if msg.status == 1 then
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = msg.str or ""})	
		else
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "领取失败！"})
		end
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self:hideSmallLoading()

		if msg.status == 1 then
			if self.data then
				self.data.list[day].canget = 1
			end
			local contentnode = self.mainLayer:getChildByName("contentnode")
			local day = contentnode:getChildByName("day"..day)

			local btn1 = day:getChildByName("btn1")
			local btn2 = day:getChildByName("btn2")
			local btn3 = day:getChildByName("btn3")

			btn3:setVisible(true)
			btn1:setVisible(false)
			btn2:setVisible(false)
		else

		end

		-- self:refreshView(msg.list)
	end)
end

function NewCommerBox:onEnter()
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.NEWCOMMERGETCONF,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self:hideSmallLoading()

		self:refreshView(msg)
	end)
end

function NewCommerBox:onExit()
	if self.data then
		local isred = false
		for i,v in ipairs(self.data.list) do
			if v.canget == 2 then
				isred = true
				break
			end
		end
		if self.redpoint and WidgetUtils:nodeIsExist(self.redpoint) then
			if isred then
				self.redpoint:setVisible(true)
			else
				self.redpoint:setVisible(false)
			end
		end
	end
	
end

return NewCommerBox
