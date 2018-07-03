BasePopBox = class("BasePopBox",function()
    return cc.Layer:create()
end)

function BasePopBox:ctor(...)
	self:initData(...)
	self:initView(...)
	self:initEvent(...)
end


function BasePopBox:initData(...)
	-- body
end

function BasePopBox:initView(...)
	-- body
end

function BasePopBox:initEvent(...)
	self:registerScriptHandler(function(state)
		if state == "enter" then
			self:onEnter()
		elseif state == "exit" then
			self:onExit()
		end
	end)
end

function BasePopBox:onEnter()
	-- body
end

function BasePopBox:onExit()
	-- body
end

function BasePopBox:initview(opacity,color)
	self:setPosition(cc.p(display.width/2,display.height/2))
	 if self.widget and self.widget:getChildByName("layer") then
	 	-- self.widget:setVisible(false)
	 	WidgetUtils.addLayerAnimation(self.widget:getChildByName("main"),function() 
	 		self:onEndAni()
	 	end)
        --ccui.Layout:setBackGroundColor(ccui.LayoutBackGroundColorType.solid)
        self.widget:getChildByName("layer"):setBackGroundColor(color or cc.c3b(0,0,0))
        self.widget:getChildByName("layer"):setBackGroundColorOpacity(math.floor((opacity or 70)/100*255))
        self.widget:getChildByName("layer"):setContentSize(cc.size(display.width,display.height))
        self.widget:getChildByName("layer"):setPosition(cc.p(-display.cx,-display.cy))
    end
end

function BasePopBox:onEndAni()
	
end

function BasePopBox:showSmallLoading()
	if not self.loadingView or not tolua.cast(self.loadingView,"cc.Node") then
		self.loadingView = require "app.ui.popbox.SmallLoadingView".new()
		self.loadingView:setPosition(cc.p(0,0))
		self:addChild(self.loadingView,9999)
	else
		self.loadingView:show()
	end
end

function BasePopBox:hideSmallLoading()
	if self.loadingView and tolua.cast(self.loadingView,"cc.Node") then
		self.loadingView:setVisible(false)
	end
end

return BasePopBox