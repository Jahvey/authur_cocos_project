local ShopView = class("ShopView",PopboxBaseView)
-- opentype 1 大厅打开 2 牌桌打开
function ShopView:ctor(opentype)
	self:initView()
	self:initEvent()
end
--Socketapi.getorder(v.shopid)

function ShopView:initView()
	self.widget = cc.CSLoader:createNode("ui/shop/shopView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	-- WidgetUtils.addClickEvent(self.mainLayer:getChildByName("btn"), function( )
	-- 	LaypopManger_instance:PopBox("CodeView",true)
	-- end)

	for i=1,6 do
		self.mainLayer:getChildByName("shop"..i):setVisible(false)
	end

end
function ShopView:getlistcall(data)
    if data.result == nil or data.result == 1 then
       	if data.shopInfoList  then
       		for i,v in ipairs(data.shopInfoList) do
       			local node = self.mainLayer:getChildByName("shop"..i)
       			node:setVisible(true)
       			node:getChildByName("text"):setString(v.shopname)
       			node:getChildByName("btn"):getChildByName("Text_1"):setString(v.rmb.."元")
       			WidgetUtils.addClickEvent(node:getChildByName("btn"), function( )
  					Socketapi.getshopbuy(v.shopid)
  				end)

       		end
       	end
    else
        LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info,sureCallFunc = function()
        end})
    end
end
function ShopView:initEvent()

    
    ComNoti_instance:addEventListener("3;19;2",self,self.getlistcall)
    ComNoti_instance:addEventListener("3;19;1",self,self.buycall)
end
 
function ShopView:buycall( data )
      LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info,sureCallFunc = function()
        end})
end
function ShopView:onEndAni()
    Socketapi.getshoplist()
end

return ShopView