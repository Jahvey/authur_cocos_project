-------------------------------------------------
--   TODO   申请解散房间UI
--   @author yc
--   Create Date 2016.10.27
-------------------------------------------------
local DissolveView = class("DissolveView",PopboxBaseView)
-- 倒计时
local COUNT_TIME = 120
-- opentype  1 发起 2 接收 3 已经拒绝或则同意
function DissolveView:ctor(data,num)
	self.data = data
	self.num = num
	self:initEvent()
	self:initView()
end

function DissolveView:initView()
	self.widget = cc.CSLoader:createNode("ui/popbox/jiesanbox.csb")
	self:addChild(self.widget)	

	self.mainLayer = self.widget:getChildByName("main")
	self.surebtn = self.mainLayer:getChildByName("surebtn")
	WidgetUtils.addClickEvent(self.surebtn, function( )
		if self.num == 1 then
			Socketapi.sendjiesanactionforkutong(1)
		else
			Socketapi.sendjiesanaction(1)
		end
		self.surebtn:setVisible(false)
		self.jujuebtn:setVisible(false)
	end)

	self.jujuebtn = self.mainLayer:getChildByName("jujuebtn")
	WidgetUtils.addClickEvent(self.jujuebtn, function( )
		if self.num == 1 then
			Socketapi.sendjiesanactionforkutong(0)
		else
			Socketapi.sendjiesanaction(0)
		end
		self.surebtn:setVisible(false)
		self.jujuebtn:setVisible(false)
	end)

	-- self.label1 = self.mainLayer:getChildByName("1")
	-- self.labeltab = {}
	-- local index =2
	-- printTable(self.data.roomPlayerItemJsons,"sjp")
	-- self.totall = #self.data.roomPlayerItemJsons
	-- for i=2,5 do
	-- 	self.mainLayer:getChildByName(tostring(i)):setVisible(false)
	-- end
	local totall = #self.data.roomPlayerItemJsons - 1 
	local index = 1
	local cell = self.mainLayer:getChildByName("cell")
	cell:setVisible(false)
	self.icons = {}
	printTable(self.data.roomPlayerItemJsons)
	for i,v in ipairs(self.data.roomPlayerItemJsons) do
		if v.userid ~= self.data.requestDismissUserid then
			self.icons[index] = cell:clone()
			self.icons[index]:setVisible(true)
			self.icons[index]:getChildByName("name"):setString(v.nickname)
			require("app.ui.common.HeadIcon").new(self.icons[index],v.headimgurl)
			print("v.headimgurl"..v.headimgurl)
			if v.dismissoptype == 0 then
				self.icons[index]:getChildByName("type"):setString("未选择")
				self.icons[index]:getChildByName("type"):setColor(cc.c3b(0, 255, 0))
			else
				self.icons[index]:getChildByName("type"):setString("同意")
				self.icons[index]:getChildByName("type"):setColor(cc.c3b(255, 0, 0))
			end
			-- self.labeltab[index] =  self.mainLayer:getChildByName(tostring(index))
			-- self.mainLayer:getChildByName(tostring(index)):setVisible(true)
			-- self.labeltab[index]:setString("玩家 "..v.nickname.." 未选择")
			-- if v.dismissoptype == 0 then
			-- else
			-- 	self.labeltab[index]:setString("玩家 "..v.nickname.." 同意解散房间")
			-- end
			self.icons[index]:setPosition(cc.p((index -totall/2 -0.5)*200,0))
			self.icons[index].userid = v.userid
			self.icons[index].nickname = v.nickname
		
			self.mainLayer:addChild(self.icons[index])
			index = index + 1
		else
			print("v.headimgurl"..v.headimgurl)
			self.mainLayer:getChildByName("2"):setString("玩家 "..v.nickname.."  发起了解散房间请求")
		end
	end
	local time = self.mainLayer:getChildByName("time"):setString("(120S)")
	local timelocal = 0
	local alltime = self.data.dismissOpTime or COUNT_TIME

	local jindu = self.mainLayer:getChildByName("set"):getChildByName("set")
	local function updata( dt)
		timelocal = timelocal + dt
		time:setString("("..(alltime - math.floor(timelocal)).."S)")
		jindu:setPercent((alltime - math.floor(timelocal))/120*100)
	end
	jindu:setPercent(100)
	self:scheduleUpdateWithPriorityLua(updata,0)
	if self.data.requestDismissUserid == LocalData_instance:getUid() then
		self.surebtn:setVisible(false)
		self.jujuebtn:setVisible(false)
	end
end
function DissolveView:releaseRoom(data)
	print("releaseRoom")
	if data.userid then
		print("releaseRoom1")
		if data.type == 1 then
			print("releaseRoom2")
			for i,v in ipairs(self.icons) do
				if data.userid == v.userid then
					v:getChildByName("type"):setString("同意")
					v:getChildByName("type"):setColor(cc.c3b(255, 0, 0))
				end
			end
			print("releaseRoom4")
		else
			print("releaseRoom3")
			for i,v in ipairs(self.data.roomPlayerItemJsons) do
				v.dismissoptype = 0
			end
			local name 
			for i,v in ipairs(self.icons) do
				if data.userid == v.userid then
					name = v.nickname
				end
			end
			LaypopManger_instance:back()
			if name then
				LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "玩家 "..name.." 拒绝解散房间"})
			end
		end
	end
end
function DissolveView:initEvent()
	ComNoti_instance:addEventListener("3;2;3;11",self,self.releaseRoom)
	ComNoti_instance:addEventListener("3;3;3;11",self,self.releaseRoom)
end

return DissolveView