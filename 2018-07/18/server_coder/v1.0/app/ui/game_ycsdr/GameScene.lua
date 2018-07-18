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
    self.localnotbegininfo = self:getSeatsInfo()
    for i,v in ipairs(self.localnotbegininfo) do
        v.state = 3
    end
    print(".......................牌局游戏开始～NotifyGameStart")
    printTable(data, "xp")

    self:setNowRound(data.round)
    local oldData = clone(data)
    for k,v in pairs(data.sdr_seats) do
        v.hand_cards = {}
        --if self:getTableConf().has_piao then
            v.ding_zhang_card = nil
        --end
    end
    self.localdingzhuang_sdr = oldData
    self.localdata_sdr = clone(oldData)
    for i,v in ipairs(self.localdata_sdr) do
        v.ding_zhang_card = nil
    end
    
    --比牌，
    if  data.round == 1  then
    	self:setDealerIndex(-1)
    	self:setRestTileNum(200)
   --  	local oldData = clone(data)
	  -- 	for k,v in pairs(data.sdr_seats) do
	  -- 		v.hand_cards = {}
	  -- 	end

 		self:setSeatsInfo(self.localnotbegininfo)
    	self:setGameBegin()
    	self.isRunning = false
        if not self:getTableConf().has_piao then
            
            table.insert(self.actionList, 1,{ act_type = ACTIONTYPEBYMYSELF.DINGZHANG} ) 
        end
    	table.insert(self.actionList, 1,{ act_type = ACTIONTYPEBYMYSELF.BIPAI,data = data} ) 
        
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
        if not self:getTableConf().has_piao then
	       self:setSeatsInfo(self.localdata_sdr.sdr_seats)
        else
            self:setSeatsInfo(data.sdr_seats)
        end
	    self:setGameBegin()

        if not self:getTableConf().has_piao then
            table.insert(self.actionList, 1,{ act_type = ACTIONTYPEBYMYSELF.DINGZHANG} ) 
        end
        
    end
end 

function GameScene:dingPaiAction( data )
    local function dingPaiEnd()
        if not self:getTableConf().has_piao then
            self:setSeatsInfo(self.localdata_sdr.sdr_seats)
            self.mytable:refreshSeat()
        end

        self:deleteAction("更新结束")
    end
    for k,v in ipairs(self:getSeatsInfo()) do
        local value = v.ding_zhang_card
        self.tablelist[v.index + 1]:dingPaiAction(value,dingPaiEnd)
    end
end
function GameScene:biPaiAction(data)

	print(".........biPaiAction")
	printTable(data,"xp")
    --self.localdata_sdr =data
	local function biPaiEnd()

        if not self:getTableConf().has_piao then
            self:setSeatsInfo(self.localdata_sdr.sdr_seats)
        else
           self:setSeatsInfo(data.sdr_seats)
        end

        self:getMyIndex()    
        self:refreshplayerpos()
		self:setRestTileNum(data.left_card_num)
	    self:setNowRound(data.round)
        self:getMyIndex()
	    self:setJiangCard(data.jiang_card)
	    self.UILayer:setJiangCard(self.table_info.jiang_card)
	    for i, v in ipairs(data.sdr_seats) do
	        if  v.index == self:getMyIndex() then
                print("set not play")
                printTable(v, "sjp3")
	            self.mytable:setBanedCardsList(v.baned_cards or {}) --设置我不能打的牌

	        end
	    end
       
	    self:setGameBegin()


	    self:deleteAction("比庄动画结束！")
	end

	self:setDealerIndex(data.dealer)
	
	for k,v in ipairs(data.sdr_seats) do
		
        if v.index == data.dealer then
            self.dingzhuanguid =v.user.uid
        end
        for i1,v1 in ipairs(self.localnotbegininfo) do
            if v1.user.uid == v.user.uid then
                v1.ding_zhuang_card = v.ding_zhuang_card
            end
        end
		
	end
    print("----------------1")
    printTable(self.localnotbegininfo,"sjp3")
    print("zhuang:"..self.dingzhuanguid)
    for i,v in ipairs(self.localnotbegininfo) do
        local value = v.ding_zhuang_card
        if v.user.uid == self.dingzhuanguid then
            self.tablelist[v.index + 1]:biPaiAction(value,biPaiEnd,true)
        else
            self.tablelist[v.index + 1]:biPaiAction(value,biPaiEnd)
        end
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
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_PIAO then  
        self:notifyPiao( data )
        self:setSeatsInfo(self.localdingzhuang_sdr.sdr_seats)
        self:setGameBegin()
        for i,v in ipairs(self.tablelist) do
           v.icon:getChildByName("dingzhang"):setVisible(false)
        end
    elseif data.act_type == ACTIONTYPEBYMYSELF.DINGZHANG then
        print("dingzhuang")
        for i,v in ipairs(self.tablelist) do
           v.icon:getChildByName("dingzhang"):setVisible(false)
        end

        self.mytable:refreshHandTile()
        self:dingPaiAction(data)
        -- self.icon:getChildByName("dingzhang")
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_ZHAO_2 then --4 杠1
        print(".........招牌动画")
        self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            local list = ComHelpFuc.getDeleteDestList(data.col_info,data.dest_card)
            -- if self:getTableConf().ttype == HPGAMETYPE.HFBH then
            --     if data.col_info.is_waichi == true then
            --         list = {}
            --     end
            -- end
            self:deleteHandTile(list,data.seat_index)
        end

        self.tablelist[data.seat_index + 1]:zhaoPaiAction2(data)
    end


    return false
end
function GameScene:refreshplayerpos( )
    -- for i,v in ipairs(self.tablelist) do
    --     print(i)
    --    v:removeFromParent()
    -- end
    local tableBase = require(self.path .. ".GameTable")
    local gameAction = require(self.path .. ".ActionView")

    local bottomtable = require("app.ui.game.base.TableBottom").create(tableBase, gameAction).new(self.layout:getChildByName("bottomnode"), self)
    local toptable = require("app.ui.game.base.TableTop").create(tableBase).new(self.layout:getChildByName("topnode"), self)
    local lefttable = require("app.ui.game.base.TableLeft").create(tableBase).new(self.layout:getChildByName("leftnode"), self)
    local righttable = require("app.ui.game.base.TableRight").create(tableBase).new(self.layout:getChildByName("rightnode"), self)

    -- 初始化策略
    local maps = {
        [2] =
        {
            [0] = { bottomtable, toptable },
            [1] = { toptable, bottomtable },
        },
        [3] =
        {
            [0] = { bottomtable, righttable, lefttable },
            [1] = { lefttable, bottomtable, righttable },
            [2] = { righttable, lefttable, bottomtable },
        },
        [4] =
        {
            [0] = { bottomtable, righttable, toptable, lefttable },
            [1] = { lefttable, bottomtable, righttable, toptable },
            [2] = { toptable, lefttable, bottomtable, righttable },
            [3] = { righttable, toptable, lefttable, bottomtable },
        },
    }

    self.tablelist = maps[self:getTableConf().seat_num][self:getMyIndex()]

    for i, v in ipairs(self.tablelist) do
        print("............i = ", i)
        v:showNode()
        v:setTableIndex(i - 1)
    end

    self.mytable = bottomtable

end

--漂相关
function GameScene:SelectPiao(data,havepass)
    if data == nil then
        return 
    end
    print("show piao")
    --self.UILayer:gameStartAciton()
     --if not self:getSeatInfoByIdx(self:getMyIndex()).is_piao then
            local piaos = 0
         
        local piao_score = data.piao_score
        if not piao_score or piao_score == 0 then
            piao_score = 0
        end
        local cantab = {}
         if 5 >= piao_score then
            cantab = {5}
        end
        if 3 >= piao_score then
            cantab = {3,5}
        end
        if 2 >= piao_score then
            cantab = {2,3,5}
        end
        local selectnode = cc.Node:create()
        selectnode:setPosition(display.cx,display.cy)
        local btn1 = ccui.Button:create("game/btn_piao.png", "game/btn_piao.png", "game/btn_piao.png", ccui.TextureResType.localType)
        
        selectnode:addChild(btn1)
        self:addChild(selectnode)
        btn1:setPositionX(0)
        WidgetUtils.addClickEvent(btn1,function ()
            self:clickPiaoBtn(selectnode,btn1,cantab,data)
        end)

        if havepass then
            local btn2 = ccui.Button:create("game/btn_guo.png", "game/btn_guo.png", "game/btn_guo.png", ccui.TextureResType.localType)
            selectnode:addChild(btn2)
            btn1:setPositionX(-100)
            btn2:setPositionX(100)
            
            WidgetUtils.addClickEvent(btn2,function ()
                self:requestPiao(0,data)
                selectnode:removeFromParent()
            end)
        end
    --end

    -- for i,v in ipairs(self:getSeatsInfo()) do
    --     if not v.is_piao then
    --         self.tablelist[v.index+1]:setPiao(-1)
    --     else
    --         self.tablelist[v.index+1]:setPiao(v.piao_score)
    --     end
    -- end
end

function GameScene:notifyPiao( data )

    print("GameScene:notifyPiao( data )")
    printTable(data,"xpp")

    local _score = data.piao_score or 0
    if _score > 0 then
        self:getSeatInfoByIdx(data.seat_index).is_piao = true
    else
        self:getSeatInfoByIdx(data.seat_index).is_piao = false
        _score = 0
    end
    self:getSeatInfoByIdx(data.seat_index).piao_score = _score
    self.tablelist[data.seat_index+1]:setPiao(_score)
    self:deleteAction("更新结束")
    table.insert(self.actionList, 1,{ act_type = ACTIONTYPEBYMYSELF.DINGZHANG} ) 
end

-- 生成飘的2级页面
function GameScene:clickPiaoBtn(selectnode,btn,cantab,data)
    
    if btn.layer and tolua.cast(btn.layer,"cc.Node") then
        btn.layer:removeFromParent()
        btn.layer = nil
        return
    end

    btn.layer = cc.Node:create()
        :addTo(selectnode)

    local bg = ccui.ImageView:create("game/action_bg.png")
        :setScale9Enabled(true)
        :setCapInsets(cc.rect(30, 30, 44, 44))
        :setAnchorPoint(cc.p(0.5, 0))
        bg:setLocalZOrder(-1)
        bg:setContentSize(cc.size(56 + 44 + 92 *#cantab, 76 + 76))
        btn.layer:addChild(bg)

    local jiantou = ccui.ImageView:create("game/action_arrow.png")
        jiantou:setAnchorPoint(cc.p(0.5, 1))
        jiantou:setPositionX(bg:getContentSize().width / 2.0)
        bg:addChild(jiantou)

    -- 生成选择项
    for i,v in ipairs(cantab) do
        local node = cc.Node:create()

        local btn = ccui.Button:create("game/piaobtn/piao_yellow_"..v..".png", "game/piaobtn/piao_yellow_"..v..".png", "game/piaobtn/piao_gray_"..v..".png", ccui.TextureResType.localType)
        btn:setAnchorPoint(cc.p(0.5, 0.5))
        btn:setScale9Enabled(true)
        -- btn:setContentSize(cc.size(50, 76 +(5 - 1) * 32))
        btn:setPositionX(0)
        btn:setPositionY(0)

        -- if min_score > i then
        --     btn:setBright(false)
        --     btn:setTouchEnabled(false)
        -- end

        WidgetUtils.addClickEvent(btn, function()
            -- self:sendAction(_tab)
            self:requestPiao(v,data)
            if tolua.cast(selectnode,"cc.Node") then
                selectnode:removeFromParent()
            end
        end )
        node:addChild(btn)

        node:setPositionX(28 + 22 +(i - 1) * 92+46)
        node:setPositionY(bg:getContentSize().height / 2.0)
        bg:addChild(node)
    end
   

    local _x, _y = btn:getPosition()
    btn.layer:setPosition(cc.p(_x, _y + 80))
end

function GameScene:requestPiao(piao_score,data)
    print("piao_score:"..piao_score)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_sdr_do_action
    
    request.seat_index = data.seat_index
    request.act_type = poker_common_pb.EN_SDR_ACTION_PIAO
    if piao_score ~= 0 then
        request.piao_score = piao_score
    end

    SocketConnect_instance:send("cs_request_sdr_do_action", msg,{json_msg_id = json_msg_id})
end





return GameScene