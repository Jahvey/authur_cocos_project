-------------------------------------------------
--   TODO   牌局结束UI
--   @author yc
--   Create Date 2016.10.27
-------------------------------------------------
local AllResultView = class("AllResultView",PopboxBaseView)
local curdata = {
  	   ["gamebankertype"] = 1,
  	   ["totalGameNums"] = 10,
  	   ["keytype"] = "3;2;3;7",
  	   ["roomnum"] = 267976,
  	   ["curPlayerFlag"] = 0,
  	   ["curPlayerIndex"] = 0,
  	   ["endtimelong"] = 1511373436256,
  	   ["curGameNums"] = 1,
  	   ["dismisstype"] = 1,
  	   ["gamenums"] = 10,
  	   ["endtime"] = "2017-11-23 01:57:16",
  	   ["gameendinfolist"] = {
    		 {
      			   ["playerid"] = 10009,
      			   ["nickname"] = "游客10009",
      			   ["losenums"] = 1,
      			   ["totalscore"] = -10,
      			   ["pushscorecount"] = 0,
      			   ["index"] = 1,
      			   ["ip"] = "171.214.181.128",
      			   ["qiangbankercount"] = 1,
      			   ["scorecountlist"] =    {
        				-10,
        			},
      			   ["headimgurl"] = "",
      			   ["zuobankercount"] = 1,
      			   ["winnums"] = 0,
      		},
    		 {
      			   ["playerid"] = 10010,
      			   ["nickname"] = "游客10010",
      			   ["losenums"] = 0,
      			   ["totalscore"] = 10,
      			   ["pushscorecount"] = 0,
      			   ["index"] = 2,
      			   ["ip"] = "171.214.181.128",
      			   ["qiangbankercount"] = 1,
      			   ["scorecountlist"] =    {
        				10,
        			},
      			   ["headimgurl"] = "",
      			   ["zuobankercount"] = 0,
      			   ["winnums"] = 1,
      		},
      		{
      			   ["playerid"] = 10010,
      			   ["nickname"] = "游客10010",
      			   ["losenums"] = 0,
      			   ["totalscore"] = 10,
      			   ["pushscorecount"] = 0,
      			   ["index"] = 2,
      			   ["ip"] = "171.214.181.128",
      			   ["qiangbankercount"] = 1,
      			   ["scorecountlist"] =    {
        				10,
        			},
      			   ["headimgurl"] = "",
      			   ["zuobankercount"] = 0,
      			   ["winnums"] = 1,
      		},
      		{
      			   ["playerid"] = 10010,
      			   ["nickname"] = "游客10010",
      			   ["losenums"] = 0,
      			   ["totalscore"] = 10,
      			   ["pushscorecount"] = 0,
      			   ["index"] = 2,
      			   ["ip"] = "171.214.181.128",
      			   ["qiangbankercount"] = 1,
      			   ["scorecountlist"] =    {
        				10,
        			},
      			   ["headimgurl"] = "",
      			   ["zuobankercount"] = 0,
      			   ["winnums"] = 1,
      		},
      		{
      			   ["playerid"] = 10010,
      			   ["nickname"] = "游客10010",
      			   ["losenums"] = 0,
      			   ["totalscore"] = 10,
      			   ["pushscorecount"] = 0,
      			   ["index"] = 2,
      			   ["ip"] = "171.214.181.128",
      			   ["qiangbankercount"] = 1,
      			   ["scorecountlist"] =    {
        				10,
        			},
      			   ["headimgurl"] = "",
      			   ["zuobankercount"] = 0,
      			   ["winnums"] = 1,
      		},
      	
    	},
  }


function AllResultView:ctor(data)
	self.data = data or curdata
	self:initView()
	
end


function AllResultView:initView()
	
	if self.data.gamebankertype > 5 then
		self.widget = cc.CSLoader:createNode("ui/result/allResultView1.csb")
	else
		self.widget = cc.CSLoader:createNode("ui/result/allResultView.csb")
	end
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
	WidgetUtils.addClickEvent(self.mainLayer:getChildByName("jisuan"), function( )
		print("分享")
		LaypopManger_instance:PopBox("sunView",function(num)
			for i,v in ipairs(self.data.gameendinfolist) do
				self.mainLayer:getChildByName(tostring(i)):getChildByName("jisuan"):setVisible(true)
				local score =self.mainLayer:getChildByName(tostring(i)):getChildByName("score_0")
				score:setVisible(true)
				if v.totalscore >= 0 then
			        score:setString("+"..(v.totalscore*num))
			        score:setTextColor(cc.c3b(0xf4, 0x17, 0x17))
			      else
			        score:setString(v.totalscore*num)
					score:setTextColor(cc.c3b(0x2a, 0xa4, 0x1a))
		      	end
			end
		end)
	end)

	-- WidgetUtils.addClickEvent(self.mainLayer:getChildByName("againbtn"), function( )
	-- 	print("在来一把")
	-- 	--CommonUtils.shareScreen()
	-- 	Socketapi.sendagaingame()
	-- end)
	local wanfa = {"明牌抢庄","通比牛牛","自由抢庄","固定庄家","牛牛上庄","明牌抢庄牛几几倍","下注抢庄牛几几倍","自由抢庄牛几几倍","赖子玩法牛几几倍"}
	self.mainLayer:getChildByName("time"):setString(self.data.endtime)
	local str  = "房间号:"
	str = str..self.data.roomnum.."    玩法:"
	str = str..wanfa[self.data.gamebankertype].."    局数:"
	str = str..self.data.gamenums
	self.mainLayer:getChildByName("tableid"):setString(str)

	-- item:getChildByName("tableid"):setString("房号:"..v.roomnum)
	--         item:getChildByName("str1"):setString("局数:"..v.gamenums)
	--         local wanfa = {"明牌抢庄","固定庄家","自由抢庄","牛牛上庄"}
	--         item:getChildByName("str2"):setString("玩法:"..wanfa[v.gamebankertype])

	self.cell = self.mainLayer:getChildByName("cell")

	for i=1,6 do
		if  self.mainLayer:getChildByName(tostring(i)) then
			self.mainLayer:getChildByName(tostring(i)):setVisible(false)
			local listview = self.mainLayer:getChildByName(tostring(i)):getChildByName("listview")
			listview:setItemModel(self.cell)
		end
	end
	self.cell:setVisible(false)

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

	for i,v in ipairs(self.data.gameendinfolist) do
		print("i"..i)
		local node = self.mainLayer:getChildByName(tostring(i))
		node:setVisible(true)
		local name = node:getChildByName("name")
		
		name:setString(ComHelpFuc.getStrWithLengthByJSP(v.nickname))
		node:getChildByName("id"):setString("ID:"..v.playerid)
		if v.totalscore >= 0 then
			local score = node:getChildByName("score")
	        score:setString("+"..v.totalscore)
	        score:setVisible(true)
	        score:setTextColor(cc.c3b(0xf4, 0x17, 0x17))
	      else
	      	local score = node:getChildByName("score")
	        score:setString(v.totalscore)
			
			 score:setTextColor(cc.c3b(0x2a, 0xa4, 0x1a))
	        score:setVisible(true)
      	end
      	--node:getChildByName("score_0"):setString("房卡消耗:"..v.useroomcards)

		local icon = node:getChildByName("icon")
		--icon:setLocalZOrder(-1)
		require("app.ui.common.HeadIcon_Club").new(icon,v.headimgurl,55)
		if v.index == 1 and self.data.fangindex == nil then
			node:getChildByName("fangtip"):setVisible(true)
		elseif self.data.fangindex == v.index then
			node:getChildByName("fangtip"):setVisible(true)
		else
			node:getChildByName("fangtip"):setVisible(false)
		end
		if isallzero then
			node:getChildByName("allwin"):setVisible(false)
		else
			if maxsorce <= v.totalscore then
				node:getChildByName("allwin"):setVisible(true)
			else
				node:getChildByName("allwin"):setVisible(false)
			end
		end
		for i1,v1 in ipairs(v.scorecountlist) do
			self.mainLayer:getChildByName(tostring(i)):getChildByName("listview"):pushBackDefaultItem()
	        local item = self.mainLayer:getChildByName(tostring(i)):getChildByName("listview"):getItem(i1-1)
	        item:getChildByName("num"):setString("第"..i1.."局")
	        item:setVisible(true)
	        item:getChildByName("score"):setString(v1)
		end
	end
end

return AllResultView