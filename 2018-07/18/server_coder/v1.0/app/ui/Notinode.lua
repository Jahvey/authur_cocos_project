
local TIME_OUT1 = 3   -- 网络一般
local TIME_OUT2 = 5   -- 网络差
local TIME_OUT3 = 10
local RECONNETTIME = 15 --
-- 是否处于后台
local enterBackGroundTime = 0
require "app.help.Qiyousdk"

function SHARECALLBACK_FUCN_FOR_ANDROID(errcode)
    --安卓获取到link转移到这里
    local event = cc.EventCustom:new("weixinsharecallback")
   event:setDataString(errcode)
   cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

local Scheduler = cc.Director:getInstance():getScheduler()
local Notinode =  class("Notinode",function()
    return cc.Node:create()
end)
function Notinode:ctor( )
	self:initData()
	self:initView()
	self:initEvent()
	if LINK_URL_DATA then
		self:linkdata(LINK_URL_DATA)
	end
end
function Notinode:initData()
	self.islogin = false
	self.linktable = nil
	self.sendServerTime = nil  -- 发送服务器时间
	self.localCheckSchedule = nil -- 本地检测时间handle
	self.netstate = 3  -- -- 3,2,1 好，一般 ，差

    --跑马灯
	self.paomaodingtable = {}
	self.paomaodingindex = 0
	self.isshowexit = false
	self.joinCallBack = nil
end
function Notinode:getInstance()
    if not Notinode_instance then
	    Notinode_instance = self.new()
	    cc.Director:getInstance():setNotificationNode(Notinode_instance)
	end
	return Notinode_instance
end
function Notinode:setisLogin(bool)
	-- body
	self.islogin = bool
end
-- 得到网络状态
function Notinode:getNetState()
	return self.netstate
end
-- 设置网络状态
function Notinode:setNetState(netstate)
	-- print("========netstate======",netstate)
	self.netstate = netstate
end
function Notinode:initView()
	self.reportnode = cc.Node:create()
	self:addChild(self.reportnode)
	-- self.testSpr = cc.Sprite:create("login/mahjong_table.jpg")
	-- self:addChild(self.testSpr)
	-- self.testSpr:setVisible(false)
	self:createLoading()
	local function onKeyReleased(keyCode, event)
        if keyCode == cc.KeyCode.KEY_BACK then
        	if tolua.cast(self.exitnode,"cc.Node") then
        		LaypopManger_instance:back()
        	else
	            self.exitnode = LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "是否退出游戏?",sureCallFunc = function()
					 if device.platform == "ios" then
					 	cc.Director:getInstance():endToLua()
					 elseif  device.platform == "android" then
						CommonUtils.exitgame()
					end
				end,cancelCallFunc = function()
					-- body
					self.isshowexit= false
				end})
			end
        elseif keyCode == cc.KeyCode.KEY_MENU  then
            
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end



function Notinode:responselogin(data)
	self:showLoading(false)
	self:showLoadingByLogined()
	if data.result == 0 then
		-- 注册心跳包请求
		SocketConnect_instance:sendheart()
		-- SocketConnect_instance:heartcheck()	
		-- 语音
	    if device.platform == "android" or device.platform == "ios" then
	    	IMDispatchMsgNode:cpLogin(GAME_LOCAL_CITY.."huapai"..data.user.uid)
		end
		-- self:RegisterLocalCheck() 
		print("登录成功")
		printTable(data)
		self:setisLogin(true)
		LocalData_instance:setIsCreated(data.is_created)
		LocalData_instance:setUseHeartBeat(data.use_heart_beat)
		LocalData_instance:setHeartBeatinterval(data.heart_beat_interval)
		local nike = LocalData_instance:getNick()
		local pic = LocalData_instance:getPic()
		local sex = LocalData_instance:getSex()
		if LocalData_instance:getNick() and LocalData_instance:getPic() and LocalData_instance:getSex() then
			Socketapi.updatainfo(LocalData_instance:getNick(), LocalData_instance:getPic(),LocalData_instance:getSex())
		end
		if data.user then
			LocalData_instance:set(data.user)
		end
		if nike then
			LocalData_instance:setNick(nike)
		end
		if pic then
			LocalData_instance:setPic(pic)
		end
		if sex then
			LocalData_instance:setSex(sex)
		end
		-- 上报推送id
		if device.platform == "ios" or device.platform == "mac" then
			ComHttp.reportToken()
		elseif device.platform == "android" then
			ComHttp.reportPushRegisId()
		end	
		--跑马灯
		ComHttp.reportpaomading()
		if device.platform == "ios" and SHENHEBAO == false then
			luaoc.callStaticMethod("RootViewController","ShowGPS")
			luaoc.callStaticMethod("RootViewController","startGPS")
		end
		ComHttp.reportPos()
		--奇鱼 反馈SDK 设置用户信息
		if IS_NEWFAKUI then
			Qiyousdk.setuserinfo()
		end
		if data.user then
			print("--------进入牌座------- = ",data.user.pos.pos_type)
			if data.user.pos.pos_type >= poker_common_pb.EN_Position_QUICK_MATCH and data.user.pos.pos_type < 300 then
				Socketapi.requestEnterMatch(data.user.pos.table_id,data.user.pos.gamesvrd_id,data.user.pos.pos_type)
			elseif data.user.pos.pos_type >= poker_common_pb.EN_Position_Fpf then
				print("---------------1")
				self:jointable(data.user.pos.table_id)
			--glApp:enterSceneByName("MainScene")
			elseif data.user.pos.pos_type == poker_common_pb.EN_Position_Hall then
				if glApp.sceneName ~= "MainScene" or glApp.sceneName == nil then
					glApp:enterSceneByName("MainScene")
				end
				if data.user.create_table_id and data.user.create_table_id ~= 0 then
					glApp:getCurScene():havecreateTable(data.user.create_table_id)
				end
				--被别人邀请进入牌座
				if self.linktable then
					if self.linktable.type and self.linktable.type == 1 and self.linktable.tableid then
						Socketapi.requestEnterTable(self.linktable.tableid)
					end
				end
			end	
		end
	elseif 	data.result == 100 then
		LocalData_instance:setIsTokenError(true)
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "微信登录验证错误，请重新登录！",sureCallFunc =function( )
			LocalData_instance:reset()
			LocalData_instance:setWechatid("")
			SocketConnect_instance:closeSocket()
			Notinode_instance:setisLogin(false)
			if glApp.sceneName ~= "LoginScene" or glApp.sceneName == nil then
				glApp:enterSceneByName("LoginScene",true)
			end
		end})	
	elseif data.result == 116 then	
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "您的账号有不良游戏行为，已被封禁。"})
	else
		print("denglu shibai")
		SocketConnect_instance:closeSocket()
		Notinode_instance:setisLogin(false)
		Notinode_instance:showLoading(false)
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "登录失败"..data.result,sureCallFunc =function( )
			if glApp.sceneName ~= "LoginScene" or glApp.sceneName == nil then
				glApp:enterSceneByName("LoginScene",true)
			end
		end})
	end
end

function Notinode:linkdata(str)
	print("output:"..str)
    local jsondata = string.gsub(str, "arthurlzmj:","")
    print("jsondata:"..jsondata)
    local jsontable = cjson.decode(jsondata)
    -- printTable(jsontable)
    if jsontable then
    	self.linktable = jsontable
    	if self.islogin and jsontable.type == 1 then
	    	Socketapi.requestEnterTable(jsontable.tableid)
	    	--self.linktable = nil
	    end
    end
end
function Notinode:needActionLink()
	return false
end
function Notinode:initEvent()
	ComNoti_instance:addEventListener("sendheartforcheck",self,self.sendheartforcheck)
	ComNoti_instance:addEventListener("cs_response_login",self,self.responselogin)
	ComNoti_instance:addEventListener("cs_response_sdr_create_table",self,self.responseCreateTable)
	ComNoti_instance:addEventListener("cs_response_sdr_enter_table",self,self.responseEnterTable)
	ComNoti_instance:addEventListener("cs_response_quick_match",self,self.responseQuickMatch)
	ComNoti_instance:addEventListener("cs_notify_repeated_login",self,self.repeatedlogin)
	ComNoti_instance:addEventListener("cs_response_heart_beat",self,self.responseHeartbeat)
	ComNoti_instance:addEventListener("cs_notify_chip_change",self,self.updateChip)
	ComNoti_instance:addEventListener("cs_notify_push_message",self,self.notfMessage)
	ComNoti_instance:addEventListener("cs_response_heart_beat",self,self.responseHeartbeat)
	
	ComNoti_instance:addEventListener("cs_notify_list_ip",self,self.NotifyListIP)
	ComNoti_instance:addEventListener("cs_reponse_table_flow_record",self,self.recordData)


	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	local listener = cc.EventListenerCustom:create("weixinurl" , function ( evt )
        local output = evt:getDataString()
        self:linkdata(output)
    end)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)


    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	local listener = cc.EventListenerCustom:create("jsonencodeforpay" , function ( evt )
        local response = evt:getDataString()
       	local output = cjson.decode(response)
       	if output then
        	-- printTable(output)
        	if output.package_json then
        		local output1 = cjson.decode(output.package_json)
        		if output1 then
        			luaoc.callStaticMethod("RootViewController","payjsoncall",output1)
        		end
        	end
        end
    end)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function Notinode:NotifyListIP(data)
	release_print(".......毛线.....Notinode:NotifyListIP 获取list_ip 成功 :",data.list_ip)
	LocalData_instance:setlist_ip(data.list_ip)
end


-- 心跳包
function Notinode:responseHeartbeat(data)
	local action = self:getActionByTag(1001)
	if action then
		self:stopActionByTag(1001)
	end
	if self.sendServerTime ~= nil then
		local time = data.time
		local interval_time = os.time() - self.sendServerTime
		self.sendServerTime = nil
		local netstate = 3 -- 1,2,3 好，一般 ，差
		if interval_time <= 1 then
			netstate = 3
		elseif  interval_time > 1 and interval_time <= 3 then
			netstate = 2
		elseif 	interval_time > 3 then
			netstate = 1
		end

		--print("网络信号:"..netstate)
		self:setNetState(netstate)
	end
end
function Notinode:sendheartforcheck()
	--print("发送了心跳包")
	local action = self:getActionByTag(1001)
	if action then
		self:stopActionByTag(1001)
	end
	local time = 0
	action  = cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()

		time = time + 1
		--print("心跳包等待时间")
		local netstate = 3
		if time == 1 then
			netstate = 3
		elseif time == 2 then
			netstate = 2
		else
			netstate = 1
		end
		if self:getNetState() > netstate then
			self:setNetState(netstate)
		end
	end)), 3)
	action:setTag(1001)
	self:runAction(action)
end
-- 本地检测
function Notinode:RegisterLocalCheck()
	self:unRegisterLocalCheck()
	local index = 0
	self.localCheckSchedule = Scheduler:scheduleScriptFunc(function ()
		if not self.islogin then
			self:unRegisterLocalCheck()
			return
		end
		index = index + 1
		if index > TIME_OUT3 then
			print("信号差")
			self:setNetState(3)
		end
		if index > RECONNETTIME then
			self:unRegisterLocalCheck()
			-- SocketConnect_instance:timeout()
			print("超时重连")
		end
	end,1,false)
end

function Notinode:unRegisterLocalCheck()
	if self.localCheckSchedule then
		Scheduler:unscheduleScriptEntry(self.localCheckSchedule)
		self.localCheckSchedule = nil
	end

end
function Notinode:jointable(tableid,callback)
	Socketapi.requestEnterTable(tableid)
	if callback then
		self.joinCallBack = callback
	end
end

function Notinode:responseCreateTable(data)
	Notinode_instance:showLoading(false)  
	if data.result == poker_common_pb.EN_MESSAGE_INVALID_PROTOCOL_VERSION then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "有新的版本更新,请重新开启游戏"})
		return 
	end
	print("..........responseCreateTable == ")
	printTable(data,"xp69")
	
	if data.result == 0 then
		if data.conf and data.conf.is_master_delegate == true then

			LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "成功创建了空房间("..data.tid..")",sureCallFunc = function()
				
				CommonUtils.sharedesk(data.tid, GT_INSTANCE:getTableDes(data.conf, 2),data.conf.ttype)
				LaypopManger_instance:back()

			end,cancelCallFunc = function()
				LaypopManger_instance:back()
			end}):setSureToShare()
		
		else
			Notinode_instance:jointable(data.tid)
		end

	elseif data.result == poker_common_pb.EN_MESSAGE_ALREADY_CREATE_TABLE then
		
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "您已经创建了房间("..data.ret_tid..")，点击确定进入！",sureCallFunc = function() 
			Notinode_instance:jointable(data.ret_tid)
		end})
	
	elseif data.result == poker_common_pb.EN_MESSAGE_NO_ENOUGH_CHIP then
		LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "房卡不足,是否购买?",sureCallFunc = function() 
			LaypopManger_instance:PopBox("ShopView")
		end})
	elseif data.result == poker_common_pb.EN_MESSAGE_ALREADY_IN_TABLE then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "您已经创建了房间("..data.ret_tid..")，点击确定进入！",sureCallFunc = function() 
			Notinode_instance:jointable(data.ret_tid)
		end})			
	else	
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result)})
	end	
end

function Notinode:responseQuickMatch(data)
	printTable(data)
	if data.result == 0 then
		Socketapi.requestEnterMatch(data.tid,data.game_svid,data.postype)
	elseif data.result == poker_common_pb.EN_MESSAGE_HAS_JOIN_PRE then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "已经报过名了！"})
	else
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "报名失败"})
	end
end

function Notinode:responseEnterTable(data)

	self.linktable = nil 
	print("............responseEnterTable ")
	printTable(data,"xp")
	Notinode_instance:showLoading(false)
	local func = function() 
		if self.joinCallBack and type(self.joinCallBack) == "function" then
			self.joinCallBack()
			self.joinCallBack = nil
		end
	end
	if data.result == 0 then
		-- 上报经纬度
		if SHENHEBAO == false then
			ComHttp.reportPos()
		end
		func()

		self:pushGameScene(data)

		-- glApp:enterSceneByName("CPaiScene",data)
		--glApp:enterSceneByName("GameScene",data)
	else
		if glApp:getCurScene().sceneName ~= "MainScene" then
			func()
			glApp:enterSceneByName("MainScene")
		else
			if data.result == poker_common_pb.EN_MESSAGE_NO_ENOUGH_CHIP then


				LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "房卡不足,是否购买?",sureCallFunc = function() 
					LaypopManger_instance:PopBox("ShopView")
				end})

			elseif data.result == poker_common_pb.EN_MESSAGE_ALREADY_CREATE_TABLE then
			-- print("========1====")
			-- if glApp.sceneName ~= "MainScene" or glApp.sceneName == nil then
				if data.ret_tid then
					LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "您已经创建了房间("..data.ret_tid..")，点击确定进入！",sureCallFunc = function() 
						self:jointable(data.ret_tid)
						func()
					end})
				elseif glApp.sceneName ~= "MainScene" then
					func()
					glApp:enterSceneByName("MainScene")
				end
			-- else		
			-- 	SocketConnect_instance.socket:close()	
			-- end	
			elseif data.result == poker_common_pb.EN_MESSAGE_ALREADY_IN_TABLE then
				func()
				SocketConnect_instance.socket:close()	
			elseif data.result == poker_common_pb.EN_MESSAGE_NOT_IN_TEA_BAR then
				func()
				LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "无法进入，您不是该亲友圈成员"})
			else
				LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = ComHelpFuc.errortips(data.result),sureCallFunc = func})	
				-- LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr	
			end
		end
	end
end
function Notinode:repeatedlogin()
	LocalData_instance:reset()
	SocketConnect_instance:closeSocket()
	Notinode_instance:setisLogin(false)

	if self.localRequestHeartBeatSchedule then
		Scheduler:unscheduleScriptEntry(self.localRequestHeartBeatSchedule)
		self.localRequestHeartBeatSchedule = nil
	end

	LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "重复登录，请重新登陆游戏。",sureCallFunc = function()
		glApp:enterScene("LoginScene",true)
	end})
end

function Notinode:cancelGame(typ)
	LocalData_instance:reset()
	SocketConnect_instance:closeSocket()
	Notinode_instance:setisLogin(false)
	
	if typ == 1 then
		-- 注销
		LocalData_instance:setWechatid("")
		glApp:enterScene("LoginScene",true)
		return
	elseif typ == 2 then
		-- 修复

		glApp:enterScene("LoginScene",false)
		return
	end
	glApp:enterScene("LoginScene",true)
end

function Notinode:updateChip(data)
	LocalData_instance:setChips(data.cur_chip)
end
function Notinode:createLoading()
	self.loadingView = require "app.ui.popbox.LoadingView".new()
	self.loadingView:setPosition(cc.p(display.width/2,display.height/2))
	self.loadingView:setVisible(false)
	self:addChild(self.loadingView,9999)
end
-- strType 用于显示的字符串类型
-- strtype 1 正在登录游戏 
function Notinode:showLoading(isVisible,strType)
	if not isVisible then
		isVisible = false
	end
	if tolua.cast(self.loadingView,"cc.Node") then
		if  self.loadingView.islogin then
			return
		end
		self.loadingView:setVisible(isVisible)
		self.loadingView:setShowStr(strType)	
	end	
end
function Notinode:showLoadingByLogin()
	if self.loadingView then
		self.loadingView.islogin = true
		self.loadingView:setVisible(true)
		self.loadingView:setShowStr(1)	
	end	
end

function Notinode:showLoadingByLogined()
	if self.loadingView  and self.loadingView.islogin then
		self.loadingView.islogin = false
		self.loadingView:setVisible(false)
	end
end

function Notinode:notfMessage(data)
	-- printTable(data)
	local output = cjson.decode(data.message)
	if output then
		if output.msgtype == 1 then
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = output.msg})
		elseif  output.msgtype == 2 then
			--跑马灯
			if output.list then
				self.paomaodingtable = output.list
			end
			self.paomaodingindex = 0
		elseif output.msgtype == 3 then
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = output.msg})
		elseif output.msgtype == 4 then 
			if SocketConnect_instance then 
				print("上报操作类型数据")
				SocketConnect_instance:reportOperateType()
			end
		end
	end
end
function Notinode:getPaomadingmsg()
	self.paomaodingindex = self.paomaodingindex + 1
	local totall = #self.paomaodingtable
	if self.paomaodingindex > totall then
		self.paomaodingindex = 1
	end
	-- print(self.paomaodingindex)
	while  (totall >= self.paomaodingindex) do
		if self.paomaodingtable[self.paomaodingindex].endtime > os.time() then
			return self.paomaodingtable[self.paomaodingindex].msg
		end
		self.paomaodingindex = self.paomaodingindex + 1
	end
	return nil 
end

function Notinode:cleanupSchedule()
	if self.localRequestHeartBeatSchedule then
		Scheduler:unscheduleScriptEntry(self.localRequestHeartBeatSchedule)
		self.localRequestHeartBeatSchedule = nil
	end
end

function Notinode:registerSchedule()

	  --注册15秒钟请求一次，检测信号
    self.localRequestHeartBeatSchedule = Scheduler:scheduleScriptFunc(function ()
    	--这里先置为网络情况最差的侍候
    	self:setNetState(3)
		Socketapi.sendRequestHeartBeat()
	end,15,false)

end

function Notinode:recordData(data)

	print("HistoryRecordView:recordData=====================")
	-- printTable(data,"xp")

	if data.result == 0 then
		if data.sdr_record and data.sdr_record.sdr_seats then
			self:pushRecordScene(data)
		else
			LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "回放视频过期，系统已自动清除！"})
			ComHttp.httpPOST(ComHttp.URL.REPORT_CRASH,{gameversion = CONFIG_REC_VERSION,crashinfo = "异常的牌局记录"..(data.sdr_record.tid or 0),uid = LocalData_instance:getUid() or 0},function()
	        	end)
		end
	elseif data.result == poker_common_pb.EN_MESSAGE_INVALID_FLOW_RECORD_NOT_FOUND then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "打牌记录不存在"})
	elseif data.result == poker_common_pb.EN_MESSAGE_DB_NOT_FOUND then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "系统异常"})
	else
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "打牌记录异常("..data.sdr_record..")"})
	end
end


function Notinode:pushGameScene(data)

	print("......Notinode:pushGameScene(data)")
	printTable(data,"xp")

	-- local gamePath = ScenePathList[data.table_info.sdr_conf.ttype]
	local gamePath = GT_INSTANCE:getGamePath(data.table_info.sdr_conf.ttype)
	local scenePackageName = "app.ui."..gamePath..".GameScene"
    local sceneClass = require(scenePackageName)

	if data.table_info.sdr_conf.ttype >= poker_common_pb.EN_Table_SDR_ES_MATCH then
		print("==================================比赛场")
		sceneClass = require("app.ui.match.matchmodule.MatchDecorator").overideGameScene(sceneClass)
	end
	require("app.ui.bag.RoomEquip").overideGameScene(sceneClass)
    local scene = sceneClass.new(data,"app.ui."..gamePath)

    if data.table_info.sdr_conf.is_free_game then
    	require("app.ui.game_decorator.DemonMode").new(scene)
    end

    display.runScene(scene)
    glApp.curscene = scene
 	glApp.sceneName = "GameScene"
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function Notinode:pushRecordScene(data)

	print("......Notinode:pushRecordScene(data)")
	-- printTable(data,"xp")
	
	-- local gamePath = ScenePathList[data.sdr_record.sdr_conf.ttype]
	local gamePath = GT_INSTANCE:getGamePath(data.sdr_record.sdr_conf.ttype)
	local scenePackageName = "app.ui."..gamePath..".RecordScene"
    local sceneClass = require(scenePackageName)
	require("app.ui.bag.RoomEquip").overideGameScene(sceneClass)
    local scene = sceneClass.new(data,nil,"app.ui."..gamePath)
    cc.Director:getInstance():pushScene(scene)
end

function Notinode:enterScene(sceneName, data)
    -- if sceneName == "MajiangScene" then
    --     sceneName = "testScene"
    -- end
    print("...........选择游戏界面！")
    local scenePackageName = "app.ui" .. ".scene." .. sceneName
    local sceneClass = require(scenePackageName)
    local scene = sceneClass.new(data)
    scene:init()
    display.runScene(scene)
    glApp.curscene = scene
 	glApp.sceneName = sceneName
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end




Notinode_instance =  Notinode:getInstance()

function goBackGround()
	print("进入 后台")
	-- if device.platform == "ios" then
	-- 	cc.SimpleAudioEngine:getInstance():pauseMusic()
	-- endp

	if device.platform ~= "ios"  and device.platform ~= "android" then
		if SocketConnect_instance and SocketConnect_instance.socket then
			SocketConnect_instance.socket:close()
	    end
	end
end

function enterBackGround()
	if device.platform == "ios" then

	 	cc.SimpleAudioEngine:destroyInstance()
	 	cc.SimpleAudioEngine:getInstance()
		package.loaded["cocos.framework.audio"] = nil
 		audio  = require("cocos.framework.audio")
 		cc.UserDefault:getInstance():setBoolForKey("isfirsttimesetaudio", false)
	 	AudioUtils.playMusic(AudioUtils.localmp3,true)
	end
	print("后台进入游戏")
		local effectvalue = cc.UserDefault:getInstance():getIntegerForKey("LocalData_effect")
    if effectvalue == 0 then
        effectvalue = 100
    elseif effectvalue == -1 then
        effectvalue = 0 
    end 
    local musicvalue = cc.UserDefault:getInstance():getIntegerForKey("LocalData_music") 
    if musicvalue == 0 then
        musicvalue = 100
    elseif musicvalue == -1 then
        musicvalue = 0 
    end
    audio.setSoundsVolume(effectvalue/100)
    audio.setMusicVolume(musicvalue/100)

end
