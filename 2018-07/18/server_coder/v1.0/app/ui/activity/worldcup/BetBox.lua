local BetBox = class("BetBox",require "app.module.basemodule.BasePopBox")

local BET_LIMIT = 1000

function BetBox:initData(mainview,data,betinfo,call)
	self.mainView = mainview
	self.data = data
	self.betInfo = betinfo
	self.call = call
	self.refresh = false
	self.requesting = false
end

function BetBox:initView()
	self.widget = cc.CSLoader:createNode("ui/worldcup/box/betBox.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	self.tip1 = self.mainLayer:getChildByName("tip1")
	self.tip2 = self.mainLayer:getChildByName("tip2")
	self.tip3 = self.mainLayer:getChildByName("tip3")
	self.flag = self.mainLayer:getChildByName("flag")

	self.btn_1 = self.mainLayer:getChildByName("btn_1")
	self.btn_2 = self.mainLayer:getChildByName("btn_2")
	self.btn_3 = self.mainLayer:getChildByName("btn_3")

	self:refreshView()
end

function BetBox:refreshView()
	if not self.data then
		return
	end

	self.tip1:setString("您已经选择"..self.data.team1.name.."vs"..self.data.team2.name)

	if self.betInfo.id == 0 then
		self.flag:setVisible(false)
		self.tip2:setString("[平局]")
	else
		self.flag:setVisible(true)
		self.flag:loadTexture(self.mainView:getCountryFlag(self.betInfo.id))
		self.tip2:setString("["..self.betInfo.name.."]")
		self.flag:setPositionX(-self.tip2:getContentSize().width/2-40)
	end

	self.tip3:setString("您已下注[上限"..BET_LIMIT.."]:"..self.data.bet_num)

	WidgetUtils.addClickEvent(self.btn_1,function ()
		self:bet(50)
	end)
	WidgetUtils.addClickEvent(self.btn_2,function ()
		self:bet(100)
	end)
	WidgetUtils.addClickEvent(self.btn_3,function ()
		self:bet(500)
	end)
end

function BetBox:bet(num)
	if self.mainView:getPoint() < num then
		LaypopManger_instance:PopBox("WCTipBox","您当前点数不足，无法成功下注，请更换下注额度或者获取更多点数后重试！")
		return
	end

	if self.data.bet_num + num > BET_LIMIT then
		LaypopManger_instance:PopBox("WCTipBox","当前下注已超过上限，请更改额度后重试！")
		return
	end

	self:showSmallLoading()
	self.requesting = true
	ComHttp.httpPOST(ComHttp.URL.WCBET,{uid = LocalData_instance.uid,gid = self.data.gid,tid = self.betInfo.id,num = num},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end
		self.refresh = true
		self:hideSmallLoading()
		self.requesting = false
		if msg.status ~= 1 then
			LaypopManger_instance:PopBox("WCTipBox","操作失败!(ErrorCde:"..msg.status..")")
			return
		end

		LaypopManger_instance:PopBox("WCTipBox","投注成功！")
		self.mainView:sharePic()

		self.mainView:setPoint(self.mainView:getPoint()-(num or 0))
		self.data.bet_num = self.data.bet_num + num
		self:refreshView()
	end)
end

function BetBox:onEnter()
end

function BetBox:onExit()
	if self.refresh then
		self.call()
	end
end

return BetBox