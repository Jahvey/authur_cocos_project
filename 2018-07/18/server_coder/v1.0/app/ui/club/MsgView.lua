local MsgView = class("MsgView",PopboxBaseView)

function MsgView:ctor(tid)
	self.tid = tid
	self:initView()
	self:initEvent()
	
end
function MsgView:initView()
	local widget = cc.CSLoader:createNode("ui/club/msg/MsgView.csb")
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")

	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		
		LaypopManger_instance:back()
	end)
	Socketapi.requestmsgclube(self.tid)
	self.cell1 = self.widget:getChildByName("cell1")
	self.cell1:setVisible(false)
	self.cell2 = self.widget:getChildByName("cell2")
	self.cell2:setVisible(false)
	self.listview = self.mainLayer:getChildByName("listview")

	local  layout = ccui.Layout:create()
	layout:setAnchorPoint(cc.p(0,0))
	layout:setContentSize(self.cell1:getContentSize())

	self.listview:setItemModel(layout)
	self:showSmallLoading()

end

function MsgView:msgcallback( data )
	self.listview:removeAllItems()
	self:hideSmallLoading()
	if data.result == 0 then
		if data.msg_list and #data.msg_list > 0 then
			for i,v in ipairs(data.msg_list) do
				self.listview:pushBackDefaultItem()
	        	local item = self.listview:getItem(i-1)
	        	if v.msg_type == 1 then
		        	local cell = self.cell1:clone()
		        	cell:setVisible(true)
		        	cell:setPosition(cc.p(0,0))
		        	item:addChild(cell)
		        	local icon = cell:getChildByName("icon")
		        	local info = cell:getChildByName("info")
		        	local time = cell:getChildByName("time")

		        	local datetab = os.date("*t", v.apply_join_msg.user.apply_time)
			       	local str = string.format("%d-%02d-%02d %02d:%02d:%02d",datetab.year,datetab.month,datetab.day,datetab.hour,datetab.min,datetab.sec)
			        time:setString(str)
			        require("app.ui.common.HeadIcon_Club").new(icon,v.apply_join_msg.user.url)
			        info:setString("玩家  "..v.apply_join_msg.user.name.."  申请加入亲友圈")

			        WidgetUtils.addClickEvent(cell:getChildByName("accept"), function( )
						--self.listview:removeItem(i-1)
						
						 Socketapi.requestmsgselect(true,data.tbid,v.apply_join_msg.user.uid)
						 self:showSmallLoading()
					end)

			        WidgetUtils.addClickEvent(cell:getChildByName("rejust"), function( )
						--self.listview:removeItem(i-1)
						
						 Socketapi.requestmsgselect(false,data.tbid,v.apply_join_msg.user.uid)
						 self:showSmallLoading()
					end)
		        end
			end
		else
			ComNoti_instance:dispatchEvent("cleanupmsg",self.tid)
		end
	else
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end

function MsgView:surecallback(data )
	

	self:hideSmallLoading()
	if data.result == 0 then
		self:showSmallLoading()
		Socketapi.requestmsgclube(self.tid)
	else
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end



end
function MsgView:initEvent()
	ComNoti_instance:addEventListener("cs_response_tea_bar_message",self,self.msgcallback)
	ComNoti_instance:addEventListener("cs_response_agree_user_join_tea_bar",self,self.surecallback)
end
return MsgView