-------------------------------------------------
--   TODO   消息UI
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local AddView = class("AddView",PopboxBaseView)
function AddView:ctor(data,headnode,typ)
	self.headnode = headnode
	self.data = data
	self.num = 1
	self:initView(typ)
end
function AddView:initView(typ)
	if typ then
		self.widget = cc.CSLoader:createNode("newyear/AddView2.csb")
	else
		self.widget = cc.CSLoader:createNode("newyear/AddView.csb")
	end
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("btnjian"), function( )
		self.num = self.num -1 
		self:updatanum()
	end)

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("btnadd"), function( )
		self.num = self.num + 1
		self:updatanum()
	end)


	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("close"), function( )
		LaypopManger_instance:back()
	end)

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("sure"), function( )
		
		self:showSmallLoading()
		if typ then
			ComHttp.httpPOST(ComHttp.URL.YEARCONFIG64,{uid= LocalData_instance.uid,num = self.num,pid = self.data.id or ""},function(msg) 
				printTable(msg,"xp")
				self.headnode:getdata(6)
		       	if msg.status == 1 then
		       		LaypopManger_instance:back()
		       		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "参加活动成功"})
		       	else
		       		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = msg.str})
		       	end
		    end)
		else
			ComHttp.httpPOST(ComHttp.URL.YEARCONFIG61,{uid= LocalData_instance.uid,num = self.num},function(msg) 
				printTable(msg,"xp")
				self.headnode:getdata(6)
		       	if msg.status == 1 then
		       		LaypopManger_instance:back()
		       		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "参加活动成功"})
		       	else
		       		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = msg.str})
		       	end
		    end)
		end
	end)


	self.mainLayer:getChildByName("pic0"):setVisible(false)
	self.mainLayer:getChildByName("pic1"):setVisible(false)
	self.mainLayer:getChildByName("pic"..self.data.itemtype):setVisible(true)
	self.mainLayer:getChildByName("title1"):setString(self.data.title)
	self.mainLayer:getChildByName("title2"):setString(self.data.content)
	if self.data.count then
		if self.data.target and self.data.target > 0 then 
			self.mainLayer:getChildByName("title3"):setString("已有"..self.data.count.."人次参加,至少"..self.data.target.."次开奖")
		else
			self.mainLayer:getChildByName("title3"):setString("已有"..self.data.count.."人次参加")
		end
	end
	local function updatatime( )
		local losttime = self.data.time - os.time()
		local daytitle = self.mainLayer:getChildByName("open"):getChildByName("day")
		local hourtitle = self.mainLayer:getChildByName("open"):getChildByName("hour")
		local mintitle = self.mainLayer:getChildByName("open"):getChildByName("min")
		if losttime <= 0 then
			daytitle:setString("0")
			hourtitle:setString("0")
			mintitle:setString("0")
		else
			local day = math.floor(losttime/(3600*24))
			if day < 10 then
				daytitle:setString("0"..day)
			else
				daytitle:setString(day)
			end
			losttime = losttime%(3600*24)
			local hour = math.floor(losttime/3600)
			if hour < 10 then
				hourtitle:setString("0"..hour)
			else
				hourtitle:setString(hour)
			end
			losttime = losttime%3600
			local min = math.ceil(losttime/60)
			if min < 10 then
				mintitle:setString("0"..min)
			else
				mintitle:setString(min)
			end
		end
	end
	
	updatatime()
	self.mainLayer:stopAllActions()
	self.mainLayer:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( ... )
		updatatime()
	end))))

	self:updatanum()

end
function AddView:updatanum()
	if self.num < 1 then
		self.num =  1
	end
	self.mainLayer:getChildByName("mid"):getChildByName("num"):setString(self.num)
	self.mainLayer:getChildByName("sure"):getChildByName("num"):setString(self.num*self.data.price)
end
return AddView