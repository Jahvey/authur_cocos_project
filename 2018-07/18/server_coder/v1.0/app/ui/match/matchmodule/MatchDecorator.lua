-------------------------------------------------
--   TODO   比赛场
--   @author pbz
--   Create Date 2018.7.2
------------------------------------------------- 
local MatchDecorator = class("MatchDecorator")

function MatchDecorator.overideGameScene(GameScene)
	local ctor_super = GameScene.ctor
	function GameScene:ctor(data, path)
		data.table_info.sdr_conf.ttype = MATCHMAP[data.table_info.sdr_conf.ttype] or data.table_info.sdr_conf.ttype
		ctor_super(self,data,path)
	end

	function GameScene:initView()
		self.name = "GameScene"
		print("=====GameScene:initView")
		self.layout = cc.CSLoader:createNode("ui/game/gameBasenew.csb")

		self:addChild(self.layout)
		WidgetUtils.setScalepos(self.layout)
		self.UILayer = requireWithFuc("app.ui.game.base.GameUILayer",MatchDecorator.overideGameUILayer).new(self)
			:addTo(self.layout:getChildByName("UInode"))
			:setPosition(cc.p(0, 0))

		self:initDataBySelf()

		self:initTable()
		self:refreshScene()
		self:setbgstype()

	end

	function GameScene:initTable()
		local tableBase = requireWithFuc(self.path .. ".GameTable",MatchDecorator.overideGameTable)
	    local gameAction = require(self.path .. ".ActionView")

	    local bottomtable = require("app.ui.game.base.TableBottom").create(tableBase, gameAction).new(self.layout:getChildByName("bottomnode"), self)
	    local toptable = require("app.ui.game.base.TableTop").create(tableBase).new(self.layout:getChildByName("topnode"), self)
	    local lefttable = require("app.ui.game.base.TableLeft").create(tableBase).new(self.layout:getChildByName("leftnode"), self)
	    local righttable = require("app.ui.game.base.TableRight").create(tableBase).new(self.layout:getChildByName("rightnode"), self)

	    -- 初始化策略
	    local maps = {
	        [2] =
	        {
	            [0] = { bottomtable, toptable },
	            [1] = { toptable, bottomtable },
	        },
	        [3] =
	        {
	            [0] = { bottomtable, righttable, lefttable },
	            [1] = { lefttable, bottomtable, righttable },
	            [2] = { righttable, lefttable, bottomtable },
	        },
	        [4] =
	        {
	            [0] = { bottomtable, righttable, toptable, lefttable },
	            [1] = { lefttable, bottomtable, righttable, toptable },
	            [2] = { toptable, lefttable, bottomtable, righttable },
	            [3] = { righttable, toptable, lefttable, bottomtable },
	        },
	    }

	    self.tablelist = maps[self:getTableConf().seat_num][self:getMyIndex()]

	    for i, v in ipairs(self.tablelist) do
	        print("............i = ", i)
	        v:showNode()
	        v:setTableIndex(i - 1)
	    end

	    self.mytable = bottomtable
	    self.myTableClass = {bottomtable,righttable,toptable,lefttable}


	    self:otherInitView()
	end

	local registerNetEventListener_super = GameScene.registerNetEventListener
	function GameScene:registerNetEventListener()
		ComNoti_instance:addEventListener("cs_response_leave_match",self,self.responseLeaveMatch)
		ComNoti_instance:addEventListener("cs_response_change_tuo_guan_state",self,self.responseTuoguanState)
		ComNoti_instance:addEventListener("cs_notify_tuo_guan_info",self,self.notifyTuoguanInfo)
		registerNetEventListener_super(self)
	end

	local NotifyGameStart_super = GameScene.NotifyGameStart
	function GameScene:NotifyGameStart(data)
		LaypopManger_instance:backByName("SingleResultView")
		self:waitGameStart()
		NotifyGameStart_super(self,data)
	end

	local doAction_super = GameScene.doAction
	function GameScene:doAction(data, _str)
		self.UILayer:hideClock()
		doAction_super(self,data, _str)
	end

	-- 显示单局结算
	function GameScene:showpeiResult(data)
		local SingleResultView = LaypopManger_instance:PopBox("SingleResultView", data, self, 1)
		
		local roomInfo = SingleResultView.mainLayer:getChildByName("roomInfo")
		local jushuStr = "第"..self:getNowRound().."/"..self:getTableConf().round.."局"
		local nameStr = GT_INSTANCE:getGameName(self:getTableConf().ttype)
		local guizeStr = GT_INSTANCE:getTableDes(self:getTableConf(),4)
		roomInfo:setString("比赛场  "..jushuStr.."  "..nameStr.."("..guizeStr..")")

	

		-- if not self.allResultData then
		-- 	SingleResultView.againBtn:ignoreContentAdaptWithSize(true)
		-- 	SingleResultView.againBtn:setScale9Enabled(true)
		-- 	SingleResultView.againBtn:setContentSize(cc.size(242,67))
		-- 	-- SingleResultView.againBtn:loadTextureNormal("cocostudio/ui/singleResult/btn_blue_long.png")
		-- 	-- SingleResultView.againBtn:loadTexturePressed("cocostudio/ui/singleResult/btn_blue_long.png")
		-- 	SingleResultView.againBtn:setPositionX(SingleResultView.againBtn:getPositionX()-20)
		-- 	SingleResultView.sharebtn:setPositionX(SingleResultView.sharebtn:getPositionX()-35)

		-- 	local text = SingleResultView.againBtn:getChildByName("text_play")
		-- 	text:setPositionX(text:getPositionX()-20)

		-- 	local count = ccui.Text:create("12s",FONTNAME_DEF,30)
		-- 		:setAnchorPoint(cc.p(0,0.5))
		-- 		:addTo(SingleResultView.againBtn)
		-- 		:setPosition(cc.p(text:getPositionX()+text:getContentSize().width/2+20,text:getPositionY()))
		-- 		:setColor(cc.c3b(0xff,0xff,0xff))
		-- 		:enableOutline(cc.c3b( 0x28, 0x58, 0x74),2)

		-- 	local time = 12
		-- 	count:runAction(cc.RepeatForever:create(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function ()
		-- 		time = time - 1
		-- 		time = time <= 0 and 0 or time

		-- 		count:setString(time.."s")
		-- 	end)))))
		-- end

		function SingleResultView:againBtnCall()
			print("再来一局")
			if  self.gamescene then
				if self.opentype == 2 then
					local owner = self.gamescene
					-- LaypopManger_instance:back()
					cc.Director:getInstance():popScene()
					-- owner:returnHall()
				else	
					local data = self.data
					local owner = self.gamescene
					AudioUtils.setMusicVolume(cc.UserDefault:getInstance():getIntegerForKey("LocalData_music") )
					if self.gamescene.allResultData ~= nil  then
						glApp:enterSceneByName("AllResultScene",self.gamescene)

						if glApp:getCurScene().sceneName == "AllResultScene" then
							local allResultData = self.gamescene.allResultData
							WidgetUtils.addClickEvent(glApp:getCurScene().returnbtn, function( )
								glApp:enterSceneByName("MatchResultScene",allResultData)
							end)

							local roomInfo = glApp:getCurScene().mainLayer:getChildByName("left_info"):getChildByName("roomInfo")
							local nameStr = GT_INSTANCE:getGameName(glApp:getCurScene().owner:getTableConf().ttype)
							local jushuStr = "第"..glApp:getCurScene().owner:getNowRound().."/"..glApp:getCurScene().owner:getTableConf().round.."局"
							roomInfo:setString(nameStr.."   "..jushuStr.."   ".."比赛场")
						end
					else	
						Socketapi.request_ready(true)
						owner:waitGameStart()
					end	
					LaypopManger_instance:back()
				end	
			end
		end

		for i,v in ipairs(self:getSeatsInfo()) do
		    v.is_piao = nil
		end
		self:setRestTileNum(0)

	end

	function GameScene:showAllResult(data)
		print("游戏结束，总结算")
		printTable(data)
		self.allResultData = data
		if data.is_dissolve_finish then
			if tolua.cast(self.dissolveView, "cc.Node") then
				LaypopManger_instance:backByName("DissolveView")
			end
			
			glApp:enterSceneByName("AllResultScene", self)

			if glApp:getCurScene().sceneName == "AllResultScene" then
				WidgetUtils.addClickEvent(glApp:getCurScene().returnbtn, function( )
					glApp:enterSceneByName("MatchResultScene",data)
				end)
			end
		end

	end

	function GameScene:responseLeaveMatch(data)
		if data.result == 0 then
			glApp:enterSceneByName("MainScene")
		else
			LaypopManger_instance:PopBox("PromptBoxView", 1, { tipstr = "退出比赛失败" })
		end
	end

	function GameScene:responseTuoguanState(data)
		if data.result == 0 then
			self:notifyTuoguanInfo({seat_index = self:getMyIndex(),is_tuo_guan = data.tuo_guan_state})
			self.mytable:refreshSeat()
		else
			LaypopManger_instance:PopBox("PromptBoxView", 1, { tipstr = "操作失败" })
		end
	end

	function GameScene:notifyTuoguanInfo(data)
		self:setTuoguanState(data.seat_index,data.is_tuo_guan)
		self.tablelist[data.seat_index + 1]:refreshSeat()

		if data.seat_index == self:getMyIndex() and data.is_tuo_guan == true then
			for i=#self.actionList,1,-1 do
				if self.actionList[i].act_type == ACTIONTYPEBYMYSELF.MYTURN or self.actionList[i].act_type == ACTIONTYPEBYMYSELF.MYTURN_CHU then
					table.remove(self.actionList,i)
				end
			end

			if self.mytable.actionview:getIsShow() then
				self.mytable.actionview:hide()
			end

			self.mytable:setIsMyTurn(false)
            self.mytable:showShouZhi(false)

            self.isRunning = false

		    local info = self.actionList[1]
		    if info then
		        self:doAction(info, "deleteAction")
		    end
		end
	end

	function GameScene:setTuoguanState(index,state)
		for i, v in ipairs(self.table_info.sdr_seats) do
			if v.index == index then
				v.is_tuo_guan = state
				return
			end
		end
	end

	local priorityAction_super = GameScene.priorityAction
	function GameScene:priorityAction(data)
		if data.act_type == ACTIONTYPEBYMYSELF.MYTURN then
	        self.mytable:setIsMyTurn(true)
	        self.mytable:showActionView(data.data)
	        self.UILayer:setOpertip(self:getMyIndex())

	        local _list = {}
	        local _dest_card = 0
	        for k,v in pairs(data.data) do
	            local _act_type = v.act_type or 0
	            local _cards = v.original_cards or v.cards or nil
	            local _li = {}
	            _li.act_type = _act_type
	            _li.cards = _cards
	            table.insert(_list,_li)
	        end
	        self:addDebugList("show",{dest = _dest_card,acts = _list})
	        return true
	    end

	    return priorityAction_super(self,data)
	end

	local onExit_super = GameScene.onExit
	function GameScene:onExit()
		print("================清除")
		onExit_super(self)

		local gamePath = GT_INSTANCE:getGamePath(self:getTableConf().ttype)
		local scenePackageName = "app.ui."..gamePath..".GameScene"
		package.loaded[scenePackageName] = nil
		-- package.loaded["app.ui.game.GameScene"] = nil
		package.loaded["app.ui.game.base.GameUILayer"] = nil
		package.loaded[self.path..".GameTable"] = nil

		print("================清除")
	end

	return GameScene
end

function MatchDecorator.overideGameUILayer(GameUILayer)
	function GameUILayer:initView()
	    
	    self.node = cc.CSLoader:createNode("ui/game/gameUIforMatch.csb")

	    print("function GameUILayer:initView()")


	    self.node:addTo(self)

	    WidgetUtils.setScalepos(self.node)

	    self.bg = self.node:getChildByName("bg")
	    WidgetUtils.setBgScale(self.bg)

	    self.logo = self.node:getChildByName("Logo")

	    function self.logo:setTexture(src)
	    	return self:loadTexture(src)
	    end

	    self.mainUi = self.node:getChildByName("main")
	    WidgetUtils.setScalepos(self.mainUi)

	    self.normalbtn = self.mainUi:getChildByName("normalbtn")
	    WidgetUtils.setScalepos(self.normalbtn)

	    self.readyNode = self.mainUi:getChildByName("readyNode")
	    -- WidgetUtils.setScalepos(self.readyNode)

	    self.waitnode = self.mainUi:getChildByName("waitnode")
	    -- WidgetUtils.setScalepos(self.waitnode)

	    self.paijuNode = self.mainUi:getChildByName("paijuNode")
	    -- WidgetUtils.setScalepos(self.paijuNode)

	    self.topbg = self.normalbtn:getChildByName("topbg")
	    --如果4人 2d新牌桌 top分成了两个节点
	    self.topbg1 = self.topbg

	    self.topbg:setPositionY(display.height / 2 - 8)

	    self.waitnode:setVisible(false)

	    -- 邀请按钮
	    self.invitebtn = self.readyNode:getChildByName("invitebtn")
	    WidgetUtils.addClickEvent(self.invitebtn, function()
	        -- CommonUtils:prompt("暂未开放，敬请期待", CommonUtils.TYPE_CENTER)
	        CommonUtils.sharedesk(self.gamescene:getTableID(), GT_INSTANCE:getTableDes(self.gamescene:getTableConf(), 2),self.gamescene:getTableConf().ttype)
	    end)

	    local function btncall(bool)
	        local index = self.gamescene:getMyIndex()
	        if index then
	            print("index _位子")
	            Socketapi.request_ready(bool)
	        else
	            print("没有找到自己的位子")
	        end
	    end
	    -- 准备和取消准备
	    self.readybtn = self.readyNode:getChildByName("readybtn")
	    WidgetUtils.addClickEvent(self.readybtn, function()
	        btncall(true)
	    end )

	    self.cancelbtn = self.readyNode:getChildByName("cancelbtn")
	    WidgetUtils.addClickEvent(self.cancelbtn, function()
	        btncall(false)
	    end )

	    self:initNormalBtn()
	    self:initPaiJuView()

	    local tips_label = cc.Label:createWithSystemFont("仅供娱乐，禁止赌博", FONTNAME_DEF, 18)
	    tips_label:setTextColor( cc.c3b( 0x00, 0x00, 0x00))
	    tips_label:setOpacity(255*0.6)
	    tips_label:setPosition(cc.p(self.logo:getPositionX(), self.logo:getPositionY()-28))
	    tips_label:setLocalZOrder(-1)
	    self.mainUi:addChild(tips_label)

	    if self.gamescene:getTableConf().ttype == HPGAMETYPE.TCGZP then
	        tips_label:setPosition( cc.p(1100, 638))
	    end
	end

	function GameUILayer:initNormalBtn()
		local backbtn = self.normalbtn:getChildByName("backbtn")
	    WidgetUtils.addClickEvent(backbtn, function()
	        Socketapi.requestLogoutTable()
	    end )

	    local voicebtn = self.normalbtn:getChildByName("voiceBtn")
	    require('app.ui.common.VoiceView').new(voicebtn)

	    local setbtn = self.normalbtn:getChildByName("setbtn")
	    WidgetUtils.addClickEvent(setbtn, function()
	        LaypopManger_instance:PopBox("SetView", 2, self.gamescene)
	    end )

	    local talkbtn = self.normalbtn:getChildByName("chatBtn")
	    WidgetUtils.addClickEvent(talkbtn, function()
	        LaypopManger_instance:PopBox("ChatView",self.gamescene)
	        --self.gamescene.tablelist[1]:baoPaiAction({dest_card = 17})
	    end )

	    local locationBtn = self.normalbtn:getChildByName("locationBtn")
	    WidgetUtils.addClickEvent(locationBtn, function()
	        self:openDistanceView(true)
	        -- self.gamescene.mytable:setAnKouListNum(1)
	    end )
	    if SHENHEBAO then
	        locationBtn:setVisible(false)
	    end

	    local roomRuleBtn = self.normalbtn:getChildByName("roomRuleBtn")
	    WidgetUtils.addClickEvent(roomRuleBtn, function()
	        self:openRoomRuleView()
	    end )

		local setbtn = self.normalbtn:getChildByName("setbtn")
	    WidgetUtils.addClickEvent(setbtn, function()
			local setview = LaypopManger_instance:PopBox("SetView", 2, self.gamescene)
			local btn = setview.mainLayer:getChildByName("btn")
			btn:setVisible(false)
			local exitbtn = ccui.Button:create("ui/game/exitmatch.png")
				:addTo(btn:getParent()):setVisible(false)
			exitbtn:setPosition(cc.p(btn:getPositionX(),btn:getPositionY()))
		 	--按钮
			WidgetUtils.addClickEvent(exitbtn, function()
				if self.gamescene:getNowRound() == 0 then
					Socketapi.requestLeaveMatch()
				else
					LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "退出将由机器人代打，被淘汰前不允许别的比赛也不能返回本场比赛。",sureCallFunc = function()
						Socketapi.requestLeaveMatch()
					end})
				end
			end)

			setview.mainLayer:getChildByName("fixbtn"):setPositionX(0)
	    end)
	end

	local waitGameStart_super = GameUILayer.waitGameStart
	function GameUILayer:waitGameStart()
		waitGameStart_super(self)
	    self.readyNode:setVisible(false)
	end

	function GameUILayer:refreshReadyCancel(info)
		if self.gamescene:getNowRound() == 0 then
			self.waitnode:setVisible(true)

			WidgetUtils.addClickEvent(self.waitnode:getChildByName("exitbtn"),function ()
				Socketapi.requestLeaveMatch()
			end)

			local nownum = 0

			for i,v in ipairs(self.gamescene:getSeatsInfo()) do
				if v.state == poker_common_pb.EN_SEAT_STATE_NO_PLAYER or v.user == nil or v.user == {} then
				else
					nownum = nownum + 1
				end
			end

	        self.waitnode:getChildByName("tip"):setString("还需等待"..(self.gamescene:getTableConf().seat_num - nownum).."人...")
		else
			self.waitnode:setVisible(false)
	    end
	end

	function GameUILayer:setOpertip(index)
	    if index == nil or self.gamescene.tablelist[index + 1] == nil then
	        return
	    end
	    self.clock:setVisible(true)

	    local _node = self.gamescene.tablelist[index + 1].node
	    local worldpos = _node:convertToWorldSpace(cc.p(_node:getChildByName("clocknode"):getPosition()))
	    local spacepos = self.gamescene.layout:convertToNodeSpace(worldpos)

	    if  self.gamescene:getMyIndex() == index then
	        if  self.gamescene:getTableConf().ttype == HPGAMETYPE.TCGZP then
	            spacepos.x = spacepos.x - 75
	        end
	    end

	    self.clock:setPosition(spacepos)

	    self.leaveTime:stopAllActions()
	    local timelast = 10
	    self.leaveTime:setString(tostring(timelast))
	    self.leaveTime:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create( function(...)
	        timelast = timelast - 1
	        if timelast < 0 then
	            timelast = 0
	        end
	        if timelast < 5 and timelast > 0 then
	            AudioUtils.playEffect("tick")
	        end
	        self.leaveTime:setString(tostring(timelast))
	    end ))))
	end

	-- local setbgstype_super = GameUILayer.setbgstype
	-- function GameUILayer:setbgstype(bg_type)
	-- 	setbgstype_super(self,bg_type)
	-- end

	function GameUILayer:hideClock()
		if self.clock then
			self.clock:setVisible(false)
			self.leaveTime:stopAllActions()
		end
	end
end

function MatchDecorator.overideGameTable(GameTable)
	local refreshSeat_super = GameTable.refreshSeat
	function GameTable:refreshSeat(info, isStart)
		refreshSeat_super(self,info,isStart)

		local ready = self.icon:getChildByName("ok"):setVisible(false)

		if not info then
			info = self.gamescene:getSeatInfoByIdx(self:getTableIndex())
		end


		if not self.tuoguan then
			self.tuoguan = cc.Node:create()
				:addTo(self.icon:getChildByName("headicon"))
				:setLocalZOrder(999)
			local img = ccui.ImageView:create("game/tuoguan.png")
				:addTo(self.tuoguan)
				:setPosition(cc.p(0,0))

			local size = img:getContentSize()
			
	        if LocalData_instance:getbaipai_stype() == 1 then
	            img:setScaleX(84 / size.width)
	            img:setScaleY(84 / size.height)
	            img:setPosition(cc.p(44,42))
	        elseif LocalData_instance:getbaipai_stype() == 2 then
	            img:setScaleX(66 / size.width)
	            img:setScaleY(66 / size.height)
	            img:setPosition(cc.p(33,31.5))
	        end
		end

		self.tuoguan = self.tuoguan and self.tuoguan:setVisible(false)
		if self.tableidx == self.gamescene:getMyIndex() then
			self:setTuoguanBoard(false)
		end

		if info.state == poker_common_pb.EN_SEAT_STATE_NO_PLAYER or info.user == nil or info.user == {} then
		else
			if info.state == poker_common_pb.EN_SEAT_STATE_WAIT_FOR_NEXT_ONE_GAME then
			elseif info.state == poker_common_pb.EN_SEAT_STATE_READY_FOR_NEXT_ONE_GAME then
			elseif info.state == poker_common_pb.EN_SEAT_STATE_PLAYING then
				if info.is_tuo_guan then
					self.tuoguan = self.tuoguan and self.tuoguan:setVisible(true)
					if self.tableidx == self.gamescene:getMyIndex() then
						self:setTuoguanBoard(true)
					end
				end
			elseif info.state == poker_common_pb.EN_SEAT_STATE_WIN then
			elseif info.state == 99 then
			else
			    print("不存在的玩家状态")
			end
		end

		self.gamescene.UILayer:refreshReadyCancel(info)
	end

	function GameTable:setTuoguanBoard(bool)
		if not self.tuoguanBorad then
			self.tuoguanBorad = cc.Node:create()
				:addTo(self.node)

			local board = ccui.ImageView:create("game/tuoguanbg.png")
				:setCapInsets(cc.rect(18, 18, 115, 115))
				:addTo(self.tuoguanBorad)
				:setAnchorPoint(cc.p(0.5,0))
				:setScale9Enabled(true)
				:setContentSize(cc.size(display.width,350))

			local cancelbtn = ccui.Button:create("gameddz/ddz_btn_blue.png")
				:addTo(self.tuoguanBorad)
				:setPosition(cc.p(0,100))
				:setScale9Enabled(true)
				:setContentSize(cc.size(214,82))
				
			local text = ccui.ImageView:create("game/text_qxtg.png")
				:addTo(cancelbtn)
				:setPosition(cc.p(112,41))

			WidgetUtils.addClickEvent(cancelbtn,function ()
				Socketapi.requestChangeTuoGuanState(false)
			end)
		end

		self.tuoguanBorad:setVisible(bool)
	end
end

return MatchDecorator