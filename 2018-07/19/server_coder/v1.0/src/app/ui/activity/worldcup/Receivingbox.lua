local Receivingbox = class("Receivingbox",require "app.module.basemodule.BasePopBox")

function Receivingbox:initData(_itemname)
	self.isSend = false
	self.itemName = _itemname
	self.data = nil
end

function Receivingbox:onEnter()
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.GETUSERINFO,{uid = LocalData_instance.uid},function(msg)
		print("...........Receivingbox:onEnter")
		printTable(msg,"xp65")
		if not WidgetUtils:nodeIsExist(self) then
			return
		end

		self:hideSmallLoading()

		self.data = msg
		self.name_field:setString(self.data.name)
		self.call_field:setString(self.data.phone)
		self.address_field:setString(self.data.address)
	end)
end

function Receivingbox:onExit()

end

function Receivingbox:initView()
	self.widget = cc.CSLoader:createNode("ui/worldcup/box/receivingAddress.csb")
	self:addChild(self.widget)

	self.mainLayer = self.widget:getChildByName("main")
	self.closeBtn  = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		LaypopManger_instance:back()
	end)

	self.mBtn  = self.mainLayer:getChildByName("btn1")
	WidgetUtils.addClickEvent(self.mBtn, function( )
		self:setUserInfo()
	end)

	if self.itemName ~= nil then
		self.mainLayer:getChildByName("itemname"):setString(self.itemName)
	else
		self.mainLayer:getChildByName("Text_1"):setVisible(false)
		self.mainLayer:getChildByName("itemname"):setVisible(false)
	end

	self.name_field = self.mainLayer:getChildByName("name_TextField") 
	self.call_field = self.mainLayer:getChildByName("call_TextField") 
	self.address_field = self.mainLayer:getChildByName("address_TextField") 

	local tip = self.mainLayer:getChildByName("tip")
	tip:setString("请联系客服jrhp007，领取奖励。")
end
function Receivingbox:setUserInfo()

	local _name = self.name_field:getString()
	local _call = self.call_field:getString()
	local _address = self.address_field:getString()

	if _name == "" or _call == "" or _address == "" then
		return
	end

	if self.isSend == true then
		return 
	end

	if self.data ~= nil then
		if _name == self.data.name  and _call == self.data.phone  and _address == self.data.address  then
			LaypopManger_instance:back()
			return 
		end
	end

	self.isSend = true 
	self:showSmallLoading()
	ComHttp.httpPOST(ComHttp.URL.SETUSERINFO,{uid = LocalData_instance.uid,name = _name, phone = _call, address = _address},function(msg)
		print("...........Receivingbox:setUserInfo")
		self.isSend = false
		printTable(msg,"xp65")
		if not WidgetUtils:nodeIsExist(self) then
			return
		end
		self:hideSmallLoading()
		LaypopManger_instance:back()
	end)

end


return Receivingbox