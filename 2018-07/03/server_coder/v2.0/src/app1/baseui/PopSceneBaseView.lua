------------------------
-- 全屏弹出框
-- node 父节点
-- 两个子节点 1个叫bg 一个叫main
------------------------
PopSceneBaseView = class("PopSceneBaseView",BaseView)
function PopSceneBaseView:ctor()
 
end
function PopSceneBaseView:initview()
	if self.widget then
		WidgetUtils.setBgScale(self.widget:getChildByName("bg"))
		WidgetUtils.setScalepos(self.widget:getChildByName("main"))
		-- self.widget:getChildByName("main"):setPosition(display.cx,display.cy)

		WidgetUtils.addLayerAnimation(self.widget:getChildByName("main"):getChildByName("bg"),function() 
	 		self:onEndAni()
	 	end)
	end	
end
function PopSceneBaseView:onEndAni()

end
return PopSceneBaseView