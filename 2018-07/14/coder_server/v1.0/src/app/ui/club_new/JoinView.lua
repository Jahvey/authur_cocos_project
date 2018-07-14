local JoinView = class("JoinView",PopboxBaseView)

function JoinView:ctor(listtui)
	self:initData(listtui)
	self:initView()
	self:initEvent()
end

function JoinView:initData(opentype)
	-- 按钮列表
	self.keyBtnList = {}
	self.roomNumList = {}
	self.listtui = listtui
end

function JoinView:initView()
	self.widget = cc.CSLoader:createNode("ui/club/club_join/joinClubView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)
	-- 数字
	self.keypadNode = self.mainLayer:getChildByName("keypadNode")

	self.confirmbtn = self.mainLayer:getChildByName("confirmbtn")
	self.inputtext = self.mainLayer:getChildByName("inputbg"):getChildByName("inputtext"):setString("")

	WidgetUtils.addClickEvent(self.confirmbtn, function( )
		
		local code = table.concat(self.roomNumList,"")
		if code and tonumber(code) then
			Socketapi.requestgetclubeinfo(tonumber(code))
		else
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "请输入正确的茶馆id"})
		end
	end)
	self:initKeyPadNode()

	--初始化，
	self.showCell = self.mainLayer:getChildByName("found"):setVisible(false)


end
-- 初始化按钮的事件
function JoinView:initKeyPadNode()
	for i=0,11 do
		local str = i
		if i == 10 then
			str = "again"
		elseif i == 11 then
			str = "delete"	
		end
		local btn = self.keypadNode:getChildByName(str)
		btn.str = str

		WidgetUtils.addClickEvent(btn, function( )
			self:setRoomNumValue(btn.str)
		end)
	end
end
-- 设置数值
function JoinView:setRoomNumValue(value)
	if not value then
		print("按钮的 value 为空 ！！！")
		return
	end 
	-- 重输
	if value == "again" then
		self.roomNumList = {}
		self.inputtext:setString(" ")
	-- 删除
	elseif value == "delete" then
		local str = ""
		local cnt = #self.roomNumList
		if cnt >= 0 then
			table.remove(self.roomNumList,cnt)
		end
		str = table.concat(self.roomNumList," ")
		self.inputtext:setString(str)
	else
		table.insert(self.roomNumList,value)
		local str = table.concat(self.roomNumList," ")
		self.inputtext:setString(str)
	end	
end

function JoinView:applycallback( data )
	print("JoinView:applycallback( data )")
	printTable(data)

	if data.result == 0 then
		self.showCell:getChildByName("btn_join"):setVisible(false)
		LaypopManger_instance:back()
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "申请加入成功，等待群主同意"})
	else
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end

function JoinView:infocallback( data )
	if data.result == 0 then

        self.showCell:setVisible(true)
        self.showCell:getChildByName("name"):setString(data.brief_data.tbname)
        self.showCell:getChildByName("info"):setString(data.brief_data.desc)
        self.showCell:getChildByName("btn_join"):setVisible(true)

        WidgetUtils.addClickEvent(self.showCell:getChildByName("btn_join"), function( )
			self.istuijian  = false
			Socketapi.requestjoinclube(data.brief_data.tbid)
		end)
		local iconbg =  self.showCell:getChildByName("iconbg")
        WidgetUtils.icon9( iconbg,data.brief_data.url )   

        self.showCell:setPositionY(180)
        self.showCell:setOpacity(0)
        local fadeIn = cc.FadeIn:create(0.1)
		local moveTo = cc.MoveTo:create(0.1,cc.p(-337.00,195.00))
		self.showCell:runAction(cc.Spawn:create(fadeIn,moveTo))

	else
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
function JoinView:initEvent()
	ComNoti_instance:addEventListener("cs_response_apply_join_tea_bar",self,self.applycallback)
	ComNoti_instance:addEventListener("cs_response_tea_bar_info",self,self.infocallback)
end
return JoinView