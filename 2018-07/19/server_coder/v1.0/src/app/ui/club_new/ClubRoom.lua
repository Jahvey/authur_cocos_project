----------------------------
-- 
----------------------------
local ClubRoom = class("ClubRoom",PopboxBaseView)

function ClubRoom:ctor(_parent)
	self.parent = _parent
	self:initView()
end

function ClubRoom:initView()
	local widget = cc.CSLoader:createNode("ui/club/club_main/Club_room.csb")
	widget:setAnchorPoint(cc.p(0,0))
	widget:addTo(self)

	self.mainLayer = widget:getChildByName("main")

	self.nolisttip = self.mainLayer:getChildByName("no"):setVisible(false)

 	self.listView = self.mainLayer:getChildByName("listview")
	local itemmodel = self.mainLayer:getChildByName("cell")

	itemmodel:retain()
	self.listView:setItemModel(itemmodel)
	itemmodel:removeFromParent()
	itemmodel:release()

	self.listView:removeAllItems()
	ComHelpFuc.setScrollViewEvent(self.listView)
	self.listView:setScrollBarEnabled(false)

 	self.createbtn =  self.mainLayer:getChildByName("create1")
	WidgetUtils.addClickEvent(self.createbtn, function( )
		if  GAME_CITY_SELECT == 6 then
			self.data.lockState = 1 --表示创建房间，被锁定的
		else
			self.data.lockState = 0
		end
		self.data.is_master_delegate = false
		LaypopManger_instance:PopBox("CreateRoomView",10,1,self.data)
	end)

	self.createbtn_dai =  self.mainLayer:getChildByName("create_dai"):setVisible(false)
	WidgetUtils.addClickEvent(self.createbtn_dai, function( )
		if  GAME_CITY_SELECT == 6 then
			self.data.lockState = 1 --表示创建房间，被锁定的
		else
			self.data.lockState = 0
		end
		self.data.is_master_delegate = true
		LaypopManger_instance:PopBox("CreateRoomView",10,1,self.data)
	end)

	self.btnSuoding =  self.mainLayer:getChildByName("btn_suoding"):setVisible(false)
	WidgetUtils.addClickEvent(self.btnSuoding, function( )
		self.data.lockState = 2 --表示房主锁定玩法
		LaypopManger_instance:PopBox("CreateRoomView",10,1,self.data)
	end)


	if  GAME_CITY_SELECT == 6 then
		print(".............GAME_CITY_SELECT ＝ ",GAME_CITY_SELECT)
		self.createbtn_dai:setVisible(true)
		self.btnSuoding:setVisible(true)
	end

	self.addbtn =  self.mainLayer:getChildByName("addbtn")
	WidgetUtils.addClickEvent(self.addbtn, function( )
		LaypopManger_instance:PopBox("AddfangclueView",self.data.tbid,self.data.chips)
	end)


end


function ClubRoom:updataView(data)
	self.data = data

	if data.result ~= 0 then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
		return
	end
	self.data = data
	if self.data.tables == nil then
		self.data.tables = {}
	end
	if #self.data.tables == 0 then
		self.nolisttip:setVisible(true)
	else
		self.nolisttip:setVisible(false)
	end

	if self.data.master_uid == LocalData_instance.uid then
		self.mainLayer:getChildByName("totallfang"):setString(self.data.chips)
	else
		self.mainLayer:getChildByName("totallfang1"):setVisible(false)
		self.mainLayer:getChildByName("totallfang"):setVisible(false)
		self.mainLayer:getChildByName("addbtn"):setVisible(false)
		self.mainLayer:getChildByName("create_dai"):setVisible(false)
		self.mainLayer:getChildByName("btn_suoding"):setVisible(false)
	end

	if data.tables then
		self.listView:removeAllItems()
		for i,v in ipairs(data.tables) do
			self.listView:pushBackDefaultItem()
			local cell = self.listView:getItem(i-1)

			cell:setVisible(true)
			local name =  cell:getChildByName("name")
			local conf =  cell:getChildByName("conf")
			local btn =  cell:getChildByName("btn")
			local jiebtn =  cell:getChildByName("btn_0")
			local num = cell:getChildByName("num")
			name:setString(v.tid)

			conf:setString(GT_INSTANCE:getTableDes(v.conf, 2))
			num:setString(v.player_num.."/"..v.conf.seat_num)
			local function callback( )
				print("info")
				LaypopManger_instance:PopBox("TableinfoclueView",self.data.tbid,v.tid,v.conf.seat_num,v.if_start)
			end
			WidgetUtils.addClickEvent(cell, function( )
				callback()
			end)
			WidgetUtils.addClickEvent(btn, function( )
				callback()
			end)
			if v.if_start then
				btn:setVisible(false)
			else
				btn:setVisible(true)
			end
			if self.data.master_uid ==  LocalData_instance.uid then
				jiebtn:setVisible(true)
				WidgetUtils.addClickEvent(jiebtn, function( )
					Socketapi.requestreleaseroomclub(v.tid)
				end)
			else
				jiebtn:setVisible(false)
			end
		end
	end
end
function ClubRoom:updatechips(chips)
	if self.data.master_uid == LocalData_instance.uid then
		self.mainLayer:getChildByName("totallfang"):setString(chips)
	end
end


return ClubRoom
