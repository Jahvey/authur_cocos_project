----------------------------
--亲友圈列表
----------------------------
local OpenView = class("OpenView",PopboxBaseView)

function OpenView:ctor()
	self:initView()
	self:initEvent()
	
end
function OpenView:initView()
	local widget = cc.CSLoader:createNode("ui/club/join/ClubjoinView.csb")
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")

	self.closeBtn = self.mainLayer:getChildByName("closebtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		if OPENCLUB ~= nil then
			self:release()
			OPENCLUB = nil
		end
		LaypopManger_instance:back()
	end)
	OPENCLUB = self
	self:retain()

	self.createBtn = self.mainLayer:getChildByName("createbtn")
	WidgetUtils.addClickEvent(self.createBtn, function( )

		if LocalData_instance:get("roletype") == poker_common_pb.EN_Role_Type_Saler then
			LaypopManger_instance:PopBox("CreateclubView")
		else
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "您不是代理,无法创建亲友圈"})
		end
	end)

	self.joinBtn = self.mainLayer:getChildByName("joinbtn")
	WidgetUtils.addClickEvent(self.joinBtn, function( )
		print('1222')
		LaypopManger_instance:PopBox("JoinclubView",self.recommend_brief_data)
	end)

	--介绍
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("my"):getChildByName("infobtn"), function( )
		
		LaypopManger_instance:PopBox("JieshaoclueView")
	end)

	Socketapi.requestgetCluelist()
	self.mylistno = self.mainLayer:getChildByName("my"):getChildByName("no")
	self.joinlistno = self.mainLayer:getChildByName("join"):getChildByName("no")
	self.mylistno:setVisible(false)
	self.joinlistno:setVisible(false)
	self.cell = self.widget:getChildByName("cell")
	self.cell:setVisible(false)
	self.listview1 = self.mainLayer:getChildByName("my"):getChildByName("listview")
	self.listview1:setItemModel(self.cell)
	self.listview2 = self.mainLayer:getChildByName("join"):getChildByName("listview")
	self.listview2:setItemModel(self.cell)
	self.list1 = {}
	self.list2 = {}

	self:hideSmallLoading()
	print(self.listview1:getItems())
	
end 

function OpenView:updataview( )
	-- body
	if #self.list1 == 0 then
		self.listview1:removeAllItems()
		self.mylistno:setVisible(true)
	else
		self.mylistno:setVisible(false)
	end
	if #self.list2 == 0 then
		self.joinlistno:setVisible(true)
	else
		self.joinlistno:setVisible(false)
	end
	self.listview1:removeAllItems()
	self.listview2:removeAllItems()
	for i,v in ipairs(self.list1) do

		v.tbname = CommonUtils.checkchange(v.tbname)
		v.desc = CommonUtils.checkchange(v.desc)

		self.listview1:pushBackDefaultItem()
        local item = self.listview1:getItem(i-1)
        item.localdata = v
        item:setVisible(true)
        item:getChildByName("bg"):getChildByName("name"):setString(v.tbname)
        local iconbg =  item:getChildByName("bg"):getChildByName("iconbg")
        WidgetUtils.icon9( iconbg,v.url )
        WidgetUtils.addClickEvent(item:getChildByName("bg"), function( )
			self:openclub(v.tbid,v.desc)
			--item:getChildByName("bg"):getChildByName("redpoint"):setVisible(false)
		end)
		item:getChildByName("bg"):getChildByName("redpoint"):setVisible(false)
	end
	self.listview2:removeAllItems()
	for i,v in ipairs(self.list2) do

		v.tbname = CommonUtils.checkchange(v.tbname)
		v.desc = CommonUtils.checkchange(v.desc)

		self.listview2:pushBackDefaultItem()
        local item = self.listview2:getItem(i-1)
        item.localdata = v
        item:setVisible(true)
        item:getChildByName("bg"):getChildByName("name"):setString(v.tbname)
        local iconbg =  item:getChildByName("bg"):getChildByName("iconbg")
        WidgetUtils.icon9( iconbg,v.url )

        WidgetUtils.addClickEvent(item:getChildByName("bg"), function( )
			self:openclub(v.tbid,v.desc)
		end)
	end
end


function OpenView:openclub(tid)
	Socketapi.requestenterclube(tid,false)
	self:showSmallLoading()
end

function OpenView:getlistcall( data )
	self:hideSmallLoading()
	if data.result == 0 then
		self.list1 = {}
		self.list2 = {}
		if data.brief_data then
			for i,v in ipairs(data.brief_data) do
				if v.master_uid  == LocalData_instance.uid then
					table.insert(self.list1,v)
				else
					table.insert(self.list2,v)
				end
			end
		end
		self.recommend_brief_data = data.recommend_brief_data
		self:updataview()
	else
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end

function OpenView:createcallback( data )
	--print("OpenView:createcallbackOpenView:createcallback")
	Socketapi.requestgetCluelist()
	self:showSmallLoading()
end

function OpenView:enterclub(data)
	print("openview")
	self:hideSmallLoading()
	if data.result == 0 then
		if data.is_refresh then
		else
			LaypopManger_instance:backByName("MainViewclub")
			LaypopManger_instance:PopBox("MainViewclub",data)
		end
	else
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end

end

function OpenView:cs_notify_tea_bar_has_new_message( data )

		for i,v in ipairs(self.listview1:getItems()) do
			if v.localdata.tbid == data.tbid then
				v:getChildByName("bg"):getChildByName("redpoint"):setVisible(true)
				break
			end
		end
end
function OpenView:cleanupmsg( tbid )
	for i,v in ipairs(self.listview1:getItems()) do
		if v.localdata.tbid == tbid then
			v:getChildByName("bg"):getChildByName("redpoint"):setVisible(false)
			break
		end
	end
end

function OpenView:msgreslutapply(data)
	data.tbname = CommonUtils.checkchange(data.tbname)
	print("OpenView:msgreslutapplyOpenView:msgreslutapply")
	local str1 = "加入亲友圈【"..data.tbname.."】id".."【"..data.tbid.."】失败,群主("..data.master_name..")".."拒绝了您的申请"
	local str2 = "加入亲友圈【"..data.tbname.."】id".."【"..data.tbid.."】成功,群主("..data.master_name..")".."同意了您的申请"
	if data.if_agree then
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = str2})
		Socketapi.requestgetCluelist()
	else
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = str1})

	end

end
function OpenView:clubejiesan(data)
	Socketapi.requestgetCluelist()
	self:showSmallLoading()
	data.tbname = CommonUtils.checkchange(data.tbname)

	local str = "您已经被移除亲友圈【"..data.tbname.."】id".."【"..data.tbid.."】"
	LaypopManger_instance:backByName("PromptBoxView")
	LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = str})
end

function OpenView:initEvent()
	ComNoti_instance:addEventListener("cs_response_enter_tea_bar",self,self.enterclub)
	ComNoti_instance:addEventListener("cs_response_tea_bar_list",self,self.getlistcall)
	ComNoti_instance:addEventListener("cs_response_create_tea_bar",self,self.createcallback)
	ComNoti_instance:addEventListener("cs_notify_tea_bar_has_new_message",self,self.cs_notify_tea_bar_has_new_message)
	ComNoti_instance:addEventListener("cleanupmsg",self,self.cleanupmsg)
	ComNoti_instance:addEventListener("cs_notify_join_tea_bar_result",self,self.msgreslutapply)
	ComNoti_instance:addEventListener("cs_notify_user_remove_out_tea_bar",self,self.clubejiesan)
end
return OpenView
