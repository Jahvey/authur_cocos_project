require "app.baseui.PopboxBaseView"

local fangkaNodeView= class("fangkaNodeView",PopboxBaseView)
function fangkaNodeView:ctor()
	self:initView()
	--self:initEvent()
end

--在弹出的窗口中的layer层中，将layer层的交互性 的选项勾选上，防止下层的触摸响应事件穿透到上层的layer中
--调用的时候必须要用self.别名的方式来调用相应的组件，原因不明
--不能写成initview，会跟父类的方法名字重名，而导致重载
function fangkaNodeView:initView()
	self.widget = cc.CSLoader:createNode("myui/raward/fangka.csb")


	self.main_node = self.widget:getChildByName("main")
    self.btn_exit = self.main_node:getChildByName("Button_Exit")
    WidgetUtils.addClickEvent(self.btn_exit, function()
         print("设置 fangka关闭按钮")

        LaypopManger_instance:back()

    end)


	self:addChild(self.widget)

end



function fangkaNodeView:initEvent()

end

return fangkaNodeView