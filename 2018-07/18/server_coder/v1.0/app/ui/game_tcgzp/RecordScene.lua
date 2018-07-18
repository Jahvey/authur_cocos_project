local RecordScene = class("RecordScene", require "app.ui.game.RecordScene")
local LongCard = require "app.ui.game.base.LongCard"
function RecordScene:otherInitView()

    --删除队列里面的某个值
    self.mytable.deleteGroupingValue = function (self,_group,value)
        --删除牌
        for colIndex,col in pairs(_group) do
            for _k,v in pairs(col) do
                if  v[1] == value then
                    if #col == 1 then
                        table.remove(_group,colIndex) 
                    else
                        table.remove(_group[colIndex],_k) 
                    end
                    return true
                end
            end
        end
        return false
    end

    --和手牌的整理，主要用于手牌和保存的牌数量不对的情况，以及捡和暗的牌不对的情况
    self.mytable.GroupingCompareHands = function (self)
        -------
        -- --是否是捡牌--第一个值是牌值，第二个值表示是否捡牌，第三个值表示是否暗牌
        local jianList = clone(self.jianList)
        local function getIsJianCard( card )
             for i,v in ipairs(jianList) do
                if v == card then
                    table.remove(jianList,i)
                    return true
                end
            end
            return false
        end
        print(".............我的捡牌列表")
        printTable(jianList,"xp26")

        -- --是否是暗牌
        local banedList = clone(self.banedList)
        local function getIsBanedCard( card )
            for i,v in ipairs(banedList) do
                if v == card then
                    table.remove(banedList,i)
                    return true
                end
            end
            return false
        end
        for k,col in pairs(self.myGrouping) do
            for kk,card_data in pairs(col) do

                if card_data[2] ~= 0 then
                    print("........我之前的捡")
                    print(".............card_data[1] = ",card_data[1])

                    if getIsJianCard(card_data[1]) == false then
                        card_data[2] = 0
                    end
                end

                if card_data[3] ~= 0 then
                    if getIsBanedCard(card_data[1]) == false then
                        card_data[3] = 0
                    end
                end
            end
        end
        print(".............我的捡牌列表")
        printTable(jianList,"xp26")



        local handtile = clone(self.gamescene:getHandTileByIdx(self.tableidx))
        local grouping = clone(self.myGrouping)
        for i=#handtile,1,-1 do
            if  self:deleteGroupingValue(grouping,handtile[i]) then
                table.remove(handtile,i)
            end
        end

        --是否是捡牌--第一个值是牌值，第二个值表示是否捡牌，第三个值表示是否暗牌
        -- local jianList = clone(self.jianList)
        -- local function getIsJianCard( card )
        --      for i,v in ipairs(jianList) do
        --         if v == card then
        --             table.remove(jianList,i)
        --             return true
        --         end
        --     end
        --     return false
        -- end
        -- print(".............我的不能出的列表")
        -- printTable(self.banedList,"xp22")
        --是否是暗牌
        local banedList = clone(self.banedList)
        local function getIsBanedCard( card )
            for i,v in ipairs(banedList) do
                if v == card then
                    table.remove(banedList,i)
                    return true
                end
            end
            return false
        end

        --手牌多了，显示的牌少了
        if handtile and #handtile >0 and self.myGrouping then

            print("............手牌多了，显示的牌少了")
            printTable(jianList,"xp26")

            if #handtile + #self.myGrouping[#self.myGrouping] < 6 then
                for k,v in pairs(handtile) do
                    local _card_data = {v,0,0}
                    if getIsJianCard(v) then
                        _card_data[2] = 1
                    end
                    if getIsBanedCard(v) then
                        _card_data[3] = 1
                    end
                    table.insert(self.myGrouping[#self.myGrouping],_card_data)
                end
            else
                local col_data = {}
                 for k,v in pairs(handtile) do
                    local _card_data = {v,0,0}
                    if getIsJianCard(v) then
                        _card_data[2] = 1
                    end
                    if getIsBanedCard(v) then
                        _card_data[3] = 1
                    end
                    table.insert(col_data,_card_data)
                end
                table.insert(self.myGrouping,col_data)
            end
        end    

        if grouping and #grouping >0 then
            print("....手牌少了，显示的牌多了")
            printTable(grouping,"xp09")
            --显示的牌多了,
            for k,v in pairs(grouping) do
                if #v > 0 then
                    for kk,vv in pairs(v) do
                        print(".....vv = ",vv)
                        self:deleteGroupingValue(self.myGrouping,vv[1])
                    end
                end
            end
        end

        -- print("........整理之后的")
        -- printTable(self.myGrouping,"xp26")


    end

    --观的流程修改，返回观的列数，并且把观的牌，放在最前面去
    self.mytable.getGuanLieGrouping = function (self)

        local guanNum = self.gamescene:getGuanTimes()
        print("......我的观牌次数！ guanNum ＝ ",guanNum)

        self.icon:getChildByName("fentext"):setString("观牌次数:"..guanNum)

        if guanNum == 0 then
            return
        end

        local list = clone(self.gamescene:getHandTileByIdx(self.tableidx))
        --因为捡的不参与，就先把捡的给踢出去

        local jianList = clone(self.jianList)
        local function getIsJianCard( card )
            for i,v in ipairs(jianList) do
                if v == card then
                    table.remove(jianList,i)
                    return true
                end
            end
            return false
        end

        -- print("......观的列表处，先把捡的删除掉")
        -- printTable(jianList,"xp26")
        for i=#list,1,-1 do
            if  getIsJianCard(list[i]) == true then
                table.remove(list,i)
            end
        end

        local alterList = 
        {  
            [0x81] =  {value = 0x71,num = 0}, --猫乙己
            [0x83] =  {value = 0x73,num = 0},--化三千
            [0x85] =  {value = 0x75,num = 0},--75
            [0x87] =  {value = 0x77,num = 0},--七十土
            [0x89] =  {value = 0x79,num = 0},--八九子
        }
        local function getIsHave(_val)
            for k,v in pairs(list) do
                if v == _val  then
                    return true
                end
            end
            return false
        end

        local function getIsAlter(_val)
            if alterList[_val] == nil then
                return _val
            end
            local _alter = alterList[_val]
            _alter.num = _alter.num  + 1
            return _alter.value
        end
        
        print("转换之前的！！！！！！！！")
        printTable(list,"xp26")

        local cloneList =  {}
        for k,v in pairs(list) do
            table.insert(cloneList,getIsAlter(v))
        end

        print("转换之后的！！！！！！！！")
        printTable(cloneList,"xp26")

        --结构体整理，统计每张牌的个数，
        local realList = {}
        for i,v in ipairs(cloneList) do
            local ishave = false
            for kk,vv in pairs(realList) do
                if vv.real_value == v then
                    vv.num = vv.num + 1
                    ishave = true
                end
            end
            if not ishave then
                local _data = {}
                _data.real_value = v
                _data.num = 1
                table.insert(realList,_data)
            end
        end
        print("转换之后的！！！！！！！！")
        printTable(realList,"xp26")


        local guanList = {}
        for k,v in pairs(realList) do
            if v.num >= 4 then
                table.insert(guanList,v.real_value)
            end
        end

        print(".......#guanList = ",#guanList)
        printTable(guanList,"xp25")


        if #guanList == 0  or #guanList > guanNum then
            return 
        end

        --满足观列的提出来,并从self.myGrouping里面删除，捡的出牌
        local function deleteGroupingValue( value )
            --删除牌
            for colIndex,col in pairs(self.myGrouping) do
                for _k,v in pairs(col) do
                    if  v[1] == value and v[2] == 0 then
                        if #col == 1 then
                            table.remove(self.myGrouping,colIndex) 
                        else
                            table.remove(self.myGrouping[colIndex],_k) 
                        end
                        return true
                    end
                end
            end
            return false
        end

        local restoreList = 
        {
            [0x71] = 0x81,--71
            [0x73] = 0x83,--73
            [0x75] = 0x85,--75
            [0x77] = 0x87,--77
            [0x79] = 0x89,--79
        }

        for k,v in pairs(guanList) do
            local columnList = {}
            local num = 4
            local _data = {v,0,1}

            local _v = restoreList[v]
            if _v == nil then
                for i = 1,num do
                    deleteGroupingValue(v)
                    table.insert(columnList,1,_data)
                end
            else
                print("......._v = ",v)
                printTable(alterList[_v],"xp26")
                if alterList[_v].num > 0 then
                    local _vv = {_v,0,1}
                    num =  num - alterList[_v].num
                    for i=1,alterList[_v].num do
                        deleteGroupingValue(_v)
                        table.insert(columnList,1,_vv)
                    end
                end
                if num > 0 then
                    for i=1,num do
                        deleteGroupingValue(v)
                        table.insert(columnList,1,_data)
                    end
                end
            end
            table.insert(self.myGrouping,1,columnList)
        end
        printTable(self.myGrouping,"xp25")
    end

    --刷新手牌
    self.mytable.refreshHandTile = function (self,move)

        self:updataHuXiText()
        self:deleteMoveSprite()
        -- print(debug.traceback("", 2))

        ----------整理牌的列表
        if self.myGrouping == nil or self.gamescene.name == "RecordScene" then
            local handtile = clone(self.gamescene:getHandTileByIdx(self.tableidx))
            self.handtile = self:sortMyHandTile(handtile)
            self.myGrouping = {}
            for k,v in pairs(self.handtile) do
                local _col = {}
                for _kk,_vv in pairs(v.valueList) do
                    table.insert(_col,_vv.real_value)
                end
                if #_col > 0 then
                    local _groupCol = {}
                    for kk,vv in pairs(_col) do
                        table.insert(_groupCol,{vv,0,0}) --第一个值是牌值，第二个值表示是否捡牌，第三个值表示是否暗牌
                    end
                    table.insert(self.myGrouping,_groupCol)  
                end
            end
            local jianList = clone(self.jianList)
            local function getIsJianCard( card )
                 for i,v in ipairs(jianList) do
                    if v == card then
                        table.remove(jianList,i)
                        return true
                    end
                end
                return false
            end
            --是否是暗牌
            local banedList = clone(self.banedList)
            local function getIsBanedCard( card )
                for i,v in ipairs(banedList) do
                    if v == card then
                        table.remove(banedList,i)
                        return true
                    end
                end
                return false
            end
            for k,col in pairs(self.myGrouping) do
                for kk,card_data in pairs(col) do
                    if getIsJianCard(card_data[1]) then
                        card_data[2] = 1
                    end
                    if getIsBanedCard(card_data[1]) then
                        card_data[3] = 1
                    end
                end
            end
        else
            self:GroupingCompareHands()
        end

        --判断观列数，
        self:getGuanLieGrouping()

        
        self.out_col = 0

        self:saveMyGrouping()
      
        --把放下去的暗杠也需要加到上述列表中
        local refreshGrouping = clone(self.myGrouping)
       
        if self.gamescene:getTableConf().ttype == HPGAMETYPE.TCGZP then --个子牌，有一部分操作后的牌也是放在手里面，
           local showTile = clone(self.gamescene:getShowTileByIdx(self.tableidx))
           print("showTile .........")
           printTable(showTile,"xp24")

           for k,v in pairs(showTile) do
                if (v.col_type == poker_common_pb.EN_SDR_COL_TYPE_YI_HUA and v.an_num == 5) then
                    local _groupCol = {}
                    for kk,vv in pairs(v.cards) do
                        table.insert(_groupCol,{vv,0,1}) --第一个值是牌值，第二个值表示是否捡牌，第三个值表示是否暗牌
                    end
                    table.insert(refreshGrouping,1,_groupCol)
                    self.out_col = self.out_col + 1
                end
            end
        end

        self.handCardNode:removeAllChildren()
        self.handCardNode:setVisible(true)

        --听胡数据
        local tingData = self.gamescene:getUpdataHuInfo()

        if tingData and #tingData == 1 and tingData[1].dest_card == 0 then
            print(".........")
            self.gamescene.UILayer:setShowTingBtn(true)
        else
            self.gamescene.UILayer:setShowTingBtn(false)
        end
        local function getIsJiaoCard(card)
            if tingData and #tingData >0 then
                for i,v in ipairs(tingData) do
                    if card == v.dest_card then
                        return true
                    end
                end
            end
            return false
        end


        --生成牌
        self.handcardspr = { }
        local all_wid = #refreshGrouping * 88
        -- if #self.myGrouping > 9 then
        --     all_wid = 7 * 88
        -- end
        self.mostLeft = - all_wid/2 - 44
        for i, _col in pairs(refreshGrouping) do
            if not self.handcardspr[i] then
                self.handcardspr[i] = { }
            end
            local _y = 9 - 10
            local oldCard = -1
            for m, cardData in pairs(_col) do
                local pai = LongCard.new(CARDTYPE.MYHAND, cardData[1])
                self.handCardNode:addChild(pai, 4 - m)
                pai.colIndex_X = i - self.out_col
                pai.colIndex_Y = m
                pai.cardData = cardData

                --第一个值是牌值，第二个值表示是否捡牌，第三个值表示是否暗牌

                local _x = 88 *(i - 1) - all_wid / 2
                if  self.out_col < i then --outcol的牌不参与捡牌显示
                    if cardData[2] ~= 0 then
                        pai.isJian = true
                        pai:setJian()
                    end
                    if cardData[3] ~= 0 then
                        pai:setGray()
                    else
                        if getIsJiaoCard(cardData[1]) then
                            pai:setJiaoTips()
                        end
                    end
                else
                    pai:setGray()
                end

                if (oldCard == cardData[1] and #_col > 5 ) then
                    _y = _y - 35
                end
                pai._x = _x
                pai._y = _y

                if move and self.gamescene.name == "GameScene" then
                    pai:setPosition(cc.p(0, _y))
                    -- 从最中间 往两边移动
                    table.insert(self.handcardspr[i], pai)
                    pai:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(_x, _y)), cc.CallFunc:create( function()

                        pai:setOriginPos(pai._x, pai._y)
                        pai:setPosition(cc.p(pai._x, pai._y))
                        self:addTileEvent(pai)
                    end )))
                else
                    pai:setOriginPos(pai._x, pai._y)
                    pai:setPosition(cc.p(pai._x, pai._y))
                    self:addTileEvent(pai)
                end

                oldCard = cardData[1]
                _y = _y + 70
            end
        end
    end


    self.mytable.addTileEvent = function (self,tile)

        local beganposx, beganposy = tile:getOriginPos()
        local function shallResponseEvent()
            if not tolua.cast(tile, "cc.Node") then
                return false
            end

            if self.gamescene:getSeatInfoByIdx(self.tableidx).state == 99 then
                return false
            end

            if self.isTouched then
                return false
            end

            if tile:getIsGray() then
                return false
            end
            return true
        end

        local function onTouchBegan(touch, event)
            -- print("..............onTouchBegan.......1")
            -- print("...........self.isTouched = ",self.isTouched)
            if not shallResponseEvent() then
                return
            end
            beganposx, beganposx = tile:getPosition()
            local locationInNode = tile:getbg():convertToNodeSpace(touch:getLocation())
            local s = tile:getbg():getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height);
            if cc.rectContainsPoint(rect, locationInNode) then
                tile:setCardOpacticy(255 * 0.4)
                self:addMoveSprite(tile, touch:getLocation())
                self.isTouched = true

                if tile:getIsJiao() then
                    self.gamescene.UILayer:showTingView(tile:getCardValue())
                end
                return true
            end
        end

        local function onTouchMove(touch, event)
            -- print("..............onTouchMove.......1")
            local touchPoint = touch:getLocation()
            self:setMoveSpritePos(touchPoint)
        end

        local function onTouchEnd(touch, event)
            self.isTouched = false
            tile:setCardOpacticy(255)
            self.gamescene.UILayer:hiddenTingView()

            if self.moveCardImg and WidgetUtils:nodeIsExist(self.moveCardImg) then
                if self.moveCardImg:getPositionY() > self.shouzhiNode:getPositionY() then
                    if self:tryChupai(tile) then
                        self:deleteMoveSprite()
                        -- 重新整理位置，扣出一张牌
                        return
                    end
                end

                local function back_move()
                     -- 重新调整位置
                    local worldpos1 = self.handCardNode:convertToWorldSpace(cc.p(tile:getPosition()))
                    self.moveCardImg:runAction(cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(0.3, worldpos1)), cc.CallFunc:create( function()
                        self:deleteMoveSprite()
                    end )))
                end
               
                local worldpos1 = self.handCardNode:convertToNodeSpace(cc.p(self.moveCardImg:getPosition()))
                if worldpos1.x <= self.mostLeft then
                    back_move()
                    return
                end

                local moveToCol = math.floor((worldpos1.x - self.mostLeft) / 88+1) - self.out_col
                local oldColIndex = tile.colIndex_X

                if moveToCol <= 0 or  moveToCol >  11 or moveToCol == oldColIndex then
                    back_move()
                    return
                end
                if moveToCol <= #self.myGrouping and #self.myGrouping[moveToCol] >= 6 then
                    back_move()
                    return
                end

                print("............oldColIndex ＝ ",oldColIndex)
                print("............moveToCol ＝ ",moveToCol)
                print("............self.myGrouping ＝ ",#self.myGrouping)
                print("............oldColIndex self.myGrouping ＝ ",#self.myGrouping[oldColIndex])
                print("............self.out_col ＝ ",self.out_col)
                -- print("............moveToCol self.myGrouping ＝ ",#self.myGrouping[moveToCol])
                --
                local function deleColIndex()
                    --删除当前列
                    if self.myGrouping[oldColIndex] then
                        if #self.myGrouping[oldColIndex] == 1 then
                            table.remove(self.myGrouping,oldColIndex) 
                            return true
                        else
                            table.remove(self.myGrouping[oldColIndex],tile.colIndex_Y) 
                        end
                    end
                    return false
                end

                --目标列和自己所在列不一样，并且目标列的数量小于6
                if moveToCol >#self.myGrouping then
                    deleColIndex()
                    table.insert(self.myGrouping,{tile.cardData})
                else
                    table.insert(self.myGrouping[moveToCol],tile.cardData) 
                    if  deleColIndex() == true  and moveToCol > oldColIndex then
                        moveToCol = moveToCol - 1
                    end
                    local function sortfunc_(_a,_b)
                        return _a[1]%16  < _b[1]%16
                    end
                    table.sort(self.myGrouping[moveToCol],sortfunc_)
                end
                self:refreshHandTile()
            end
        end

        local function onTouchCancell(touch, event)
            print("onTouchCancel======")
            self.isTouched = false
            tile:setCardOpacticy(255)
            self.gamescene.UILayer:hiddenTingView()
            if self.moveCardImg and WidgetUtils:nodeIsExist(self.moveCardImg) then
                -- 重新调整位置
                local worldpos1 = self.handCardNode:convertToWorldSpace(cc.p(tile:getPosition()))

                self.moveCardImg:runAction(cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(0.3, worldpos1)), cc.CallFunc:create( function()
                    self:deleteMoveSprite()
                end )))

            end
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
        listener:registerScriptHandler(onTouchCancell, cc.Handler.EVENT_TOUCH_CANCELLED)
        local eventDispatcher = tile:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, tile)
    end

    --删除手牌，出牌的时候删除某列的某张牌，固定到行和列
    self.mytable.deleteHandCard = function (self,_list,data)
       
        if data and data.colIndex_X and data.colIndex_X ~= -1 then
            local col = self.myGrouping[data.colIndex_X]
            if  col then
                if #col == 1 then
                    table.remove(self.myGrouping,data.colIndex_X) 
                else
                    table.remove(self.myGrouping[data.colIndex_X],data.colIndex_Y) 
                end
            end
            return
        else
            local list = clone(_list)
            local function deleteGrouping(value)
              --删除牌
                for colIndex,col in pairs(self.myGrouping) do
                    for _k,v in pairs(col) do
                        if  v[1] == value and v[2] == 0 then
                            if #col == 1 then
                                table.remove(self.myGrouping,colIndex) 
                            else
                                table.remove(self.myGrouping[colIndex],_k) 
                            end
                            return true
                        end
                    end
                end
                return false
            end
            for i=#list,1,-1 do
                if deleteGrouping(list[i]) == true then
                    table.remove(list,i)
                end
            end
        end
        -- self:refreshHandTile()
    end

    --保存和读取，用于断线重连后，也要是之前的拖牌情况
    self.mytable.saveMyGrouping = function (self,isNil)
        if isNil  then
           self.myGrouping = nil 
        end

        local grouping = cjson.encode(self.myGrouping)
        cc.UserDefault:getInstance():setStringForKey("myGrouping"..LocalData_instance.uid,grouping)
    end

    self.mytable.getMyGrouping = function (self)

       local grouping = cc.UserDefault:getInstance():getStringForKey("myGrouping"..LocalData_instance.uid)
        if not grouping or grouping == "" then
            return nil
        end
        local tab = cjson.decode(grouping)

        return tab
    end

    -- self.mytable:refreshHandTile(false)
end


function RecordScene:priorityAction(data,hidenAnimation)

    if data.act_type == poker_common_pb.EN_SDR_ACTION_JIAN then  --捡
        print("...........EN_SDR_ACTION_JIAN --捡 ")
        printTable(data,"xp11")
        self:addHandTile(data.seat_index, data.dest_card)

        if  data.seat_index == self:getMyIndex() then
            self.mytable:setJianCardsList(data.jian_cards)
        end
        local lastNode  = self.tablelist[data.last_action_index+1].effectnode
        self.tablelist[data.seat_index+1]:JianShangShouAction(data.dest_card,lastNode)

        return true
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_HUA then  --滑

        self:tableHideEffectnode()
        self:addShowTile(data.seat_index, data.col_info)
        self.tablelist[data.seat_index + 1]:refreshXiaZhua(data)
        -- EN_SDR_COL_TYPE_YI_HUA
        -- an_num == 5 不放下去
        -- --为true的时候，表示是用已经歪了的吃的，只需要更新内容
        self:deleteHandTile(data.col_info.cards,data.seat_index)
        self.tablelist[data.seat_index+1]:huaPaiAction(data)
        return true
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_GANG then --招
        print(".........招牌动画")
        self:tableHideEffectnode()
        self:addShowTile(data.seat_index, data.col_info)

        --为true的时候，表示是用已经歪了的吃的，只需要更新内容
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            self:deleteHandTile(data.col_info.cards,data.seat_index)
        end
        self.tablelist[data.seat_index + 1]:zhaoPaiAction(data)
        return true
    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_AN_GANG then --观
        print(".........观牌动画")
        printTable(data,"xp26")
        self:tableHideEffectnode()
        self:setGuanTimes(data)

        self.tablelist[data.seat_index + 1]:refreshXiaZhua(data)
        self.tablelist[data.seat_index + 1]:guanPaiAction(data)
        return true

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_TOU then  --偷牌
        self:tableHideEffectnode()

        self:setRestTileNum(self:getRestTileNum() -1)
        self.UILayer:refreshInfoNode()
        self.tablelist[data.seat_index + 1]:refreshXiaZhua(data)

        self:addHandTile(data.seat_index, data.dest_card)
        self.tablelist[data.seat_index + 1]:touPaiAction(data)
        return true

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_UPDATE then  --更新out_col
        print(".........更新out_col")
        printTable(data,"xp8")
        -- 
        self:addShowTile(data.seat_index, data.col_info)
        self.tablelist[data.seat_index+1]:refreshShowTile()
        self.tablelist[data.seat_index+1]:refreshHandTile()

        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function() 
            self:deleteAction("更新结束")
        end)))
        return true
    end

    return false
end

function RecordScene:actiongo()
    local action = cc.Sequence:create(cc.DelayTime:create(0.75), cc.CallFunc:create( function()
        if self.table_info.sdr_total_action_flows and self.table_info.sdr_total_action_flows[self.beiginpos] ~= nil then

            local data = self.table_info.sdr_total_action_flows[self.beiginpos]
            if data.action.act_type == poker_common_pb.EN_SDR_ACTION_PRE_CHUPAI then
                self.beiginpos = self.beiginpos + 1
                data = self.table_info.sdr_total_action_flows[self.beiginpos]
            end

            self:action(data)
            self.beiginpos = self.beiginpos + 1

            self:updataProgress()
        else
            print("结束")
            self:stopAllActions()
            self:endplay()
        end
    end ))
    self:runAction(cc.RepeatForever:create(action))
end

return RecordScene