-------------------------------------------------
--   TODO   通知中心
--   @author sjp
--   Create Date 2016.10.24
-------------------------------------------------
local scheduler = require "app.net.scheduler"
local ComNoti = class("ComNoti")

function ComNoti:ctor( ) 
	self:init()
end

function ComNoti:getInstance()
    if not ComNoti_instance then
	    ComNoti_instance = self.new()
	end
	return ComNoti_instance
end

function ComNoti:ctor( ) 
	--通知注册中心
	self.comnoti = {}
	self.eventtab = {}
	self.scheget = scheduler.scheduleGlobal(function()
			self:getEvent()
		end, 0)
end
function ComNoti:getEvent()
	if #self.eventtab > 0 then
		local eventName = self.eventtab[1].eventName
		local data = self.eventtab[1].data
		table.remove(self.eventtab,1)
		assert(type(eventName) == "string" and eventName ~= "",
        "ComNoti:dispatchEvent() - invalid eventName")
	
		if eventName ~= "cs_response_heart_beat" and eventName ~= "sendheartforcheck" then
			print("comoti:"..eventName)
		end
		local handle = self.comnoti[eventName]
		if handle  then
			for k,v in pairs(handle) do
				if v and tolua.cast(v.node,"cc.Node") then
					v.fuc(data)
				end
			end
		end
	end
end
function ComNoti:dispatchEvent(eventName,data)
	table.insert(self.eventtab,{eventName = eventName , data = data})
	-- assert(type(eventName) == "string" and eventName ~= "",
 --        "ComNoti:dispatchEvent() - invalid eventName")
	
	-- if eventName ~= "cs_response_heart_beat" and eventName ~= "sendheartforcheck" then
	-- 	print("comoti:"..eventName)
	-- end
	-- local handle = self.comnoti[eventName]
	-- if handle  then
	-- 	for k,v in pairs(handle) do
	-- 		if v and tolua.cast(v.node,"cc.Node") then
	-- 			v.fuc(data)
	-- 		end
	-- 	end
	-- end
end
function ComNoti:cleanupEvent()
	self.eventtab = {}
end
function ComNoti:addEventListener(eventName,node,fuc)
	assert(type(eventName) == "string" and eventName ~= "",
        "ComNoti:addEventListener() - invalid eventName")

	assert(tolua.cast(node,"cc.Node"),
        "ComNoti:addEventListener() - invalid node")
	if self.comnoti[eventName] == nil then
		self.comnoti[eventName] = {}
	end
	self.comnoti[eventName][tostring(node)]  = {node = node ,fuc = handler(node, fuc),eventName = eventName}


	local function eventhandler(tag)
        if "cleanup" == tag then
            self.comnoti[eventName][tostring(node)] = nil
        end
    end
    node:registerScriptHandler(eventhandler)

end
ComNoti_instance = ComNoti:getInstance()