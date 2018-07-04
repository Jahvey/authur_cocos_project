local InviteActivityView = class("InviteActivityView",PopboxBaseView)

function InviteActivityView:ctor()
	self:initView()

	local eventDispatcher = self:getEventDispatcher()
	local listener = cc.EventListenerCustom:create("weixinsharecallback" , function ( evt )
		local output = evt:getDataString()
		if tonumber(output) and tonumber(output) == 0 then
			print("分享成功")
			if self.sharetype and self.sharetype == 0 then
				ComHttp.httpPOST(ComHttp.URL.REPORTWECHATINVITE,{uid = LocalData_instance.uid,type = 1},function(msg)
				end)
			elseif self.sharetype and self.sharetype == 1 then
				ComHttp.httpPOST(ComHttp.URL.REPORTWECHATINVITE,{uid = LocalData_instance.uid,type = 2},function(msg)
				end)
			end
		else
			print("分享失败")
		end
	end)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

	self:showSmallLoading()
end

function InviteActivityView:initView()
	self.widget = cc.CSLoader:createNode("ui/inviteAct/inviteActView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	self.bg = self.mainLayer:getChildByName("imgbg")

	local rulebtn = self.bg:getChildByName("rulebtn")
	local rulebg = self.bg:getChildByName("board2"):setVisible(false)
	local touchlayer2 = rulebg:getChildByName("touch"):setVisible(false)

	WidgetUtils.addClickEvent(rulebtn,function ()
		if rulebg:isVisible() then
			rulebg:setVisible(false)
			-- touchlayer2:setVisible(false)
		else
			rulebg:setVisible(true)
			-- touchlayer2:setVisible(true)
		end
	end)

	local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)   
    listener:registerScriptHandler(function(touch, event)
    	rulebg:setVisible(false)
    	-- touchlayer2:setVisible(false)
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = touchlayer2:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchlayer2)

	local invitebtn = self.bg:getChildByName("btn1")
	local invitebg = self.bg:getChildByName("board1"):setVisible(false)
	local touchlayer1 = invitebg:getChildByName("touch"):setVisible(false)

	WidgetUtils.addClickEvent(invitebtn,function ()
		if invitebg:isVisible() then
			invitebg:setVisible(false)
			-- touchlayer1:setVisible(false)
		else
			invitebg:setVisible(true)
			-- touchlayer1:setVisible(true)
		end
		-- LaypopManger_instance:PopBox("SharePromptBoxView")
	end)

	local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)   
    listener:registerScriptHandler(function(touch, event)
    	-- print("==============touchlayer1")
    	invitebg:setVisible(false)
    	-- touchlayer1:setVisible(false)
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = touchlayer1:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchlayer1)

    local invitebtn1 = invitebg:getChildByName("button1")
    local invitebtn2 = invitebg:getChildByName("button2")

    local sharetitle = "恩施花牌大酬宾，邀请好友送不停！！"
    local sharecontent = "恩施绍胡、楚胡，利川、巴东上大人、鹤峰百胡、建始楚胡，还可以这样玩，各位老乡赶紧看过来！"
    local sharetitle2 = "恩施绍胡、楚胡，利川、巴东上大人、鹤峰百胡、建始楚胡，还可以这样玩，各位老乡赶紧看过来！"

    WidgetUtils.addClickEvent(invitebtn1,function ()
    	self.sharetype = 0
		CommonUtils.wechatShare2({
			title = sharetitle,
			content = sharecontent,
			url = "/Share/springinvite?type=2&channel="..CLIENT_QUDAO.."&uid="..LocalData_instance.uid,
			flag = 0,
			icon = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),
			})
		-- ComHttp.httpPOST(ComHttp.URL.REPORTWECHATINVITE,{uid = LocalData_instance.uid,type = 1},function(msg)
		-- end)
		print(sharetitle)
		print(sharecontent)
	end)

	WidgetUtils.addClickEvent(invitebtn2,function ()
		self.sharetype = 1
		CommonUtils.wechatShare2({
			title = sharetitle2,
			content = "",
			url = "/Share/springinvite?type=2&channel="..CLIENT_QUDAO.."&uid="..LocalData_instance.uid,
			flag = 1,
			icon = cc.FileUtils:getInstance():fullPathForFilename("common/icon.png"),
			})
		-- ComHttp.httpPOST(ComHttp.URL.REPORTWECHATINVITE,{uid = LocalData_instance.uid,type = 2},function(msg)
		-- end)
		print(sharetitle2)
	end)

	local getbyinvite = self.bg:getChildByName("btn3")

	WidgetUtils.addClickEvent(getbyinvite,function ()
		self:getInviteAward()
	end)

	self.timelable1 = self.bg:getChildByName("timelabel1"):setString("")
	self:setButtonStatus()
end

function InviteActivityView:getInviteAward()
	self:setButtonStatus()
	ComHttp.httpPOST(ComHttp.URL.GETINVITEAWARD,{uid = LocalData_instance.uid},function(msg)
			if not WidgetUtils:nodeIsExist(self) then
				return
			end
			printTable(msg,"sjp3")

			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "领取了"..msg.num.."张房卡"})
			self:getActInfo()
		end)
end

function InviteActivityView:setButtonStatus()
	self.bg:getChildByName("btn2"):setVisible(true)
	self.bg:getChildByName("btn3"):setVisible(false)
end

function InviteActivityView:refreshView(data)
	-- local finishimg = self.bg:getChildByName("finishimg")
	local invitenumlabel = self.bg:getChildByName("invitenum")
	local ownednumlabel = self.bg:getChildByName("ownednum")
	local restnumlabel = self.bg:getChildByName("restnum")

	if tonumber(data.invite_open) == 1 then
		invitenumlabel:setString(data.invite_people)
		ownednumlabel:setString(data.invite_had.."/"..data.invite_max)
		restnumlabel:setString(data.invite_tobe)
		if tonumber(data.invite_tobe) > 0 then
			self.bg:getChildByName("btn3"):setVisible(true)
			self.bg:getChildByName("btn2"):setVisible(false)
		else
			self:setButtonStatus()
		end
	else
		self:setButtonStatus()
		invitenumlabel:setString("0")
		ownednumlabel:setString("0")
		restnumlabel:setString("0")
	end

	self.bg:getChildByName("timelabel1"):setString("活动时间："..self:formatTime(data.invite_starttime).."-"..self:formatTime(data.invite_endtime))
end

function InviteActivityView:onEndAni()
	self:getActInfo()
end

function InviteActivityView:getActInfo()
	ComHttp.httpPOST(ComHttp.URL.GETINVITEACTSTATE,{uid = LocalData_instance.uid},function(msg)
			if not WidgetUtils:nodeIsExist(self) then
				return
			end
			printTable(msg,"sjp3")
			self:refreshView(msg)
			self:hideSmallLoading()
		end)
end

function InviteActivityView:formatTime(sec)
	if sec < 0 then
		return ""
	end

	local datetab = os.date("*t", sec)
	local string = datetab.year.."/"..datetab.month.."/"..datetab.day
	return string
end

function InviteActivityView:getCharacterCountInUTF8String(str,length)
    local lengthmax = length or 16
    local locallengt = 0
    local c
    local i = 1
    while true do
        c = string.byte(string.sub(str,i,i))
        print(c)
        if not c then
            return str,locallengt
        elseif (c<=127)  then
            locallengt = locallengt + 1
            if locallengt > lengthmax then
                return string.sub(str,1,i-1).."..."
            end
            i = i + 1;
        elseif (bit.band(c , 0xE0) == 0xC0) then
            locallengt = locallengt + 2
            if locallengt > lengthmax then
                return string.sub(str,1,i-1).."..."
            end
            i = i + 2;
        elseif (bit.band(c , 0xF0) == 0xE0) then
            locallengt = locallengt + 2
            if locallengt > lengthmax then
                return string.sub(str,1,i-1).."..."
            end
            i = i + 3;
        elseif (bit.band(c , 0xF8) == 0xF0) then
            locallengt = locallengt + 2
            if locallengt > lengthmax then
                return string.sub(str,1,i-1).."..."
            end
            i = i + 4;
        else 
            return str,locallengt
        end
    end
    return str,locallengt
end

return InviteActivityView