----------------------------
-- 商城
----------------------------
local ShopScene = class("ShopScene",function()
	return cc.Scene:create()
end)
function ShopScene:ctor()
	self:initData()
	self:initView()
	self:initEvent()
end
function ShopScene:initData()
	self.data = nil
end
function ShopScene:initView()
	local widget = cc.CSLoader:createNode("ui/shop/shopView.csb")
	self:addChild(widget)
	
	self.mainLayer = widget:getChildByName("main")
	WidgetUtils.setBgScale(widget:getChildByName("bg"))
	self.midNode = self.mainLayer:getChildByName("midNode")
	WidgetUtils.setScalepos(self.mainLayer)
	self.closeBtn = self.midNode:getChildByName("Image_12"):getChildByName("closebtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		self:closeUI()
	end)
	self.codeBtn = self.midNode:getChildByName("codeBtn"):setVisible(false)
	WidgetUtils.addClickEvent(self.codeBtn, function( )
		self:codeBtnCall()
	end)

	self.midScrollView = self.midNode:getChildByName("Image_12"):getChildByName("midScrollView")
	self.shopItem = self.midScrollView:getChildByName("shopitem")
	self.shopItem:retain()
	self.shopItem:removeFromParent()
	self.midScrollView:removeAllChildren()

end
function ShopScene:createList()
	local x,y = self.shopItem:getPosition()
	local size = self.shopItem:getContentSize()
	for i,v in ipairs(self.data.list) do
		local copyItem = self.shopItem:clone()
		self.midScrollView:addChild(copyItem)

		local row = math.ceil(i/3)
		local col = i - (row-1)*3

		copyItem:setPosition(cc.p(x+(col-1)*(size.width-5),y-(row-1)*(size.height-5)))

		local textlabel = copyItem:getChildByName("textlabel")
		local buybtn = copyItem:getChildByName("buybtn")
		local price = buybtn:getChildByName("price")
		price:setString("￥ "..v.price)
		WidgetUtils.addClickEvent(buybtn, function( )
			self:buyCall(v)
		end)
		WidgetUtils.addClickEvent(copyItem, function( )
			self:buyCall(v)
		end)
		textlabel:setString(v.name)

	end
end
function ShopScene:buyCall(info)
	print("购买")
	ComHttp.getorder(info)
end
function ShopScene:codeBtnCall()
	print("更改邀请码")
	LaypopManger_instance:PopBox("InviteCodeView")
end
function ShopScene:closeUI()
	if self.shopItem then
		self.shopItem:release()
		self.shopItem = nil
	end
	glApp:enterSceneByName("MainScene")		
end
function ShopScene:initEvent()
  	ComHttp.httpPOST(ComHttp.URL.MARKET_LIST,{uid = LocalData_instance:getUid()},function(data)
	   print("请求商城列表")
	   if not WidgetUtils:nodeIsExist(self) then
			return
		end
		print(data)
		self.data = data
		if self.data.list and #self.data.list > 0 then
			self:createList()
		end	
	end)
end
return ShopScene