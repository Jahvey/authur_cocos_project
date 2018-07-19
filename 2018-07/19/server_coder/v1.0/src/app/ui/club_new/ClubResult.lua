
-- EN_TeaBar_Date_Type_Today = 1;//今日
-- EN_TeaBar_Date_Type_Yesterday = 2;//昨日
-- EN_TeaBar_Date_Type_Week = 3;//本周
-- EN_TeaBar_Date_Type_Last_Week = 4;//上周
-- EN_TeaBar_Date_Type_Month = 5;//本月
-- EN_TeaBar_Date_Type_Last_Month = 6;//上月
local ClubResult = class("ClubResult",PopboxBaseView)

function ClubResult:ctor(_parent)
	self.parent = _parent
	self:initView()
	self:initEvent()
end
function ClubResult:initView()
	local widget = cc.CSLoader:createNode("ui/club/club_main/Club_result.csb")
	widget:addTo(self)
	self.mainLayer = widget:getChildByName("main")


	--按局结算
	self.juNode = self.mainLayer:getChildByName("node2")
	local juCell = self.mainLayer:getChildByName("cell2"):setVisible(false)
	self.juListView = self.juNode:getChildByName("listview")
	self.juListView:setItemModel(juCell)
	self.juListView:setScrollBarEnabled(false)
	

	--按人结算
	self.renNode = self.mainLayer:getChildByName("node1")
	local renCell = self.mainLayer:getChildByName("cell1"):setVisible(false)
	self.renListView = self.renNode:getChildByName("listview")
	self.renListView:setItemModel(renCell)
	self.renListView:setScrollBarEnabled(false)

	local chooseBack = self.renNode:getChildByName("back_img"):setVisible(false)

	self.dateBtn = self.renNode:getChildByName("Btn_date")
	WidgetUtils.addClickEvent(self.dateBtn, function( )
		chooseBack:setVisible(not chooseBack:isVisible())
	end)
	self.isanmite = true
	local _BtnList = {}
	local _text = {"今日","昨日","历史"}
	for i=1,3 do
		local btn = chooseBack:getChildByName("btn_"..i)
		btn:setTag(i)
		WidgetUtils.addClickEvent(btn, function( )
			if self.isanmite then
				return
			end
			local _tag = btn:getTag()
			for ii,vv in ipairs(_BtnList) do
				if _tag == vv:getTag() then
					vv:setEnabled(false)
					vv:setTitleColor(cc.c3b( 0xff, 0xd3, 0x21))
				else
					vv:setEnabled(true)
					vv:setTitleColor(cc.c3b( 0xbb, 0xbb, 0xbb))
				end
			end
			chooseBack:setVisible(false)
			self:getinfo(_tag)
			self.dateBtn:getChildByName("text"):setString(_text[_tag])
		end)
		table.insert(_BtnList,btn)
	end

	self.list1 = nil 
	self.list2 = nil
	self.list3 = nil
	--按房间结算
	self.list4 = nil
	--
	self.listlocal1 = nil 
	self.listlocal2 = nil 
	self.listlocal3 = nil


	self.timesbtn =  self.renNode:getChildByName("Sprite_3"):getChildByName("timesbtn")
	WidgetUtils.addClickEvent(self.timesbtn, function( )
		if self.userlist and #self.userlist > 1 then
			print("排序")
			table.sort(self.userlist,function(a,b)
				return a.play_num > b.play_num
			end)
			self:updatacell_ren()
		end
	end)

	self.winbtn =  self.renNode:getChildByName("Sprite_3"):getChildByName("winbtn")
	WidgetUtils.addClickEvent(self.winbtn, function( )
		if self.userlist and #self.userlist > 1 then
			print("排序")
			table.sort(self.userlist,function(a,b)
				return a.best_score_num > b.best_score_num
			end)
			self:updatacell_ren()
		end
	end)

	self.check1 = self.mainLayer:getChildByName("bg"):getChildByName("check2")
	self.check2 = self.mainLayer:getChildByName("bg"):getChildByName("check1")

	self.selecttype = cc.UserDefault:getInstance():getIntegerForKey("chaguanselectinfo",2)
	self.check1:setTag(1)
	self.check2:setTag(2)

	local function selectedEvent( sender, eventType )
        if eventType == ccui.CheckBoxEventType.selected then
        	self.check1:setSelected(false)
        	self.check1:setTouchEnabled(true)

        	self.check2:setSelected(false)
        	self.check2:setTouchEnabled(true)

           	sender:setSelected(true)
    		sender:setTouchEnabled(false)
        	if sender:getTag() == 1 then
        		cc.UserDefault:getInstance():setIntegerForKey("chaguanselectinfo",1)
        		self.renNode:setVisible(true)
        		self.juNode:setVisible(false)
        		self.selecttype  = 1
        		if self.isanmite == false then
        			self:getinfo(1)        		end
        	else
        		cc.UserDefault:getInstance():setIntegerForKey("chaguanselectinfo",2)
        		self.juNode:setVisible(true)
        		self.renNode:setVisible(false)
        		self.selecttype = 2
        		if self.isanmite == false then
        			self:getinfo(4)
        		end
       	 	end
        end
    end
 	if self.selecttype == 1 then
	    selectedEvent( self.check1, ccui.CheckBoxEventType.selected )
    else
    	selectedEvent( self.check2, ccui.CheckBoxEventType.selected )
    end
    self.check1:addEventListener(selectedEvent)
    self.check2:addEventListener(selectedEvent)

	self.input = self.renNode:getChildByName("cha"):getChildByName("input")
	self.input:setTextColor(cc.c3b( 0x4f, 0x2c, 0x14))
	self.input:setPlaceHolderColor(cc.c3b( 0xa0, 0x7b, 0x50))
	self.input:addEventListener(function(sender, eventType)
        local event = {}
        if eventType == 0 then
            event.name = "ATTACH_WITH_IME"
        elseif eventType == 1 then
            event.name = "DETACH_WITH_IME"
        elseif eventType == 2 then
            event.name = "INSERT_TEXT"
            self:inputsearch()

        elseif eventType == 3 then
            event.name = "DELETE_BACKWARD"
            self:inputsearch()
        end
        print( event.name)
    end)

    WidgetUtils.addClickEvent(self.renNode:getChildByName("cha"):getChildByName("btn"), function( )
		self:inputsearch()
	end)
	 WidgetUtils.addClickEvent(self.renNode:getChildByName("cha"):getChildByName("btn_clear"), function( )
		self.input:setString("")
		self:inputsearch()
	end)

end

function ClubResult:updataView(data)
	print("...........ClubResult:updataView() self.tbid= ",data.tbid)
	self.tbid = data.tbid
	self.parent:showSmallLoading()

	self.isanmite = false
	if  self.datatype  then
	else
		if self.selecttype  == 1 then
			self.datatype  = 1
		else
			self.datatype  = 4
		end
	end
	self.list1 = nil
	self.list2 = nil
	self.list3 = nil
	self.list4 = nil

	if self.datatype == 4 then
		Socketapi.requestgetpaijuclub(self.tbid)
	else
		Socketapi.requestgetuserlistinfo(self.tbid,self.datatype)
	end
end

function ClubResult:inputsearch()
	local str = self.input:getString()
	self:updataview( self.selecttype )
end

function ClubResult:getinfo(type)

	print("...........ClubResult:getinfo  type = ",type)
	if type == 1 then
		if self.list1 == nil then
			self.list1 = nil
			self.parent:showSmallLoading()
			Socketapi.requestgetuserlistinfo(self.tbid,poker_common_pb.EN_TeaBar_Date_Type_Today)
		else
			self:updataview( 1 )
			self:updataviewconf(self.listlocal1.conf)
		end
	elseif type == 2 then
		if self.list2 == nil then
			self.list2 = nil
			self.parent:showSmallLoading()
			Socketapi.requestgetuserlistinfo(self.tbid,poker_common_pb.EN_TeaBar_Date_Type_Yesterday)
		else
			self:updataview( 2 )
			self:updataviewconf(self.listlocal2.conf)
		end
	elseif type ==3 then
		if self.list3 == nil then
			self.list3 = nil
			self.parent:showSmallLoading()
			Socketapi.requestgetuserlistinfo(self.tbid,poker_common_pb.EN_TeaBar_Date_Type_History)
		else
			self:updataview( 3 )
			self:updataviewconf(self.listlocal3.conf)
		end
	elseif type == 4 then
		if self.list4 == nil then
			self.parent:showSmallLoading()
			Socketapi.requestgetpaijuclub(self.tbid)
		else
			self:updataviewconf()
		end
	end
end


function ClubResult:updatacell_ren()

	self.renListView:removeAllItems()
	for i,v in ipairs(self.userlist) do
		self.renListView:pushBackDefaultItem()

    	local cell = self.renListView:getItem(i-1)
		cell:setVisible(true)
		-- v.name = "今日长牌（南充&西充）客服"
		cell:getChildByName("cell"):getChildByName("name"):setString(ComHelpFuc.GetShortName(v.name,18))
        cell:getChildByName("cell"):getChildByName("uid"):setString("ID:"..v.uid)
        cell:getChildByName("cell"):getChildByName("num1"):setString(v.create_table_num)
        cell:getChildByName("cell"):getChildByName("num2"):setString(v.play_num)
        cell:getChildByName("cell"):getChildByName("num3"):setString(v.best_score_num)
        cell:getChildByName("cell"):getChildByName("num4"):setString(v.settle_num)
        local icon = cell:getChildByName("cell"):getChildByName("node"):getChildByName("icon")
       	local headicon = require("app.ui.common.HeadIcon").new(icon,v.url,70).headicon
       	if headicon then
    		headicon:setTouchEnabled(false)
    	end	
       	
        local jiebtn = cell:getChildByName("cell"):getChildByName("jie")
       	local move = cell:getChildByName("cell"):getChildByName("remove")
       	if v.uid == LocalData_instance.uid then
       		move:setVisible(false)
       	else
       		move:setVisible(true)
       	end
       	jiebtn:setVisible(true)
    	
    	WidgetUtils.addClickEvent(jiebtn, function( )
			LaypopManger_instance:PopBox("JieclueView",self.tbid,v.settle_num,function(num)
				print("sure num")
				Socketapi.requestsetjiesuannum( self.tbid,v.uid,self.datatype,num)
				self.parent:showSmallLoading()
			end)
		end)
		WidgetUtils.addClickEvent(move, function( )
			
			  LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "是否确定把玩家("..v.name..")移除亲友圈?",sureCallFunc = function()
					Socketapi.requestremoveroleclue(self.tbid,v.uid)
					self.parent:showSmallLoading()
				
				end,cancelCallFunc = function()
				end})
		end)
	end
end



function ClubResult:updataview( type )
	print("ClubResult:updataview:"..type)
	self.selecttype  = type
	local userlist  = {}
	if type == 1 then
		userlist  = self.listlocal1
		self.datatype = poker_common_pb.EN_TeaBar_Date_Type_Today
	elseif type == 2 then
		userlist  = self.listlocal2
		self.datatype   =poker_common_pb.EN_TeaBar_Date_Type_Yesterday
	elseif type == 3 then
		userlist  = self.listlocal3
		self.datatype = poker_common_pb.EN_TeaBar_Date_Type_History
	end
	self.userlist = userlist
	if self.input:getString() ~= "" then
		print("456")
		self.userlist = {}
		for i,v in ipairs(userlist) do
			local x1,x2=string.find(tostring(v.uid), self.input:getString())
			if x1 == 1 then
				print("insert  search")
				table.insert(self.userlist,v)
			end
		end
	end
	self:updatacell_ren()
end


function ClubResult:updatacell_ju()
	self.juListView:removeAllItems()
	for i,v in ipairs(self.list4) do
		self.juListView:pushBackDefaultItem()
    	local cell = self.juListView:getItem(i-1)
		cell:setVisible(true)
		-- v.table.best_name = "今日长牌（南充&西充）客服"
		local _name  = v.table.best_name or ""
        cell:getChildByName("cell"):getChildByName("name"):setString(ComHelpFuc.GetShortName(_name,18))
        cell:getChildByName("cell"):getChildByName("uid"):setString("ID:"..(v.table.best_uid or ""))

        local jiebtn = cell:getChildByName("cell"):getChildByName("jie")
        if v.table.if_settled then
        	jiebtn:setEnabled(false)
        	jiebtn:getChildByName("text2"):setVisible(true)
        	jiebtn:getChildByName("text1"):setVisible(false)
        	cell:getChildByName("cell"):getChildByName("num1"):setVisible(false)
        	cell:getChildByName("cell"):getChildByName("num2"):setVisible(true)
        else
        	jiebtn:setEnabled(true)
        	jiebtn:getChildByName("text1"):setVisible(true)
        	jiebtn:getChildByName("text2"):setVisible(false)
        	cell:getChildByName("cell"):getChildByName("num1"):setVisible(true)
        	cell:getChildByName("cell"):getChildByName("num2"):setVisible(false)
        end

         WidgetUtils.addClickEvent(jiebtn, function( )
			self.parent:showSmallLoading()
			Socketapi.requestgettablejiesuantableclub(self.tbid,v.table.statistics_id)
		end)

        local infobtn = cell:getChildByName("cell"):getChildByName("remove")
        WidgetUtils.addClickEvent(infobtn, function( )
			self.parent:showSmallLoading()
			Socketapi.requestgettablejiesuantableinfoclub(self.tbid,v.table.statistics_id)
		end)
      	cell:getChildByName("cell"):getChildByName("tableid"):setString(v.table.tid)
      	cell:getChildByName("cell"):getChildByName("num3"):setString(v.table.conf.round)
      	
      	local datetab = os.date("*t", v.table.statistics_time)
      	local str = string.format("%d-%02d-%02d",datetab.year,datetab.month,datetab.day)
        cell:getChildByName("cell"):getChildByName("num4"):setString(str)

        str = string.format("%02d:%02d:%02d",datetab.hour,datetab.min,datetab.sec)
        cell:getChildByName("cell"):getChildByName("num5"):setString(str)

        
	end
end

function ClubResult:updataviewpaiju(  )

	self.datatype = poker_common_pb.EN_TeaBar_Date_Type_History
	self:updatacell_ju()
end



function ClubResult:updataviewconf( data )
	if data == nil then
	else
		self.mainLayer:getChildByName("totallfang"):setString(data.create_table_num)
		self.mainLayer:getChildByName("totallxiao"):setString(data.cost_chips)
	end
end
function ClubResult:getinfocallback( data )
	
	print("ClubResult:getinfocallback..............1")

	printTable(data,"sjp3")
	-- 
	--self:updataviewconf(data)
	if data.result == 0 then
		--self:updataviewconf( data )
		if data.date_type == poker_common_pb.EN_TeaBar_Date_Type_Today then
			if self.list1 == nil then
				self.list1 = {}
			end
			for i,v in ipairs(data.users) do
				table.insert(self.list1,v)
			end

			if data.is_end then
				self.listlocal1  = self.list1
				self.listlocal1.conf = data
				self:updataview(1)
				self:updataviewconf( data )
				self.parent:hideSmallLoading()
			end
		elseif data.date_type == poker_common_pb.EN_TeaBar_Date_Type_Yesterday then
			if self.list2 == nil then
				self.list2 = {}
			end
			for i,v in ipairs(data.users) do
				table.insert(self.list2,v)
			end
			if data.is_end then
				self.listlocal2  = self.list2
				self.listlocal2.conf = data
				self:updataview(2)
				self:updataviewconf( data )
				self.parent:hideSmallLoading()
			end
		elseif data.date_type == poker_common_pb.EN_TeaBar_Date_Type_History then
			if self.list3 == nil then
				self.list3 = {}
			end
			for i,v in ipairs(data.users) do
				table.insert(self.list3,v)
			end
			if data.is_end then
				self.listlocal3 = self.list3
				self.listlocal3.conf = data
				self:updataview(3)
				self:updataviewconf( data )
				self.parent:hideSmallLoading()
			end
		end
	else
		self.parent:hideSmallLoading()
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end

function ClubResult:cs_response_remove_user(data)
	self.parent:hideSmallLoading()
	if data.result == 0 then
		local findpos = nil
		if self.list1 and self.tbid == data.tbid then
			for i,v in ipairs(self.list1) do
				if v.uid == data.uid then
					findpos = i
				end
			end
		end
		if findpos then
			table.remove(self.list1,findpos)
		end

		local findpos = nil
		if self.list2 and self.tbid == data.tbid then
			for i,v in ipairs(self.list2) do
				if v.uid == data.uid then
					findpos = i
				end
			end
		end
		if findpos then
			table.remove(self.list2,findpos)
		end

		local findpos = nil
		if self.list3 and self.tbid == data.tbid then
			for i,v in ipairs(self.list3) do
				if v.uid == data.uid then
					findpos = i
				end
			end
		end
		if findpos then
			table.remove(self.list3,findpos)
		end

		local findpos = nil
		for i,v in ipairs(self.userlist) do
			if v.uid == data.uid then
					findpos = i
				end
		end
		if findpos then
			table.remove(self.userlist,findpos)
		end

		self:inputsearch()

	else
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end

function ClubResult:getinfopaijucallback(data)
	if data.result ==0 then
		if data.stat_tables then
			if self.list4 == nil then
				self.list4 = {}
			end
			for i,v in ipairs(data.stat_tables) do
				table.insert(self.list4,v)
			end
			if data.is_end then
				self:updataviewpaiju(1)
				self:updataviewconf()
				self.parent:hideSmallLoading()
			end
		else
			self.parent:hideSmallLoading()
		end
	else
		self.parent:hideSmallLoading()
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
function ClubResult:cs_response_modify_settle_num( data )
	self.parent:hideSmallLoading()
	if data.result == 0 then
		local index = -1
		if data.date_type == poker_common_pb.EN_TeaBar_Date_Type_Today then
			if self.list1 and self.tbid == data.tbid then
				for i,v in ipairs(self.list1) do
					if v.uid == data.uid then
						self.list1[i].settle_num = data.settle_num
						index = i
					end
				end
			end
		elseif data.date_type == poker_common_pb.EN_TeaBar_Date_Type_Yesterday then
			if self.list2 and self.tbid == data.tbid then
				for i,v in ipairs(self.list2) do
					if v.uid == data.uid then
						self.list2[i].settle_num = data.settle_num
						index = i
					end
				end
			end
		elseif data.date_type == poker_common_pb.EN_TeaBar_Date_Type_History then
			if self.list3 and self.tbid == data.tbid then
				for i,v in ipairs(self.list3) do
					if v.uid == data.uid then
						self.list3[i].settle_num = data.settle_num
						index = i
					end
				end
			end
		end
		if  index ~= -1 then
			local cell = self.renListView:getItem(index-1)
    	    cell:getChildByName("cell"):getChildByName("num4"):setString(data.settle_num)
		end

		-- self:updatacell_ren()
		-- self.listviewdelegale1:updataView(true)
	else
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
function ClubResult:cs_response_tea_bar_statistics( data )
	self.parent:hideSmallLoading()
	if data.result == 0 then
		LaypopManger_instance:backByName("TablejiesuanInfo")
		LaypopManger_instance:PopBox("TablejiesuanInfo",data)
	else
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
function ClubResult:cs_response_tea_bar_table_settle(data)
	self.parent:hideSmallLoading()
	if data.result == 0 then
		if self.list4 ~= nil then
			for i,v in ipairs(self.list4) do
				if v.table.statistics_id == data.statistics_id then
					self.list4[i].table.if_settled = true

					local cell = self.juListView:getItem(i-1)
					local jiebtn = cell:getChildByName("cell"):getChildByName("jie")
					jiebtn:setEnabled(false)
		        	jiebtn:getChildByName("text2"):setVisible(true)
		        	jiebtn:getChildByName("text1"):setVisible(false)
		        	cell:getChildByName("cell"):getChildByName("num1"):setVisible(false)
		        	cell:getChildByName("cell"):getChildByName("num2"):setVisible(true)
				end
			end
			-- self.listviewdelegale2:updataView(true)
			-- self:updatacell_ju()
		end
	else
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
--
function ClubResult:initEvent()
	
	ComNoti_instance:addEventListener("cs_response_tea_bar_table_settle",self,self.cs_response_tea_bar_table_settle)
	ComNoti_instance:addEventListener("cs_response_tea_bar_statistics",self,self.cs_response_tea_bar_statistics)
	ComNoti_instance:addEventListener("cs_response_statistics_table_record_list",self,self.getinfopaijucallback)
	ComNoti_instance:addEventListener("cs_response_get_tea_bar_user_list",self,self.getinfocallback)
	ComNoti_instance:addEventListener("cs_response_remove_user",self,self.cs_response_remove_user)
	ComNoti_instance:addEventListener("cs_response_modify_settle_num",self,self.cs_response_modify_settle_num)
end
return ClubResult