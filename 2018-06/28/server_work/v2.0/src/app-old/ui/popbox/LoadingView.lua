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
	"正在支付",
	"获取支付结果",
	"处理未完成的订单",
	"正在传输信息",
	"正在进入房间",
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
	self.widget = cc.CSLoader:createNode("ui/popbox/loadingView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	-- WidgetUtils.addClickEvent(self.widget:getChildByName("layer"), function( )
	-- 	LaypopManger_instance:back()
	-- end)

	self.tip = self.mainLayer:getChildByName("tip"):setString("")
	self.circle = self.mainLayer:getChildByName("circle")
	local act = cc.RotateBy:create(0.1, 30)
	self.circle:runAction(cc.RepeatForever:create(act))

	self:setShowStr(self.strtype)

	local layer = self.widget:getChildByName("layer")

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)   
    listener:registerScriptHandler(function(touch, event)
    	-- print("............1点击到  LoadingView")
    	-- print(tostring(self:isVisible() and Notinode_instance:isVisible()))
    	if self:isVisible() and Notinode_instance:isVisible() then
    		-- print("屏蔽事件")
    	end
    	return self:isVisible() and Notinode_instance:isVisible()

    end, cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = layer:getEventDispatcher()
    --eventDispatcher:addEventListenerWithFixedPriority(listener, -1)

    layer:registerScriptHandler(function(state)
        -- print("--------------"..state)
       if state == "enter" then
             eventDispatcher:addEventListenerWithFixedPriority(listener, -1)
        elseif state == "exit" then
             eventDispatcher:removeEventListener(listener)
        end
    end)

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
	-- self.tip:setPositionX(-self.tip:getContentSize().width/2)
	-- self:tipAction(str)
end
-- function LoadingView:tipAction(str)
-- 	self.tip:stopAllActions()
-- 	local count = 0
-- 	local callfunc = function() 
-- 		count = count + 1
-- 		if (count % 4) == 0 then
-- 			self.tip:setString(str)
-- 		elseif (count % 4) == 2 then
-- 			self.tip:setString(str.."..")
-- 		elseif (count % 4) == 1 then
-- 			self.tip:setString(str..".")
-- 		elseif (count % 4) == 3 then
-- 			self.tip:setString(str.."...")
-- 		end	
-- 	end
-- 	CommonUtils.schedule(self.tip, 0.2, callfunc)
-- end
function LoadingView:initEvent()
end
return LoadingView