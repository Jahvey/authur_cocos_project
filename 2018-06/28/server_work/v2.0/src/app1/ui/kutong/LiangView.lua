-------------------------------------------------
--   TODO   帮助UI
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local Card = require "app.ui.kutong.Card"
local HelpView = class("HelpView",PopboxBaseView)
function HelpView:ctor(scene)
	self.scene = scene
	self:initView()
end

function HelpView:initView()
	self.widget = cc.CSLoader:createNode("ui/kutong/liangzha/LiangView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closeBtn"), function( )
		print("返回大厅")
		Socketapi.doactionforkutong(1)
		LaypopManger_instance:back()
	end)
    self.cell = self.mainLayer:getChildByName("cell")
    for i,v in ipairs(self.scene.data.roomPlayerItemJsons) do
    	local localpos = self.scene:getLocalindex(v.index)
    	local item = self.mainLayer:getChildByName(localpos)
    	item:getChildByName("name"):setString(ComHelpFuc.getStrWithLengthByJSP(v.nickname))
    	local icon = item:getChildByName("icon")
    	require("app.ui.common.HeadIcon_Club").new(icon,v.headimgurl,110)
    	local listview = item:getChildByName("listview")
    	listview:setItemModel(self.cell)
    	for i1,v1 in ipairs(v.curLiangBooms) do
    		listview:pushBackDefaultItem()
	        local item1 = listview:getItem(i1-1)
	        for i2,v2 in ipairs(v1.curCards) do
	        	local card = Card.new(v2,true)
	        	card:setCardAnchorPoint(cc.p(0,0))
	        	card:setScale(0.45)
	        	card:setPositionX((i2-1)*20)
	        	item1:addChild(card)
	        end
	        item1:getChildByName("zha"):setString(#v1.curCards.."炸")
    	end
    end
    self.cell:setVisible(false)

end

return HelpView