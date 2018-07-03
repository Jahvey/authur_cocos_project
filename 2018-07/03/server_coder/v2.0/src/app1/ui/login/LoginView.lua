require "app.help.WidgetUtils"
require "app.help.AudioUtils"
require "app.baseui.BaseView"
require "app.baseui.PopSceneBaseView"
require "app.baseui.PopboxBaseView"
require "app.baseui.LaypopManger"
require "app.data.LocalData"
require "app.data.LocalConfig"
require "app.help.ComNoti"
require "app.help.CommonUtils"
require "app.net.SocketConnect"
require "app.help.NetPicUtils"
require "app.help.ComHelpFuc"
require "app.net.Socketapi"
require "app.net.ComHttp"
require "app.ui.Notinode"
require "app.language.LangUtils"

local LoginView = class("LoginView",function()
    return cc.Node:create()
end)


function LoginView:ctor(loginscene)
    print("login view local")
    self:initview(loginscene)
    self:initEvent()
    Notinode_instance.tipsmsg = {}
    
end

function LoginView:initview(loginscene)
	local checknode = loginscene.layout:getChildByName("checkNode")
	checknode:setVisible(false)

	local loginnode = loginscene.layout:getChildByName("loginNode")
	loginnode:setVisible(true)

	self.protocolBg = loginnode:getChildByName("checkbg")
	WidgetUtils.addClickEvent(self.protocolBg, function( )
		print("用户协议")
		LaypopManger_instance:PopBox("UserAgreementView")
	end)
	self.checkbox = loginnode:getChildByName("checkbg"):getChildByName("checkbox")

	local weChatLoginBtn = loginnode:getChildByName("weChatLoginBtn")
	local guestLoginBtn = loginnode:getChildByName("guestLoginBtn"):setVisible(false)
	
	CommonUtils.isInstallweichat(function(isinstante)
		INSTALLWEICHAT = isinstante
	end)
	-- SHENHEBAO = true 
	-- INSTALLWEICHAT = false
	-- SHENHEBAO = true
	if INSTALLWEICHAT == false then
		weChatLoginBtn:setVisible(false)
		guestLoginBtn:setVisible(true)
	end
	local function guestlogin()
		print("guest")
		local tableinfo = {}
		tableinfo.code = os.time()
		--tableinfo.code = "1"
		--tableinfo.code = "1516460481"
		Notinode_instance:showLoading(true)
		ComHttp.httpPOST( ComHttp.URL.GUESTLOGIN,tableinfo,function(data)
			printTable(data,"sjp")
			LocalData_instance:set(data.data.content)
			Socketapi.joinhall()
		end)
	end
	local weixinbtn
	local function WeixinSdkLogin()
		if device.platform == "ios" then
			luaoc.callStaticMethod("RootViewController","weixinLoginAction",{callback =function(code)
				-- body
				print("codelua:"..code)
				Notinode_instance:showLoading(true)
				weixinbtn(code)
			end})
		elseif device.platform == "android" then
			luaj = require("cocos.cocos2d.luaj")
			local function logincallback(code)
				print("codelua:"..code)
				Notinode_instance:showLoading(true)
				weixinbtn(code)
			end
			local className = "com/dazhongjuyou/moretop/wxapi/WXEntryActivity"
		    local methodName = "weiXinLogin"
		    local args  =  {logincallback}
		    local sig = "(I)V"
		    luaj.callStaticMethod(className, methodName, args, sig)	
		end
	end
	weixinbtn = function(code)
		local userid = cc.UserDefault:getInstance():getStringForKey("userid","")
		if userid == "" and code == nil then
			WeixinSdkLogin()
		else
			if code then
				ComHttp.httpPOST(ComHttp.URL.LOGIN,{code = code},function(msg)
						if msg.result ==403 then
							cc.UserDefault:getInstance():setStringForKey("userid","")
							WeixinSdkLogin()
						elseif msg.result == 1 then
							cc.UserDefault:getInstance():setStringForKey("userid",msg.data.content.userid)
							Notinode_instance:responselogin(msg)
						else 
							cc.UserDefault:getInstance():setStringForKey("userid","")
						end
					end)
			else
				Notinode_instance:showLoading(true)
				ComHttp.httpPOST(ComHttp.URL.LOGIN,{userid = userid},function(msg)
						if msg.result ==403 then
							cc.UserDefault:getInstance():setStringForKey("userid","")
							WeixinSdkLogin()
						elseif msg.result == 1 then
							cc.UserDefault:getInstance():setStringForKey("userid",msg.data.content.userid)
							Notinode_instance:responselogin(msg)
						else
							cc.UserDefault:getInstance():setStringForKey("userid","")
						end
					end)
			end
		end
	end

	local weChatLoginBtn = loginnode:getChildByName("weChatLoginBtn")
	local function clickwechat ( )
		if not self:checkSelectProtocol() then
			return
		end
		-- if true then
		-- 	require "app.ui.kutong.AnmiKu"
		-- 	local node = AnmiKu.sazi(4,6)
		-- 	self:addChild(node)
		-- 	node:setPosition(cc.p(display.cx,display.cy))
		-- 	return 
		-- end
		-- if true then
		-- 	LaypopManger_instance:PopBox("AllResultView",data)
		-- 	return 
		-- end
		-- if true then
		-- 	LaypopManger_instance:PopBox("SingleResultView",data)
			
		-- 	return 
		-- end
		if device.platform == "mac" then
			guestlogin()
		else
			weixinbtn()
		end
		--guestlogin()
	end
	WidgetUtils.addClickEvent(weChatLoginBtn, clickwechat)
	

	WidgetUtils.addClickEvent(guestLoginBtn, function( )
		print("guestLoginBtn")
		if not self:checkSelectProtocol() then
			return
		end
		guestlogin()
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

	-- self.actionview = require "app.ui.game.ActionView".new(self.scene)
	-- self.actionview:setPosition(cc.p(display.width - 200,200))
	-- self:addChild(self.actionview)
	-- self.actionview:show({playTypes={1,2,3,4}})
	-- if self.actionview:isVisible() then
	-- 	print("显示")
	-- else
	-- 	print("隐藏")
	-- end
	-- local pos = self.actionview:convertToWorldSpace(cc.p(0,0))
	-- print(pos.x)
	-- print(pos.y)
end
-- 检测是否勾选同意协议
function LoginView:checkSelectProtocol()
	if not self.isselected then
		LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "请确认并同意用户协议"})
		return false
	end
	return true
end
function LoginView:initEvent()
end

function LoginView:test(data)
	-- data = {
	-- 	["carddata"] = 17,
 --  	   ["chiCards"] = {
 --    		   ["15;16;17"] =  {
 --      			"17;18;19",
 --      		},
 --    		   ["16;17;18"] =  {
 --      			"17;18;19",
 --      		},
 --    		   ["17;17;7"] =  {
 --      		},
 --      		["17;17;2"] =  {
 --      		},
 --      		["17;17;1"] =  {
 --      		},
 --      		["17;17;3"] =  {
 --      		},
 --      		["17;17;4"] =  {
 --      		},
 --    		   ["17;18;19"] =  {
 --      			"15;16;17",
 --      			"16;17;18",
 --      			"16;17;18",
 --      			"16;17;18",
 --      			"16;17;18",
 --      			"16;17;18",
 --      			"16;17;18",
 --      			"16;17;18",
 --      			"16;17;18",
 --      		},
 --    	},
 --  	   ["keytype"] = "3;4;3",
 --  	   ["playTypes"] = {
 --    		5,
 --    		9,
 --    	},
 --  	   ["curPlayerIndex"] = 2,
 --  	   ["curPlayerFlag"] = 2,
 --  }

  
end

	



return LoginView
