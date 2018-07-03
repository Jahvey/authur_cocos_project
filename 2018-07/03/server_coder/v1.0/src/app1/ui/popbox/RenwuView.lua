-------------------------------------------------
--   TODO   帮助UI
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local HelpView = class("HelpView",PopboxBaseView)
function HelpView:ctor()
	self:initView()
	self:initEvent()
	Socketapi.renwu()
end
function HelpView:zhancall(data)

	if data.result == 0 then
		 Notinode_instance:showLoading(false)
		print("弹框")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info,sureCallFunc = function()
		end})
		return
	end
	for i,v in ipairs(data.tasklist) do
			self.listView:pushBackDefaultItem()
	        local item = self.listView:getItem(i-1)
	        item:getChildByName("num"):setString("x"..v.rewardroomcardnums)
	        item:getChildByName("di"):setString(v.taskname)
	        item:getChildByName("di_0"):setString(v.curnums.."/"..v.totalnums)
	        item:getChildByName("pro"):setPercent(v.curnums/v.totalnums*100)
	end
end
function HelpView:initView()
	self.widget = cc.CSLoader:createNode("ui/renwu/helpView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closeBtn"), function( )
		print("返回大厅")
		LaypopManger_instance:back()
	end)
	self.listView = self.mainLayer:getChildByName("listview")
	local item = self.mainLayer:getChildByName("cell")
	item:retain()
	self.listView:setItemModel(item)
	item:removeFromParent()
	item:release()

end


function HelpView:initEvent()
	ComNoti_instance:addEventListener("3;2;4;1",self,self.zhancall)
end
return HelpView