
-- EN_TeaBar_Date_Type_Today = 1;//今日
-- EN_TeaBar_Date_Type_Yesterday = 2;//昨日
-- EN_TeaBar_Date_Type_Week = 3;//本周
-- EN_TeaBar_Date_Type_Last_Week = 4;//上周
-- EN_TeaBar_Date_Type_Month = 5;//本月
-- EN_TeaBar_Date_Type_Last_Month = 6;//上月
local InfoView = class("InfoView",PopboxBaseView)

function InfoView:ctor(data)
	self.data = data
	if self.data.master_uid ==  LocalData_instance.uid then
		self.ismy = true
	end
	--self.ismy = false
	self:initView()
	self:initEvent()
	
end
function InfoView:initView()
	local widget = cc.CSLoader:createNode("ui/club/info/ClubmainView.csb")
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")

	self.closeBtn = self.mainLayer:getChildByName("closebtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		
		LaypopManger_instance:back()
	end)

	self.returnbtn = self.mainLayer:getChildByName("returnbtn")
	WidgetUtils.addClickEvent(self.returnbtn, function( )
		
		LaypopManger_instance:back()
	end)


	self.input = self.mainLayer:getChildByName("cha"):getChildByName("input")
	self.input:setTextColor(cc.c3b(0x4f, 0x2c, 0x14))
	self.input:setPlaceHolderColor(cc.c3b(0xbb, 0xa5, 0x8d))
	self.input:addEventListener(function(sender, eventType)
        local event = {}
        if eventType == 0 then
            event.name = "ATTACH_WITH_IME"
            -- self.mainLayer:stopAllActions()
            -- self.mainLayer:runAction(cc.MoveTo:create(0.3,cc.p(0,300)))
        elseif eventType == 1 then
            event.name = "DETACH_WITH_IME"
            --  self.mainLayer:stopAllActions()
            -- self.mainLayer:runAction(cc.MoveTo:create(0.3,cc.p(0,0)))
        elseif eventType == 2 then
            event.name = "INSERT_TEXT"
            self:inputsearch()

        elseif eventType == 3 then
            event.name = "DELETE_BACKWARD"
            self:inputsearch()
        end
        -- event.target = sender
        -- callback(event)
        print( event.name)
    end)

    WidgetUtils.addClickEvent(self.mainLayer:getChildByName("cha"):getChildByName("btn"), function( )
		
		self.input:setString("")
		self:inputsearch()
	end)


	self.title = self.mainLayer:getChildByName("bg"):getChildByName("title"):getChildByName("text")
	self.title:setString(self.data.tbname)
	self.cell1 = self.mainLayer:getChildByName("cell1")
	self.cell1:setVisible(false)
	self.listview1 = self.mainLayer:getChildByName("node1"):getChildByName("listview")


	self.cell2 = self.mainLayer:getChildByName("cell2")
	self.cell2:setVisible(false)
	self.listview2 = self.mainLayer:getChildByName("node2"):getChildByName("listview")


	-- local  layout = ccui.Layout:create()
	-- layout:setAnchorPoint(cc.p(0,0))
	-- layout:setContentSize(self.cell:getContentSize())

	-- self.listview:setItemModel(layout)
	self.check1 = self.mainLayer:getChildByName("bg"):getChildByName("check2")
	self.check2 = self.mainLayer:getChildByName("bg"):getChildByName("check1")
	self.btn1 = self.mainLayer:getChildByName("node1"):getChildByName("btn1")
	self.btn2 = self.mainLayer:getChildByName("node1"):getChildByName("btn2")
	self.btn3 = self.mainLayer:getChildByName("node1"):getChildByName("btn3")
	--self.listview:setVisible(false)
	self.list1 = nil 
	self.list2 = nil
	self.list3 = nil
	--按房间结算
	self.list4 = nil
	--
	self.listlocal1 = nil 
	self.listlocal2 = nil 
	self.listlocal3 = nil
	--按房间结算
	self.listlocal4 = nil
	--
 	--local MylistView = require "app.help.MylistView".new(self.listview,self.cell:getContentSize())
 	self.listviewdelegale1 = require "app.help.MylistView".new(self.listview1,self.cell1:getContentSize())
 	self.listviewdelegale1:setTotall(0,true)
 	self.listviewdelegale1:setModelcell(self.cell1)
 	self.listviewdelegale1:setcellAtindex(function(cell,idx)
 		--print("updataidex:"..idx)
 		self:updatacell(cell,idx)
 	end)

 	self.listviewdelegale2 = require "app.help.MylistView".new(self.listview2,self.cell2:getContentSize())
 	self.listviewdelegale2:setTotall(0,true)
 	self.listviewdelegale2:setModelcell(self.cell2)
 	self.listviewdelegale2:setcellAtindex(function(cell,idx)
 		--print("updataidex:"..idx)
 		self:updatacellpaiju(cell,idx)
 	end)


	self.isanmite = true
	WidgetUtils.addClickEvent(self.btn1, function( )
		if self.isanmite then
			return
		end
		self:selectbtn(1)
	end)
	WidgetUtils.addClickEvent(self.btn2, function( )
		if self.isanmite then
			return
		end
		self:selectbtn(2)
	end)
	WidgetUtils.addClickEvent(self.btn3, function( )
		if self.isanmite then
			return
		end
		self:selectbtn(3)
	end)

	self.timesbtn =  self.mainLayer:getChildByName("node1"):getChildByName("Sprite_3"):getChildByName("timesbtn")
	WidgetUtils.addClickEvent(self.timesbtn, function( )
		if self.userlist and #self.userlist > 1 then
			print("排序")
			table.sort(self.userlist,function(a,b)
				return a.play_num > b.play_num
			end)
			self.listviewdelegale1:updataView(true)
		end
	end)

	self.winbtn =  self.mainLayer:getChildByName("node1"):getChildByName("Sprite_3"):getChildByName("winbtn")
	WidgetUtils.addClickEvent(self.winbtn, function( )
		if self.userlist and #self.userlist > 1 then
			print("排序")
			table.sort(self.userlist,function(a,b)
				return a.best_score_num > b.best_score_num
			end)
			self.listviewdelegale1:updataView(true)
		end
	end)


	if self.ismy then

		self.mainLayer:getChildByName("bg"):getChildByName("title"):setVisible(false)
		self.selecttype = cc.UserDefault:getInstance():getIntegerForKey("chaguanselectinfo",2)
		self.check1:setTag(1)
		self.check2:setTag(2)
		local function selectedEvent( sender, eventType )
	        if eventType == ccui.CheckBoxEventType.selected then
	        	self.check1:setSelected(false)
	        	self.check1:setTouchEnabled(true)
	        	-- self.check1:getChildByName("spr1"):setVisible(false)
	        	-- self.check1:getChildByName("spr2"):setVisible(true)
	        	self.check2:setSelected(false)
	        	self.check2:setTouchEnabled(true)
	        	-- self.check2:getChildByName("spr1"):setVisible(false)
	        	-- self.check2:getChildByName("spr2"):setVisible(true)
	           	sender:setSelected(true)
        		sender:setTouchEnabled(false)
        		-- sender:getChildByName("spr1"):setVisible(true)
	        	-- sender:getChildByName("spr2"):setVisible(false)
	        	if sender:getTag() == 1 then
	        		cc.UserDefault:getInstance():setIntegerForKey("chaguanselectinfo",1)
	        		self.mainLayer:getChildByName("cha"):setVisible(true)
	        		self.mainLayer:getChildByName("node1"):setVisible(true)
	        		self.mainLayer:getChildByName("node2"):setVisible(false)
	        		self.selecttype  = 1
	        		if self.isanmite == false then
	        			self:selectbtn(1)
	        		end
	        		self.mainLayer:getChildByName("totallfang"):setVisible(true)
					self.mainLayer:getChildByName("totallxiao"):setVisible(true)
					self.mainLayer:getChildByName("totallfang1"):setVisible(true)
					self.mainLayer:getChildByName("totallxiao1"):setVisible(true)
	        	else
	        		cc.UserDefault:getInstance():setIntegerForKey("chaguanselectinfo",2)
	        		self.mainLayer:getChildByName("cha"):setVisible(false)
	        		self.mainLayer:getChildByName("node2"):setVisible(true)
	        		self.mainLayer:getChildByName("node1"):setVisible(false)
	        		self.mainLayer:getChildByName("totallfang"):setVisible(false)
					self.mainLayer:getChildByName("totallxiao"):setVisible(false)
					self.mainLayer:getChildByName("totallfang1"):setVisible(false)
					self.mainLayer:getChildByName("totallxiao1"):setVisible(false)
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
	    self.check1:setEnabled(false)
	    self.check2:setEnabled(false)
	else
		self.check1:setVisible(false)
		self.check2:setVisible(false)
		self.timesbtn:setVisible(false)
		self.winbtn:setVisible(false)
		self.mainLayer:getChildByName("node2"):setVisible(false)
		self.mainLayer:getChildByName("node1"):setVisible(true)
		self.btn1:setVisible(false)
		self.btn2:setVisible(false)
		self.btn3:setVisible(false)
		 self.mainLayer:getChildByName("node1"):getChildByName("title7"):setVisible(false)
		 self.mainLayer:getChildByName("node1"):getChildByName("title3"):setVisible(false)
		 self.mainLayer:getChildByName("node1"):getChildByName("title4"):setVisible(false)
		 self.mainLayer:getChildByName("node1"):getChildByName("title5"):setVisible(false)
		 self.mainLayer:getChildByName("node1"):getChildByName("title6"):setVisible(false)
		 self.mainLayer:getChildByName("totallfang"):setVisible(false)
		 self.mainLayer:getChildByName("totallxiao"):setVisible(false)
		 self.mainLayer:getChildByName("totallfang1"):setVisible(false)
		self.mainLayer:getChildByName("totallxiao1"):setVisible(false)

	end

end

function InfoView:inputsearch()
	local str = self.input:getString()
	self:updataview( self.selecttype )
end
function InfoView:selectbtn(num)
	self.btn1:setEnabled(true)
	self.btn2:setEnabled(true)
	self.btn3:setEnabled(true)
	self.btn1:getChildByName("1"):setVisible(false)
	self.btn2:getChildByName("1"):setVisible(false)
	self.btn3:getChildByName("1"):setVisible(false)
	self.btn1:getChildByName("2"):setVisible(true)
	self.btn2:getChildByName("2"):setVisible(true)
	self.btn3:getChildByName("2"):setVisible(true)
	if num== 1 then
		self.btn1:setEnabled(false)
		self.btn1:getChildByName("1"):setVisible(true)
		self.btn1:getChildByName("2"):setVisible(false)
	elseif num ==2 then
		self.btn2:setEnabled(false)
		self.btn2:getChildByName("1"):setVisible(true)
		self.btn2:getChildByName("2"):setVisible(false)
	elseif num ==3 then
		self.btn3:setEnabled(false)
		self.btn3:getChildByName("1"):setVisible(true)
		self.btn3:getChildByName("2"):setVisible(false)
	end
	self:getinfo(num)
end

function InfoView:onEndAni()
	self.isanmite = false
	self.check1:setEnabled(true)
	self.check2:setEnabled(true)
	if self.ismy then
		if self.selecttype  == 1 then
			self:selectbtn(1)
		else
			self:getinfo(4)
		end
	else
		self:selectbtn(1)
	end
end

function InfoView:getinfo(type)
	if type == 1 then
		if self.list1 == nil then
			self.list1 = nil
			self:showSmallLoading()
			Socketapi.requestgetuserlistinfo(self.data.tbid,poker_common_pb.EN_TeaBar_Date_Type_Today)
		else
			self:updataview( 1 )
			self:updataviewconf(self.listlocal1.conf)
		end
	elseif type == 2 then
		if self.list2 == nil then
			self.list2 = nil
			self:showSmallLoading()
			Socketapi.requestgetuserlistinfo(self.data.tbid,poker_common_pb.EN_TeaBar_Date_Type_Yesterday)
		else
			self:updataview( 2 )
			self:updataviewconf(self.listlocal2.conf)
		end
	elseif type ==3 then
		if self.list3 == nil then
			self.list3 = nil
			self:showSmallLoading()
			Socketapi.requestgetuserlistinfo(self.data.tbid,poker_common_pb.EN_TeaBar_Date_Type_History)
		else
			self:updataview( 3 )
			self:updataviewconf(self.listlocal3.conf)
		end
	elseif type == 4 then
		if self.list4 == nil then
			self:showSmallLoading()
			Socketapi.requestgetpaijuclub(self.data.tbid)
		else
			self:updataviewconf()
		end
	end
end

function InfoView:updatacell(cell,i)
	local v = self.userlist[i]
	print("-------------")
       
        cell:setVisible(true)
        local path = "cocostudio/ui/club/info/back_graylight.png"
        if i%2 == 0 then
        	path = "common/null.png"
        end
        -- cell:getChildByName("cell"):loadTexture(path, ccui.TextureResType.localType)
        cell:getChildByName("cell"):getChildByName("name"):setString(v.name)
        cell:getChildByName("cell"):getChildByName("uid"):setString("ID:"..v.uid)
        cell:getChildByName("cell"):getChildByName("num1"):setString(v.create_table_num)
        cell:getChildByName("cell"):getChildByName("num2"):setString(v.play_num)
        cell:getChildByName("cell"):getChildByName("num3"):setString(v.best_score_num)
        cell:getChildByName("cell"):getChildByName("num4"):setString(v.settle_num)
        local icon = cell:getChildByName("cell"):getChildByName("node"):getChildByName("icon")
        icon:setScale(0.74)
        if device.platform == "ios" then
       		require("app.ui.common.HeadIcon_Club").new(icon,v.url)
       	else
       		require("app.ui.common.HeadIcon").new(icon,v.url)
       	end

        local jiebtn = cell:getChildByName("cell"):getChildByName("jie")
       	local move = cell:getChildByName("cell"):getChildByName("remove")
       	if v.uid == LocalData_instance.uid then
       		move:setVisible(false)
       	else
       		move:setVisible(true)
       	end
       	jiebtn:setVisible(true)
        if self.ismy then
        	WidgetUtils.addClickEvent(jiebtn, function( )
				LaypopManger_instance:PopBox("JieclueView",self.data.tbid,v.settle_num,function(num)
					print("sure num")
					Socketapi.requestsetjiesuannum( self.data.tbid,v.uid,self.datatype,num)
					self:showSmallLoading()
				end)
			end)
			WidgetUtils.addClickEvent(move, function( )
				
				  LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "是否确定把玩家("..v.name..")移除茶馆?",sureCallFunc = function()
						Socketapi.requestremoveroleclue(self.data.tbid,v.uid)
						self:showSmallLoading()
						--LaypopManger_instance:back()
					
					end,cancelCallFunc = function()
						-- body
					end})
			end)
        else
        	jiebtn:setVisible(false)
        	move:setVisible(false)
        	cell:getChildByName("cell"):getChildByName("num1"):setVisible(false)
        	cell:getChildByName("cell"):getChildByName("num2"):setVisible(false)
        	cell:getChildByName("cell"):getChildByName("num3"):setVisible(false)
        	cell:getChildByName("cell"):getChildByName("num4"):setVisible(false)
        end
	-- end
end
function InfoView:updataview( type )
	print("InfoView:updataview:"..type)
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
	--self.listview:removeAllItems()
	print("------123")
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
	self.listviewdelegale1:setTotall(#self.userlist,true)
	self.listviewdelegale1:updataView(true)
	
end

function InfoView:updatacellpaiju( cell,i )
	local v =  self.listlocal4[i]
	--print("-------------")
       
        cell:setVisible(true)
        local path = "cocostudio/ui/club/info/back_graylight.png"
        if i%2 == 0 then
        	path = "common/null.png"
        end
        -- cell:getChildByName("cell"):loadTexture(path, ccui.TextureResType.localType)
        cell:getChildByName("cell"):getChildByName("name"):setString(v.table.best_name or "")
        cell:getChildByName("cell"):getChildByName("uid"):setString("ID:"..(v.table.best_uid or ""))
        -- local icon = cell:getChildByName("cell"):getChildByName("node"):getChildByName("icon")
        -- icon:setScale(0.74)
        -- require("app.ui.common.HeadIcon_Club").new(icon,v.url)
        

        local jiebtn = cell:getChildByName("cell"):getChildByName("jie")
        if v.table.if_settled then
        	jiebtn:setEnabled(false)
        	--jiebtn:setVisible(false)
        	jiebtn:getChildByName("text2"):setVisible(true)
        	jiebtn:getChildByName("text1"):setVisible(false)
        	cell:getChildByName("cell"):getChildByName("num1"):setVisible(false)
        	cell:getChildByName("cell"):getChildByName("num2"):setVisible(true)
        else
        	jiebtn:setEnabled(true)
        	--jiebtn:setVisible(true)
        	jiebtn:getChildByName("text1"):setVisible(true)
        	jiebtn:getChildByName("text2"):setVisible(false)
        	cell:getChildByName("cell"):getChildByName("num1"):setVisible(true)
        	cell:getChildByName("cell"):getChildByName("num2"):setVisible(false)
        end

         WidgetUtils.addClickEvent(jiebtn, function( )
			self:showSmallLoading()
			Socketapi.requestgettablejiesuantableclub(self.data.tbid,v.table.statistics_id)
		end)

        local infobtn = cell:getChildByName("cell"):getChildByName("remove")
        WidgetUtils.addClickEvent(infobtn, function( )
			self:showSmallLoading()
			Socketapi.requestgettablejiesuantableinfoclub(self.data.tbid,v.table.statistics_id)
		end)
      	cell:getChildByName("cell"):getChildByName("tableid"):setString(v.table.tid)
      	cell:getChildByName("cell"):getChildByName("num3"):setString(v.table.conf.round)
      	
      	local datetab = os.date("*t", v.table.statistics_time)
      	local str = string.format("%d-%02d-%02d %02d:%02d:%02d",datetab.year,datetab.month,datetab.day,datetab.hour,datetab.min,datetab.sec)
        cell:getChildByName("cell"):getChildByName("num4"):setString(str)

end
function InfoView:updataviewpaiju(  )

	--self.listlocal4
	self.datatype = poker_common_pb.EN_TeaBar_Date_Type_History
	--self.listview:removeAllItems()
	print("------123")
	--self.listlocal4
	self.listviewdelegale2:setTotall(#self.listlocal4,true)
	self.listviewdelegale2:updataView(true)
	
end


function InfoView:updataviewconf( data )
	if data == nil then
		self.mainLayer:getChildByName("totallfang"):setVisible(false)
		self.mainLayer:getChildByName("totallxiao"):setVisible(false)
		self.mainLayer:getChildByName("totallfang1"):setVisible(false)
		self.mainLayer:getChildByName("totallxiao1"):setVisible(false)
	else
		-- if self.ismy  then
		-- 	self.mainLayer:getChildByName("totallfang"):setVisible(true)
		-- 	self.mainLayer:getChildByName("totallxiao"):setVisible(true)
		-- end
		self.mainLayer:getChildByName("totallfang"):setString(data.create_table_num)
		self.mainLayer:getChildByName("totallxiao"):setString(data.cost_chips)
	end
end
function InfoView:getinfocallback( data )
	printTable(data,"sjp3")
	self:hideSmallLoading()
	--self:updataviewconf(data)
	if data.result ==0 then
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
			end
		end
	else
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end

function InfoView:cs_response_remove_user(data)
	self:hideSmallLoading()
	if data.result == 0 then
		local findpos = nil
		if self.list1 and self.data.tbid == data.tbid then
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
		if self.list2 and self.data.tbid == data.tbid then
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
		if self.list3 and self.data.tbid == data.tbid then
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

function InfoView:getinfopaijucallback(data)
	self:hideSmallLoading()
	if data.result ==0 then
		
		if data.stat_tables then
			if self.list4 == nil then
				self.list4 = {}
			end
			for i,v in ipairs(data.stat_tables) do
				table.insert(self.list4,v)
			end
			if data.is_end then
				self.listlocal4  = self.list4
				self:updataviewpaiju(1)
				self:updataviewconf()
			end
		end
	else
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
function InfoView:cs_response_modify_settle_num( data )
	self:hideSmallLoading()
	if data.result == 0 then
		if data.date_type == poker_common_pb.EN_TeaBar_Date_Type_Today then
			if self.list1 and self.data.tbid == data.tbid then
				for i,v in ipairs(self.list1) do
					if v.uid == data.uid then
						self.list1[i].settle_num = data.settle_num
					end
				end
			end
		elseif data.date_type == poker_common_pb.EN_TeaBar_Date_Type_Yesterday then
			if self.list2 and self.data.tbid == data.tbid then
				for i,v in ipairs(self.list2) do
					if v.uid == data.uid then
						self.list2[i].settle_num = data.settle_num
					end
				end
			end
		elseif data.date_type == poker_common_pb.EN_TeaBar_Date_Type_History then
			if self.list3 and self.data.tbid == data.tbid then
				for i,v in ipairs(self.list3) do
					if v.uid == data.uid then
						self.list3[i].settle_num = data.settle_num
					end
				end
			end
		end
		self.listviewdelegale1:updataView(true)
	else
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
function InfoView:cs_response_tea_bar_statistics( data )
	self:hideSmallLoading()
	if data.result == 0 then
		LaypopManger_instance:backByName("TablejiesuanInfo")
		LaypopManger_instance:PopBox("TablejiesuanInfo",data)
	else
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
function InfoView:cs_response_tea_bar_table_settle(data)
	self:hideSmallLoading()
	if data.result == 0 then
		if self.list4 ~= nil then
			for i,v in ipairs(self.list4) do
				if v.table.statistics_id == data.statistics_id then
					self.list4[i].table.if_settled = true
				end
			end
			self.listviewdelegale2:updataView(true)
		end
	else
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
--
function InfoView:initEvent()
	--cs_response_statistics_table_record_list
	
	ComNoti_instance:addEventListener("cs_response_tea_bar_table_settle",self,self.cs_response_tea_bar_table_settle)
	ComNoti_instance:addEventListener("cs_response_tea_bar_statistics",self,self.cs_response_tea_bar_statistics)
	ComNoti_instance:addEventListener("cs_response_statistics_table_record_list",self,self.getinfopaijucallback)
	ComNoti_instance:addEventListener("cs_response_get_tea_bar_user_list",self,self.getinfocallback)
	ComNoti_instance:addEventListener("cs_response_remove_user",self,self.cs_response_remove_user)
	ComNoti_instance:addEventListener("cs_response_modify_settle_num",self,self.cs_response_modify_settle_num)
end
return InfoView