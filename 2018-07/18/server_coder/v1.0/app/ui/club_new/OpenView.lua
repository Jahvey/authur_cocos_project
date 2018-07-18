----------------------------
--亲友圈列表
----------------------------
local OpenView = class("OpenView",PopboxBaseView)

function OpenView:ctor()
	self:initView()
	self:initEvent()
	
end
function OpenView:initView()
	local widget = cc.CSLoader:createNode("ui/club/club_open/Club_open.csb")
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")

	self.closeBtn = self.mainLayer:getChildByName("closebtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		if OPENCLUB ~= nil then
			-- self:release()
			OPENCLUB = nil
		end
		LaypopManger_instance:back()
	end)
	OPENCLUB = self
	-- self:retain()

	--初始化左边控制列表
	self.myClub = self.mainLayer:getChildByName("myClub")
	self.clubGuide = self.mainLayer:getChildByName("clubGuide"):setVisible(false)

	self.listView = self.mainLayer:getChildByName("listView")
	ComHelpFuc.setScrollViewEvent(self.listView)
	self.listView:setScrollBarEnabled(false)

	local itemlist = {}
	-- self.mySelect = 0
	local function touchEvent(item)
		-- if self.mySelect == item.ttype then
		-- 	return
		-- end
		-- self.mySelect = item.ttype
		for m,n in ipairs(itemlist) do
			n:getChildByName("img1"):setVisible(false)
			n:getChildByName("img2"):setVisible(true)
		end
		item:getChildByName("img1"):setVisible(true)
		item:getChildByName("img2"):setVisible(false)
		if item.ttype == 1 then
			self.myClub:setVisible(true)
			Socketapi.requestgetCluelist()
			self:showSmallLoading()
			self.clubGuide:setVisible(false)
		else
			self.clubGuide:setVisible(true)
			self.myClub:setVisible(false)
		end
	end

	for i=1,2 do
		self.listView:pushBackDefaultItem()
		local item = self.listView:getItem(i-1)
		item.ttype = i
		table.insert(itemlist,item)
		WidgetUtils.addClickEvent(item,function ()
			touchEvent(item)
		end)
	end
	touchEvent(itemlist[1])


	--初始化我的亲友圈
	self.createBtn = self.myClub:getChildByName("createbtn")
	WidgetUtils.addClickEvent(self.createBtn, function( )
		if LocalData_instance:get("roletype") == poker_common_pb.EN_Role_Type_Saler then
			LaypopManger_instance:PopBox("CreateclubView")
		else
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "您不是代理,无法创建亲友圈"})
		end
	end)

	self.joinBtn = self.myClub:getChildByName("joinbtn")
	WidgetUtils.addClickEvent(self.joinBtn, function( )
		print('1222')
		LaypopManger_instance:PopBox("JoinclubView",self.recommend_brief_data)
	end)
	
	self.mylistno = self.myClub:getChildByName("my"):getChildByName("no")
	self.joinlistno = self.myClub:getChildByName("join"):getChildByName("no")
	self.mylistno:setVisible(false)
	self.joinlistno:setVisible(false)

	self.cell = self.myClub:getChildByName("cell")
	self.cell:setVisible(false)

	self.listview1 = self.myClub:getChildByName("my"):getChildByName("listview")
	self.listview1:setItemModel(self.cell)
	ComHelpFuc.setScrollViewEvent(self.listview1)
	self.listview1:setScrollBarEnabled(false)


	self.listview2 = self.myClub:getChildByName("join"):getChildByName("listview")
	self.listview2:setItemModel(self.cell)
	ComHelpFuc.setScrollViewEvent(self.listview2)
	self.listview2:setScrollBarEnabled(false)

	self.list1 = {}
	self.list2 = {}
	-- Socketapi.requestgetCluelist()
	-- self:showSmallLoading()

	--初始化亲友圈引导
	local pageview = self.clubGuide:getChildByName("pageView")

	local pointtable = {}
	local pointnode = self.clubGuide:getChildByName("pointnode")
	pointnode:removeAllChildren()

	local num = 3
	for i=1,num do
		local point = ccui.ImageView:create("common/blackpoint.png")
	        	:addTo(pointnode)
	        	:setPositionX((-(num-1)/2+i-1)*30)

	    table.insert(pointtable,point)
	end

	local function setPointLight(index)
		for i,v in ipairs(pointtable) do
			if i == index then
				v:loadTexture("common/whitepoint.png")
			else
				v:loadTexture("common/blackpoint.png")
			end
		end
	end

	local function onClickPageViewCallBack()
        local index = pageview:getCurrentPageIndex() + 1
        if index ~= 0 then
        	setPointLight(index)
        end
    end
    pageview:addEventListener(onClickPageViewCallBack)
	self:scheduleUpdateWithPriorityLua(onClickPageViewCallBack,0)
	setPointLight(1)

	local finger = self.clubGuide:getChildByName("finger")
	finger:setPositionX(600)
	local moveTo = cc.MoveTo:create(0.8,cc.p(500,-318.00))
	finger:runAction(cc.RepeatForever:create(cc.Sequence:create(moveTo,cc.DelayTime:create(0.2),cc.CallFunc:create(function ()
		finger:setPositionX(600)
	end))))

	
	print(self.listview1:getItems())
	
end 

function OpenView:updataview( )
	-- body
	if #self.list1 == 0 then
		self.mylistno:setVisible(true)
	else
		self.mylistno:setVisible(false)
	end

	self.listview1:removeAllItems()
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

        WidgetUtils.addClickEvent(item:getChildByName("bg"):getChildByName("join"), function( )
			self:openclub(v.tbid,v.desc)
			--item:getChildByName("bg"):getChildByName("redpoint"):setVisible(false)
		end)

		item:getChildByName("bg"):getChildByName("redpoint"):setVisible(false)
	end

	if #self.list2 == 0 then
		self.joinlistno:setVisible(true)
	else
		self.joinlistno:setVisible(false)
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

		WidgetUtils.addClickEvent(item:getChildByName("bg"):getChildByName("join"), function( )
			self:openclub(v.tbid,v.desc)
		end)
	end
end


function OpenView:openclub(tid)
	Socketapi.requestenterclube(tid,false)
	self:showSmallLoading()
end

function OpenView:getlistcall( data )
	print(".......OpenView:getlistcall( data ) ")
	printTable(data)

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
