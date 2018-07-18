local RetinfoView = class("RetinfoView",PopboxBaseView)

function RetinfoView:ctor(tbid,info,name,pay_type)
	self.tbname = name
	self.tbid = tbid
	self.info = info
	self.pay_type = pay_type
	self:initView()
	self:initEvent()
	
end
function RetinfoView:initView()
	local widget = cc.CSLoader:createNode("ui/club/smallbox/XiugaiView.csb")
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")

	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		
		LaypopManger_instance:back()
	end)
	self.input = self.mainLayer:getChildByName("input2")
	self.input:setPlaceHolder(self.info)
	self.input:setString(self.info)
	self.input:setTextColor(cc.c3b(0, 0, 0))



	local payCheckBox = {}
	local checkBox1 = self.mainLayer:getChildByName("CheckBox_1")
	table.insert(payCheckBox,checkBox1)
	local checkBox2 = self.mainLayer:getChildByName("CheckBox_2")
	table.insert(payCheckBox,checkBox2)

	local defaultCheck = 1
	if self.pay_type == poker_common_pb.EN_TeaBar_Pay_Type_Master then 
		defaultCheck = 1
	elseif self.pay_type == poker_common_pb.EN_TeaBar_Pay_Type_AA then 
		defaultCheck = 2
	end


	WidgetUtils.createSingleBox(payCheckBox, defaultCheck, function (sender, isSelected)
	  	local index = sender:getTag()
    	local checkBox = payCheckBox[index]
		if isSelected then
			defaultCheck = checkBox:getTag()
			checkBox:getChildByName("Label"):setTextColor(cc.c3b(0x8f,0x47,0x1a))
		else
			checkBox:getChildByName("Label"):setTextColor(cc.c3b(0x6a,0x51,0x42))
		end
	end)

	










	self.input:addEventListener(function(sender, eventType)
        local event = {}
        if eventType == 0 then
            event.name = "ATTACH_WITH_IME"
            self.mainLayer:stopAllActions()
            self.mainLayer:runAction(cc.MoveTo:create(0.3,cc.p(0,300)))
        elseif eventType == 1 then
            event.name = "DETACH_WITH_IME"
             self.mainLayer:stopAllActions()
            self.mainLayer:runAction(cc.MoveTo:create(0.3,cc.p(0,0)))
        elseif eventType == 2 then
            event.name = "INSERT_TEXT"
        elseif eventType == 3 then
            event.name = "DELETE_BACKWARD"
        end
        -- event.target = sender
        -- callback(event)
        print( event.name)
    end)


	self.name = self.mainLayer:getChildByName("name")
	self.tbname = CommonUtils.checkchange(self.tbname)
	self.name:setString(self.tbname)
	self.surebtn = self.mainLayer:getChildByName("surebtn")
	WidgetUtils.addClickEvent(self.surebtn, function( )
		
		--LaypopManger_instance:back()
		if (self.input:getString() == self.input:getPlaceHolder()) and (self.pay_type == defaultCheck - 1) then
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "没有任何修改信息"})
		else
			Socketapi.requestresetinfoclue(self.tbid,self.input:getString(),defaultCheck - 1)
		end
		
	end)
	self.releasebtn = self.mainLayer:getChildByName("btn")
	WidgetUtils.addClickEvent(self.releasebtn, function( )
		
		
		LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "是否要解散亲友圈,解散亲友圈后数据将无法恢复?",sureCallFunc = function()
			Socketapi.requestreleasseclue(self.tbid)
		end,cancelCallFunc = function()
			
		end})
	end)

	
	--Socketapi.requestmsgclube(self.tid)
end

function RetinfoView:msgcallback(data)
	if data.result == 0 then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "修改成功",sureCallFunc =function( )
			LaypopManger_instance:back()
		end})
		
	else
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
function  RetinfoView:cs_response_free_tea_bar( data )
	if data.result == 0 then
		LaypopManger_instance:back()
		--LaypopManger_instance:back()
	else
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
function RetinfoView:initEvent()
	ComNoti_instance:addEventListener("cs_response_modify_tea_bar_desc",self,self.msgcallback)

	ComNoti_instance:addEventListener("cs_response_free_tea_bar",self,self.cs_response_free_tea_bar)
end
return RetinfoView