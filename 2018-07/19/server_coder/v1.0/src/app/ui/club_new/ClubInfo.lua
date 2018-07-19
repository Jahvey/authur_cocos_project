----------------------------
-- 
----------------------------
local ClubInfo = class("ClubInfo",PopboxBaseView)

function ClubInfo:ctor(_parent)
	self.parent = _parent
	self:initView()
end

function ClubInfo:initView()
	local widget = cc.CSLoader:createNode("ui/club/club_main/Club_info.csb")
	widget:addTo(self)

	self.mainLayer = widget:getChildByName("main")

	self.jieshaotitle1 = self.mainLayer:getChildByName("my"):getChildByName("text1")
	self.jieshaotitle2 = self.mainLayer:getChildByName("my"):getChildByName("text2")
	self.jieshaotitle3 = self.mainLayer:getChildByName("my"):getChildByName("text3")
	self.jieshaotitle4 = self.mainLayer:getChildByName("my"):getChildByName("text4")
	self.jieshaotitle5 = self.mainLayer:getChildByName("my"):getChildByName("text5")
	self.jieshaotitle6 = self.mainLayer:getChildByName("my"):getChildByName("text6")

	self.descstr = self.mainLayer:getChildByName("my"):getChildByName("info")

	self.addbtn =  self.mainLayer:getChildByName("my"):getChildByName("addbtn")
	WidgetUtils.addClickEvent(self.addbtn, function( )
		
		LaypopManger_instance:PopBox("AddfangclueView",self.data.tbid,self.data.chips)
	end)
	
	self.infobtn =  self.mainLayer:getChildByName("my"):getChildByName("infobtn")
	WidgetUtils.addClickEvent(self.infobtn, function( )
		LaypopManger_instance:PopBox("RetinfoView",self.data.tbid,self.data.desc,self.data.tbname,self.data.pay_type)
	end)

	local sharebtn = self.mainLayer:getChildByName("my"):getChildByName("sharebtn")
	WidgetUtils.addClickEvent(sharebtn, function( )
		
		CommonUtils.shareclub(self.data.tbid,self.data.tbname,self.data.desc)
	end)

end

function ClubInfo:updataView(data)
	self.data = data

	self.data.tbname = CommonUtils.checkchange(self.data.tbname)
	self.data.desc = CommonUtils.checkchange(self.data.desc)

	self.jieshaotitle1:setString(self.data.tbid)
	self.jieshaotitle2:setString(self.data.tbname)
	self.jieshaotitle3:setString(self.data.master_name)
	self.jieshaotitle4:setString(self.data.user_num.."/"..self.data.max_user_num)
	self.jieshaotitle5:setString(self.data.chips)

	if self.data.pay_type == poker_common_pb.EN_TeaBar_Pay_Type_Master  then 
		self.jieshaotitle6:setString("亲友圈主人支付")
	elseif self.data.pay_type == poker_common_pb.EN_TeaBar_Pay_Type_AA then 
		self.jieshaotitle6:setString("亲友圈均摊支付") 
	end
	self.descstr:setString(self.data.desc)

	if self.data.master_uid == LocalData_instance.uid then
		self.infobtn:setVisible(true)
		self.addbtn:setVisible(true)
		self.jieshaotitle5:setVisible(true)
		self.mainLayer:getChildByName("my"):getChildByName("title1_2"):setVisible(true)
	else
		--隐藏亲友圈房卡那一列，和支付方式的
		self.infobtn:setVisible(false)
		self.addbtn:setVisible(false)
		self.jieshaotitle5:setVisible(false)
		self.mainLayer:getChildByName("my"):getChildByName("title1_2"):setVisible(false)
	end

end
function ClubInfo:updatechips(chips)
	self.data.chips = chips
	self.jieshaotitle5:setString(self.data.chips)
end




return ClubInfo
