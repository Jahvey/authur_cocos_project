local Check = class("Check")

require "mime"

function Check:ctor()
	self.data = self:getData()
	self.idx = 1
	-- self:sendRequest()
	self.cdnlist = CM_INSTANCE:getHTTPCDNLOCALDFAULIST()
end

function Check:getData()

	local default = CM_INSTANCE:getHTTPLOCALDFAULIST()
	
	local defaultstr = mime.b64(cjson.encode(default))
	--cc.UserDefault:getInstance():setStringForKey("ConfigData",defaultstr)
	local str = cc.UserDefault:getInstance():getStringForKey("ConfigData",defaultstr)
	str = mime.unb64(str)

	local tab = cjson.decode(str)

	return tab 
end

function Check:setData()
	printTable(self.data,"sjp3")
	local str = cjson.encode(self.data)
	str = mime.b64(str)
	cc.UserDefault:getInstance():setStringForKey("ConfigData",str)
end

function Check:reformData(newdata)
	if newdata and type(newdata) == "table" then
		for i,v in ipairs(newdata) do
			self.data[i] = v
		end
	end
	self:setData()
end

function Check:sendRequest(param1,param2)
	self.isrequest = true
	print("========正在请求"..param1)
	local xhr = cc.XMLHttpRequest:new()
	xhr.isdone = false
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local addres = "http://"..param1.."/aliyun/index.php/Api/getlist"
	--local addres = "http://cpdssapi.arthur-tech.com/aliyun/index.php/Api/getlist"
	release_print(addres)
	xhr:open("POST", addres)
	local function responsecallback()
		if xhr.isdone then
			return
		end

		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local response = mime.unb64(xhr.response)
			local output = cjson.decode(response)
			
			if output and output.serverstatus == 1 then
				printTable(output,"sjp111")
				self:reformData(output.webip)
				SocketConnect_instance.current_ip = output.ip
				print("========链接ip"..param1.."成功")
				self.idx = 1
				xhr.isdone = true
			else
				xhr.isdone = true
				self:failEvent(param1)
			end
		else
			xhr.isdone = true
			self:failEvent(param1)
			-- self:failEvent(param1)
		end
	end 

	if Notinode_instance.checknet then
		Notinode_instance.checknet:stopAllActions()
		Notinode_instance.checknet:runAction(cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(function()
				if not xhr.isdone then
					xhr.isdone = true
					self:failEvent(param1)
				end
			end)))
	end

	local sendstr = "num="..param2

	xhr:registerScriptHandler(responsecallback)
	xhr:send(sendstr)

	return xhr
end

function Check:sendRequest2(call)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	local addres = "https://www.baidu.com"
	release_print(addres)
	xhr:open("GET", addres)
	local function responsecallback()
		print("responsecallback")
		print(xhr.status)
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			print("链接百度成功")
			call()
		else
			print("链接百度失败")
			--SocketConnect_instance:closeSocket()
		end
	end

	xhr:registerScriptHandler(responsecallback)
	xhr:send()

	return xhr
end

function Check:failEvent(ip)
	self.idx = math.min(self.idx+1,#self.data+#self.cdnlist+1)
	local event = {
		[1] = function ()
			self:sendRequest(self.data[1],0)
		end,
		[2] = function ()
			self:sendRequest2(function ()
				self:sendRequest(self.cdnlist[1],1)
			end)
		end,
	}

	for i=2,#self.data do
		table.insert(event,function ()
			self:sendRequest(self.data[i],i-1)
		end)
	end
	if self.cdnlist[2] then
		table.insert(event,function ()
			self:sendRequest(self.cdnlist[2],#self.data)
		end)
	end

	print("链接地址"..ip.."失败")

	if event[self.idx] then
		event[self.idx]()
		print("=============eventid"..self.idx)
	else
		print("所有链接失效，停止请求http")
		--SocketConnect_instance:closeSocket()
	end

end

return Check