-------------------------------------------------
--   TODO   房间规则提示
--   @author yc
--   Create Date 2016.11.1
-------------------------------------------------
local RoomRuleLayer = class("RoomRuleLayer",function() 
	return cc.Node:create() 
end)
function RoomRuleLayer:ctor(data)
	self:initData(data)
	self:initView()
end
function RoomRuleLayer:initData(data)
	self.data = data
end
function RoomRuleLayer:initView()
	local layout  =  cc.LayerColor:create(cc.c4b(0,0,0,0),display.width, display.height)
    -- layout:setContentSize(cc.size(display.width,display.height))
    local listener = cc.EventListenerTouchOneByOne:create ()
        listener:setSwallowTouches(true)   
        listener:registerScriptHandler(function(touch, event)
        	self:removeFromParent()
        end, cc.Handler.EVENT_TOUCH_BEGAN)
        local eventDispatcher = layout:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layout)
	layout:setAnchorPoint(cc.p(0,1))
	layout:setTouchEnabled(true)
	self:addChild(layout)
	self:setPosition(cc.p(0,display.height))
	-- 背景
	local bg = ccui.ImageView:create("common/back_tip.png",ccui.TextureResType.localType)
	self:addChild(bg)
	bg:setTouchEnabled(true)
	bg:setScale9Enabled(true)
	bg:setAnchorPoint(cc.p(0,1))
	bg:setCapInsets(cc.rect(30, 30, 32,32))
	
	bg:setPosition(cc.p(18,-75))
	WidgetUtils.setScalepos(bg)

	local list = GT_INSTANCE:getTableDes(self.data,1)

	local _height = #list*40+30
	bg:setContentSize(cc.size(194,_height))
	for i,v in ipairs(list) do
		local text = ccui.Text:create(v,"",22)
		text:setColor(cc.c3b( 0x96, 0x38, 0x23))
		bg:addChild(text)
		text:setAnchorPoint(cc.p(0,1))

		local x = 30
		local y = bg:getContentSize().height-20 - (i-1)*40
		text:setPosition(cc.p(x,y))
	end
end

return RoomRuleLayer