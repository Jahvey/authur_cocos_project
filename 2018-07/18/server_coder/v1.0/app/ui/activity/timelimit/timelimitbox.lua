local timelimitbox = class("timelimitbox",PopboxBaseView)

function timelimitbox:ctor(_data)
	self.data = _data
	self:initView()
	self:initEvent()
end

function timelimitbox:initEvent()
	self:registerScriptHandler(function(state)
		if state == "enter" then
			self:onEnter()
		elseif state == "exit" then
			self:onExit()
		end
	end)
end

function timelimitbox:initView()
	print(".....timelimitbox:initView()")
	self.widget = cc.CSLoader:createNode("ui/timeLimit/timeLimit.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("close"):setVisible(false)
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		self.leaveTime:stopAllActions()
		LaypopManger_instance:back()
	end)

	for i = 1,3 do
		self.mainLayer:getChildByName("tips_"..i):setVisible(false)
	end

	self.mainLayer:getChildByName("tips_1"):setVisible(true)

	self.mainLayer:getChildByName("title_1"):setVisible(false)
	self.mainLayer:getChildByName("title_2"):setVisible(false)

	if self.data.number == 480 then
		self.mainLayer:getChildByName("title_1"):setVisible(true)
	elseif self.data.number == 88 then
		self.mainLayer:getChildByName("title_2"):setVisible(true)
	end

	self.sureBtn  = self.mainLayer:getChildByName("sureBtn")
	WidgetUtils.addClickEvent(self.sureBtn, function( )
		local info = {paytype = self.data.paytype,mid = self.data.mid}
		ComHttp.getorder(info)
	end)

	self.leaveTime = self.sureBtn:getChildByName("leavetime")
end

function timelimitbox:onEnter()
	print(".....timelimitbox:onEnter()")

	self.leaveTime:stopAllActions()
    local timelast = 15
    self.leaveTime:setString(tostring(timelast))
    self.leaveTime:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create( function(...)
        timelast = timelast - 1
        self.leaveTime:setString(tostring(timelast))
        if timelast == 0 then
            self.leaveTime:stopAllActions()
            self.sureBtn:setTouchEnabled(false)
			self.sureBtn:setBright(false)
			self.leaveTime:setVisible(false)

            self.mainLayer:getChildByName("tips_1"):setVisible(false)
            self.mainLayer:getChildByName("tips_3"):setVisible(true)
        end
        if timelast == 12 then
        	self.closeBtn:setVisible(true)
        end        	
    end ))))
end

function timelimitbox:onExit()

end



return timelimitbox