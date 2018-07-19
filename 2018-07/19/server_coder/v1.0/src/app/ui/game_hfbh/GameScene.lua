-- 长牌场景
local GameScene = class("GameScene", require "app.ui.game.GameScene")


function GameScene:initDataBySelf()
    self.voicelist = { }
    -- 添加一个房间开始的等待动画
    self.actionList = { { act_type = ACTIONTYPEBYMYSELF.CREATE_CARD } }

    self.allResultData = nil
    self.chuPaiIndex = -1
    self.display_anpai = false

    -- self:setRestTileNum(0)

    self.lastAct = nil

    self.myDedugList = {}


    table.insert(self.myDedugList,"tableId:"..self:getTableID())
    table.insert(self.myDedugList,"round:"..self:getNowRound()+1)
    table.insert(self.myDedugList,"useId:"..LocalData_instance:getUid())
end



function GameScene:NotifyGameStart(data)
    print(".......................牌局游戏开始～")
    printTable(data, "xp")

    self:setNowRound(data.round)
   
    --比牌，
    if  data.round == 1 then
    	self:setDealerIndex(-1)
    	self:setRestTileNum(200)
    	local oldData = clone(data)
	  	for k,v in pairs(data.sdr_seats) do
	  		v.hand_cards = {}
	  	end

 		self:setSeatsInfo(data.sdr_seats)
    	self:setGameBegin()
    	self.isRunning = false
    	table.insert(self.actionList, 1,{ act_type = ACTIONTYPEBYMYSELF.BIPAI,data = oldData} ) 
    else

	    self:setDealerIndex(data.dealer)
	    
	    self:setRestTileNum(data.left_card_num)
	    self:setNowRound(data.round)

	    self:setJiangCard(data.jiang_card)
	    self.UILayer:setJiangCard(self.table_info.jiang_card)
	    for i, v in ipairs(data.sdr_seats) do
	        if  v.index == self:getMyIndex() then
	            self.mytable:setBanedCardsList(v.baned_cards or {}) --设置我不能打的牌
	        end
	    end
	    self:setSeatsInfo(data.sdr_seats)
	    self:setGameBegin()
    end
end 


function GameScene:biPaiAction(data)

	print(".........biPaiAction")
	printTable(data,"xp")

	local function biPaiEnd()    
		self:setRestTileNum(data.left_card_num)
	    self:setNowRound(data.round)

	    self:setJiangCard(data.jiang_card)
	    self.UILayer:setJiangCard(self.table_info.jiang_card)
	    for i, v in ipairs(data.sdr_seats) do
	        if  v.index == self:getMyIndex() then
	            self.mytable:setBanedCardsList(v.baned_cards or {}) --设置我不能打的牌
	        end
	    end
	    self:setSeatsInfo(data.sdr_seats)
	    self:setGameBegin()

        if self.biCardError == true then
            local tableSeat = self:getSeatsInfo()
            if  type(tableSeat) == "table" then 
                infoStr = self:printTable(tableSeat)
            end
            table.insert(self.myDedugList,"GameTable :"..infoStr)
            self:uploadDebugList()

            self.biCardError = false
        end

	    self:deleteAction("比庄动画结束！")
	end

	self:setDealerIndex(data.dealer)
	
	for k,v in ipairs(data.sdr_seats) do
		local value = v.hand_cards[1]
		self.tablelist[v.index + 1]:biPaiAction(value,biPaiEnd)
	end
	

end


function GameScene:priorityAction(data)
	 if data.act_type == poker_common_pb.EN_SDR_ACTION_WEI then  --自己翻出来的碰为昭
        print(".........偎牌动画")
         self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)

        local list = ComHelpFuc.getDeleteDestList(data.col_info,data.dest_card)
        if data.col_info.is_waichi == true then
            list = {}
        end
        print("..............EN_SDR_ACTION_WEI")
        printTable(list)

        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            self:deleteHandTile(list,data.seat_index)
        end

        self.tablelist[data.seat_index + 1]:weiPaiAction(data)
 		return true
      elseif data.act_type == poker_common_pb.EN_SDR_ACTION_UPDATE then  --更新out_col,百胡的update只是用于补口，就需要删除补的牌
        print(".........更新out_col")
        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            self:deleteHandTile({data.dest_card},data.seat_index)
        end
        -- self.tablelist[data.seat_index+1]:refreshShowTile()
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function() 
            self:deleteAction("更新结束")
        end)))
        return true
    end


    return false
end



return GameScene