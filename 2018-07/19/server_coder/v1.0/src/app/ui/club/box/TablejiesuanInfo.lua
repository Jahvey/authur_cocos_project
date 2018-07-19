local TablejiesuanInfo = class("TablejiesuanInfo",PopboxBaseView)

function TablejiesuanInfo:ctor(data)
	self.data = data
	self:initView()
	
end
function TablejiesuanInfo:initView()
	local widget = cc.CSLoader:createNode("ui/club/smallbox/Cluegameresultinfo.csb")
	self:addChild(widget)
	self.widget = widget
	self.mainLayer = widget:getChildByName("main")

	self.closeBtn = self.mainLayer:getChildByName("closeBtn")
	WidgetUtils.addClickEvent(self.closeBtn, function( )
		
		LaypopManger_instance:back()
	end)
	printTable(self.data)
	local tableidstr = self.mainLayer:getChildByName("tableid")
	tableidstr:setString("房间ID:"..self.data.detail.tid)
	local tableidconf = self.mainLayer:getChildByName("tableconf")
	tableidconf:setString("房间规则:"..GT_INSTANCE:getTableDes(self.data.detail.conf, 2))
	for i=1,8 do
		self.mainLayer:getChildByName("node"..i):setVisible(false)
	end
	for i,v in ipairs(self.data.detail.statistics.seat_statistics_list) do
		local node = self.mainLayer:getChildByName("node"..i)
		node:setVisible(true)
		local icon = node:getChildByName("icon")
		require("app.ui.common.HeadIcon_Club").new(icon,v.pic_url)
		local name = node:getChildByName("name")
		name:setString(ComHelpFuc.getStrWithLength(v.nick))
		node:getChildByName("id"):setString("ID:"..v.uid)
		local score = node:getChildByName("score")
		if v.final > 0 then
			score:setColor(cc.c3b(0x33, 0x80, 0x25))
			score:setString("+"..v.final)
		else
			score:setColor(cc.c3b(0xde, 0x42, 0x23))
			score:setString(v.final)
		end
	end

	--Socketapi.requestmsgclube(self.tid)
end

return TablejiesuanInfo