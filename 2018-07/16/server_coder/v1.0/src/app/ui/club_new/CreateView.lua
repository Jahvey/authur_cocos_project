local CreateView = class("CreateView",PopboxBaseView)

function CreateView:ctor()

	self:initView()
	self:initEvent()
	
end

function CreateView:getStrWithcount(str)
    local pos = 0
    --str = "善良的简单快乐的"
    if str == nil or str == "" then
        return 0
    end
    local count = 0
     while(pos <string.len(str) )
       do
           --print(str)
            local char1 = string.sub(str,pos+1,pos+2)
            local len = ComHelpFuc.getUtf8Length(char1)
            
            -- if count > 4 then
            -- 	return  string.sub(str,1,pos)..".."
            -- else
            -- 	pos =pos  + len
            -- end
            pos =pos  + len
            count = count + 1
        end
   return count
end
function CreateView:initView()
	local widget = cc.CSLoader:createNode("ui/club/create/CreateView.csb")
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")

	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		
		LaypopManger_instance:back()
	end)
	self.input1 = self.mainLayer:getChildByName("input1")
	
	self.input1:setTextColor(cc.c3b(0, 0, 0))
	self.input2 = self.mainLayer:getChildByName("input2")
	self.input2:setTextColor(cc.c3b(0, 0, 0))
	self.create = self.mainLayer:getChildByName("create")




	self.input2:addEventListener(function(sender, eventType)
        local event = {}
        if eventType == 0 then
            event.name = "ATTACH_WITH_IME"
            self.mainLayer:stopAllActions()
            self.mainLayer:runAction(cc.MoveTo:create(0.3,cc.p(0,200)))
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


    self.index = 1

	WidgetUtils.addClickEvent(self.create, function( )
		local str1 = self.input1:getString()
		local str2 = self.input2:getString()

		local count1 = self:getStrWithcount(str1)
		local count2 = self:getStrWithcount(str2)

		local payType = 0


		if self.index == 1 then 
			payType = poker_common_pb.EN_TeaBar_Pay_Type_Master
		elseif self.index == 2  then 
			payType = poker_common_pb.EN_TeaBar_Pay_Type_AA
		end


		if self.input1:getString()~= "" and self.input2:getString() ~= "" then
			
			if count1 > 6 then
				LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "名字不能超过6个字符"})
			elseif count1 > 60 then
				LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "介绍不能超过60个字符"})
			else
				Socketapi.requestcreateclube(self.input1:getString(),self.input2:getString(),payType)
			end
		else
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "请输入完整的信息"})
		end
	end)


	local payCheckBox = {}
	local checkBox1 = self.mainLayer:getChildByName("CheckBox_1")
	table.insert(payCheckBox,checkBox1)
	local checkBox2 = self.mainLayer:getChildByName("CheckBox_2")
	table.insert(payCheckBox,checkBox2)

	WidgetUtils.createSingleBox(payCheckBox, 1, function (sender, isSelected)
	  	local index = sender:getTag()
    	local checkBox = payCheckBox[index]
		if isSelected then
			checkBox:getChildByName("Label"):setTextColor(cc.c3b(0x8f,0x47,0x1a))
			self.index = checkBox:getTag()
		else
			checkBox:getChildByName("Label"):setTextColor(cc.c3b(0x6a,0x51,0x42))
		end
	end)

end

function CreateView:createcallback( data )
	if data.result == 0 then
		LaypopManger_instance:back()
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "创建成功"})



		
	else
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
function CreateView:initEvent()
	ComNoti_instance:addEventListener("cs_response_create_tea_bar",self,self.createcallback)
end
return CreateView