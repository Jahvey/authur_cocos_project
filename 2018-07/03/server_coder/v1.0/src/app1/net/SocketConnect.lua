--
-- SocketConnect.lua
-- 处理SocketTCP的事件
-- 打包并发送数据
-- 解析包数据
-- TODO断线重连等公共逻辑
-- liyanzi
--
local scheduler = require("app.net.scheduler")
local SocketTCP = require "app.net.SocketTCP"

local SocketConnect = class("SocketConnect")

function SocketConnect:ctor( ) 
	self:init()
	self.closebymyself = false
	self.isreconnect = false
	self.lasethost = nil
	self.lasetport = nil
	self.delaytimetab = {}
	self.delaytime = false
	self.iszhixingaction = false
end

function SocketConnect.getInstance()
    if not SocketConnect_instance then
	    SocketConnect_instance = SocketConnect.new()
	end
	return SocketConnect_instance
end

function SocketConnect:init( )
	-- cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

	-- self.parser = require("app/socket/Parser").new()
	-- self.packageBuilder = require("app.socket.PackageBuilder").new()
	-- self.dispatcher =require("app.socket.PackageDispatcher"):getInstance()

	self.parser = require("app/net/Parser").new()
	self.packageBuilder = require("app.net.PackageBuilder").new()
end

function SocketConnect:start( host, port)
	STOPSOCEKT = false
	self.parser:reset()
	if self.heartreturnsche then
		scheduler.unscheduleGlobal(self.heartreturnsche)
		self.heartreturnsche = nil
	end
	if self.sendheartsch then
		scheduler.unscheduleGlobal(self.sendheartsch)
		self.sendheartsch = nil
	end
	self.closebymyself = false
	print(".....host =",host)
	print(".....port =",port)
	if SocketConnect_instance ==self then
		print(" the same")
	else
		print("not same")
	end

	self.delaytimetab = {}
	self.delaytime = false
	self.iszhixingaction = false

	self.lasethost = host or self.lasethost
	self.lasetport = port or self.lasetport
	if self.socket == nil then
		self.socket = SocketTCP.new(self.lasethost, self.lasetport, false)
		self.socket:addEventListener(SocketTCP.EVENT_DATA, handler(self, self.data))
		self.socket:addEventListener(SocketTCP.EVENT_CLOSE, handler(self, self.close))
		self.socket:addEventListener(SocketTCP.EVENT_CLOSED, handler(self, self.closed))
		self.socket:addEventListener(SocketTCP.EVENT_CONNECTED, handler(self, self.connected))
		self.socket:addEventListener(SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.connectFailure))
	end

	self:doConnectSocket()
	self:checknet()
end
function SocketConnect:checknet( )
end
function SocketConnect:doConnectSocket()
	self.socket:connect()
end

function SocketConnect:data( event )
	--print("SocketConnect:data")
	--print(event.data)
	local result = self.parser:readPackage(event.data)
	--printTable(result)

	for i,v in ipairs(result) do
		local output = cjson.decode(v)
		if output then
			--if output.result == 0 then
				--printTable(output)
			--else
				if output.keytype ~= "3;1;3" then
					print(output.keytype)
					printTable(output,"sjp10")
				end
				--ComNoti_instance:dispatchEvent(output.keytype,output)
				if output.keytype == "3;1;3" then
					ComNoti_instance:dispatchEvent(output.keytype,output)
				else
					if output.result == 403 then
						LaypopManger_instance:PopBox("PromptBoxView",1,{tipstr = "房卡不足"})
					end
					table.insert(self.delaytimetab,{k=output.keytype,v=output})
					self:doacton()
				end
			--end
		else
			print("socket json  error")
		end
	end
end

function SocketConnect:doacton()
	if STOPSOCEKT then
		print("return1")
		Notinode_instance.timenode:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
				self:doacton()
			end)))

		return 
	end
	print("ctt1")
	if self.delaytimetab[1] then
		if self.delaytimetab[1].k == "3;3;3;16" then
			STOPSOCEKT = true
		end
		if self.delaytimetab[1].k == "3;3;3;2" then
			STOPSOCEKT = true
		end
		ComNoti_instance:dispatchEvent(self.delaytimetab[1].k, self.delaytimetab[1].v)
		table.remove(self.delaytimetab,1)
		self:doacton()
	end
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
	self.isreconnect = true
	self:start()
end
function SocketConnect:heartreturn()
	if self.sendtime then
		Notinode_instance:setnet(os.time() - self.sendtime)
	end
	if self.heartreturnsche then
		scheduler.unscheduleGlobal(self.heartreturnsche)
		self.heartreturnsche = nil
	end
	local function returncallback()
		if self.sendheartsch then
			scheduler.unscheduleGlobal(self.sendheartsch)
			self.sendheartsch = nil
		end
		self:sendHeart()

	end
	if self.sendheartsch then
		scheduler.unscheduleGlobal(self.sendheartsch)
		self.sendheartsch = nil
	end
	self.sendheartsch = scheduler.scheduleGlobal(returncallback, 8) 
end
function SocketConnect:sendHeart()
	self.sendtime = os.time()

	Socketapi.sendheart()
	local index = 0
	local function returncallback()
		-- body
		index = index + 0.1
		Notinode_instance:setnet(index)
		if index >= 5 then
			scheduler.unscheduleGlobal(self.heartreturnsche)
			self.socket:close()
		end
	end
	self.heartreturnsche = scheduler.scheduleGlobal(returncallback, 0.1) 
end
function SocketConnect:connected( event )
	print("SocketConnect:connected")
	Notinode_instance:showLoading(false)
	
	if self.lastmsg and self.lastname then
		self:send(self.lastname,self.lastmsg)
	end
	self:sendHeart()
	
end

function SocketConnect:connectFailure( event )
	print("SocketConnect:connectFailure")
end

function SocketConnect:send(msgName, data, param)


	-- print(data.cs_request_login.acc_type)
	-- print(data.cs_request_login.account)
	if self.socket == nil or not self.socket.isConnected then
		return false
	end
	local jsonstr = json.encode(data)
	
	if msgName ~="3;1;3" then
		print(msgName)
		print("jsonstr:"..jsonstr..CryTo:Md5(jsonstr.."zgameMd5"))
	end
	self.socket:send(jsonstr..CryTo:Md5(jsonstr.."zgameMd5").."\r\n")

	-- local pkg = self.packageBuilder:buildPackage(msgName, data, param)
	-- -- printTable(pkg)
	-- local tab = pkg:getPack()
	-- printTable(tab)
	-- self.socket:send(pkg:getPack())
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
	self.socket:close()

end

SocketConnect_instance = SocketConnect:getInstance()