
require "app.help.ComNoti"
require "app.help.WidgetUtils"
Cards = require "app.ui.game.Card"



--   	   ["isDissmissDeal"] = 0,
--   	   ["carddata"] = 0,
--   	   ["keytype"] = "3;4;1",
--   	   ["status"] = 0,
--   	   ["mouseCardDataList"] = {
--     	},
--   	   ["diCardCount"] = 136,
--   	   ["curPlayerFlag"] = 0,
--   	   ["mouseType"] = 1,
--   	   ["isGangMoouse"] = 1,
--   	   ["totalGameNums"] = 4,
--   	   ["roomnum"] = 421973,
--   	   ["curBanker"] = 0,
--   	   ["curGameNums"] = 0,
--   	   ["curPlayerIndex"] = 0,
--   	   ["roomPlayerItemJsons"] = {
--     		 {
--       			   ["playerid"] = 10034,
--       			   ["nickname"] = "游客",
--       			   ["sex"] = 1,
--       			   ["openid"] = "1484896578",
--       			   ["isrequestdismiss"] = 0,
--       			   ["curGameStatus"] = 0,
--       			   ["isshowdismiss"] = 0,
--       			   ["ip"] = "171.212.113.14",
--       			   ["index"] = 1,
--       			   ["isPlayCard"] = 0,
--       			   ["headimgurl"] = "",
--       			   ["userid"] = "8f448533bb804959aceb840341b79b93",
--       			   ["score"] = 0,
--       		},
--     	},
--   }
local MajiangScene = class("MajiangScene",function()
    return cc.Scene:create()
end)

local testtime1 = 0
local testime2 = 0
function MajiangScene:ctor(data)
	GAME_SELECT_TYPE = 3
	MATYPETYPE = data.gamematype
	self.voicelist = {}
	self.gameplayernums = data.gameplayernums
	if self.gameplayernums == 5 then
		self.isfive = true
	end
	--gamenums,gameplayernums,gameusecoinstype,gameplaygun,gamequanleida
	self.ismyturn = false
	AudioUtils.stopMusic(true)
	self.confstr =""
	self.confstr = self.confstr..data.totalGameNums.."局 "


	self.gamestatus = data.status
	self.data = data
	self.tableid = data.roomnum
	for i,v in ipairs(data.roomPlayerItemJsons) do
		if v.userid == LocalData_instance:getUid() then
			self.myindex = v.index
		end
	end
	self:initEvent()
	self:initview()
	  local function update()
		self:playVoice()
	end
	self:scheduleUpdateWithPriorityLua(update,0)
end
function MajiangScene:onExit()

end
function MajiangScene:initview()
	--Socketapi.readyaction()
	if self.gameplayernums == 5 then
		self.layout = cc.CSLoader:createNode("ui/game/game5/gamelayer1.csb")
	else
		self.layout = cc.CSLoader:createNode("ui/game/gamelayer.csb")
	end
	self:addChild(self.layout)
	self.cuolayer = self.layout:getChildByName("cuo")
	WidgetUtils.setBgScale(WidgetUtils.getNodeByWay(self.layout,{"bg"}))
	self.mainlayer = WidgetUtils.getNodeByWay(self.layout,{"main"})
	WidgetUtils.setScalepos(self.mainlayer)
	self.lastlabel = WidgetUtils.getNodeByWay(self.mainlayer,{"last"})
	self.talklayer = WidgetUtils.getNodeByWay(self.mainlayer,{"talklayer"})
	self.tableidlable = WidgetUtils.getNodeByWay(self.mainlayer,{"tableid"})
	self.talklayer:setLocalZOrder(100)
	WidgetUtils.setScalepos(WidgetUtils.getNodeByWay(self.mainlayer,{"top"}))
	WidgetUtils.setScalepos(WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}))
	--WidgetUtils.setScalepos(WidgetUtils.getNodeByWay(self.mainlayer,{"painode"}))
	self:inittalkview()
	self.tableidlable:setString("房间:"..self.tableid)
	self.ju = WidgetUtils.getNodeByWay(self.mainlayer,{"ju"})
	self.tips = WidgetUtils.getNodeByWay(self.mainlayer,{"tips"})
	self.tips:getChildByName("confstr"):setString("等待牌局开始...")
	self.painode = WidgetUtils.getNodeByWay(self.mainlayer,{"painode"})
	local wanfa = {"明牌抢庄","通比牛牛","自由抢庄","固定庄家","牛牛上庄","明牌抢庄牛几几倍","下注抢庄牛几几倍","自由抢庄牛几几倍","赖子玩法牛几几倍"}
	self.confstr = self.confstr..wanfa[self.data.gamebankertype].." "
	if self.data.gameusecoinstype == 1 then
		self.confstr = self.confstr.."房主支付".." "
	elseif self.data.gameusecoinstype == 2 then
		self.confstr = self.confstr.."AA支付".." "
	elseif self.data.gameusecoinstype == 3 then
		self.confstr = self.confstr.."代开房".." "
	end
	if self.isfive == true then
		local str = "房间:"..self.tableid
		str = str.."("..self.data.totalGameNums.."局 "..wanfa[self.data.gamebankertype].." "
			if self.data.gamecardnums == 1 then
				str = str.."一副牌 "
			elseif self.data.gamecardnums == 2 then
				str = str.."两副牌 "
			end
			if self.data.gameusecoinstype == 1 then
				str = str.."房主支付"
			elseif self.data.gameusecoinstype == 2 then
				str = str.."AA支付"
			elseif self.data.gameusecoinstype == 3 then
				str = str.."代开房"
			end
			str = str..")"
		self.tableidlable:setString(str)
	else
		WidgetUtils.getNodeByWay(self.mainlayer,{"wanfa"}):setString("玩法:"..wanfa[self.data.gamebankertype])
		if self.data.gamebankertype~= 2 and self.data.gamebankertype~= 6 and self.data.gamebankertype~= 7 and self.data.gamebankertype~= 8 and self.data.gamebankertype~= 9 then
			if self.data.gamediscoretype == 1 then
				WidgetUtils.getNodeByWay(self.mainlayer,{"difen"}):setString("底分:1-2")
			elseif self.data.gamediscoretype == 2 then
				WidgetUtils.getNodeByWay(self.mainlayer,{"difen"}):setString("底分:2-4")
			elseif self.data.gamediscoretype == 4 then
				WidgetUtils.getNodeByWay(self.mainlayer,{"difen"}):setString("底分:4-8")
			elseif self.data.gamediscoretype == 5 then
				WidgetUtils.getNodeByWay(self.mainlayer,{"difen"}):setString("底分:5-10")
			elseif self.data.gamediscoretype == 10 then
				WidgetUtils.getNodeByWay(self.mainlayer,{"difen"}):setString("底分:10-20")
			end
		elseif self.data.gamebankertype == 2 then
			WidgetUtils.getNodeByWay(self.mainlayer,{"difen"}):setString("底分:"..self.data.gamediscoretype)
		elseif self.data.gamebankertype~= 6 and self.data.gamebankertype~= 7 and self.data.gamebankertype~= 8 and self.data.gamebankertype~= 9 then
			WidgetUtils.getNodeByWay(self.mainlayer,{"difen"}):setString("底分:1")
		else
			WidgetUtils.getNodeByWay(self.mainlayer,{"difen"}):setVisible(false)
		end
	end
	WidgetUtils.setScalepos(self.painode)
	self.copylable = WidgetUtils.getNodeByWay(self.mainlayer,{"label"})
	self.kaipaibtn1 = WidgetUtils.getNodeByWay(self.mainlayer,{"painode","kaibtn11"})
	self.kaipaibtn2 = WidgetUtils.getNodeByWay(self.mainlayer,{"painode","kaibtn12"})

	self.kanpaibtn1 = WidgetUtils.getNodeByWay(self.mainlayer,{"painode","kanbtn1"})
	self.kanpaibtn2 = WidgetUtils.getNodeByWay(self.mainlayer,{"painode","kanbtn2"})


	self.kaipaibtn1:setVisible(false)
	self.kaipaibtn2:setVisible(false)

	self.kanpaibtn1:setVisible(false)
	self.kanpaibtn2:setVisible(false)

	WidgetUtils.addClickEvent(self.kaipaibtn1, function( )
		Socketapi.doaction(3)
		self.kaipaibtn1:setVisible(false)
		self.kaipaibtn2:setVisible(false)
	end)
	WidgetUtils.addClickEvent(self.kaipaibtn2, function( )
		--Socketapi.doaction(3)
		self.kaipaibtn1:setVisible(false)
		self.kaipaibtn2:setVisible(false)
		if tolua.cast(self.gameview,"cc.Node") then
			self.gameview.tableviews[1]:showhandtip()
		end
	end)


	WidgetUtils.addClickEvent(self.kanpaibtn1, function( )
		self.kanpaibtn1:setVisible(false)
		self.kanpaibtn2:setVisible(false)
		self.kaipaibtn1:setVisible(true)
		self.kaipaibtn2:setVisible(true)
		if tolua.cast(self.gameview,"cc.Node") then
			self.gameview:fanpanall()
		end
	end)
	WidgetUtils.addClickEvent(self.kanpaibtn2, function( )
		self.kanpaibtn1:setVisible(false)
		self.kanpaibtn2:setVisible(false)
		self.kaipaibtn1:setVisible(true)
		self.kaipaibtn2:setVisible(true)
		if tolua.cast(self.gameview,"cc.Node") then
			self.gameview:cuopai()
		end
	end)



	self.actionnode = WidgetUtils.getNodeByWay(self.mainlayer,{"actionnode"})
	self.actionnode:setLocalZOrder(2)
	--self.actionnode:setVisible(false)
	self.dianliang = WidgetUtils.getNodeByWay(self.mainlayer,{"top","dian","dian"})
	if WidgetUtils.getNodeByWay(self.mainlayer,{"dian"}) then
		self.dianliang1 = WidgetUtils.getNodeByWay(self.mainlayer,{"dian","dian"})
	end
	self.wifi = WidgetUtils.getNodeByWay(self.mainlayer,{"top","wifi"})
	self:setDianliang()
	self.btnnode = WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"})

	self.timelabel = WidgetUtils.getNodeByWay(self.mainlayer,{"time"})
	 self.timelabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
        local date = os.date("%X")

        local datetab = os.date("*t",os.time())
		local string = datetab.year.."/"..datetab.month.."/"..datetab.day.." "..datetab.hour
		if datetab.min >= 10 then
			string = string..":"..datetab.min
		else
			string = string..":0"..datetab.min
		end

        self.timelabel:setString(string)
    end),cc.DelayTime:create(1))))

	self.setbtn = WidgetUtils.getNodeByWay(self.mainlayer,{"setbtn"})

	WidgetUtils.addClickEvent(self.setbtn, function( )
		--SocketConnect_instance.socket:close()
		LaypopManger_instance:PopBox("SetView",2,self)
	end)
	WidgetUtils.addClickEvent(WidgetUtils.getNodeByWay(self.mainlayer,{"guibtn"}), function( )
		--SocketConnect_instance.socket:close()
		-- if true then
		-- 	LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "规则确定中，当前屏蔽功能",sureCallFunc = function()
				
		-- 	end})
		-- end
		LaypopManger_instance:PopBox("Guiview",self.data)
	end)
	self.exitbtn = WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode","exit1"})
	WidgetUtils.addClickEvent(self.exitbtn, function( )
		
		self:exitbtncall()
	end)
	self.exitbtn1 = WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode","exit2"})
	WidgetUtils.addClickEvent(self.exitbtn1, function( )
		
		self:exitbtncall()
	end)

	self.readybtn = WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode","readybtn"})
	WidgetUtils.addClickEvent(self.readybtn, function( )
		if  self.iswait then
			self.readybtn:setVisible(false)
			self.exitbtn1:setVisible(false)
		end
		Socketapi.readyaction()
		self.xiazhuang:setVisible(false)
	end)
	self.xiazhuang = WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode","xiazhuang2"})
	self.lianzhuang = WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode","xiazhuang1"})
	WidgetUtils.addClickEvent(self.xiazhuang, function( )
		self.xiazhuang:setVisible(false)
		self.lianzhuang:setVisible(false)
		Socketapi.readyaction(true)
	end)

	
	WidgetUtils.addClickEvent(self.lianzhuang, function( )
		self.xiazhuang:setVisible(false)
		self.lianzhuang:setVisible(false)
		Socketapi.readyaction(false)
	end)

	self.beiginbtn = WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode","beiginbtn"})
	WidgetUtils.addClickEvent(self.beiginbtn, function( )
		
		Socketapi.beiginaction()
	end)
	self.beiginbtn:setVisible(false)

	self.talkbtn = WidgetUtils.getNodeByWay(self.mainlayer,{"talkbtn"})
	WidgetUtils.addClickEvent(self.talkbtn, function( )
		self.talklayer:setVisible(true)
	end)

	self.voicebtn = WidgetUtils.getNodeByWay(self.mainlayer,{"voicebtn"})
	require('app.ui.common.VoiceView').new(self.voicebtn)

	self.yaoqingbtn = WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode","invbtn"})
	WidgetUtils.addClickEvent(self.yaoqingbtn, function( )
		print(self.confstr)
		CommonUtils.sharedesk(self.tableid,self.confstr,"大众牛牛")
	end)

	self.fuzhi = WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode","fuzhi"})
	WidgetUtils.addClickEvent(self.fuzhi, function( )
		CommonUtils.copyfang(self.tableid)
	end)
	self.xiazhu = self.painode:getChildByName("goldxia")
	self.xiazhu:setVisible(false)
	self.icon = {}
	for i=1,self.gameplayernums do
		self.icon[i] = WidgetUtils.getNodeByWay(self.mainlayer,{"iconbg"..(i)})
		self.icon[i]:setVisible(false)
		--WidgetUtils.getNodeByWay(self.icon[i],{"icon"}):setLocalZOrder(-1)
		self.icon[i]:getChildByName("goldxia"):setVisible(false)
		self.icon[i]:setLocalZOrder(3)

	end

	-- 中间指针
	--WidgetUtils.getNodeByWay(self.mainlayer,{"nodemid","midbg"}):setRotation((self.myindex-1)*90)


	
	-- 是否存在重连解散房间
	if self.data.requestDismissUserid then
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function( )
			self.DissolveView = LaypopManger_instance:PopBox("DissolveView",self.data)
		end)))
		
	end
	print("游戏状态:"..self.data.status)
	self:updatainfo(self.data)

	for i,v in ipairs(self.data.roomPlayerItemJsons) do
		if v.index == self:getMyIndex() then
			if v.showBankerOptionType == 1  then
				self.needshowxiazhuang = true
			else
				self.needshowxiazhuang = false
			end
		end
	end
	self:updatainfo(self.data)

	if self.myindex == 1 then
		self.exitbtn:setVisible(true)
		self.exitbtn1:setVisible(false)
	else
		self.exitbtn:setVisible(false)
		self.exitbtn1:setVisible(true)
	end

	if self.data.status == 1 then
		self:setregamestart(self.data)
	elseif self.data.status == 2 then
		WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}):setVisible(false)
		--Socketapi.readyaction()
	elseif self.data.status == 0 then
		WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}):setVisible(true)
		self.isfirist = true
	elseif self.data.status == - 1 then
		WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}):setVisible(true)
		self.isfirist = true
	else
		print("等待中")
	end
	

	self:setTip()
end
function MajiangScene:getSex(index)
	for i,v in ipairs(self.data.roomPlayerItemJsons) do
		if v.index == index then
			print("find")
			return v.sex
		end
	end
	return 1
end

function MajiangScene:setDianliang()

	local function doaction1()
		CommonUtils.getDianliangLevel(function(value)
			self.dianliang:setPercent(value)
			if self.dianliang1 then
				self.dianliang1:setPercent(value)
			end
		end)
	end
	doaction1()
	self.dianliang:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(10),cc.CallFunc:create(function()
		doaction1()
	end))))
	-- 后去网络信息
	local function doaction2()
		self.wifi:setTexture("game/wifi/wifi"..Notinode_instance.netstate..".png")
	end

	self.wifi:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
		doaction2()
	end))))
end

function MajiangScene:setTip(index,bool,time)
	

end
function MajiangScene:exitbtncall()
	if  self.iswait  then
		Socketapi.sendexit()
	end
	if self.gamestatus == 0 or self.gamestatus == -1 then
		if self.myindex == 1 and self.data.gameusecoinstype ~= 4 then
			LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "是否确定退出房间?(不消耗房卡)",sureCallFunc = function()
				Socketapi.sendexit()
			end})
		else
			Socketapi.sendexit()
		end
	else
		LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "是否解散房间？",sureCallFunc = function()
			Socketapi.sendjiesan()
		end})
	end
end

function MajiangScene:readycanell(data)
	if data.result == 1 then
		self.readybtn:setVisible(false)
	end
end


function MajiangScene:updatainfo(data)
	self.gamestatus = data.status
	self.data = data
	self.diCardCount = data.diCardCount
	--self.pailast:setString(self.diCardCount)
	if self.isfive then
		self.ju:setString("第"..data.curGameNums.."/"..data.totalGameNums.."局")
	else
		self.ju:setString("局："..data.curGameNums.."/"..data.totalGameNums)
	end
	self.curGameNums =data.curGameNums
	if self.gamestatus ~= -1 then
		self.exitbtn:setVisible(false)
		self.exitbtn1:setVisible(false)
	else
		--self.exitbtn:setVisible(true)
		WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}):setVisible(true)
	end
	self:updataicon(data)
	-- if #data.roomPlayerItemJsons == self.gameplayernums then
	-- 	self:showip()
	-- 	--self.isfirist = false
	-- else
	-- 	self.isfirist = true
	-- end
end
function MajiangScene:updataicon(data,isgamestart)
	for i,v in ipairs(self.icon) do
		v:setVisible(false)
	end
	for i,v in ipairs(data.roomPlayerItemJsons) do
		if v.userid == LocalData_instance:getUid() then
			self.myindex = v.index
		end
	end
	local iswait = false
	print("updataicon")
	for i,v in ipairs(data.roomPlayerItemJsons) do
			local localindex = self:getLocalindex(v.index)
			print(localindex)
			self.icon[localindex]:setVisible(true)
			self.icon[localindex].curdata = v
			self.icon[localindex]:getChildByName("name"):setString(ComHelpFuc.getStrWithLengthByJSP(v.nickname))
			self.icon[localindex]:getChildByName("fen"):setString(v.score)
			self.icon[localindex]:getChildByName("zhuang"):setVisible(false)
			self.icon[localindex]:getChildByName("zhuang1"):setVisible(false)
			local icon  = self.icon[localindex]:getChildByName("icon")
			--if icon.iscreate == nil then
			if self.isfive then
				require("app.ui.common.HeadIcon_Club").new(icon,v.headimgurl,88)
			else
				require("app.ui.common.HeadIcon_Club").new(icon,v.headimgurl,80)
			end

			WidgetUtils.addClickEvent(self.icon[localindex], function( )
				print("用户协议")
				LaypopManger_instance:PopBox("PlayerInfoViewforgame",v,self.myindex,v.index)
			end)

			if v.curGameStatus == 0 and isgamestart == nil then

				self.icon[localindex]:getChildByName("ready"):setVisible(true)
				-- if isgamestart == nil and self:getMyIndex() == 1 then
				-- 	self.beiginbtn:setVisible(true)
				-- 	self.readybtn:setVisible(false)
				-- end
				if  v.index == self:getMyIndex() then
					self.xiazhuang:setVisible(false)
					self.lianzhuang:setVisible(false)
					self.readybtn:setVisible(false)
				end
			else
				if isgamestart == nil and (self.data.roomHostUserid == LocalData_instance.userid) and self.data.curGameNums == 0 then
					self.beiginbtn:setVisible(true)
					self.readybtn:setVisible(false)
				else
					if self.needshowxiazhuang and self:getMyIndex() == v.index  then
						self.xiazhuang:setVisible(true)
						self.lianzhuang:setVisible(true)
						self.readybtn:setVisible(false)
						self.needshowxiazhuang = false
					elseif self:getMyIndex() == v.index  then
						if self.data.curGameNums == 0 then
							self.readybtn:setVisible(true)
						end
					end
				end
				self.icon[localindex]:getChildByName("ready"):setVisible(false)
			end

			if data.curBanker == v.index then
				self.icon[localindex]:getChildByName("zhuang"):setVisible(true)
				self.icon[localindex]:getChildByName("zhuang1"):setVisible(true)
			else
				self.icon[localindex]:getChildByName("zhuang"):setVisible(false)
				self.icon[localindex]:getChildByName("zhuang1"):setVisible(false)
			end
			if self.myindex == v.index then
				if v.curJoinGameStatus == 1 then
					self.iswait = true
					self.icon[localindex]:setColor(cc.c3b(0x99, 0x99, 0x99))
				else
					self.icon[localindex]:setColor(cc.c3b(255, 255, 255))
					self.iswait = false
				end
			end

	end
	if self.iswait then
		self.readybtn:setVisible(true)
		self.exitbtn:setVisible(false)
		self.exitbtn1:setVisible(true)
		self.beiginbtn:setVisible(false)
		self.yaoqingbtn:setVisible(false)
		self.fuzhi:setVisible(false)
		WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}):setVisible(true)
	else
		if #data.roomPlayerItemJsons  == self.gameplayernums and self.gamestatus == 0 then
			WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}):setVisible(false)
			
		end
	end
end
function MajiangScene:setregamestart(data)
	self.gameisstare =true
	self:setgamestart(data,true)
	self:settipsstr(data,true)
end
function MajiangScene:setgamestart(data,isre)
	if isre then
	else
		AudioUtils.playEffect("niu_start")
	end
	-- if self.data.gamebankertype == 4  then
	-- 	self.xiazhu:setVisible(true)
	-- 	self.xiazhu:getChildByName("text"):setString(data.curPoolScore)
	-- end
	if isre then
	else
		if data.curGameNums == 0 then
			self:showip()
		end
	end
	self.needshowxiazhuang = false
	self.xiazhuang:setVisible(false)
	self.lianzhuang:setVisible(false)
	self.gameisstare =true
	if self.isfive then
		self.xiazhu:setVisible(false)
	end
	for i=1,self.gameplayernums do
		self.icon[i] = WidgetUtils.getNodeByWay(self.mainlayer,{"iconbg"..(i)})
		if WidgetUtils.getNodeByWay(self.icon[i],{"goldxia"}) then
			WidgetUtils.getNodeByWay(self.icon[i],{"goldxia"}):setVisible(false)
		end

	end
	if self.iswait then
		WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}):setVisible(true)
	else
		WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}):setVisible(false)
	end
	self.data = data 
	self.isfirist = false
	self.gamestatus = 2
	self.lastaction = nil
	self.lastoneaction = nil
	self.curBanker = data.curBanker
	if self.isfive then
		self.ju:setString("第"..data.curGameNums.."/"..self.data.totalGameNums.."局")
	else
		self.ju:setString("局："..data.curGameNums.."/"..self.data.totalGameNums)
	end
	self.curGameNums =data.curGameNums
	-- body
	if tolua.cast(self.gameview,"cc.Node") then
		self.gameview:removeFromParent()
	end
	

	self:updataicon(self.data,true)
	self.gameview = require "app.ui.game.GameView".new(self,data,false)
	self.gameview:setPosition(cc.p(0,0))
	self.mainlayer:addChild(self.gameview)
	
end
--{"curQuan":0,"curBanker":1,"curGameNums":1,"index":1,"score":0,"curCards":[4,5,6,9,11,12,13,14,17,24,24,25,26,28],"curOutCards":[],"isPlayCard":1,"curDeskCardsItems":[],"playTypes":[7],"curPlayerIndex":1,"curPlayerFlag":1,"diCardCount":83,"keytype":"3;4;2"}


--可出牌类型：-1:无操作 1:暗杠2:明杠3:听牌4:碰5:弯杠6胡牌
--7:出牌8:过)

function MajiangScene:initEvent()
	ComNoti_instance:addEventListener("3;2;3;2",self,self.setgamestart)
	ComNoti_instance:addEventListener("3;2;3;3",self,self.actionflag)
	ComNoti_instance:addEventListener("3;2;2;3",self,self.readycanell)
	ComNoti_instance:addEventListener("3;2;2;9",self,self.beigincallback)
	ComNoti_instance:addEventListener("3;2;3;5",self,self.doAction)
	--ComNoti_instance:addEventListener("3;2;3",self,self.responsecall)

	ComNoti_instance:addEventListener("3;2;3;8",self,self.chatmsg)
	ComNoti_instance:addEventListener("3;2;3;9",self,self.jiesan)
	ComNoti_instance:addEventListener("3;2;3;13",self,self.updatainfo)
	ComNoti_instance:addEventListener("3;2;3;10",self,self.exitgame)
	ComNoti_instance:addEventListener("3;2;3;6",self,self.gameover)
	ComNoti_instance:addEventListener("3;2;3;7",self,self.gameoverAll)


	ComNoti_instance:addEventListener("3;2;3;4",self,self.fapaiaction)
	ComNoti_instance:addEventListener("3;2;3;14",self,self.settipsstr)
end
function MajiangScene:settipsstr( data,isre)
	local strtab = {"抢庄中","下注中","开牌中","结算中","等待下局开始"}
	if data.curStage then
		if data.curStage ~= 4 then
			self.tips:stopAllActions()
			local time = data.surplustime
			self.tips:getChildByName("confstr"):setString(strtab[data.curStage].."("..time.."秒)")
			self.tips:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
				time = time - 1 
				if time < 0 then
					time = 0
				end
				self.tips:getChildByName("confstr"):setString(strtab[data.curStage].."("..time.."秒)")
			end))))
		else
			self.tips:stopAllActions()
			if isre then
				local time =data.surplustime + data.surplustimeextra
				self.tips:getChildByName("confstr"):setString("等待牌局开始".."("..time.."秒)")
				self.tips:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
					time = time - 1 
					if time < 0 then
						time = 0
					end
					self.tips:getChildByName("confstr"):setString("等待牌局开始".."("..time.."秒)")
				end))))
			else
				local time1 = data.surplustime
				local time2 = data.surplustimeextra
				self.tips:getChildByName("confstr"):setString("结算中".."("..time1.."秒)")
				self.tips:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
					time1 = time1 - 1 
					if time1 <= 0 then
						if time2 then
							if time2 == data.surplustimeextra and  tolua.cast(self.gameview,"cc.Node") then
								self.gameview:removeFromParent()
								if self.iswait then
								else
									self.btnnode:setVisible(true)
									self.readybtn:setVisible(true)
									self.exitbtn:setVisible(false)
									self.exitbtn1:setVisible(false)
									self.beiginbtn:setVisible(false)
									self.yaoqingbtn:setVisible(false)
									self.fuzhi:setVisible(false)
									if self.needshowxiazhuang  then
										self.xiazhuang:setVisible(true)
										self.lianzhuang:setVisible(true)
										self.readybtn:setVisible(false)
									end
								end
							end
							time2 = time2 - 1
							if time2 <= 0 then
								time2 = 0
							end
							self.tips:getChildByName("confstr"):setString("等待牌局开始".."("..time2.."秒)")
						end
					else
						self.tips:getChildByName("confstr"):setString("结算中".."("..time1.."秒)")
					end
				end))))
			end
		end
	
	end
end
function MajiangScene:beigincallback( data )
	if data.result == 0 then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info,sureCallFunc = function()
			
		end})
	end
end
function MajiangScene:responsecall( data )
	-- if data.result == 0 then
	-- 	LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "摆牌错误",sureCallFunc = function()
			
	-- 	end})
	-- end
end

--操作
function MajiangScene:actionflag(data)
	self.gameview:showAction(data)
	--self.icon[1]:setVisible(false)
end
--摸牌
function MajiangScene:moAction(data)

end

function MajiangScene:getMyIndex()
	return self.myindex
end


function MajiangScene:getLocalindex(index)
	local localindex = 1
	if index - self.myindex >= 0 then
		localindex = index - self.myindex + 1
	else
		localindex = index - self.myindex + self.gameplayernums+1
	end
	return localindex
end



--1:拢2:招3:报牌4:碰5:吃6:胡7:特殊天胡8:出牌9:过10:畏)
function MajiangScene:doAction(data )
	local locaindex  =self:getLocalindex(data.index)
	if data.actiontype == 2 or data.actiontype == 4 then
		self.gameview:xiazhu(data)
		if  data.isplaybanker == 1 then
			print("打庄")
		end
		if locaindex == 1 then
			self.actionnode:getChildByName("node"):removeAllChildren()
		end
	elseif data.actiontype == 3 then
		self.gameview:kaipai(data)
		if locaindex == 1 then
			self.kaipaibtn1:setVisible(false)
			self.kaipaibtn2:setVisible(false)
			self.kanpaibtn1:setVisible(false)
			self.kanpaibtn2:setVisible(false)
			self.cuolayer:setVisible(false)
			self.cuolayer:removeAllChildren()
		end
	elseif data.actiontype == 1 then
		if data.curBanker  and data.curBanker ~= 0 then
			AudioUtils.playEffect("niu_xuanzhuang")
			self.curBanker = data.curBanker
			self.icon[self:getLocalindex(self.curBanker)]:getChildByName("zhuang"):setVisible(true)
			self.gameview:qiangzhuang(data)
			self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function( ... )
				if self.curBanker then
					local localpos = self:getLocalindex(self.curBanker)
					for i=1,self.gameplayernums do
						if i == localpos then
						else
							self.icon[i]:getChildByName("qiang"):setVisible(false)
						end
					end

				end
			end)))
		end
		self.icon[locaindex]:getChildByName("qiang"):setVisible(true)
		if self.data.gamebankertype == 1 then
			self.icon[locaindex]:getChildByName("qiang"):setTexture("game/qiang"..data.qiangbankertimes..".png")
		else
			if data.qiangbankertimes > 0 then
				self.icon[locaindex]:getChildByName("qiang"):setTexture("game/qiang.png")
			else
				self.icon[locaindex]:getChildByName("qiang"):setTexture("game/qiang"..data.qiangbankertimes..".png")
			end
		end
		if data.qiangbankertimes > 0 then
			AudioUtils.playVoice("qiang.mp3",self:getSex(data.index))
		else
			AudioUtils.playVoice("buqiang.mp3",self:getSex(data.index))
		end
		if locaindex == 1 then
			self.actionnode:getChildByName("node"):removeAllChildren()
		end
	end
	if locaindex == 1 then
		self.actionnode:getChildByName("node"):removeAllChildren()
		--self.actionnode:getChildByName("clock"):setVisible(false)
	end
end
function MajiangScene:fapaiaction(data )
	self.gameview:fapaiaction(data)
end
function MajiangScene:gameover(data)
	
	for i,v in ipairs(data.gameendinfolist) do
		if v.index == self:getMyIndex() then
			if v.showBankerOptionType == 1  then
				self.needshowxiazhuang = true
			else
				self.needshowxiazhuang = false
			end
		end
	end
	self.gameview:cs_notify_dn_game_over(data)
end
function MajiangScene:gameoverAll(data)
	local time = 0
	if data.dismisstype == 2 then
		time=  4
	end
	self:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function ( ... )
		self:setTip()
		if tolua.cast(self.DissolveView,"cc.Node") ~= nil then
			LaypopManger_instance:PopBox("AllResultView",data)
			return
		elseif self.isshowresult then
			self.allresult = data
			return
		end
		if tolua.cast(self.SingleResultView,"cc.Node") == nil then
			LaypopManger_instance:PopBox("AllResultView",data)
		else
			self.allresult = data
		end
	end)))
end
function MajiangScene:exitgame(data)
	glApp:enterSceneByName("MainScene")
end

function MajiangScene:getSex(index)
	for i,v in ipairs(self.data.roomPlayerItemJsons) do
		if v.index == index then
			print("find")
			return v.sex
		end
	end
	return 1
end
function MajiangScene:getSexByUid(index)
	for i,v in ipairs(self.data.roomPlayerItemJsons) do
		if v.index == index then
			print("find")
			return v.sex
		end
	end
	return 1
end

-- ["content"] = "{\"type\":3,\"id\":{\"result\":\"0\",\"time\":\"3200\",\"url\":\"http://store.aiwaya.cn/amr58971ffa4033f20c7bece6ad.amr\"}}",
  	   --["userid"] = "566ec88e7fb2480b96f7a3877151dcd8",
  	   --["keytype"] = "3;4;8",
function MajiangScene:chatmsg( data,isaction)
	print("接受到聊天消息")
	local datajson = data.content
	local datatab = cjson.decode(datajson)
	local index  =nil 
	for i,v in ipairs(self.data.roomPlayerItemJsons) do
		if v.userid == data.userid then
			index = v.index
		end
	end
	if index == nil then
		return 
	end
	if datatab.type == 3 and isaction == nil then
		table.insert(self.voicelist,data)
		return
	end
	local localindex = self:getLocalindex(index)
	local chatnode = self.icon[localindex]:getChildByName("nodechat")
	local allchren = chatnode:getChildren()
	for i,v in ipairs(allchren) do
		v:setVisible(false)
	end
	chatnode:stopAllActions()
	if datatab.type == 1 then
		local qipao = chatnode:getChildByName("qipao")
		local text = chatnode:getChildByName("text")
		qipao:setVisible(true)
		text:setVisible(true)
		text:setString(self.texttab[datatab.id])
		AudioUtils.playVoice("chat"..datatab.id..".mp3",self:getSex(index))
		chatnode:runAction(cc.Sequence:create(cc.DelayTime:create(4),cc.CallFunc:create(function( )
			local allchren = chatnode:getChildren()
			for i,v in ipairs(allchren) do
				v:setVisible(false)
			end
		end)))
	elseif datatab.type == 2 then
		cc.SpriteFrameCache:getInstance():addSpriteFrames("biaoqingbao/biaoqing.plist", "biaoqingbao/biaoqing.pvr.ccz")
		local node = chatnode:getChildByName("node")
		node:setVisible(true)
		node:removeAllChildren()
		local path = ""
		if datatab.id >= 10 then
			path=  "biaoqingbao/biaoqing"..datatab.id..".csb"
		else
			path=  "biaoqingbao/biaoqing0"..datatab.id..".csb"
		end
		local actionnode =  cc.CSLoader:createNode(path)
		action = cc.CSLoader:createTimeline(path)
		actionnode:runAction(action)
		action:gotoFrameAndPlay(0,false)
		node:addChild(actionnode)
		chatnode:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function( )
			local allchren = chatnode:getChildren()
			for i,v in ipairs(allchren) do
				v:setVisible(false)
			end
		end)))
	elseif datatab.type == 3 then
		print("播放音效")
		if device.platform == "android" or device.platform == "ios" then
			IMDispatchMsgNode:playFromUrl(datatab.id.url)
			--if IMDispatchMsgNode:playRecord(datatab.id.url) then
				--cc.SimpleAudioEngine:getInstance():pauseMusic()
				local qipao = chatnode:getChildByName("voice")
				qipao:getChildByName("text"):setString(math.floor(datatab.id.time/1000))
				qipao:setVisible(true)
				chatnode:runAction(cc.Sequence:create(cc.DelayTime:create(datatab.id.time/1000+1),cc.CallFunc:create(function( )
					local allchren = chatnode:getChildren()
					for i,v in ipairs(allchren) do
						v:setVisible(false)
					end
				end)))
			--end
		end
	elseif datatab.type == 4 then
		local qipao = chatnode:getChildByName("qipao")
		local text = chatnode:getChildByName("text")
		qipao:setVisible(true)
		text:setVisible(true)
		text:setString(datatab.id)
		--AudioUtils.playVoice("chat"..datatab.id..".mp3",self:getSex(index))
		chatnode:runAction(cc.Sequence:create(cc.DelayTime:create(4),cc.CallFunc:create(function( )
			local allchren = chatnode:getChildren()
			for i,v in ipairs(allchren) do
				v:setVisible(false)
			end
		end)))
	elseif datatab.type == 5 then
		require "app.ui.Hudongeffect"
		local localpos1 = self:getLocalindex(datatab.begin1)
		local localpos2 = self:getLocalindex(datatab.end1)
		if self.icon[localpos1] and self.icon[localpos2] then
			local pos1 = self.icon[localpos1]:convertToWorldSpace(cc.p(self.icon[localpos1]:getChildByName("icon"):getPositionX(),self.icon[localpos1]:getChildByName("icon"):getPositionY()))
			local pos2 = self.icon[localpos2]:convertToWorldSpace(cc.p(self.icon[localpos2]:getChildByName("icon"):getPositionX(),self.icon[localpos2]:getChildByName("icon"):getPositionY()))
			self:addChild(Hudongeffect.playeffect( pos1,pos2,datatab.id ))
			
		end

	end
	chatnode:setVisible(true)
end
function MajiangScene:inittalkview()

	self.texttab = {
	"财运来的时候真是挡也挡不住",
	"大家一起浪起来",
	"大牛吃小牛，不要伤心哦",
	"底牌亮出来，绝对吓死你",
	"风水轮流转，底裤都输光了",
	"开牌啊，想把牌拿回家吗",
	"哇，你真是个天生的演员",
	"我是庄家谁敢挑战我",
	"辛辛苦苦二十年，一把输到解放前",
	"一点小钱，那都不是事",
	}
	local node1 = self.talklayer:getChildByName("talk"):getChildByName("node1")
	local node2 = self.talklayer:getChildByName("talk"):getChildByName("node2")

	node1:setVisible(true)
	node2:setVisible(false)

	local function sendchat(type,id)
		local tableinfo = {}
		tableinfo.type = type
		tableinfo.id = id
		local jsonstr = json.encode(tableinfo)
		Socketapi.sendchat(jsonstr)
	end
	local btn1 = self.talklayer:getChildByName("talk"):getChildByName("yuyanbtn")
	local btn2 = self.talklayer:getChildByName("talk"):getChildByName("biaoqingbtn")
	WidgetUtils.addClickEvent(btn1, function( )
		node1:setVisible(true)
		node2:setVisible(false)
		btn1:setEnabled(false)
		btn2:setEnabled(true)
	end)
	WidgetUtils.addClickEvent(btn2, function( )
		node1:setVisible(false)
		node2:setVisible(true)
		btn1:setEnabled(true)
		btn2:setEnabled(false)
	end)
	node1:setVisible(true)
	node2:setVisible(false)
	btn1:setEnabled(false)
	btn2:setEnabled(true)
	
	WidgetUtils.addClickEvent(self.talklayer, function( )
		self.talklayer:setVisible(false)
	end)

	local item = node2:getChildByName("cell")
	item:retain()
    item:removeFromParent()

	local listView = node2:getChildByName("listview")
	listView:setItemModel(item)
	for i,v in ipairs(self.texttab) do
		listView:pushBackDefaultItem()
		local item = listView:getItem(i-1)
		local text = item:getChildByName("bg"):getChildByName("text"):setString(self.texttab[i])
		WidgetUtils.addClickEvent(item:getChildByName("bg"), function( )
			print(i)
			sendchat(1,i)
			self.talklayer:setVisible(false)
		end)
	end
	for i=1,16 do
		local btn = node1:getChildByName("btn"..i)
		WidgetUtils.addClickEvent(btn, function( )
			print(i)
			sendchat(2,i)
			self.talklayer:setVisible(false)
		end)
	end
	item:release()
	self.inputtext = self.talklayer:getChildByName("talk"):getChildByName("input")
	self.sendbtn = self.talklayer:getChildByName("talk"):getChildByName("surebtn")
	WidgetUtils.addClickEvent(self.sendbtn, function( )
		
		if self.inputtext:getString() ~= "" then
			local find =string.find(self.inputtext:getString(),"\r\n")
			if string.len(self.inputtext:getString()) > 60 then
				LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "输入文字太长了"})
			elseif find == nil then
				sendchat(4,self.inputtext:getString())
				self.inputtext:setString("")
				self.talklayer:setVisible(false)
			else
				LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "输入字符串含有非法字段"})
			end
		end
	end)
end

function MajiangScene:jiesan(data)
	if data.requestDismissUserid then
		if data.roomPlayerItemJsons == nil then
			data.roomPlayerItemJsons = {}
		end
		for i,v in ipairs(self.data.roomPlayerItemJsons) do
			data.roomPlayerItemJsons[i] = {}
			data.roomPlayerItemJsons[i].userid =v.userid
			data.roomPlayerItemJsons[i].nickname = v.nickname
			data.roomPlayerItemJsons[i].headimgurl = v.headimgurl
			data.roomPlayerItemJsons[i].dismissoptype = 0
		end

		self.DissolveView = LaypopManger_instance:PopBox("DissolveView",data)
	end
end

function MajiangScene:showip()
	local isfirst = self.isfirist
	 local function doaciton()
	 	print("show ip")
		if isfirst then
			self.isfirist = false
			local iplist = {}
			for i,v in ipairs(self.data.roomPlayerItemJsons) do
				if v.playerid ~= LocalData_instance.playerid then
					if iplist[v.ip] == nil then
						iplist[v.ip] = 1 
					else
						iplist[v.ip] = iplist[v.ip] + 1
					end
				end
			end
			local ipcommon = nil
			for k,v in pairs(iplist) do
				if v >= 2 then
					ipcommon = k
					break
				end
			end
			if ipcommon then
				print("showip 1")
				self:runAction(cc.CallFunc:create(function()
					print("showip 2")
					LaypopManger_instance:PopBox("idview",self.data,self,ipcommon)
					self.isfirist = false
				end))
				
			end
		else
			print("show ip not")
		end
	end
	self:runAction(cc.CallFunc:create(doaciton))
end
function MajiangScene:playVoice()
	if device.platform ~="android" and device.platform ~="ios" then
		return
	end
	if IMDispatchMsgNode:isPlaying() then
		return
	end
	if #self.voicelist > 0 then
		
		self:chatmsg(self.voicelist[1],true)
		table.remove(self.voicelist,1)
	end
end

return MajiangScene