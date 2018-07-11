-------------------------------------------------
--   TODO   加入房间UI
--   @author yc
--   Create Date 2016.10.24
-------------------------------------------------
local JoinRoomView = class("JoinRoomView",PopboxBaseView)
function JoinRoomView:ctor()
	-- self.super.ctor(self)
	self:initData()
    self:initView()
    self:initEvent()
end
function JoinRoomView:initData()
	-- 房间号列表
	self.roomNumList = {} 
	-- 按钮列表
	self.keyBtnList = {}
	self.isrequest = false
end
function JoinRoomView:initView()
	self.widget = cc.CSLoader:createNode("ui/joinRoom/joinRoomView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
			userdata={}
			userdata.cid=3
			userdata.pid=14
			userdata.json={
				["type"]="3.点击关闭按钮"
				--["info"]="大结算信息/失败原因"
		    }
		    CommonUtils.sends(userdata)
		if LaypopManger_instance:back()==nil then
			userdata={}
			userdata.cid=3
			userdata.pid=15
			userdata.json={
				["type"]="3.跳转到大厅"
				--["info"]="大结算信息/失败原因"
		    }
		    CommonUtils.sends(userdata)
		end
	end)
	-- 数字node
	self.insertNode = self.mainLayer:getChildByName("insertNode")
	for i=1,6 do
		local num = self.insertNode:getChildByName("board_"..i):getChildByName("num")
		num:setString("")
		num.value = nil
		table.insert(self.roomNumList,num)
	end
	-- 数字
	self.keypadNode = self.mainLayer:getChildByName("keypadNode")
	self:initKeyPadNode()
	
end
-- 初始化按钮的事件
function JoinRoomView:initKeyPadNode()
	for i=0,11 do
		local str = i
		if i == 10 then
			str = "again"
		elseif i == 11 then
			str = "delete"	
		end
		local btn = self.keypadNode:getChildByName(str)
		btn.str = str
		btn:setPressedActionEnabled(false)

		WidgetUtils.addClickEvent(btn, function( )
			self:setRoomNumValue(btn.str)
			userdata={}
			userdata.cid=3
			userdata.pid=12
			userdata.json={
				["type"]="3.输入id"
				--["info"]="大结算信息/失败原因"
		    }
		    CommonUtils.sends(userdata)
		end)
	end
end
-- 设置数值
function JoinRoomView:setRoomNumValue(value)
	if not value then
		print("按钮的 value 为空 ！！！")
		return
	end 
	-- 重输
	if value == "again" then
		for i,numLabel in ipairs(self.roomNumList) do
			if numLabel.value then
				numLabel.value = nil 
				numLabel:setString("")
			end	
		end
	-- 删除
	elseif value == "delete" then
		for i=6,1,-1 do
			local numLabel = self.roomNumList[i]
			if numLabel.value then
				numLabel.value = nil
				numLabel:setString("")
				break
			end
		end
	else
		local num = 0
		for i,numLabel in ipairs(self.roomNumList)	do
			if not numLabel.value then
				numLabel.value = value 
				numLabel:setString(value)
				num = num + 1
				break
			else
				num = num + 1	
			end
		end
		if num == 6 then
			self:enterRoom()
			userdata={}
			userdata.cid=3
			userdata.pid=13
			userdata.json={
				["type"]="3.跳转到房间"
				--["info"]="大结算信息/失败原因"
		    }
		    CommonUtils.sends(userdata)
		end
	end	
end
-- 进入房间
function JoinRoomView:enterRoom()
	print("进入房间")
	if self.isrequest then
		return 
	end
	-- LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "发生了的法律萨芬发射点发生法撒旦法撒旦法撒大放送拉撒路烦死了理发师两大类"})
	local tid = "" 
	for i,numLabel in ipairs(self.roomNumList) do
		if i > 6 then
			break
		end
		tid = tid .. numLabel:getString()
		-- numLabel:setString("")
		-- numLabel.value = nil
	end
	self.isrequest = true
	Notinode_instance:jointable(tid,function() 
		self.isrequest = false	
	end)
end
function JoinRoomView:initEvent()
end
-- 响应
return JoinRoomView