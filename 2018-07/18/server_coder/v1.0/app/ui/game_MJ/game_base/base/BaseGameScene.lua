-- 游戏场景基类
local BaseGameScene = class("BaseGameScene", function()
    return cc.Scene:create()
end )



function BaseGameScene:ctor(data, path)
    LocalData_instance:setbaipai_stype_real()
    self.name = "BaseGameScene"
    self.path = path
    self.Suanfuc = nil
    self:initData(data)
    self:initView()
    self:initEvent()
end

function BaseGameScene:initEvent()
    local function update()
        self:onUpdate()
    end
    self:scheduleUpdateWithPriorityLua(update, 0)

    self:registerScriptHandler( function(state)
        print("--------------" .. state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end )

    self:registerNetEventListener()
end

-- 数据处理
function BaseGameScene:initData(data)

    self.table_info = data.table_info
    LocalData_instance:setGameType(self:getTableConf().ttype)
end

-- 获取重连时的actionchoice
function BaseGameScene:getActionChoiceByIdx(idx)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            if v.action_choice and v.action_choice.is_determine then
                return false
            end
            return v.action_choice and v.action_choice.choices, v.action_token
        end
    end
    return false
end
function BaseGameScene:getTableState()
    return self.table_info.state
end
function BaseGameScene:setTableState(state)
    self.table_info.state = state
end
-- 获取所有座位信息
function BaseGameScene:getSeatsInfo()
    return self.table_info.sdr_seats
end
-- 设置座位信息
function BaseGameScene:setSeatsInfo(seatsinfo)
    self.table_info.sdr_seats = seatsinfo

end
-- 根据idx获取座位信息,idx为服务器idx
function BaseGameScene:getSeatInfoByIdx(idx)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            return v
        end
    end
    return false
end
-- 更改指定座位信息
function BaseGameScene:setSeatInfo(info)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == info.index then
            self.table_info.sdr_seats[i] = clone(info)
            print("查找到了")
        end
    end
    return false
end

-- 获取自己的服务器位置索引
function BaseGameScene:getMyIndex()
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.user and v.user.uid == LocalData_instance:getUid() then
        -- if v.user and v.user.uid == 10344 then
            return v.index
        end
    end
    --如果是回放界面，如果没找到自己，就默认是1
    if self.name == "RecordScene" then
        return 1
    end
    return -1
end
-- 根据uid获取服务器位置索引
function BaseGameScene:getIndexByUID(uid)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.user and v.user.uid == uid then
            return v.index
        end
    end

    return false
end
-- 根据uid获取性别
function BaseGameScene:getSexByUid(uid)
    if not uid then
        print("uid 为空")
        return nil
    end
    local gender = nil
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.user and v.user.uid == tonumber(uid) then
            gender = v.user.gender
            break
        end
    end
    print("性别..gender=", gender)
    return gender
end
-- 根据uid获取性别
function BaseGameScene:getSexByIndex(idx)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            if v.user then
                return v.user.gender
            end
        end
    end
    return nil
end


-- 断线重连后，获取解散房间的信息
function BaseGameScene:getDissolveInfo()
    local _data = { }
    -- _data.uid = self.table_info.dissolve_info.start_uid
    _data.dissolve_info = self.table_info.dissolve_info

    -- _data.vote_down

    return _data
end


-- 获取房间配置
function BaseGameScene:getTableConf()
    return self.table_info.sdr_conf
end
-- 获取房间ID
function BaseGameScene:getTableID()
    return self.table_info.tid
end

-- 获取房主ID
function BaseGameScene:getTableCreaterID()
    return self.table_info.sdr_conf.creator_uid
end
-- 获取庄的索引
function BaseGameScene:getDealerIndex()
    return self.table_info.dealer or -1
end
function BaseGameScene:setDealerIndex(idx)
    self.table_info.dealer = idx
end

-- 获取庄的索引
function BaseGameScene:getOldDealerIndex()
    return self.table_info.dealer_index_2 or -1
end
function BaseGameScene:setOldDealerIndex(idx)
    self.table_info.dealer_index_2 = idx
end

-- 获小家的索引
function BaseGameScene:getXiaoJiaIndex()
    return self.table_info.xiaojia_index or -1
end
function BaseGameScene:setXiaoJiaIndex(idx)
    self.table_info.xiaojia_index = idx
end


function BaseGameScene:getDealerUid()
    local dealerData = self.table_info.sdr_seats[self.table_info.dealer + 1]
    if dealerData and dealerData.user then
        return dealerData.user.uid
    end
    return -1
end


-- 获取剩余牌的数量
function BaseGameScene:getRestTileNum()
    return self.table_info.left_card_num or 0
end
function BaseGameScene:setRestTileNum(num)
    self.table_info.left_card_num = num
end
-- 获取当前局数
function BaseGameScene:getNowRound()
    return self.table_info.round or 0
end
function BaseGameScene:setNowRound(round)
    self.table_info.round = round
end

function BaseGameScene:getUserInfoByUid(uid)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.user and v.user.uid == uid then
            return v.user
        end
    end
    return nil
end

----------设置癞子牌
function BaseGameScene:setJokerCard(card)
    self.table_info.laizi_card  = card 
end
function BaseGameScene:getJokerCard()
    return self.table_info.laizi_card
end
--获取是否是癞子
function BaseGameScene:getIsJokerCard(_card)
    
    if not self.table_info.laizi_card or self.table_info.laizi_card == 0 or not _card or _card == 0  then
        return false
    end

    if self.table_info.laizi_card == _card then
        return true
    end
    
    return false
end


----------设置癞子牌
function BaseGameScene:setPiziCard(card)
    self.table_info.pizi_card  = card 
end
function BaseGameScene:getPiziCard()
    return self.table_info.pizi_card
end
--获取是否是癞子
function BaseGameScene:getIsPiziCard(_card)
    
    if not self.table_info.pizi_card or self.table_info.pizi_card == 0 or not _card or _card == 0  then
        return false
    end

    if self.table_info.pizi_card == _card then
        return true
    end
    
    return false
end

-------------------------------手牌处理
-- 根据位置索引获取手牌
function BaseGameScene:getHandCardsByIdx(idx)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            return v.hand_cards or { }
        end
    end
    return { }
end
-- 给手牌添加一张牌
function BaseGameScene:addHandCard(_data)

    if self.name == "GameScene" then
        self:addDebugList("a_H",{_data.dest_card})
    end
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == _data.seat_index then
            -- if _data.seat_index == self:getMyIndex()  then
                if v.hand_cards and type(v.hand_cards) == "table" then
                    table.insert(v.hand_cards, _data.dest_card)
                    return
                end
            -- else

            -- end
          
            break
        end
    end
end
-- 删除手牌
function BaseGameScene:deleteHandCard(_data)

    local seat_index = _data.seat_index 
    local valuelist = self.Suanfuc:getDeleteList(_data)

    print("删除手牌,deleteHandCard")
    printTable(valuelist,"xp70")

    -- if self.name == "GameScene" then
    --     self:addDebugList("d_H",valuelist)
    -- end

    for i, v in ipairs(self.table_info.sdr_seats) do
        -- printTable(v,"xp")
        if v.index == seat_index then
            if  seat_index == self:getMyIndex() or self.name == "RecordScene" then
                print("................我的手牌！！！数量 ",#v.hand_cards)
                for ii, vv in ipairs(valuelist) do
                    for iii, vvv in ipairs(v.hand_cards) do
                        if vvv == vv then
                            table.remove(v.hand_cards, iii)
                            break
                        end
                    end
                end
                print("................我的手牌！！！数量 ",#v.hand_cards)
            else
                --别人家删除手牌
                print("................别人的手牌！！！数量 ",#v.hand_cards)
                for ii, vv in ipairs(valuelist) do
                    table.remove(v.hand_cards, #v.hand_cards)
                end 
                print("................别人的手牌！！！数量 ",#v.hand_cards)
            end
            return
        end
    end
end

-------------------------------出牌处理
-- 根据位置索引获取打出的牌
function BaseGameScene:getPutoutTileByIdx(idx)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            return v.out_cards or { }
        end
    end
    return { }
end
-- 给指定位置添加一张打出的牌
function BaseGameScene:addOutCard(_data)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == _data.seat_index then
            if not v.out_cards then
                v.out_cards = { }
            end
            table.insert(v.out_cards, _data.dest_card)
        end
    end
    return false
end

-------------------------------摆牌处理
-- 根据位置索引获取摆出来的牌
function BaseGameScene:getShowCardsByIdx(idx)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            return v.out_col or { }
        end
    end
    return { }
end
-- 给指定位置添加一组摆出来的牌
function BaseGameScene:addShowCard(_data)

    print(".....指定位置添加一组摆出来的牌")
    printTable(_data,"xp99")

    local data = _data.col_info
    if self.name == "GameScene" and _data.seat_index == self:getMyIndex() then
        local _li = {}
        _li.col_type = data.col_type or 0
        _li.cards = data.original_cards or data.cards or nil
        _li.token = data.token or -1

        self:addDebugList("a_s",_li)
    end

    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == _data.seat_index then
            if not v.out_col then
                v.out_col = {}
                table.insert(v.out_col, data)
            else
                -- if self.name == "GameScene" and _data.seat_index == self:getMyIndex() then
                    -- print(".....我自己的摆牌")
                    -- printTable(v.out_col,"xp99")
                -- end
                local isHave = false
                for ii,vv in ipairs(v.out_col) do
                    if vv.token and data.token and vv.token == data.token then
                        v.out_col[ii] = data
                        isHave = true
                    end
                end

                if isHave == false then
                    table.insert(v.out_col, data)    
                end

                 -- if self.name == "GameScene" and _data.seat_index == self:getMyIndex() then
                    -- print(".....我自己的摆牌 后")
                    -- printTable(v.out_col,"xp99")
                -- end
            end
            return
        end
    end
end

function BaseGameScene:getLastestAction()
    if self.table_info.sdr_total_action_flows then
        return self.table_info.sdr_total_action_flows[#self.table_info.sdr_total_action_flows]
    else
        return false
    end
end

-- override
function BaseGameScene:initView()
    -- body
end
function BaseGameScene:onUpdate()
    -- body
end
function BaseGameScene:onEnter()
    -- body
    Notinode_instance:showLoadingByLogined()
end
function BaseGameScene:onExit()
    -- body
end
function BaseGameScene:registerNetEventListener()
    -- body
end
--恩施麻将的特殊需求
function BaseGameScene:getIsHavePlay(tag)
    -- repeated int32 game_play_type_2 = 41;    // 多选玩法类型 0->抬杠 1->杠上炮 2->禁止养痞 3->打癞禁胡 4->打痞禁胡
    local _palyList = self:getTableConf().game_play_type_2
    if _palyList and #_palyList > 0  then
        for k,v in pairs(_palyList) do
            if v == tag then
                return true
            end
        end
    end
    return false
end


return BaseGameScene