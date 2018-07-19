-------------------------------------------------
--   TODO   历史记录 战绩
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local HistoryRecordView = class("HistoryRecordView",PopboxBaseView)
function HistoryRecordView:ctor()
	self:initData()
	self:initView()
	self:initEvent()
	-- Socketapi.requestUserRecord()
end
function  HistoryRecordView:onEndAni()
	print("onEndAni")
	Socketapi.requestUserRecord()
	self:showSmallLoading()
end
function HistoryRecordView:initData()
	self.data = data
end

function HistoryRecordView:initView()
	self.widget = cc.CSLoader:createNode("ui/historyrecord/historyRecordView.csb")
	self:addChild(self.widget)
	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("bg"):getChildByName("closeBtn"), function( )
		print("返回大厅")
			if not LaypopManger_instance:back() then
				if tolua.cast(self,"cc.Node") then
					self:removeFromParent()
				end	
			end
	end)

	self.node1 = self.mainLayer:getChildByName("bg"):getChildByName("node1")
	self.node2 = self.mainLayer:getChildByName("bg"):getChildByName("node2")

	WidgetUtils.addClickEvent(self.node2:getChildByName("returnbtn"), function( )
		print("返回大厅")
		self.node2:setVisible(false)
		self.node1:setVisible(true)
	end)

	self.node1:getChildByName("testbtn")--:setVisible(false)
	WidgetUtils.addClickEvent(self.node1:getChildByName("testbtn"), function( )
		print("返回大厅")
		LaypopManger_instance:PopBox("RecordCodeView")
	end)

	-- 第一个
	self.listView = self.mainLayer:getChildByName("bg"):getChildByName("node1"):getChildByName("listView"):setVisible(true)
	local item = self.listView:getChildByName("item")
	item:retain()
	self.listView:setItemModel(item)
	item:removeFromParent()
	item:release()
	self.listView:removeAllItems()
	
	self.node2:setVisible(false)
	self.listView2 = self.node2:getChildByName("listView2")
	local item = self.node2:getChildByName("item2")
	item:retain()
	self.listView2:setItemModel(item)
	item:removeFromParent()
	item:release()
	self.listView2:removeAllItems()

	-- self.testbtn = self.mainLayer:getChildByName("testbtn"):setVisible(false)
	-- if device.platform == "windows" then
	-- 	self.testbtn:setVisible(true)
	-- 	WidgetUtils.addClickEvent(self.testbtn, function( )
	-- 		print("回放")
	-- 		Socketapi.requestTableFlowRecord()
	-- 	end)
	-- end
	-- self.panel = self.bg2:getChildByName("panel")
	-- for i=1,4 do
	-- 	self.panel:getChildByName("nameLabel"..i):setString("")		
	-- end
end
-- 第一个列表
function HistoryRecordView:createListView(data)

	table.sort(data.records, function (a,b)
		return a.stamp > b.stamp
	end )

	for i,v in ipairs(data.records) do
		self.listView:pushBackDefaultItem()
        local item = self.listView:getItem(i-1):setTouchEnabled(true)

        local index = item:getChildByName("index")
        -- 房间号
        local roomid = item:getChildByName("roombg"):getChildByName("roomid")  
        -- 时间
        local time = item:getChildByName("time")

        for k=1,4 do
        	local name = item:getChildByName("name"..k)
        	name:setVisible(false)
        end
        for m,vv in ipairs(v.final_user_scores) do
        	local name = item:getChildByName("name"..m)
        	name:setVisible(true)
        	local nick = ComHelpFuc.GetShortName(vv.nick,18)
        	name:getChildByName("name"):setString(nick)
        	name:getChildByName("score"):setString(vv.score)
        	local icon = name:getChildByName("icon")
        	local headicon = require("app.ui.common.HeadIcon").new(icon,vv.role_pic_url,60)
        end
        roomid:setString("房号:"..v.tid)
        index:setString("场次:"..i)
        local datetab = os.date("*t", v.stamp)
		-- local str = datetab.year.."-"..datetab.month.."-"..datetab.day.." "..datetab.hour..":"..datetab.min..":"..datetab.sec
        local str = string.format("%d-%02d-%02d %02d:%02d:%02d",datetab.year,datetab.month,datetab.day,datetab.hour,datetab.min,datetab.sec)

        time:setString(str)

        item:setPressedActionEnabled(false)
        WidgetUtils.addClickEvent(item, function( )
        	-- print("========1===")
			self:showPanel2(v)
		end)
	end
end
-- 第二个列表
function HistoryRecordView:createListView2(info)
	self.listView2:removeAllItems()
	for i,v in ipairs(info) do
		self.listView2:pushBackDefaultItem()
        local item = self.listView2:getItem(i-1)

        local bg1 = item:getChildByName("bg1")
        if i%2 == 0 then
        	bg1:setVisible(false)
        end
        local timeLabel = item:getChildByName("timeLabel")
        local index = item:getChildByName("index")
        local btn = item:getChildByName("button")
      	local share = item:getChildByName("share")--:setVisible(false)
      	local win = item:getChildByName("win"):setVisible(false)
      	local lose= item:getChildByName("lose"):setVisible(false)
      	local ping= item:getChildByName("ping"):setVisible(false)

      	-- local _x = btn:getPositionX()+share:getPositionX()
      	-- btn:setPositionX(_x/2.0)

      	if not v.scores then
      		v.scores = {}
      	end
      	for k=1,4 do
      		local valueLabel = item:getChildByName("valueLabel"..k):setString("")
      	end
        for m,vv in ipairs(info[1].scores) do
        	for m1,vv1 in ipairs(v.scores) do
        		if vv.uid == vv1.uid then
        			local valueLabel = item:getChildByName("valueLabel"..m)
        			valueLabel:setString(vv1.score)	

        			if vv.uid == LocalData_instance:getUid() then
        				if vv1.score > 0 then
        					win:setVisible(true)	
        				elseif vv1.score == 0 then
        					ping:setVisible(true)
        				else
        					lose:setVisible(true)	
        				end
        			end
        			break
        		end
        	end
        end
        index:setString(i)
        local time = v.stamp
        local datetab = os.date("*t", time)
		-- local string = datetab.month.."-"..datetab.day.." "..datetab.hour..":"..datetab.min
		local str = string.format("%02d-%02d %02d:%02d",datetab.month,datetab.day,datetab.hour,datetab.min)
        timeLabel:setString(str)
        WidgetUtils.addClickEvent(btn, function( )


        	-- Socketapi.requestrecodegame(self.recordid,i,self.stamp)
        	local tab = {}
        	tab.recordid = self.recordid
    		tab.round = v.round_index or i
    		tab.stamp = self.stamp
    		tab.game_type = 60

			Socketapi.requestTableFlowRecord(tab)


        end)
        WidgetUtils.addClickEvent(share, function( )
        	print("share")

        	Socketapi.cs_request_replay_code(self.recordid,v.round_index,self.stamp)

        end)
	end
end
function HistoryRecordView:getPlayerName(data,uid)
	for i,v in ipairs(data.final_user_scores) do
		if v.uid == uid then
			return v
		end
	end
end
function HistoryRecordView:setNameList(info)
	if not info.round_results[1].scores then
		return
	end
	for i=1,4 do
		self.node2:getChildByName("name"..i):setVisible(false)
	end
	for i,v in ipairs(info.round_results[1].scores) do
		local nameLabel = self.node2:getChildByName("name"..i)
		local playinfo = self:getPlayerName(info,v.uid)

        local nick = ComHelpFuc.GetShortName(playinfo.nick,18)
		nameLabel:setString(nick)
		nameLabel:setVisible(true)
	end
end
-- 显示第二个界面
function HistoryRecordView:showPanel2(info)
	-- print("HistoryRecordView:showPanel2=====================")
	-- printTable(info)
	if not info or not info.round_results or #info.round_results == 0 then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "未完成牌局！"})
		return
	end
	self.node2:setVisible(true)
	self.node1:setVisible(false)
	self.recordid = info.recordid
	self.stamp = info.stamp
	self:setNameList(info)
	self:createListView2(info.round_results)
end
function HistoryRecordView:reponseHistoryRecord(data)
	printTable(data)
	self:hideSmallLoading()
	if not data or not data.records then
		return
	end
	self.data = data
	self:createListView(data)
end

function HistoryRecordView:cs_response_replay_code(data )
	if data.result == 0 then
		CommonUtils.sharerecord(data.replay_code)
		if device.platform == "android" or device.platform == "ios" then
		else
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "回放码:"..data.replay_code})
		end
	else
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "分享失败，牌局已经失效("..data.result..")"})
	end
end
function HistoryRecordView:initEvent()
	ComNoti_instance:addEventListener("cs_response_user_record",self,self.reponseHistoryRecord)
	ComNoti_instance:addEventListener("cs_response_replay_code",self,self.cs_response_replay_code)
end

return HistoryRecordView