-------------------------------------------------
--   TODO   切换视角
--   @author xp
--   Create Date 2018.5.8
-------------------------------------------------
local SwitchingView = class("SwitchingView",PopboxBaseView)
-- 倒计时
function SwitchingView:ctor(_gamescene)
	self.gamescene = _gamescene
	self:initData()
	self:initView()
end

function SwitchingView:initData()

	self.selectUid =  LocalData_instance:getVisualAngleUID()

end

function SwitchingView:initView()
	self.widget = cc.CSLoader:createNode("ui/switchingview/switchingview.csb")
	self:addChild(self.widget)	

	self.mainLayer = self.widget:getChildByName("main")
	self.closebtn = self.mainLayer:getChildByName("closebtn")
	WidgetUtils.addClickEvent(self.closebtn, function( )
		LaypopManger_instance:back()
	end)


	self.refuseBtn = self.mainLayer:getChildByName("refuseBtn")
	WidgetUtils.addClickEvent(self.refuseBtn, function( )
		self:refuseCall()
	end)

	if self.gamescene:getTableConf().seat_num == 3 then
		self.mainLayer:getChildByName("item_4"):setVisible(false)

		self.mainLayer:getChildByName("item_1"):setPositionX(-200)
		self.mainLayer:getChildByName("item_2"):setPositionX(0)
		self.mainLayer:getChildByName("item_3"):setPositionX(200)

	elseif self.gamescene:getTableConf().seat_num == 2 then
		self.mainLayer:getChildByName("item_4"):setVisible(false)
		self.mainLayer:getChildByName("item_3"):setVisible(false)

		self.mainLayer:getChildByName("item_1"):setPositionX(-120)
		self.mainLayer:getChildByName("item_2"):setPositionX(120)
	end

	self:refreshView()
end
function SwitchingView:refreshView()
	-- 
	local index = 0
	for i,v in pairs(self.gamescene:getSeatsInfo()) do
		index = index + 1
		local item = self.mainLayer:getChildByName("item_"..index)
		item.uid = v.user.uid

		item:getChildByName("name"):setString(ComHelpFuc.getCharacterCountInUTF8String(v.user.nick,9))

		local head = item:getChildByName("headicon")

	 	local headicon = require("app.ui.common.HeadIcon").new(head, v.user.role_picture_url,76).headicon
        -- head.headicon = headicon
        -- head:setPosition(cc.p(0, 2))

        if  item.uid == self.selectUid then
        	item:getChildByName("yes"):setVisible(true)
        else
        	item:getChildByName("yes"):setVisible(false)
        end


        WidgetUtils.addClickEvent(headicon, function()
             self:clickHeadIcon(item.uid)
        end )

    end
end
function SwitchingView:clickHeadIcon(_uid)

	-- 
	local index = 0
	for i,v in pairs(self.gamescene:getSeatsInfo()) do
		index = index + 1
		local item = self.mainLayer:getChildByName("item_"..index)
	    if  item.uid == _uid then
        	item:getChildByName("yes"):setVisible(true)
        else
        	item:getChildByName("yes"):setVisible(false)
        end
	end

	self.selectUid = _uid
end



function SwitchingView:refuseCall()
	if  self.selectUid ==  LocalData_instance:getVisualAngleUID() then
		self:closeUI()
	else
		LocalData_instance:setVisualAngleUID(self.selectUid)
		self.gamescene:switchingReplay()
	end
end

function SwitchingView:closeUI()
	LaypopManger_instance:backByName("SwitchingView")
end

return SwitchingView