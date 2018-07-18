local RecordScene = class("RecordScene", require "app.ui.game.RecordScene")

local PokerCard = require "app.ui.game_poker.PokerCard"
function RecordScene:createCardSprite(typemj,value,isgray)
	return PokerCard.new(typemj, value, isgray)
end

function RecordScene:initView(data)
    self.layout = cc.CSLoader:createNode("ui/gamexj/gameBase.csb")
        :addTo(self)

    self.UILayer = require("app.ui.game_poker.GameUILayer").new(self)
    :addTo(self.layout:getChildByName("UInode"))
    :setPosition(cc.p(0, 0))

    WidgetUtils.setScalepos(self.layout)
    self.UILayer:hideNormalBtn()

    self:initTable()

    self:refreshScene()
    self:setbgstype()

    self:initRecordPlayer(data)

    
    self:setJiangCard(self.table_info.jiang_card)
    self.UILayer:setJiangCard(self.table_info.jiang_card)

end

function RecordScene:initTable()
    local tableBase = require(self.path .. ".GameTable")
    local gameAction = require(self.path .. ".ActionView")
    local bottomtable = require("app.ui.game_poker.TableBottom").create(tableBase, gameAction).new(self.layout:getChildByName("bottomnode"), self)
    local toptable = require("app.ui.game_poker.TableTop").create(tableBase).new(self.layout:getChildByName("topnode"), self)
    local lefttable = require("app.ui.game_poker.TableLeft").create(tableBase).new(self.layout:getChildByName("leftnode"), self)
    local righttable = require("app.ui.game_poker.TableRight").create(tableBase).new(self.layout:getChildByName("rightnode"), self)

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
        v:showNode()
        v:setTableIndex(i - 1)
    end

    self.mytable = bottomtable

    self:otherInitView()

end

function RecordScene:priorityAction(data)
    if data.act_type == poker_common_pb.EN_SDR_ACTION_PAO then --明杠为抓
        self:tableHideEffectnode()

        self:addShowTile(data.seat_index, data.col_info)
        if data.dele_hand_cards then
            self:deleteHandTile(data.dele_hand_cards,data.seat_index)
        else
            local deleteList = data.col_info.cards
            if data.col_info.is_waichi == true then
                local card = data.col_info.cards[1]
                deleteList = {card,card,card,card}
            end
            deleteList = {data.col_info.cards[1],data.col_info.cards[2],data.col_info.cards[3],data.col_info.cards[4]}
        end

        self.tablelist[data.seat_index + 1]:paoPaiAction(data,hidenAnimation)

        return true
    end

    return false
end

-- 给手牌添加一张牌
function RecordScene:addHandTile(idx, value)

    if self.name == "GameScene" then
        self:addDebugList("a_H",{value})
    end

    for i, v in ipairs(self.table_info.sdr_seats) do
        if v.index == idx then
            if v.hand_cards and type(v.hand_cards) == "table" then
                if self.name == "GameScene" and idx ~= self:getMyIndex() then
                    table.insert(v.hand_cards, 0)
                else
                    table.insert(v.hand_cards, value)
                end
                
                return
            end
            break
        end
    end
end

function RecordScene:deleteHandTile(valuelist, seat_index)

    -- if self.name == "GameScene" and seat_index ~= self:getMyIndex() then
    --     return
    -- end

    print("删除手牌,deleteHandTile")
    printTable(valuelist,"xp")


    if self.name == "GameScene" then
        self:addDebugList("d_H",valuelist)
    end

    for i, v in ipairs(self.table_info.sdr_seats) do
        -- printTable(v,"xp")

        if v.index == seat_index then

            -- print("................我的手牌！！！数量 ",#v.hand_cards)
            for ii, vv in ipairs(valuelist) do
                for iii, vvv in ipairs(v.hand_cards) do
                    if self.name == "GameScene" and seat_index ~= self:getMyIndex() then
                        if vvv == 0 then
                            table.remove(v.hand_cards, iii)
                        end
                        break
                    else
                        if vvv == vv then
                            table.remove(v.hand_cards, iii)
                            break
                        end
                    end
                end
            end
            -- print(".....删除后....我的手牌！！！数量 ",#v.hand_cards)
            return
        end
    end
end

return RecordScene