local ExchangeDetailBox = class("ExchangeDetailBox",require "app.module.basemodule.BasePopBox")

function ExchangeDetailBox:initView()
	self.widget = cc.CSLoader:createNode("ui/worldcup/box/exchangeDetailBox.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	self.sureBtn = self.mainLayer:getChildByName("btn")
	WidgetUtils.addClickEvent(self.sureBtn, function( )
		LaypopManger_instance:back()
	end)

	self.listView = self.mainLayer:getChildByName("listview")

	local itemmodel = self.listView:getChildByName("item")
	itemmodel:retain()
	self.listView:setItemModel(itemmodel)
	self.listView:removeAllItems()
	itemmodel:release()
end

function ExchangeDetailBox:refreshView(data)
	self.listView:removeAllItems()

	for i,v in ipairs(data.list or {}) do
		self.listView:pushBackDefaultItem()

		local item = self.listView:getItem(i-1)
		
		local label1 = item:getChildByName("label1")
		local label2 = item:getChildByName("label2")
		local label3 = item:getChildByName("label3")

		label1:setString(os.date("%m月%d日",v.date).."消耗")
		label2:setString(v.point)
		label3:setString("大力神点数兑换了"..v.name)

		label2:setPositionX(label1:getPositionX()+label1:getContentSize().width)
		label3:setPositionX(label2:getPositionX()+label2:getContentSize().width)
	end
end

function ExchangeDetailBox:getList()
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.WCSHOPGETDETAIL,{uid = LocalData_instance.uid},function(msg)
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

function ExchangeDetailBox:onEnter()
	self:getList()
end

function ExchangeDetailBox:onExit()
end

return ExchangeDetailBox