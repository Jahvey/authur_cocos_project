----------------------------
--茶馆列表
----------------------------
local MainView = class("MainView",PopboxBaseView)

function MainView:ctor(data)
	self.data = data
	self.ismy = false
	MAINCLUBDATA = data
	CURTBID = self.data.tbid

	self.selectType = -1
	if self.data.master_uid ==  LocalData_instance.uid then
		self.ismy = true
	end
	self:initView()
	self:initEvent()

end
function MainView:initView()
	local widget = cc.CSLoader:createNode("ui/club/club_main/ClubmainView.csb")
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")
	MAINCLUB = self
	-- self:retain()

	self.mainLayer:getChildByName("helpbtn"):setVisible(false)
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("helpbtn"), function( )
		LaypopManger_instance:PopBox("JieshaoclueView")
	end)
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("returnbtn"), function( )
		self:stopAllActions()
		LaypopManger_instance:back()
		CURTBID = 0 
		MAINCLUBDATA = nil
	end)

	self.title = self.mainLayer:getChildByName("bg"):getChildByName("title"):getChildByName("text")
	self.title:setString(self.data.tbname)

	self.listView = self.mainLayer:getChildByName("left_list")

	self.addNode = self.mainLayer:getChildByName("addNode")

	ComHelpFuc.setScrollViewEvent(self.listView)
	self.listView:setScrollBarEnabled(false)

	self._typeCheck = {}
	for i=1,4 do
		local item = self.listView:getChildByName("checkmodel_"..i)
		item.ttype = i
		table.insert(self._typeCheck,item)

		WidgetUtils.addClickEvent(item, function(  )
			self:clickLeftTitle(i)

			if i==2 then
				local userdata={}
			    userdata.cid=4
			    userdata.pid=28
			    userdata.json={
			        ["type"]="4.点击【亲友圈信息】"

			    }
			    CommonUtils.sends(userdata)
			-- elseif i==3 then
			-- 	--todo
			-- 	local userdata={}
			--     userdata.cid=4
			--     userdata.pid=36
			--     userdata.json={
			--         ["type"]="4.点击【成员信息】"

			--     }
			--     CommonUtils.sends(userdata)
			end

		end)
	end

	print("..............clickLeftTitle")
	self:clickLeftTitle(1)

	self:refreshmsg()

	self.redpoint =  self.listView:getChildByName("checkmodel_4"):getChildByName("redpoint"):setVisible(false)

	if self.ismy then
		self._typeCheck[4]:setVisible(true)
	else
		self._typeCheck[4]:setVisible(false)
	end

	self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(function( ... )
		self:refreshmsg()
	end))))
end 

function MainView:initTabView( index )
	local list = {	"app.ui.club_new.ClubRoom",
					"app.ui.club_new.ClubInfo",
					"app.ui.club_new.ClubResult",
					"app.ui.club_new.ClubMsg",
					"app.ui.club_new.ClubMembers"}

	local className = list[index]
	if index == 3 and self.ismy == false then
		className = list[5]
	end
	self._typeCheck[index].class = require(className).new(self)
	self._typeCheck[index].class:setPosition(5, 0)
	self._typeCheck[index].class:addTo(self.addNode)
	self._typeCheck[index].class:updataView(self.data)
end


function MainView:clickLeftTitle(index)
	if  self.listView.isscrolling == true then
		return
	end
	for k,v in pairs(self._typeCheck) do
		if v.ttype == index  then
			self.selectType = index
			if v.class then
				v.class:setVisible(true)
				if index == 1 then
				elseif index == 4 or index == 3 then
					-- print("............self.data = ",self.data.)
					v.class:updataView(self.data)
				end
			else
				if index==3 then
					userdata={}
			    	userdata.cid=4
			    	userdata.pid=36
			    	userdata.json={
			        	 ["type"]="4.点击【成员信息】"

			    	}
			   		CommonUtils.sends(userdata)	
				end
				self:initTabView(index)	

			end
			v:getChildByName("img1"):setVisible(true)
			v:getChildByName("img2"):setVisible(false)
		else
			if v.class then
				v.class:setVisible(false)
			end
			v:getChildByName("img1"):setVisible(false)
			v:getChildByName("img2"):setVisible(true)
		end
	end
end

function MainView:refreshmsg( )
	Socketapi.requestenterclube(self.data.tbid,true)
end
function MainView:updatacell(cell,i)
	local v = self.data.tables[i]
	cell:setVisible(true)
	local name =  cell:getChildByName("bg"):getChildByName("name")
	local conf =  cell:getChildByName("bg"):getChildByName("conf")
	local btn =  cell:getChildByName("bg"):getChildByName("btn")
	local jiebtn =  cell:getChildByName("bg"):getChildByName("btn_0")
	local bg = cell:getChildByName("bg")
	local num = cell:getChildByName("bg"):getChildByName("num")
	name:setString(v.tid)

	conf:setString(GT_INSTANCE:getTableDes(v.conf, 2))
	num:setString(v.player_num.."/"..v.conf.seat_num)
	local function callback( )
		LaypopManger_instance:PopBox("TableinfoclueView",self.data.tbid,v.tid,v.conf.seat_num,v.if_start)
	end
	WidgetUtils.addClickEvent(bg, function( )
		callback()
	end)
	WidgetUtils.addClickEvent(btn, function( )


		print("4.点击xxxx房间【加入】")
	    local userdata={}
	    userdata.cid=4
	    userdata.pid=26
	    userdata.json={
	        ["type"]="4.点击xxxx房间【加入】"

	    }
	    CommonUtils.sends(userdata)
		callback()
	end)
	if v.if_start then
		btn:setVisible(false)
	else
		btn:setVisible(true)
	end
	if self.ismy then
		jiebtn:setVisible(true)
		WidgetUtils.addClickEvent(jiebtn, function( )
			Socketapi.requestreleaseroomclub(v.tid)
		end)
	else
		jiebtn:setVisible(false)
	end
end

function MainView:updataview( data)

	print("...........MainView:updataview( )  ")

	if  self._typeCheck[1].class  then
		self._typeCheck[1].class:updataView(data)
	end
	if  self._typeCheck[2].class  then
		self._typeCheck[2].class:updataView(data)
	end
end

function MainView:updatechips(data )
	self:hideSmallLoading()
	if data.result == 0 then
		self.data.chips = data.chips
		if self._typeCheck[2].class then
			self._typeCheck[2].class:updatechips(data.chips)
		end
		if self._typeCheck[1].class then
			self._typeCheck[1].class:updatechips(data.chips)
		end
	else
		--LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
function MainView:cs_notify_tea_bar_has_new_message( data )
	if CURTBID == data.tbid then
		self.redpoint:setVisible(true)
		if self.selectType == 4 and self._typeCheck[4].class then
			self._typeCheck[4].class:updataView(self.data)
		end
	end
end

function MainView:cleanupmsg( tbid )
	if tbid == self.data.tbid then
		self.redpoint:setVisible(false)
	end
end
function MainView:updatamsg( data )
	if data.result ~= 0 then
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
		return
	end
	if data.result == 0 then
		self:refreshmsg( )
	end
end

function MainView:clubejiesan( data )
	print("MAINCLUB"..CURTBID)
	if CURTBID == data.tbid then
		LaypopManger_instance:backByName("MainViewclub")
	end
end
function MainView:cs_response_dissolve_tea_bar_table( data )
	if data.result ~= 0 then
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
		return
	end
	print(".......cs_response_dissolve_tea_bar_table ")
	printTable(data)

	if data.tid == glApp:getCurScene().table_id then
		glApp:getCurScene().table_id = nil
	end

	self:refreshmsg()
end

function MainView:initEvent()
	ComNoti_instance:addEventListener("cs_response_dissolve_tea_bar_table",self,self.cs_response_dissolve_tea_bar_table)
	ComNoti_instance:addEventListener("cs_notify_user_remove_out_tea_bar",self,self.clubejiesan)
	ComNoti_instance:addEventListener("cs_response_modify_tea_bar_desc",self,self.updatamsg)
	ComNoti_instance:addEventListener("cleanupmsg",self,self.cleanupmsg)
	ComNoti_instance:addEventListener("cs_response_put_chips_to_tea_bar",self,self.updatechips)
	ComNoti_instance:addEventListener("cs_response_enter_tea_bar",self,self.updataview)
	ComNoti_instance:addEventListener("cs_notify_tea_bar_has_new_message",self,self.cs_notify_tea_bar_has_new_message)
end



return MainView
