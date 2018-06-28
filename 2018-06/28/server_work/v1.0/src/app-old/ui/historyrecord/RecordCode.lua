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
	self.widget = cc.CSLoader:createNode("ui/joinRoom/RecordView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
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
	if tonumber(tid)  then
		self.isrequest = true
		Socketapi.cs_request_replay_code_data(tonumber(tid))
	end

end
function JoinRoomView:responseEnterTable(data)
	self.isrequest = false
	if data.result == 0 then
		LaypopManger_instance:back()
		-- glApp:enterSceneByName("PlaybackScene",data)
		if data.sdr_record and data.sdr_record.sdr_seats then
			Notinode_instance:pushRecordScene(data)
			return
		end
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "回放视频过期，系统已自动清除！"})
		-- printTable(data)

	elseif data.result == poker_common_pb.EN_MESSAGE_INVALID_FLOW_RECORD_NOT_FOUND then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "打牌记录不存在"})
	elseif data.result == poker_common_pb.EN_MESSAGE_DB_NOT_FOUND then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "系统异常"})
	elseif data.result == poker_common_pb.EN_MESSAGE_INVALID_REPLAY_CODE then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "回放码已经失效"})
	else
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "打牌记录异常("..data.result..")"})
	end
end
function JoinRoomView:initEvent()
	ComNoti_instance:addEventListener("cs_response_replay_code_data",self,self.responseEnterTable)
end
-- 响应
return JoinRoomView