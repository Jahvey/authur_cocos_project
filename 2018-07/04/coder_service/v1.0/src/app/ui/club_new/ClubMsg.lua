local ClubMsg = class("ClubMsg",PopboxBaseView)

function ClubMsg:ctor(_parent)
	self.parent = _parent
	self:initView()
	self:initEvent()
	
end
function ClubMsg:initView()
	local widget = cc.CSLoader:createNode("ui/club/club_main/Club_msg.csb")
	widget:addTo(self)
	self.mainLayer = widget:getChildByName("main")

	self.cell1 = widget:getChildByName("cell1")
	self.cell1:setVisible(false)
	self.cell2 = widget:getChildByName("cell2")
	self.cell2:setVisible(false)
	self.listview = self.mainLayer:getChildByName("listview")

	local  layout = ccui.Layout:create()
	layout:setAnchorPoint(cc.p(0,0))
	layout:setContentSize(self.cell1:getContentSize())

	self.listview:setItemModel(layout)

	self.tips = self.mainLayer:getChildByName("bg_2"):getChildByName("tips"):setVisible(false)

end


function ClubMsg:updataView(data)

	-- print("......ClubMsg:updataView tbid =",tbid)
	self.tbid = data.tbid
	Socketapi.requestmsgclube(self.tbid)
	self.parent:showSmallLoading()

end

function ClubMsg:msgcallback( data )

	print("......ClubMsg:msgcallback( data ) =",self.tbid)
	printTable(data,"xp")
	
	self.listview:removeAllItems()

	self.parent:hideSmallLoading()
	if data.result == 0 then
		if data.msg_list and #data.msg_list > 0 then
			self.tips:setVisible(false)
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
			        info:setString("玩家  "..v.apply_join_msg.user.name.."  申请加入茶馆")

			        WidgetUtils.addClickEvent(cell:getChildByName("accept"), function( )
						 Socketapi.requestmsgselect(true,data.tbid,v.apply_join_msg.user.uid)
						 self.parent:showSmallLoading()
					end)

			        WidgetUtils.addClickEvent(cell:getChildByName("rejust"), function( )
						 Socketapi.requestmsgselect(false,data.tbid,v.apply_join_msg.user.uid)
						 self.parent:showSmallLoading()
					end)
			    -- else
			    -- 	local cell = self.cell2:clone()
		     --    	cell:setVisible(true)
		     --    	cell:setPosition(cc.p(0,0))
		     --    	item:addChild(cell)
		     --    	local info = cell:getChildByName("info")
			    --     info:setString("你成功加入“"..v.apply_join_msg.user.name.."”茶馆，去和牌友们打个招呼吧!")
		        end
			end
		else
			self.tips:setVisible(true)
			ComNoti_instance:dispatchEvent("cleanupmsg",self.tbid)
		end
	else
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end

function ClubMsg:surecallback(data )
	
	self.parent:hideSmallLoading()
	if data.result == 0 then
		self.parent:showSmallLoading()
		Socketapi.requestmsgclube(self.tbid)
	else
		LaypopManger_instance:backByName("PromptBoxView")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
function ClubMsg:initEvent()
	ComNoti_instance:addEventListener("cs_response_tea_bar_message",self,self.msgcallback)
	ComNoti_instance:addEventListener("cs_response_agree_user_join_tea_bar",self,self.surecallback)
end
return ClubMsg