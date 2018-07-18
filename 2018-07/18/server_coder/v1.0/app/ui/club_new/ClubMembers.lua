
-- EN_TeaBar_Date_Type_Today = 1;//今日
-- EN_TeaBar_Date_Type_Yesterday = 2;//昨日
-- EN_TeaBar_Date_Type_Week = 3;//本周
-- EN_TeaBar_Date_Type_Last_Week = 4;//上周
-- EN_TeaBar_Date_Type_Month = 5;//本月
-- EN_TeaBar_Date_Type_Last_Month = 6;//上月
local ClubMembers = class("ClubMembers",PopboxBaseView)

function ClubMembers:ctor(_parent)
	self.parent = _parent
	--self.ismy = false
	self:initView()
	self:initEvent()

end
function ClubMembers:initView()
	local widget = cc.CSLoader:createNode("ui/club/club_main/Club_members.csb")
	widget:addTo(self)

	self.mainLayer = widget:getChildByName("main")

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("exitclub"), function( )
		Socketapi.cs_request_apply_drop_tea_bar(self.tbid)
	end)
	
	self.cell = widget:getChildByName("cell")
	self.cell:setVisible(false)

	self.listView = self.mainLayer:getChildByName("listview")
	self.listView:setScrollBarEnabled(false)

	local  layout = ccui.Layout:create()
	layout:setAnchorPoint(cc.p(0,0))
	layout:setContentSize(cc.size(930,112))
	self.listView:setItemModel(layout)

	print("...........ClubMembers:initView()")
end


function ClubMembers:updataView(data)
	print("...........ClubMembers:updataView()")
	self.tbid = data.tbid
	self.parent:showSmallLoading()
	self.list1 = nil
	Socketapi.requestgetuserlistinfo(self.tbid,poker_common_pb.EN_TeaBar_Date_Type_Today)
end

function ClubMembers:cs_response_apply_drop_tea_bar( data )
	self.parent:hideSmallLoading()
	if data.result == 0 then
		LaypopManger_instance:backByName("OtherClubMembersclue")
	else
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end

function ClubMembers:getinfocallback( data )

	print("...........ClubMembers:getinfocallback()")
	-- printTable(data,"sjp3")
	
	if data.result == 0 then
		if self.list1 == nil then
			self.list1 = {}
		end
		for i,v in ipairs(data.users) do
			table.insert(self.list1,v)
		end
		if data.is_end then
			self.parent:hideSmallLoading()
			self.listView:removeAllItems()
			for k,v in pairs(self.list1) do
				-- print("......... k = ",k)
				if (k-1)%3 == 0 then
					self.listView:pushBackDefaultItem()
				end
	        	local item = self.listView:getItem((k-1)/3)
	        	
	        	local cell = self.cell:clone()
	        	cell:setVisible(true)
	        	cell:setPosition(cc.p((k-1)%3 * 305+8,-3))
	        	item:addChild(cell)

        		local icon = cell:getChildByName("icon")
        		local head = require("app.ui.common.HeadIcon_Club").new(icon, v.url,70)
	    		if head.headicon then
	    			head.headicon:setTouchEnabled(false)
	    		end
	    		cell:getChildByName("name"):setString(ComHelpFuc.GetShortName(v.name,18))
	    		cell:getChildByName("id"):setString("id:"..v.uid)
			end
		end
	else
		self.parent:hideSmallLoading()
	end
end

function ClubMembers:initEvent()
	--cs_response_statistics_table_record_list
	ComNoti_instance:addEventListener("cs_response_get_tea_bar_user_list",self,self.getinfocallback)
	ComNoti_instance:addEventListener("cs_response_apply_drop_tea_bar",self,self.cs_response_apply_drop_tea_bar)
end
return ClubMembers