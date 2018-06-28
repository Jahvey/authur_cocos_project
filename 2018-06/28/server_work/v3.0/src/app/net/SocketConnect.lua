--
-- SocketConnect.lua
-- 处理SocketTCP的事件
-- 打包并发送数据
-- 解析包数据
-- TODO断线重连等公共逻辑
-- liyanzi
--
local SocketTCP = require "app.net.SocketTCP"
local scheduler = require "app.net.scheduler"
local SocketConnect = class("SocketConnect")

function SocketConnect:ctor( ) 
	self:init()
	self.closebymyself = false

	self.operatetypereport = {}
	self.localindexseletip = 1

	self.last_ip = nil
	self.defaultIpList = {}
	self.current_ip = nil
	self.list_ip = nil
	
	self:initDefaultIp()
	if CM_INSTANCE:getHTTPLOCALDFAULIST() then
		self.netchecker = require "app.net.Check".new()
	end

end

function SocketConnect:initDefaultIp()
	self.defaultIpList  = CM_INSTANCE:getIPLOCALDAFAULTLIST()

	local defaultId = cc.UserDefault:getInstance():getIntegerForKey("default_uid",0)
	local cnt = #self.defaultIpList
	local idx = math.fmod(defaultId,cnt)+1
	
	if defaultId == 0 then
		self.current_ip = self.defaultIpList[1]
	else	
		if idx == 0 then
			self.current_ip = self.defaultIpList[1]
		else
			self.current_ip = self.defaultIpList[idx]
		end
	end
end

function SocketConnect.getInstance()
    if not SocketConnect_instance then
	    SocketConnect_instance = SocketConnect.new()
	end
	return SocketConnect_instance
end

function SocketConnect:init( )
	self.parser = require("app/net/Parser").new()
	self.packageBuilder = require("app.net.PackageBuilder").new()
end

function SocketConnect:start()
	ComNoti_instance:cleanupEvent()
	self.parser:reset()
	self:stopallsche()
	self.operatetypereport = {}
	
	release_print(".............SocketConnect:start()")
	
	if self.failedconnect and CM_INSTANCE:getHTTPLOCALDFAULIST() then
		release_print("..............1")
		if  self.last_ip == self.current_ip  then
			release_print("............2")
			if  self.list_ip == nil  then
			 	if not self.isrequest then
			 		self.isrequest = true
			 		self.netchecker:sendRequest(self.netchecker.data[1],0)
			 	end
			else
				release_print("..............4 ")
				self.last_ip = self.list_ip
				self.list_ip = nil
			end
		else
			release_print("..............5")
			self.last_ip = self.current_ip
		end
	else
		release_print("............6")
		self.last_ip = self.current_ip
	end
	
	
	-- end
	self.closebymyself =false
	--外网固定ip
	self.port = CM_INSTANCE:getPORTONLINE()
	--根据配置
	if CM_INSTANCE:getIPLOCAL() then
		self.last_ip = CM_INSTANCE:getIPLOCAL().ip or self.last_ip
		self.port = CM_INSTANCE:getIPLOCAL().port  or self.port
	end

	release_print("...目前 链接的..self.last_ip =",self.last_ip)
	release_print("...目前 链接的..self.port =",self.port)
	if self.socket == nil then
		self.socket = SocketTCP.new(self.last_ip, self.port, false)
		self.socket:addEventListener(SocketTCP.EVENT_DATA, handler(self, self.data))
		self.socket:addEventListener(SocketTCP.EVENT_CLOSE, handler(self, self.close))
		self.socket:addEventListener(SocketTCP.EVENT_CLOSED, handler(self, self.closed))
		self.socket:addEventListener(SocketTCP.EVENT_CONNECTED, handler(self, self.connected))
		self.socket:addEventListener(SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.connectFailure))
	end
	self.socket:connect(self.last_ip, self.port)
	self:checknet()
end
function SocketConnect:checknet( )
end

function SocketConnect:stopallsche()
	if self.scheget then
		scheduler.unscheduleGlobal(self.scheget)
	end

	if self.schesend then
		scheduler.unscheduleGlobal(self.schesend)
	end
	if self.schesendheart then
		scheduler.unscheduleGlobal(self.schesendheart)
	end
end
function SocketConnect:doConnectSocket()
	self.socket:connect()
end
function SocketConnect:havegetdata()
	--print("havegetdata")
	if self.scheget == nil then
		local time = 0
		self.scheget = scheduler.scheduleGlobal(function()
			time = time + 1
			--print("havegetdata wait time:"..time)
			if time == 5 then
				--print("网络良好")
			end

			if time == 7 then
				--print("网络开始有问题了")
			end
			if time == 8 then
				--print("网络差")
			end
			if time == 10 then
				--print("网络最差")
				Notinode_instance:setNetState(1)
			end
			if time >= 12 then
				--print("可以重连了")
				SocketConnect_instance.socket:close()
				scheduler.unscheduleGlobal(self.scheget)
				release_print("心跳结束")

			end
		end, 1)
	else
		scheduler.unscheduleGlobal(self.scheget)
		self.scheget = nil
		self:havegetdata()
	end
end

function SocketConnect:sendheart()
	--print("发送心跳包")
	Socketapi.sendRequestHeartBeat()
	if self.schesendheart ~= nil then
		scheduler.unscheduleGlobal(self.schesendheart)
		self.schesendheart = nil
	end
	local time = 0
	self.schesendheart = scheduler.scheduleGlobal(function()
			time = time + 1
			if time > 9 then
				self:sendheart()
			end
		end, 1)
	
end

function SocketConnect:havesenddata()
	--print("havesenddata")
	if self.schesend == nil then
		local time = 0
		self.schesend = scheduler.scheduleGlobal(function()
			time = time + 1
			--print("havesenddata wait time:"..time)
			if time == 5 then
				self:sendheart()
				ComNoti_instance:dispatchEvent("sendheartforcheck", "123")
			end
		end, 1)
	else
		scheduler.unscheduleGlobal(self.schesend)
		self.schesend = nil
		self:havesenddata()
	end
end

function SocketConnect:test()
	self:data({data = self.datastr})
end
function SocketConnect:reportOperateType()
	local reportOperateString = ""

	if LOG_operatetypereport then 
		for i=1,#LOG_operatetypereport do
			reportOperateString = reportOperateString..i..LOG_operatetypereport[i].. "\n"
		end
	end
	ComHttp.httpPOST(ComHttp.URL.REPORT_CRASH,{gameversion = CONFIG_REC_VERSION,crashinfo = reportOperateString,uid = LocalData_instance.uid },function()
	 		print("上报操作类型成功")
        end)
	
end


function SocketConnect:data( event )
	--print("SocketConnect:data")
	-- if self.isfirist  then
	-- 	local lenth = string.len(event.data)
	-- 	self.datastr = string.sub(event.data,math.floor(lenth/2),lenth)
	-- end
	local result,headResult = self.parser:readPackage(event.data)
	
	if result then
		for i,tab in ipairs(result) do
			for k,v in pairs(tab) do
				if type(v) == "table" then
					if headResult and headResult[i] then
						-- print("==== headResult.json_msg_id=====222===", headResult[i].json_msg_id)
						if headResult[i].json_msg_id then
							v.json_msg_id = headResult[i].json_msg_id
						end
						if headResult[i].json_msg then
							v.json_msg = json.decode(headResult[i].json_msg)
						end
					end	
					

					if k == "cs_response_heart_beat" or k == "cs_notify_seat_operation_choice"then 
						if self.operatetypereport then 
							if #self.operatetypereport  >= 100 then 
								if self.operatetypereport[1] then 
									table.remove(self.operatetypereport,1)
								end
							end

							if k == "cs_response_heart_beat" then
								table.insert(self.operatetypereport,k.." "..tostring(os.date()))
							else
								local str = cjson.encode(v)
								if str then
									table.insert(self.operatetypereport,str.." "..tostring(os.date()))
								end
							end
						end
					end
					-- NetPicUtils.saveLog(k,v)
					if (k ~= "cs_response_heart_beat") and (k ~= "cs_notify_repeated_login")  then
						release_print(k)
						printTable(v,"sjp3")
						-- table.insert(self.delaytimetab,{k=k,v=v})
					 -- 	self:doacton()
					 	ComNoti_instance:dispatchEvent(k, v)
				 		if k == "cs_response_connect_ip" then
					 		release_print("......cs_response_connect_ip 请求  connect_ip.....",v.conn_ip)
							self.current_ip = v.conn_ip
							self.failedconnect = false
							--self:connectFailure()
							self.socket:close()
							--self:start()
						elseif k == "cs_notify_list_ip" then
							self.list_ip = v.list_ip
						else
							self:havegetdata()
						end
					 	
					elseif (k == "cs_notify_repeated_login") then
						Notinode_instance:repeatedlogin()
					else 
						--release_print(k)
						self:havegetdata()
						ComNoti_instance:dispatchEvent(k, v)
					end	
					--ComNoti_instance:dispatchEvent(k, v)
					 
				end
			end
		end
	else
		print("SocketConnect:data parse error")
		ComHttp.httpPOST(ComHttp.URL.REPORT_CRASH,{gameversion = CONFIG_REC_VERSION,crashinfo = "SocketConnect:data parse error",uid = LocalData_instance:getUid() or 0},function()
	        end)
		self.socket:close()
	end
	-- print(event.data)
end

function SocketConnect:doacton()

end

function SocketConnect:close( event )
	print("SocketConnect:close")
	-- LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "网络连接断开了"})	
	--self:dispatchEvent({name = EVENT_SOCKET_CLOSED, data = ''})
	if self.closebymyself then
		--自己主动调用关闭
	else
		Notinode_instance:showLoading(true,2)
		self:closed()
	end
end

function SocketConnect:closed( event )
	print("SocketConnect:closed")
	--self:dispatchEvent({name = EVENT_SOCKET_CLOSED, data = ''})
	--网络连接断开了
	if self.closebymyself == false then
		self:start()
	end
end

function SocketConnect:connected( event )
	print("SocketConnect:connected")
	self.isrequest = false
	--连接成功，--如果是请求gameip的ip，则请求gameip
	if  LocalData_instance:getlist_ip() and self.last_ip == LocalData_instance:getlist_ip() then
		Socketapi.sendRequestConnectIP()
		return
	end
	LocalData_instance:setconnect_ip(self.last_ip)
	self.parser:reset()
	Notinode_instance:showLoading(false)
	if self.lastmsg and self.lastname then
		if self.lastname == "cs_request_login" then

			if  LocalData_instance:getIsTokenError() then
				return
			end
			-- release_print(".......重新登陆时，发送的 list_ip = ",LocalData_instance:getlist_ip())
		  	if LocalData_instance:getlist_ip() then
		        --self.lastmsg.cs_request_login.request_list_ip = LocalData_instance:getlist_ip()
		        LocalData_instance:setlist_ip(nil)
		   	end 
	   	end
	   	release_print('登录消息')
		self:send(self.lastname,self.lastmsg)
	end
end

function SocketConnect:connectFailure( event )
	self.failedconnect = true
	print("SocketConnect:connectFailure")
end

function SocketConnect:send(msgName, data, param)

	

	if  msgName ~= "cs_request_connect_ip" and LocalData_instance:getlist_ip() and self.last_ip == LocalData_instance:getlist_ip()  then
		return
	end
	self:havesenddata()
	-- if msgName ~= "cs_request_heart_beat" then
	-- 	print(msgName)
	-- end
	if msgName == "cs_request_do_action" then
		self.lastredo = true
	end
	
	
	-- print(data.cs_request_login.account)
	if self.socket == nil or not self.socket.isConnected then
		return false
	end
	-- NetPicUtils.saveLog(msgName,{})
	-- local tablejson = {firsttype =3, secondtype = 1,thirdtype = 1,userid = 1,roomnum = 0,type = 0}
	-- local jsonstr = json.encode(tablejson)
	-- print("jsonstr:"..jsonstr)
	-- self.socket:send(jsonstr.."\r\n")
	local pkg = self.packageBuilder:buildPackage(msgName, data, param)
	-- print(pkg)
	local tab = pkg:getPack()
	if msgName ~= "cs_request_heart_beat" then
		release_print(msgName)
	end	
	self.socket:send(pkg:getPack())
end

function SocketConnect:isConnected( )
	if self.closebymyself then
		return false
	end
	if self.socket then
		return self.socket.isConnected
	end
	return false
end

function SocketConnect:closeSocket( )
	self.closebymyself = true
	self:stopallsche()
	if self.socket then
		self.socket:close()
	end
end

SocketConnect_instance = SocketConnect:getInstance()