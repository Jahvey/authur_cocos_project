------------------------------
-- 显示ip 距离
-- yc 
--- 2016/11/7
------------------------------
local DistanceView = class("DistanceView",PopboxBaseView)
function DistanceView:ctor(scene)
	printTable(data)

	if device.platform == "ios" and SHENHEBAO then
        luaoc.callStaticMethod("RootViewController","ShowGPS")
        luaoc.callStaticMethod("RootViewController","startGPS")
        ComHttp.reportPos()
    end
    
	self:initData(scene)
	self:initView()
	self:initEvent()
end

function DistanceView:initData(scene)
	self.gameScene = scene
	self.infolist = {}
	self.tipLabelTb = {}
	local ret = nil
	for i,v in ipairs(self.gameScene:getSeatsInfo()) do
		if v.user then
			if self.gameScene:getTableConf().seat_num < 4 then
				table.insert(self.infolist,v.user)
			else
				-- if self.gameModel:getDealer() == v.index then
				-- 	seatid = 1
				-- elseif self.gameModel:getDiJiaIndex() == v.index  then
				-- 	seatid = 3
				-- elseif not ret then		
				-- 	seatid = 2
				-- 	ret = v.index
				-- else 
				-- 	seatid = 4	
				-- end
				self.infolist[i] = v.user
			end	
		end
	end
	self.distanceLabelList = {}
	self.isrequest = false
	print("DistanceView:initData------------------")
	printTable(self.infolist, "")
	if #self.infolist >= 2 then
		self.isrequest = true
	end
end

function DistanceView:initView()
	self.widget = cc.CSLoader:createNode("ui/distance/distanceView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("closebtn"), function( )
		LaypopManger_instance:back()
	end)

	self.siren = self.mainLayer:getChildByName("siren"):setVisible(false)
	self.sanren = self.mainLayer:getChildByName("sanren"):setVisible(false)

   	if self.gameScene:getTableConf().seat_num == 4 then
   		self.siren:setVisible(true)
   		for i=1,6 do
   			local tip = self.siren:getChildByName("tip"..i):setString("")
   			table.insert(self.tipLabelTb,tip)
   		end
   		self:showSiRen()
   		self:showUserInfo(1)
   	else
   		self.sanren:setVisible(true)
   		for i=1,3 do
   			local tip = self.sanren:getChildByName("tip"..i):setString("")
   			table.insert(self.tipLabelTb,tip)
   		end
   		self:showSanRen()
   		self:showUserInfo(2)
   	end
   
end
function DistanceView:showSiRen()
	if #self.infolist == 1 then
		for i,v in ipairs(self.tipLabelTb) do
			v:setString("")
		end
	elseif #self.infolist == 2 then
		for i,v in ipairs(self.tipLabelTb) do
			if i == 1 then
			   CommonUtils.tipAction(v,"正在获取")
			end 
		end
	elseif #self.infolist == 3 then
		for i,v in ipairs(self.tipLabelTb) do
			if i == 1 or i == 2 or i==5 then
			   CommonUtils.tipAction(v,"正在获取")
			end 
		end
	elseif #self.infolist == 4 then	
		for i,v in ipairs(self.tipLabelTb) do
			CommonUtils.tipAction(v,"正在获取")
		end
	end 
	
end
function DistanceView:showSanRen()
	if #self.infolist == 1 then
		for i,v in ipairs(self.tipLabelTb) do
			v:setString("")
		end
	elseif #self.infolist == 2 then
		for i,v in ipairs(self.tipLabelTb) do
			if i == 1 then
			   CommonUtils.tipAction(v,"正在获取")
			end 
		end
	elseif #self.infolist == 3 then	
		for i,v in ipairs(self.tipLabelTb) do
			if i == 1 then
			   CommonUtils.tipAction(v,"正在获取")
			end 
		end
		
	end 
end
function DistanceView:showUserInfo(type)
	local ret = nil
	for i,v in ipairs(self.gameScene:getSeatsInfo()) do
		local headnode 
		if type == 1 then
			-- if not self.gameScene.gameIsStart then
				seatid = i
			-- else	
			-- 	if self.gameModel:getDealer() == v.index then
			-- 		seatid = 1
			-- 	elseif self.gameModel:getDiJiaIndex() == v.index  then
			-- 		seatid = 3
			-- 	elseif not ret then		
			-- 		seatid = 2
			-- 		ret = v.index
			-- 	else 
			-- 		seatid = 4	
			-- 	end
			-- end	
	
			headnode = self.siren:getChildByName("headnode"..seatid)		
		elseif type == 2 then
			headnode = self.sanren:getChildByName("headnode"..i)
		end	
		local headbg = headnode:getChildByName("headbg")
		local headicon = headnode:getChildByName("headicon")
		local name = headnode:getChildByName("name")
		local ip = headnode:getChildByName("ip")
		local kong = headnode:getChildByName("kong")
		if v.user then
			kong:setVisible(false)
			require("app.ui.common.HeadIcon").new(headicon,v.user.role_picture_url)
			headicon:setScale(86/90)
      		name:setString(v.user.nick)
      		ip:setString("IP:"..CommonUtils.getIpStr(v.user.last_login_ip))
      	else
      		headbg:setVisible(false)
      		headicon:setVisible(false)
      		name:setVisible(false)
      		ip:setVisible(false)
      		kong:setVisible(true)	
      	end	
	end	
end


function DistanceView:initEvent()
	-- 只有 2个人以上才请求
	if self.isrequest then
		local uid_1,uid_2,uid_3,uid_4

		if self.infolist[1] then
			uid_1 = self.infolist[1].uid
		end

		if self.infolist[2] then
			uid_2 = self.infolist[2].uid
		end

		if self.infolist[3] then
			uid_3 = self.infolist[3].uid
		end

		if self.infolist[4] then
			uid_4 = self.infolist[4].uid
		end



		ComHttp.httpPOST(ComHttp.URL.GETOTHERCOORDINATE,{uid1 = uid_1,uid2 = uid_2,uid3 = uid_3,uid4 = uid_4 },function(msg) 
			if not WidgetUtils:nodeIsExist(self) then
				return
			end
			printTable(msg, "")
			self:setDistance(msg)
			
		end)	
	end

end
-- 1-(1,2) 2-(2,3) 3-(1,3) 4-(1,4) 5(2,4) 6(3,4)
function DistanceView:setDistance(msg)
	for i,v in ipairs(self.tipLabelTb) do
		v:stopAllActions()
		v:setAnchorPoint(cc.p(0.5,0.5))
	end
	if self.gameScene:getTableConf().seat_num == 4 then
		for i,v in ipairs(msg.list) do
			if i == 1 then
				self.tipLabelTb[1]:setString(CommonUtils.getDistanceStr(v.distance))
			end
			if i == 2 then
				self.tipLabelTb[2]:setString(CommonUtils.getDistanceStr(v.distance))
			end
			if i == 3 then
				self.tipLabelTb[5]:setString(CommonUtils.getDistanceStr(v.distance))
			end
			if i == 4 then
				self.tipLabelTb[4]:setString(CommonUtils.getDistanceStr(v.distance))
			end
			if i == 5 then
				self.tipLabelTb[6]:setString(CommonUtils.getDistanceStr(v.distance))
			end
			if i == 6 then
				self.tipLabelTb[3]:setString(CommonUtils.getDistanceStr(v.distance))
			end
		end
	else
		for i,v in ipairs(msg.list) do
			if i == 1 then
				self.tipLabelTb[1]:setString(CommonUtils.getDistanceStr(v.distance))
			end
			if i == 2 then
				self.tipLabelTb[2]:setString(CommonUtils.getDistanceStr(v.distance))
			end
			if i == 3 then
				self.tipLabelTb[3]:setString(CommonUtils.getDistanceStr(v.distance))
			end
		end
	end		
end
return DistanceView