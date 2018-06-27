-------------------------------------------------
--   TODO   loadingUI
--   @author yc
--   Create Date 2016.10.28
-------------------------------------------------
local LoadingView = class("LoadingView",function() 
	return cc.Node:create()
end)
local STR_LIST = {
	"正在登录游戏",
	"正在重连",
	"努力加载中",
	"获取订单中",
}
-- strtype 1 正在登录游戏
function LoadingView:ctor(strtype)
	self:initData(strtype)
	self:initView()
	self:initEvent()
	
end
function LoadingView:initData(strtype)
	self.strtype = strtype
end

function LoadingView:initView()
	local touchLayer = ccui.Layout:create()
	touchLayer:setAnchorPoint(cc.p(0.5,0.5))
	touchLayer:setPosition(cc.p(0,0))
    touchLayer:setContentSize(cc.size(display.width*2,display.height*2))
    touchLayer:setTouchEnabled(true)
    local  listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    local function onTouchBegan()
    	return self:isVisible()
    end
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )

    touchLayer:getEventDispatcher():addEventListenerWithFixedPriority(listener,-1)
    self:addChild(touchLayer)

	self.widget = cc.CSLoader:createNode("ui/popbox/loadingView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.widget:getChildByName("layer"), function( )
		LaypopManger_instance:back()
	end)

	self.tip = self.mainLayer:getChildByName("tip"):setString("")
	self.circle = self.mainLayer:getChildByName("circle")
	local act = cc.RotateBy:create(0.1, 10)
	self.circle:runAction(cc.RepeatForever:create(act))

	self:setShowStr(self.strtype)
	if self.strtype == 2 then
		self:runAction(cc.Sequence:create(cc.DelayTime:create(10),cc.CallFunc:create(function()
			LocalData_instance:reset()
			SocketConnect_instance:closeSocket()
			Notinode_instance:setisLogin(false)
			glApp:enterScene("LoginScene",true)
		end)))
	end
end
function LoadingView:setShowStr(strtype)
	if not strtype then
		strtype = 1
	end
	local str = STR_LIST[strtype] or ""
	self.tip:setString(str)
	self.tip:setPositionX(-self.tip:getContentSize().width/2)
	self:tipAction(str)

	if strtype ~= 2 then
		self:runAction(cc.Sequence:create(cc.DelayTime:create(10),cc.CallFunc:create(function( )
				self:setVisible(false)
		end)))
	end
end
function LoadingView:tipAction(str)
	self.tip:stopAllActions()
	local count = 0
	local callfunc = function() 
		count = count + 1
		if (count % 4) == 0 then
			self.tip:setString(str)
		elseif (count % 4) == 2 then
			self.tip:setString(str.."..")
		elseif (count % 4) == 1 then
			self.tip:setString(str..".")
		elseif (count % 4) == 3 then
			self.tip:setString(str.."...")
		end	
	end
	CommonUtils.schedule(self.tip, 0.2, callfunc)
end
function LoadingView:initEvent()
end
return LoadingView