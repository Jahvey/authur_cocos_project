local ShopPage = class("ShopPage",function ()
	return cc.Node:create()
end)

local RULE_TITLE = "大力神点数商城"
local RULE_CONTENT = "1. 活动时间：2018-06-14 12:00 ~ 2018-07-16 12:00\n2. 玩家可使用大力神点数兑换产品，消耗的点数将从总点数中扣除。\n3. 无兑换次数限制，商店产品兑完即止。\n4. 点击“兑换详情”，可查看兑换记录。\n5. 兑换实物后请联系客服jrhp007领奖。\n"

function ShopPage:ctor(mainview)
	self:initData(mainview)
	self:initView()
	self:initEvent()
end

function ShopPage:initData(mainview)
	self.mainView = mainview

	self.itemList = {}
end

function ShopPage:initView()
	self.widget = cc.CSLoader:createNode(self.mainView:getResourcePath().."shop/shopnode.csb")
	self:addChild(self.widget)

	local rulebtn = self.widget:getChildByName("rulebtn")

	WidgetUtils.addClickEvent(rulebtn, function()
		LaypopManger_instance:PopBox("WCRuleBox",{title = RULE_TITLE,content = RULE_CONTENT})
	end)

	local detailbtn = self.widget:getChildByName("detailbtn")
	WidgetUtils.addClickEvent(detailbtn, function()
		LaypopManger_instance:PopBox("WCExchangeDetail")
	end)

	self.listView = self.widget:getChildByName("listview")

	local itemmodel = self.listView:getChildByName("item")
	itemmodel:retain()
	self.listView:setItemModel(itemmodel)
	self.listView:removeAllItems()
	itemmodel:release()
end

function ShopPage:initEvent()
	self:registerScriptHandler(function(state)
		if state == "enter" then
			self:onEnter()
		elseif state == "exit" then
			self:onExit()
		end
	end)
end

function ShopPage:refreshView(data)
	self.listView:removeAllItems()

	for i,v in ipairs(data.list or {}) do
		self.listView:pushBackDefaultItem()

		local item = self.listView:getItem(i-1)
		item.data = v

		local name = item:getChildByName("name")
		local img = item:getChildByName("img"):ignoreContentAdaptWithSize(true)
		local restnum = item:getChildByName("restnum")
		local btn = item:getChildByName("btn")
		local price = btn:getChildByName("price")

		name:setString(v.name)
		NetPicUtils.getPic(img, v.url)
		restnum:setString("剩余数量"..v.num)

		if v.isunlimit == 1 then
			restnum:setVisible(false)
		else
			restnum:setVisible(true)
		end

		WidgetUtils.addClickEvent(btn,function ()
			if self.mainView:getPoint() < v.point then
				LaypopManger_instance:PopBox("WCTipBox","点数不足!")
				return
			end

			if v.isunlimit ~= 1 and v.num <= 0  then
				LaypopManger_instance:PopBox("WCTipBox","库存不足!")
				return
			end

			LaypopManger_instance:PopBox("WCConfirmBox",v,function ()
				if not WidgetUtils:nodeIsExist(self) then
					return
				end
				self:buy(v)
			end)
		end)
	
		price:setString(self:formatPrice(v.point))
	end
end

function ShopPage:buy(data)
	self.mainView:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.WCSHOPBUY ,{uid = LocalData_instance.uid,pid = data.id},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self.mainView:hideSmallLoading()
		self:getConf()
		if msg.status ~= 1 then
			LaypopManger_instance:PopBox("WCTipBox","兑换失败!(ErrorCde:"..msg.status..")")
			return
		end

		self.mainView:setPoint(self.mainView:getPoint()-(data.point or 0))

		if data.item_type == 1 then
			self.mainView:showReward(data)
		elseif data.item_type == 4 then
			-- LaypopManger_instance:PopBox("WCAdressBox",data.name)
			LaypopManger_instance:PopBox("ShopTipBox2",data.name)
		end
	end)
end

function ShopPage:getConf()
	self.mainView:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.WCSHOPGETCONF ,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self.mainView:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end

		self:refreshView(msg)
	end)
end

function ShopPage:formatPrice(price)
	local str = price

	if price >= 10000 then
		if price%10000 == 0 then
			str = string.format("%d".."万",(price/10000))
		else
			str = string.format("%.2f".."万",(price/10000))
		end
	end

	return str
end

function ShopPage:onEnter()
	self:getConf()
end

function ShopPage:onExit()
	if self.itemModel then
		self.itemModel:release()
	end
end

return ShopPage