
local ReportView = class("ReportView",PopboxBaseView)
function ReportView:ctor()
	ComHttp.URL.REPORTUSERDUBO = "/Maininterface/report",
	self:initView()
end



function ReportView:initView()

	self.widget = cc.CSLoader:createNode("ui/report/ReportView.csb")
	self:addChild(self.widget)

	self.closeBtn  = self.widget:getChildByName("main"):getChildByName("closeBtn")

	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)


	self.mainView = self.widget:getChildByName("main")
	self.userField = self.mainView:getChildByName("TextField_1")
	self.numberField = self.mainView:getChildByName("TextField_2")




	local checkBoxList = {}
	self.xuanze = - 1
	local function selectedEvent(sender,eventType)
		-- body
		-- if sender:getTag() == 1 then 
		-- 	if sender:setSelected(true) then 
		-- 		self.xuanze = 1
		-- 	else
		-- 		self.xuanze = -1
		-- 	end
	 --   	elseif sender:getTag() == 2 then 
	 --   		if sender:setSelected(true) then 
	 --   			self.xuanze = 2
	 --   		else
	 --   			self.xuanze = -1
		-- 	end
	 --   	elseif sender:getTag() == 3 then 
	 --   		if sender:setSelected(true) then 
	 --   			self.xuanze = 3
	 --   		else
	 --   			self.xuanze = -1
		-- 	end
		-- end


		-- print("5555555555555555",sender:getTag(),sender:setSelected(true))
		if eventType == ccui.CheckBoxEventType.selected then
			for i,v in ipairs(checkBoxList) do
				v:setSelected(false)
			end
			sender:setSelected(true)
			self.xuanze = sender:getTag()
		end

	end


	for i=1,3 do
		local checkbox = self.mainView:getChildByName("CheckBox_"..i)
		table.insert(checkBoxList,checkbox)
		checkbox:setTag(i)
		checkbox:addEventListener(selectedEvent)
	end





	local touchlayer = ccui.Layout:create()
    touchlayer:setContentSize(cc.size(display.width*4, display.height*4))
    touchlayer:setPosition(cc.p(-display.width, -display.height))
    self:addChild(touchlayer, 10)
    touchlayer:setTouchEnabled(true)
    touchlayer:setVisible(false)

    WidgetUtils:addPressListener(touchlayer, function (event)
        self.userField:setDetachWithIME(true)
        self.numberField:setDetachWithIME(true)
        -- self.userField:getString()
     
    end)
	local old_x,old_y = self.widget:getPosition()
	self.userField:addEventListener(function (target, event)

        if event == ccui.TextFiledEventType.attach_with_ime then-- 进入输入
            if device.platform == "ios" then
                 self.widget:stopAllActions()
                 self.widget:runAction(cc.Sequence:create(cc.MoveTo:create(0.225,cc.p(old_x, old_y+200)),cc.CallFunc:create(function()
                    touchlayer:setVisible(true)
                 end)))
                 cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(true)
            end
        elseif event == ccui.TextFiledEventType.detach_with_ime then-- 离开输入
            if device.platform == "ios" then
                self.widget:stopAllActions()
                self.widget:runAction(cc.Sequence:create(cc.MoveTo:create(0.175, cc.p(old_x, old_y)),cc.CallFunc:create(function()
                        touchlayer:setVisible(false)
                 end)))
                cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
            end

        elseif event == ccui.TextFiledEventType.insert_text then --输入字符
        elseif event == ccui.TextFiledEventType.delete_backward then--删除字符
        end
    end)

	self.numberField:addEventListener(function (target, event)


        if event == ccui.TextFiledEventType.attach_with_ime then-- 进入输入
            if device.platform == "ios" then
                 self.widget:stopAllActions()
                 self.widget:runAction(cc.Sequence:create(cc.MoveTo:create(0.225,cc.p(old_x, old_y+200)),cc.CallFunc:create(function()
                    touchlayer:setVisible(true)
                 end)))
                 cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(true)
            end

        elseif event == ccui.TextFiledEventType.detach_with_ime then-- 离开输入
            if device.platform == "ios" then
                self.widget:stopAllActions()
                self.widget:runAction(cc.Sequence:create(cc.MoveTo:create(0.175, cc.p(old_x, old_y)),cc.CallFunc:create(function()
                        touchlayer:setVisible(false)
                 end)))
                cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false)
            end

        elseif event == ccui.TextFiledEventType.insert_text then --输入字符
        elseif event == ccui.TextFiledEventType.delete_backward then--删除字符
        end

        
       	-- self.numberFieldText:setString(self.numberField:getString())
        
    end)


	WidgetUtils.addClickEvent(self.mainView:getChildByName("surBtn"), function( )
		
		self:sendRePort()
	end)


end
function ReportView:sendRePort()

	print("45555555555555555555",self.xuanze)


	local _name = self.userField:getString()
	local number = self.numberField:getString()

	if self:checkUser(_name) == false then 
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "ID不能为空,请重新输入ID"})
		return
	end
	if tonumber(_name) == nil  then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "ID错误,请重新输入ID"})
		return
	end


	if self:checkNumber(number) == false then 
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "电话号码不能为空"})
		return
	end
	

	if self:getNumberIsOK(number) == false then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "电话号码位数不对"})
		return
	end

	-- print("self.xuanze---------------------",self.xuanze)

	if self.xuanze < 0 then 
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "选择举报类型"})
		return
	end

	Notinode_instance:showLoading(true,8)
	ComHttp.httpPOST(ComHttp.URL.REPORTUSERDUBO,{uid = LocalData_instance.uid,reportuid = _name,contact = number,type = self.xuanze},function(msg)
		LaypopManger_instance:back()
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "提交成功！"})
	end)
end



function ReportView:checkUser(str)
	local userNull = true
	if str == ""  or  string.len(str) == 0 then 
		 userNull = false
		 return userNull
	end
	return userNull
end

function ReportView:checkNumber(str)
	local numberNull = true 
	if str == ""  or  string.len(str) == 0 then 
		numberNull = false
		return numberNull
	end
	return numberNull
end


function ReportView:getNumberIsOK(str)


	if string.len(str) ~= 11 then 
		return false
	end 

	if string.len(str) == 11 then
		local n = tonumber(str)
		if n == nil then
		 	return false
		else
		 	return true
		end
	end

	
end



function ReportView:onEndAni()

end


return ReportView