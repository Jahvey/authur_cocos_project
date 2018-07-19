local RankPage = class("RankPage",function ()
	return cc.Node:create()
end)

local RULE_TITLE = "大力神点数排行榜"
local RULE_CONTENT = "1.排行榜活动时间：2018-06-14 12:00 ~ 2018-07-16 12:00\n奖励领取时间：2018-07-16 12:00 ~ 2018-07-18 12:00\n2. 大力神点数超过%d才能领取排名奖励。\n3.  排名中若遇点数相同的玩家，按达到该点数的时间先后进行排名。\n4.  领取实物后请联系客服jrhp007领奖。\n5.  奖励领取时间截止时若未领取，将视为放弃。\n"


function RankPage:ctor(mainview,item)
	self:initData(mainview,item)
	self:initView()
	self:initEvent()
end

function RankPage:initData(mainview,item)
	self.mainView = mainview
	self.item = item
end

function RankPage:initView()
	self.widget = cc.CSLoader:createNode(self.mainView:getResourcePath().."rank/ranknode.csb")
	self:addChild(self.widget)

	self.ruleBtn = self.widget:getChildByName("rulebtn")

	self.myRank = self.widget:getChildByName("myrank")
	self.rankTip = self.widget:getChildByName("ranktip")
	self.getBtn = self.widget:getChildByName("getbtn")
	self.getBtn_gray = self.widget:getChildByName("getbtn_gray")
	self.getBtn_gray2 = self.widget:getChildByName("getbtn_gray2")

	self:initRankNode()
	self:initAwardNode()

	local tagnode = self.widget:getChildByName("tagnode")
	local awardpage = tagnode:getChildByName("awardpage"):setTouchEnabled(true)
	local rankpage = tagnode:getChildByName("rankpage"):setTouchEnabled(true)
	local awardpage_s = tagnode:getChildByName("awardpage_s")
	local rankpage_s = tagnode:getChildByName("rankpage_s")

	WidgetUtils.addClickEvent(rankpage,function ()
		awardpage:setVisible(true)
		rankpage:setVisible(false)
		awardpage_s:setVisible(false)
		rankpage_s:setVisible(true)
		self:showRankNode()
	end)

	WidgetUtils.addClickEvent(awardpage,function ()
		awardpage:setVisible(false)
		rankpage:setVisible(true)
		awardpage_s:setVisible(true)
		rankpage_s:setVisible(false)
		self:showAwardNode()
	end)
end

function RankPage:initEvent()
	self:registerScriptHandler(function(state)
		if state == "enter" then
			self:onEnter()
		elseif state == "exit" then
			self:onExit()
		end
	end)
end

function RankPage:initRankNode()
	self.rankNode = self.widget:getChildByName("ranknode")

	self.rankNode.listView = self.rankNode:getChildByName("listview")
	self.rankNode.tip = self.rankNode:getChildByName("tip")

	self.rankNode.itemModel = self.rankNode.listView:getChildByName("item")
	self.rankNode.itemModel:retain()
	self.rankNode.listView:setItemModel(self.rankNode.itemModel)
	self.rankNode.listView:removeAllItems()
	self.rankNode.itemModel:release()
end

function RankPage:initAwardNode()
	self.awardNode = self.widget:getChildByName("awardnode")

	self.awardNode.listView = self.awardNode:getChildByName("listview")
	self.awardNode.tip = self.awardNode:getChildByName("tip")

	self.awardNode.itemModel = self.awardNode.listView:getChildByName("item")
	self.awardNode.itemModel:retain()
	self.awardNode.listView:setItemModel(self.awardNode.itemModel)
	self.awardNode.listView:removeAllItems()
	self.awardNode.itemModel:release()
end

function RankPage:refreshRankNode(data)
	self.rankNode.data = data

	self.myRank:setString("第"..data.rank.."名")
	if data.is_prize == 3 then
		self.rankTip:setVisible(true)
	else
		self.rankTip:setVisible(false)
	end
	self.rankNode.tip:setString("领取奖励至少需要"..data.limit.."大力神点数")

	WidgetUtils.addClickEvent(self.ruleBtn, function()
		LaypopManger_instance:PopBox("WCRuleBox",{title = RULE_TITLE,content = string.format(RULE_CONTENT,data.limit)})
	end)

	self.rankNode.listView:removeAllItems()


	for i,v in ipairs(data.list or {}) do
		self.rankNode.listView:pushBackDefaultItem()

		local item = self.rankNode.listView:getItem(i-1)
		
		local bg = item:getChildByName("bg")
		local srank = item:getChildByName("srank"):ignoreContentAdaptWithSize(true)
		local ranknum = item:getChildByName("ranknum")
		local head = item:getChildByName("head"):setScale(0.7)
		local name = item:getChildByName("name")
		local id = item:getChildByName("id")
		local point = item:getChildByName("point")

		if i <= 3 then
			srank:setVisible(true)
			ranknum:setVisible(false)
			srank:loadTexture(self.mainView:getResourcePath().."rank/"..i..".png")
		else
			srank:setVisible(false)
			ranknum:setVisible(true)
			ranknum:setString(i)
		end

		require("app.ui.common.HeadIcon").new(head,v.img)
		name:setString(self:getCharacterCountInUTF8String(v.nick,10))
		id:setString("ID:"..v.uid)
		point:setString(v.point)

		if v.uid == LocalData_instance.uid then
			bg:loadTexture(self.mainView:getResourcePath().."rank/myborad.png")
		end
	end

	WidgetUtils.addClickEvent(self.getBtn,function ()
		if data.is_prize == 0 then
			LaypopManger_instance:PopBox("WCTipBox","现在还不能领奖")
		elseif data.is_prize == 1 then
			-- LaypopManger_instance:PopBox("WCTipBox","您当前点数不足，无法成功下注，请更换下注额度或者更多点数后重试！")
			LaypopManger_instance:PopBox("RankAwardTip",data.rank)
		elseif data.is_prize == 2 then
			LaypopManger_instance:PopBox("WCTipBox","您已经领过奖了！")
		elseif data.is_prize == 3 then
			if data.rank > 10 then
				LaypopManger_instance:PopBox("WCTipBox","很遗憾，您的排名位于10名以后无法领取世界杯活动奖励！")
			else
				LaypopManger_instance:PopBox("WCTipBox","很遗憾，您的点数不足"..data.limit.."点，无法领取世界杯活动奖励！")
			end
		end
	end)

	if data.is_prize == 0 then
		self.getBtn:setVisible(false)
		self.getBtn_gray:setVisible(true)
		self.getBtn_gray2:setVisible(false)
	elseif data.is_prize == 1 then
		self.getBtn:setVisible(true)
		self.getBtn_gray:setVisible(false)
		self.getBtn_gray2:setVisible(false)
	elseif data.is_prize == 2 then
		self.getBtn:setVisible(false)
		self.getBtn_gray:setVisible(false)
		self.getBtn_gray2:setVisible(true)
	elseif data.is_prize == 3 then
		self.getBtn:setVisible(false)
		self.getBtn_gray:setVisible(true)
		self.getBtn_gray2:setVisible(false)
	end 

	-- self.item.setRedVisible(data.is_prize == 1)
end

function RankPage:refreshAwardNode(data)
	self.awardNode.data = data

	self.awardNode.tip:setString("截止至"..os.date("%m月%d日%H:%M",data.prizedate).."，总点数排名前10的玩家将会获得丰厚的奖励哦！")

	for i,v in ipairs(data.list or {}) do
		self.awardNode.listView:pushBackDefaultItem()

		local item = self.awardNode.listView:getItem(i-1)
		
		local bg = item:getChildByName("bg")
		local rank = item:getChildByName("rank"):ignoreContentAdaptWithSize(true)
		local award_1 = item:getChildByName("award_1"):setVisible(false)
		local award_2 = item:getChildByName("award_2"):setVisible(false)
		-- local award_3 = item:getChildByName("award_3")

		if i%2 == 0 then
			bg:setVisible(false)
		end

		local awardlist = {award_1,award_2}
		
		rank:loadTexture(self.mainView:getResourcePath().."rank/rank_text_"..v.rank..".png")

		for m,n in ipairs(v.list) do
			if awardlist[m] then
				NetPicUtils.getPic(awardlist[m]:getChildByName("img"):ignoreContentAdaptWithSize(true), n.url)
				awardlist[m]:getChildByName("name"):setString(n.name)
				awardlist[m]:setVisible(true)
			end
		end
	end
end

function RankPage:showRankNode()
	self.rankNode:setVisible(true)
	self.awardNode:setVisible(false)

	if not self.rankNode.data and not self.rankNode.requesting then
		self:getRankList()
	end
end

function RankPage:showAwardNode()
	self.rankNode:setVisible(false)
	self.awardNode:setVisible(true)

	if not self.awardNode.data and not self.awardNode.requesting then
		self:getAwardList()
	end
end

function RankPage:getCharacterCountInUTF8String(str,length)
	local lengthmax = length or 16
	local locallengt = 0
	local c
	local i = 1
	while true do
		c = string.byte(string.sub(str,i,i))
		print(c)
		if not c then
			return str
		elseif (c<=127)  then
			locallengt = locallengt + 1
			if locallengt > lengthmax then
				return string.sub(str,1,i-1).."..."
			end
			i = i + 1;
		elseif (bit.band(c , 0xE0) == 0xC0) then
			locallengt = locallengt + 2
			if locallengt > lengthmax then
				return string.sub(str,1,i-1).."..."
			end
			i = i + 2;
		elseif (bit.band(c , 0xF0) == 0xE0) then
			locallengt = locallengt + 2
			if locallengt > lengthmax then
				return string.sub(str,1,i-1).."..."
			end
			i = i + 3;
		elseif (bit.band(c , 0xF8) == 0xF0) then
			locallengt = locallengt + 2
			if locallengt > lengthmax then
				return string.sub(str,1,i-1).."..."
			end
			i = i + 4;
		else 
			return str
		end
	end
	return str
end

function RankPage:getRankList()
	self.mainView:showSmallLoading()
	self.rankNode.requesting = true
	ComHttp.httpPOST(ComHttp.URL.WCRANKGETRANKLIST,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self.mainView:hideSmallLoading()
		self.rankNode.requesting = false

		if msg.status ~= 1 then
			return
		end
		self:refreshRankNode(msg)
	end)
end

function RankPage:getAwardList()
	self.mainView:showSmallLoading()
	self.awardNode.requesting = true
	ComHttp.httpPOST(ComHttp.URL.WCRANKGETPRIZELIST,{uid = LocalData_instance.uid},function(msg)
		printTable(msg)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self.mainView:hideSmallLoading()
		self.awardNode.requesting = false

		if msg.status ~= 1 then
			return
		end

		self:refreshAwardNode(msg)
	end)
end

function RankPage:onEnter()
	self:showRankNode()
end

function RankPage:onExit()
	-- body
end

return RankPage