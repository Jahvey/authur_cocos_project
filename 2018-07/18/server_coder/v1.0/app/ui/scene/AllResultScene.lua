-------------------------------------------------
--   TODO   牌局结束UI
--   @author yc
--   Create Date 2016.10.27
-------------------------------------------------
local AllResultScene = class("AllResultScene",function()
	return cc.Scene:create()
end)
function AllResultScene:ctor(owner)
	print("...........AllResultScene:ctor")
	-- printTable(data)

	local data  = owner.allResultData
	-- local data = {
 --  	   ["result_list"] = {
 --    		 {
 --      			   ["chips"] = 10,
 --      			   ["uid"] = 10804,
 --      			   ["total_score"] = 0,
 --      		},
 --    		 {
 --      			   ["chips"] = 1000,
 --      			   ["uid"] = 10803,
 --      			   ["total_score"] = 1000,
 --      		},
 --    		 {
 --      			   ["chips"] = 100000,
 --      			   ["uid"] = 10764,
 --      			   ["total_score"] = -10000,
 --      		},
 --    	},
 --  	}

	self.owner = owner
	self:initData(data)
	self:initView()
	self:initEvent()
end
function AllResultScene:initData(data)
	self.data = data
end
function AllResultScene:initView()
	self.widget = cc.CSLoader:createNode("ui/result/allResultView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.returnbtn  = self.mainLayer:getChildByName("returnbtn")
	WidgetUtils.addClickEvent(self.returnbtn, function( )
		-- LaypopManger_instance:back()
		glApp:enterSceneByName("MainScene")
	end)
	self.sharebtn = self.mainLayer:getChildByName("sharebtn")
	WidgetUtils.addClickEvent(self.sharebtn, function( )
		self:shareBtnCall()
	end)
	if SHENHEBAO then
		self.sharebtn:setVisible(false)
	end


	self:setGameInfo()
	self:setPlayerInfo()
end
function AllResultScene:setGameInfo()

	if self.owner == nil then
		return
	end

	-- left_info
	local roomInfo = self.mainLayer:getChildByName("left_info"):getChildByName("roomInfo")
	local nameStr = GT_INSTANCE:getGameName(self.owner:getTableConf().ttype)
	local jushuStr = "第"..self.owner:getNowRound().."/"..self.owner:getTableConf().round.."局"
	local roomidStr = "房间ID:"..self.owner:getTableID()
	if self.owner:getTableConf().is_free_game then
		roomidStr = "试玩场"
	end
	roomInfo:setString(nameStr.."   "..jushuStr.."   "..roomidStr)

	-- right_info
	local right_info = self.mainLayer:getChildByName("right_info")
	right_info:getChildByName("guize"):setString(GT_INSTANCE:getTableDes(self.owner:getTableConf(),3))

	-- time_info
	self.mainLayer:getChildByName("time_info"):getChildByName("time"):setString(os.date("%Y-%m-%d  %H:%M"))
end




function AllResultScene:setPlayerInfo()

	if #self.data.result_list == 3 then
		self.mainLayer:getChildByName("item_4"):setVisible(false)

		self.mainLayer:getChildByName("item_1"):setPositionX(-329.00)
		self.mainLayer:getChildByName("item_2"):setPositionX(0)
		self.mainLayer:getChildByName("item_3"):setPositionX(329)

	elseif #self.data.result_list == 2 then

		self.mainLayer:getChildByName("item_3"):setVisible(false)
		self.mainLayer:getChildByName("item_4"):setVisible(false)

		self.mainLayer:getChildByName("item_1"):setPositionX(-200)
		self.mainLayer:getChildByName("item_2"):setPositionX(200)
	end

	-- 得到大赢家
	local function getDaYingJia(data)
		local val = 0
		for i,v in ipairs(data) do
			if v.total_score > val then
				val = v.total_score 
			end
		end
		return val
	end

	local maxsocre = getDaYingJia(self.data.result_list)
	for i,v in ipairs(self.data.result_list) do
		local item = self.mainLayer:getChildByName("item_"..i)
		if not item then
			break
		end
		local headicon = item:getChildByName("headicon")
		local name = item:getChildByName("name")
		local id = item:getChildByName("id")

		local dayingjia = item:getChildByName("dayingjia"):setVisible(false)
		local fangzhu = item:getChildByName("fangzhu"):setVisible(false)

		if 	self.owner then
			local playinfo = self.owner:getUserInfoByUid(v.uid)
			if playinfo then
				local headicon = require("app.ui.common.HeadIcon").new(headicon,playinfo.role_picture_url).headicon
				
				local size =  headicon:getContentSize()
				headicon:setScaleX(76/size.width)
		        headicon:setScaleY(76/size.height)

				name:setString(ComHelpFuc.getStrWithLength(playinfo.nick,12))
			else
				name:setString("信息丢失")
			end
		end

		id:setString("ID:"..v.uid)


		--房卡
		local fankaNode = item:getChildByName("fangkabg"):getChildByName("fankaNode")
		local fangkaIcon = fankaNode:getChildByName("Image_4")
		local fangkanum = fankaNode:getChildByName("num")
		fangkanum:setString("剩余"..v.chips)
		fangkanum:setPositionX(0)

		local _w = fangkanum:getContentSize().width
		fangkaIcon:setPositionX(_w + 10)

		_w = _w + fangkaIcon:getContentSize().width
		fankaNode:setPositionX(121.00-_w/2.0)


		--分数
		local scoreNode = item:getChildByName("scoreNode")
		local allscoreIcon =  scoreNode:getChildByName("allscore")
		local scorenum =  scoreNode:getChildByName("scorenum")

		local score_abs = math.abs(v.total_score)
		_w = allscoreIcon:getContentSize().width+5
		allscoreIcon:setPositionX(0)

		scorenum:setPositionX(_w)
		if  v.total_score > 0 then
			scorenum:setString("+"..score_abs)

			scorenum:setColor(cc.c3b( 0xff, 0xab, 0x25))
			scorenum:enableOutline(cc.c3b( 0x62, 0x3c, 0x17),2)

		elseif v.total_score == 0 then

			scorenum:setString(score_abs)
			
			scorenum:setColor(cc.c3b( 0xff, 0xff, 0xff))
			scorenum:enableOutline(cc.c3b( 0x51, 0x30, 0x21),2)
		else
			scorenum:setString("-"..score_abs)
			scorenum:setColor(cc.c3b( 0x70, 0xbc, 0xff))
			scorenum:enableOutline(cc.c3b( 0x19, 0x50, 0x7e),2)
		end
		_w = _w + scorenum:getContentSize().width
		scoreNode:setPositionX(144.00-_w/2.0)


		if v.total_score == maxsocre and maxsocre ~= 0 then
        	dayingjia:setVisible(true)
        end
        if	self.owner  and self.owner:getTableCreaterID() == v.uid then
        	fangzhu:setVisible(true)
        end
	end
end
function AllResultScene:shareBtnCall()
	print("分享")
	CommonUtils.shareScreen()
end
function AllResultScene:initEvent()

end
return AllResultScene