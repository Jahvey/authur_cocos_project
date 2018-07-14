-------------------------------------------------
--   TODO   申请解散房间UI
--   @author yc
--   Create Date 2016.10.27
-------------------------------------------------
local DissolveView = class("DissolveView",PopboxBaseView)
-- 倒计时
local COUNT_TIME = 180
function DissolveView:ctor(seatinfo,data)
	-- printTable(seatinfo)
	-- printTable(data)

	self.oldtime = os.time()

	self:initData(seatinfo,data)
	self:initView()
	self:initEvent()
end

function DissolveView:initData(seatinfo,data)
	print("...............DissolveView:initData")
	printTable(data,"xp")

	printTable(seatinfo,"xp")


-- {
--   	   ["dissolve_info"] = {
--     		   ["pre_state"] = 2,
--     		   ["agree_uid_list"] =  {
--       			14580,
--       			14578,
--       			14577,
--       		},
--     		   ["start_uid"] = 14580,
--     	},
--   	   ["uid"] = 14577,
--   }


-- GameScene:NotifyDissolveTableOperation 收到解散房间的广播
-- [LUA-print] {
--   	   ["uid"] = 14578,
--   	   ["vote_down"] = true,
--   }
	self.itemList = {}

	self.myStatus = 3	--1为同意，2为发起者，3为等待，4为拒绝！

	self.usersinfo = {}
	self.startInfo = nil

	for i,v in ipairs(seatinfo) do
		if v.user then
			local ret = {}
			ret.name = v.user.nick
			ret.picurl = v.user.role_picture_url
			ret.uid = v.user.uid
			ret.status = 3 --1为同意，2为发起者，3为等待，4为拒绝！
			for m,vv in ipairs(data.dissolve_info.agree_uid_list) do
				if v.user.uid == vv then
					ret.status = 1
				end
				if LocalData_instance:getUid() == vv then
					self.myStatus = 1	--1为同意，2为发起者
				end
			end
			if data.dissolve_info.start_uid == v.user.uid then
				ret.status = 2
			end	
			table.insert(self.usersinfo,ret)

			if v.user.uid == data.dissolve_info.start_uid then
				self.startInfo = v.user
			end
		end
	end

	if data.dissolve_info.start_uid == LocalData_instance:getUid() then
		self.myStatus = 2
	end	
end

function DissolveView:initView()
	self.widget = cc.CSLoader:createNode("ui/dissolveroom/dissolveView.csb")
	self:addChild(self.widget)	

	self.mainLayer = self.widget:getChildByName("main")
	self.closebtn = self.mainLayer:getChildByName("closebtn")
	WidgetUtils.addClickEvent(self.closebtn, function( )
		LaypopManger_instance:back()
	end)
	self.closebtn:setVisible(false)


	self.refuseBtn = self.mainLayer:getChildByName("refuseBtn"):setVisible(false)	
	self.okBtn = self.mainLayer:getChildByName("okBtn"):setVisible(false)	

	WidgetUtils.addClickEvent(self.refuseBtn, function( )
		self:refuseCall()
	end)

	WidgetUtils.addClickEvent(self.okBtn, function( )
		self:okBtnCall()
	end)

	--tips
	self.tips_node = self.mainLayer:getChildByName("tips_node")
	self.organizer = self.tips_node:getChildByName("organizer")
	self.tips = self.tips_node:getChildByName("tips")

	self.organizer:setString(ComHelpFuc.getStrWithLength(self.startInfo.nick,10))

	if self.myStatus == 2 then
		self.organizer:setString("您")
	end

	if #self.usersinfo == 3 then
		self.mainLayer:getChildByName("item_4"):setVisible(false)

		self.mainLayer:getChildByName("item_1"):setPositionX(-200)
		self.mainLayer:getChildByName("item_2"):setPositionX(0)
		self.mainLayer:getChildByName("item_3"):setPositionX(200)

	elseif #self.usersinfo == 2 then
		self.mainLayer:getChildByName("item_4"):setVisible(false)
		self.mainLayer:getChildByName("item_3"):setVisible(false)

		self.mainLayer:getChildByName("item_1"):setPositionX(-120)
		self.mainLayer:getChildByName("item_2"):setPositionX(120)
	end

	self:refreshView()
	self:setCountdown()
end
function DissolveView:refreshView()

	-- 
	for i,v in ipairs(self.usersinfo) do
		local item = self.mainLayer:getChildByName("item_"..i)

		item:getChildByName("name"):setString(v.name)

		local headicon = item:getChildByName("headicon")
		local headicon = require("app.ui.common.HeadIcon").new(headicon,v.picurl).headicon
			
		local size =  headicon:getContentSize()
		headicon:setScaleX(76/size.width)
        headicon:setScaleY(76/size.height)


        item:getChildByName("yes"):setVisible(false)
        item:getChildByName("no"):setVisible(false)
        item:getChildByName("text_1"):setVisible(false)
        item:getChildByName("text_2"):setVisible(false)

		-- self.myStatus = 3	--1为同意，2为发起者，3为等待，4为拒绝！
        if v.status == 1 then
        	item:getChildByName("yes"):setVisible(true)
        elseif v.status == 2 then
			item:getChildByName("text_1"):setVisible(true)
		elseif v.status == 3 then
			item:getChildByName("text_2"):setVisible(true)
		elseif v.status == 4 then
			item:getChildByName("no"):setVisible(true) -- 不会在这个界面上出现拒绝，当拒绝的时候就关闭界面
        end
	end

	if self.myStatus == 1 then 
		self.tips:setString("申请了解散房间，等待其他玩家选择")
	elseif self.myStatus == 2 then 
		self.tips:setString("申请了解散房间，等待其他玩家选择")
	elseif self.myStatus == 3 then 
		self.tips:setString("申请了解散房间，请选择")
		self.refuseBtn:setVisible(true)
		self.okBtn:setVisible(true)
	end

	local _w = self.organizer:getContentSize().width
	self.tips:setPositionX(_w)

	_w = _w + self.tips:getContentSize().width
	self.tips_node:setPositionX(-(_w/2.0))

end

function DissolveView:okBtnCall()
	Socketapi.request_releaseroom(true,false)
	-- LaypopManger_instance:back()
end
function DissolveView:refuseCall()
	Socketapi.request_releaseroom(false,false)
	-- LaypopManger_instance:back()
end
-- 设置倒计时
function DissolveView:setCountdown()
	
	local time_node = self.mainLayer:getChildByName("time_node")
	local num_2 = time_node:getChildByName("num_2")
	local num_3 = time_node:getChildByName("num_3")
	local num_4 = time_node:getChildByName("num_4")


	local callfunc = function() 

		local time = COUNT_TIME - (os.time() - self.oldtime)

		local _fen =  math.floor(time/60)
		local _miao =  time%60

		num_2:setString(_fen)

		num_3:setString(math.floor(_miao/10))
		num_4:setString(_miao%10)

		if time <= 0 then
			self:stopAllActions()
			self:closeUI()
		end
	end
	CommonUtils.schedule(self, 1, callfunc)
end
function DissolveView:closeUI()
	-- LaypopManger_instance:back()
	-- self:removeFromParent()
	LaypopManger_instance:backByName("DissolveView")
end
function DissolveView:releaseRoom(data)
	if not WidgetUtils:nodeIsExist(self) then
		return
	end

	if data.uid == LocalData_instance:getUid() then
		self.refuseBtn:setVisible(false)
		self.okBtn:setVisible(false)


		self.tips:setString("申请了解散房间，等待其他玩家选择")
		local _w = self.organizer:getContentSize().width
		_w = _w + self.tips:getContentSize().width

		self.tips_node:setPositionX(-(_w/2.0))
	end

	for i,v in ipairs(self.usersinfo) do
		if data.uid == v.uid then
			local item = self.mainLayer:getChildByName("item_"..i)
			item:getChildByName("text_2"):setVisible(false)

			if not data.vote_down then
		        item:getChildByName("yes"):setVisible(true)
			else
				item:getChildByName("no"):setVisible(true)

				self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() 
					self:closeUI()
					LaypopManger_instance:backByName("PromptBoxView")
					LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "玩家"..v.name.."拒绝了解散房间"})
				end)))
				return 
	    	end
		end
	end

end
function DissolveView:initEvent()
	-- ComNoti_instance:addEventListener("cs_notify_dissolve_table_operation",self,self.releaseRoom)
end
return DissolveView