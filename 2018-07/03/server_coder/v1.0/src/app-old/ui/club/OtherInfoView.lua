
-- EN_TeaBar_Date_Type_Today = 1;//今日
-- EN_TeaBar_Date_Type_Yesterday = 2;//昨日
-- EN_TeaBar_Date_Type_Week = 3;//本周
-- EN_TeaBar_Date_Type_Last_Week = 4;//上周
-- EN_TeaBar_Date_Type_Month = 5;//本月
-- EN_TeaBar_Date_Type_Last_Month = 6;//上月
local InfoView = class("InfoView",PopboxBaseView)

function InfoView:ctor(data)
	self.data = data
	--self.ismy = false
	self:initView()
	self:initEvent()
	
end
function InfoView:initView()
	local widget = cc.CSLoader:createNode("ui/club/info/Roleinfo.csb")
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")

	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		
		LaypopManger_instance:back()
	end)

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("exitclub"), function( )
		
		Socketapi.cs_request_apply_drop_tea_bar(self.data.tbid)
	end)
	
	self.cell = self.mainLayer:getChildByName("cell")
	self.cell:setVisible(false)
	self.listview = self.mainLayer:getChildByName("listview")

	self.listviewdelegale1 = require "app.help.MylistView".new(self.listview,self.cell:getContentSize())
 	self.listviewdelegale1:setTotall(0,true)
 	self.listviewdelegale1:setModelcell(self.cell)
 	self.listviewdelegale1:setcellAtindex(function(cell,idx)
 		self:updatacell(cell,idx)
 	end)

	self:hideSmallLoading()

end
function InfoView:updatacell( cell,i)
	print("updata cell")
	local v = self.listlocal1[i]
    cell:setVisible(true)
    for j=1,3 do
    	local node = cell:getChildByName("iconbg"..j)
    	local data = self.listlocal1[(i-1)*3+j]
    	if data then
    		node:setVisible(true)
    		local icon = node:getChildByName("icon")
    		icon:setLocalZOrder(-1)

    		local head  =require("app.ui.common.HeadIcon_Club").new(icon,data.url)
    		--icon:setEnabled(false)
    		if head.headicon then
    			head.headicon:setTouchEnabled(false)
    		end
    		node:getChildByName("name"):setString(ComHelpFuc.getStrWithLength(data.name))
    		node:getChildByName("id"):setString("id:"..data.uid)
    	else
    		node:setVisible(false)
    	end
    end
end
function InfoView:onEndAni()
	self:showSmallLoading()
	Socketapi.requestgetuserlistinfo(self.data.tbid,poker_common_pb.EN_TeaBar_Date_Type_Today)
end
function InfoView:cs_response_apply_drop_tea_bar( data )
	--self:hideSmallLoading()
	if data.result == 0 then
		LaypopManger_instance:backByName("OtherInfoViewclue")
	else
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end
end
function InfoView:initEvent()
	--cs_response_statistics_table_record_list
	ComNoti_instance:addEventListener("cs_response_get_tea_bar_user_list",self,self.getinfocallback)
	ComNoti_instance:addEventListener("cs_response_apply_drop_tea_bar",self,self.cs_response_apply_drop_tea_bar)
end
function InfoView:updataview()
	self.listviewdelegale1:updataView(true)
end
function InfoView:getinfocallback( data )
	printTable(data,"sjp3")
	
	--self:updataviewconf(data)
	if data.result ==0 then
		--self:updataviewconf( data )
		if self.list1 == nil then
			self.list1 = {}
		end
		for i,v in ipairs(data.users) do
			table.insert(self.list1,v)
		end
		if data.is_end then
			self.listlocal1  = self.list1
			-- for i=1,100 do
			-- 	self.listlocal1[i+4] = self.listlocal1[4]
			-- end
			print("totall:"..math.ceil(#self.listlocal1/3))
			self.listviewdelegale1:setTotall(math.ceil(#self.listlocal1/3),true)

			self:updataview(true)
			self:hideSmallLoading()
		end
	end
end
return InfoView