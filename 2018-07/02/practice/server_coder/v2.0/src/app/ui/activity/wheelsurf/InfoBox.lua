local InfoBox = class("InfoBox",require "app.module.basemodule.BasePopBox")

function InfoBox:initData(data,callfunc)
	self.num = data
	self.callfunc = callfunc
	self.needupdate = needupdate
end

function InfoBox:onEnter()
	-- if self.needupdate then
	-- 	self:showSmallLoading()
	-- 	ComHttp.httpPOST(ComHttp.URL.WHEELGETCONF,{uid = LocalData_instance.uid},function(msg)
	-- 		printTable(msg)
	-- 		if not WidgetUtils:nodeIsExist(self) then
	-- 			return
	-- 		end

	-- 		self:hideSmallLoading()

	-- 		if msg.status ~= 1 then
	-- 			return
	-- 		end

	-- 		self.num = msg.redpacket or 0
	-- 		self:refreshView()
	-- 	end)
	-- end
end

function InfoBox:onExit()
	if self.callfunc then
		self.callfunc(self.num)
	end
end

function InfoBox:initView()
	self.widget = cc.CSLoader:createNode("ui/wheelsurf/infobox.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)


	self:refreshView()
end

function InfoBox:refreshView()
	local numlabel = self.mainLayer:getChildByName("num")

	numlabel:setString(self.num.."元")

	local btn1 = self.mainLayer:getChildByName("btn1")

	local btn2 = self.mainLayer:getChildByName("btn2")

	if self.num >= 30 then
		btn1:setEnabled(true)
	else
		btn1:setEnabled(false)
	end

	if self.num >= 1 then
		btn2:setEnabled(true)
	else
		btn2:setEnabled(false)
	end

	WidgetUtils.addClickEvent(btn1,function ()
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "你提现的请求已提交，请联系客服jrhp007领取。"})
	end)
	
	WidgetUtils.addClickEvent(btn2,function ()
		LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "你是否兑换10张房卡？",sureCallFunc = function()
			self:exchangeCard()
		end,cancelCallFunc = function()
		end})
	end)
end

function InfoBox:exchangeCard()
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.WHEELEXCHANGE,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end

		self.num = msg.redpacket
		self:refreshView()

		self:showreward(msg.num)
	end)
end

function InfoBox:showreward(data)

	local widget = cc.CSLoader:createNode("cocostudio/ui/wheelsurf/gongxihuode/gongxihuode.csb")
	widget:setPosition(cc.p((display.cx-640)/2,0))
	self:addChild(widget,2)
	local btn = widget:getChildByName("final"):getChildByName("btn"):getChildByName("btn")

	local num = widget:getChildByName("final"):getChildByName("num")
	local icon = widget:getChildByName("final"):getChildByName("baoxiang")
	num:setString(data.."张房卡")
	icon:loadTexture("cocostudio/ui/wheelsurf/gongxihuode/icon_fangka.png", ccui.TextureResType.localType)
	icon:ignoreContentAdaptWithSize(true)

	WidgetUtils.addClickEvent(btn, function( )
		widget:removeFromParent()
	end)

	local action = cc.CSLoader:createTimeline("cocostudio/ui/wheelsurf/gongxihuode/gongxihuode.csb")

    widget:runAction(action)
    action:gotoFrameAndPlay(0,false)

    local action = cc.CSLoader:createTimeline("cocostudio/ui/wheelsurf/gongxihuode/xuanzhuanguang.csd.csb")

    widget:getChildByName("FileNode_1"):runAction(action)
    action:gotoFrameAndPlay(0,true)
end

return InfoBox