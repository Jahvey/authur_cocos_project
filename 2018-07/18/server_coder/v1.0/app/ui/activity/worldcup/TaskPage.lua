local TaskPage = class("TaskPage",function ()
	return cc.Node:create()
end)

local RULE_TITLE = "世界杯每日玩牌奖励"
local RULE_CONTENT = "1. 活动时间：2018-06-14 12:00 ~ 2018-07-16 12:00\n2. 每日玩牌局数达到规定局数，可领取相应的大力神点数奖励。\n3. 每日玩牌局数达到128局后，每多玩32局可额外领取50点大力神点数奖励。\n4. 每日凌晨00:00清空玩牌局数。\n"

function TaskPage:ctor(mainview,item)
	self:initData(mainview,item)
	self:initView()
	self:initEvent()
end

function TaskPage:initData(mainview,item)
	self.mainView = mainview
	self.item = item
end

function TaskPage:initView()
	self.widget = cc.CSLoader:createNode(self.mainView:getResourcePath().."task/tasknode.csb")
	self:addChild(self.widget)

	local rulebtn = self.widget:getChildByName("rulebtn")

	WidgetUtils.addClickEvent(rulebtn, function()
		LaypopManger_instance:PopBox("WCRuleBox",{title = RULE_TITLE,content = RULE_CONTENT})
	end)

	self.timeLabel = self.widget:getChildByName("time")
	self.loadingBar = self.widget:getChildByName("loadingbar")
	self.getBtn = self.widget:getChildByName("getbtn")
	self.playLabel = self.widget:getChildByName("nowplay")
	self.numLabel = self.widget:getChildByName("num")

	self.taskList = {}
	for i=1,3 do
		table.insert(self.taskList,self.widget:getChildByName("tasknode_"..i))
	end
end

function TaskPage:initEvent()
	self:registerScriptHandler(function(state)
		if state == "enter" then
			self:onEnter()
		elseif state == "exit" then
			self:onExit()
		end
	end)
end

function TaskPage:refreshView(data)
	if data.list.status == 1 then
		self.getBtn:setEnabled(true)
		WidgetUtils.addClickEvent(self.getBtn,function ()
			self:getAward()
		end)
	else
		self.getBtn:setEnabled(false)
	end

	self.item.setRedVisible(data.list.status == 1)

	self.timeLabel:setString("活动时间:"..os.date("%Y年%m月%d日",data.starttime).."至"..os.date("%Y年%m月%d日",data.endtime))
	local final = math.min(#data.list.list,3)
	self.loadingBar:setPercent(100*data.list.play/data.list.list[final].play)
	self.playLabel:setString(data.list.play)
	self.numLabel:setString(data.list.canget)

	for i,v in ipairs(data.list.list) do
		local tasknode = self.taskList[i]

		if tasknode then
			local progress = tasknode:getChildByName("progress")
			local num = tasknode:getChildByName("num")
			local icon = tasknode:getChildByName("icon")
			local gettag = tasknode:getChildByName("gettag")

			progress:setString(math.min(data.list.play,v.play).."/"..v.play.."局")
			num:setString(v.num)
			if v.status == 2 then
				gettag:setVisible(true)
				icon:setVisible(false)
				num:setVisible(false)
			else
				gettag:setVisible(false)
				icon:setVisible(true)
				num:setVisible(true)
			end
		end
	end
end

function TaskPage:getConf()
	self.mainView:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.WCTASKGETCONF,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self.mainView:hideSmallLoading()

		if msg.status ~= 1 then
			return
		end

		self:refreshView(msg)
	end)
end

function TaskPage:getAward()
	self.mainView:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.WCTASKGETAWARD,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self.mainView:hideSmallLoading()
		self:getConf()
		if msg.status ~= 1 then
			return
		end

		if msg.ord > 3 then
			self.mainView:gainPoint(msg.num,self.mainView:convertToNodeSpace(self.getBtn:getParent():convertToWorldSpace(cc.p(self.getBtn:getPositionX(),self.getBtn:getPositionY()))))
		else
			self.mainView:gainPoint(msg.num,self.mainView:convertToNodeSpace(self.taskList[msg.ord]:getParent():convertToWorldSpace(cc.p(self.taskList[msg.ord]:getPositionX(),self.taskList[msg.ord]:getPositionY()))))
		end

		-- self.mainView:setPoint(self.mainView:getPoint()+(msg.num or 0))
	end)
end

function TaskPage:onEnter()
	self:getConf()
end

function TaskPage:onExit()
end

return TaskPage
