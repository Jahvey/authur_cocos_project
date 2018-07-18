local CreateRoomViewNew = class("CreateRoomViewNew",PopboxBaseView)

function CreateRoomViewNew:ctor(select,typ,data)
	self.selecttype = select
	self.clubetype = typ
	self.clubedata = data
	self.isclube = false
	if self.clubetype and self.clubedata then
		self.isclube = true
	end
	self:initData()
	self:initView()
end

function CreateRoomViewNew:initData()
	self.tabList = {} --左边的列表
	self.panelList = {}
	self.isLock = false

	ComNoti_instance:addEventListener("cs_response_change_teabar_create_info",self,self.changeTeabarCreateInfo)
end
function CreateRoomViewNew:changeTeabarCreateInfo(data)
	print("................changeTeabarCreateInfo")
	printTable(data,"xp227")
	if data.result == 0 then
		if  self.clubedata.teabar_create_info  and #self.clubedata.teabar_create_info > 0 then
			for k,v in pairs(self.clubedata.teabar_create_info) do
				if v.game_type == data.game_type then
					v.create_info = data.teabar_create_info
				end
			end
		else
			self.clubedata.teabar_create_info = {}
			table.insert(self.clubedata.teabar_create_info,{game_type = data.game_type,create_info = data.teabar_create_info})
		end
		if  self.panelList[data.game_type]  then
			self.panelList[data.game_type]:removeFromParent()
			self.panelList[data.game_type] = nil
		end
		self:clickItem(data.game_type)
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "操作成功！"})
	end
end

function CreateRoomViewNew:initView()
	self.widget = cc.CSLoader:createNode("ui/createroom/createRoomViewNew.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.viewList = self.mainLayer:getChildByName("viewList")

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closeBtn"), function( )
		print("返回大厅")
		LaypopManger_instance:back()
	end)

	self.sureBtn = self.mainLayer:getChildByName("sureBtn")
	WidgetUtils.addClickEvent(self.sureBtn, function( )
		print("确定 进入房间")
		self:sureBtnCall()
	end)

	self.fangka = self.sureBtn:getChildByName("fangka_num")
	self.fangka_sale = self.sureBtn:getChildByName("fangka_num_sale"):setVisible(false)
	self.sureBtn:getChildByName("line_sale"):setVisible(false)


	self:initLeftListView()
	self:initTitle() --之前是因为创建房间界面需要切换，现在有三种，切换不了，于是取消
	if self.selecttype ~= 99 then
		self:initListView()
	end
end

function CreateRoomViewNew:initLeftListView()
	self.listView = self.mainLayer:getChildByName("listView")
	self.listView:setScrollBarEnabled(false)

	local itemmodel = self.listView:getChildByName("checkmodel")

	itemmodel:retain()
	self.listView:setItemModel(itemmodel)
	itemmodel:removeFromParent()
	itemmodel:release()


	local topArrow = ccui.ImageView:create("common/arrow.png") 
	topArrow:setScaleY(-1)
	self.mainLayer:addChild(topArrow)
	topArrow:setPositionX(-445)
	topArrow:setPositionY(282)
	local moveTo = cc.MoveTo:create(0.5,cc.p(-445,282.00))
	local moveReverse = cc.MoveTo:create(0.4,cc.p(-445,287.00))
	topArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(moveTo,moveReverse)))

	local bottomArrow = ccui.ImageView:create("common/arrow.png") 
	self.mainLayer:addChild(bottomArrow)
	bottomArrow:setPositionX(-445)
	bottomArrow:setPositionY(-337)
	local moveTo_ = cc.MoveTo:create(0.5,cc.p(-445,-337.00))
	local moveReverse = cc.MoveTo:create(0.4,cc.p(-445,-342.00))
	bottomArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(moveTo_,moveReverse)))

	self.listView:onScroll(function(event)
		if event.name and event.name ~= "" then
			if self.listView.showArrow == true then
				if event.name == "BOUNCE_TOP" then
					topArrow:setVisible(false)
				elseif event.name == "BOUNCE_BOTTOM" then
					bottomArrow:setVisible(false)
				else
					local _Y = self.listView:getInnerContainer():getPositionY()
					local _height = self.listView:getContentSize().height - self.listView:getInnerContainerSize().height
					if   _Y < 0  then
						bottomArrow:setVisible(true)
					end
					if  _Y > _height  then
						topArrow:setVisible(true)
					end
				end
			end
		end
	end)

	self.topArrow = topArrow
	self.bottomArrow = bottomArrow
end

function CreateRoomViewNew:initTitle()
	self.mainLayer:getChildByName("title_bg"):setVisible(false)

	--玩法锁定
	if self.isclube  and self.clubedata.lockState == 2 then
		self.mainLayer:getChildByName("title"):setTexture("ui/createroom/suo_title_kaifang.png")
		self.sureBtn:setVisible(false)
		self.mainLayer:getChildByName("text_tip_2"):setVisible(false)
		self.textTip = self.mainLayer:getChildByName("text_tip_1"):setVisible(true)

		WidgetUtils.addClickEvent(self.mainLayer:getChildByName("btn_unlock"), function( )
			print("解除锁定")
			Socketapi.cs_request_change_teabar_create_info(self.clubedata.tbid,self.gametype,"")
		end)

		WidgetUtils.addClickEvent(self.mainLayer:getChildByName("btn_lock"), function( )
			print("锁定玩法")
			local str = self:getSelectInfo()
			Socketapi.cs_request_change_teabar_create_info(self.clubedata.tbid,self.gametype,str)
		end)
	else
		self.mainLayer:getChildByName("btn_unlock"):setVisible(false)
		self.mainLayer:getChildByName("btn_lock"):setVisible(false)
		self.mainLayer:getChildByName("text_tip_1"):setVisible(false)
		self.textTip = self.mainLayer:getChildByName("text_tip_2"):setVisible(true)
		self.sureBtn:setVisible(true)
		if self.selecttype == 99 then
			self.mainLayer:getChildByName("title"):setVisible(false)
			local title_bg = self.mainLayer:getChildByName("title_bg_3"):setVisible(true)

			local check_1 = title_bg:getChildByName("check_1")
			check_1.idx = 1
			local check_2 = title_bg:getChildByName("check_2")
			check_2.idx = 2
			local check_3 = title_bg:getChildByName("check_3")
			check_3.idx = 3

			self:setTitleEvent({check_1,check_2,check_3})
		end
	end


	-- self.check_left = self.mainLayer:getChildByName("title_bg"):getChildByName("check_left")
	-- self.check_right = self.mainLayer:getChildByName("title_bg"):getChildByName("check_right")
	-- self.selecttype = cc.UserDefault:getInstance():getIntegerForKey("game_class_select",1) --选择斗十四还是斗地主
	-- self.check_left:setTag(1)
	-- self.check_right:setTag(2)

	-- if #CM_INSTANCE:getPOKERGAMESLIST() == 0 and #CM_INSTANCE:getMAJIANGGAMESLIST() == 0  then
	-- -- 	self.mainLayer:getChildByName("title_bg"):setVisible(true)
	-- -- else
	-- -- 	self.mainLayer:getChildByName("title_bg"):setVisible(false)
	-- 	self.selecttype =1
	-- end

	-- local function selectedEvent( sender, eventType )
 --        if eventType == ccui.CheckBoxEventType.selected then
 --        	self.check_left:setSelected(false)
 --        	self.check_left:setTouchEnabled(true)

 --        	self.check_right:setSelected(false)
 --        	self.check_right:setTouchEnabled(true)

 --           	sender:setSelected(true)
 --    		sender:setTouchEnabled(false)
 --        	if sender:getTag() == 1 then
 --        		cc.UserDefault:getInstance():setIntegerForKey("game_class_select",1)
 --        		self.selecttype  = 1
 --        	else
 --        		cc.UserDefault:getInstance():setIntegerForKey("game_class_select",2)
 --        		self.selecttype = 2
 --       	 	end
       	 	
 --        end
 --    end
 -- 	if self.selecttype == 1 then
	--     selectedEvent( self.check_left, ccui.CheckBoxEventType.selected )
 --    else
 --    	selectedEvent( self.check_right, ccui.CheckBoxEventType.selected )
 --    end
 --    self.check_left:addEventListener(selectedEvent)
 --    self.check_right:addEventListener(selectedEvent)
 --    self:initListView()
end

function CreateRoomViewNew:setTitleEvent(checklist)
	local function selectedEvent( sender, eventType )
        if eventType == ccui.CheckBoxEventType.selected then
			for i,v in ipairs(checklist) do
				if v.idx ~= sender.idx then
					v:setSelected(false)
					v:setTouchEnabled(true)
				end
			end

			sender:setSelected(true)
			sender:setTouchEnabled(false)
			
			cc.UserDefault:getInstance():setIntegerForKey("game_class_select",sender.idx)
			-- self.selecttype = sender.idx
			self:refeshListView(sender.idx)
		end
    end

    for i,v in ipairs(checklist) do
		v:addEventListener(selectedEvent)

		if v.idx == cc.UserDefault:getInstance():getIntegerForKey("game_class_select",1) then
			print("===============game_class_select",cc.UserDefault:getInstance():getIntegerForKey("game_class_select",1))
			selectedEvent(v, ccui.CheckBoxEventType.selected)
		end
    end
end

function CreateRoomViewNew:initListView()

	self.listView:removeAllItems()

	-- self.selecttype = cc.UserDefault:getInstance():getIntegerForKey("game_class_select",1) --选择斗十四还是斗地主
	self.gametype = cc.UserDefault:getInstance():getIntegerForKey("game_type",CM_INSTANCE:getGAMESLIST()[1])

	-- local huaPais = CM_INSTANCE:getGAMESLIST()
	-- local pokers = CM_INSTANCE:getPOKERGAMESLIST()
	-- local majiangs = CM_INSTANCE:getMAJIANGGAMESLIST()

	-- if #pokers == 0 and #majiangs then
	-- 	self.selecttype = 1 
	-- end

	-- if #huaPais == 0 and #majiangs then
	-- 	self.selecttype = 2 
	-- end

	-- if #pokers == 0 and #huaPais then
	-- 	self.selecttype = 3
	-- end

	local itemlist = {}
	local defaultidx = 1
	local _list = {}

	print("........self.selecttype = ",self.selecttype)

	if self.isclube or self.selecttype == 10 then
		for k,v in pairs(CM_INSTANCE:getGAMESLIST()) do
			table.insert(_list,v)
		end

		for k,v in pairs(CM_INSTANCE:getPOKERGAMESLIST()) do
			table.insert(_list,v)
		end

		for k,v in pairs(CM_INSTANCE:getMAJIANGGAMESLIST()) do
			table.insert(_list,v)
		end
		if self.isclube then
			self.gametype = cc.UserDefault:getInstance():getIntegerForKey("game_type_clube",_list[1])
		else
			self.gametype = cc.UserDefault:getInstance():getIntegerForKey("game_type_all",_list[1])
		end
	else
		if self.selecttype == 1 then
			_list = CM_INSTANCE:getGAMESLIST()
			self.gametype = cc.UserDefault:getInstance():getIntegerForKey("game_type",_list[1])
		elseif self.selecttype == 2 then
			_list = CM_INSTANCE:getPOKERGAMESLIST()
			self.gametype = cc.UserDefault:getInstance():getIntegerForKey("game_type_poker",_list[1])
		elseif self.selecttype == 3 then
			_list = CM_INSTANCE:getMAJIANGGAMESLIST()
			self.gametype = cc.UserDefault:getInstance():getIntegerForKey("game_type_majiang",_list[1])
		end
	end

	table.sort(_list,function(_a,_b)
		if LocalData_instance:getIsFeeByGameType(_a) then
			_a = _a - 100
		end

		local __b = _b 
		if LocalData_instance:getIsFeeByGameType(_b) then
			_b = _b - 100
		end
		return _a < _b
	end)

	for i,v in ipairs(_list) do
		self.listView:pushBackDefaultItem()
		local item = self.listView:getItem(i-1)

		local text1 = item:getChildByName("img1"):getChildByName("text"):ignoreContentAdaptWithSize(true)
		local text2 = item:getChildByName("img2"):getChildByName("text"):ignoreContentAdaptWithSize(true)

		text1:loadTexture("ui/createroom/huapai_"..v.."_1.png")
		text2:loadTexture("ui/createroom/huapai_"..v.."_2.png")
		if  LocalData_instance:getIsFeeByGameType(v)  then
			item:getChildByName("gongce"):setVisible(false)
		else
			item:getChildByName("gongce"):setVisible(true)
		end
		item.ttype = v

		table.insert(itemlist,item)
		if v == self.gametype then
			defaultidx = i
		end
	end

	local function touchEvent(item)
		for m,n in ipairs(itemlist) do
			n:getChildByName("img1"):setVisible(false)
			n:getChildByName("img2"):setVisible(true)
		end
		print(".........item.ttype = ",item.ttype)

		item:getChildByName("img1"):setVisible(true)
		item:getChildByName("img2"):setVisible(false)
		self:clickItem(item.ttype)
		self:refreshCardValue()
	end


	print(".........#itemlist = ",#itemlist)


	for i,item in ipairs(itemlist) do
		item:setTouchEnabled(true)
		WidgetUtils.addClickEvent(item,function ()
			touchEvent(item)
		end)
	end

	touchEvent(itemlist[defaultidx])

	self.topArrow:setVisible(false)
	self.bottomArrow:setVisible(false)
		
	
	if  #_list > 5  then
		self.listView.showArrow = true
		if defaultidx > 5  then
			self.topArrow:setVisible(true)
			self.listView:jumpToPercentVertical(defaultidx/#_list*100)
		else
			self.bottomArrow:setVisible(true)
		end
	else
		self.listView.showArrow = false
	end
end

function CreateRoomViewNew:refeshListView(idx)
	self.listView:removeAllItems()

	-- self.selecttype = cc.UserDefault:getInstance():getIntegerForKey("game_class_select",1) --选择斗十四还是斗地主
	
	local itemlist = {}
	local defaultidx = 1
	local _list = {}

	if idx == 1 then
		_list = CM_INSTANCE:getGAMESLIST()
	elseif idx == 2 then
		_list = CM_INSTANCE:getPOKERGAMESLIST()
	elseif idx == 3 then
		_list = CM_INSTANCE:getMAJIANGGAMESLIST()
	end
	
	table.sort(_list,function(_a,_b)
		if LocalData_instance:getIsFeeByGameType(_a) then
			_a = _a - 100
		end

		local __b = _b 
		if LocalData_instance:getIsFeeByGameType(_b) then
			_b = _b - 100
		end
		return _a < _b
	end)

	self.gametype = cc.UserDefault:getInstance():getIntegerForKey("game_type_"..self.selecttype,_list[1])

	for i,v in ipairs(_list) do
		self.listView:pushBackDefaultItem()
		local item = self.listView:getItem(i-1)

		local text1 = item:getChildByName("img1"):getChildByName("text"):ignoreContentAdaptWithSize(true)
		local text2 = item:getChildByName("img2"):getChildByName("text"):ignoreContentAdaptWithSize(true)

		text1:loadTexture("ui/createroom/huapai_"..v.."_1.png")
		text2:loadTexture("ui/createroom/huapai_"..v.."_2.png")
		if  LocalData_instance:getIsFeeByGameType(v)  then
			item:getChildByName("gongce"):setVisible(false)
		else
			item:getChildByName("gongce"):setVisible(true)
		end
		item.ttype = v

		table.insert(itemlist,item)
		if v == self.gametype then
			defaultidx = i
		end
	end

	local function touchEvent(item)
		for m,n in ipairs(itemlist) do
			n:getChildByName("img1"):setVisible(false)
			n:getChildByName("img2"):setVisible(true)
		end
		print(".........item.ttype = ",item.ttype)

		item:getChildByName("img1"):setVisible(true)
		item:getChildByName("img2"):setVisible(false)
		self:clickItem(item.ttype)
		self:refreshCardValue()
	end


	print(".........#itemlist = ",#itemlist)


	for i,item in ipairs(itemlist) do
		item:setTouchEnabled(true)
		WidgetUtils.addClickEvent(item,function ()
			touchEvent(item)
		end)
	end

	touchEvent(itemlist[defaultidx])

	self.topArrow:setVisible(false)
	self.bottomArrow:setVisible(false)
		
	
	if #_list > 5  then
		self.listView.showArrow = true
		if defaultidx > 5  then
			self.topArrow:setVisible(true)
			self.listView:jumpToPercentVertical(defaultidx/#_list*100)
		else
			self.bottomArrow:setVisible(true)
		end
	else
		self.listView.showArrow = false
	end
end

function CreateRoomViewNew:configToTable(str)
	if not str or str == "" then
		return nil
	end
	printTable(str,"xp227")
	local sub_str_tab = {};

    for i=1,#str do
    	sub_str_tab[i] = tonumber(string.sub(str, i, i));
    end
    printTable(sub_str_tab,"xp227")
    return sub_str_tab
end

function CreateRoomViewNew:clickItem(ttype)
	for i,v in pairs(self.panelList) do
		v:setVisible(false)
	end
	if not ttype then
		return
	end

	self.gametype = ttype
	print(ttype)
	if not self.panelList[ttype] then
		local node = cc.CSLoader:createNode("ui/createroom/tabletype/ttype_"..ttype..".csb")
			:addTo(self.viewList)
		self.panelList[ttype] = node:getChildByName("panel")

		self:setDefaultInfo(ttype,node:getChildByName("panel"))
	end
	self.panelList[ttype]:setVisible(true)

end

function CreateRoomViewNew:setDefaultInfo(ttype,pane)

	-- print(".............................. = ",index)
	-- local pane = self.viewList:getChildByName("panel"..index)
	pane.itemList = {} --数组

	local nodeNum = 0
	local itemIndex = 1
	local item = pane:getChildByName("item"..itemIndex)
	while(item) do

		item:setPositionY(550-(itemIndex-1)*67)

		item.nodeList = {}
		local nodeList = {}
		local nodeIndex = 1
		local node = item:getChildByName("node"..nodeIndex)
		while(node) do
			local check = node:getChildByName("singleCheck")
			check:setPositionY(0)
			check.itemIndex = itemIndex
			check.nodeIndex = nodeIndex

			check:addEventListener(function(sender)
				self:checkItemNode(sender)
			end)
			nodeNum = nodeNum +1
			table.insert(item.nodeList,node)
			nodeIndex = nodeIndex + 1
			node = item:getChildByName("node"..nodeIndex)
		end
		table.insert(pane.itemList,item)
		itemIndex = itemIndex + 1
		item = pane:getChildByName("item"..itemIndex)
	end

	if self.isclube then
		for kk,vv in ipairs(pane.itemList) do
			if kk == 1 then
				vv:setVisible(false)
			end
			vv:setPositionY(vv:getPositionY()+64)
		end
	end

	-- 设置保存的配置
	local defaultselect = self:configToTable(LocalData_instance:getCreateRoomConfig(ttype..LocalData_instance:getUid()))
	
	printTable(defaultselect,"xp227")

	if self.isclube  and (self.clubedata.lockState == 1 or self.clubedata.lockState == 2) then
		defaultselect = nil
		if  self.clubedata.teabar_create_info  and #self.clubedata.teabar_create_info > 0 then
			for k,v in pairs(self.clubedata.teabar_create_info) do
				if v.game_type == ttype then
					defaultselect = self:configToTable(v.create_info)
					self.isLock = true
				end
			end
		end
		
	end

	if defaultselect then
		if #defaultselect ~= nodeNum then
			defaultselect = nil
			self.isLock = false
		end
	else
		self.isLock = false
	end

	if defaultselect then
		print("..................哈哈哈 #defaultselect = ",#defaultselect)
		printTable(defaultselect,"xp227")
		local _defaultIndex = 1
		for i,v in ipairs(pane.itemList) do
			for ii,vv in ipairs(v.nodeList) do
				local check = vv:getChildByName("singleCheck")
				local label = vv:getChildByName("value")
				if self.isclube  and (self.clubedata.lockState == 2 or self.clubedata.lockState == 1) then
					check:loadTextureFrontCross("cocostudio/ui/createroom/suo_lock.png",ccui.TextureResType.localType)
					if  self.clubedata.master_uid == LocalData_instance.uid and self.clubedata.lockState == 2 then -- 如果我是茶馆主
						if defaultselect[_defaultIndex] == 1 then
							check:setSelected(true)
						else
							check:setSelected(false)
						end
					else
						check:loadTextureBackGroundDisabled("cocostudio/ui/createroom/createroom_9.png",ccui.TextureResType.localType)
						check:loadTextureFrontCrossDisabled("cocostudio/ui/createroom/suo_gray_dot.png",ccui.TextureResType.localType)
						if defaultselect[_defaultIndex] == 1 then
							check:setSelected(true)
							check:setTouchEnabled(false)
						else
							check:setSelected(true)
							check:setEnabled(false)
						end
					end
				else
					if defaultselect[_defaultIndex] == 1 then
						check:setSelected(true)
					else
						check:setSelected(false)
					end
				end
				_defaultIndex = _defaultIndex + 1 
			end
		end
	end
	self:specialTreatment(ttype)
end

function CreateRoomViewNew:checkItemNode(nodeCheck)
	print("..........点击单选！nodeCheck.itemIndex ＝ ",nodeCheck.itemIndex)

	-- 判断那些多选的功能
	local pane = self.panelList[self.gametype]
	if 	(self.gametype == HPGAMETYPE.ESSH and nodeCheck.itemIndex == 5 ) or 
		(self.gametype == HPGAMETYPE.LCSDR and nodeCheck.itemIndex == 4 ) or
		(self.gametype == HPGAMETYPE.ESCH and nodeCheck.itemIndex == 4 ) or
		(self.gametype == HPGAMETYPE.JSCH and nodeCheck.itemIndex == 5 ) or
		(self.gametype == HPGAMETYPE.SZ96 and nodeCheck.itemIndex == 4 ) or 
		(self.gametype == HPGAMETYPE.XCCH and nodeCheck.itemIndex == 5 ) or 
		(self.gametype == HPGAMETYPE.HFBH and nodeCheck.itemIndex == 5 ) or 
		(self.gametype == HPGAMETYPE.BDSDR and nodeCheck.itemIndex == 6 ) or
		(self.gametype == HPGAMETYPE.JDPDK and nodeCheck.itemIndex == 5 ) or
		(self.gametype == HPGAMETYPE.SJHP and nodeCheck.itemIndex == 4 )or
		(self.gametype == HPGAMETYPE.WJHP and nodeCheck.itemIndex == 4 )or
		(self.gametype == HPGAMETYPE.ESMJ and (nodeCheck.itemIndex == 5 or nodeCheck.itemIndex == 6)) or
		(self.gametype == HPGAMETYPE.LJSDR and nodeCheck.itemIndex == 5 ) or
		(self.gametype == HPGAMETYPE.FJSDR and nodeCheck.itemIndex == 5 ) or
		(self.gametype == HPGAMETYPE.TCGZP and nodeCheck.itemIndex == 4 )  then 

		self:specialTreatment(self.gametype)
		return
	end

	--	实现，不能同时被选中，
	if self.gametype == HPGAMETYPE.HFBH and nodeCheck.itemIndex == 4  then 
		local isXuan = false 
		for i,v in ipairs(pane.itemList[nodeCheck.itemIndex].nodeList) do
			local check = v:getChildByName("singleCheck")
			local label = v:getChildByName("value")
			if i == nodeCheck.nodeIndex and check:isSelected() then
				isXuan = true
			end
		end
		if isXuan then
			for i,v in ipairs(pane.itemList[nodeCheck.itemIndex].nodeList) do
				local check = v:getChildByName("singleCheck")
				local label = v:getChildByName("value")
				if i ~= nodeCheck.nodeIndex then
					check:setSelected(false)
				end
			end
		end 
		return
	end

	for i,v in ipairs(pane.itemList[nodeCheck.itemIndex].nodeList) do
		local check = v:getChildByName("singleCheck")
		local label = v:getChildByName("value")
		if i == nodeCheck.nodeIndex then
			check:setSelected(true)
			check:setTouchEnabled(false)
		else
			check:setSelected(false)
			check:setTouchEnabled(true)
		end
	end

	--把房卡改变
	if nodeCheck.itemIndex == 1 or nodeCheck.itemIndex == 2 or nodeCheck.itemIndex == 3 then
		self:refreshCardValue()
	end
	
	self:specialTreatment(self.gametype)
end

--特殊处理
function CreateRoomViewNew:specialTreatment(ttype)
	local pane = self.panelList[ttype]
	--特殊处理，每个游戏都有可能有自己的特殊处理
	if ttype == HPGAMETYPE.MCDDZ then
		--算番是不是选择的加法
		if pane.itemList[4].nodeList[1]:getChildByName("singleCheck"):isSelected() then
			pane.itemList[5].nodeList[1]:getChildByName("value"):setString("不封顶")
		else
			pane.itemList[5].nodeList[1]:getChildByName("value"):setString("5炸封顶")
		end
	end

	if ttype == HPGAMETYPE.LCSDR then
		if pane.itemList[2].nodeList[1]:getChildByName("singleCheck"):isSelected() then
			pane.itemList[6]:setVisible(true)
		else
			pane.itemList[6]:setVisible(false)
		end
	end

	if ttype == HPGAMETYPE.SJHP or ttype == HPGAMETYPE.WJHP then
		pane.itemList[8]:setPositionY(550-(7-1)*67)
		if pane.itemList[6].nodeList[1]:getChildByName("singleCheck"):isSelected() then
			pane.itemList[7]:setVisible(true)
			pane.itemList[8]:setVisible(false)
		else
			pane.itemList[7]:setVisible(false)
			pane.itemList[8]:setVisible(true)
		end
		self.btn1 = pane:getChildByName("help1")
		WidgetUtils.addClickEvent(self.btn1, function( )
			self.btn1:getChildByName("Image_1"):setVisible(true)
			pane:getChildByName("touch"):setVisible(true)
		end)
		-- self.btn2 = pane.itemList[6]:getChildByName("help2")
		-- WidgetUtils.addClickEvent(self.btn2, function( )
		-- 	self.btn2:getChildByName("Image_1"):setVisible(true)
		-- 	pane:getChildByName("touch"):setVisible(true)
		-- end)


		WidgetUtils.addClickEvent(pane:getChildByName("touch"), function( )
			self.btn1:getChildByName("Image_1"):setVisible(false)
			pane:getChildByName("touch"):setVisible(false)
		end)
	end


	if ttype == HPGAMETYPE.YCDDZ then
		pane.itemList[2]:setVisible(false)
		pane.itemList[8]:setPositionY(550-(2-1)*67)

	end
	if ttype == HPGAMETYPE.YCXZP then
		if pane.itemList[5].nodeList[1]:getChildByName("singleCheck"):isSelected() then
			pane.itemList[6]:setVisible(true)
			pane.itemList[7]:setPositionY(pane.itemList[6]:getPositionY()-67)
		else
			pane.itemList[6]:setVisible(false)
			pane.itemList[7]:setPositionY(pane.itemList[6]:getPositionY())
		end
	end

	if ttype == HPGAMETYPE.TCGZP  then
		if pane.itemList[2].nodeList[1]:getChildByName("singleCheck"):isSelected() then--三人
			pane.itemList[7].nodeList[2]:setVisible(true)
			pane.itemList[4].nodeList[4]:setVisible(true)
		else
			pane.itemList[7].nodeList[1]:getChildByName("singleCheck"):setSelected(true)
			pane.itemList[7].nodeList[2]:getChildByName("singleCheck"):setSelected(false)
			pane.itemList[7].nodeList[2]:setVisible(false)
			pane.itemList[4].nodeList[4]:setVisible(false)
		end
		if self.isclube == false then
			if pane.itemList[4].nodeList[1]:getChildByName("singleCheck"):isSelected() then--打花
				pane.itemList[8]:setVisible(true)
				self.textTip:setVisible(false)

			else
				pane.itemList[8]:setVisible(false)
				self.textTip:setVisible(true)
			end
		end
	end
end

function CreateRoomViewNew:refreshCardValue()
	local pane = self.panelList[self.gametype]

	local fangkanumbe = 0
	--2人的8局:标准20张,均摊10张; 12局:标准30，均摊15; 16局:标准40,均摊20，
	--3人的8局:标准30张,均摊10张; 12局:标准45，均摊15; 16局:标准60,均摊20，
	--4人的8局:标准40张,均摊10张; 12局:标准60，均摊15; 16局:标准80,均摊20，
	local _fangkaTable = 
		{
			{{30,10},{45,15},{60,20}},
			{{40,10},{60,15},{80,20}}
		}

	--只有利川上大人和恩施楚胡 有两人玩法
	if self.gametype == HPGAMETYPE.LCSDR or self.gametype == HPGAMETYPE.ESCH or 
		self.gametype == HPGAMETYPE.BDMJ or self.gametype == HPGAMETYPE.ESMJ then
		_fangkaTable = 
		{	
			{{20,10},{30,15},{40,20}},
			{{30,10},{45,15},{60,20}},
			{{40,10},{60,15},{80,20}}
		}
	end  
	if self.gametype == HPGAMETYPE.SJHP or self.gametype == HPGAMETYPE.WJHP or 
		self.gametype == HPGAMETYPE.LJSDR or self.gametype == HPGAMETYPE.FJSDR then
		_fangkaTable = 
		{	
			{{30,10},{45,15},{60,20},{75,25}},
		}
	end

	if self.gametype == HPGAMETYPE.TCGZP then
		_fangkaTable = 
		{	
			{{15,5},{30,10},{36,12}},
			{{20,5},{40,10},{48,12}}
		}
	end  

	local _ren = 0
	for k,v in ipairs(pane.itemList[2].nodeList) do
		local check = v:getChildByName("singleCheck")
		if check:isSelected() then
			_ren = k
			break
		end
	end

	local _ju = 0
	for k,v in ipairs(pane.itemList[3].nodeList) do
		local check = v:getChildByName("singleCheck")
		if check:isSelected() then
			_ju = k
			break
		end
	end
	local _fangkatype = 0
	if self.isclube then 
		_fangkatype = self.clubedata.pay_type + 1
	else
		for k,v in ipairs(pane.itemList[1].nodeList) do
			local check = v:getChildByName("singleCheck")
			if check:isSelected() then
				_fangkatype = k
				break
			end
		end
	end
	
	if _ju ~= 0 and _fangkatype ~= 0 then
		fangkanumbe = _fangkaTable[_ren][_ju][_fangkatype]
	end
	if self:getSale(fangkanumbe) == false then
		self.fangka:setString("/"..fangkanumbe)
		self.fangka:setPositionY(52)
		self.fangka_sale:setVisible(false)
		self.sureBtn:getChildByName("line_sale"):setVisible(false)
	end

end

-- 是否打折，
function CreateRoomViewNew:getSale(_num)
	local _saleList = LocalData_instance:getIsSale(self.gametype)
	if _saleList == nil  then
		return false
	end

	local _sale = 1
	local juList = {8,12,16}
	local pane = self.panelList[self.gametype]
	for k,v in ipairs(pane.itemList[3].nodeList) do
		local check = v:getChildByName("singleCheck")
		if _saleList[juList[k]] ~= nil  then
			if v.saleTips == nil then
			    local _saleTips = ccui.ImageView:create("cocostudio/ui/createroom/icon_sale.png")
			    local value = v:getChildByName("value")
			    local _x = value:getPositionX() + value:getContentSize().width 
			    _saleTips:setAnchorPoint(cc.p(0,0.5))
			    _saleTips:setPosition(cc.p(_x,0))
			    v:addChild(_saleTips)
			    v.saleTips = _saleTips
			end
			if check:isSelected() then
				_sale = _saleList[juList[k]]
			end
		end
	end

	if _sale == 1 then
		return false
	end

	self.fangka_sale:setString("/".._num)
	self.fangka_sale:setVisible(true)
	self.sureBtn:getChildByName("line_sale"):setVisible(true)
	_num = math.floor(_num *_sale)

	self.fangka:setString("/".._num)
	self.fangka:setPositionY(63)

	return true
end


-- 得到选中的数据
function CreateRoomViewNew:getSelectInfo()

	local selectInfoList = {}
	local selectPanel = self.panelList[self.gametype]
	if not selectPanel then
		return
	end
	
	print(".................茶馆创建房间,self.isLock = ",self.isLock)

	local savestr = ""
	for i,v in ipairs(selectPanel.itemList) do
		local list = {}
		for ii,vv in ipairs(v.nodeList) do
			local check = vv:getChildByName("singleCheck")
			if self.isclube and self.clubedata.lockState == 1 and self.isLock == true then  --茶馆创建房间

				if check:isEnabled() then
					table.insert(list,check.nodeIndex)
					savestr = savestr.."1"
				else
					savestr = savestr.."0"
				end
			else
				if check:isSelected() then
					table.insert(list,check.nodeIndex)
					savestr = savestr.."1"
				else
					savestr = savestr.."0"
				end
			end
		end
		table.insert(selectInfoList,list)
	end

	if self.isclube  and self.clubedata.lockState == 2 then
		return savestr
	else
		if self.isclube == false then  --茶馆创建房间不保存
			LocalData_instance:setCreateRoomConfig(self.gametype..LocalData_instance.uid,savestr)
		end
	end
	print("...........保存 game_type ＝ ",self.gametype)
	if self.isclube then
		cc.UserDefault:getInstance():setIntegerForKey("game_type_clube", self.gametype)
	else
		if self.selecttype == 1 then
			cc.UserDefault:getInstance():setIntegerForKey("game_type", self.gametype)
		elseif self.selecttype == 2 then
			cc.UserDefault:getInstance():setIntegerForKey("game_type_poker", self.gametype)
		elseif self.selecttype == 3 then
			cc.UserDefault:getInstance():setIntegerForKey("game_type_majiang", self.gametype)
		elseif self.selecttype == 10 then
			cc.UserDefault:getInstance():setIntegerForKey("game_type_all", self.gametype)
		elseif self.selecttype == 99 then
			cc.UserDefault:getInstance():setIntegerForKey("game_type_"..self.selecttype, self.gametype)
		end
	end

	return selectInfoList
end

function CreateRoomViewNew:sureBtnCall()
	
	if not self.gametype then
		return
	end
	local info = self:getSelectInfo()
	-- print("......确定按钮！.",info)
	-- printTable(info,"xp")
	
	local tab = {}
	tab.ttype = self.gametype
	tab.ztype = 10

	--相同类容统一配置
	--支付方式 
	local _paytypetable = {0,1}
	tab.pay_type = _paytypetable[info[1][1]]
	--人数
	local _seat = {3,4,2} --2是补位，在各自的CreateTable函数里面会重新复制，如果有两人的话

	tab.seat_num = _seat[info[2][1]]
	if tab.seat_num ~= 2 and tab.seat_num ~= 3 and tab.seat_num ~= 4 then
		return
	end

	--局数
	local _round = {8,12,16,24}



	tab.round = _round[info[3][1]]

	if self.isclube then
		tab.tbid = self.clubedata.tbid
		tab.master_uid = self.clubedata.master_uid
		tab.is_master_delegate = self.clubedata.is_master_delegate
	end

	local _gametype = 
	{
		[HPGAMETYPE.ESSH]	= function(data) return self:getCreateTable_sh(data) end,
		[HPGAMETYPE.LCSDR]= function(data) return self:getCreateTable_sdr(data) end,
		[HPGAMETYPE.ESCH]= function(data) return self:getCreateTable_ch(data) end,
		[HPGAMETYPE.BDSDR]= function(data) return self:getCreateTable_bdsdr(data) end,
		[HPGAMETYPE.HFBH]= function(data) return self:getCreateTable_hfbh(data) end,
		[HPGAMETYPE.LFSDR]= function(data) return self:getCreateTable_lfsdr(data) end,
		[HPGAMETYPE.JSCH]= function(data) return self:getCreateTable_jsch(data) end,
		[HPGAMETYPE.YSGSDR]= function(data) return self:getCreateTable_ysgsdr(data) end,
		[HPGAMETYPE.SZ96]= function(data) return self:getCreateTable_sz96(data) end,
		[HPGAMETYPE.YSGDDZ]= function(data) return self:getCreateTable_ysgddz(data) end,
		[HPGAMETYPE.MCDDZ]= function(data) return self:getCreateTable_mcddz(data) end,
		[HPGAMETYPE.ESDDZ]= function(data) return self:getCreateTable_esddz(data) end,
		[HPGAMETYPE.XESDR]= function(data) return self:getCreateTable_xesdr(data) end,
		[HPGAMETYPE.XCCH]= function(data) return self:getCreateTable_xcch(data) end,
		[HPGAMETYPE.BDMJ]= function(data) return self:getCreateTable_bdmj(data) end,
		[HPGAMETYPE.XE96]= function(data) return self:getCreateTable_xe96(data) end,
		[HPGAMETYPE.XFSH]= function(data) return self:getCreateTable_xfsh(data) end,
		[HPGAMETYPE.XFPDK]= function(data) return self:getCreateTable_xfpdk(data) end,
		[HPGAMETYPE.JDPDK]= function(data) return self:getCreateTable_jdpdk(data) end,
		[HPGAMETYPE.JDDDZ] = function (data) return self:getCreateTable_jdddz(data) end,
		[HPGAMETYPE.YCXZP] = function (data) return self:getCreateTable_ycxzp(data) end,
		[HPGAMETYPE.YCSDR] = function (data) return self:getCreateTable_ycsdr(data) end,
		[HPGAMETYPE.YCDDZ] = function (data) return self:getCreateTable_ycddz(data) end,
		[HPGAMETYPE.ESMJ] = function (data) return self:getCreateTable_esmj(data) end,
		[HPGAMETYPE.SJHP] = function (data) return self:getCreateTable_sjhp(data) end,
		[HPGAMETYPE.WJHP] = function (data) return self:getCreateTable_wjhp(data) end,
		[HPGAMETYPE.TCGZP] = function (data) return self:getCreateTable_tcgzp(data) end,
		[HPGAMETYPE.LJSDR] = function (data) return self:getCreateTable_ljsdr(data) end,
		[HPGAMETYPE.FJSDR] = function (data) return self:getCreateTable_fjsdr(data) end,

	}
	if  _gametype[self.gametype]  then
		local _tab = _gametype[self.gametype](info)
		for k,v in pairs(_tab) do
		 	tab[k] = v
		 end 
	else
		print("...没有....self.gametype = ",self.gametype)
		return
	end
	print("..............创建。。")
	printTable(tab,"xp26")
	Socketapi.requestCreateTable(tab)
end

--恩施绍胡玩法
function CreateRoomViewNew:getCreateTable_sh(info)
	print("恩施绍胡玩法")
	local tab = {}
	
	local _qiang = {0,1,2}
	tab.qiang_type = _qiang[info[4][1]]

	--玩法 可胡不追
	tab.is_ke_hu_bu_zhui = false
	for k,v in pairs(info[5]) do
		if v == 1 then
			tab.is_ke_hu_bu_zhui = true
		end
	end

	--封顶
	local _feng = {0}
	tab.max_multiple = _feng[info[6][1]]

	return tab
end
--利川上大人
function CreateRoomViewNew:getCreateTable_sdr(info)
	print("利川上大人")
	local tab = {}

	--人数
	local _seat = {2,3,4}
	tab.seat_num = _seat[info[2][1]]

	--玩法
	tab.has_piao = false
	for k,v in pairs(info[4]) do
		if v == 1 then
			tab.has_piao = true
		end
	end
	--封顶
	local _feng = {0}
	tab.max_multiple = _feng[info[5][1]]

	if  tab.seat_num == 2 then
		local _qihu = {16,18}
		tab.special_score = _qihu[info[6][1]]
	end

	return tab
end

--恩施楚胡
function CreateRoomViewNew:getCreateTable_ch(info)
	print("恩施楚胡")
	local tab = {}

	--人数
	local _seat = {2,3,4}
	tab.seat_num = _seat[info[2][1]]

	--玩法
	tab.is_du_gang_jiang_zhao = false
	tab.is_chi_re = false
	for k,v in pairs(info[4]) do
		if v == 1 then
			tab.is_chi_re = true
		end
		if v == 2 then
			tab.is_du_gang_jiang_zhao = true
		end
	end

	--封顶
	local _feng = {0}
	tab.max_multiple = _feng[info[5][1]]

	return tab
end

--巴东上大人
function CreateRoomViewNew:getCreateTable_bdsdr(info)
	print("巴东上大人")
	local tab = {}

	--底分
	local _di = {1,2,5}
	tab.di_score = _di[info[4][1]]

	--起胡
	local _zimo = {21,31}
	tab.jing_hu_score = _zimo[info[5][1]]

	--玩法
	tab.is_dai_kan_mao = false
	tab.is_fangpao_bao_pei = false
	for k,v in pairs(info[6]) do
		if v == 1 then
			tab.is_dai_kan_mao = true
			elseif v == 2 then
			tab.is_fangpao_bao_pei = true
		end
	end

	--封顶
	local _feng = {0}
	tab.max_multiple = _feng[info[7][1]]

	return tab
end

--鹤峰百胡
function CreateRoomViewNew:getCreateTable_hfbh(info)
	print("鹤峰百胡")
	local tab = {}
	
		--玩法
	tab.wu_ba_bu_peng = false
	tab.du_kan_bu_chai = false
	for k,v in pairs(info[4]) do
		if v == 1 then
			tab.wu_ba_bu_peng = true
		elseif v == 2 then
			tab.du_kan_bu_chai = true
		end
	end

	tab.luo_di_sheng_hua = true
	for k,v in pairs(info[5]) do
		if v == 1 then
			tab.luo_di_sheng_hua = false
		end
	end

	--放炮加分
	local _fen = {0,10,20,30}
	tab.pao_fen = _fen[info[6][1]]

	--封顶
	local _feng = {0}
	tab.max_multiple = _feng[info[7][1]]
	return tab

end
--来凤上大人
function CreateRoomViewNew:getCreateTable_lfsdr(info)
	print("来凤上大人")
	local tab = {}

	--玩法
	local _dao_jin = {true,false}
	tab.is_dao_jin = _dao_jin[info[4][1]]
	--封顶
	local _feng = {0}
	tab.max_multiple = _feng[info[5][1]]

	return tab
end

--建始楚胡
function CreateRoomViewNew:getCreateTable_jsch(info)
	print("建始楚胡")
	local tab = {}

	tab.is_long_ke_gua_long = false

	local _countway = {0,1}
	tab.count_way = _countway[info[4][1]]

	-- 玩法
	for k,v in pairs(info[5]) do
		if v == 1 then
			tab.is_long_ke_gua_long = true
		end
	end

	--封顶
	local _feng = {0}
	tab.max_multiple = _feng[info[6][1]]

	return tab
end

--野三关上大人
function CreateRoomViewNew:getCreateTable_ysgsdr(info)
	print("野三关上大人")
	local tab = {}

	--底分
	local _fen = {1,5,10}
	tab.di_score = _fen[info[4][1]]

	--封顶
	local _feng = {0}
	tab.max_multiple = _feng[info[5][1]]

	return tab
end

-- 湘西96
function CreateRoomViewNew:getCreateTable_sz96(info)
	print("湘西96")
	local tab = {}

	tab.has_piao = false
	-- 玩法
	for k,v in pairs(info[4]) do
		if v == 1 then
			tab.has_piao = true
		end
	end
	--封顶
	local _feng = {8}
	tab.max_multiple = _feng[info[5][1]]

	return tab
end

-- 野三关斗地主
function CreateRoomViewNew:getCreateTable_ysgddz(info)
	print("野三关斗地主")
	local tab = {}

	--底分
	local _fen = {1,5,10,20}
	tab.di_score = _fen[info[4][1]]

	--封顶
	local _feng = {40,80,160}
	tab.max_line = _feng[info[5][1]]

	return tab
end


-- 麻城斗地主
function CreateRoomViewNew:getCreateTable_mcddz(info)
	print("麻城斗地主")
	local tab = {}

	--算分方式，0加，1乘
	local _suanfan = {0,1}
	tab.count_way = _suanfan[info[4][1]]

	--封顶，由算分方式决定
	local _fan = {0,5}
	tab.max_multiple = _fan[info[4][1]]

	return tab
end

-- 恩施斗地主
function CreateRoomViewNew:getCreateTable_esddz(info)
	print("恩施斗地主")
	local tab = {}


	--封顶，由算分方式决定
	local _feng = {4,6,8}
	tab.max_multiple = _feng[info[4][1]]

	return tab
end

-- 经典斗地主
function CreateRoomViewNew:getCreateTable_jdddz(info)
	print("经典斗地主")
	local tab = {}

	--封顶，由算分方式决定
	local _feng = {32,64,128}
	tab.max_line = _feng[info[4][1]]

	return tab
end

--宣恩上大人
function CreateRoomViewNew:getCreateTable_xesdr(info)
	local tab = {}
	
	local _qiang = {0,1,2}
	tab.qiang_type = _qiang[info[5][1]]

	--底分
	local _fen = {1,5,10,20}
	tab.di_score = _fen[info[4][1]]
	--算分方式，0加，1乘
	local _suanfan = {0,1}
	tab.count_way = _suanfan[info[6][1]]
	-- --玩法 可胡不追
	-- tab.is_ke_hu_bu_zhui = false
	-- for k,v in pairs(info[5]) do
	-- 	if v == 1 then
	-- 		tab.is_ke_hu_bu_zhui = true
	-- 	end
	-- end

	--封顶
	local _feng = {0}
	tab.max_multiple = _feng[info[7][1]]

	return tab
end
--宣恩 96
function CreateRoomViewNew:getCreateTable_xe96( info )
	local tab = {}
	
	local _qiang = {0,1,2}
	tab.qiang_type = _qiang[info[5][1]]

	--底分
	local _fen = {1,5,10,20}
	tab.di_score = _fen[info[4][1]]

	--封顶
	local _feng = {0}
	tab.max_multiple = _feng[info[6][1]]

	local _countway = {0,1}
	tab.count_way = _countway[info[7][1]]

	return tab
end
--咸丰绍胡
function CreateRoomViewNew:getCreateTable_xfsh( info )
	local tab = {}
	
	local _qiang = {0,1,2}
	tab.qiang_type = _qiang[info[5][1]]

	--底分
	local _fen = {1,5,10,20}
	tab.di_score = _fen[info[4][1]]

	--封顶
	local _feng = {0}
	tab.max_multiple = _feng[info[6][1]]

	return tab
end

-- 孝昌扯胡
function CreateRoomViewNew:getCreateTable_xcch(info)
	print("孝昌扯胡")
	local tab = {}

	--底分
	local _fen = {1,2,3,4}
	tab.di_score = _fen[info[4][1]]


	tab.you_lai_bi_bai = false
	-- 玩法
	for k,v in pairs(info[5]) do
		if v == 1 then
			tab.you_lai_bi_bai = true
		end
	end

	--封顶
	local _feng = {0}
	tab.max_multiple = _feng[info[6][1]]

	return tab
end


-- 巴东麻将
function CreateRoomViewNew:getCreateTable_bdmj(info)
	print("巴东麻将")
	local tab = {}
	--底分
	local _fen = {5,10}
	tab.di_score = _fen[info[4][1]]

	--人数
	local _seat = {2,3,4}
	tab.seat_num = _seat[info[2][1]]

	return tab
end

-- 咸丰3A12
function CreateRoomViewNew:getCreateTable_xfpdk(info)
	print("咸丰3A12")
	local tab = {}

	local _feng = {4,6,8}
	tab.max_bomb = _feng[info[4][1]]

	return tab
end

-- 经典跑得快
function CreateRoomViewNew:getCreateTable_jdpdk(info)
	print("经典跑的快")
	local tab = {}

	local _chupai = {false,true}
	tab.is_last_winner_dealer = _chupai[info[4][1]]

	for k,v in pairs(info[5]) do
		if v == 1 then
			tab.you_da_bi_chu = true
		end
		if v == 2 then
			tab.able_two_lain_dui = true
		end
		if v == 3 then
			tab.bomb_3_a = true
		end
	end

	return tab
end
--宣城上大人
function CreateRoomViewNew:getCreateTable_ycsdr( info)
	local tab = {}
	local tabpiao = {true,false}
	tab.has_piao = tabpiao[info[4][1]]
	local tabinfo = {0,1}
	tab.game_play_type =  tabinfo[info[5][1]]
	tab.seat_num = 4
	return tab
end
--应城斗地主
function CreateRoomViewNew:getCreateTable_ycddz(info)
	local tab = {}
	local _feng = {1,5}
	tab.laizi_num = _feng[info[4][1]]
	local _feng = {4,6,8,0}
	tab.max_bomb = _feng[info[6][1]]
	local _feng = {0,1}
	tab.deal_handcard_type = _feng[info[5][1]]
	local _suanfan = {0,1}
	tab.count_way = _suanfan[info[7][1]]


	local _suanfan = {1,3,5,10}
	tab.di_score = _suanfan[info[8][1]]



	return tab
end

-- 应城小字牌
function CreateRoomViewNew:getCreateTable_ycxzp(info)
	print("应城小字牌")
	local tab = {}

	--底分
	local _fen = {1,3,5,10}
	tab.di_score = _fen[info[4][1]]

	--漂分
	if info[5][1] == 2 then
		tab.piao_score  = 0
 	else
 		_fen = {2,3,5,10}
		tab.piao_score = _fen[info[6][1]]
	end

	--封顶
	local _feng = {0}
	tab.max_multiple = _feng[info[7][1]]
	return tab
end

-- 恩施麻将
function CreateRoomViewNew:getCreateTable_esmj(info)
	print("恩施麻将")
	local tab = {}

	--人数
	local _seat = {2,3,4}
	tab.seat_num = _seat[info[2][1]]

	-- --玩法
	local _game_play_type = {2,3}
	tab.game_play_type = _game_play_type[info[4][1]]


	tab.game_play_type_2 = {}

	-- optional int32 game_play_type = 40;	// 单选玩法类型 0->定张 1->定张定恰定光 2->一癞到底 3->多癞
	-- repeated int32 game_play_type_2 = 41;	// 多选玩法类型 0->抬杠 1->杠上炮 2->禁止养痞 3->打癞禁胡 4->打痞禁胡

	--可选玩法
	for k,v in pairs(info[5]) do
		if v == 1 then
			table.insert(tab.game_play_type_2,0)
		elseif v == 2 then
			table.insert(tab.game_play_type_2,1)
		elseif v == 3 then
			table.insert(tab.game_play_type_2,2)
		end
	end
	--玩法 可选玩法
	for k,v in pairs(info[6]) do
		if v == 1 then
			table.insert(tab.game_play_type_2,3)
		elseif v == 2 then
			table.insert(tab.game_play_type_2,4)
		end
	end

	printTable(tab.game_play_type_2,"xp66")

	--底分
	local _fen = {0.5,1,2.5,5}
	tab.di_score = _fen[info[7][1]] * 10
	return tab
end


function CreateRoomViewNew:getCreateTable_sjhp( info )
	local tab = {}
	tab.game_play_type_2 = {}
	tab.is_fangpao_bao_pei = false
	for k,v in pairs(info[4]) do
		if v == 1 then
			table.insert(tab.game_play_type_2,poker_common_pb.ENM_SDR_PLAY_TYPE_XIAN_DUI)
		elseif v == 2 then
			table.insert(tab.game_play_type_2,poker_common_pb.ENM_SDR_PLAY_TYPE_ZHUO_MIAN_SUAN_ZHU_JING)
		elseif v == 3 then
			table.insert(tab.game_play_type_2,poker_common_pb.ENM_SDR_PLAY_TYPE_ZHI_NENG_ZI_MO)
		elseif v == 4 then
			tab.is_fangpao_bao_pei = true
		end
	end
	if info[5][1] == 1 then
		table.insert(tab.game_play_type_2,poker_common_pb.ENM_SDR_PLAY_TYPE_ZI_DAI_1_KAN_JING)
	elseif info[5][1] == 2 then
		table.insert(tab.game_play_type_2,poker_common_pb.ENM_SDR_PLAY_TYPE_ZI_DAI_2_HUA_JING)
	end

	local _di = {1,2}
	tab.count_way = _di[info[6][1]]
	
	local _round = {4,6,8,10}
	tab.round = _round[info[3][1]]
	if info[6][1] == 1 then
		local _di = {1,2,3}
		tab.special_score = _di[info[7][1]]
	else
		local _di = {1,2,3}
		tab.special_score = _di[info[8][1]]
	end
	return tab
end


function CreateRoomViewNew:getCreateTable_wjhp( info )
	local tab = {}
	tab.game_play_type_2 = {}
	tab.is_fangpao_bao_pei = false
	for k,v in pairs(info[4]) do
		if v == 1 then
			table.insert(tab.game_play_type_2,poker_common_pb.ENM_SDR_PLAY_TYPE_XIAN_DUI)
		elseif v == 2 then
			table.insert(tab.game_play_type_2,poker_common_pb.ENM_SDR_PLAY_TYPE_ZHUO_MIAN_SUAN_ZHU_JING)
		elseif v == 3 then
			table.insert(tab.game_play_type_2,poker_common_pb.ENM_SDR_PLAY_TYPE_ZHI_NENG_ZI_MO)
		elseif v == 4 then
			tab.is_fangpao_bao_pei = true
		end
	end
	if info[5][1] == 1 then
		table.insert(tab.game_play_type_2,poker_common_pb.ENM_SDR_PLAY_TYPE_ZI_DAI_1_KAN_JING)
	elseif info[5][1] == 2 then
		table.insert(tab.game_play_type_2,poker_common_pb.ENM_SDR_PLAY_TYPE_ZI_DAI_2_HUA_JING)
	end

	local _di = {1,2}
	tab.count_way = _di[info[6][1]]
	
	local _round = {4,6,8,10}
	tab.round = _round[info[3][1]]
	if info[6][1] == 1 then
		local _di = {1,2,3}
		tab.special_score = _di[info[7][1]]
	else
		local _di = {1,2,3}
		tab.special_score = _di[info[8][1]]
	end
	return tab
end


-- 通城个子牌
function CreateRoomViewNew:getCreateTable_tcgzp(info)
	-- print("通城个子牌")
	local tab = {}
	-- --玩法 可选玩法
	tab.is_dahua = false
	tab.is_shiduihu = false
	tab.is_yipaoduoxiang = false
	tab.can_jian_pai = false
	for k,v in pairs(info[4]) do
		if v == 1 then
			tab.is_dahua = true
		elseif v == 2 then
			tab.is_shiduihu = true
		elseif v == 3 then
			tab.is_yipaoduoxiang = true
		elseif v == 4 then
			if  info[2][1] == 1 then --第4个选中，并且是三人
				tab.can_jian_pai = true --是否捡牌
			end
		end
	end
	local _list = {0,1,2,3}
	tab.piao_score = _list[info[5][1]]
	local _list = {1,2,3}
	tab.di_score = _list[info[6][1]]

	_list = {7,9}
	tab.hupai_score = _list[info[7][1]]
	if tab.is_dahua == true then
		_list = {0,1}
		tab.suanhua_type = _list[info[8][1]]
	end

	local _round = {4,8,10}
	tab.round = _round[info[3][1]]

	return tab
end



-- 老精上大人
function CreateRoomViewNew:getCreateTable_ljsdr(info)
	print("老精上大人")
	local tab = {}

	local _round = {4,6,8,10}
	tab.round = _round[info[3][1]]

	--底分
	local _di = {1,2,5}
	tab.di_score = _di[info[4][1]]

	-- --玩法
	tab.is_dai_kan_mao = false
	tab.is_fangpao_bao_pei = false
	tab.zimo_score = 0
	tab.qiang_an_mao = false
	for k,v in pairs(info[5]) do
		if v == 1 then
			tab.is_fangpao_bao_pei = true
		elseif v == 2 then
			tab.is_dai_kan_mao = true
		elseif v == 3 then
			tab.zimo_score = 1	
		elseif v == 4 then
			tab.qiang_an_mao = true
		end
	end

	--封顶
	local _feng = {0}
	tab.max_multiple = _feng[info[6][1]]

	return tab
end


-- 当阳翻精上大人
function CreateRoomViewNew:getCreateTable_fjsdr(info)
	print("当阳翻精上大人")
	local tab = {}

	local _round = {4,6,8,10}
	tab.round = _round[info[3][1]]

	--底分
	local _di = {1,2,5}
	tab.di_score = _di[info[4][1]]

	-- --玩法
	tab.is_dai_kan_mao = false
	for k,v in pairs(info[5]) do
		if v == 1 then
			tab.is_dai_kan_mao = true
		end
	end

	--封顶
	local _feng = {0}
	tab.max_multiple = _feng[info[6][1]]

	return tab
end

return CreateRoomViewNew