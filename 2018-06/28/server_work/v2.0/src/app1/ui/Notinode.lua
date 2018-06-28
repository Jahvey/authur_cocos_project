
local TIME_OUT1 = 3   -- 网络一般
local TIME_OUT2 = 5   -- 网络差
local TIME_OUT3 = 10
local RECONNETTIME = 15 --


function SHARECALLBACK_FUCN_FOR_ANDROID(errcode)
    --安卓获取到link转移到这里
 
   if tonumber(errcode) == 0 and ISPYQUAN == true then
   		ComHttp.shareback()
   		--print("发送了秦秋")
   end
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
	self.tipsmsg = {}
	self.msgindex = 0
	self.islogin = false
	self.linktable = nil
	self.sendServerTime = nil  -- 发送服务器时间
	self.localCheckSchedule = nil -- 本地检测时间handle
	self.netstate = 4  -- -- 4,3,2 好，一般 ，差 极差
	--跑马灯
	self.paomaodingtable = {}
	self.paomaodingindex = 0
	self.isshowexit = false
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
	self.netstate = netstate
end
function Notinode:initView()
	-- self.testSpr = cc.Sprite:create("login/mahjong_table.jpg")
	-- self:addChild(self.testSpr)
	-- self.testSpr:setVisible(false)
	self.timenode = cc.Node:create()
	self:addChild(self.timenode)

	 local function onKeyReleased(keyCode, event)
	 	if self.isshowexit then
	 		return 
	 	end
	 	self.isshowexit = true
        local label = event:getCurrentTarget()
        if keyCode == cc.KeyCode.KEY_BACK then
            LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "是否退出游戏?",sureCallFunc = function()
				cc.Director:getInstance():endToLua()
				CommonUtils.exitgame()
			end,cancelCallFunc = function()
				-- body
				self.isshowexit= false
			end})
        elseif keyCode == cc.KeyCode.KEY_MENU  then
            
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    local listener = cc.EventListenerCustom:create("yvsdk_finshed" , handler(self, self.onFinshPlayVoice))
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
	self:createLoading()
end


function Notinode:onFinshPlayVoice()
	cc.SimpleAudioEngine:getInstance():resumeMusic()
end
function Notinode:responselogin(data)
	LocalData_instance:set(data.data.content)
	Socketapi.joinhall()
end

function Notinode:linkdata(str)
	print("output:"..str)
    local jsondata = string.gsub(str, "arthurlzmj:","")
    print("jsondata:"..jsondata)
    local jsontable = cjson.decode(jsondata)
    print(jsontable)
    if jsontable then
    	self.linktable = jsontable
    	if self.islogin and jsontable.type == 1 then
	    	--Socketapi.requestEnterTable(jsontable.tableid)
	    	--self.linktable = nil
	    end
    end
end
function Notinode:needActionLink()
	return false
end
function Notinode:rankcall(data )
	table.insert(self.tipsmsg,data.content)
	self:showtips()
end
function Notinode:initEvent()
	ComNoti_instance:addEventListener("3;2;3;15",self,self.rankcall)
	ComNoti_instance:addEventListener("3;1;1",self,self.Logincallback)
	ComNoti_instance:addEventListener("3;2;1;2",self,self.entertablecallback)
	ComNoti_instance:addEventListener("3;3;1;2",self,self.entertablecallback)
	ComNoti_instance:addEventListener("3;3;3;1",self,self.entertableforkutong)
	ComNoti_instance:addEventListener("3;2;3;1",self,self.entertable)
	ComNoti_instance:addEventListener("3;2;2;1",self,self.entertable)
	ComNoti_instance:addEventListener("3;1;3",self,self.heartreturn)
	ComNoti_instance:addEventListener("3;11;1",self,self.toastcall)
	ComNoti_instance:addEventListener("3;1;8",self,self.msgcall)
	ComNoti_instance:addEventListener("3;2;6",self,self.recordcall)
	ComNoti_instance:addEventListener("3;1;4",self,self.goldupdata)
	ComNoti_instance:addEventListener("3;22;2",self,self.repeatlogin)
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	local listener = cc.EventListenerCustom:create("weixinurl" , function ( evt )
        local output = evt:getDataString()
        self:linkdata(output)
    end)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)


     local listener = cc.EventListenerCustom:create("weixinsharecallback" , function ( evt )
        local output = evt:getDataString()
	    if tonumber(output) == 0 and ISPYQUAN == true then
	   		ComHttp.shareback()
	   		--print("发送了秦秋")
	   end
    end)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end
function Notinode:entertablecallback(data)
	if data.result == 0 then
		 Notinode_instance:showLoading(false)
		print("弹框")
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info,sureCallFunc = function()
		--glApp:enterScene("MainScene",true)
	end})
		return 
	end
end

function Notinode:getMsg()
	self.msgindex = self.msgindex+1
	if  self.msgtable then
		if self.msgtable[self.msgindex] and self.msgtable[self.msgindex].content then
			return self.msgtable[self.msgindex].content
		else
			self.msgindex = 1 
			if self.msgtable[self.msgindex] and self.msgtable[self.msgindex].content then
				return self.msgtable[self.msgindex].content
			else
				return "欢迎您来到聚闲有游戏，祝你游戏愉快"
			end
		end
	else
		return "欢迎您来到聚闲有游戏，祝你游戏愉快"
	end
end
function Notinode:msgcall(data)
	self.msgtable = data.gamemessagelist
end
function Notinode:Logincallback(data)
	Socketapi.sendtotallmsg()
	print("Logincallback:"..glApp.sceneName)
	LocalData_instance.ip = data.ip
	LocalData_instance.gamecoins = data.gamecoins
	LocalData_instance.accountid = data.accountid
	LocalData_instance.ggao = data.content
	print("Logincallback:"..glApp.sceneName)
	if data.gamestatus == 0 then
		if glApp.sceneName ~= "MainScene" then
			glApp:enterSceneByName("MainScene")
		else
			glApp.curscene:updataview()
		end
	elseif data.gamestatus == 1 then
		Socketapi.reconjointable()
	elseif data.gamestatus == 2 then
		Socketapi.reconjointableforkutong()
	end
end
function Notinode:heartreturn(data)
	SocketConnect_instance:heartreturn()
end
function Notinode:entertable(data)
	 Notinode_instance:showLoading(false)
	glApp:enterSceneByName("MajiangScene",data)
end
function Notinode:entertableforkutong(data)
	 Notinode_instance:showLoading(false)
	glApp:enterSceneByName("KutongScene",data)
end
function Notinode:createLoading()
	self.loadingView = require "app.ui.popbox.LoadingView".new()
	self.loadingView:setPosition(cc.p(display.width/2,display.height/2))
	self.loadingView:setVisible(false)
	self:addChild(self.loadingView,9999)

	self.tipsnode = cc.Sprite:create("load.png")
	self.tipsnode:setPosition(cc.p(display.cx,display.height-50))
	self:addChild(self.tipsnode)
	local s = self.tipsnode:getContentSize()
    local label = cc.Label:createWithSystemFont( "", "", 30)
    label:setColor(cc.c3b(0xd6, 0xc2, 0x5a))
    self.tipsnode:addChild(label,2)
    label:setPosition(s.width/2, s.height/2)
    label:setAnchorPoint(cc.p(0.5, 0.5))
    self.tipstext = label
    self.tipsnode:setVisible(false)

end
function Notinode:showtips(  )
	print("show tip1")
	if self.isplayingtip then
		return
	end
	if #self.tipsmsg > 0 then
		print("show tip2")
		self.isplayingtip = true
		local msg = self.tipsmsg[1]
		self.tipsnode:setVisible(true)
		self.tipsnode:stopAllActions()
		table.remove(self.tipsmsg,1)
		 self.tipstext:setString(msg)
		self.tipsnode:setOpacity(0)
		self.tipsnode:runAction(cc.Sequence:create(cc.FadeIn:create(0.5),cc.DelayTime:create(5),cc.FadeOut:create(0.5),cc.CallFunc:create(function( ... )
			
			self.tipsnode:setVisible(false)
		end),cc.DelayTime:create(1),cc.CallFunc:create(function( ... )
			
			self.isplayingtip = false
			self:showtips()
		end)))
	end
end
-- strType 用于显示的字符串类型
-- strtype 1 正在登录游戏 
function Notinode:showLoading(isVisible,strType)
	if not isVisible then
		isVisible = false
	end
	if self.loadingView then
		self.loadingView:stopAllActions()
		self.loadingView:setVisible(isVisible)
		self.loadingView:setShowStr(strType)
	end	
end
function Notinode:recordcall(data)
	if data.result == 0 then
		 Notinode_instance:showLoading(false)
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = data.info,sureCallFunc = function()
		end})
		return
	end
	local leng = string.len(data.data)
	local index = 1
	local jsonlist = {}
	while index < leng do
		local findpos = string.find(data.data,"#",index)
		if findpos then
			local str = string.sub(data.data,index,findpos-1)
			index = findpos + 1
			--release_print(str)
			table.insert(jsonlist,str)
		else
			break
		end
	end
	local  scene = require "app.ui.scene.RecordScene".new(jsonlist)
	cc.Director:getInstance():pushScene(scene)
end

function Notinode:repeatedlogin()
	LocalData_instance:reset()
	SocketConnect_instance:closeSocket()
	Notinode_instance:setisLogin(false)
	LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "请重新登陆游戏。",sureCallFunc = function()
		glApp:enterScene("LoginScene",true)
	end})
end
function Notinode:goldupdata(data)
	if data.gamecoins > LocalData_instance.gamecoins then
		--LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "你获得了"..(data.gamecoins - LocalData_instance.gamecoins).."金豆"})
	end
	LocalData_instance.gamecoins = data.gamecoins
end

function Notinode:toastcall(data)
	CommonUtils:prompt(data.sysinfo)
end
function Notinode:repeatlogin( data )
	LocalData_instance:reset()
	SocketConnect_instance:closeSocket()
	Notinode_instance:setisLogin(false)
	LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "请重新登陆游戏。",sureCallFunc = function()
		glApp:enterScene("LoginScene",true)
	end})
end

function Notinode:setnet(time)
	if time <= 1 then
		self.netstate = 4
	elseif time<= 1.5 then
		self.netstate = 3
	elseif time<= 2 then
		self.netstate = 2
	else 
		self.netstate = 1
	end
end
Notinode_instance =  Notinode:getInstance()

function goBackGround()
	if device.platform == "ios" then
		--audio.resumeMusic()
	end
	if SocketConnect_instance.socket then
		SocketConnect_instance.socket:close()
	end
	print("进入 后台")
end



function enterBackGround()
	if device.platform == "ios" then
		--audio.pauseMusic()
		cc.SimpleAudioEngine:destroyInstance()
		cc.SimpleAudioEngine:getInstance()
		package.loaded["cocos.framework.audio"] = nil
		audio = require "cocos.framework.audio"
		AudioUtils.playMusic(AudioUtils.musiclocal)
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
