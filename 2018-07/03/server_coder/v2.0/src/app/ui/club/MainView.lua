----------------------------
--茶馆列表
----------------------------
local MainView = class("MainView",PopboxBaseView)

function MainView:ctor(data)
	self.data = data
	if self.data.master_uid ==  LocalData_instance.uid then
		self.ismy = true
	end

	self.isredpoint  = isredpoint
	CURTBID = self.data.tbid
	self:initView()
	self:initEvent()

	printTable(data,"sjp6")
	
end
function MainView:initView()
	local widget = cc.CSLoader:createNode("ui/club/main/ClubmainView.csb")
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")
	MAINCLUB = self
	self:retain()
	self.nolisttip = self.mainLayer:getChildByName("node"):getChildByName("no")
	self.nolisttip:setVisible(false)
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closebtn"), function( )
		LaypopManger_instance:back()
		CURTBID = 0
		self:release()
		MAINCLUB = nil
	end)
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("returnbtn"), function( )
		LaypopManger_instance:back()
		CURTBID = 0 
		self:release()
		MAINCLUB = nil
	end)

	self.title = self.mainLayer:getChildByName("bg"):getChildByName("title"):getChildByName("text")
	self.title:setString(self.data.tbname)

	self.redpoint =  self.mainLayer:getChildByName("my"):getChildByName("msgbtn"):getChildByName("redpoint")
	if isredpoint then
		self.redpoint:setVisible(true)
	else
		self.redpoint:setVisible(false)
	end

	self.jieshaotitle1 = self.mainLayer:getChildByName("my"):getChildByName("text1")
	self.jieshaotitle2 = self.mainLayer:getChildByName("my"):getChildByName("text2")
	self.jieshaotitle3 = self.mainLayer:getChildByName("my"):getChildByName("text3")
	self.jieshaotitle4 = self.mainLayer:getChildByName("my"):getChildByName("text4")
	self.jieshaotitle5 = self.mainLayer:getChildByName("my"):getChildByName("text5")
	self.jieshaotitle6 = self.mainLayer:getChildByName("my"):getChildByName("text6")

	self.descstr = self.mainLayer:getChildByName("my"):getChildByName("info")
	self:updataconf()

	self.msgbtn = self.mainLayer:getChildByName("my"):getChildByName("msgbtn")
	WidgetUtils.addClickEvent(self.msgbtn, function( )
		
		LaypopManger_instance:PopBox("MsgViewclub",self.data.tbid)
	end)
	self.rolebtn =  self.mainLayer:getChildByName("my"):getChildByName("rolebtn")
	WidgetUtils.addClickEvent(self.rolebtn, function( )
		if self.ismy then
			LaypopManger_instance:PopBox("InfoViewclue",self.data)
		else
			LaypopManger_instance:PopBox("OtherInfoViewclue",self.data)
		end
	end)

	self.addbtn =  self.mainLayer:getChildByName("my"):getChildByName("addbtn")
	WidgetUtils.addClickEvent(self.addbtn, function( )
		
		LaypopManger_instance:PopBox("AddfangclueView",self.data.tbid,self.data.chips)
	end)
	
	self.infobtn =  self.mainLayer:getChildByName("my"):getChildByName("infobtn")
	WidgetUtils.addClickEvent(self.infobtn, function( )
		LaypopManger_instance:PopBox("RetinfoView",self.data.tbid,self.data.desc,self.data.tbname,self.data.pay_type)
	end)
	self.createbtn =  self.mainLayer:getChildByName("create")
	WidgetUtils.addClickEvent(self.createbtn, function( )
		
		LaypopManger_instance:PopBox("CreateRoomView",1,self.data)
	end)
	self.timedely = 5
	self.canrefresh = true
	self.refreshbtn =  self.mainLayer:getChildByName("node"):getChildByName("refreshbtn")

	local function eventhandler(tag)
        if "enter" == tag then
            self.canrefresh = true
            self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(function( ... )
            	self:refreshmsg()
            end))))
        end
    end
    self.refreshbtn:setVisible(false)
    self.refreshbtn:registerScriptHandler(eventhandler)

	WidgetUtils.addClickEvent(self.refreshbtn, function( )
		if self.canrefresh == false then
			CommonUtils:prompt(self.timedely.."秒后可刷新")
			return 
		end
		self.refreshbtn:setColor(cc.c3b(0, 0,0))
		self:refreshmsg()
		self.timedely = 5
		self.canrefresh = false
		self.refreshbtn:runAction(cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( ... )
			self.timedely = self.timedely - 1
			if self.timedely == 0 then
				self.canrefresh = true
				self.refreshbtn:setColor(cc.c3b(255, 255,255))
			end
		end)), 5))
	end)

	self.cell = self.mainLayer:getChildByName("node"):getChildByName("cell")
	self.cell:setVisible(false)
	self.listview = self.mainLayer:getChildByName("node"):getChildByName("listview")

	-- local  layout = ccui.Layout:create()
	-- layout:setContentSize(self.cell:getContentSize())
	-- self.listview:setItemModel(layout)


	self.listviewdelegale = require "app.help.MylistView".new(self.listview,self.cell:getContentSize())
 	self.listviewdelegale:setTotall(0,true)
 	self.listviewdelegale:setModelcell(self.cell)
 	self.listviewdelegale:setcellAtindex(function(cell,idx)
 		print("updataidex:"..idx)
 		self:updatacell(cell,idx)
 	end)
 	

	if self.data.master_uid == LocalData_instance.uid then
	else
		self.addbtn:setVisible(false)
		self.jieshaotitle5:setVisible(false)
		self.mainLayer:getChildByName("my"):getChildByName("title1_2"):setVisible(false)
		self.msgbtn:setVisible(false)
		self.infobtn:setVisible(false)
	end
	local sharebtn = self.mainLayer:getChildByName("my"):getChildByName("sharebtn")
	WidgetUtils.addClickEvent(sharebtn, function( )
		
		CommonUtils.shareclub(self.data.tbid,self.data.tbname,self.data.desc)
	end)
	self:hideSmallLoading()
end 
function MainView:refreshmsg( )
	--self:showSmallLoading()
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
	--name:setString(ComHelpFuc.getStrWithLength(v.owner_name))
	name:setString(v.tid)

	conf:setString(GT_INSTANCE:getTableDes(v.conf, 2))
	--conf:setScale(0.65)
	num:setString(v.player_num.."/"..v.conf.seat_num)
	local function callback( )
		print("info")
		LaypopManger_instance:PopBox("TableinfoclueView",self.data.tbid,v.tid,v.conf.seat_num,v.if_start)
	end
	WidgetUtils.addClickEvent(bg, function( )
		callback()
	end)
	WidgetUtils.addClickEvent(btn, function( )
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
function MainView:updataconf()
	self.jieshaotitle1:setString(self.data.tbid)
	self.jieshaotitle2:setString(self.data.tbname)
	self.jieshaotitle3:setString(self.data.master_name)
	self.jieshaotitle4:setString(self.data.user_num.."/"..self.data.max_user_num)
	self.jieshaotitle5:setString(self.data.chips)

	if self.data.pay_type == poker_common_pb.EN_TeaBar_Pay_Type_Master  then 
		self.jieshaotitle6:setString("茶馆主人支付")
	elseif self.data.pay_type == poker_common_pb.EN_TeaBar_Pay_Type_AA then 
		self.jieshaotitle6:setString("茶馆均摊支付") 
	end
	self.descstr:setString(self.data.desc)
end
function MainView:onEndAni()
	self:updataview( self.data)
end

function MainView:updataview( data)
	print("--------------------get")

	printTable(data,"sjp6")

	--self:hideSmallLoading()
	-- self.listview:removeAllItems()
	-- self.listview:stopAllActions()
	if data.result ~= 0 then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
		return
	end
	self.data = data
	if self.data.tables == nil then
		self.data.tables = {}
	end
	if #self.data.tables == 0 then
		self.nolisttip:setVisible(true)
	else
		self.nolisttip:setVisible(false)
	end
	if data.tables then
		self.listviewdelegale:setTotall(#self.data.tables,true)
		self.listviewdelegale:updataView(true)
		-- for i,v in ipairs(data.tables) do
		-- 	self.listview:pushBackDefaultItem()
	 --        local item = self.listview:getItem(i-1)
	 --        local cell  = self.cell:clone()
	 --        cell:setPosition(cc.p(0,0))
	 --        cell:setVisible(true)
	 --        item:addChild(cell)
	 --       	local name =  cell:getChildByName("bg"):getChildByName("name")
	 --   		local conf =  cell:getChildByName("bg"):getChildByName("conf")
	 --   		local btn =  cell:getChildByName("bg"):getChildByName("btn")
	 --   		local bg = cell:getChildByName("bg")
	 --   		local num = cell:getChildByName("bg"):getChildByName("num")
	 --   		name:setString("")
	 --   		conf:setString(LocalConfig.getCreateConfstt(v.conf))
	 --   		num:setString(v.player_num.."/"..v.conf.seat_num)
	 --   		local function callback( )
	 --   			print("info")
	 --   			LaypopManger_instance:PopBox("TableinfoclueView",v.tid,v.conf.seat_num,v.if_start)
	 --   		end
	 --   		WidgetUtils.addClickEvent(bg, function( )
		-- 		callback()
		-- 	end)
		-- 	WidgetUtils.addClickEvent(btn, function( )
		-- 		callback()
		-- 	end)
		-- 	if v.if_start then
		-- 		btn:setVisible(false)
		-- 	end

		-- end
	end
	self:updataconf()
end

function MainView:updatechips(data )
	self:hideSmallLoading()
	if data.result == 0 then
		self.data.chips = data.chips
		self.jieshaotitle5:setString(self.data.chips)
	else
		--LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
function MainView:cs_notify_tea_bar_has_new_message( data )
	if CURTBID == data.tbid then
		self.redpoint:setVisible(true)
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
