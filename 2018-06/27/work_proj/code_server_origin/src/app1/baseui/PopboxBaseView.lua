------------------------
-- 非全屏弹出框
-- 全屏弹出框
-- node 父节点
-- 两个子节点 1个叫layer 一个叫main
------------------------
PopboxBaseView = class("PopboxBaseView",BaseView)
function PopboxBaseView:ctor()
 	
end
function PopboxBaseView:initview()
	self:setPosition(cc.p(display.width/2,display.height/2))
	 if self.widget and self.widget:getChildByName("layer") then
	 	-- self.widget:setVisible(false)
	 	WidgetUtils.addLayerAnimation(self.widget:getChildByName("main"),function() 
	 		self:onEndAni()
	 	end)
        --ccui.Layout:setBackGroundColor(ccui.LayoutBackGroundColorType.solid)
        self.widget:getChildByName("layer"):setBackGroundColor(cc.c3b(0,0,0))
        self.widget:getChildByName("layer"):setBackGroundColorOpacity(math.floor((num or 60)/100*255))
        self.widget:getChildByName("layer"):setContentSize(cc.size(display.width*2,display.height*2))
        self.widget:getChildByName("layer"):setPosition(cc.p(-display.cx,-display.cy))
    end
end
function PopboxBaseView:onEndAni()

end
return PopboxBaseView
