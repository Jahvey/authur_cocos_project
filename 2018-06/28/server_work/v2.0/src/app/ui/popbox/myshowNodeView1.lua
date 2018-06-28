require "app.baseui.PopboxBaseView"

local myshowNodeView= class("myshowNodeView1",PopboxBaseView)
function myshowNodeView:ctor()
	self:initView()
	self:initEvent()
end

--不能写成initview，会跟父类的方法名字重名，而导致重载
function myshowNodeView:initView()
	self.widget = cc.CSLoader:createNode("myui/test/Node.csb")


	self.main_node = self.widget:getChildByName("main")
    self.btn1 = self.main_node:getChildByName("cancel")
    WidgetUtils.addClickEvent(self.btn1, function()
         print("设置 关闭按钮")
         --LaypopManger_instance:PopBox("myshowView1")
        --LaypopManger_instance:PopBox("myshowNodeView1")
        --widget:setVisible(false)
        LaypopManger_instance:back()

    end)


	self:addChild(self.widget)

end



function myshowNodeView:initEvent()

end

return myshowNodeView