------------------------------
-- 显示ip 距离
-- yc 
--- 2016/11/7
------------------------------
local DistanceView = class("DistanceView",PopboxBaseView)
function DistanceView:ctor(data)
	print(data)
	self:initData(data)
	self:initView()
	self:initEvent()
end

function DistanceView:initView()
	self.widget = cc.CSLoader:createNode("ui/popbox/distanceView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closebtn"), function( )
		LaypopManger_instance:back()
	end)

	self.listView = self.mainLayer:getChildByName("listView")
	local item = self.listView:getChildByName("item")
	item:retain()
    self.listView:setItemModel(item)
    item:removeFromParent()
    item:release()
    self.listView:removeAllItems()

    self:createListView()
end
function DistanceView:initData(data)
	self.infolist = {}
	for i,v in ipairs(data) do
		if v.user then
			if v.user.uid ~= LocalData_instance.uid then
				table.insert(self.infolist,v.user)
			end
		end
	end
	self.distanceLabelList = {}
	self.isrequest = false
	print("DistanceView:initData------------------")
	print(self.infolist, "")
	if #self.infolist >= 2 then
		self.isrequest = true
	end
end

function DistanceView:initEvent()
	-- 只有 2个人以上才请求
	if self.isrequest then
		ComHttp.httpPOST(ComHttp.URL.GETOTHERCOORDINATE,{uid1 = self.infolist[1].uid,uid2 = self.infolist[2].uid,uid3 = (self.infolist[3] and self.infolist[3].uid) or "",},function(msg) 
			if not WidgetUtils:nodeIsExist(self) then
				return
			end
			self:setDistance(msg)
			print(msg, "")
		end)	
	end

end
function DistanceView:createListView()
	local cnt = #self.infolist
	if cnt == 2 then
		cnt = 1
	end
	for i=1,cnt do
		self.listView:pushBackDefaultItem()
        local item = self.listView:getItem(i-1)

        local name1 = item:getChildByName("name1")
        local name2 = item:getChildByName("name2")
        local ip1 = item:getChildByName("ip1")
        local ip2 = item:getChildByName("ip2")
        local distance = item:getChildByName("distance")
        local headicon1 = item:getChildByName("headicon1"):setScale(50/88)
        local headicon2 = item:getChildByName("headicon2"):setScale(50/88)
        local headbg1 = item:getChildByName("headbg1")
        local headbg2 = item:getChildByName("headbg2")
        local tipLabel = item:getChildByName("tipLabel"):setVisible(false) -- ip相同
        headicon1:setPosition(headbg1:getPosition())
        headicon2:setPosition(headbg2:getPosition())
        local info1  = self.infolist[i]
        local info2  = self.infolist[i+1]
        if cnt > 1 then
        	if info1 and not info2 then
        		info2 = self.infolist[1]
        	end
        end	
        require("app.ui.common.HeadIcon").new(headicon1,info1.role_picture_url)
      	name1:setString(info1.nick)
      	ip1:setString("IP:"..CommonUtils.getIpStr(info1.last_login_ip))
      	distance.uid1 = info1.uid
      	if info2 then
        	name2:setString(info2.nick)
        	ip2:setString("IP:"..CommonUtils.getIpStr(info2.last_login_ip))
        	distance.uid2 = info2.uid
        	require("app.ui.common.HeadIcon").new(headicon2,info2.role_picture_url)

        	if info2.last_login_ip == info1.last_login_ip then
        		tipLabel:setVisible(true)
        	end
        else
        	name2:setString("")
        	ip2:setString("")
        	name1:setPositionY(item:getContentSize().height/2)
        	ip1:setPositionY(item:getContentSize().height/2)
        	headbg1:setPositionY(item:getContentSize().height/2)
        	headicon1:setPositionY(item:getContentSize().height/2)
        	headicon2:setVisible(false)
			headbg2:setVisible(false)
        end	
        if not self.isrequest then
        	distance:setString("未知")
        else
          	CommonUtils.tipAction(distance,"正在获取")
        	table.insert(self.distanceLabelList,distance)	
        end
	end
end

function DistanceView:setDistance(msg)
	for i,v in ipairs(msg.list) do
		for m,vv in ipairs(self.distanceLabelList) do
			if (tonumber(v.a) == vv.uid1 and tonumber(v.b) == vv.uid2) or (tonumber(v.b) == vv.uid1 and tonumber(v.a) == vv.uid2) then
				vv:stopAllActions()
				vv:setString(CommonUtils.getDistanceStr(v.distance))
				break
			end
		end
	end
end
return DistanceView