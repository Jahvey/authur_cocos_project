-------------------------------------------------
--   TODO   CustomerserviceView
--   @author adonai
--   Create Date 2018.07.18
-------------------------------------------------
local CustomerserviceView = class("CustomerserviceView",PopboxBaseView)

function CustomerserviceView:ctor(opentype,scene)
	self.scene = scene
	self:initData(opentype)
	self:initView()
	self:initEvent()
end

function CustomerserviceView:initData(opentype)

end


function CustomerserviceView:initView()
	self.widget = cc.CSLoader:createNode("ui/CustomerserviceView/msgView.csb")

	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)
	

end



function CustomerserviceView:initEvent()

end
return CustomerserviceView