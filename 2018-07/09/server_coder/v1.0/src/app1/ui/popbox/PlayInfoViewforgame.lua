-------------------------------------------------
--   TODO   玩家详情UI
--   @author yc
--   Create Date 2016.10.26
-------------------------------------------------
local PlayInfoView = class("PlayInfoView",PopboxBaseView)
--- data 为真 查看别个
function PlayInfoView:ctor(data,fromindex,toindex)
	self.fromindex = fromindex
	self.toindex = toindex
	self:initData(data)
	self:initView()
	self:initEvent()
end

function PlayInfoView:initData(data)
	self.data = data
end

function PlayInfoView:initView()
	self.widget = cc.CSLoader:createNode("ui/popbox/playInfoViewforgame.csb")
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
		--ComHelpFuc.getStrWithLengthByJSP(LocalData_instance.nickname)
		self.nameLabel:setString("昵称:"..ComHelpFuc.getStrWithLengthByJSP(self.data.nickname))
		self.IDLabel:setString("ID:"..self.data.playerid)
		self.money:setString("保密")
		self.ip:setString("IP:"..self.data.ip)
		require("app.ui.common.HeadIcon").new(self.headImg,self.data.headimgurl)
	if self.data.playerid ~= LocalData_instance.playerid then
		for i=1,4 do
			local btn = self.mainLayer:getChildByName("btn"..i)
			WidgetUtils.addClickEvent(btn, function( )
				local tableinfo = {}
				tableinfo.type = 5
				tableinfo.id = i
				tableinfo.begin1 = self.fromindex 
				tableinfo.end1 = self.toindex
				local jsonstr = json.encode(tableinfo)
				Socketapi.sendchat(jsonstr)
				LaypopManger_instance:back()
			end)
		end

	else
		for i=1,4 do
			local btn = self.mainLayer:getChildByName("btn"..i)
			btn:setColor(cc.c3b(0x99,0x96,0x96))
		end
	end
	--self.ip:setString(LocalData_instance.)


end

function PlayInfoView:initEvent()

end
return PlayInfoView