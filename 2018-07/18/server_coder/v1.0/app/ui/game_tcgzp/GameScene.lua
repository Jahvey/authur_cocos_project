-- 长牌场景
local GameScene = class("GameScene", require "app.ui.game.GameScene")
local LongCard = require "app.ui.game.base.LongCard"
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


function GameScene:otherInitView()

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
        --是否是捡牌--第一个值是牌值，第二个值表示是否捡牌，第三个值表示是否暗牌
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

    
        for k,col in pairs(self.myGrouping) do
            if  self.guan_colNum  and self.guan_colNum < k then
            else
                for kk,card_data in pairs(col) do
                    if card_data[2] ~= 0 then
                        if getIsJianCard(card_data[1]) == false then
                            card_data[2] = 0
                        end
                    end

                    -- if card_data[3] ~= 0 then
                    --     if getIsBanedCard(card_data[1]) == false then
                    --         card_data[3] = 0
                    --     end
                    -- end
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

        --手牌多了，显示的牌少了
        if handtile and #handtile >0 and self.myGrouping then

            print("............手牌多了，显示的牌少了")
            printTable(jianList,"xp26")
            local alterList = 
            {   
                [0x71] =  {value = 0x2e,is = {0x2d,0x2f}, num = 0}, --猫乙己
                [0x73] =  {value = 0x3e,is = {0x3d,0x3f},num = 0},--化三千
                [0x77] =  {value = 0x4d,is = {0x4f},num = 0},--七十土
                [0x79] =  {value = 0x5e,is = {0x5f},num = 0},--八九子

                [0x7a] =  {value = 0x4e,is = {0x4f},num = 0},--七十土
                [0x78] =  {value = 0x5d,is = {0x5f},num = 0},--八九子

                [0x81] =  {value = 0x2e,is = {0x2d,0x2f},must = 0x71,num = 0}, --猫乙己
                [0x83] =  {value = 0x3e,is = {0x3d,0x3f},must = 0x73,num = 0},--化三千
                [0x87] =  {value = 0x4d,is = {0x4f},must = 0x77,num = 0},--七十土
                [0x89] =  {value = 0x5e,is = {0x5f},must = 0x79,num = 0},--八九子

                [0x85] =  {value = 0x75,must = 0x75,num = 0},--75
            }

            local function getIsHave(_val,_all)
                for k,v in pairs(_all) do
                    if v == _val  then
                        return true
                    end
                end
                return false
            end

            local function getIsAlter(_val,_all)
                if alterList[_val] == nil then
                    return _val
                end
                local _alter = alterList[_val]
                if _val == 0x85 then
                    _alter.num = _alter.num  + 1
                    return 0x75
                else
                    for k,v in pairs(_alter.is) do
                        if getIsHave(v,_all) == true then
                            _alter.num = _alter.num  + 1
                            return _alter.value
                        end
                    end
                    if _alter.must ~= nil then
                        _alter.num = _alter.num  + 1
                        return _alter.must
                    end
                end
                return _val
            end
    

            local function getIsOneValue(_list)

                local list = clone(_list)
                local cloneList =  {}
                for k,v in pairs(list) do
                    table.insert(cloneList,getIsAlter(v,list))
                end
                local oneValue = 0
                for k,v in pairs(cloneList) do
                    if oneValue == 0 then
                        oneValue =  math.floor(v/16)
                    else
                        if oneValue ~= math.floor(v/16) then
                            return false
                        end
                    end
                end
                return true
            end
            local guanNum,guanList,alterList = self:getGuanNum()
            -- if guanNum == 0 or #guanList == 0  or #guanList > guanNum then
            --     guanNum = 0
            -- end

            local col_data = {}
            for k,v in pairs(handtile) do
                local _card_data = {v,0,0}
                if getIsJianCard(v) then
                    _card_data[2] = 1
                end
                -- if getIsBanedCard(v) then
                    _card_data[3] = 0
                -- end

                local ishave = false
                --先找相同的
                for i=guanNum+1,self.maxCol do
                    local length = 0 
                    if  self.myGrouping[i] then
                        length = #self.myGrouping[i]
                    end
                    if length > 0 and length < 6 and ishave == false then
                        for _k,_v in pairs(self.myGrouping[i]) do
                            if v == _v[1] then
                                table.insert(self.myGrouping[i],_card_data)
                                ishave = true
                                break
                            end

                            if (v > 0x70 and _v[1] > 0x70) and math.abs(v - _v[1]) == 16 then
                                table.insert(self.myGrouping[i],_card_data)
                                ishave = true
                                break
                            end
                        end
                    end
                end
                if ishave == false then
                    for i=guanNum+1,self.maxCol do
                        if self.myGrouping[i] and #self.myGrouping[i] > 0 and #self.myGrouping[i] < 6 and ishave == false then
                            local _list = {v}
                            for _k,_v in pairs(self.myGrouping[i]) do
                                table.insert(_list,_v[1])
                            end
                            if  ishave == false then
                                if  getIsOneValue(_list) then
                                    print("....找到了，列数为 = ",i)
                                    table.insert(self.myGrouping[i],_card_data)
                                    ishave = true
                                    break
                                end
                            end
                        end
                    end
                end

                if ishave == false then
                    table.insert(col_data,_card_data)
                end
            end
            if #col_data > 0 then
                for i=self.maxCol,1,-1 do
                    if self.myGrouping[i] then
                        local _oldNum = #self.myGrouping[i]
                        if  _oldNum < 6 and #col_data > 0 then
                            for ii=1,6-_oldNum do
                                if #col_data > 0 then
                                    table.insert(self.myGrouping[i],col_data[1])
                                    table.remove(col_data,1)
                                end
                            end
                        end
                    end
                end
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

        -- if banedList and #banedList > 0 then
            for k,col in pairs(self.myGrouping) do
                for kk,card_data in pairs(col) do
                    -- if card_data[3] == 0 then
                        if getIsBanedCard(card_data[1]) == true then
                            card_data[3] = 1
                        else
                            card_data[3] = 0
                        end
                    -- end
                end
            end
        -- end
    end


     --观的流程修改，返回观的列数，并且把观的牌，放在最前面去
    self.mytable.getGuanNum = function (self)
        local _guanNum = self.gamescene:getGuanTimes()
        print("...........我观的次数！！！！guanNum ＝ ",_guanNum)
        if  _guanNum == 0 then
            return 0,{},nil
        end

        if  _guanNum == self.guan_colNum  then
            return self.guan_colNum,{},nil 
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
        

        local cloneList =  {}
        for k,v in pairs(list) do
            table.insert(cloneList,getIsAlter(v))
        end
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
        local guanList = {}
        for k,v in pairs(realList) do
            if v.num >= 4 then
                table.insert(guanList,v.real_value)
            end
        end
        return _guanNum,guanList,alterList
    end

    --观的流程修改，返回观的列数，并且把观的牌，放在最前面去
    self.mytable.getGuanLieGrouping = function (self)

        local guanNum,guanList,alterList = self:getGuanNum()
        if guanNum == 0 or #guanList == 0  or #guanList > guanNum then
            return 0
        end

        --满足观列的提出来,并从self.myGrouping里面删除，捡的出牌
        local function deleteGroupingValue( value )
            --删除牌
            for colIndex,col in pairs(self.myGrouping) do
                for _k,v in pairs(col) do
                    if  v[1] == value and v[2] == 0 then
                        if #col == 1 then
                            self.myGrouping[colIndex] = {}
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

            --需要删除一个中间的空白列，如果有的话
            for i=#guanList,#self.myGrouping do
                if self.myGrouping[i] and #self.myGrouping[i] == 0 then
                    table.remove(self.myGrouping,i)
                    break
                end
            end
        end

        return #guanList
        -- printTable(self.myGrouping,"xp25")
    end

    --刷新手牌
    self.mytable.refreshHandTile = function (self,move)

        self:updataHuXiText()
        self:deleteMoveSprite()

        -- print(debug.traceback("", 2))
        print(".......................................捡牌列表")
        printTable(self.banedList,"xp227")

        self.maxCol = 9

        ----------整理牌的列表
        if self.myGrouping == nil or self.gamescene.name == "RecordScene" then
            local handtile = clone(self.gamescene:getHandTileByIdx(self.tableidx))
            self.handtile = self:sortMyHandTile(handtile)
            self.myGrouping = {}

            for i=1,self.maxCol do
                table.insert(self.myGrouping,{})
            end

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
                    self.myGrouping[k] = _groupCol
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
        -- self.guan_colNum  = 0
        --判断观列数，
        if self.guan_colNum == nil or self.guan_colNum ~= self.gamescene:getGuanTimes() then
            self.guan_colNum = self:getGuanLieGrouping()
        end

        --如果超过9列，需要合并,先删除空余的
        print("............如果超过9列.#self.myGrouping = ",#self.myGrouping)
        if #self.myGrouping > self.maxCol then
            local col_data = {}
            for i=#self.myGrouping,self.maxCol,-1 do
                if self.myGrouping[i] and #self.myGrouping[i] == 0 and #self.myGrouping > self.maxCol then
                  table.remove(self.myGrouping,i)
                end
            end
        end

        -- --如果超过9列，需要合并
        print("............如果超过9列.#self.myGrouping =  ",#self.myGrouping)

        if #self.myGrouping > self.maxCol then
            local col_data = {}
            for i=#self.myGrouping,self.maxCol+1,-1 do
                if  self.myGrouping[i] and #self.myGrouping[i] > 0 then
                    for k,v in pairs(self.myGrouping[i]) do
                       table.insert(col_data,v)
                    end
                end
                print("..............删除当前列  ＝ ",i)
                table.remove(self.myGrouping,i)
            end
            if  #col_data > 0 then  
                for i=self.maxCol,self.guan_colNum,-1 do
                    if self.myGrouping[i] then
                        local _oldNum = #self.myGrouping[i]
                        if  _oldNum < 6 and #col_data > 0 then
                            for ii=1,6-_oldNum do
                                if #col_data > 0 then
                                    table.insert(self.myGrouping[i],col_data[1])
                                    table.remove(col_data,1)
                                end
                            end
                        end
                    end
                end
            end
        end

        for k,v in pairs(self.myGrouping) do
            local function sortfunc_(_a,_b)
                return  _a[1]%16 < _b[1]%16
            end
            table.sort(v,sortfunc_)
        end

        self:saveMyGrouping()
      
        --把放下去的暗杠也需要加到上述列表中
        local refreshGrouping = clone(self.myGrouping)

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
        local all_wid = #refreshGrouping * 98
        -- if #self.myGrouping > 9 then
        --     all_wid = 7 * 88
        -- end


        for i=1,self.maxCol do
            local bg = ccui.ImageView:create("game/card_back_gzp.png")
            bg:addTo(self.handCardNode)
            bg:setPosition(cc.p(98*(i - 5)-1,56))
        end

        self.mostLeft = - 98*4 - 59

        for i, _col in pairs(refreshGrouping) do
            if not self.handcardspr[i] then
                self.handcardspr[i] = { }
            end
            local _y = 9 - 10
            local oldCard = -1
            -- printTable(_col,"xp26")
            local num = #_col
            local add_Y = 60
            if  num > 4 then
                add_Y = 240/num
            end

            for m, cardData in pairs(_col) do
                local pai = LongCard.new(CARDTYPE.MYHAND, cardData[1])
                self.handCardNode:addChild(pai, num - m)
                pai.colIndex_X = i 
                pai.colIndex_Y = m
                pai.cardData = cardData

                --第一个值是牌值，第二个值表示是否捡牌，第三个值表示是否暗牌
                if i <= self.guan_colNum then
                    cardData[3] = 1
                end

                local _x = 98 *(i - 5)
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
         

                if m == 1 then
                    if add_Y ~= 60 then
                       _y =  _y - (60-add_Y)
                    end
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
                _y = _y + add_Y
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

                local moveToCol = math.floor((worldpos1.x - self.mostLeft) / 98 + 1) 
                local oldColIndex = tile.colIndex_X
                if moveToCol <= self.guan_colNum then
                    for i=self.guan_colNum+1,oldColIndex do
                        if  self.myGrouping[i] and #self.myGrouping[i] >= 6 then
                        else
                            if moveToCol <= self.guan_colNum then
                                moveToCol = i
                            end
                        end
                    end
                end
                if moveToCol > self.maxCol then
                    for i=self.maxCol,oldColIndex,-1 do
                        if self.myGrouping[i] and #self.myGrouping[i] >= 6 then
                        else
                            if  moveToCol > self.maxCol then
                                moveToCol = i
                            end
                        end
                    end
                end
                 --目标列和自己所在列不一样，并且目标列的数量小于6
                if moveToCol == oldColIndex then
                    back_move()
                    return
                end
                if self.myGrouping[moveToCol] and #self.myGrouping[moveToCol] >= 6 then
                    back_move()
                    return
                end

                print("............oldColIndex ＝ ",oldColIndex)
                print("............moveToCol ＝ ",moveToCol)
                print("............self.myGrouping ＝ ",#self.myGrouping)
                print("............oldColIndex self.myGrouping ＝ ",#self.myGrouping[oldColIndex])
                -- print("............moveToCol self.myGrouping ＝ ",#self.myGrouping[moveToCol])
                --
                local function deleColIndex()
                    --删除当前列
                    if self.myGrouping[oldColIndex] then
                        if #self.myGrouping[oldColIndex] == 1 then
                            self.myGrouping[oldColIndex] = {}
                            -- table.remove(self.myGrouping,oldColIndex) 
                            return true
                        else
                            table.remove(self.myGrouping[oldColIndex],tile.colIndex_Y) 
                        end
                    end
                    return false
                end
                if  self.myGrouping[moveToCol] == nil  then
                    self.myGrouping[moveToCol] = {}
                end

                deleColIndex()
                table.insert(self.myGrouping[moveToCol],tile.cardData) 
                -- local function sortfunc_(_a,_b)
                --     return _a[1]%16  <= _b[1]%16
                -- end
                -- table.sort(self.myGrouping[moveToCol],sortfunc_)

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
                    self.myGrouping[data.colIndex_X] = {}
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
                                self.myGrouping[colIndex] = {}
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




--clone-- self.myTableClass = {bottomtable,righttable,toptable,lefttable}
    --重载打出的牌
    self.mytable.refreshPutoutTile = function (self)

        self.outCardNode:setPosition(cc.p(-95,338))
        self.outCardNode:removeAllChildren()
        self.outCardNode:setVisible(true)

        self.outcardspr = { }
        self.nextPutPos = cc.p(0-BASECARDWIDTH/2, BASECARDHEIGHT/2)
        local putouttile = clone(self.gamescene:getPutoutTileByIdx(self.tableidx))
        
        for i,v in ipairs(putouttile) do
            local card = LongCard.new(CARDTYPE.ONTABLE, v)
            card:setPosition(self.nextPutPos)
            self.outCardNode:addChild(card)
            table.insert(self.outcardspr, card)
            if i%7 == 0 then
                self.nextPutPos = cc.p(0-BASECARDWIDTH/2, BASECARDHEIGHT/2 - (BASECARDHEIGHT-10)*i/7)
            else
                self.nextPutPos = cc.p(cc.p(self.nextPutPos.x+38,self.nextPutPos.y))
            end

            if self.gamescene:getIsJiangCard(v) then
                card:showJiang()
            end
            if self.gamescene:getIsJokerCard(v) then
                card:showJoker()
            end
        end

    end
    
    self.myTableClass[2].refreshPutoutTile = function (self)

        self.outCardNode:setPosition(cc.p(-365,132))
        self.outCardNode:removeAllChildren()
        self.outCardNode:setVisible(true)

        local putouttile =  clone(self.gamescene:getPutoutTileByIdx(self.tableidx))

        self.outcardspr = { }
        self.nextPutPos = cc.p(-BASECARDWIDTH/2,0-BASECARDHEIGHT/2)
        for i,v in ipairs(putouttile) do
            local card = LongCard.new(CARDTYPE.ONTABLE, v)
            card:setPosition(self.nextPutPos)
            self.outCardNode:addChild(card)
            table.insert(self.outcardspr, card)
            if i%7 == 0 then
                self.nextPutPos = cc.p(-BASECARDWIDTH/2 - BASECARDWIDTH*i/7, -BASECARDHEIGHT/2 )
            else
                self.nextPutPos = cc.p(cc.p(self.nextPutPos.x,self.nextPutPos.y-28))
            end
            print("...........TableRight..self.nextPutPos i = ",i)
            print("...........TableRight..self.nextPutPos x= "..self.nextPutPos.x.." y: "..self.nextPutPos.y)
            if self.gamescene:getIsJiangCard(v) then
                card:showJiang()
            end
            if self.gamescene:getIsJokerCard(v) then
                card:showJoker()
            end
        end
    end


    self.myTableClass[3].refreshPutoutTile = function (self)

        self.outCardNode:setPosition(cc.p(95,-150))
        self.outCardNode:removeAllChildren()
        self.outCardNode:setVisible(true)
        local putouttile = clone(self.gamescene:getPutoutTileByIdx(self.tableidx))
        self.outcardspr = { }
  
        self.nextPutPos = cc.p(BASECARDWIDTH/2,0-BASECARDHEIGHT/2)
        for i,v in ipairs(putouttile) do
            local card = LongCard.new(CARDTYPE.ONTABLE, v)
            card:setPosition(self.nextPutPos)
            self.outCardNode:addChild(card)
            table.insert(self.outcardspr, card)
            if i%7 == 0 then
                self.nextPutPos = cc.p(BASECARDWIDTH/2, 0-BASECARDHEIGHT/2 - (BASECARDHEIGHT-10)*i/7)
            else
                self.nextPutPos = cc.p(cc.p(self.nextPutPos.x-38,self.nextPutPos.y))
            end
            if self.gamescene:getIsJiangCard(v) then
                card:showJiang()
            end
            if self.gamescene:getIsJokerCard(v) then
                card:showJoker()
            end
        end

    end


    self.myTableClass[4].refreshPutoutTile = function (self)
        self.outCardNode:setPosition(cc.p(362,132))
        self.outCardNode:removeAllChildren()
        self.outCardNode:setVisible(true)
        local putouttile =  clone(self.gamescene:getPutoutTileByIdx(self.tableidx))
        
        self.outcardspr = { }
 
        self.nextPutPos = cc.p(BASECARDWIDTH/2,0-BASECARDHEIGHT/2)
        for i,v in ipairs(putouttile) do
            local card = LongCard.new(CARDTYPE.ONTABLE, v)
            card:setPosition(self.nextPutPos)
            self.outCardNode:addChild(card)
            table.insert(self.outcardspr, card)
            if i%7 == 0 then
                self.nextPutPos = cc.p(BASECARDWIDTH/2 + BASECARDWIDTH*i/7, -BASECARDHEIGHT/2 )
            else
                self.nextPutPos = cc.p(cc.p(self.nextPutPos.x,self.nextPutPos.y-28))
            end
            print("...........TableLeft..self.nextPutPos i = ",i)
            print("...........TableLeft..self.nextPutPos x= "..self.nextPutPos.x.." y: "..self.nextPutPos.y)

            if self.gamescene:getIsJiangCard(v) then
                card:showJiang()
            end
            if self.gamescene:getIsJokerCard(v) then
                card:showJoker()
            end
        end

    end

    -- function TableBottom:refreshPutoutTile()

    -- end


    -- self.mytable:refreshHandTile(false)
end


function GameScene:priorityAction(data)

    if data.act_type == ACTIONTYPEBYMYSELF.MYTURN_CHU then
        
        self.mytable:setIsMyTurn(true)
        self.mytable:showShouZhi(true, data.data)
        self.UILayer:setOpertip(data.data.seat_index)
        self.mytable:refreshHandTile(false)

        return true
     elseif data.act_type == poker_common_pb.EN_SDR_ACTION_JIAN then  --捡
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
        self:setGuanTimes(data)
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
            local list = {}
            local dest_card = data.dest_card
            for i,v in ipairs(data.col_info.cards) do
                if dest_card ~= -1 and v == dest_card then
                    dest_card = -1
                else
                    table.insert(list,v)
                end
            end
            self:deleteHandTile(list,data.seat_index)
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
        data.iszhua = false
        self:setRestTileNum(self:getRestTileNum() -1)
        self.UILayer:refreshInfoNode()
        self.tablelist[data.seat_index + 1]:refreshXiaZhua(data)

        self:addHandTile(data.seat_index, data.dest_card)
        self.tablelist[data.seat_index + 1]:touPaiAction(data)
        return true

    elseif data.act_type == poker_common_pb.EN_SDR_ACTION_ZHUA then  --抓牌
        self:tableHideEffectnode()
        data.iszhua = true

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



--漂相关
function GameScene:SelectPiao(data)

	self.UILayer:gameStartAciton()
    -- self.UILayer.clock:setVisible(false)

    local piao_score = self:getSeatInfoByIdx(self:getMyIndex()).piao_score
    print("............SelectPiao.....piao_score = ",piao_score)
    if not piao_score or piao_score == -1 then
        if not data then
            if not piao_score  then
                piao_score = 0
            end
            data = {can_pass = (piao_score == -1),
                    min_score = piao_score, }
        end
        local selectnode = cc.Node:create()
        selectnode:setPosition(display.cx,display.cy)
        local btn1 = ccui.Button:create("game/btn_pao.png", "game/btn_pao.png", "game/btn_pao.png", ccui.TextureResType.localType)
        selectnode:addChild(btn1)
        self:addChild(selectnode)
        btn1:setPositionX(0)
        WidgetUtils.addClickEvent(btn1,function ()
            self:clickPiaoBtn(selectnode,btn1,data.min_score)
        end)

        if data.can_pass then
            local btn2 = ccui.Button:create("game/btn_guo.png", "game/btn_guo.png", "game/btn_guo.png", ccui.TextureResType.localType)
            selectnode:addChild(btn2)
            btn1:setPositionX(-100)
            btn2:setPositionX(100)
            
            WidgetUtils.addClickEvent(btn2,function ()
                self:requestPiao(0)
                selectnode:removeFromParent()
            end)
        end
    end

    for i,v in ipairs(self:getSeatsInfo()) do
        if  v.index == self:getMyIndex() then

            print("我的漂的状态......v.piao_score == ",v.piao_score)
            print("我的漂的状态......v.piao_score == ",v.piao_score)
        end


        if not v.piao_score or v.piao_score == -1 then
            self.tablelist[v.index+1]:setPiao(-1)
        else
            self.tablelist[v.index+1]:setPiao(v.piao_score)
        end
    end
end
function GameScene:responseSelectPiao( data )
    -- if data.result == 0 then
    --     data.seat_index = self:getMyIndex()
    --     self:notifyPiao(data)
    -- end
end
function GameScene:notifyPiao( data )

    print("GameScene:notifyPiao( data )")
    printTable(data,"xp26")

    local _score = data.piao_score or 0
    if _score > 0 then
        self:getSeatInfoByIdx(data.seat_index).is_piao = true
    else
        self:getSeatInfoByIdx(data.seat_index).is_piao = false
        _score = 0
    end
    self:getSeatInfoByIdx(data.seat_index).piao_score = _score
    self.tablelist[data.seat_index+1]:setPiao(_score)
end

-- 生成飘的2级页面
function GameScene:clickPiaoBtn(selectnode,btn,min_score)
	
	if btn.layer and tolua.cast(btn.layer,"cc.Node") then
		btn.layer:removeFromParent()
		btn.layer = nil
		return
	end

	btn.layer = cc.Node:create()
		:addTo(selectnode)
    
    local _list = {}
    print(".............piao_score = ",self:getTableConf().piao_score)
    for i=1,self:getTableConf().piao_score do
        table.insert(_list,i)
    end

	local bg = ccui.ImageView:create("game/action_bg.png")
        :setScale9Enabled(true)
        :setCapInsets(cc.rect(30, 30, 44, 44))
        :setAnchorPoint(cc.p(0.5, 0))
        bg:setLocalZOrder(-1)
        bg:setContentSize(cc.size(56 + 44 + 92 *(#_list - 1), 76 + 76))
        btn.layer:addChild(bg)

    local jiantou = ccui.ImageView:create("game/action_arrow.png")
        jiantou:setAnchorPoint(cc.p(0.5, 1))
        jiantou:setPositionX(bg:getContentSize().width / 2.0)
        bg:addChild(jiantou)

   	-- 生成选择项
    for k,v in pairs(_list) do
        -- local node = self:createSelectNode(v)
        local node = cc.Node:create()

        local btn = ccui.Button:create("game/piaobtn/piao_yellow_"..v..".png", "game/piaobtn/piao_yellow_"..v..".png", "game/piaobtn/piao_gray_"..v..".png", ccui.TextureResType.localType)
	    btn:setAnchorPoint(cc.p(0.5, 0.5))
	    btn:setScale9Enabled(true)
	    btn:setPositionX(0)
	    btn:setPositionY(0)

        if min_score > v then
            btn:setBright(false)
            btn:setTouchEnabled(false)
        end

	    WidgetUtils.addClickEvent(btn, function()
	        -- self:sendAction(_tab)
            self:requestPiao(v)
	        if tolua.cast(selectnode,"cc.Node") then
	        	selectnode:removeFromParent()
	        end
	    end )
	    node:addChild(btn)

        node:setPositionX(28 + 22 +(k - 1) * 92)
        node:setPositionY(bg:getContentSize().height / 2.0)
        bg:addChild(node)
    end

    local _x, _y = btn:getPosition()
    btn.layer:setPosition(cc.p(_x, _y + 80))
end

function GameScene:requestPiao(piao_score)
    local msg = poker_msg_pb.PBCSMsg()
    local request = msg.cs_request_select_piao
    request.is_piao = true
    request.piao_score = piao_score
    SocketConnect_instance:send("cs_request_select_piao", msg)
end


return GameScene