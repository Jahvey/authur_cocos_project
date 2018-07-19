-------------------------------------------------
--   TODO   玩家详情UI
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local PlayInfoViewforgame = class("PlayInfoViewforgame",PopboxBaseView)
--- data 为真 查看别个
function PlayInfoViewforgame:ctor(data)
	self:initData(data)
	self:initView()
	self:initEvent()
end

function PlayInfoViewforgame:initData(data)
	self.data = data
end

function PlayInfoViewforgame:initView()
	self.widget = cc.CSLoader:createNode("ui/playerinfo/playInfoViewforgame.csb")
	self:addChild(self.widget)

	self.layer = self.widget:getChildByName("layer")
	WidgetUtils.addClickEvent(self.layer, function( )
		LaypopManger_instance:back()
	end)

	self.mainLayer = self.widget:getChildByName("main")
	-- 头像
	self.headicon = self.mainLayer:getChildByName("headicon")
	self.headImg = self.mainLayer:getChildByName("headImg")
	-- 女性
	self.maleIcon = self.mainLayer:getChildByName("maleIcon"):setVisible(false)
	-- 男性
	self.femaleIcon = self.mainLayer:getChildByName("femaleIcon"):setVisible(false)
	-- 名字
	self.nameLabel = self.mainLayer:getChildByName("nameLabel")
	-- IP
	self.IPLabel = self.mainLayer:getChildByName("IPLabel")
	-- ID
	self.IDLabel = self.mainLayer:getChildByName("IDLabel")

	self.distanceLabel = self.mainLayer:getChildByName("distanceLabel"):setVisible(false)
	-- 距离
	-- self.distance = self.distanceLabel:getChildByName("distance")

	-- self.surebtn = self.mainLayer:getChildByName("surebtn")
	-- WidgetUtils.addClickEvent(self.surebtn, function( )
	-- 	LaypopManger_instance:back()
	-- end)


	self.cell = self.mainLayer:getChildByName("bottombg"):getChildByName("cell")
	
	self.listview = self.mainLayer:getChildByName("bottombg"):getChildByName("listview")

	self.listview:setItemModel(self.cell)
	print("-----------------dsf")
	for i=1,6 do
		self.listview:pushBackDefaultItem()
		local item = self.listview:getItem(i-1)
		item:getChildByName("Image"):loadTexture("game/hudong/card"..i..".png",ccui.TextureResType.localType)
		item:getChildByName("Image"):setContentSize(cc.size(125,125))
		local btn = item:getChildByName("btn")
		if self.data.uid == LocalData_instance:getUid() then
			print("isself")
			btn:setColor(cc.c3b(127, 127, 127))
			item:getChildByName("Image"):setColor(cc.c3b(127, 127, 127))
			btn:setEnabled(false)
		end

		WidgetUtils.addClickEvent(btn, function( )
			Socketapi.sendChat(1,tostring(self.data.uid),i,3)
			LaypopManger_instance:back()
		end)
	end
	self.cell:setVisible(false)

	if self.data then
		self.nameLabel:setString(self.data.nick)
		self.IDLabel:setString("ID："..self.data.uid)
		self.IPLabel:setString("IP: "..(CommonUtils.getIpStr(self.data.last_login_ip)))
		-- 男
		if self.data.gender == 0 or self.data.gender == 2 then
			self.maleIcon:setVisible(true)
		elseif self.data.gender == 1 then
			self.femaleIcon:setVisible(true)	
		end
		local equips = {}
		if self.data.items_info and self.data.items_info ~= "" then
			equips = cjson.decode(self.data.items_info)
		end

		local headframe = require("app.ui.bag.RoomEquip").getHeadFrame(equips)

		if headframe then
			self.headImg:setVisible(false)
		else
			self.headImg:setVisible(true)
		end

		local _headicon = require("app.ui.common.HeadIcon").new(self.headicon,self.data.role_picture_url,nil,headframe).headicon
	  	local size =  _headicon:getContentSize()
        _headicon:setScaleX(90/size.width)
        _headicon:setScaleY(90/size.height)

		if self.data.uid == LocalData_instance:getUid() then
			return
		end

		self.distanceLabel:setVisible(true)
		CommonUtils.tipAction(self.distanceLabel,"正在获取")

		ComHttp.httpPOST(ComHttp.URL.GETONE_COORDINATE,{uid = LocalData_instance:getUid(),player = self.data.uid},function(msg) 
			if not WidgetUtils:nodeIsExist(self) then
				return
			end
			self.distanceLabel:stopAllActions()
			local str = CommonUtils.getDistanceStr(msg.distance)
			if str == "未知" then
				str = "相距：未知"
			end
			self.distanceLabel:setString(str)
		end)	
	else
		self.nameLabel:setString(LocalData_instance:getNick() or "")
		self.IDLabel:setString("ID："..(LocalData_instance:getUid() or ""))
		self.IPLabel:setString("IP: "..(LocalData_instance:getLoginIp() or ""))
		-- 男
		if LocalData_instance:getSex() == 0 or LocalData_instance:getSex() == 2 then
			self.maleIcon:setVisible(true)
		elseif LocalData_instance:getSex() == 1 then
			self.femaleIcon:setVisible(true)
		end
		local equips = {}
		if LocalData_instance:get("items_info") and LocalData_instance:get("items_info") ~= "" then
			equips = cjson.decode(LocalData_instance:get("items_info"))
		end

		local headframe = require("app.ui.bag.RoomEquip").getHeadFrame(equips)

		if headframe then
			self.headImg:setVisible(false)
		else
			self.headImg:setVisible(true)
		end

		local _headicon  = require("app.ui.common.HeadIcon").new(self.headicon,LocalData_instance:getPic(),nil,headframe).headicon
	  	local size =  _headicon:getContentSize()
        _headicon:setScaleX(90/size.width)
        _headicon:setScaleY(90/size.height)
	end	

end

function PlayInfoViewforgame:initEvent()

end
return PlayInfoViewforgame