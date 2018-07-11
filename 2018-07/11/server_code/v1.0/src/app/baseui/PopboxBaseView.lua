------------------------
-- 非全屏弹出框
-- 全屏弹出框
-- node 父节点
-- 两个子节点 1个叫layer 一个叫main
------------------------
PopboxBaseView = class("PopboxBaseView",BaseView)
function PopboxBaseView:ctor()
 	self.loadingView = nil
end
function PopboxBaseView:initview(opacity,color)
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
function PopboxBaseView:onEndAni()
	
end

function PopboxBaseView:showSmallLoading()
	if not self.loadingView or not tolua.cast(self.loadingView,"cc.Node") then
		self.loadingView = require "app.ui.popbox.SmallLoadingView".new()
		self.loadingView:setPosition(cc.p(0,0))
		self:addChild(self.loadingView,9999)
	else
		self.loadingView:show()
	end
end

function PopboxBaseView:hideSmallLoading()
	if self.loadingView and tolua.cast(self.loadingView,"cc.Node") then
		self.loadingView:setVisible(false)
	end
end
-- 灯笼
function PopboxBaseView:dengLongAction()
	local lantern1 = self.widget:getChildByName("main"):getChildByName("lantern")
	local lantern2 = self.widget:getChildByName("main"):getChildByName("bg"):getChildByName("lantern")
	if not lantern1 and not lantern2 then
		return
	end
	local lantern = nil 
	if lantern1 then
		lantern = lantern1
	end
	if lantern2 then
		lantern = lantern2
	end
	local deng = ccui.ImageView:create("common/denglongguang.png",ccui.TextureResType.localType)
	lantern:addChild(deng)

	deng:setPosition(cc.p(lantern:getContentSize().width/2,lantern:getContentSize().height/2))
	deng:setOpacity(0)
	deng:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(0.8),cc.DelayTime:create(0.5),cc.FadeOut:create(0.8))))
end
return PopboxBaseView
