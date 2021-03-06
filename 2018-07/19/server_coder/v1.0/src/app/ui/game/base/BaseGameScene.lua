-- 游戏场景基类
local BaseGameScene = class("BaseGameScene", function()
    return cc.Scene:create()
end )



function BaseGameScene:ctor(data, path)
    LocalData_instance:setbaipai_stype_real()
    self.name = "BaseGameScene"
    self.path = path
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
    print("seatsinfo")
    printTable(seatsinfo,"sjp3")
    self.table_info.sdr_seats = seatsinfo

end
-- 根据idx获取座位信息,idx为服务器idx
function BaseGameScene:getSeatInfoByIdx(idx)
    for i, v in ipairs(self.table_info.sdr_seats) do
        -- print(v.index,idx)
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
function BaseGameScene:setJiangCard(card)
    self.table_info.jiang_card  = card 
end


--获取是否是将牌
function BaseGameScene:getIsJiangCard(_card)
    
    if not self.table_info.jiang_card or self.table_info.jiang_card == 0 or not _card or _card == 0  then
        return false
    end

    --来凤上大人只有将牌一种，其他的是一列三种
    if self:getTableConf().ttype == HPGAMETYPE.LFSDR or self:getTableConf().ttype == HPGAMETYPE.FJSDR then
        if self.table_info.jiang_card == _card then
            return true
        end
    else
        if math.floor(self.table_info.jiang_card/16) == math.floor(_card/16)  then
            return true
        end

    end

    
    return false
end

function BaseGameScene:setJokerCard(card)
    self.table_info.joker_card  = card 
end
--获取是否是癞子
function BaseGameScene:getIsJokerCard(_card)
    
    if not self.table_info.joker_card or self.table_info.joker_card == 0 or not _card or _card == 0  then
        return false
    end

    if self.table_info.joker_card == _card then
        return true
    end
    
    return false
end



-------------------------------手牌处理
-- 根据位置索引获取手牌
function BaseGameScene:getHandTileByIdx(idx)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            return v.hand_cards or { }
        end
    end
    return { }
end
-- 给手牌添加一张牌
function BaseGameScene:addHandTile(idx, value)

    if self.name == "GameScene" and idx ~= self:getMyIndex() then
        return
    end

    if self.name == "GameScene" then
        self:addDebugList("a_H",{value})
    end

    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            if v.hand_cards and type(v.hand_cards) == "table" then
                table.insert(v.hand_cards, value)
                break
            end
            break
        end
    end
    if (idx == self:getMyIndex() and self:getTableConf().ttype == HPGAMETYPE.SJHP) or (idx == self:getMyIndex() and self:getTableConf().ttype == HPGAMETYPE.WJHP)  then
        self.mytable:addHandTile(value)
    end
end

-- 删除手牌
function BaseGameScene:deleteHandTile(valuelist, seat_index,data)

    if self.name == "GameScene" and seat_index ~= self:getMyIndex() then
        return
    end

    print("删除手牌,deleteHandTile")
    printTable(valuelist,"xp")

    if self.name == "GameScene" then
        self:addDebugList("d_H",valuelist)
    end

    for i, v in ipairs(self.table_info.sdr_seats) do
        -- printTable(v,"xp")

        if v.index == seat_index then
            -- print("................我的手牌！！！数量 ",#v.hand_cards)           
            -- printTable(v.hand_cards,"xp09")
            for ii, vv in ipairs(valuelist) do
                for iii, vvv in ipairs(v.hand_cards) do
                    if vvv == vv then
                        table.remove(v.hand_cards, iii)
                        break
                    end
                end
            end
            -- print("................我的手牌！！！数量 ",#v.hand_cards)
            -- printTable(v.hand_cards,"xp09")

            if self.name == "GameScene" and v.index == self:getMyIndex() then
                if  self:getTableConf().ttype == HPGAMETYPE.TCGZP then
                    self.mytable:deleteHandCard(valuelist,data)
                end
            end
            -- print(".....删除后....我的手牌！！！数量 ",#v.hand_cards)
            break
        end
    end
    if (self:getTableConf().ttype == HPGAMETYPE.SJHP or self:getTableConf().ttype == HPGAMETYPE.WJHP) and seat_index == self:getMyIndex() then
        self.mytable:deletitles(valuelist)
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
function BaseGameScene:addPutoutTile(idx, value)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            if not v.out_cards then
                v.out_cards = { }
            end
            table.insert(v.out_cards, value)
            return value
        end
    end
    return false
end

-------------------------------弃牌处理
-- 根据位置索引获取打出的牌
function BaseGameScene:getDiscardTileByIdx(idx)

    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            print(".........BaseGameScene:getDiscardTileByIdx")
            printTable(v.discards)

            return v.discards or { }
        end
    end
    return {}
end
-- 给指定位置添加一张打出的牌
function BaseGameScene:addDisardTile(idx, value)

    print(".........BaseGameScene:addDisardTile")
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            if not v.discards then
                v.discards = { }
            end
            table.insert(v.discards, value)
            return value
        end
    end
    return false
end 


-------------------------------摆牌处理
-- 根据位置索引获取摆出来的牌
function BaseGameScene:getShowTileByIdx(idx)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            return v.out_col or { }
        end
    end
    return { }
end
-- 给指定位置添加一组摆出来的牌
function BaseGameScene:addShowTile(idx, data)


    print(".....指定位置添加一组摆出来的牌")
    printTable(data,"xp24")


    if self.name == "GameScene" and idx == self:getMyIndex() then
        -- print(".....指定位置添加一组摆出来的牌")
        -- printTable(data,"xp99")
        local _li = {}
        _li.col_type = data.col_type or 0
        _li.cards = data.original_cards or data.cards or nil
        _li.token = data.token or -1

        self:addDebugList("a_s",_li)
    end


    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            if not v.out_col then
                v.out_col = {}
                table.insert(v.out_col, data)
            else
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

-- 添加下抓
function BaseGameScene:addXiaZhua(idx)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            v["disable_4_times"] = v["disable_4_times"] + 1     
        end
    end
end

--设置亮拢的牌
function BaseGameScene:setLongCard(idx,_longcard)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
           v.long_card = _longcard
        end
    end
end

function BaseGameScene:getLongCard(idx)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
           return v.long_card
        end
    end
    return -1
end
function BaseGameScene:setUpdataHuInfo(data)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == self:getMyIndex() then
            v.check_hu_info = data
        end
    end
end

function BaseGameScene:getUpdataHuInfo()
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == self:getMyIndex() then
            return v.check_hu_info
        end
    end
    return nil
end

function BaseGameScene:getGuanTimes(idx) 
   for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == self:getMyIndex() then
             return v.guan_times or 0
        end
    end
    return 0
end


function BaseGameScene:setGuanTimes(data) 
   for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == data.seat_index then
            v.guan_times = data.guan_times
        end
    end
end


return BaseGameScene