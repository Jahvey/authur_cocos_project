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
    printTable(data, "xp69")

    self:setNowRound(data.round)
   
    --比牌，
    if  data.round == 1 then
    	self:setDealerIndex(-1)
    	self:setOldDealerIndex(-1)
    	
    	local tileNum = data.left_card_num - 3
    	local oldData = clone(data)

	  	for k,v in pairs(data.sdr_seats) do
	  		tileNum = tileNum + #v.hand_cards
	  		v.hand_cards = {}
	  	end
	  	self:setRestTileNum(tileNum)

 		self:setSeatsInfo(data.sdr_seats)
    	self:setGameBegin()
    	self.isRunning = false
    	table.insert(self.actionList, 1,{ act_type = ACTIONTYPEBYMYSELF.BIPAI,data = oldData} ) 
    	local info = self.actionList[1]
        if info then
            self:doAction(info, "biPaiAction")
        end
    else
	    self:setDealerIndex(data.dealer)
	    self:setOldDealerIndex(-1)
	    self:setRestTileNum(data.left_card_num)
	    self:setNowRound(data.round)

	    self:setJiangCard(data.jiang_card)
	    self.UILayer:setJiangCard(self.table_info.jiang_card)

	    self:setJokerCard(data.joker_card)
	    self.UILayer:setJokerCard(self.table_info.joker_card)


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

	    self:setJokerCard(data.joker_card)
	    self.UILayer:setJokerCard(self.table_info.joker_card)

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


return GameScene