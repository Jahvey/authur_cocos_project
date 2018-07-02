-------------------------------------------------
--   TODO   玩家详情UI
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local PlayInfoView = class("PlayInfoView",PopboxBaseView)
--- data 为真 查看别个
function PlayInfoView:ctor(data)
	self:initData(data)
	self:initView()
	self:initEvent()
end

function PlayInfoView:initData(data)
	self.data = data
end

function PlayInfoView:initView()
	self.widget = cc.CSLoader:createNode("ui/popbox/playInfoView.csb")
	self:addChild(self.widget)

	self.layer = self.widget:getChildByName("layer")
	WidgetUtils.addClickEvent(self.layer, function( )
		LaypopManger_instance:back()
	end)

	self.mainLayer = self.widget:getChildByName("main")
	-- 头像
	self.headImg = self.mainLayer:getChildByName("icon")
	-- 女性
	-- self.maleIcon = self.mainLayer:getChildByName("maleIcon"):setVisible(false)
	-- -- 男性
	-- self.femaleIcon = self.mainLayer:getChildByName("femaleIcon"):setVisible(false)
	-- 名字
	self.nameLabel = self.mainLayer:getChildByName("name")

	self.money = self.mainLayer:getChildByName("goldbtn"):getChildByName("gold")
	self.ip = self.mainLayer:getChildByName("ip")
	self.IDLabel = self.mainLayer:getChildByName("id")
	-- -- IP
	-- self.IPLabel = self.mainLayer:getChildByName("IPLabel")
	-- ID
	if self.data  and  self.data.playerid ~= LocalData_instance.playerid then
		--ComHelpFuc.getStrWithLengthByJSP(LocalData_instance.nickname)
		self.nameLabel:setString("昵称:"..ComHelpFuc.getStrWithLengthByJSP(self.data.nickname))
		self.IDLabel:setString("ID:"..self.data.playerid)
		self.money:setString("保密")
		self.ip:setString("IP:"..self.data.ip)
		require("app.ui.common.HeadIcon").new(self.headImg,self.data.headimgurl)
	else
		self.nameLabel:setString("昵称:"..ComHelpFuc.getStrWithLengthByJSP(LocalData_instance.nickname))
		self.IDLabel:setString("ID:"..LocalData_instance.playerid)
		self.money:setString(LocalData_instance.gamecoins)
		self.ip:setString("IP:"..LocalData_instance.ip)
		require("app.ui.common.HeadIcon").new(self.headImg,LocalData_instance:getPic())
	end
	--self.ip:setString(LocalData_instance.)


end

function PlayInfoView:initEvent()

end
return PlayInfoView