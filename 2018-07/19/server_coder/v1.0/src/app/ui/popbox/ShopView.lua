----------------------------
-- 商城
----------------------------
local ShopView = class("ShopView",PopboxBaseView)
function ShopView:ctor()
	self:initData()
	--ios 和安卓 都需要打开商铺列表
	self:initView()
	self:initEvent()
end
function ShopView:initData()
	self.data = nil
end
function ShopView:initView()
	local widget = cc.CSLoader:createNode("ui/shop/shopViewForIOS.csb")
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")

	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		if self.shopItem then
			self.shopItem:release()
			self.shopItem = nil
		end
		if self.shopitem2 then
			self.shopitem2:release()
			self.shopitem2 = nil
		end
		LaypopManger_instance:back()
	end)

	self.midScrollView = self.mainLayer:getChildByName("Node_2"):getChildByName("midScrollView")
	self.shopItem = self.midScrollView:getChildByName("shopitem")
	self.shopItem:retain()
	self.shopItem:removeFromParent()
	self.midScrollView:removeAllChildren()

	self.shopitem2 = self.mainLayer:getChildByName("Node_2"):getChildByName("shopitem2")
	self.shopitem2:retain()
	self.shopitem2:removeFromParent()

	self.mainLayer:getChildByName("girl"):setVisible(false)


	local copybtn = self.mainLayer:getChildByName("copybtn")

	WidgetUtils.addClickEvent(copybtn, function( )
		CommonUtils.copyTo(self.ioswechatid or "")
	end)

	local wechatlabel = self.mainLayer:getChildByName("wechatlabel")
	wechatlabel:setString("")

	self:getAgentInfo()
end
function ShopView:createList()
	local x,y = 11.2,291.2
	local size = self.shopItem:getContentSize()
	local cnt = #self.data.list
	for i,v in ipairs(self.data.list) do
		local copyItem = self.shopItem:clone()
		self.midScrollView:addChild(copyItem)

		local row = math.ceil(i/4)
		local col = i - (row-1)*4

		copyItem:setPosition(cc.p(x+(col-1)*(size.width+11.2),y-(row-1)*(size.height+11.2)))

		local textlabel = copyItem:getChildByName("textlabel")
		local buybtn = copyItem:getChildByName("buybtn")
		local price = buybtn:getChildByName("price")
		local img = copyItem:getChildByName("img")
		NetPicUtils.getPic(img, v.img)

		copyItem:getChildByName("image_free"):setVisible(false)
		if v.is_firstpay and v.is_firstpay > 0  then
			copyItem:getChildByName("image_free"):setVisible(true)
			copyItem:getChildByName("image_free"):getChildByName("Text"):setString("首充赠送"..v.is_firstpay.."张")
		end
		img.downcallback = function(image)
            image:setContentSize(img:getContentSize())
        end
		price:setString("￥"..v.showprice)
		WidgetUtils.addClickEvent(buybtn, function( )
			self:buyCall(v)
		end)
		WidgetUtils.addClickEvent(copyItem, function( )
			self:buyCall(v)
		end)
		textlabel:setString(v.name.."/")
	end
	local row = math.ceil(cnt/4)
	local col = cnt - (row-1)*4
	local copyItem2 = self.shopitem2:clone()
	self.midScrollView:addChild(copyItem2)
	copyItem2:setPosition(cc.p(x+(col)*(size.width+11.2),y-(row-1)*(size.height+11.2)))

	WidgetUtils.addClickEvent(copyItem2, function( )
		self.mainLayer:setVisible(false)
		self:initView2()
	end)
	
	if SHENHEBAO then
		copyItem2:setVisible(false)
	end
end
function ShopView:buyCall(info)
	print("购买")
	ComHttp.getorder(info)
end

function ShopView:initEvent()
	self:showSmallLoading()
  	ComHttp.httpPOST(ComHttp.URL.MARKET_LIST,{uid = LocalData_instance:getUid()},function(data)
	   print("请求商城列表")
	   -- printTable(data,"xp")

	   print(".CLIENT_QUDAO = ",CLIENT_QUDAO)

	   if not WidgetUtils:nodeIsExist(self) then
			return
		end
		self:hideSmallLoading()
		print("请求商城列表——————－1")
		printTable(data,"xp65")
		self.data = data
		if self.data.list and #self.data.list > 0 then
			self:createList()
		else
			self.mainLayer:getChildByName("girl"):setVisible(true)
		end	
	end)
end

function ShopView:initView2()
	local widget = cc.CSLoader:createNode("ui/shop/shopView2.csb")
	self:addChild(widget)
	local mainLayer = widget:getChildByName("main")

	local closeBtn = mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(closeBtn, function( )
		LaypopManger_instance:back()
	end)

	local listView = mainLayer:getChildByName("listView")
	local daili_item = mainLayer:getChildByName("item1")
	daili_item:retain()
	daili_item:removeFromParent()
	daili_item:setVisible(false)


	local  wechat = {}
	table.insert(wechat, {wechatName = "游戏公众号：", wechat = "jrhp888"})
	table.insert(wechat, {wechatName = "客服号：", wechat = "jrhp007"})
	for i,v in ipairs(CM_INSTANCE:getGAMESLIST()) do
		local _wechatName = GT_INSTANCE:getWechatName(v)
		local _wechat = GT_INSTANCE:getWechat(v)
		if _wechatName and _wechat  then
			table.insert(wechat, {wechatName = _wechatName, wechat = _wechat })
		end
	end

	for k,v in pairs(wechat) do
		local copyItem = daili_item:clone()
		listView:addChild(copyItem)

		copyItem:setVisible(true)
		local tip1 = copyItem:getChildByName("tip1")
		local copybtn = copyItem:getChildByName("copybtn")

		print(".....copybtn = ",copybtn)
		

		WidgetUtils.addClickEvent(copybtn, function( )
			CommonUtils.copyTo(v.wechat)
		end)
		tip1:setString(v.wechatName..v.wechat)
	end
	daili_item:release()
end

function ShopView:getAgentInfo()
	ComHttp.httpPOST(ComHttp.URL.GETAGENTINFO,{uid = LocalData_instance:getUid()},function(data)
	   	if not WidgetUtils:nodeIsExist(self) then
			return
		end
		print("ShopView:getAgentInfo()")
		printTable(data,"xp")
		if data.list[1] then
			local wechatlabel = self.mainLayer:getChildByName("wechatlabel")
			wechatlabel:setString(data.list[1].content)

			self.ioswechatid = data.list[1].copyinfo
		end
	end)
end

return ShopView
