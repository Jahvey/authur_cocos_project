-------------------------------------------------
--   TODO   牌局结束UI
--   @author yc
--   Create Date 2016.10.27
-------------------------------------------------
local AllResultView = class("AllResultView",PopboxBaseView)
local Card = require "app.ui.kutong.Card"
function AllResultView:ctor(data,gamedata,str)
	self.data = data or curdata
	self.str =str
	self.gamedata = gamedata
	self:initView()
	
end


function AllResultView:initView()
	self.widget = cc.CSLoader:createNode("ui/kutong/result/allResultView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("returnbtn"), function( )
		print("返回大厅")
		 LaypopManger_instance:back()
		glApp:enterSceneByName("MainScene")
	end)

	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("sharebtn"), function( )
		print("分享")
		CommonUtils.shareScreen()
	end)
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("next"), function( )
		if self.data.isLastGame == 1 then
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "牌局已经结束",sureCallFunc = function()
			end})
		else
		 LaypopManger_instance:back()
		end
	end)
	if self.data.isLastGame == 1 then
		self.mainLayer:getChildByName("returnbtn"):setVisible(true)
		self.mainLayer:getChildByName("next"):setVisible(true)
	else
		self.mainLayer:getChildByName("returnbtn"):setVisible(false)
		self.mainLayer:getChildByName("next"):setVisible(true)
	end

	-- WidgetUtils.addClickEvent(self.mainLayer:getChildByName("againbtn"), function( )
	-- 	print("在来一把")
	-- 	--CommonUtils.shareScreen()
	-- 	Socketapi.sendagaingame()
	-- end)
	--local wanfa = {"明牌抢庄","通比牛牛","自由抢庄","固定庄家","牛牛上庄","明牌抢庄牛几几倍","下注抢庄牛几几倍","自由抢庄牛几几倍","赖子玩法牛几几倍"}
	self.mainLayer:getChildByName("time"):setString(self.data.endtime)
	self.mainLayer:getChildByName("tableid"):setString(self.str)
	for i=1,4 do
		self.mainLayer:getChildByName(i):setVisible(false)
		self.mainLayer:getChildByName(i):getChildByName("duiyou"):setVisible(false)
	end
	local isallzero = true
	local maxsorce = 0
	for i,v in ipairs(self.data.gameendinfolist) do
		if v.totalscore ~= 0 then
			isallzero = false
		end
		if maxsorce <= v.totalscore then
			maxsorce =  v.totalscore
		end

	end
	self.cell = self.mainLayer:getChildByName("cell")

	for i,v in ipairs(self.data.gameendinfolist) do

		local node = self.mainLayer:getChildByName(i)
		node:setVisible(true)
		if v.curresultscore == 4 then
			node:getChildByName("score_0"):setString(v.curresultscore.."  窟桶")
		else
			node:getChildByName("score_0"):setString(v.curresultscore or 0)
		end
		node:getChildByName("liaowang"):setString(v.totalBirdJokerNums)
		node:getChildByName("score"):setString(v.onescore)
		node:getChildByName("totallscore"):setString(v.totalscore)
		node:getChildByName("id"):setString(v.nickname)
		node:getChildByName("name"):setString(v.playerid)
		if self.data.roomHostPlayerid == v.playerid then
			node:getChildByName("fangtip"):setVisible(true)
		else
			node:getChildByName("fangtip"):setVisible(false)
		end
		if LocalData_instance.playerid == v.playerid then
			if v.index == 1 then
				self.mainLayer:getChildByName(3):getChildByName("duiyou"):setVisible(true)
			elseif v.index == 2 then
				self.mainLayer:getChildByName(4):getChildByName("duiyou"):setVisible(true)
			elseif v.index == 3 then
				self.mainLayer:getChildByName(1):getChildByName("duiyou"):setVisible(true)
			elseif v.index == 4 then
				self.mainLayer:getChildByName(2):getChildByName("duiyou"):setVisible(true)
			end
		end
		local icon = node:getChildByName("icon")
		require("app.ui.common.HeadIcon_Club").new(icon,v.headimgurl,84)
		if v.cardCompleteOrder then
			node:getChildByName("no"):setVisible(true)
			node:getChildByName("no"):setTexture("cocostudio/ui/kutong/result/no"..v.cardCompleteOrder..".png")
		else
			node:getChildByName("no"):setVisible(false)
		end
		if self.data.isLastGame == 1 then
			if isallzero then
				node:getChildByName("allwin"):setVisible(false)
			else
				if maxsorce <= v.totalscore then
					node:getChildByName("allwin"):setVisible(true)
				else
					node:getChildByName("allwin"):setVisible(false)
				end
			end
		else
			node:getChildByName("allwin"):setVisible(false)
		end

		local listview = node:getChildByName("listview")
    	listview:setItemModel(self.cell)
    	for i1,v1 in ipairs(v.rewardAndTongInfos) do
    		listview:pushBackDefaultItem()
	        local item1 = listview:getItem(i1-1)
	        if v1.type == 4 then
	        	 item1:getChildByName("spe"):setVisible(true)
	        	 item1:getChildByName("spe"):setString(v1.rewardinfo)
	        else
	        	 item1:getChildByName("spe"):setVisible(false)
		        for i2,v2 in ipairs(v1.curCards) do
		        	local card = Card.new(v2,true)
		        	card:setCardAnchorPoint(cc.p(0,0))
		        	card:setScale(0.5)
		        	card:setPositionX((i2-1)*18)
		        	item1:addChild(card)
		        end
		    end
	        item1:getChildByName("tong"):setLocalZOrder(1)
	        item1:getChildByName("jiang"):setLocalZOrder(1)
	        if v1.type == 1 then
	        	item1:getChildByName("tong"):setString(v1.score.."分")
		        item1:getChildByName("jiang"):setVisible(false)
	        else
		        item1:getChildByName("tong"):setString(v1.tongNums.."桶")
		        item1:getChildByName("jiang"):setString(v1.rewardNums.."奖")
		    end
    	end

	end	
	self.cell:setVisible(false)
end

return AllResultView