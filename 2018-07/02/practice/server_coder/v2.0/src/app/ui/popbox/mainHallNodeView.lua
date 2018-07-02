require "app.baseui.PopboxBaseView"

local mainHallNodeView= class("mainHallNodeView",PopboxBaseView)
function mainHallNodeView:ctor()
	self:initView()
	--self:initEvent()
end

--在弹出的窗口中的layer层中，将layer层的交互性 的选项勾选上，防止下层的触摸响应事件穿透到上层的layer中
--调用的时候必须要用self.别名的方式来调用相应的组件，原因不明
--不能写成initview，会跟父类的方法名字重名，而导致重载
function mainHallNodeView:initView()
	self.widget = cc.CSLoader:createNode("myui/raward/award.csb")


	self.main_layer = self.widget:getChildByName("main")
    -- self.btn_exit = self.main_node:getChildByName("Button_Exit")
    -- WidgetUtils.addClickEvent(self.btn_exit, function()
    --      print("设置 award关闭按钮")

    --     LaypopManger_instance:back()

    -- end)

    self.btn_exit = self.main_layer:getChildByName("Button_Exit")

    self.btn_luckdraw = self.main_layer:getChildByName("Button_LuckDraw")

    self.text_num=self.btn_luckdraw:getChildByName("Text_num")

    self.btn_finish = self.main_layer:getChildByName("Button_finish")
    self.btn_share = self.main_layer:getChildByName("Button_share")

    self.btn_share = self.main_layer:getChildByName("Button_share")

    self.btn_detail = self.main_layer:getChildByName("Button_detail")

    
    self.count=1
    WidgetUtils.addClickEvent(self.btn_luckdraw, function ( )
        -- body
       
       if(self.count>3)
       then

       		 LaypopManger_instance:PopBox("luckDrawMsgNodeView")
       		 self.btn_luckdraw:setEnabled(false)

		else
 
   			print("抽奖"..(self.count).."次")
   			self.text_num:setString("剩"..(3-self.count).."次")

		end
		 self.count=self.count+1

    end)
    WidgetUtils.addClickEvent(self.btn_exit, function ( )
        -- body
        LaypopManger_instance:back()
        --main_layer:setVisible(false)

    end)



    
    WidgetUtils.addClickEvent(self.btn_detail, function( )
         print("设置 fangkaNodeView")
        LaypopManger_instance:PopBox("fangkaNodeView")

    end)


	self:addChild(self.widget)

end



function mainHallNodeView:initEvent()

end

return mainHallNodeView