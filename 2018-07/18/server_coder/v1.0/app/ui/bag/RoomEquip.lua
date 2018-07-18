local RoomEquip = class("RoomEquip")

-- 重写GameScene(class)
function RoomEquip.overideGameScene(GameScene)
	local initTable_super = GameScene.initTable
	function GameScene:initTable()
		initTable_super(self)

		for i,v in ipairs(self.tablelist) do
			RoomEquip.overideBaseTable(v)
		end
	end

	return GameScene
end

-- 重写BaseTable(Instance)
function RoomEquip.overideBaseTable(BaseTable)
	local refreshSeat_super = BaseTable.refreshSeat
	function BaseTable:refreshSeat(info, isStart)
		refreshSeat_super(self, info, isStart)

		if not info then
			info = self.gamescene:getSeatInfoByIdx(self:getTableIndex())
		end

		local equips = {}

		if info.state == poker_common_pb.EN_SEAT_STATE_NO_PLAYER or info.user == nil or info.user == { } then

		else
			if info.user.items_info and info.user.items_info ~= "" then
				equips = cjson.decode(info.user.items_info)
				print("===========装备！！！！")
				printTable(equips)
			end
			local head = self.icon:getChildByName("headicon")
			if not head.headicon or not WidgetUtils:nodeIsExist(head.headicon) then
				head.headicon = head:getChildByTag("65545").headicon
			end
			local scale = head.headicon:getScale()
			local width = head.headicon:getContentSize().width
			local headframe = RoomEquip.getHeadFrame(equips)
			local headnew = require("app.ui.common.HeadIcon").new(head, info.user.role_picture_url,scale*width,headframe)
			local headicon = headnew.headicon
	        head.headicon = headicon

	        local originframe = self.icon:getChildByName("headbg")
	        if originframe and originframe:getContentSize().height < 150 then
	        	if headframe then
	        		originframe:setVisible(false)
	        	else
	        		originframe:setVisible(true)
	        	end
	        end

	        if self.gamescene:getSeatInfoByIdx(self.tableidx).state ~= 99 then
	            headicon:setTouchEnabled(true)
	            WidgetUtils.addClickEvent(headicon, function()
	                print("-----1111")
	                self:clickHeadIcon(info.user)
	            end )
	        end
		end
		
	end

	return BaseTable
end

function RoomEquip.getHeadFrame(equips)
	for i,id in ipairs(equips) do
		local data = ItemConf:getItemData(id)

		if data and data.type == 201 then
			return data.img
		end
	end
	return nil
end

return RoomEquip