local JoinView = class("JoinView",PopboxBaseView)

function JoinView:ctor(listtui)
	self.listtui = listtui
	self:initView()
	self:initEvent()
	
end
function JoinView:initView()
	local widget = cc.CSLoader:createNode("ui/club/join/JoinView.csb")
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")

	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		
		LaypopManger_instance:back()
	end)
	self.input1 = self.mainLayer:getChildByName("input1")
	self.input1:setTextColor(cc.c3b(0, 0, 0))

	self.createBtn = self.mainLayer:getChildByName("surebtn")
	WidgetUtils.addClickEvent(self.createBtn, function( )
		if tonumber(self.input1:getString()) then
			Socketapi.requestgetclubeinfo(tonumber(self.input1:getString()))
		else
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "请输入正确的亲友圈id"})
		end
	end)

	self.cell = self.widget:getChildByName("cell")
	self.cell:setVisible(false)
	self.tips = self.mainLayer:getChildByName("hot")

	self.listview = self.mainLayer:getChildByName("listview")
	self.listview:setItemModel(self.cell)
	if self.listtui then

		for i,v in ipairs(self.listtui) do
			v.tbname = CommonUtils.checkchange(v.tbname)
			v.desc = CommonUtils.checkchange(v.desc)

			self.listview:pushBackDefaultItem()
	        local item = self.listview:getItem(i-1)
	        item:setVisible(true)
	        item:getChildByName("bg"):getChildByName("name"):setString(v.tbname)
	        item:getChildByName("bg"):getChildByName("desc"):setString(v.desc)
	        WidgetUtils.addClickEvent(item:getChildByName("bg"):getChildByName("btn"), function( )
				
				Socketapi.requestjoinclube(v.tbid)
				self.istuijian = true
				item:getChildByName("bg"):getChildByName("btn"):setVisible(false)
			end)
			local iconbg =  item:getChildByName("bg"):getChildByName("iconbg")
        	WidgetUtils.icon9( iconbg,v.url )

		end
	end
end

function JoinView:applycallback( data )
	if data.result == 0 then
		if self.istuijian then
		else
			LaypopManger_instance:back()
		end
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "申请加入成功，等待群主同意"})
	else
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end

function JoinView:infocallback( data )
	if data.result == 0 then

		data.brief_data.tbname = CommonUtils.checkchange(data.brief_data.tbname)
		data.brief_data.desc = CommonUtils.checkchange(data.brief_data.desc)

		self.tips:setVisible(false)
		self.listview:removeAllItems()
		self.listview:pushBackDefaultItem()
        local item = self.listview:getItem(0)
        item:setVisible(true)
        item:getChildByName("bg"):getChildByName("name"):setString(data.brief_data.tbname)
        item:getChildByName("bg"):getChildByName("desc"):setString(data.brief_data.desc)
        WidgetUtils.addClickEvent(item:getChildByName("bg"):getChildByName("btn"), function( )
			self.istuijian  = false
			Socketapi.requestjoinclube(data.brief_data.tbid)
		end)
		local iconbg =  item:getChildByName("bg"):getChildByName("iconbg")
        WidgetUtils.icon9( iconbg,data.brief_data.url )

	else
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
function JoinView:initEvent()
	ComNoti_instance:addEventListener("cs_response_apply_join_tea_bar",self,self.applycallback)
	ComNoti_instance:addEventListener("cs_response_tea_bar_info",self,self.infocallback)
end
return JoinView