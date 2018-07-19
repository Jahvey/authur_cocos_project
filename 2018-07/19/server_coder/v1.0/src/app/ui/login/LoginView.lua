require "app.ui.CityManager"
require "app.ui.GameTypeManager"
require "app.help.WidgetUtils"
require "app.help.AudioUtils"
require "app.baseui.BaseView"
require "app.baseui.PopboxBaseView"
-- require "app.baseui.LaypopManger"
require "app.module.PopboxManager"
require "app.help.ComNoti"
require "app.help.CommonUtils"
require "app.net.SocketConnect"
require "app.help.NetPicUtils"

require "app.net.Socketapi"
require "app.net.ComHttp"
require "app.module.HttpManager"
require "app.ui.Notinode"
require "app.help.ComHelpFuc"
require "app.data.LocalData"

require "app.module.ModuleManager"
SHENHEBAO = false
CONFIG_DEBUG = false

local LoginView = class("LoginView",function()
    return cc.Node:create()
end)
function LoginView:ctor(loginscene,isnohttp)

    self.isclickWeiChat = false

    if device.platform == "ios"  or device.platform == "android" then
	    if cc.UserDefault:getInstance():getIntegerForKey("OPEN_CITY",0) == 0 then
		   	Notinode_instance:enterScene("SelectScene")
		    return
		end
	end

    self:initview(loginscene,isnohttp)
    self:initEvent()
    
end

function LoginView:initview(loginscene,isnohttp)
	local checknode = loginscene.layout:getChildByName("checkNode")
	checknode:setVisible(false)

	local loginnode = loginscene.layout:getChildByName("loginNode")
	loginnode:setVisible(true)
	WidgetUtils.setScalepos(loginnode)
	self.protocolBg = loginnode:getChildByName("protocolBg")
	WidgetUtils.addClickEvent(self.protocolBg, function( )
		print("用户协议")
		LaypopManger_instance:PopBox("UserAgreementView")
	end)
	self.checkbox = loginnode:getChildByName("protocolBg"):getChildByName("checkbox")

	local weChatLoginBtn = loginnode:getChildByName("weChatLoginBtn")
	local guestLoginBtn = loginnode:getChildByName("guestLoginBtn"):setVisible(false)
	self.bg = loginscene.layout:getChildByName("bg")
	
	CommonUtils.isInstallweichat(function(isinstante)
		INSTALLWEICHAT = isinstante
	end)

	if SHENHEBAO or INSTALLWEICHAT == false  then
		weChatLoginBtn:setVisible(false)
		guestLoginBtn:setVisible(true)
	else
		weChatLoginBtn:setVisible(true)
		guestLoginBtn:setVisible(false)
	end
	

	self.citybtn = loginnode:getChildByName("citybtn")
	WidgetUtils.addClickEvent(self.citybtn, function( )
		LaypopManger_instance:PopBox("PromptBoxView",2,{tipstr = "是否切换城市?",sureCallFunc = function()
			Notinode_instance:enterScene("SelectScene")
		end,cancelCallFunc = function()
			LaypopManger_instance:back()
		end})	
	end)	

	self.citybtn:getChildByName("citytext"):setTexture("city/city_"..GAME_LOCAL_CITY..".png")
	
	-- weChatLoginBtn:setVisible(false)
	-- guestLoginBtn:setVisible(true)
	-- isnohttp = false

	-- self.isclickWeiChat = true
	-- LocalData_instance:setlogintype(poker_common_pb.EN_Accout_Guest)
	-- self:requestLogin(poker_common_pb.EN_Accout_Guest,os.time()..math.random(100000,9999999))	

	-- 保存本地数据(php)
	local function saveLocalData(httpMsg)
		-- 保存数据
		if httpMsg.nickname then
			LocalData_instance:setNick(httpMsg.nickname)
		end	
		if httpMsg.img then
			
			print("............头像  ",httpMsg.img)

			LocalData_instance:setPic(httpMsg.img)
		end
		if httpMsg.unionid then
			LocalData_instance:setAccount(httpMsg.unionid)
			cc.UserDefault:getInstance():setStringForKey("weixin_account", httpMsg.unionid)
		end
		if httpMsg.userhash then	
			LocalData_instance:setToken(httpMsg.userhash)
			cc.UserDefault:getInstance():setStringForKey("weixin_userhash", httpMsg.userhash)
		end
		if httpMsg.wechatid then
			LocalData_instance:setWechatid(httpMsg.wechatid)
		end	
		-- php 1 男 2 女 C++ 0 男 1 女
		if httpMsg.sex then
			LocalData_instance:setSex(tonumber(httpMsg.sex)-1)
		end	
	end

	local weChatLoginBtn = loginnode:getChildByName("weChatLoginBtn")
	local function clickwechat ( )

		print(".................微信登录！！！")

		weChatLoginBtn:setTouchEnabled(false)
        weChatLoginBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create( function()
            weChatLoginBtn:setTouchEnabled(true)
        end )))

		if not self:checkSelectProtocol() then
			return
		end
		if self.isclickWeiChat then
			return
		end
		self:runAction(cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(function() 
			self.isclickWeiChat = false
		end)))
		-- Notinode_instance:showLoading(true)
		-- 微信SDK 登录
		local function WeixinSdkLogin()	
			if device.platform == "ios" then
				-- self.isclickWeiChat = true
				luaoc.callStaticMethod("RootViewController","weixinLoginAction",{callback =function(code)
					-- body
					print("codelua:"..code)
					self.isclickWeiChat = true
					Notinode_instance:showLoading(true)
					ComHttp.httpPOST(ComHttp.URL.LOGIN,{code = code},function(msg)
						print("登录php")
						printTable(msg)
						if not WidgetUtils:nodeIsExist(self) then
							-- Notinode_instance:showLoading(false)
							self.isclickWeiChat = false
							return
						end
						self.isclickWeiChat = false
						saveLocalData(msg)
						LocalData_instance:setlogintype(poker_common_pb.EN_Accout_Weixin)
						self:requestLogin(poker_common_pb.EN_Accout_Weixin)
					end)
				end})
			elseif device.platform == "android" then
				-- self.isclickWeiChat = true
				-- Notinode_instance:showLoading(true)
				luaj = require("cocos.cocos2d.luaj")
				local function logincallback(code)
					print("codelua:"..code)
					self.isclickWeiChat = true
					Notinode_instance:showLoading(true)
					ComHttp.httpPOST(ComHttp.URL.LOGIN,{code = code},function(msg)
						if not WidgetUtils:nodeIsExist(self) then
							Notinode_instance:showLoading(false)
							self.isclickWeiChat = false
							return
						end
						self.isclickWeiChat = false
						print("登录php")
						-- printTable(msg)
						saveLocalData(msg)
						LocalData_instance:setlogintype(poker_common_pb.EN_Accout_Weixin)
						self:requestLogin(poker_common_pb.EN_Accout_Weixin)
					end)
				end
				local className = NOWANDROIDPATH
			    local methodName = "weiXinLogin"
			    local args  =  {logincallback}
			    local sig = "(I)V"
			    luaj.callStaticMethod(className, methodName, args, sig)	
			else
				Notinode_instance:showLoading(true)
				LocalData_instance:setlogintype(poker_common_pb.EN_Accout_Guest)
				self:requestLogin(poker_common_pb.EN_Accout_Guest,os.time()..math.random(100000,9999999))		
			end
		end
		-- 微信ID存在直接请求威信校验
		if LocalData_instance:getWechatid() and LocalData_instance:getWechatid() ~= "" then
			ComHttp.httpPOST(ComHttp.URL.CHECK_LOGIN,{wechatid = LocalData_instance:getWechatid()},function(msg)
				if not WidgetUtils:nodeIsExist(self) then
					self.isclickWeiChat = false
					return
				end
				self.isclickWeiChat = false
				-- 状态：1正常，2已过期，3错误的wecha
				if tonumber(msg.status) == 1 then
					print("登录php")
					-- printTable(msg)
					saveLocalData(msg)
					LocalData_instance:setlogintype(poker_common_pb.EN_Accout_Weixin)
					self:requestLogin(poker_common_pb.EN_Accout_Weixin)
				elseif tonumber(msg.status) == 2 then
					print("微信登录已过期")
					WeixinSdkLogin()
				elseif tonumber(msg.status) == 3 then
					print("错误的威信id")
					WeixinSdkLogin()
				end	
			end)
		else
			WeixinSdkLogin()
		end
	end

	WidgetUtils.addClickEvent(weChatLoginBtn,clickwechat)
	WidgetUtils.addClickEvent(guestLoginBtn, function( )
		print("guestLoginBtn")
		if self.isclickWeiChat then
			return
		end
		if not self:checkSelectProtocol() then
			return
		end
		self.isclickWeiChat = true
		LocalData_instance:setlogintype(poker_common_pb.EN_Accout_Guest)
		self:requestLogin(poker_common_pb.EN_Accout_Guest,os.time()..math.random(100000,9999999))	
	end)	
	self.isselected = true
	local function selectedEvent( sender, eventType )
        if eventType == ccui.CheckBoxEventType.selected then
        	self.isselected =  true
        elseif eventType == ccui.CheckBoxEventType.unselected then
            self.isselected = false
        end
    end
	self.checkbox:addEventListener(selectedEvent)
	if isnohttp then
		local account = cc.UserDefault:getInstance():getStringForKey("weixin_account","")
		local hash = cc.UserDefault:getInstance():getStringForKey("weixin_userhash", "")
		if account ~= "" and hash ~= "" then
			LocalData_instance:setAccount(account)
			LocalData_instance:setToken(hash)
			self:requestLogin(poker_common_pb.EN_Accout_Weixin)
		else
			self:runAction(cc.CallFunc:create(function ( )
				if LocalData_instance:getWechatid() then
					clickwechat()
				end
			end))
		end
	else
		self:runAction(cc.CallFunc:create(function ( )
			if LocalData_instance:getWechatid() then
				clickwechat()
			end
		end))
	end
	self:initMusic()
end
-- 检测是否勾选同意协议
function LoginView:checkSelectProtocol()
	if not self.isselected then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "请确认并同意用户协议"})
		return false
	end
	return true
end
function LoginView:responseLogin()
	self.isclickWeiChat = false
end
function LoginView:initEvent()
	ComNoti_instance:addEventListener("cs_response_login",self,self.responseLogin)
	--ComNoti_instance:addEventListener("cs_response_login",self,self.responselogin)
	--ComNoti_instance:addEventListener("wein_skd_login_return",self,self.weisdkloginresult)
end
-- 更新本地数据
function LoginView:updateLocalData(data)
	if data.result == 0 then
		LocalData_instance:setIsCreated(data.is_created)
		LocalData_instance:setUseHeartBeat(data.use_heart_beat)
		LocalData_instance:setHeartBeatinterval(data.heart_beat_interval)
		if data.user then
			LocalData_instance:set(data.user)
		end
	end
end
-- 请求登录
function LoginView:requestLogin(typ,uuid)
	Notinode_instance:showLoadingByLogin()
	print("LoginView:requestLogin")
	-- 请求登录
	Socketapi.login(typ,uuid)
end
-- 添加按钮特效
function LoginView:btnEffect(node,dir)
	if node.layout:getChildByName("btnEffect") then
		node.layout:getChildByName("btnEffect"):removeFromParent()
	end
	local sprite = WidgetUtils:createLoginEffect2(dir)
	-- sprite:setScaleX(-1)
	sprite:setName("btnEffect")
	node.layout:addChild(sprite)
	sprite:setPosition(cc.p(display.cx,display.cy))

end
-- 添加亮光效果
function LoginView:shineEffect(node)
	-- 1.创建模板、ClippingNode(裁剪节点)
	local pic = "common/game_title.png"
    local stencil = display.newSprite(pic)

    local clipper = cc.ClippingNode:create()
    clipper:setStencil(stencil)
    -- clipper:setInverted(true)
    clipper:setAlphaThreshold(0)

	-- 2.标题和光效
    local spr_title = display.newSprite(pic)
    local spr_titlesz = spr_title:getContentSize()
    spark = display.newSprite("common/shine2.png")
    spark:setBlendFunc(gl.ONE,gl.ONE)
    spr_title:setOpacity(0)
    clipper:addChild(spr_title)
    clipper:addChild(spark)
	
	local x,y = self.bg:getPosition()
	clipper:setPosition(x+40,y-90)
	node.layout:addChild(clipper)
    local act1 = cc.CallFunc:create(function() 
    	spark:setPosition(cc.p(-400, 0)) end)
    local act2 = cc.MoveBy:create(4,cc.p(800,0))
    local act3 = cc.CallFunc:create(function() 
    	self:btnEffect(node)
    end)
    local act4 = cc.DelayTime:create(5)
    spark:runAction(cc.RepeatForever:create(cc.Sequence:create(act1,act2,act3,act4)))
end
--声音预加载
function LoginView:preloadEffect()

end


function LoginView:initMusic()
    -- audio.stopAllSounds()
    -- if device.platform == "windows" or device.platform == "mac" then 
    --     return true
    -- end
    AudioUtils.playMusic( nil,true)
    if cc.UserDefault:getInstance():getIntegerForKey("LocalData_music",-99) == -99 then
        cc.UserDefault:getInstance():setIntegerForKey("LocalData_music",50)
    end
    local effectvalue = cc.UserDefault:getInstance():getIntegerForKey("LocalData_effect")
    if effectvalue == 0 then
        effectvalue = 100
    elseif effectvalue == -1 then
        effectvalue = 0 
    end 
    local musicvalue = cc.UserDefault:getInstance():getIntegerForKey("LocalData_music") 
    if musicvalue == 0 then
        musicvalue = 70
    elseif musicvalue == -1 then
        musicvalue = 0 
    end
    audio.setSoundsVolume(effectvalue/100)
    audio.setMusicVolume(musicvalue/100)
    if effectvalue > 0 then
        cc.UserDefault:getInstance():setIntegerForKey("LocalData_effect",effectvalue)
    elseif effectvalue == 0 then
        cc.UserDefault:getInstance():setIntegerForKey("LocalData_effect",-1)
    end
    if musicvalue > 0 then
        cc.UserDefault:getInstance():setIntegerForKey("LocalData_music",musicvalue)
    elseif musicvalue == 0 then
        cc.UserDefault:getInstance():setIntegerForKey("LocalData_music",-1)
    end


end

return LoginView
