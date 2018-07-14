local RechargeView = class("RechargeView",require "app.module.basemodule.BasePopBox")

function RechargeView:initView()
	self.widget = cc.CSLoader:createNode("ui/rechargeactivity/recharge.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	self.listview = self.mainLayer:getChildByName("listview")

	local itemmodel = self.mainLayer:getChildByName("item")

	itemmodel:retain()
	self.listview:setItemModel(itemmodel)
	itemmodel:removeFromParent()
	itemmodel:release()

	self.timecount = self.mainLayer:getChildByName("timecount")

	self.rechargebtn = self.mainLayer:getChildByName("rechargebtn")

	WidgetUtils.addClickEvent(self.rechargebtn,function ()
		LaypopManger_instance:backByName("RechargeView")
		LaypopManger_instance:PopBox("ShopView")
	end)
end

function RechargeView:refreshView(data)
	self.timecount:stopAllActions()
	self.timecount:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function ()
			self.timecount:setString("活动倒计时:"..self:timeFormat(data.endtime - os.time()))
		end),cc.DelayTime:create(1))))

	self:refreshListView(data)
end

function RechargeView:refreshListView(data)
	self.listview:removeAllItems()
	for i,v in ipairs(data.list or {}) do
		self.listview:pushBackDefaultItem()
        local item = self.listview:getItem(i-1)

        local title = item:getChildByName("title")

        title:setString(v.name)

        local cardnodelist = {}
        for m=1,4 do
        	local cardnode = item:getChildByName("cardnode"..m)

        	if v.prizelist[m] then
	        	cardnode:getChildByName("num"):setString(v.prizelist[m])
	        	cardnode.num = v.prizelist[m]
	        	table.insert(cardnodelist,cardnode)
	        else
	        	cardnode:setVisible(false)
	        end
        end

        local btn = item:getChildByName("btn")

        WidgetUtils.addClickEvent(btn,function ()
    		self:getPrize(v.id,cardnodelist,btn)
    	end)

        if v.chance > 0 then
        	btn:setEnabled(true)
        else
        	btn:setEnabled(false)
        end
	end
end

function RechargeView:onEnter()
	self:getConf()
end

function RechargeView:onExit()
	-- if self.selectlight then
	-- 	self.selectlight:release()
	-- end

end

function RechargeView:getConf()
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.RECHARGEGETCONF,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end

		self:refreshView(msg)
	end)
end

function RechargeView:getPrize(id,cardlist,btn)
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.RECHARGEGETPRIZE,{uid = LocalData_instance.uid,id = id},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end

		self:openview({itemtype = 2,name = "房卡"..msg.num.."张"})

		for i,v in ipairs(cardlist) do
			if v.num == msg.num then
				v:getChildByName("selected"):setVisible(true)
			else
				v:getChildByName("selected"):setVisible(false)
			end
		end

		if msg.chance <= 0 then
			btn:setEnabled(false)
		else
			btn:setEnabled(true)
		end
	end)
end

function RechargeView:timeFormat(time)
	local str = ""

	if time <= 0 then
		return "0秒"
	end

	local secend = time%60
	if secend >= 10 then
		str =  secend.."秒"..str
	elseif secend > 0 then
		str = "0"..secend.."秒"..str
	end

	time = math.floor(time/60)

	local minutes = time%60
	if minutes >= 10 then
		str =  minutes.."分"..str
	elseif minutes > 0 then
		str = "0"..minutes.."分"..str
	end

	time = math.floor(time/60)

	local hour = time%24
	if hour >= 10 then
		str =  hour.."时"..str
	elseif hour > 0 then
		str = "0"..hour.."时"..str
	end

	time = math.floor(time/24)

	if time > 0 then
		str = time.."天"..str
	end

	return str
end

function RechargeView:openview(msg)
	local node = cc.CSLoader:createNode("ui/rechargeactivity/award/zhanshi.csb")
	self:addChild(node)
	-- node:getChildByName("node"):setVisible(false)

	local actionnode = node:getChildByName("zhanshi")

	local image = actionnode:getChildByName("Node_1"):getChildByName("Node_24_0"):getChildByName("images")
	image:ignoreContentAdaptWithSize(true)
	if msg.itemtype == 2 then
		image:loadTexture("ui/rechargeactivity/award/images/fangka_big.png", ccui.TextureResType.localType)
	else
		image:loadTexture("ui/rechargeactivity/award/images/hongbao_big.png", ccui.TextureResType.localType)
	end

	local text = node:getChildByName("node"):getChildByName("di"):getChildByName("text")
	text:setString(msg.name)

	local lightnode = node:getChildByName("light")

	local action1 = cc.CSLoader:createTimeline("ui/rechargeactivity/award/hongbaohuodong.csb")
	actionnode:runAction(action1)
	action1:gotoFrameAndPlay(0,false)

	local action2 = cc.CSLoader:createTimeline("ui/rechargeactivity/award/light.csb")
	lightnode:runAction(action2)
	action2:gotoFrameAndPlay(0,true)


	WidgetUtils.addClickEvent(node:getChildByName("node"):getChildByName("closeBtn"), function( )
		node:removeFromParent()
	end)
	WidgetUtils.addClickEvent(node:getChildByName("node"):getChildByName("btn"), function( )
		CommonUtils.shareScreen_2()
    	-- ISFENXIANGMEIRIACTIVIEY = true
	end)
end

return RechargeView