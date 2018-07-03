-- 游戏场景基类
local BaseGameScene = class("BaseGameScene", function()
    return cc.Scene:create()
end )

function BaseGameScene:ctor(data, path)

    
    
    LAIZIVALUE_LOCAL = -1
    LocalData_instance:setbaipai_stype_real()
    self.name = "BaseGameScene"
    self.path = path
    self:initData(data)
    -- LocalData_instance:setNowGameType(self:getTableConf().ttype)
    self:initView()
    self:initEvent()

    AudioUtils.playMusic("ddzroombgm",true)
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

    self._data = {}
    self._data.mingPai = false  --  明牌开关

    -- 经典斗地主开启明牌功能
    if (self.table_info.sdr_conf.ttype == HPGAMETYPE.JDDDZ) then
        self:setMingPai(true)
    end
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
            return v.index
        end
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
    -- print("获取庄:"..self.table_info.dealer)
    return self.table_info.dealer or -1
end
function BaseGameScene:setDealerIndex(idx)
    print("设置庄:"..self.table_info.dealer)
    self.table_info.dealer = idx
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
        --self:addDebugList("a_H",{value})
    end

    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            if v.hand_cards and type(v.hand_cards) == "table" then
                table.insert(v.hand_cards, value)
                return
            end
            break
        end
    end
end
-- 删除手牌
function BaseGameScene:deleteHandTile(valuelist, seat_index)

    -- if self.name == "GameScene" then
    if self.name == "GameScene" and not self:isMingPaiByIdx(seat_index) then
        if seat_index ~= self:getMyIndex() then 
            for i, v in ipairs(self.table_info.sdr_seats) do
                if v.index == seat_index then
                   for i1,v1 in ipairs(valuelist) do
                       table.remove(v.hand_cards,1)
                   end
                end
            end
        end
        return
    end


    for i, v in ipairs(self.table_info.sdr_seats) do
        -- printTable(v,"xp")

        if v.index == seat_index then

            -- print("................我的手牌！！！数量 ",#v.hand_cards)
            for ii, vv in ipairs(valuelist) do
                for iii, vvv in ipairs(v.hand_cards) do
                    if vvv == vv then
                        table.remove(v.hand_cards, iii)
                        break
                    end
                end
            end
            print(".....删除后....我的手牌！！！数量 ",#v.hand_cards)
            return
        end
    end
end
-- 设置手牌
function BaseGameScene:setHandTileByIdx(idx, cards)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            self.table_info.sdr_seats[i].hand_cards = cards
            break
        end
    end
end
-- 设置明牌状态
function BaseGameScene:setMingPaiByIdx(idx, value)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            self.table_info.sdr_seats[i].is_mingpai = value
            break
        end
    end
end
-- 是否明牌
function BaseGameScene:isMingPaiByIdx(idx)
    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            if (v.is_mingpai and v.is_mingpai == 1) then
                return true
            end
            return false
        end
    end

    return false
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
function BaseGameScene:setDoublevalue(tableindex,value)
    local info = self:getSeatInfoByIdx(tableindex)
    info.double_times = value
end

function BaseGameScene:getDoubleValue(tableindex)
    local info = self:getSeatInfoByIdx(tableindex)
    return info.double_times
end
function BaseGameScene:setDiZhuCards(_list)
    self.table_info.dipai_cards = _list
end

function BaseGameScene:getDiZhuCards(_list)
    return  self.table_info.dipai_cards or {}
end

-- 获取明牌开关
function BaseGameScene:getMingPai()
    return self._data.mingPai
end

-- 设置明牌开关
function BaseGameScene:setMingPai(status)
    self._data.mingPai = status
end

return BaseGameScene