local Setrealname = class("Setrealname",PopboxBaseView)

function Setrealname:ctor()
	self:initView()
end

function Setrealname:initView()

	self.widget = cc.CSLoader:createNode("ui/setrealname/setrealname.csb")
	self:addChild(self.widget)

	self.closeBtn  = self.widget:getChildByName("main"):getChildByName("closebtn")

	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)



	self.mainView = self.widget:getChildByName("main"):getChildByName("Image")
	self.nameField = self.mainView:getChildByName("name_bg"):getChildByName("TextField")
	self.numberField = self.mainView:getChildByName("number_bg"):getChildByName("TextField")


	local touchlayer = ccui.Layout:create()
    touchlayer:setContentSize(cc.size(display.width*4, display.height*4))
    touchlayer:setPosition(cc.p(-display.width, -display.height))
    self:addChild(touchlayer, 10)
    touchlayer:setTouchEnabled(true)
    touchlayer:setVisible(false)

    WidgetUtils:addPressListener(touchlayer, function (event)
        self.nameField:setDetachWithIME(true)
        self.numberField:setDetachWithIME(true)
    end)
	local old_x,old_y = self.widget:getPosition()
	self.nameField:addEventListener(function (target, event)
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
    end)


	WidgetUtils.addClickEvent(self.mainView:getChildByName("btn1"), function( )
		
		self:sendRealName()
	end)


end
function Setrealname:sendRealName()
	local _name = self.nameField:getString()
	local number = self.numberField:getString()

	if self:checkName(_name) == false then 
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "姓名不能为空,请输入姓名"})
		return
	end


	if self:checkNumber(number) == false then 
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "身份证号码不能为空"})
		return
	end
	

	if self:getNumberIsOK(number) == false then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "身份证号的格式或位数不对"})
		return
	end

	Notinode_instance:showLoading(true,8)
	ComHttp.httpPOST(ComHttp.URL.SETREALNAME,{uid = LocalData_instance.uid,code = number,name = _name},function(msg)
		Notinode_instance:showLoading(false)
		LaypopManger_instance:back()
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "认证成功！"})
	end)
end



function Setrealname:checkName(str)
	local nameNull = true
	if str == ""  or  string.len(str) == 0 then 
		 nameNull = false
		 return nameNull
	end
	return nameNull
end

function Setrealname:checkNumber(str)
	local numberNull = true 
	if str == ""  or  string.len(str) == 0 then 
		numberNull = false
		return numberNull
	end
	return numberNull
end


function Setrealname:getNumberIsOK(str)


	if string.len(str) ~= 15 and string.len(str) ~= 18 then 
		return false
	end 


	if string.len(str) == 15 then
		local n = tonumber(str)
		if n == nil then
		 	return false
		else
		 	return true
		end
	end

	if string.len(str) == 18 then
		local _n = string.sub(str,1,17)
		local _x = string.sub(str,-1)
		local n = tonumber(_n);
		if n == nil then
		 	return false
		end
		local x = tonumber(_x);
		if x == nil and _x ~= "X" and _x ~= "x" then
			return false
		end
		return true
	end
end



function Setrealname:onEndAni()

	print("打开 实名认证界面")
		-- ComHttp.httpPOST(ComHttp.URL.SETREALNAME,{uid = LocalData_instance.uid},function(msg)
		-- 	if not WidgetUtils:nodeIsExist(self) then
		-- 		return
		-- 	end
		-- 	printTable(msg,"sjp")
		-- 	self:refreshView(msg)
		-- 	if self.loadingView then
		-- 		self.loadingView:removeFromParent()
		-- 		self.loadingView = nil
		-- 	end
		-- end)
end


return Setrealname