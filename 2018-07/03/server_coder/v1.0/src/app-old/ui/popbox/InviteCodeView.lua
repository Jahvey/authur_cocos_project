---------------------------------------
-- 邀请码
---------------------------------------
local InviteCodeView = class("InviteCodeView",PopboxBaseView)
function InviteCodeView:ctor(opentype)
	-- self.super.ctor(self)
	self:initData(opentype)
    self:initView()
    self:initEvent()
end
function InviteCodeView:initData(opentype)
	-- 按钮列表
	self.keyBtnList = {}
	self.roomNumList = {}
	self.opentype = opentype
end
function InviteCodeView:initView()
	self.widget = cc.CSLoader:createNode("ui/joinRoom/InviteCodeView.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)
	-- 数字
	self.keypadNode = self.mainLayer:getChildByName("keypadNode")

	self.confirmbtn = self.mainLayer:getChildByName("confirmbtn")
	self.inputtext = self.mainLayer:getChildByName("inputbg"):getChildByName("inputtext"):setString("")
	WidgetUtils.addClickEvent(self.confirmbtn, function( )
		self:confirmBtnCall()
	end)
	self:initKeyPadNode()
end
function InviteCodeView:confirmBtnCall()
	print("确认")
	local code = table.concat(self.roomNumList,"")
	-- print("========code =",code)
	ComHttp.httpPOST(ComHttp.URL.BINDDAGENT,{uid = LocalData_instance:getUid(),binduid = code},function(data)
		if not WidgetUtils:nodeIsExist(self) then
			return
		end
	end)
end
-- 初始化按钮的事件
function InviteCodeView:initKeyPadNode()
	for i=0,11 do
		local str = i
		if i == 10 then
			str = "again"
		elseif i == 11 then
			str = "delete"	
		end
		local btn = self.keypadNode:getChildByName(str)
		btn.str = str

		WidgetUtils.addClickEvent(btn, function( )
			self:setRoomNumValue(btn.str)
		end)
	end
end
-- 设置数值
function InviteCodeView:setRoomNumValue(value)
	if not value then
		print("按钮的 value 为空 ！！！")
		return
	end 
	-- 重输
	if value == "again" then
		self.roomNumList = {}
		self.inputtext:setString(" ")
	-- 删除
	elseif value == "delete" then
		local str = ""
		local cnt = #self.roomNumList
		if cnt >= 0 then
			table.remove(self.roomNumList,cnt)
		end
		str = table.concat(self.roomNumList," ")
		self.inputtext:setString(str)
	else
		if #self.roomNumList < 6 then
			table.insert(self.roomNumList,value)
			local str = table.concat(self.roomNumList," ")
			self.inputtext:setString(str)
			local num = #self.roomNumList
		end	
	end	
end
function InviteCodeView:initEvent()

end

return InviteCodeView