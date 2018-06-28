
require "app.help.ComNoti"
require "app.help.WidgetUtils"
Cards = require "app.ui.game.Card"
local Card = require "app.ui.kutong.Card"
require "app.ui.kutong.Suanfuc"

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
	GAME_SELECT_TYPE = 2
	self.cctype = 2
	AudioUtils.playMusic("bgm3")
	MATYPETYPE = data.gamematype
	self.voicelist = {}
	self.gamestatus = data.status
	self.data = data

	self.gameplayernums = data.gameplayernums

	--gamenums,gameplayernums,gameusecoinstype,gameplaygun,gamequanleida
	self.ismyturn = false
	--AudioUtils.stopMusic(true)
	self.confstr =""
	self.confstr = self.confstr..data.gamenums.."局 "
	if self.data.gameplaytype == 1 then
		self.confstr = self.confstr .."普通玩法 "
	else
		self.confstr = self.confstr .."纯比炸 "
	end

	if self.data.gamejokertype == 1 then
		self.confstr = self.confstr .."5王算奖 "
	else
		self.confstr = self.confstr .."6王算奖 "
	end

	if self.data.gamerewardtype == 1 then
		self.confstr = self.confstr .."一奖4桶 "
	else
		self.confstr = self.confstr .."一奖6桶 "
	end

	if self.data.gamebirdtype == 1 then
		self.confstr = self.confstr .."对家进鸟王 "
	else
		self.confstr = self.confstr .."3家进鸟王 "
	end

	if self.data.gameglobaltype == 1 then
		self.confstr = self.confstr .."全球通 "
	end
	self.confstrrsult = "房间号:"..data.roomnum.." "..self.confstr
	
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
	self.layout = cc.CSLoader:createNode("ui/kutong/gamelayerkutong.csb")
	self:addChild(self.layout)
	self.cuolayer = self.layout:getChildByName("cuo")
	WidgetUtils.setBgScale(WidgetUtils.getNodeByWay(self.layout,{"bg"}))
	self.mainlayer = WidgetUtils.getNodeByWay(self.layout,{"main"})
	WidgetUtils.setScalepos(self.mainlayer)
	self.lastlabel = WidgetUtils.getNodeByWay(self.mainlayer,{"last"})
	self.talklayer = WidgetUtils.getNodeByWay(self.mainlayer,{"talklayer"})
	self.tableidlable = WidgetUtils.getNodeByWay(self.mainlayer,{"top","tableid"})
	self.talklayer:setLocalZOrder(100)
	WidgetUtils.setScalepos(WidgetUtils.getNodeByWay(self.mainlayer,{"top"}))
	WidgetUtils.setScalepos(WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}))
	WidgetUtils.setScalepos(WidgetUtils.getNodeByWay(self.mainlayer,{"painode"}))
	self:inittalkview()
	self.tableidlable:setString(self.tableid)
	self.ju = WidgetUtils.getNodeByWay(self.mainlayer,{"top","ju"})
	self.tips = WidgetUtils.getNodeByWay(self.mainlayer,{"tips"})
	if self.data.gamejokertype == 1 then
		self.tableidlable = WidgetUtils.getNodeByWay(self.mainlayer,{"top","wanfa2"}):setString("5王算奖")
	else
		self.tableidlable = WidgetUtils.getNodeByWay(self.mainlayer,{"top","wanfa2"}):setString("6王算奖")
	end

	if self.data.gamerewardtype == 1 then
		self.tableidlable = WidgetUtils.getNodeByWay(self.mainlayer,{"top","wanfa1"}):setString("一奖4桶")
	else
		self.tableidlable = WidgetUtils.getNodeByWay(self.mainlayer,{"top","wanfa1"}):setString("一奖6桶")
	end
	if self.data.gameplaytype == 1 then
	 	WidgetUtils.getNodeByWay(self.mainlayer,{"top","difen"}):setString("普通模式")
	else
		WidgetUtils.getNodeByWay(self.mainlayer,{"top","difen"}):setString("比炸模式")
	end

	--self.tips:getChildByName("confstr"):setString("等待牌局开始...")
	self.painode = WidgetUtils.getNodeByWay(self.mainlayer,{"painode"})
	
	-- WidgetUtils.setScalepos(self.painode)
	self.copylable = WidgetUtils.getNodeByWay(self.mainlayer,{"label"})
	



	self.fennode = WidgetUtils.getNodeByWay(self.mainlayer,{"fen"})

	self.actionnode = WidgetUtils.getNodeByWay(self.mainlayer,{"actionnode"})
	self.actionnode:setLocalZOrder(2)
	self.actionnode:setVisible(false)

	self.actionnode1 = WidgetUtils.getNodeByWay(self.mainlayer,{"btnnodemid"})
	self.actionnode1:setLocalZOrder(2)
	self.actionnode1:setVisible(false)
	self.liangbtn = WidgetUtils.getNodeByWay(self.mainlayer,{"liangbtn"})
	self.liangbtn:setVisible(false)

	WidgetUtils.addClickEvent(self.liangbtn, function( )
		--SocketConnect_instance.socket:close()
		Socketapi.doactionforkutong(1)
		self.liangbtn:setVisible(false)
	end)

	self.dianliang = WidgetUtils.getNodeByWay(self.mainlayer,{"dian","dian"})
	self.wifi = WidgetUtils.getNodeByWay(self.mainlayer,{"wifi"})
	self:setDianliang()
	self.btnnode = WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"})

	self.timelabel = WidgetUtils.getNodeByWay(self.mainlayer,{"time"})
	 self.timelabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
        local date = os.date("%X")
        self.timelabel:setString(date)
    end),cc.DelayTime:create(1))))

	self.setbtn = WidgetUtils.getNodeByWay(self.mainlayer,{"setbtn"})

	WidgetUtils.addClickEvent(self.setbtn, function( )
		--SocketConnect_instance.socket:close()
		LaypopManger_instance:PopBox("SetView",2,self)
	end)
	WidgetUtils.addClickEvent(WidgetUtils.getNodeByWay(self.mainlayer,{"guibtn"}), function( )
		
		if tolua.cast(self.gameview,"cc.Node") then
			
			if self.gameview.tableviews[1].iscantouch then
				if cc.UserDefault:getInstance():getIntegerForKey("pailie",1) == 1 then
					cc.UserDefault:getInstance():setIntegerForKey("pailie",2)
				else
					cc.UserDefault:getInstance():setIntegerForKey("pailie",1)
				end
			
				self.gameview.tableviews[1]:sortcards()
			end
		end

	end)
	self.exitbtn = WidgetUtils.getNodeByWay(self.mainlayer,{"exit1"})
	WidgetUtils.addClickEvent(self.exitbtn, function( )
		
		self:exitbtncall()
	end)

	self.readybtn = WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode","readybtn"})
	WidgetUtils.addClickEvent(self.readybtn, function( )
		self.readybtn:setVisible(false)
		Socketapi.readyaction1()
	end)


	self.sazibtn = WidgetUtils.getNodeByWay(self.mainlayer,{"sazibtn"})
	WidgetUtils.addClickEvent(self.sazibtn, function( )
		self.sazibtn:setVisible(false)
		Socketapi.saziaciton()
	end)
	self.sazibtn:setVisible(false)

	self.talkbtn = WidgetUtils.getNodeByWay(self.mainlayer,{"talkbtn"})
	WidgetUtils.addClickEvent(self.talkbtn, function( )
		self.talklayer:setVisible(true)
	end)

	self.voicebtn = WidgetUtils.getNodeByWay(self.mainlayer,{"voicebtn"})
	require('app.ui.common.VoiceView').new(self.voicebtn)

	self.yaoqingbtn = WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode","invbtn"})
	WidgetUtils.addClickEvent(self.yaoqingbtn, function( )
		print(self.confstr)
		CommonUtils.sharedesk(self.tableid,self.confstr,"大众窟筒")
	end)

	self.fuzhi = WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode","fuzhi"})
	WidgetUtils.addClickEvent(self.fuzhi, function( )
		CommonUtils.copyfang(self.tableid)
	end)
	self.icon = {}
	for i=1,4 do
		self.icon[i] = WidgetUtils.getNodeByWay(self.mainlayer,{"icon"..(i)})
		self.icon[i]:setVisible(false)
		WidgetUtils.getNodeByWay(self.icon[i],{"icon"}):setLocalZOrder(-1)

		if WidgetUtils.getNodeByWay(self.icon[i],{"lastcard"}) then
			WidgetUtils.getNodeByWay(self.icon[i],{"lastcard"}):setVisible(false)
		end

		if WidgetUtils.getNodeByWay(self.icon[i],{"clock"}) then
			WidgetUtils.getNodeByWay(self.icon[i],{"clock"}):setVisible(false)
		end
		self.icon[i]:setLocalZOrder(3)

	end

	-- 中间指针
	--WidgetUtils.getNodeByWay(self.mainlayer,{"nodemid","midbg"}):setRotation((self.myindex-1)*90)


	
	-- 是否存在重连解散房间
	if self.data.requestDismissUserid then
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function( )
			self.DissolveView = LaypopManger_instance:PopBox("DissolveView",self.data,1)
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

	-- if self.myindex == 1 then
	-- 	self.exitbtn:setVisible(true)
	-- else
	-- 	self.exitbtn:setVisible(false)
	-- end

	if self.data.status == 1 then
		self:setregamestart(self.data)
	elseif self.data.status == 2 then
		WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}):setVisible(false)
		--Socketapi.readyaction()

		for i,v in ipairs(self.data.roomPlayerItemJsons) do
			if v.playerid == LocalData_instance.playerid then
				if v.curGameStatus ~= 0  then
					if self.data.gameOneEndRespJson then
						self:gameover(self.data.gameOneEndRespJson,0)
					end
				end
			end
		end
		
		
	elseif self.data.status == 0 then
		WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}):setVisible(true)
		self.isfirist = true
	elseif self.data.status == - 1 then
		WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}):setVisible(true)
		self.isfirist = true
		for i=1,4 do
			self.fennode:getChildByName("name"..i):setVisible(false)
			self.fennode:getChildByName("tong"..i):setVisible(false)
			self.fennode:getChildByName("jiang"..i):setVisible(false)
			self.fennode:getChildByName("fen"..i):setVisible(false)
			self.fennode:getChildByName("wu"..i):setVisible(false)
		end
	else
		print("等待中")
	end
	
	if self.data.isShowDice == 1 then
		self:rengsazi()
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

function MajiangScene:setclock(clock)
	-- body
	for i=1,4 do
		self.icon[i] = WidgetUtils.getNodeByWay(self.mainlayer,{"icon"..(i)})

		if WidgetUtils.getNodeByWay(self.icon[i],{"clock"}) then
			WidgetUtils.getNodeByWay(self.icon[i],{"clock"}):setVisible(false)
			WidgetUtils.getNodeByWay(self.icon[i],{"clock"}):stopAllActions()
		end

	end
	if clock == nil then
		return
	end
	print("set clock")
	clock:setVisible(true)
	local totall = 10
	clock:getChildByName("num"):setString(totall)
	clock:stopAllActions()
	clock:runAction(cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( ... )
		totall = totall - 1
		if totall < 0 then
			totall = 0
		end
		clock:getChildByName("num"):setString(totall)
	end)), 10))
end

function MajiangScene:setDianliang()

	local function doaction1()
		CommonUtils.getDianliangLevel(function(value)
			self.dianliang:setPercent(value)
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
		Socketapi.sendexitforkutong()
	end
	if self.gamestatus == 0 or self.gamestatus == -1 then
		if self.myindex == 1 and self.data.gameusecoinstype ~= 4 then
			LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "是否确定退出房间?(不消耗房卡)",sureCallFunc = function()
				Socketapi.sendexitforkutong()
			end})
		else
			Socketapi.sendexitforkutong()
		end
	else
		LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "是否解散房间？",sureCallFunc = function()
			Socketapi.sendjiesanforkutong()
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
	self.ju:setString("局数:"..data.curGameNums.."/"..data.totalGameNums)
	self.curGameNums =data.curGameNums
	if self.gamestatus ~= -1 then
		--self.exitbtn:setVisible(false)
	else
		--self.exitbtn:setVisible(true)
		WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}):setVisible(true)
	end
	self:updataicon(data)
	if #data.roomPlayerItemJsons == self.gameplayernums then
		self:showip()
		--self.isfirist = false
	else
		self.isfirist = true
	end
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
			if v.score > 0 then
				self.icon[localindex]:getChildByName("gold"):getChildByName("text"):setString("."..v.score)
			elseif v.score == 0 then
				self.icon[localindex]:getChildByName("gold"):getChildByName("text"):setString(v.score)
			else
				self.icon[localindex]:getChildByName("gold"):getChildByName("text"):setString("/"..v.score)
			end
			self.icon[localindex]:getChildByName("zhuang"):setVisible(false)
			local icon  = self.icon[localindex]:getChildByName("icon")
			--icon:setScale(0.85)
			--if icon.iscreate == nil then
				require("app.ui.common.HeadIcon_Club").new(icon,v.headimgurl,80)

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
					self.readybtn:setVisible(false)
				end
			else
				if isgamestart == nil then
					if  v.index == self:getMyIndex() then
						self.readybtn:setVisible(true)
					end
				end
				self.icon[localindex]:getChildByName("ready"):setVisible(false)
			end

			if data.curBanker == v.index then
				self.icon[localindex]:getChildByName("zhuang"):setVisible(true)
			else
				self.icon[localindex]:getChildByName("zhuang"):setVisible(false)
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
			if v.userid == self.data.roomHostUserid then
				self.icon[localindex]:getChildByName("fang"):setVisible(true)
			else
				self.icon[localindex]:getChildByName("fang"):setVisible(false)
			end
			if v.curGameResult == 1 then
				if v.cardCompleteOrder and v.cardCompleteOrder ~= 0 then
					local you = self.icon[localindex]:getChildByName("you")
					you:setVisible(true)
					you:setTexture("cocostudio/ui/kutong/result/no"..v.cardCompleteOrder..".png")
				end
			end

	end
		if #data.roomPlayerItemJsons  == self.gameplayernums and self.gamestatus == 0 then
			WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}):setVisible(false)
			
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
		--AudioUtils.playEffect("niu_start")
	end
	for i=1,4 do
		self.icon[i]:getChildByName("you"):setVisible(false)
		self.painode:getChildByName("hand"..i):removeAllChildren()
		self.painode:getChildByName("num"..i):setVisible(false)
	end
	


	print("setgamestart")
	-- if self.data.gamebankertype == 4  then
	-- 	self.xiazhu:setVisible(true)
	-- 	self.xiazhu:getChildByName("text"):setString(data.curPoolScore)
	-- end
	if isre then
	else
		-- if data.curGameNums == 0 then
		-- 	self:showip()
		-- end
	end
	print("data.curPlayerFlag:"..data.curPlayerIndex)
	if data.curPlayerIndex and data.curPlayerIndex ~= 0 then
		local localindex = self:getLocalindex(data.curPlayerIndex)
		print("localindex"..localindex)
		if localindex ~= 1 then
			self:setclock(self.icon[localindex]:getChildByName("clock"))
		end
	end

	self.gameisstare =true
	if self.iswait then
		WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}):setVisible(true)
	else
		WidgetUtils.getNodeByWay(self.mainlayer,{"btnnode"}):setVisible(false)
	end
	self.data = data 
	self.isfirist = false
	self.gamestatus = 2
	self.curBanker = data.curBanker
	self.ju:setString("局数:"..data.curGameNums.."/"..self.data.totalGameNums)
	self.curGameNums =data.curGameNums
	-- body
	if tolua.cast(self.gameview,"cc.Node") then
		self.gameview:removeFromParent()
	end
	

	self:updataicon(self.data,true)
	self.gameview = require "app.ui.kutong.GameView".new(self,data,isre)
	self.gameview:setPosition(cc.p(0,0))
	self.mainlayer:addChild(self.gameview)
	local function isneednotshow(index)
		if self.myindex%2 == index%2 then
			return false 
		else
			return true
		end
	end
	for i,v in ipairs(self.data.roomPlayerItemJsons) do
		self.fennode:getChildByName("name"..i):setVisible(true)
		self.fennode:getChildByName("name"..i):setString(v.nickname)
		self.fennode:getChildByName("tong"..i):setVisible(true)
		self.fennode:getChildByName("tong"..i):setString(v.curGameTongNums.."桶")
		self.fennode:getChildByName("jiang"..i):setVisible(true)
		self.fennode:getChildByName("jiang"..i):setString(v.curGameRewardNums.."奖")
		if isneednotshow(v.index) then
			self.fennode:getChildByName("wu"..i):setVisible(true)
			self.fennode:getChildByName("fen"..i):setVisible(false)
			self.fennode:getChildByName("fen"..i):setString(v.curGameScore.."分")
		else
			self.fennode:getChildByName("fen"..i):setVisible(true)
			self.fennode:getChildByName("wu"..i):setVisible(false)
			self.fennode:getChildByName("fen"..i):setString(v.curGameScore.."分")
		end
	end
	
end
--{"curQuan":0,"curBanker":1,"curGameNums":1,"index":1,"score":0,"curCards":[4,5,6,9,11,12,13,14,17,24,24,25,26,28],"curOutCards":[],"isPlayCard":1,"curDeskCardsItems":[],"playTypes":[7],"curPlayerIndex":1,"curPlayerFlag":1,"diCardCount":83,"keytype":"3;4;2"}


--可出牌类型：-1:无操作 1:暗杠2:明杠3:听牌4:碰5:弯杠6胡牌
--7:出牌8:过)

function MajiangScene:initEvent()
	ComNoti_instance:addEventListener("3;3;3;2",self,self.setgamestart)
	ComNoti_instance:addEventListener("3;3;3;3",self,self.actionflag)
	ComNoti_instance:addEventListener("3;3;2;3",self,self.readycanell)
	ComNoti_instance:addEventListener("3;3;2;9",self,self.beigincallback)
	ComNoti_instance:addEventListener("3;3;3;5",self,self.doAction)
	ComNoti_instance:addEventListener("3;3;2;2",self,self.responsecall)

	ComNoti_instance:addEventListener("3;3;3;8",self,self.chatmsg)
	ComNoti_instance:addEventListener("3;3;3;9",self,self.jiesan)
	ComNoti_instance:addEventListener("3;3;3;13",self,self.updatainfo)
	ComNoti_instance:addEventListener("3;3;3;10",self,self.exitgame)
	ComNoti_instance:addEventListener("3;3;3;6",self,self.gameover)
	ComNoti_instance:addEventListener("3;3;3;7",self,self.gameoverAll)


	ComNoti_instance:addEventListener("3;3;3;4",self,self.fapaiaction)
	ComNoti_instance:addEventListener("3;3;3;14",self,self.settipsstr)
	ComNoti_instance:addEventListener("3;3;3;15",self,self.rengsazi)
	ComNoti_instance:addEventListener("3;3;3;16",self,self.rengsazireslut)
end
function MajiangScene:rengsazireslut(data )
	require "app.ui.kutong.AnmiKu"
	local node = AnmiKu.sazi(data.dicenum1,data.dicenum2,function( )
		print("saziend")
		STOPSOCEKT = false
	end)
	self:addChild(node)
	node:setPosition(cc.p(display.cx,display.cy))
end
function MajiangScene:rengsazi(data )
	self.readybtn:setVisible(false)
	--self.exitbtn:setVisible(false)
	self.yaoqingbtn:setVisible(false)
	self.fuzhi:setVisible(false)
	if LocalData_instance.userid == self.data.roomHostUserid then
		self.sazibtn:setVisible(true)
	end
end
function MajiangScene:settipsstr( data,isre)
	
end
function MajiangScene:beigincallback( data )
	if data.result == 0 then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info,sureCallFunc = function()
			
		end})
	end
end
function MajiangScene:responsecall( data )
	if data.result == 0 then
		SocketConnect_instance.socket:close()
	end
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
		localindex = index - self.myindex + 4+1
	end
	return localindex
end



---- 1单张 2 顺子  3 单对 4 连队  5 3张 6飞机  7炸弹
function MajiangScene:doAction(data )
	if data.isclear == 1 then
		self.gameview:cleanputout()
	end
	if data.actiontype ==2  then
		self.gameview:chupai(data,true)
		--self:getSex(data.index)
		if data.cardtype == 1 then
			AudioUtils.playVoice("one"..data.real..".mp3",self:getSex(data.index))
		elseif data.cardtype == 2 then
			AudioUtils.playVoice("shunzi.mp3",self:getSex(data.index))
		elseif data.cardtype == 3 then
			AudioUtils.playVoice("two"..data.real..".mp3",self:getSex(data.index))
		elseif data.cardtype == 4 then
			AudioUtils.playVoice("liandui.mp3",self:getSex(data.index))
		elseif data.cardtype == 5 then
			AudioUtils.playVoice("three"..data.real..".mp3",self:getSex(data.index))
		elseif data.cardtype == 6 then
			AudioUtils.playVoice("feiji.mp3",self:getSex(data.index))
		elseif data.cardtype == 7 then
			if data.num == 4 and data.real <= 15 then
				AudioUtils.playVoice("four"..data.real..".mp3",self:getSex(data.index))
			elseif data.num > 4  then
				AudioUtils.playVoice("bomb"..data.num..".mp3",self:getSex(data.index))
			end
		end


	elseif data.actiontype ==3  then
		self.gameview:guo(data)
		AudioUtils.playVoice("pass.mp3",self:getSex(data.index))
	end

	if data.curPlayerIndex and data.curPlayerIndex ~= 0 then
		local localindex = self:getLocalindex(data.curPlayerIndex)

		self.painode:getChildByName("buchu"..localindex):setVisible(false)
		self.gameview.tableviews[localindex].putnode:removeAllChildren()


		if localindex ~= 1 then
			self:setclock(self.icon[localindex]:getChildByName("clock"))
		end
	end
	if data.gameScoreUpdates then
		for i,v in ipairs(data.gameScoreUpdates) do
			self.fennode:getChildByName("tong"..i):setString(v.curGameTongNums.."桶")
			self.fennode:getChildByName("jiang"..i):setString(v.curGameRewardNums.."奖")
			self.fennode:getChildByName("fen"..i):setString(v.curGameScore.."分")
		end

	end

	if data.curGameResult == 1 then
		local localindex = self:getLocalindex(data.index)
		local you = self.icon[localindex]:getChildByName("you")
		you:setVisible(true)
		you:setTexture("cocostudio/ui/kutong/result/no"..data.cardCompleteOrder..".png")
	end



end
function MajiangScene:gameover(data,delaytime)

	print("---------111")
	-- LaypopManger_instance:back()
	-- LaypopManger_instance:back()
	if  data.isLastGame == 1 then
		self.isover = true
	end
	self:runAction(cc.Sequence:create(cc.DelayTime:create(delaytime or 2),cc.CallFunc:create(function( ... )
			for i=1,4 do
				self.icon[i] = WidgetUtils.getNodeByWay(self.mainlayer,{"icon"..(i)})
				if WidgetUtils.getNodeByWay(self.icon[i],{"clock"}) then
					WidgetUtils.getNodeByWay(self.icon[i],{"clock"}):setVisible(false)
				end

			end


			self.actionnode1:setVisible(true)

			WidgetUtils.addClickEvent(self.actionnode1:getChildByName("readybtn"), function( )
				if self.isover then
					LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "牌局已经结束",sureCallFunc = function()
					end})
				else
					self.actionnode1:setVisible(false)
					Socketapi.readyaction1()
				end
			end)

			WidgetUtils.addClickEvent(self.actionnode1:getChildByName("zhanbtn"), function( )
				LaypopManger_instance:PopBox("AllResultViewforkutong",data,self.data,self.confstrrsult)
			end)
			self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( ... )
				LaypopManger_instance:PopBox("AllResultViewforkutong",data,self.data,self.confstrrsult)
			end)))
			for i,v in ipairs(data.gameendinfolist) do
				self.fennode:getChildByName("name"..i):setVisible(true)
				self.fennode:getChildByName("name"..i):setString(v.nickname)
				self.fennode:getChildByName("tong"..i):setVisible(true)
				self.fennode:getChildByName("tong"..i):setString(v.curGameTongNums.."桶")
				self.fennode:getChildByName("jiang"..i):setVisible(true)
				self.fennode:getChildByName("jiang"..i):setString(v.curGameRewardNums.."奖")
				self.fennode:getChildByName("fen"..i):setVisible(true)
				self.fennode:getChildByName("wu"..i):setVisible(false)
				self.fennode:getChildByName("fen"..i):setString(v.curGameScore.."分")	


			end
			if tolua.cast(self.gameview,"cc.Node") then
				self.gameview:cleanputout()
				for k,v in pairs(self.gameview.tableviews) do
					v.putnode:removeAllChildren()
				end
			end



	end)))


	self:createhand(data)
end
function MajiangScene:createhand(data)
	print("chuang")
	for j,v in ipairs(data.gameendinfolist) do
		local localpos = self:getLocalindex(v.index)
		local node = self.painode:getChildByName("hand"..localpos)
		node:removeAllChildren()

		local localindex = self:getLocalindex(v.index)
		if v.cardCompleteOrder and v.cardCompleteOrder ~= 0 then
			local you = self.icon[localindex]:getChildByName("you")
			you:setVisible(true)
			you:setTexture("cocostudio/ui/kutong/result/no"..v.cardCompleteOrder..".png")
		end

		print("localpos:"..localpos)
		--v.curCards = {1,2,3,4,5,6,7,8,9,10,11,12,13,1,2,3,4,5,6,7,8,9,10,11,12,13,1,2,3,4,5,6,7,8,9,10,11,12,13}
		 local curcards = Suanfuc.sort1hand(v.curCards)
	     if cc.UserDefault:getInstance():getIntegerForKey("pailie",1) == 2 then
	        curcards = Suanfuc.sort2hand(v.curCards)
	     end
	     local totall = #v.curCards
    	local down =55
    	local up  = (55*20)/21
    	if self.data.gameplaytype ~= 1 then
    		self.painode:getChildByName("num"..localpos):setVisible(true)
    		self.painode:getChildByName("num"..localpos):setString(v.totalTongNums.."/")
    	end
    	if tolua.cast(self.gameview,"cc.Node") then
    		self.gameview.tableviews[localpos]:showwinlost(v.onescore)
    		if localpos == 1 then
    			self.gameview.tableviews[localpos].cardnode:removeAllChildren()
    			self.gameview.tableviews[localpos].iscantouch = false
    		end
    	end
		if localpos == 1 then
			for i=1,totall do
		        local card = Card.new(curcards[i],true)
		        node:addChild(card)
		        if totall > 20 then
		            if i <= (totall-20) then
		                --card:setPosition(cc.p((i - 20/2 -0.5)*(55*20)/21,60))
		                card:setPosition(cc.p((i-1)*up - down*19/2,60))
		            else
		                card:setPosition(cc.p(((i+20 - totall) - 20/2 -0.5)*down,0))
		            end
		        else
		            card:setPosition(cc.p((i - totall/2 -0.5)*down,0))
		        end
		    end
		elseif localpos == 2 then
			node:setScale(0.45)
			for i=1,totall do
		        local card = Card.new(curcards[i],true)
		        node:addChild(card)
		        card:setCardAnchorPoint(cc.p(1,0))
		        if totall > 20 then
		            if i <= (totall-20) then
		                --card:setPosition(cc.p((i - 20/2 -0.5)*(55*20)/21,60))
		                card:setPosition(cc.p((i-1)*up - down*19,60))
		            else
		                card:setPosition(cc.p(-19*down +(i-1-totall+20)*down,0))
		            end
		        else
		            card:setPosition(cc.p(-19*down +(i-1-totall+20)*down,0))
		        end
		    end
		elseif localpos == 3 then
			node:setScale(0.45)
			for i=1,totall do
		        local card = Card.new(curcards[i],true)
		        node:addChild(card)
		        card:setCardAnchorPoint(cc.p(1,0))
		        if totall > 20 then
		            if i <= (totall-20) then
		                --card:setPosition(cc.p((i - 20/2 -0.5)*(55*20)/21,60))
		                card:setPosition(cc.p((i-1)*up - down*19,60))
		            else
		                card:setPosition(cc.p(-19*down +(i-1-totall+20)*down,0))
		            end
		        else
		            card:setPosition(cc.p(-19*down +(i-1-totall+20)*down,0))
		        end
		    end
		elseif localpos == 4 then
			node:setScale(0.45)
			for i=1,totall do
		        local card = Card.new(curcards[i],true)
		        node:addChild(card)
		        card:setCardAnchorPoint(cc.p(0,0))
		        if totall > 20 then
		            if i <= (totall-20) then
		                --card:setPosition(cc.p((i - 20/2 -0.5)*(55*20)/21,60))
		                card:setPosition(cc.p((i-1)*up,60))
		            else
		                card:setPosition(cc.p((i-1-totall+20)*down,0))
		            end
		        else
		        	 card:setPosition(cc.p((i-1)*down,0))
		            -- card:setPosition(cc.p((i-1-totall+20)*down,0))
		        end
		    end
		end
	end
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
		AudioUtils.playVoice("chatku"..datatab.id..".mp3",self:getSex(index))
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
	"啊冒有各个牌，打不起",
	"打死拧，手气合理干呢批",
	"等啊来打，啊好打几",
	"各个牌，嫩有不嘞",
	"和不住哩，你们都奖花了水呐",
	"莫走快里，捡几分走",
	"拿炸炸他，别让他出",
	"手手六鱼仔，打棺材哟",
	"有宁鸟了王波，我来捡几只",
	"炸不大不要紧，这下准备库他们桶",
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
			data.roomPlayerItemJsons[i].dismissoptype = 0
			data.roomPlayerItemJsons[i].headimgurl= v.headimgurl
		end

		self.DissolveView = LaypopManger_instance:PopBox("DissolveView",data,1)
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